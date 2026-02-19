%% src/classify_nozzles.m
clc; clear;

% Load features
features = readtable('../results/features_summary.csv');

health = strings(height(features),1);

for i = 1:height(features)
    area = features.ContaminationArea(i) * 100; % %
    symmetry = features.RadialSymmetry(i);
    variance = features.IntensityVariance(i);

    % Check severe first
    if area > 15 || symmetry < 0.7 || variance > 0.05
        health(i) = "Severe";
    % Then mild
    elseif area > 5 || symmetry < 0.85 || variance > 0.02
        health(i) = "Mild";
    % Else clean
    else
        health(i) = "Clean";
    end
end

features.NozzleHealth = health;

% Save updated table
writetable(features, '../results/features_classified.csv');
disp('Nozzle classification complete with area, symmetry, and variance!');
