%% run_pipeline.m – Guaranteed Clean/Mild/Severe
clc; clear; close all;

disp('Starting nozzle analysis pipeline...');

%% Step 0: Ensure results folder exists
if ~exist('../results', 'dir')
    mkdir('../results');
end

%% Step 1: Generate synthetic data with guaranteed labels
disp('Step 1: Generating synthetic nozzle images...');
numImages = 20;
imgSize = [64 64];

for i = 1:numImages
    img = ones(imgSize); % white background
    
    % Assign blob number based on desired label
    if i <= 7
        numBlobs = 0; % Clean
    elseif i <= 14
        numBlobs = randi([1,2]); % Mild
    else
        numBlobs = randi([3,4]); % Severe
    end
    
    radius = randi([1,2],1,numBlobs);        % small radius
    intensity = 0.85 + 0.1*rand(1,numBlobs); % light for clean/mild, slightly darker for severe
    
    for j = 1:numBlobs
        [X,Y] = meshgrid(1:imgSize(2),1:imgSize(1));
        cx = randi([5,imgSize(2)-5]);
        cy = randi([5,imgSize(1)-5]);
        maskBlob = sqrt((X-cx).^2 + (Y-cy).^2) <= radius(j);
        img(maskBlob) = intensity(j);
    end
    
    filename = sprintf('../data/synthetic/nozzle_%02d.png',i);
    imwrite(img, filename);
end
disp('Synthetic images generated.');

%% Step 2: Extract features
disp('Step 2: Extracting features...');
featureTable = table;
imgFiles = dir('../data/synthetic/*.png');

for i = 1:length(imgFiles)
    img = imread(fullfile(imgFiles(i).folder,imgFiles(i).name));
    
    % Convert to double grayscale
    if size(img,3) == 3
        imgGray = im2double(rgb2gray(img));
    else
        imgGray = im2double(img);
    end
    
    % Contamination mask: pixels < 0.95
    mask = imgGray < 0.95;
    
    % Feature 1: Contamination area
    area = sum(mask(:))/numel(mask); % 0-1
    
    % Feature 2: Rough radial symmetry
    if sum(mask(:)) > 0
        rotMask = rot90(mask,2);
        symmetry = sum(mask(:) & rotMask(:)) / sum(mask(:));
    else
        symmetry = 1;
    end
    
    % Feature 3: Intensity variance within mask
    if sum(mask(:)) > 0
        intensityVar = var(imgGray(mask));
    else
        intensityVar = 0;
    end
    
    featureTable.ImageName{i,1} = imgFiles(i).name;
    featureTable.ContaminationArea(i,1) = area;
    featureTable.RadialSymmetry(i,1) = symmetry;
    featureTable.IntensityVariance(i,1) = intensityVar;
end

writetable(featureTable, '../results/features_summary.csv');
disp('Feature extraction complete.');

%% Step 3: Classify nozzles with tuned thresholds
disp('Step 3: Classifying nozzles...');
health = strings(height(featureTable),1);

for i = 1:height(featureTable)
    areaPct = featureTable.ContaminationArea(i)*100;
    symmetry = featureTable.RadialSymmetry(i);
    variancePct = featureTable.IntensityVariance(i)*100;
    
    % Tuned thresholds for demo
    if areaPct > 5 || symmetry < 0.7 || variancePct > 0.01
        health(i) = "Severe";
    elseif areaPct > 1 || symmetry < 0.85 || variancePct > 0.005
        health(i) = "Mild";
    else
        health(i) = "Clean";
    end
end

featureTable.NozzleHealth = health;
writetable(featureTable, '../results/features_classified.csv');
disp('Nozzle classification complete.');

%% Step 4: Display demo table of first N nozzles
N = min(5,height(featureTable));
demoTable = featureTable(1:N, {'ImageName','ContaminationArea','RadialSymmetry','IntensityVariance','NozzleHealth'});
demoTable.ContaminationArea = round(demoTable.ContaminationArea*100,1); % %
demoTable.IntensityVariance = round(demoTable.IntensityVariance*100,3); % %
disp('--- Demo: Nozzle Features and Classification ---');
disp(demoTable);

%% Step 5: Show images with masks and color-coded labels
figure('Name','Nozzle Demo','NumberTitle','off');
for i = 1:N
    img = imread(fullfile(imgFiles(i).folder,imgFiles(i).name));
    if size(img,3) == 3
        imgGray = im2double(rgb2gray(img));
    else
        imgGray = im2double(img);
    end
    mask = imgGray < 0.95;
    
    % Color-coded label
    switch demoTable.NozzleHealth(i)
        case "Clean"
            c = [0 1 0]; % green
        case "Mild"
            c = [1 1 0]; % yellow
        case "Severe"
            c = [1 0 0]; % red
    end
    
    % Top row: original image
    subplot(2,N,i);
    imshow(img); title(['Original: ', demoTable.ImageName{i}]);
    
    % Bottom row: overlay mask with color
    subplot(2,N,N+i);
    imshow(img); hold on;
    h = imshow(cat(3,mask*c(1),mask*c(2),mask*c(3)));
    set(h,'AlphaData',0.5);
    title(['Label: ', demoTable.NozzleHealth{i}]);
end

disp('Pipeline complete! Check ../results for CSV and visualizations.');
