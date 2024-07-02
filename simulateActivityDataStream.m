% Main script to run the simulation
activityFolders = {
    'C:\Users\KRUPESH\OneDrive\Desktop\SCS\Elderly-Fall-Detection-System\MobiAct_Dataset_v2.0\Annotated Data\SLH', ...
    'C:\Users\KRUPESH\OneDrive\Desktop\SCS\Elderly-Fall-Detection-System\MobiAct_Dataset_v2.0\Annotated Data\SBW', ...
    'C:\Users\KRUPESH\OneDrive\Desktop\SCS\Elderly-Fall-Detection-System\MobiAct_Dataset_v2.0\Annotated Data\SLW', ...
    'C:\Users\KRUPESH\OneDrive\Desktop\SCS\Elderly-Fall-Detection-System\MobiAct_Dataset_v2.0\Annotated Data\SBE', ...
    'C:\Users\KRUPESH\OneDrive\Desktop\SCS\Elderly-Fall-Detection-System\MobiAct_Dataset_v2.0\Annotated Data\SRH'
};

fallFolders = {
    'C:\Users\KRUPESH\OneDrive\Desktop\SCS\Elderly-Fall-Detection-System\MobiAct_Dataset_v2.0\Annotated Data\BSC', ...
    'C:\Users\KRUPESH\OneDrive\Desktop\SCS\Elderly-Fall-Detection-System\MobiAct_Dataset_v2.0\Annotated Data\FKL', ...
    'C:\Users\KRUPESH\OneDrive\Desktop\SCS\Elderly-Fall-Detection-System\MobiAct_Dataset_v2.0\Annotated Data\FOL', ...
    'C:\Users\KRUPESH\OneDrive\Desktop\SCS\Elderly-Fall-Detection-System\MobiAct_Dataset_v2.0\Annotated Data\SDL'
};

% Set switch time in seconds (set to empty for random switching)
switchTime = 10; % Example: switch after 10 seconds

simulateDataStream(activityFolders, fallFolders, switchTime);

% Define local functions within the script

function simulateDataStream(activityFolders, fallFolders, switchTime)
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
    maxIterations = 100;
    iteration = 0;

    % Initialize a structure to accumulate data for visualization
    windowSize = 1000; % Adjust as needed for performance
    accumulatedData = initializeAccumulatedData(windowSize);
    
    % Initialize plot handles
    fig1 = initializePlot('Relative Time Visualization');
    fig2 = initializePlot('Actual Time Visualization');
    
    % Initialize elapsed time
    elapsedTime = 0;

    % Randomly select and stream data from activity files
    while iteration < maxIterations
        iteration = iteration + 1;

        % Select a random activity file
        activityFile = selectRandomFile(activityFiles);
        fprintf('Streaming activity data from %s\n', activityFile.name);
        [accumulatedData, elapsedTime] = streamAnnotatedData(activityFile, @processData, accumulatedData, 'activity', fig1, fig2, fallFiles, switchTime, elapsedTime);

        % Switch to fall scenario after the activity file
        fallFile = selectRandomFile(fallFiles);
        fprintf('Switching to fall data from %s\n', fallFile.name);
        [accumulatedData, elapsedTime] = streamAnnotatedData(fallFile, @processData, accumulatedData, 'fall', fig1, fig2, fallFiles, switchTime, elapsedTime);
    end
end

function [accumulatedData, elapsedTime] = streamAnnotatedData(file, processingFunction, accumulatedData, eventType, fig1, fig2, fallFiles, switchTime, elapsedTime)
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

        % Accumulate data for visualization
        accumulatedData = accumulateData(accumulatedData, data(i, :));
        
        % Process current data point only
        processingFunction(data(i, :));

        % Update plots with the new data
        updatePlots(fig1, fig2, accumulatedData);

        % Simulate a switch to fall scenario after the specified time
        if strcmp(eventType, 'activity') && relTime >= (elapsedTime + switchAfter)
            fallFile = selectRandomFile(fallFiles);
            fprintf('Switching to fall data from %s\n', fallFile.name);
            [accumulatedData, elapsedTime] = streamAnnotatedData(fallFile, processingFunction, accumulatedData, 'fall', fig1, fig2, fallFiles, switchTime, relTime);
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

function processData(data)
    % Implement your processing logic here
    % Example: Display the current activity data
    disp('Processing data:');
    disp(data); % Display the current activity data (for debugging)
end

function updatePlots(fig1, fig2, data)
    % Update plots with the new data
    figure(fig1);
    subplot(3, 1, 1);
    plot(data.rel_time, data.acc_x, '-r', data.rel_time, data.acc_y, '-g', data.rel_time, data.acc_z, '-b');
    title('Accelerometer Data (Relative Time)');
    xlabel('Relative Time (s)');
    ylabel('Acceleration');
    legend({'X', 'Y', 'Z'});
    hold on;

    subplot(3, 1, 2);
    plot(data.rel_time, data.gyro_x, '-r', data.rel_time, data.gyro_y, '-g', data.rel_time, data.gyro_z, '-b');
    title('Gyroscope Data (Relative Time)');
    xlabel('Relative Time (s)');
    ylabel('Angular Velocity');
    legend({'X', 'Y', 'Z'});
    hold on;

    subplot(3, 1, 3);
    plot(data.rel_time, data.azimuth, '-r', data.rel_time, data.pitch, '-g', data.rel_time, data.roll, '-b');
    title('Orientation Data (Relative Time)');
    xlabel('Relative Time (s)');
    ylabel('Angle');
    legend({'Azimuth', 'Pitch', 'Roll'});
    hold on;

    figure(fig2);
    subplot(3, 1, 1);
    plot(data.timestamp, data.acc_x, '-r', data.timestamp, data.acc_y, '-g', data.timestamp, data.acc_z, '-b');
    title('Accelerometer Data (Actual Time)');
    xlabel('Time');
    ylabel('Acceleration');
    legend({'X', 'Y', 'Z'});
    hold on;

    subplot(3, 1, 2);
    plot(data.timestamp, data.gyro_x, '-r', data.timestamp, data.gyro_y, '-g', data.timestamp, data.gyro_z, '-b');
    title('Gyroscope Data (Actual Time)');
    xlabel('Time');
    ylabel('Angular Velocity');
    legend({'X', 'Y', 'Z'});
    hold on;

    subplot(3, 1, 3);
    plot(data.timestamp, data.azimuth, '-r', data.timestamp, data.pitch, '-g', data.timestamp, data.roll, '-b');
    title('Orientation Data (Actual Time)');
    xlabel('Time');
    ylabel('Angle');
    legend({'Azimuth', 'Pitch', 'Roll'});
    hold on;

    drawnow; % Update the plots immediately
end

function fig = initializePlot(figName)
    fig = figure('Name', figName);
    subplot(3, 1, 1);
    hold on;
    subplot(3, 1, 2);
    hold on;
    subplot(3, 1, 3);
    hold on;
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
