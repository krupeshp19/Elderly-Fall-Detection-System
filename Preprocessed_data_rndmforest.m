% Define the data directories
folders = {
    'C:\Users\KRUPESH\OneDrive\Desktop\SCS\Elderly-Fall-Detection-System\MobiAct_Dataset_v2.0\Annotated Data\STD', ...
    'C:\Users\KRUPESH\OneDrive\Desktop\SCS\Elderly-Fall-Detection-System\MobiAct_Dataset_v2.0\Annotated Data\WAL', ...
    'C:\Users\KRUPESH\OneDrive\Desktop\SCS\Elderly-Fall-Detection-System\MobiAct_Dataset_v2.0\Annotated Data\JOG', ...
    'C:\Users\KRUPESH\OneDrive\Desktop\SCS\Elderly-Fall-Detection-System\MobiAct_Dataset_v2.0\Annotated Data\JUM', ...
    'C:\Users\KRUPESH\OneDrive\Desktop\SCS\Elderly-Fall-Detection-System\MobiAct_Dataset_v2.0\Annotated Data\STU', ...
    'C:\Users\KRUPESH\OneDrive\Desktop\SCS\Elderly-Fall-Detection-System\MobiAct_Dataset_v2.0\Annotated Data\STN', ...
    'C:\Users\KRUPESH\OneDrive\Desktop\SCS\Elderly-Fall-Detection-System\MobiAct_Dataset_v2.0\Annotated Data\SCH', ...
    'C:\Users\KRUPESH\OneDrive\Desktop\SCS\Elderly-Fall-Detection-System\MobiAct_Dataset_v2.0\Annotated Data\SIT', ...
    'C:\Users\KRUPESH\OneDrive\Desktop\SCS\Elderly-Fall-Detection-System\MobiAct_Dataset_v2.0\Annotated Data\CHU', ...
    'C:\Users\KRUPESH\OneDrive\Desktop\SCS\Elderly-Fall-Detection-System\MobiAct_Dataset_v2.0\Annotated Data\CSI', ...
    'C:\Users\KRUPESH\OneDrive\Desktop\SCS\Elderly-Fall-Detection-System\MobiAct_Dataset_v2.0\Annotated Data\CSO', ...
    'C:\Users\KRUPESH\OneDrive\Desktop\SCS\Elderly-Fall-Detection-System\MobiAct_Dataset_v2.0\Annotated Data\SLH', ...
    'C:\Users\KRUPESH\OneDrive\Desktop\SCS\Elderly-Fall-Detection-System\MobiAct_Dataset_v2.0\Annotated Data\SBW', ...
    'C:\Users\KRUPESH\OneDrive\Desktop\SCS\Elderly-Fall-Detection-System\MobiAct_Dataset_v2.0\Annotated Data\SLW', ...
    'C:\Users\KRUPESH\OneDrive\Desktop\SCS\Elderly-Fall-Detection-System\MobiAct_Dataset_v2.0\Annotated Data\SBE', ...
    'C:\Users\KRUPESH\OneDrive\Desktop\SCS\Elderly-Fall-Detection-System\MobiAct_Dataset_v2.0\Annotated Data\SRH', ...
    'C:\Users\KRUPESH\OneDrive\Desktop\SCS\Elderly-Fall-Detection-System\MobiAct_Dataset_v2.0\Annotated Data\FOL', ...
    'C:\Users\KRUPESH\OneDrive\Desktop\SCS\Elderly-Fall-Detection-System\MobiAct_Dataset_v2.0\Annotated Data\FKL', ...
    'C:\Users\KRUPESH\OneDrive\Desktop\SCS\Elderly-Fall-Detection-System\MobiAct_Dataset_v2.0\Annotated Data\BSC', ...
    'C:\Users\KRUPESH\OneDrive\Desktop\SCS\Elderly-Fall-Detection-System\MobiAct_Dataset_v2.0\Annotated Data\SDL', ...
};

% Set up parallel pool
parpool;

% Initialize variables to store data
allData = [];
allLabels = [];
totalFilesProcessed = 0;

