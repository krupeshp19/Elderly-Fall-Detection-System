function activityData = generateActivityData(duration)
    % This function generates synthetic accelerometer and gyroscope data
    % for a given duration. It simulates normal activities and fall events.
    % The output data structure aligns with project requirements for use
    % in further processing and machine learning models.

    % Parameters
    % duration - The total duration (in seconds) for which to generate data

    % Validate input
    if nargin < 1 || duration <= 0
        error('Duration must be a positive integer.');
    end
    
    % Set random seed for reproducibility
    rng(0);

    % Initialize time vector
    t = 1:duration;

    % Generate normal activity data (e.g., walking)
    normalAccel = sin(2 * pi * 0.2 * t) + 0.1 * randn(size(t));
    normalGyro = cos(2 * pi * 0.2 * t) + 0.1 * randn(size(t));

    % Initialize accelerometer and gyroscope data arrays
    accelData = normalAccel;
    gyroData = normalGyro;

    % Introduce random fall events
    fallDuration = 10; % Duration of a fall event
    numFalls = randi([1, 3]); % Random number of falls between 1 and 3

    fallPositions = [];
    for i = 1:numFalls
        % Ensure non-overlapping fall events
        fallStart = randi([1, duration - fallDuration]);
        while any(abs(fallStart - fallPositions) < fallDuration)
            fallStart = randi([1, duration - fallDuration]);
        end
        fallPositions(end+1) = fallStart; %#ok<AGROW>

        % Generate fall event data for accelerometer
        fallAccel = 5 * rand(1, fallDuration); % Higher values to simulate a fall
        accelData(fallStart:fallStart + fallDuration - 1) = fallAccel;

        % Generate fall event data for gyroscope
        fallGyro = 5 * rand(1, fallDuration); % Higher values to simulate a fall
        gyroData(fallStart:fallStart + fallDuration - 1) = fallGyro;
    end

    % Package the generated data into a struct
    activityData.time = t;
    activityData.accel = accelData;
    activityData.gyro = gyroData;

    % Plot the generated data for visual verification
    figure;
    subplot(2, 1, 1);
    plot(t, accelData);
    title('Synthetic Accelerometer Data');
    xlabel('Time (s)');
    ylabel('Acceleration (m/s^2)');

    subplot(2, 1, 2);
    plot(t, gyroData);
    title('Synthetic Gyroscope Data');
    xlabel('Time (s)');
    ylabel('Angular Velocity (rad/s)');

end
