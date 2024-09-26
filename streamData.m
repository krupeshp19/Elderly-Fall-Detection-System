function streamData(activityFolders, fallFolders, switchTime, RFModel)
    % List files from the directories
    activityFiles = [];
    for i = 1:length(activityFolders)
        activityFiles = [activityFiles; listFiles(activityFolders{i})]; %#ok<AGROW>
    end
    
    fallFiles = [];
    for i = 1:length(fallFolders)
        fallFiles = [fallFiles; listFiles(fallFolders{i})]; %#ok<AGROW>
    end

    % Set a maximum number of iterations to prevent infinite loop
    maxIterations = 10;
    iteration = 0;

    % Initialize a structure to accumulate data
    windowSize = 20; % Adjust as needed for performance
    accumulatedData = initializeAccumulatedData(windowSize);
    
    % Initialize elapsed time
    elapsedTime = 0;

    % Randomly select and stream data from activity files
    while iteration < maxIterations
        iteration = iteration + 1;

        % Select a random activity file
        activityFile = selectRandomFile(activityFiles);
        fprintf('Streaming activity data from %s\n', activityFile.name);
        [accumulatedData, elapsedTime] = streamAnnotatedData(activityFile, @processData, accumulatedData, 'activity', fallFiles, switchTime, elapsedTime, RFModel);

        % Switch to fall scenario after the activity file
        fallFile = selectRandomFile(fallFiles);
        fprintf('Switching to fall data from %s\n', fallFile.name);
        [accumulatedData, elapsedTime] = streamAnnotatedData(fallFile, @processData, accumulatedData, 'fall', fallFiles, switchTime, elapsedTime, RFModel);
    end
end

function [accumulatedData, elapsedTime] = streamAnnotatedData(file, processingFunction, accumulatedData, eventType, fallFiles, switchTime, elapsedTime, RFModel)
    data = loadAnnotatedFile(fullfile(file.folder, file.name));
    numSamples = height(data);
    startTime = datetime('now'); % Reset start time at the beginning of each file

    % Randomly decide when to switch to a fall scenario within the activity stream
    switchToFall = randi([1, numSamples]);
    if isempty(switchTime)
        switchAfter = switchToFall;
    else
        switchAfter = switchTime;
    end

    for i = 1:numSamples
        tic;
        currentTime = datetime('now');
        relTime = seconds(currentTime - startTime) + elapsedTime; % Correct relative time calculation
        data.timestamp(i) = posixtime(currentTime); % Convert current time to POSIX time (seconds since Unix epoch)
        data.rel_time(i) = relTime;

        % Accumulate data
        accumulatedData = accumulateData(accumulatedData, data(i, :));
        
        % Process current data point only
        processingFunction(data(i, :), RFModel);

        % Simulate a switch to fall scenario after the specified time
        if strcmp(eventType, 'activity') && relTime >= (elapsedTime + switchAfter)
            fallFile = selectRandomFile(fallFiles);
            fprintf('Switching to fall data from %s\n', fallFile.name);
            [accumulatedData, ~] = streamAnnotatedData(fallFile, processingFunction, accumulatedData, 'fall', fallFiles, switchTime, relTime, RFModel);
            break;
        end
        
        pauseTime = 0.1 - toc;
        if pauseTime > 0
            pause(pauseTime); % Adjust pause time dynamically
        end
    end
    
    % Update elapsedTime after finishing the current file
    elapsedTime = relTime;
end

function data = loadAnnotatedFile(filePath)
    try
        data = readtable(filePath, 'Delimiter', ',', 'ReadVariableNames', true);
        % Ensure that the data columns are as expected
        expectedColumns = {'timestamp', 'rel_time', 'acc_x', 'acc_y', 'acc_z', 'gyro_x', 'gyro_y', 'gyro_z', 'azimuth', 'pitch', 'roll', 'label'};
        if ~all(ismember(expectedColumns, data.Properties.VariableNames))
            error('The data file does not contain the expected columns.');
        end
    catch ME
        error('Error loading file %s: %s', filePath, ME.message);
    end
end

function accumulatedData = initializeAccumulatedData(windowSize)
    accumulatedData = struct('timestamp', NaN(windowSize, 1), 'rel_time', NaN(windowSize, 1), ...
                             'acc_x', NaN(windowSize, 1), 'acc_y', NaN(windowSize, 1), 'acc_z', NaN(windowSize, 1), ...
                             'gyro_x', NaN(windowSize, 1), 'gyro_y', NaN(windowSize, 1), 'gyro_z', NaN(windowSize, 1), ...
                             'azimuth', NaN(windowSize, 1), 'pitch', NaN(windowSize, 1), 'roll', NaN(windowSize, 1));
end

function accumulatedData = accumulateData(accumulatedData, newData)
    % Shift data for the rolling window effect
    accumulatedData.timestamp = [accumulatedData.timestamp(2:end); newData.timestamp];
    accumulatedData.rel_time = [accumulatedData.rel_time(2:end); newData.rel_time];
    accumulatedData.acc_x = [accumulatedData.acc_x(2:end); newData.acc_x];
    accumulatedData.acc_y = [accumulatedData.acc_y(2:end); newData.acc_y];
    accumulatedData.acc_z = [accumulatedData.acc_z(2:end); newData.acc_z];
    accumulatedData.gyro_x = [accumulatedData.gyro_x(2:end); newData.gyro_x];
    accumulatedData.gyro_y = [accumulatedData.gyro_y(2:end); newData.gyro_y];
    accumulatedData.gyro_z = [accumulatedData.gyro_z(2:end); newData.gyro_z];
    accumulatedData.azimuth = [accumulatedData.azimuth(2:end); newData.azimuth];
    accumulatedData.pitch = [accumulatedData.pitch(2:end); newData.pitch];
    accumulatedData.roll = [accumulatedData.roll(2:end); newData.roll];
end

function files = listFiles(directory)
    files = dir(fullfile(directory, '*.csv'));
end

function file = selectRandomFile(files)
    index = randi(length(files));
    file = files(index);
end