% Define label mapping
labelMapping = containers.Map( ...
    {'STD', 'WAL', 'JOG', 'JUM', 'STU', 'STN', 'SCH', 'SIT', 'CHU', 'CSI', 'CSO', 'LYI', 'FOL', 'FKL', 'BSC', 'SDL'}, ...
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1} ...
);

% Load and preprocess data in parallel
parfor i = 1:length(folders)
    folderData = [];
    folderLabels = [];
    files = dir(fullfile(folders{i}, '*.csv'));
    numFiles = length(files);
    totalFilesProcessed = totalFilesProcessed + numFiles; % Count the number of files processed
    for j = 1:numFiles
        filePath = fullfile(files(j).folder, files(j).name);
        rawData = readtable(filePath);
        
        % Assign numerical labels based on the 'label' column values
        numericalLabels = zeros(height(rawData), 1);
        for k = 1:height(rawData)
            numericalLabels(k) = labelMapping(rawData.label{k});
        end
        rawData.label = numericalLabels;

        % Segment the data into fixed-size windows (1 seconds = 200 samples)
        windowSize = 20;
        numWindows = floor(height(rawData) / windowSize);
        for k = 1:numWindows
            startIdx = (k-1) * windowSize + 1;
            endIdx = startIdx + windowSize - 1;
            windowData = rawData(startIdx:endIdx, :);
            
            % Extract features
            features = extractFeatures(windowData);
            folderData = [folderData; features];
            
            % Determine the majority label in the window
            majorityLabel = mode(windowData.label);
            folderLabels = [folderLabels; majorityLabel];
        end
    end
    
    % Combine results from each folder
    allData = [allData; folderData];
    allLabels = [allLabels; folderLabels];
end

% Save combined data to a CSV file for final verification
preprocessedData = array2table([allData, allLabels], ...
    'VariableNames', {'meanAccX', 'meanAccY', 'meanAccZ', 'varAccX', 'varAccY', 'varAccZ', 'stdAccX', 'stdAccY', 'stdAccZ', ...
        'skewAccX', 'skewAccY', 'skewAccZ', 'kurtAccX', 'kurtAccY', 'kurtAccZ', 'smaAccX', 'smaAccY', 'smaAccZ', 'rmsAccX', 'rmsAccY', 'rmsAccZ', ...
        'zcrAccX', 'zcrAccY', 'zcrAccZ', 'energyAccX', 'energyAccY', 'energyAccZ', 'meanGyroX', 'meanGyroY', 'meanGyroZ', 'varGyroX', 'varGyroY', 'varGyroZ', ...
        'stdGyroX', 'stdGyroY', 'stdGyroZ', 'skewGyroX', 'skewGyroY', 'skewGyroZ', 'kurtGyroX', 'kurtGyroY', 'kurtGyroZ', 'smaGyroX', 'smaGyroY', 'smaGyroZ', ...
        'rmsGyroX', 'rmsGyroY', 'rmsGyroZ', 'zcrGyroX', 'zcrGyroY', 'zcrGyroZ', 'energyGyroX', 'energyGyroY', 'energyGyroZ', 'meanOriAzimuth', 'meanOriPitch', ...
        'meanOriRoll', 'varOriAzimuth', 'varOriPitch', 'varOriRoll', 'stdOriAzimuth', 'stdOriPitch', 'stdOriRoll', ...
        'skewOriAzimuth', 'skewOriPitch', 'skewOriRoll', 'kurtOriAzimuth', 'kurtOriPitch', 'kurtOriRoll', ...
        'meanFFTAccX', 'meanFFTAccY', 'meanFFTAccZ', 'dominantFreqAccX', 'dominantFreqAccY', 'dominantFreqAccZ', ...
        'meanFFTGyroX', 'meanFFTGyroY', 'meanFFTGyroZ', 'dominantFreqGyroX', 'dominantFreqGyroY', 'dominantFreqGyroZ', 'Label'});
writetable(preprocessedData, 'preprocessed_data_combined_binary20.csv');

% Display the total number of files processed
fprintf('Total number of files processed: %d\n', totalFilesProcessed);

