function activityData = extractFeatures(t, accelData, gyroData, tBodyAcc, tGravityAcc, tBodyAccJerk, tBodyGyroJerk, activityLog, ~)
    % Compute magnitudes
    tBodyAccMag = sqrt(sum(tBodyAcc.^2, 1));
    tGravityAccMag = sqrt(sum(tGravityAcc.^2, 1));
    tBodyAccJerkMag = sqrt(sum(tBodyAccJerk.^2, 1));
    tBodyGyroMag = sqrt(sum(gyroData.^2, 1));
    tBodyGyroJerkMag = sqrt(sum(tBodyGyroJerk.^2, 1));

    % Fast Fourier Transform (FFT)
    fBodyAcc = abs(fft(tBodyAcc, [], 2));
    fBodyAccJerk = abs(fft(tBodyAccJerk, [], 2));
    fBodyGyro = abs(fft(gyroData, [], 2));
    fBodyAccMag = abs(fft(tBodyAccMag));
    fBodyAccJerkMag = abs(fft(tBodyAccJerkMag));
    fBodyGyroMag = abs(fft(tBodyGyroMag));
    fBodyGyroJerkMag = abs(fft(tBodyGyroJerkMag));

    % Package the generated data into a struct
    activityData.time = t;
    activityData.accel = accelData;
    activityData.gyro = gyroData;
    activityData.tBodyAcc = tBodyAcc;
    activityData.tGravityAcc = tGravityAcc;
    activityData.tBodyAccJerk = tBodyAccJerk;
    activityData.tBodyGyroJerk = tBodyGyroJerk;
    activityData.tBodyAccMag = tBodyAccMag;
    activityData.tGravityAccMag = tGravityAccMag;
    activityData.tBodyAccJerkMag = tBodyAccJerkMag;
    activityData.tBodyGyroMag = tBodyGyroMag;
    activityData.tBodyGyroJerkMag = tBodyGyroJerkMag;
    activityData.fBodyAcc = fBodyAcc;
    activityData.fBodyAccJerk = fBodyAccJerk;
    activityData.fBodyGyro = fBodyGyro;
    activityData.fBodyAccMag = fBodyAccMag;
    activityData.fBodyAccJerkMag = fBodyAccJerkMag;
    activityData.fBodyGyroMag = fBodyGyroMag;
    activityData.fBodyGyroJerkMag = fBodyGyroJerkMag;
    activityData.log = activityLog;
end
