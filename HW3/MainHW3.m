%% Homework #3 - Signal Tracking (Baseband Model)
clear;
clc;
close all;
%% Directory
sHW3Root = fileparts(mfilename('fullpath'));
addpath(fullfile(sHW3Root, 'SourceCode'));
addpath(genpath(fullfile(sHW3Root, 'SourceCode', 'function')));
sConfig = fctConfigHW3(sHW3Root);
%% Task1 & Task2
run(fullfile(sHW3Root, 'SourceCode', 'MainTask1.m'));
run(fullfile(sHW3Root, 'SourceCode', 'MainTask2.m'));
