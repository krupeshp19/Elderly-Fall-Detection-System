% Main Script for Elderly Fall Detection System
% Paths to activity and fall data folders
activityFolders = {
    "C:\Users\KRUPESH\OneDrive\Desktop\SCS\Elderly-Fall-Detection-System\MobiAct_Dataset_v2.0\StreamData\SLH",...
    "C:\Users\KRUPESH\OneDrive\Desktop\SCS\Elderly-Fall-Detection-System\MobiAct_Dataset_v2.0\StreamData\SBW",...
    "C:\Users\KRUPESH\OneDrive\Desktop\SCS\Elderly-Fall-Detection-System\MobiAct_Dataset_v2.0\StreamData\SBE",...
    "C:\Users\KRUPESH\OneDrive\Desktop\SCS\Elderly-Fall-Detection-System\MobiAct_Dataset_v2.0\StreamData\SRH",...
    "C:\Users\KRUPESH\OneDrive\Desktop\SCS\Elderly-Fall-Detection-System\MobiAct_Dataset_v2.0\StreamData\SLW",...
};

fallFolders = {
    "C:\Users\KRUPESH\OneDrive\Desktop\SCS\Elderly-Fall-Detection-System\MobiAct_Dataset_v2.0\StreamData\BSC",...
    "C:\Users\KRUPESH\OneDrive\Desktop\SCS\Elderly-Fall-Detection-System\MobiAct_Dataset_v2.0\StreamData\FKL",...
    "C:\Users\KRUPESH\OneDrive\Desktop\SCS\Elderly-Fall-Detection-System\MobiAct_Dataset_v2.0\StreamData\FOL",...
    "C:\Users\KRUPESH\OneDrive\Desktop\SCS\Elderly-Fall-Detection-System\MobiAct_Dataset_v2.0\StreamData\SDL",...
};

% Load the trained Random Forest model
model = load('fall_detection_best_rf_model_binary20.mat');
RFModel = model.bestModel;

% Set switch time in seconds (set to empty for random switching)
switchTime = 10; % Example: switch after 10 seconds

% Start the data streaming process
try
    streamData(activityFolders, fallFolders, switchTime, RFModel);
catch ME
    fprintf('An error occurred: %s\n', ME.message);
end
