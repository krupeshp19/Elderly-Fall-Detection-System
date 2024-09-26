% Ensure you have the Parallel Computing Toolbox
if isempty(gcp('nocreate'))
    parpool('local');
end

% Load preprocessed data
data = readtable('preprocessed_data_combined_binary20.csv');

% Split data into features (X) and labels (y)
X = data{:, 1:end-1};
y = data{:, end};

% Split data into training (70%) and testing (30%) sets
cv = cvpartition(size(X, 1), 'HoldOut', 0.3);
XTrain = X(training(cv), :);
yTrain = y(training(cv), :);
XTest = X(test(cv), :);
yTest = y(test(cv), :);

% Compute class weights
classLabels = unique(yTrain);
numClasses = length(classLabels);
classCounts = histcounts(yTrain, numClasses);
classWeights = max(classCounts) ./ classCounts;
sampleWeights = arrayfun(@(label) classWeights(label == classLabels), yTrain);

% Hyperparameter tuning with grid search
numTreesOptions = [100, 150, 200];
minLeafSizeOptions = [2, 4, 6];
bestAccuracy = 0;
bestModel = [];

fprintf('Starting grid search for hyperparameter tuning...\n');
tic; % Start timer

for numTrees = numTreesOptions
    for minLeafSize = minLeafSizeOptions
        fprintf('Training Random Forest with %d trees and min leaf size %d...\n', numTrees, minLeafSize);
        
        % Train a Random Forest model with class weights
        RFModel = TreeBagger(numTrees, XTrain, yTrain, 'OOBPrediction', 'On', 'Method', 'classification', ...
                             'Weights', sampleWeights, 'MinLeafSize', minLeafSize, ...
                             'Options', statset('UseParallel', true, 'UseSubstreams', true, 'Streams', RandStream('mlfg6331_64')));

        % Evaluate the model
        yPred = str2double(predict(RFModel, XTest));
        accuracy = sum(yPred == yTest) / length(yTest);
        fprintf('Model Accuracy: %.2f%%\n', accuracy * 100);

        if accuracy > bestAccuracy
            bestAccuracy = accuracy;
            bestModel = RFModel;
        end
    end
end

elapsedTime = toc; % Stop timer
fprintf('Grid search completed in %.2f seconds.\n', elapsedTime);
fprintf('Best Model Accuracy: %.2f%%\n', bestAccuracy * 100);

% Detailed evaluation of the best model
yPred = str2double(predict(bestModel, XTest));
confMat = confusionmat(yTest, yPred);
precision = diag(confMat) ./ sum(confMat, 2);
recall = diag(confMat) ./ sum(confMat, 1)';
f1Score = 2 * (precision .* recall) ./ (precision + recall);

fprintf('Precision: %.2f%%\n', mean(precision, 'omitnan') * 100);
fprintf('Recall: %.2f%%\n', mean(recall, 'omitnan') * 100);
fprintf('F1 Score: %.2f\n', mean(f1Score, 'omitnan'));

% Plot confusion matrix
figure;
confusionchart(confMat, 'RowSummary', 'row-normalized', 'ColumnSummary', 'column-normalized');
title('Confusion Matrix');

% Save the best model
save('fall_detection_best_rf_model_binary20.mat', 'bestModel');

% Clean up the parallel pool
delete(gcp('nocreate'));
