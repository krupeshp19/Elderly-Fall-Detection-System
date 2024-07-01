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

simulateDataStream(activityFolders, fallFolders);

% Define local functions within the script

function simulateDataStream(activityFolders, fallFolders)
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
    
    % Randomly select and stream data from activity files
    while iteration < maxIterations
        iteration = iteration + 1;

        % Select a random activity file
        activityFile = selectRandomFile(activityFiles);
        fprintf('Streaming activity data from %s\n', activityFile.name);
        accumulatedData = streamAnnotatedData(activityFile, @processData, accumulatedData, 'activity', fig1, fig2);

        % Ensure a fall scenario occurs after each activity file
        fallFile = selectRandomFile(fallFiles);
        fprintf('Switching to fall data from %s\n', fallFile.name);
        accumulatedData = streamAnnotatedData(fallFile, @processData, accumulatedData, 'fall', fig1, fig2);
    end
end

function accumulatedData = streamAnnotatedData(file, processingFunction, accumulatedData, eventType, fig1, fig2)
    data = loadAnnotatedFile(fullfile(file.folder, file.name));
    numSamples = height(data);
    startTime = datetime('now'); % Current time as the start time
    
    % Randomly decide when to switch to a fall scenario within the activity stream
    switchToFall = randi([1, numSamples]);

    for i = 1:numSamples
        tic;
        currentTime = datetime('now');
        elapsedTime = currentTime - startTime;
        relTime = seconds(elapsedTime); % Relative time in seconds
        data.timestamp(i) = posixtime(currentTime); % Convert current time to POSIX time (seconds since Unix epoch)
        data.rel_time(i) = relTime;

        % Accumulate data for visualization
        accumulatedData = accumulateData(accumulatedData, data(i, :), eventType);
        
        % Process current data point only
        processingFunction(data(i, :));

        % Update plots with the new data
        updatePlots(fig1, fig2, accumulatedData);

        % Simulate a switch to fall scenario at random point within activity stream
        if i == switchToFall && strcmp(eventType, 'activity')
            fallFile = selectRandomFile(fallFiles);
            fprintf('Randomly switching to fall data from %s\n', fallFile.name);
            accumulatedData = streamAnnotatedData(fallFile, processingFunction, accumulatedData, 'fall', fig1, fig2);
            break;
        end
        
        pauseTime = 0.1 - toc;
        if pauseTime > 0
            pause(pauseTime); % Adjust pause time dynamically
        end
    end
end

function data = loadAnnotatedFile(filePath)
    data = readtable(filePath, 'Delimiter', ',', 'ReadVariableNames', true);
    % Ensure that the data columns are as expected
    expectedColumns = {'timestamp', 'rel_time', 'acc_x', 'acc_y', 'acc_z', 'gyro_x', 'gyro_y', 'gyro_z', 'azimuth', 'pitch', 'roll', 'label'};
    if ~all(ismember(expectedColumns, data.Properties.VariableNames))
        error('The data file does not contain the expected columns.');
    end
end

function processData(data)
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
    plotEventMarkers(data.rel_time, data.events);

    subplot(3, 1, 2);
    plot(data.rel_time, data.gyro_x, '-r', data.rel_time, data.gyro_y, '-g', data.rel_time, data.gyro_z, '-b');
    title('Gyroscope Data (Relative Time)');
    xlabel('Relative Time (s)');
    ylabel('Angular Velocity');
    legend({'X', 'Y', 'Z'});
    hold on;
    plotEventMarkers(data.rel_time, data.events);

    subplot(3, 1, 3);
    plot(data.rel_time, data.azimuth, '-r', data.rel_time, data.pitch, '-g', data.rel_time, data.roll, '-b');
    title('Orientation Data (Relative Time)');
    xlabel('Relative Time (s)');
    ylabel('Angle');
    legend({'Azimuth', 'Pitch', 'Roll'});
    hold on;
    plotEventMarkers(data.rel_time, data.events);

    figure(fig2);
    subplot(3, 1, 1);
    plot(data.timestamp, data.acc_x, '-r', data.timestamp, data.acc_y, '-g', data.timestamp, data.acc_z, '-b');
    title('Accelerometer Data (Actual Time)');
    xlabel('Time');
    ylabel('Acceleration');
    legend({'X', 'Y', 'Z'});
    hold on;
    plotEventMarkers(data.timestamp, data.events);

    subplot(3, 1, 2);
    plot(data.timestamp, data.gyro_x, '-r', data.timestamp, data.gyro_y, '-g', data.timestamp, data.gyro_z, '-b');
    title('Gyroscope Data (Actual Time)');
        xlabel('Time');
    ylabel('Angular Velocity');
    legend({'X', 'Y', 'Z'});
    hold on;
    plotEventMarkers(data.timestamp, data.events);

    subplot(3, 1, 3);
    plot(data.timestamp, data.azimuth, '-r', data.timestamp, data.pitch, '-g', data.timestamp, data.roll, '-b');
    title('Orientation Data (Actual Time)');
    xlabel('Time');
    ylabel('Angle');
    legend({'Azimuth', 'Pitch', 'Roll'});
    hold on;
    plotEventMarkers(data.timestamp, data.events);

    drawnow; % Update the plots immediately
end

function plotEventMarkers(time, events)
    for i = 1:length(events)
        if ~isnan(events(i))
            xline(time(events(i)), '--k', 'LineWidth', 2, 'DisplayName', 'Event');
        end
    end
    hold off;
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
                             'azimuth', NaN(windowSize, 1), 'pitch', NaN(windowSize, 1), 'roll', NaN(windowSize, 1), ...
                             'events', NaN(windowSize, 1));
end

function accumulatedData = accumulateData(accumulatedData, newData, eventType)
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
    
    if strcmp(eventType, 'fall')
        accumulatedData.events = [accumulatedData.events(2:end); length(accumulatedData.rel_time)];
    else
        accumulatedData.events = [accumulatedData.events(2:end); NaN];
    end
end

function files = listFiles(directory)
    files = dir(fullfile(directory, '*.csv'));
end

function file = selectRandomFile(files)
    index = randi(length(files));
    file = files(index);
end

