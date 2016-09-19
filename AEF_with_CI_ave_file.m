clear
close all
clc

addpath ./fieldtrip-20151119; 
ft_defaults

% read in continuous raw data and define trials
directory = './raw_recording/AEF_withCI/0015/';
%file_name = '2016_02_26_0015_MN_AEF_with_EB_run2_n100_analysis_01.ave';
file_name = '2016_02_26_0015_MN_AEF_with_EB_with_SP_run1_n100_analysis_01.ave';
%file_name = '2016_02_26_0015_MN_AEF_with_CI_run1_n100_analysis_01.ave';

% directory = './raw_recording/AEF_withCI/0037/';
% file_name = '2016_02_26_0037_MH_AEF_with_EB_with_SP_run2_n100_analysis_01.ave';

% read in averaged data
cfg = [];
cfg.dataset = fullfile(directory,file_name);
cfg.channel = (1:20);
cfg.continuous  = 'yes';
epoch_data = ft_preprocessing(cfg);

% plot AEF before ICA
cfg = [];
cfg.viewmode = 'butterfly';
cfg.blocksize = 0.5;
cfg.ylim = [-1.5e-13 1.5e-13];
ft_databrowser(cfg,epoch_data);
grid on

%% ICA
% perform the independent component analysis (i.e., decompose the data)
cfg        = [];
cfg.method = 'runica'; % this is the default and uses the implementation from EEGLAB
comp = ft_componentanalysis(cfg, epoch_data);
cfg.viewmode = 'component';
ft_databrowser(cfg, comp);

%%
% remove the bad components and backproject the data
cfg = [];
cfg.component = [1 3 4 15 16]; % to be removed component(s)
epoch_data = ft_rejectcomponent(cfg, comp, epoch_data);


% % plot AEF after ICA
cfg = [];
cfg.viewmode = 'butterfly';
cfg.blocksize = 0.5;
cfg.ylim = [-1.5e-13 1.5e-13];
ft_databrowser(cfg,epoch_data);
grid on