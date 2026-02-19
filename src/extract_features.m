%% src/extract_features.m
% Extract contamination features from nozzle images
% Visualizes masks correctly (black = contamination)
% Saves results to CSV

clc; clear; close all;

inputFolder = '../data/synthetic/';
outputCSV = '../results/features_summary.csv';

if ~exist('../results', 'dir')
    mkdir('../results');
end

imgFiles = dir(fullfile(inputFolder, '*.png'));

% Prepare table
results = table('Size',[length(imgFiles) 4], ...
                'VariableTypes',{'string','double','double','double'}, ...
                'VariableNames',{'ImageName','ContaminationArea','RadialSymmetry','IntensityVariance'});

% Threshold for contamination
contaminationThreshold = 0.3;

[xx, yy] = deal([]); % grid placeholders

for i = 1:length(imgFiles)
    img = imread(fullfile(inputFolder, imgFiles(i).name));
    img = im2double(img);
    
    % Contamination mask
    contaminationMask = img < contaminationThreshold;
    contaminationArea = sum(contaminationMask(:)) / sum(img(:) > 0);
    
    % Radial symmetry
    [rows, cols] = size(img);
    if isempty(xx)
        [xx, yy] = meshgrid(1:cols, 1:rows);
    end
    center = [cols/2, rows/2];
    distances = sqrt((xx - center(1)).^2 + (yy - center(2)).^2);
    radialSymmetry = 1 - std(distances(contaminationMask)) / max(distances(:));
    
    % Intensity variance
    intensityVar = var(img(contaminationMask));
    
    % Save
    results.ImageName(i) = string(imgFiles(i).name);
    results.ContaminationArea(i) = contaminationArea;
    results.RadialSymmetry(i) = radialSymmetry;
    results.IntensityVariance(i) = intensityVar;
    
    % Visualization for first 3 images
    if i <= 3
        figure;
        subplot(1,2,1); imshow(img); title(['Original Image: ', imgFiles(i).name]);
        subplot(1,2,2); imshow(~contaminationMask, 'InitialMagnification','fit'); % inverted mask
        title('Contamination Mask (black = contaminated)');
        colormap(gray);
    end
end

% Save CSV
writetable(results, outputCSV);
disp('Feature extraction complete! CSV saved.');
