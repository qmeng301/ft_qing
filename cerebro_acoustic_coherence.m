close all
clear 
clc

addpath ./fieldtrip-20151119;

%% define trials and read in raw data
directory = './raw_recording/am_noise';
file_name = '0004_XL_AM_sine_01.bdf';
    
% create the trial definition
cfg = [];
cfg.dataset = fullfile(directory,file_name);
cfg.trialfun              = 'ft_trialfun_general';
cfg.trialdef.eventtype    = 'STATUS';
cfg.trialdef.eventvalue   = [144 145 146 147 148]; % stimulus triggers
cfg.trialdef.prestim      = 0.2; % latency in seconds
cfg.trialdef.poststim     = 2.6; % latency in seconds
%    
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
%cfg = [];
%cfg.viewmode = 'vertical';
%ft_databrowser(cfg,pre_data);

%%
load env_4-8hz.mat;






%% load layout and modify label
cfg = []; 
cfg.layout   = 'biosemi64.lay';
%ft_layoutplot(cfg);
layout = ft_prepare_layout(cfg);
pre_data.label = layout.label(1:64,1);

%% frequency and connectivity analysis

