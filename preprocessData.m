function preprocessedData = preprocessData(activityData)
    % This function preprocesses the synthetic activity data by normalizing
    % and filtering the accelerometer and gyroscope data.

    % Extract raw data
    accelData = activityData.accel;
    gyroData = activityData.gyro;

    % Normalize the accelerometer data
    normAccel = (accelData - mean(accelData)) / std(accelData);

    % Normalize the gyroscope data
    normGyro = (gyroData - mean(gyroData)) / std(gyroData);

    % Apply a low-pass filter to the normalized data
    % Design a low-pass filter
    fs = 50; % Sampling frequency (Hz)
    fc = 5; % Cutoff frequency (Hz)
    [b, a] = butter(4, fc / (fs / 2), 'low'); % 4th order Butterworth filter

    % Filter the accelerometer data
    filtAccel = filtfilt(b, a, normAccel);

    % Filter the gyroscope data
    filtGyro = filtfilt(b, a, normGyro);

    % Package the preprocessed data into a struct
    preprocessedData.time = activityData.time;
    preprocessedData.accel = filtAccel;
    preprocessedData.gyro = filtGyro;

    % Plot the preprocessed data for visual verification
    figure;
    subplot(2, 1, 1);
    plot(activityData.time, filtAccel);
    title('Preprocessed Accelerometer Data');
    xlabel('Time (s)');
    ylabel('Normalized Acceleration (m/s^2)');

    subplot(2, 1, 2);
    plot(activityData.time, filtGyro);
    title('Preprocessed Gyroscope Data');
    xlabel('Time (s)');
    ylabel('Normalized Angular Velocity (rad/s)');

end
