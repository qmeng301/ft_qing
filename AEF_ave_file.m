clear
close all
clc

addpath ./fieldtrip-20151119; 
ft_defaults

% read in continuous raw data and define trials
directory = './raw_recording/AEF/0015/';
%file_name = '2016_02_26_0015_MN_AEF_run1_n100_analysis_01.ave';
file_name = '2016_02_26_0015_MN_AEF_run1_p2_n100_analysis_01.ave';

% read in averaged data
cfg = [];
cfg.dataset = fullfile(directory,file_name);
cfg.channel = (1:20);
cfg.continuous  = 'yes';
raw_data = ft_preprocessing(cfg);

% plot AEF
cfg = [];
cfg.viewmode = 'butterfly';
cfg.blocksize = 0.5;
cfg.ylim = [-1.5e-13 1.5e-13];
ft_databrowser(cfg,raw_data);
grid on
