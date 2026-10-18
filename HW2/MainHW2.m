%% Capstone Design of Autonomous Navigation System [202602-ECE7067-001]
%% Homework #2 - Signal Tracking
%% 2026.11.08
%% Ji Won Lee, @Inha Univ. (M.S.)
%% Directory
clear; clc; close all;
sHW2Root = fileparts(mfilename('fullpath'));
addpath(fullfile(sHW2Root, 'SourceCode'));
addpath(genpath(fullfile(sHW2Root, 'SourceCode', 'function')));
%% Task-1
run(fullfile(sHW2Root, 'SourceCode', 'MainTask1.m'));
%% Task-2
run(fullfile(sHW2Root, 'SourceCode', 'MainTask2.m'));
%% Task-3
% Data/Task3.json
%% Task-4
run(fullfile(sHW2Root, 'SourceCode', 'MainTask4.m'));