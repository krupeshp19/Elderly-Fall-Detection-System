function features = extractFeatures(preprocessedData, windowSize, overlap)
    % This function extracts relevant features from the preprocessed activity
    % data. Features are calculated over sliding windows.

    % Parameters
    % windowSize - The size of the sliding window (in samples)
    % overlap - The number of overlapping samples between consecutive windows

    % Extract preprocessed data
    accelData = preprocessedData.accel;
    gyroData = preprocessedData.gyro;
    time = preprocessedData.time;

    % Initialize feature arrays
    numWindows = floor((length(accelData) - windowSize) / (windowSize - overlap)) + 1;
    meanAccel = zeros(numWindows, 1);
    stdAccel = zeros(numWindows, 1);
    rmsAccel = zeros(numWindows, 1);
    meanGyro = zeros(numWindows, 1);
    stdGyro = zeros(numWindows, 1);
    rmsGyro = zeros(numWindows, 1);

    % Calculate features over sliding windows
    for i = 1:numWindows
        startIdx = (i - 1) * (windowSize - overlap) + 1;
        endIdx = startIdx + windowSize - 1;
        if endIdx > length(accelData)
            break;
        end

        % Extract window data
        windowAccel = accelData(startIdx:endIdx);
        windowGyro = gyroData(startIdx:endIdx);

        % Calculate features
        meanAccel(i) = mean(windowAccel);
        stdAccel(i) = std(windowAccel);
        rmsAccel(i) = rms(windowAccel);
        meanGyro(i) = mean(windowGyro);
        stdGyro(i) = std(windowGyro);
        rmsGyro(i) = rms(windowGyro);
    end

    % Package the extracted features into a struct
    features.meanAccel = meanAccel;
    features.stdAccel = stdAccel;
    features.rmsAccel = rmsAccel;
    features.meanGyro = meanGyro;
    features.stdGyro = stdGyro;
    features.rmsGyro = rmsGyro;
    features.time = time(1:windowSize-overlap:endIdx);

end