% Extract features
function features = extractFeatures(data)
    % Time-domain features
    meanAcc = mean(data{:, {'acc_x', 'acc_y', 'acc_z'}});
    varAcc = var(data{:, {'acc_x', 'acc_y', 'acc_z'}});
    stdAcc = std(data{:, {'acc_x', 'acc_y', 'acc_z'}});
    skewAcc = skewness(data{:, {'acc_x', 'acc_y', 'acc_z'}});
    kurtAcc = kurtosis(data{:, {'acc_x', 'acc_y', 'acc_z'}});
    smaAcc = sum(abs(data{:, {'acc_x', 'acc_y', 'acc_z'}}));
    rmsAcc = sqrt(mean(data{:, {'acc_x', 'acc_y', 'acc_z'}} .^ 2));
    zcrAcc = sum(diff(sign(data{:, {'acc_x', 'acc_y', 'acc_z'}})) ~= 0);
    energyAcc = sum(data{:, {'acc_x', 'acc_y', 'acc_z'}} .^ 2);
    
    meanGyro = mean(data{:, {'gyro_x', 'gyro_y', 'gyro_z'}});
    varGyro = var(data{:, {'gyro_x', 'gyro_y', 'gyro_z'}});
    stdGyro = std(data{:, {'gyro_x', 'gyro_y', 'gyro_z'}});
    skewGyro = skewness(data{:, {'gyro_x', 'gyro_y', 'gyro_z'}});
    kurtGyro = kurtosis(data{:, {'gyro_x', 'gyro_y', 'gyro_z'}});
    smaGyro = sum(abs(data{:, {'gyro_x', 'gyro_y', 'gyro_z'}}));
    rmsGyro = sqrt(mean(data{:, {'gyro_x', 'gyro_y', 'gyro_z'}} .^ 2));
    zcrGyro = sum(diff(sign(data{:, {'gyro_x', 'gyro_y', 'gyro_z'}})) ~= 0);
    energyGyro = sum(data{:, {'gyro_x', 'gyro_y', 'gyro_z'}} .^ 2);

    % Orientation features
    meanOri = mean(data{:, {'azimuth', 'pitch', 'roll'}});
    varOri = var(data{:, {'azimuth', 'pitch', 'roll'}});
    stdOri = std(data{:, {'azimuth', 'pitch', 'roll'}});
    skewOri = skewness(data{:, {'azimuth', 'pitch', 'roll'}});
    kurtOri = kurtosis(data{:, {'azimuth', 'pitch', 'roll'}});

    % Frequency-domain features (using FFT)
    fftAccX = abs(fft(data.acc_x));
    fftAccY = abs(fft(data.acc_y));
    fftAccZ = abs(fft(data.acc_z));
    meanFFTAcc = mean([fftAccX, fftAccY, fftAccZ]);
    dominantFreqAccX = max(fftAccX);
    dominantFreqAccY = max(fftAccY);
    dominantFreqAccZ = max(fftAccZ);
    
    fftGyroX = abs(fft(data.gyro_x));
    fftGyroY = abs(fft(data.gyro_y));
    fftGyroZ = abs(fft(data.gyro_z));
    meanFFTGyro = mean([fftGyroX, fftGyroY, fftGyroZ]);
    dominantFreqGyroX = max(fftGyroX);
    dominantFreqGyroY = max(fftGyroY);
    dominantFreqGyroZ = max(fftGyroZ);

    % Combine all features into a single row vector
    features = [meanAcc, varAcc, stdAcc, skewAcc, kurtAcc, smaAcc, rmsAcc, zcrAcc, energyAcc, ...
                meanGyro, varGyro, stdGyro, skewGyro, kurtGyro, smaGyro, rmsGyro, zcrGyro, energyGyro, ...
                meanOri, varOri, stdOri, skewOri, kurtOri, ...
                meanFFTAcc, dominantFreqAccX, dominantFreqAccY, dominantFreqAccZ, ...
                meanFFTGyro, dominantFreqGyroX, dominantFreqGyroY, dominantFreqGyroZ];
end

% Terminate parallel pool
delete(gcp('nocreate'));
