%% src/preprocess.m
% Automated Nozzle Health Analysis
% Preprocess synthetic nozzle images for feature extraction
% Converts to grayscale, reduces noise, normalizes intensity, crops nozzle
% Saves images in data/processed/

clc; clear; close all;

inputFolder = '../data/synthetic/';
outputFolder = '../data/processed/';

% Create folder if it doesn't exist
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

% List all PNG images in input folder
imgFiles = dir(fullfile(inputFolder, '*.png'));

for i = 1:length(imgFiles)
    % Read image
    img = imread(fullfile(inputFolder, imgFiles(i).name));
    
    % Convert to grayscale (safe for real data)
    imgGray = im2double(img); % im2double scales 0-1
    
    % Noise reduction using median filter
    imgFiltered = medfilt2(imgGray, [3 3]); % 3x3 median filter
    
    % Optional: Crop to nozzle circle (assuming center)
    [rows, cols] = size(imgFiltered);
    center = round([rows/2, cols/2]);
    nozzleRadius = 50; % same as before
    [xx, yy] = meshgrid(1:cols, 1:rows);
    mask = sqrt((xx - center(2)).^2 + (yy - center(1)).^2) <= nozzleRadius;
    imgCropped = imgFiltered .* mask; % zero out everything outside circle
    
    % Normalize intensity 0-1
    imgNorm = (imgCropped - min(imgCropped(:))) / (max(imgCropped(:)) - min(imgCropped(:)));
    
    % Save processed image
    filename = fullfile(outputFolder, imgFiles(i).name);
    imwrite(imgNorm, filename);
    
    % Optional: display first 3 images
    if i <= 3
        figure(1); imshow(imgNorm); title(['Processed Image ', num2str(i)]);
        drawnow;
    end
end

disp('Preprocessing complete! Processed images saved in data/processed/');
