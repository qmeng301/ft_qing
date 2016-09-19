clear
close all
clc

addpath ./fieldtrip-20151119;
ft_defaults
%% define trials and read in raw data
%directory = './raw_recording/AEF_withCI/0015';
directory = './raw_recording/AEF_withCI/0037';
file_name = '2016_02_26_0037_MH_AEF_with_EB_with_SP_run1_analysis_01.con';

% read in continuous data
cfg = [];
cfg.dataset = fullfile(directory,file_name);
cfg.channel = (1:20);
cfg.continuous  = 'yes';
raw_data = ft_preprocessing(cfg);

% create the trial definition
cfg.trialfun              = 'mytrialfun_MEG';
cfg.trialdef.trigchannel    = '049';
cfg.trialdef.prestim      = 0.1; % latency in seconds
cfg.trialdef.poststim     = 0.5; % latency in seconds
cfg = ft_definetrial(cfg);
trl = cfg.trl;

% cfg = [];
% cfg.viewmode = 'butterfly';
% cfg.blocksize = 10;
% ft_databrowser(cfg,raw_data);

%% lowpass filtering
cfg = [];
cfg.lpfilter        = 'yes';
cfg.lpfreq          = 30;
pre_data = ft_preprocessing(cfg,raw_data);

% cfg = [];
% cfg.viewmode = 'butterfly';
% ft_databrowser(cfg,pre_data);
%% define trials
cfg = [];
cfg.trl  = trl;
epoch_data = ft_redefinetrial (cfg, pre_data);

% cfg = [];
% cfg.viewmode = 'butterfly';
% ft_databrowser(cfg,epoch_data);

% %% ICA
% % perform the independent component analysis (i.e., decompose the data)
% cfg        = [];
% cfg.method = 'runica'; % this is the default and uses the implementation from EEGLAB
% comp = ft_componentanalysis(cfg, epoch_data);
% cfg.viewmode = 'component';
% ft_databrowser(cfg, comp);
% 
% %%
% % remove the bad components and backproject the data
% cfg = [];
% cfg.component = [1 2 13 14]; % to be removed component(s)
% epoch_data = ft_rejectcomponent(cfg, comp, epoch_data);


%% timelocked analysis
cfg = [];
ave_data = ft_timelockanalysis(cfg, epoch_data);


cfg = [];
cfg.viewmode = 'butterfly';
%cfg.ylim = [-1.5e-13 1.5e-13];
cfg.ylim = [-5e-13 5e-13];
cfg.preproc.baselinewindow  = [-0.1 0];
ft_databrowser(cfg,ave_data);
grid on

% cfg = [];
% cfg.layout = 'butterfly';
% %cfg.axes = 'yes';
% cfg.baseline      = [-0.1, 0];
% %cfg.fontsize = 12;
% figure
% ft_multiplotER(cfg, ave_data);
