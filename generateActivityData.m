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

    % Initialize accelerometer and gyroscope data arrays for x, y, and z axes
    accelData = zeros(3, duration);
    gyroData = zeros(3, duration);

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

    % Function to generate noise with variable levels
    generateNoise = @(baseNoise, variability, size) baseNoise + variability * randn(size);

    % Function to smooth transitions between activities
    smoothTransition = @(startVal, endVal, len) linspace(startVal, endVal, len);

    % Function to generate varying speed patterns
    generateVaryingSpeed = @(baseFreq, variability, len) baseFreq + variability * sin(linspace(0, 2*pi, len));

    % Simulate activities
    for i = 1:length(activityLabels)
        startIdx = activityIntervals(i) + 1;
        endIdx = activityIntervals(i + 1);
        len = endIdx - startIdx + 1;

        switch activityLabels{i}
            case 'Sitting'
                accelData(:, startIdx:endIdx) = generateNoise(0, 0.05, [3, len]);
                gyroData(:, startIdx:endIdx) = generateNoise(0, 0.05, [3, len]);
            case 'Sitting up fast'
                accelData(:, startIdx:endIdx) = smoothTransition(0, 2, len) + generateNoise(0.1, 0.1, [3, len]);
                gyroData(:, startIdx:endIdx) = smoothTransition(0, 1, len) + generateNoise(0.1, 0.1, [3, len]);
            case 'Going upstairs'
                freq = generateVaryingSpeed(0.5, 0.2, len);
                accelData(:, startIdx:endIdx) = 1.5 * sin(2 * pi * freq .* (1:len)) + generateNoise(0.2, 0.2, [3, len]);
                gyroData(:, startIdx:endIdx) = 1.5 * cos(2 * pi * freq .* (1:len)) + generateNoise(0.2, 0.2, [3, len]);
            case 'Going downstairs'
                freq = generateVaryingSpeed(0.5, 0.2, len);
                accelData(:, startIdx:endIdx) = 1.5 * sin(2 * pi * freq .* (1:len)) + generateNoise(0.2, 0.2, [3, len]);
                gyroData(:, startIdx:endIdx) = 1.5 * cos(2 * pi * freq .* (1:len)) + generateNoise(0.2, 0.2, [3, len]);
            case 'Walking'
                freq = generateVaryingSpeed(0.5, 0.2, len);
                accelData(:, startIdx:endIdx) = 1.5 * sin(2 * pi * freq .* (1:len)) + generateNoise(0.2, 0.2, [3, len]);
                gyroData(:, startIdx:endIdx) = 1.5 * cos(2 * pi * freq .* (1:len)) + generateNoise(0.2, 0.2, [3, len]);
            case 'Running'
                freq = generateVaryingSpeed(1, 0.5, len);
                accelData(:, startIdx:endIdx) = 3 * sin(2 * pi * freq .* (1:len)) + generateNoise(0.3, 0.3, [3, len]);
                gyroData(:, startIdx:endIdx) = 3 * cos(2 * pi * freq .* (1:len)) + generateNoise(0.3, 0.3, [3, len]);
            case 'Jumping'
                accelData(:, startIdx:endIdx) = 3 * abs(sin(2 * pi * (1:len))) + generateNoise(0.3, 0.3, [3, len]);
                gyroData(:, startIdx:endIdx) = 3 * abs(cos(2 * pi * (1:len))) + generateNoise(0.3, 0.3, [3, len]);
            case 'Sitting down fast'
                accelData(:, startIdx:endIdx) = smoothTransition(2, 0, len) + generateNoise(0.1, 0.1, [3, len]);
                gyroData(:, startIdx:endIdx) = smoothTransition(1, 0, len) + generateNoise(0.1, 0.1, [3, len]);
            case 'Lying'
                accelData(:, startIdx:endIdx) = generateNoise(0, 0.03, [3, len]);
                gyroData(:, startIdx:endIdx) = generateNoise(0, 0.03, [3, len]);
        end
    end

    % Introduce random fall events with gradual changes
    fallDuration = 10;
    fallTypes = {'forward', 'backward'};
    fallDistribution = randperm(length(activityLabels), length(fallTypes));

    for i = 1:length(fallTypes)
        activityIdx = fallDistribution(i);
        startIdx = activityIntervals(activityIdx) + 1;
        endIdx = activityIntervals(activityIdx + 1);

        if endIdx - startIdx > 2 * fallDuration
            fallStart = randi([startIdx + fallDuration, endIdx - fallDuration]);

            switch fallTypes{i}
                case 'forward'
                    fallAccel = smoothTransition(0, 5, fallDuration); % Gradual increase to simulate fall
                    accelData(:, fallStart:fallStart + fallDuration - 1) = repmat(fallAccel, 3, 1);
                    fallGyro = smoothTransition(0, 5, fallDuration); % Gradual increase to simulate fall
                    gyroData(:, fallStart:fallStart + fallDuration - 1) = repmat(fallGyro, 3, 1);
                case 'backward'
                    fallAccel = smoothTransition(0, -5, fallDuration); % Gradual decrease to simulate fall
                    accelData(:, fallStart:fallStart + fallDuration - 1) = repmat(fallAccel, 3, 1);
                    fallGyro = smoothTransition(0, -5, fallDuration); % Gradual decrease to simulate fall
                    gyroData(:, fallStart:fallStart + fallDuration - 1) = repmat(fallGyro, 3, 1);
            end
        end
    end

    % Package the generated data into a struct
    activityData.time = t;
    activityData.accel = accelData;
    activityData.gyro = gyroData;

    % Plot the generated data for visual verification
    figure;
    subplot(3, 2, 1); hold on; title('Accelerometer Data (X-axis)'); xlabel('Time (s)'); ylabel('Acceleration (m/s^2)');
    subplot(3, 2, 2); hold on; title('Gyroscope Data (X-axis)'); xlabel('Time (s)'); ylabel('Angular Velocity (rad/s)');
    subplot(3, 2, 3); hold on; title('Accelerometer Data (Y-axis)'); xlabel('Time (s)'); ylabel('Acceleration (m/s^2)');
    subplot(3, 2, 4); hold on; title('Gyroscope Data (Y-axis)'); xlabel('Time (s)'); ylabel('Angular Velocity (rad/s)');
    subplot(3, 2, 5); hold on; title('Accelerometer Data (Z-axis)'); xlabel('Time (s)'); ylabel('Acceleration (m/s^2)');
    subplot(3, 2, 6); hold on; title('Gyroscope Data (Z-axis)'); xlabel('Time (s)'); ylabel('Angular Velocity (rad/s)');

    colors = lines(length(activityLabels) + length(fallTypes));
    legendLabels = [activityLabels, {'Forward Fall', 'Backward Fall'}];

    % Plot data
    for i = 1:length(activityLabels)
        startIdx = activityIntervals(i) + 1;
        endIdx = activityIntervals(i + 1);
        for axis = 1:3
            subplot(3, 2, axis * 2 - 1);
            plot(t(startIdx:endIdx), accelData(axis, startIdx:endIdx), 'Color', colors(i, :), 'LineWidth', 1.5);
            subplot(3, 2, axis * 2);
            plot(t(startIdx:endIdx), gyroData(axis, startIdx:endIdx), 'Color', colors(i, :), 'LineWidth', 1.5);
        end
    end

    % Highlight fall events
    for i = 1:length(fallTypes)
        if i == 1
            fallIdx = find(accelData(1, :) == 5, 1);
        else
            fallIdx = find(accelData(1, :) == -5, 1);
        end
        if ~isempty(fallIdx)
            fallEnd = fallIdx + fallDuration - 1;
            for axis = 1:3
                subplot(3, 2, axis * 2 - 1);
                plot(t(fallIdx:fallEnd), accelData(axis, fallIdx:fallEnd), 'Color', colors(length(activityLabels) + i, :), 'LineWidth', 1.5);
                subplot(3, 2, axis * 2);
                plot(t(fallIdx:fallEnd), gyroData(axis, fallIdx:fallEnd), 'Color', colors(length(activityLabels) + i, :), 'LineWidth', 1.5);
            end
        end
    end

    % Add legend
    legend(legendLabels, 'Location', 'best', 'FontSize', 8);  % Place legend outside the subplots
    hold off;

    % Save the data to a file (uncomment to save)
    % save('synthetic_activity_data.mat', 'activityData');
end