function activityData = generateActivityData(duration)
    % This function generates synthetic accelerometer and gyroscope data
    % for a given duration. It simulates different activities and fall events.

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
    activityLabels = {'Sitting', 'Sitting up fast', 'Walking', 'Running', 'Sitting down fast', 'Lying'};
    
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

    % Initialize activity log
    activityLog = [];

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
        activityID = i; % Unique ID for each activity

        % Log the activity
        activityLog = [activityLog; struct('ID', activityID, 'Label', activityLabels{i}, 'Start', startIdx, 'End', endIdx)];

        switch activityLabels{i}
            case 'Sitting'
                accelData(:, startIdx:endIdx) = generateNoise(0, 0.05, [3, len]);
                gyroData(:, startIdx:endIdx) = generateNoise(0, 0.05, [3, len]);
            case 'Sitting up fast'
                accelData(:, startIdx:endIdx) = smoothTransition(0, 2, len) + generateNoise(0.1, 0.1, [3, len]);
                gyroData(:, startIdx:endIdx) = smoothTransition(0, 1, len) + generateNoise(0.1, 0.1, [3, len]);
            case 'Walking'
                freq = generateVaryingSpeed(0.5, 0.2, len);
                accelData(:, startIdx:endIdx) = 1.5 * sin(2 * pi * freq .* (1:len)) + generateNoise(0.2, 0.2, [3, len]);
                gyroData(:, startIdx:endIdx) = 1.5 * cos(2 * pi * freq .* (1:len)) + generateNoise(0.2, 0.2, [3, len]);
            case 'Running'
                freq = generateVaryingSpeed(1, 0.5, len);
                accelData(:, startIdx:endIdx) = 3 * sin(2 * pi * freq .* (1:len)) + generateNoise(0.3, 0.3, [3, len]);
                gyroData(:, startIdx:endIdx) = 3 * cos(2 * pi * freq .* (1:len)) + generateNoise(0.3, 0.3, [3, len]);
            % case 'Jumping'
                % accelData(:, startIdx:endIdx) = 3 * abs(sin(2 * pi * (1:len))) + generateNoise(0.3, 0.3, [3, len]);
                % gyroData(:, startIdx:endIdx) = 3 * abs(cos(2 * pi * (1:len))) + generateNoise(0.3, 0.3, [3, len]);
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
    fallMagnitudes = [4, 6]; % Different magnitudes for falls
    fallDistribution = randperm(length(activityLabels), length(fallTypes));

    for i = 1:length(fallTypes)
        activityIdx = fallDistribution(i);
        startIdx = activityIntervals(activityIdx) + 1;
        endIdx = activityIntervals(activityIdx + 1);

        if endIdx - startIdx > 2 * fallDuration
            fallStart = randi([startIdx + fallDuration, endIdx - fallDuration]);
            fallMagnitude = fallMagnitudes(randi(length(fallMagnitudes)));
            fallID = length(activityLabels) + i; % Unique ID for each fall

            % Log the fall
            activityLog = [activityLog; struct('ID', fallID, 'Label', [fallTypes{i} ' Fall'], 'Start', fallStart, 'End', fallStart + fallDuration - 1)];

            switch fallTypes{i}
                case 'forward'
                    fallAccel = smoothTransition(0, fallMagnitude, fallDuration); % Gradual increase to simulate fall
                    accelData(:, fallStart:fallStart + fallDuration - 1) = repmat(fallAccel, 3, 1);
                    fallGyro = smoothTransition(0, fallMagnitude, fallDuration); % Gradual increase to simulate fall
                    gyroData(:, fallStart:fallStart + fallDuration - 1) = repmat(fallGyro, 3, 1);
                case 'backward'
                    fallAccel = smoothTransition(0, -fallMagnitude, fallDuration); % Gradual decrease to simulate fall
                    accelData(:, fallStart:fallStart + fallDuration - 1) = repmat(fallAccel, 3, 1);
                    fallGyro = smoothTransition(0, -fallMagnitude, fallDuration); % Gradual decrease to simulate fall
                    gyroData(:, fallStart:fallStart + fallDuration - 1) = repmat(fallGyro, 3, 1);
            end
        end
    end

    % Package the generated data into a struct
    activityData.time = t;
    activityData.accel = accelData;
    activityData.gyro = gyroData;
    activityData.log = activityLog;

    % Plot the generated data for visual verification
    figure;
    ax1 = subplot(3, 2, 1);
    hold on;
    title('Accelerometer Data (X-axis)');
    xlabel('Time (s)');
    ylabel('Acceleration (m/s^2)');

    ax2 = subplot(3, 2, 2);
    hold on;
    title('Gyroscope Data (X-axis)');
    xlabel('Time (s)');
    ylabel('Angular Velocity (rad/s)');

    ax3 = subplot(3, 2, 3);
    hold on;
    title('Accelerometer Data (Y-axis)');
    xlabel('Time (s)');
    ylabel('Acceleration (m/s^2)');

    ax4 = subplot(3, 2, 4);
    hold on;
    title('Gyroscope Data (Y-axis)');
    xlabel('Time (s)');
    ylabel('Angular Velocity (rad/s)');

    ax5 = subplot(3, 2, 5);
    hold on;
    title('Accelerometer Data (Z-axis)');
    xlabel('Time (s)');
    ylabel('Acceleration (m/s^2)');

    ax6 = subplot(3, 2, 6);
    hold on;
    title('Gyroscope Data (Z-axis)');
    xlabel('Time (s)');
    ylabel('Angular Velocity (rad/s)');

    colors = lines(length(activityLabels) + length(fallTypes));
    legendLabels = [activityLabels, {'Forward Fall', 'Backward Fall'}];

    for i = 1:length(activityLabels)
        startIdx = activityIntervals(i) + 1;
        endIdx = activityIntervals(i + 1);
        plot(ax1, t(startIdx:endIdx), accelData(1, startIdx:endIdx), 'Color', colors(i, :), 'LineWidth', 1.5);
        plot(ax2, t(startIdx:endIdx), gyroData(1, startIdx:endIdx), 'Color', colors(i, :), 'LineWidth', 1.5);
        plot(ax3, t(startIdx:endIdx), accelData(2, startIdx:endIdx), 'Color', colors(i, :), 'LineWidth', 1.5);
        plot(ax4, t(startIdx:endIdx), gyroData(2, startIdx:endIdx), 'Color', colors(i, :), 'LineWidth', 1.5);
        plot(ax5, t(startIdx:endIdx), accelData(3, startIdx:endIdx), 'Color', colors(i, :), 'LineWidth', 1.5);
        plot(ax6, t(startIdx:endIdx), gyroData(3, startIdx:endIdx), 'Color', colors(i, :), 'LineWidth', 1.5);
    end

    for i = 1:length(fallTypes)
        fallIdx = find(abs(accelData(1, :)) == max(abs(accelData(1, :))), 1);
        if ~isempty(fallIdx)
            fallEnd = fallIdx + fallDuration - 1;
            plot(ax1, t(fallIdx:fallEnd), accelData(1, fallIdx:fallEnd), 'Color', colors(length(activityLabels) + i, :), 'LineWidth', 1.5);
            plot(ax2, t(fallIdx:fallEnd), gyroData(1, fallIdx:fallEnd), 'Color', colors(length(activityLabels) + i, :), 'LineWidth', 1.5);
            plot(ax3, t(fallIdx:fallEnd), accelData(2, fallIdx:fallEnd), 'Color', colors(length(activityLabels) + i, :), 'LineWidth', 1.5);
            plot(ax4, t(fallIdx:fallEnd), gyroData(2, fallIdx:fallEnd), 'Color', colors(length(activityLabels) + i, :), 'LineWidth', 1.5);
            plot(ax5, t(fallIdx:fallEnd), accelData(3, fallIdx:fallEnd), 'Color', colors(length(activityLabels) + i, :), 'LineWidth', 1.5);
            plot(ax6, t(fallIdx:fallEnd), gyroData(3, fallIdx:fallEnd), 'Color', colors(length(activityLabels) + i, :), 'LineWidth', 1.5);
        end
    end

    legend(ax1, legendLabels, 'Location', 'best');
    hold(ax1, 'off');

    % Save the data to a file 
    % save('synthetic_activity_data.mat', 'activityData');
end
