clear
close all
clc

addpath ./fieldtrip-20160515
ft_defaults
directory                   = './raw_recording/ERP';
file_name                   = '0004_XL_AEP_02.bdf';
%% define trials and read in raw data

% create the trial definition
cfg                         = [];
cfg.dataset                 = fullfile(directory,file_name);
cfg.trialfun                = 'ft_trialfun_general';
cfg.trialdef.eventtype      = 'STATUS';
cfg.trialdef.eventvalue     = 144; % stimulus triggers
cfg.trialdef.prestim        = 0.1; % latency in seconds
cfg.trialdef.poststim       = 0.5; % latency in seconds    
cfg                         = ft_definetrial(cfg);

% reference
cfg.continuous              = 'yes';
cfg.demean                  = 'yes';
cfg.dftfilter               = 'yes';
cfg.dftfreq                 = [50 100];
cfg.channel                 = 'EEG';
cfg.reref                   = 'yes'; 
cfg.refchannel              = 'all';
data_EEG                    = ft_preprocessing(cfg);

cfg                         = [];
cfg.viewmode                = 'vertical';
ft_databrowser(cfg,data_EEG);
%% load layout and modify label
cfg = []; 
cfg.layout   = 'biosemi64.lay';
layout = ft_prepare_layout(cfg);
data_EEG.label = layout.label(1:64,1);

%% artifact rejection
cfg                         = [];
cfg.metric                  = 'zvalue';
data_EEG_clean              = ft_rejectvisual(cfg,data_EEG);
% cfg                         = [];
% cfg.viewmode                = 'vertical';
% ft_databrowser(cfg,data_EEG_clean);
%%
cfg                         = [];
cfg.lpfilter                = 'yes';
cfg.lpfreq                  = 30;
cfg.demean                  = 'yes';
cfg.baselinewindow          = [-0.1 0];
data_EEG_filt               = ft_preprocessing(cfg,data_EEG_clean);

cfg = [];
cfg.viewmode = 'vertical';
ft_databrowser(cfg,data_EEG_filt);

%% define pre and post period

% cfg = [];            
% cfg.toilim = [-0.3 0];
% data_pre = ft_redefinetrial(cfg, pre_data);
% 
% cfg.toilim = [0 0.3];
% data_post = ft_redefinetrial(cfg, pre_data);          
%% output cov matrix of the entire interval
cfg                     = [];
% cfg.covariance          ='yes';
% cfg.covariancewindow    = [-3 0.3];
% cfg.vartrllength = 2;
data_ERP                = ft_timelockanalysis(cfg,data_EEG_filt);
% cfg = [];
% cfg.covariance='yes';
% avg_pre = ft_timelockanalysis(cfg,data_pre);
% avg_pst = ft_timelockanalysis(cfg,data_post);
% %% timelocked analysis
% cfg = [];
% %cfg.trials = find(pre_data.trialinfo==144);
% cfg.trials = 'all';
% AEP_ave_data = ft_timelockanalysis(cfg, pre_data);


%% plot result

% multiplot
cfg                     = [];
cfg.layout              = layout;
cfg.fontsize            = 12;
cfg.axes                = 'yes';
cfg.showlabels          = 'yes';
%cfg.ylim                = [-3e-6 3e-6]; 
cfg.xlim                = [-0.1 0.5];
figure()
ft_multiplotER(cfg, data_ERP); 
axis tight

% Topoplot
cfg                 = [];
cfg.layout          = layout;
cfg.xlim            = [-0.1 0.5];
%cfg.zlim            = [-3e-6 3e-6];
cfg.style           = 'both';
cfg.comment         = 'no';  % date 
figure()
ft_topoplotER(cfg, data_ERP);
axis tight

% save AEP_avg_data.mat avg
% save AEP_avg_data_pre.mat avg_pre
% save AEP_avg_data_post.mat avg_pst
