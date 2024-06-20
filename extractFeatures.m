function features = extractFeatures(preprocessedData)
    try
        % Validate input data
        validateattributes(preprocessedData, {'struct'}, {'nonempty'}, mfilename, 'preprocessedData');
        validateattributes(preprocessedData.accel, {'numeric'}, {'size', [3, NaN]}, mfilename, 'accelData');
        validateattributes(preprocessedData.gyro, {'numeric'}, {'size', [3, NaN]}, mfilename, 'gyroData');
        
        % Initialize feature struct
        features = struct;
        
        % Feature extraction function
        extractStatFeatures = @(data) struct( ...
            'mean', mean(data, 2), ...
            'std', std(data, 0, 2), ...
            'rms', rms(data, 2), ...
            'max', max(data, [], 2), ...
            'min', min(data, [], 2), ...
            'energy', sum(data .^ 2, 2));
        
        % Extract features for accelerometer data
        features.accel = extractStatFeatures(preprocessedData.accel);
        
        % Extract features for gyroscope data
        features.gyro = extractStatFeatures(preprocessedData.gyro);
        
        % Calculate correlations between accelerometer and gyroscope data
        features.corr = struct( ...
            'accel_gyro_x', corr(preprocessedData.accel(1, :)', preprocessedData.gyro(1, :)'), ...
            'accel_gyro_y', corr(preprocessedData.accel(2, :)', preprocessedData.gyro(2, :)'), ...
            'accel_gyro_z', corr(preprocessedData.accel(3, :)', preprocessedData.gyro(3, :)'));
        
    catch ME
        % Handle errors gracefully
        disp('An error occurred during feature extraction:');
        disp(ME.message);
        features = [];
    end
end