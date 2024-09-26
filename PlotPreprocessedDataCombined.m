% Load the preprocessed combined data
preprocessedData = readtable('preprocessed_data_combined_binary.csv');

% Extract the labels
labels = preprocessedData.Label;

% Count the occurrences of each label
labelCounts = histcounts(labels, 'BinMethod', 'integers');

% Define the label names for visualization
labelNames = {'Activity','Fall'};

% Create a bar plot to visualize the distribution of labels
figure;
bar(labelCounts);
set(gca, 'XTickLabel', labelNames, 'XTick', 1:numel(labelNames));
xlabel('Activity/Fall Type');
ylabel('Count');
title('Distribution of Activity/Fall Types in Preprocessed Data');
xtickangle(45); % Rotate x-axis labels for better readability
grid on;

% Display the counts for each label
for i = 1:numel(labelCounts)
    text(i, labelCounts(i), num2str(labelCounts(i)), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center');
end
