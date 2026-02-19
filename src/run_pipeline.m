%% run_pipeline.m
clc; clear; close all;

disp('Starting full nozzle analysis pipeline...');

% Step 1: Generate synthetic data
disp('Step 1: Generating synthetic nozzle images...');
generate_data;

% Step 2: Extract features
disp('Step 2: Extracting features...');
extract_features;

% Step 3: Classify nozzles
disp('Step 3: Classifying nozzles...');
classify_nozzle;

disp('Pipeline complete! Check ../results for CSV and visualizations.');
