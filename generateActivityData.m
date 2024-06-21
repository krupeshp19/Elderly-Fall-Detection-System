function [accelData, gyroData, activityLog, fs, t] = generateActivityData(duration)
    % Validate input
    if ~isscalar(duration) || duration <= 0 || mod(duration, 1) ~= 0
        error('Duration must be a positive integer.');
    end

    % Initialize parameters
    fs = 50; % Sampling frequency (Hz)
    t = 1:(duration * fs);
    activityLabels = {'STANDING', 'WALKING UPSTAIRS', 'WALKING', 'WALKING DOWNSTAIRS', 'JOGGING', 'SITTING', 'LAYING'};
    activityDuration = floor(duration / length(activityLabels) * fs);
    activityIntervals = 0:activityDuration:(length(activityLabels) * activityDuration);
    activityLog = [];

    % Initialize accelerometer and gyroscope data arrays for x, y, and z axes
    accelData = zeros(3, length(t));
    gyroData = zeros(3, length(t));

    % Helper functions
    generateNoise = @(baseNoise, variability, size) baseNoise + variability * randn(size);
    generateVaryingSpeed = @(baseFreq, variability, len) baseFreq + variability * sin(linspace(0, 2*pi, len));

    % Define mathematical functions for each activity and axis
    % Walking
    walkingAccelX = @(len) 1.5 * sin(2 * pi * generateVaryingSpeed(0.5, 0.2, len) .* (1:len));
    walkingAccelY = @(len) 1.5 * cos(2 * pi * generateVaryingSpeed(0.5, 0.2, len) .* (1:len));
    walkingAccelZ = @(len) 1.5 * sin(2 * pi * generateVaryingSpeed(0.5, 0.2, len) .* (1:len));
    walkingGyroX = @(len) 1.5 * cos(2 * pi * generateVaryingSpeed(0.5, 0.2, len) .* (1:len));
    walkingGyroY = @(len) 1.5 * sin(2 * pi * generateVaryingSpeed(0.5, 0.2, len) .* (1:len));
    walkingGyroZ = @(len) 1.5 * cos(2 * pi * generateVaryingSpeed(0.5, 0.2, len) .* (1:len));

    % Walking Upstairs
    walkingUpstairsAccelX = @(len) 1.7 * sin(2 * pi * generateVaryingSpeed(0.6, 0.3, len) .* (1:len));
    walkingUpstairsAccelY = @(len) 1.7 * cos(2 * pi * generateVaryingSpeed(0.6, 0.3, len) .* (1:len));
    walkingUpstairsAccelZ = @(len) 1.7 * sin(2 * pi * generateVaryingSpeed(0.6, 0.3, len) .* (1:len));
    walkingUpstairsGyroX = @(len) 1.7 * cos(2 * pi * generateVaryingSpeed(0.6, 0.3, len) .* (1:len));
    walkingUpstairsGyroY = @(len) 1.7 * sin(2 * pi * generateVaryingSpeed(0.6, 0.3, len) .* (1:len));
    walkingUpstairsGyroZ = @(len) 1.7 * cos(2 * pi * generateVaryingSpeed(0.6, 0.3, len) .* (1:len));

    % Walking Downstairs
    walkingDownstairsAccelX = @(len) 1.8 * sin(2 * pi * generateVaryingSpeed(0.7, 0.4, len) .* (1:len));
    walkingDownstairsAccelY = @(len) 1.8 * cos(2 * pi * generateVaryingSpeed(0.7, 0.4, len) .* (1:len));
    walkingDownstairsAccelZ = @(len) 1.8 * sin(2 * pi * generateVaryingSpeed(0.7, 0.4, len) .* (1:len));
    walkingDownstairsGyroX = @(len) 1.8 * cos(2 * pi * generateVaryingSpeed(0.7, 0.4, len) .* (1:len));
    walkingDownstairsGyroY = @(len) 1.8 * sin(2 * pi * generateVaryingSpeed(0.7, 0.4, len) .* (1:len));
    walkingDownstairsGyroZ = @(len) 1.8 * cos(2 * pi * generateVaryingSpeed(0.7, 0.4, len) .* (1:len));

    % Sitting
    sittingAccel = @(len) generateNoise(0, 0.05, [3, len]);
    sittingGyro = @(len) generateNoise(0, 0.05, [3, len]);

    % Standing
    standingAccel = @(len) generateNoise(0, 0.03, [3, len]);
    standingGyro = @(len) generateNoise(0, 0.03, [3, len]);

    % Laying
    layingAccel = @(len) generateNoise(0, 0.02, [3, len]);
    layingGyro = @(len) generateNoise(0, 0.02, [3, len]);

    % Jogging
    joggingAccelX = @(len) 2.0 * sin(2 * pi * generateVaryingSpeed(0.9, 0.5, len) .* (1:len));
    joggingAccelY = @(len) 2.0 * cos(2 * pi * generateVaryingSpeed(0.9, 0.5, len) .* (1:len));
    joggingAccelZ = @(len) 2.0 * sin(2 * pi * generateVaryingSpeed(0.9, 0.5, len) .* (1:len));
    joggingGyroX = @(len) 2.0 * cos(2 * pi * generateVaryingSpeed(0.9, 0.5, len) .* (1:len));
    joggingGyroY = @(len) 2.0 * sin(2 * pi * generateVaryingSpeed(0.9, 0.5, len) .* (1:len));
    joggingGyroZ = @(len) 2.0 * cos(2 * pi * generateVaryingSpeed(0.9, 0.5, len) .* (1:len));

    % Simulate activities
    for i = 1:length(activityLabels)
        startIdx = activityIntervals(i) + 1;
        endIdx = activityIntervals(i + 1);
        len = endIdx - startIdx + 1;
        activityID = i;

        % Log the activity
        activityLog = [activityLog; struct('ID', activityID, 'Label', activityLabels{i}, 'Start', startIdx, 'End', endIdx)];

        switch activityLabels{i}
            case 'WALKING'
                accelData(:, startIdx:endIdx) = [walkingAccelX(len); walkingAccelY(len); walkingAccelZ(len)] + generateNoise(0.2, 0.2, [3, len]);
                gyroData(:, startIdx:endIdx) = [walkingGyroX(len); walkingGyroY(len); walkingGyroZ(len)] + generateNoise(0.2, 0.2, [3, len]);
            case 'WALKING UPSTAIRS'
                accelData(:, startIdx:endIdx) = [walkingUpstairsAccelX(len); walkingUpstairsAccelY(len); walkingUpstairsAccelZ(len)] + generateNoise(0.25, 0.25, [3, len]);
                gyroData(:, startIdx:endIdx) = [walkingUpstairsGyroX(len); walkingUpstairsGyroY(len); walkingUpstairsGyroZ(len)] + generateNoise(0.25, 0.25, [3, len]);
            case 'WALKING DOWNSTAIRS'
                accelData(:, startIdx:endIdx) = [walkingDownstairsAccelX(len); walkingDownstairsAccelY(len); walkingDownstairsAccelZ(len)] + generateNoise(0.3, 0.3, [3, len]);
                gyroData(:, startIdx:endIdx) = [walkingDownstairsGyroX(len); walkingDownstairsGyroY(len); walkingDownstairsGyroZ(len)] + generateNoise(0.3, 0.3, [3, len]);
            case 'SITTING'
                accelData(:, startIdx:endIdx) = sittingAccel(len);
                gyroData(:, startIdx:endIdx) = sittingGyro(len);
            case 'STANDING'
                accelData(:, startIdx:endIdx) = standingAccel(len);
                gyroData(:, startIdx:endIdx) = standingGyro(len);
            case 'LAYING'
                accelData(:, startIdx:endIdx) = layingAccel(len);
                gyroData(:, startIdx:endIdx) = layingGyro(len);
            case 'JOGGING'
                accelData(:, startIdx:endIdx) = [joggingAccelX(len); joggingAccelY(len); joggingAccelZ(len)] + generateNoise(0.4, 0.4, [3, len]);
                gyroData(:, startIdx:endIdx) = [joggingGyroX(len); joggingGyroY(len); joggingGyroZ(len)] + generateNoise(0.4, 0.4, [3, len]);
        end
    end

    % Introduce random fall events
    fallDuration = 10 * fs; % Duration of fall event in samples
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
                    fallAccel = linspace(0, fallMagnitude, fallDuration); % Gradual increase to simulate fall
                    accelData(:, fallStart:fallStart + fallDuration - 1) = repmat(fallAccel, 3, 1);
                    fallGyro = linspace(0, fallMagnitude, fallDuration); % Gradual increase to simulate fall
                    gyroData(:, fallStart:fallStart + fallDuration - 1) = repmat(fallGyro, 3, 1);
                case 'backward'
                    fallAccel = linspace(0, -fallMagnitude, fallDuration); % Gradual decrease to simulate fall
                    accelData(:, fallStart:fallStart + fallDuration - 1) = repmat(fallAccel, 3, 1);
                    fallGyro = linspace(0, -fallMagnitude, fallDuration); % Gradual decrease to simulate fall
                    gyroData(:, fallStart:fallStart + fallDuration - 1) = repmat(fallGyro, 3, 1);
            end
        end
    end
end
