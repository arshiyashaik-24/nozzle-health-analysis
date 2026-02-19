%% src/generate_data.m
% Generate synthetic nozzle images with realistic contamination patterns
% Smaller filled blobs, darker than nozzle, visible in mask
% Saves images in data/synthetic/

clc; clear; close all;

outputFolder = '../data/synthetic/';
numImages = 20;
imgSize = 128;             % image size
nozzleRadius = 50;         % nozzle circle radius
numBlobs = 10;              % contamination spots per nozzle
blobRadiusRange = [4, 12]; % smaller blobs
blobIntensityRange = [0, 0.25]; % darker than nozzle (0.3)

% Create folder if it doesn't exist
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

[xx, yy] = meshgrid(1:imgSize, 1:imgSize);

for i = 1:numImages
    % White background
    img = ones(imgSize, imgSize);
    
    % Nozzle circle
    center = [imgSize/2, imgSize/2];
    nozzleMask = sqrt((xx - center(1)).^2 + (yy - center(2)).^2) <= nozzleRadius;
    img(nozzleMask) = 0.3;  % nozzle gray
    
    % Add smaller contamination blobs
    for b = 1:numBlobs
        while true
            posX = randi([1, imgSize]);
            posY = randi([1, imgSize]);
            if sqrt((posX - center(1))^2 + (posY - center(2))^2) <= nozzleRadius
                break;
            end
        end
        
        blobRadius = randi(blobRadiusRange);
        blobIntensity = blobIntensityRange(1) + rand*(blobIntensityRange(2)-blobIntensityRange(1));
        
        blobMask = sqrt((xx - posX).^2 + (yy - posY).^2) <= blobRadius;
        img(blobMask) = blobIntensity;
    end
    
    % Save image
    filename = fullfile(outputFolder, sprintf('nozzle_%02d.png', i));
    imwrite(img, filename);
    
    % Display first 3 images
    if i <= 3
        figure(1); imshow(img); title(['Synthetic Nozzle ', num2str(i)]);
        drawnow;
    end
end

disp('Synthetic nozzle images generation complete!');
