function preprocessedData = preprocessData(activityData)
    try
        % Validate input data
        validateattributes(activityData, {'struct'}, {'nonempty'}, mfilename, 'activityData');
        validateattributes(activityData.accel, {'numeric'}, {'size', [3, NaN]}, mfilename, 'accelData');
        validateattributes(activityData.gyro, {'numeric'}, {'size', [3, NaN]}, mfilename, 'gyroData');
        
        % Normalize the accelerometer and gyroscope data
        accelData = normalize(activityData.accel, 2);
        gyroData = normalize(activityData.gyro, 2);
        
        % Apply a low-pass filter to remove noise
        [b, a] = butter(2, 0.1, 'low');
        for i = 1:3
            accelData(i, :) = filtfilt(b, a, accelData(i, :));
            gyroData(i, :) = filtfilt(b, a, gyroData(i, :));
        end
        
        % Package the preprocessed data into a struct
        preprocessedData.time = activityData.time;
        preprocessedData.accel = accelData;
        preprocessedData.gyro = gyroData;
        preprocessedData.log = activityData.log;
        
        % Plot the preprocessed data for visual verification
        figure;
        subplot(3, 2, 1); plot(preprocessedData.time, accelData(1, :)); title('Accelerometer X-axis');
        subplot(3, 2, 2); plot(preprocessedData.time, gyroData(1, :)); title('Gyroscope X-axis');
        subplot(3, 2, 3); plot(preprocessedData.time, accelData(2, :)); title('Accelerometer Y-axis');
        subplot(3, 2, 4); plot(preprocessedData.time, gyroData(2, :)); title('Gyroscope Y-axis');
        subplot(3, 2, 5); plot(preprocessedData.time, accelData(3, :)); title('Accelerometer Z-axis');
        subplot(3, 2, 6); plot(preprocessedData.time, gyroData(3, :)); title('Gyroscope Z-axis');
        
    catch ME
        % Handle errors gracefully
        disp('An error occurred during preprocessing:');
        disp(ME.message);
        preprocessedData = [];
    end
end