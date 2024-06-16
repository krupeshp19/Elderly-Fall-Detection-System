function activityData = generateActivityData(duration)
    % This function generates synthetic accelerometer and gyroscope data
    % for a given duration. It simulates different activities and fall events.

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

    % Define a fixed sequence of activities
    activityLabels = {'Sitting', 'Sitting up fast', 'Jumping', 'Going downstairs', ...
                      'Walking', 'Running', 'Going upstairs', 'Sitting down fast', 'Lying'};

    % Define durations for short-duration activities (in seconds)
    shortDuration = 5; % duration for short activities
    shortActivities = {'Sitting up fast', 'Sitting down fast'};

    % Calculate remaining duration for long activities
    longActivities = setdiff(activityLabels, shortActivities);
    remainingDuration = duration - length(shortActivities) * shortDuration;
    longActivityDuration = floor(remainingDuration / length(longActivities));

    % Assign durations to each activity
    activityDurations = containers.Map();
    for i = 1:length(shortActivities)
        activityDurations(shortActivities{i}) = shortDuration;
    end
    for i = 1:length(longActivities)
        activityDurations(longActivities{i}) = longActivityDuration;
    end

    % Define activity intervals
    activityIntervals = zeros(length(activityLabels) + 1, 1);
    for i = 1:length(activityLabels)
        activityIntervals(i + 1) = activityIntervals(i) + activityDurations(activityLabels{i});
    end
    if activityIntervals(end) < duration
        activityIntervals(end) = duration;
    end

    % Simulate activities
    for i = 1:length(activityLabels)
        startIdx = activityIntervals(i) + 1;
        endIdx = activityIntervals(i + 1);

        switch activityLabels{i}
            case 'Sitting'
                accelData(startIdx:endIdx) = 0.05 * randn(1, endIdx - startIdx + 1);
                gyroData(startIdx:endIdx) = 0.05 * randn(1, endIdx - startIdx + 1);
            case 'Sitting up fast'
                accelData(startIdx:endIdx) = linspace(0, 2, endIdx - startIdx + 1) + 0.1 * randn(1, endIdx - startIdx + 1);
                gyroData(startIdx:endIdx) = linspace(0, 1, endIdx - startIdx + 1) + 0.1 * randn(1, endIdx - startIdx + 1);
            case 'Jumping'
                accelData(startIdx:endIdx) = 3 * abs(sin(2 * pi * (1:(endIdx - startIdx + 1)))) + 0.3 * randn(1, endIdx - startIdx + 1);
                gyroData(startIdx:endIdx) = 3 * abs(cos(2 * pi * (1:(endIdx - startIdx + 1)))) + 0.3 * randn(1, endIdx - startIdx + 1);
            case 'Going downstairs'
                accelData(startIdx:endIdx) = 1.5 * sin(2 * pi * 0.5 * (1:(endIdx - startIdx + 1))) + 0.2 * randn(1, endIdx - startIdx + 1);
                gyroData(startIdx:endIdx) = 1.5 * cos(2 * pi * 0.5 * (1:(endIdx - startIdx + 1))) + 0.2 * randn(1, endIdx - startIdx + 1);
            case 'Walking'
                accelData(startIdx:endIdx) = 1.5 * sin(2 * pi * 0.5 * (1:(endIdx - startIdx + 1))) + 0.2 * randn(1, endIdx - startIdx + 1);
                gyroData(startIdx:endIdx) = 1.5 * cos(2 * pi * 0.5 * (1:(endIdx - startIdx + 1))) + 0.2 * randn(1, endIdx - startIdx + 1);
            case 'Running'
                accelData(startIdx:endIdx) = 3 * sin(2 * pi * 1 * (1:(endIdx - startIdx + 1))) + 0.3 * randn(1, endIdx - startIdx + 1);
                gyroData(startIdx:endIdx) = 3 * cos(2 * pi * 1 * (1:(endIdx - startIdx + 1))) + 0.3 * randn(1, endIdx - startIdx + 1);
            case 'Going upstairs'
                accelData(startIdx:endIdx) = 1.5 * sin(2 * pi * 0.5 * (1:(endIdx - startIdx + 1))) + 0.2 * randn(1, endIdx - startIdx + 1);
                gyroData(startIdx:endIdx) = 1.5 * cos(2 * pi * 0.5 * (1:(endIdx - startIdx + 1))) + 0.2 * randn(1, endIdx - startIdx + 1);
            case 'Sitting down fast'
                accelData(startIdx:endIdx) = linspace(2, 0, endIdx - startIdx + 1) + 0.1 * randn(1, endIdx - startIdx + 1);
                gyroData(startIdx:endIdx) = linspace(1, 0, endIdx - startIdx + 1) + 0.1 * randn(1, endIdx - startIdx + 1);
            case 'Lying'
                accelData(startIdx:endIdx) = 0.03 * randn(1, endIdx - startIdx + 1);
                gyroData(startIdx:endIdx) = 0.03 * randn(1, endIdx - startIdx + 1);
        end
    end

    % Introduce random fall events with gradual changes
    fallDuration = 10;
    fallTypes = {'forward', 'backward'};
    for i = 1:length(fallTypes)
        activityIdx = randi(length(activityLabels));
        startIdx = activityIntervals(activityIdx) + 1;
        endIdx = activityIntervals(activityIdx + 1);

        if endIdx - startIdx > 2 * fallDuration
            fallStart = randi([startIdx + fallDuration, endIdx - fallDuration]);

            switch fallTypes{i}
                case 'forward'
                    fallAccel = linspace(0, 5, fallDuration); % Gradual increase to simulate fall
                    accelData(fallStart:fallStart + fallDuration - 1) = fallAccel;
                    fallGyro = linspace(0, 5, fallDuration); % Gradual increase to simulate fall
                    gyroData(fallStart:fallStart + fallDuration - 1) = fallGyro;
                case 'backward'
                    fallAccel = linspace(0, -5, fallDuration); % Gradual decrease to simulate fall
                    accelData(fallStart:fallStart + fallDuration - 1) = fallAccel;
                    fallGyro = linspace(0, -5, fallDuration); % Gradual decrease to simulate fall
                    gyroData(fallStart:fallStart + fallDuration - 1) = fallGyro;
            end
        end
    end

    % Package the generated data into a struct
    activityData.time = t;
    activityData.accel = accelData;
    activityData.gyro = gyroData;

    % Plot the generated data for visual verification
    figure;
    subplot(2, 1, 1);
    hold on;
    title('Synthetic Accelerometer Data with Different Activities and Falls');
    xlabel('Time (s)');
    ylabel('Acceleration (m/s^2)');

    subplot(2, 1,2);
    hold on;
    title('Synthetic Gyroscope Data with Different Activities and Falls');
    xlabel('Time (s)');
    ylabel('Angular Velocity (rad/s)');

    colors = lines(length(activityLabels) + length(fallTypes));
    legendLabels = [activityLabels, {'Forward Fall', 'Backward Fall'}];

    for i = 1:length(activityLabels)
        startIdx = activityIntervals(i) + 1;
        endIdx = activityIntervals(i + 1);
        subplot(2, 1, 1);
        plot(t(startIdx:endIdx), accelData(startIdx:endIdx), 'Color', colors(i, :), 'LineWidth', 1.5);
        subplot(2, 1, 2);
        plot(t(startIdx:endIdx), gyroData(startIdx:endIdx), 'Color', colors(i, :), 'LineWidth', 1.5);
    end

    for i = 1:length(fallTypes)
                if i == 1
            fallIdx = find(accelData == 5, 1);
        else
            fallIdx = find(accelData == -5, 1);
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
    hold off;

    subplot(2, 1, 2);
    legend(legendLabels, 'Location', 'best');
    hold off;

    % Save the data to a file
    % save('synthetic_activity_data.mat', 'activityData');
end

