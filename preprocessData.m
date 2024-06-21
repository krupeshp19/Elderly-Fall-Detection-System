function [accelData, gyroData, tBodyAcc, tGravityAcc, tBodyAccJerk, tBodyGyroJerk] = preprocessData(accelData, gyroData, fs)
    % Apply median filter
    accelData = medfilt1(accelData, 3, [], 2);
    gyroData = medfilt1(gyroData, 3, [], 2);

    % Apply 3rd order low pass Butterworth filter with a corner frequency of 20 Hz
    [b, a] = butter(3, 20/(fs/2), 'low');
    accelData = filtfilt(b, a, accelData')';
    gyroData = filtfilt(b, a, gyroData')';

    % Separate acceleration into body and gravity components using low pass Butterworth filter with 0.3 Hz
    [b_grav, a_grav] = butter(3, 0.3/(fs/2), 'low');
    tGravityAcc = filtfilt(b_grav, a_grav, accelData')';
    tBodyAcc = accelData - tGravityAcc;

    % Compute Jerk signals
    tBodyAccJerk = diff(tBodyAcc, 1, 2);
    tBodyAccJerk = [tBodyAccJerk, tBodyAccJerk(:, end)]; % Maintain original length
    tBodyGyroJerk = diff(gyroData, 1, 2);
    tBodyGyroJerk = [tBodyGyroJerk, tBodyGyroJerk(:, end)]; % Maintain original length
end
