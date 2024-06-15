function activityData = generateActivityData(duration)
    % This function generates synthetic accelerometer and gyroscope data
    % for a given duration. It simulates different activities and fall events.
    % It ensures reproducibility, validation, error handling, and secure data generation.

    % Parameters
    % duration - The total duration (in seconds) for which to generate data

    % Set random seed for reproducibility
    rng(42);

    % Validate input
    if ~isscalar(duration) || duration <= 0
        error('Duration must be a positive integer.');
    end

    % Initialize time vector
    t = 1:duration;

    % Initialize accelerometer and gyroscope data arrays
    accelData = zeros(1, duration);
    gyroData = zeros(1, duration);

    % Define activity ratios (relative duration of each activity)
    activityRatios = [
        0.15;  % Sitting
        0.02;  % Standing up
        0.25;  % Walking
        0.25;  % Running
        0.02;  % Sitting down
        0.25;  % Lying
    ];

    % Calculate activity intervals based on duration and ratios
    activityIntervals = round(duration * activityRatios);
    activityIntervals = [0; cumsum(activityIntervals)];

    % Ensure the intervals sum to the total duration
    if activityIntervals(end) < duration
        activityIntervals(end) = duration;
    end

    % Activity labels
    activityLabels = {'Sitting', 'Standing up', 'Walking', 'Running', 'Sitting down', 'Lying'};

    % Simulate activities
    for i = 1:length(activityLabels)
        startIdx = activityIntervals(i) + 1;
        endIdx = activityIntervals(i + 1);

        switch activityLabels{i}
            case 'Sitting'
                accelData(startIdx:endIdx) = 0.05 * randn(1, endIdx - startIdx + 1); % Low variation
                gyroData(startIdx:endIdx) = 0.05 * randn(1, endIdx - startIdx + 1); % Low variation
            case 'Standing up'
                accelData(startIdx:endIdx) = linspace(0, 2, endIdx - startIdx + 1) + 0.1 * randn(1, endIdx - startIdx + 1);
                gyroData(startIdx:endIdx) = linspace(0, 1, endIdx - startIdx + 1) + 0.1 * randn(1, endIdx - startIdx + 1);
            case 'Walking'
                accelData(startIdx:endIdx) = 1.5 * sin(2 * pi * 0.5 * (1:(endIdx - startIdx + 1))) + 0.2 * randn(1, endIdx - startIdx + 1);
                gyroData(startIdx:endIdx) = 1.5 * cos(2 * pi * 0.5 * (1:(endIdx - startIdx + 1))) + 0.2 * randn(1, endIdx - startIdx + 1);
            case 'Running'
                accelData(startIdx:endIdx) = 3 * sin(2 * pi * 1 * (1:(endIdx - startIdx + 1))) + 0.3 * randn(1, endIdx - startIdx + 1);
                gyroData(startIdx:endIdx) = 3 * cos(2 * pi * 1 * (1:(endIdx - startIdx + 1))) + 0.3 * randn(1, endIdx - startIdx + 1);
            case 'Sitting down'
                accelData(startIdx:endIdx) = linspace(2, 0, endIdx - startIdx + 1) + 0.1 * randn(1, endIdx - startIdx + 1);
                gyroData(startIdx:endIdx) = linspace(1, 0, endIdx - startIdx + 1) + 0.1 * randn(1, endIdx - startIdx + 1);
            case 'Lying'
                accelData(startIdx:endIdx) = 0.03 * randn(1, endIdx - startIdx + 1); % Very low variation
                gyroData(startIdx:endIdx) = 0.03 * randn(1, endIdx - startIdx + 1); % Very low variation
        end
    end

    % Introduce random fall events in the middle of activities
    fallDuration = 10; % Duration of a fall event
    numFalls = 2; % Simulate two types of falls

    % Fall event types: forward and backward
    fallTypes = {'forward', 'backward'};
    for i = 1:numFalls
        % Select a random activity interval
        activityIdx = randi(length(activityLabels));
        startIdx = activityIntervals(activityIdx) + 1;
        endIdx = activityIntervals(activityIdx + 1);
        
        % Randomly select the start point of the fall event within the interval
        fallStart = randi([startIdx + fallDuration, endIdx - fallDuration]);

        fallType = fallTypes{i};

        switch fallType
            case 'forward'
                % Generate forward fall event data
                fallAccel = 5 * ones(1, fallDuration); % Higher values to simulate a fall
                accelData(fallStart:fallStart + fallDuration - 1) = fallAccel;
                fallGyro = 5 * ones(1, fallDuration); % Higher values to simulate a fall
                gyroData(fallStart:fallStart + fallDuration - 1) = fallGyro;
            case 'backward'
                % Generate backward fall event data
                fallAccel = -5 * ones(1, fallDuration); % Higher values to simulate a fall
                accelData(fallStart:fallStart + fallDuration - 1) = fallAccel;
                fallGyro = -5 * ones(1, fallDuration); % Higher values to simulate a fall
                gyroData(fallStart:fallStart + fallDuration - 1) = fallGyro;
        end
    end

    % Package the generated data into a struct
    activityData.time = t;
    activityData.accel = accelData;
    activityData.gyro = gyroData;

    % Plot the generated data for visual verification with colors
    figure;

    subplot(2, 1, 1);
    hold on;
    title('Synthetic Accelerometer Data with Different Activities and Falls');
    xlabel('Time (s)');
    ylabel('Acceleration (m/s^2)');
    
    subplot(2, 1, 2);
    hold on;
    title('Synthetic Gyroscope Data with Different Activities and Falls');
    xlabel('Time (s)');
    ylabel('Angular Velocity (rad/s)');

    colors = lines(length(activityLabels) + numFalls); % Generate distinct colors
    legendLabels = [activityLabels, {'Forward Fall', 'Backward Fall'}]; % Create as cell array
    
    % Plot each activity interval with different colors
    for i = 1:length(activityLabels)
        startIdx = activityIntervals(i) + 1;
        endIdx = activityIntervals(i + 1);
        subplot(2, 1, 1);
        plot(t(startIdx:endIdx), accelData(startIdx:endIdx), 'Color', colors(i, :), 'LineWidth', 1.5);
        subplot(2, 1, 2);
        plot(t(startIdx:endIdx), gyroData(startIdx:endIdx), 'Color', colors(i, :), 'LineWidth', 1.5);
    end
    
    % Plot fall events with different colors
    for i = 1:numFalls
        if i == 1
            fallIdx = find(accelData == 5, 1); % Find the start of forward fall event
        else
            fallIdx = find(accelData == -5, 1); % Find the start of backward fall event
        end
        
        if ~isempty(fallIdx)
            fallEnd = fallIdx + fallDuration - 1;
            subplot(2, 1, 1);
            plot(t(fallIdx:fallEnd), accelData(fallIdx:fallEnd), 'Color', colors(length(activityLabels) + i, :), 'LineWidth', 1.5);
            subplot(2, 1, 2);
            plot(t(fallIdx:fallEnd), gyroData(fallIdx:fallEnd), 'Color', colors(length(activityLabels) + i, :), 'LineWidth', 1.5);
        end
    end

    subplot(2, 1, 1);
    legend(legendLabels, 'Location', 'best');
    subplot(2, 1, 2);
    legend(legendLabels, 'Location', 'best');
    
    hold off;

    % Save the data to a file (optional)
    % save('synthetic_activity_data.mat', 'activityData');
end
