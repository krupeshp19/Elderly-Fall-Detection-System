function preprocessedData = preprocessData(activityData)
    % Normalize the accelerometer and gyroscope data
    accelData = activityData.accel;
    gyroData = activityData.gyro;
    
    accelData = normalize(accelData, 2);
    gyroData = normalize(gyroData, 2);
    
    % Apply a low-pass filter to remove noise
    % Design a low-pass filter with a cutoff frequency of 0.1 Hz
    [b, a] = butter(2, 0.1, 'low');
    for i = 1:3
        accelData(i, :) = filtfilt(b, a, accelData(i, :));
        gyroData(i, :) = filtfilt(b, a, gyroData(i, :));
    end
    
    % Package the preprocessed data into a struct
    preprocessedData.time = activityData.time;
    preprocessedData.accel = accelData;
    preprocessedData.gyro = gyroData;
    
    % Plot the preprocessed data for visual verification
    figure;
    subplot(3, 2, 1); plot(preprocessedData.time, accelData(1, :)); title('Accelerometer X-axis');
    subplot(3, 2, 2); plot(preprocessedData.time, gyroData(1, :)); title('Gyroscope X-axis');
    subplot(3, 2, 3); plot(preprocessedData.time, accelData(2, :)); title('Accelerometer Y-axis');
    subplot(3, 2, 4); plot(preprocessedData.time, gyroData(2, :)); title('Gyroscope Y-axis');
    subplot(3, 2, 5); plot(preprocessedData.time, accelData(3, :)); title('Accelerometer Z-axis');
    subplot(3, 2, 6); plot(preprocessedData.time, gyroData(3, :)); title('Gyroscope Z-axis');
end
