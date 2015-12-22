clear
close all
clc

addpath ./fieldtrip-20151119;
%% define trials and read in raw data
directory = './raw_recording/ERP';
file_name = '0004_XL_AEP_02.bdf';
    
% create the trial definition
cfg = [];
cfg.dataset = fullfile(directory,file_name);
cfg.trialfun              = 'ft_trialfun_general';
cfg.trialdef.eventtype    = 'STATUS';
cfg.trialdef.eventvalue   = 144; % stimulus triggers
cfg.trialdef.prestim      = 0.1; % latency in seconds
cfg.trialdef.poststim     = 0.5; % latency in seconds
    
cfg = ft_definetrial(cfg);
trl = cfg.trl;
%ft_databrowser(cfg);
cfg=[];
cfg.dataset = fullfile(directory,file_name);
cfg.trl = trl;
epoch_data = ft_preprocessing(cfg);
%% filtering and rereference
cfg = [];
cfg.lpfilter        = 'yes';
cfg.lpfreq          = 30;
cfg.hpfilter        = 'yes';
cfg.hpfreq          = 1.5;

cfg.reref         = 'yes';
cfg.refchannel    = (1:64);

cfg.channel    = (1:64);

pre_data = ft_preprocessing(cfg,epoch_data);
%data_type = ft_senstype(pre_data)
cfg = [];
cfg.viewmode = 'vertical';
ft_databrowser(cfg,pre_data);


%%
% artifact rejection 
%cfg        = [];
%cfg.method = 'channel';
%ft_rejectvisual(cfg, data)

% artifact rejection
%cfg = [];
%cfg.method   = 'summary';
%cfg.layout   = lay;       % this allows for plotting
%cfg.channel  = (1:64);    % do not show EOG channels
%data_clean   = ft_rejectvisual(cfg, data);


%% load layout and modify label
cfg = []; 
cfg.layout   = 'biosemi64.lay';
%ft_layoutplot(cfg);
layout = ft_prepare_layout(cfg);
pre_data.label = layout.label(1:64,1);
%% timelocked analysis and 
cfg = [];
cfg.trials = find(pre_data.trialinfo==144);
ave_data = ft_timelockanalysis(cfg, pre_data);
%ft_singleplotER([],task);

cfg = [];
cfg.layout = layout;
%cfg.layout.label = layout.label(1:64,1);

cfg.interactive = 'yes';
cfg.axes = 'yes';
cfg.showlabels = 'yes';
cfg.fontsize = 12;
%ft_topoplotER(cfg,ave_data);
%cfg.vlim = [-5, 5];
ft_multiplotER(cfg, ave_data);
