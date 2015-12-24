close all
clear 
clc

addpath ./fieldtrip-20151119;
%% define trials and read in raw EEG data
directory = './raw_recording/am_noise';
file_name = '0004_XL_AM_sine_01.bdf';
    
% create the trial definition
cfg = [];
cfg.dataset = fullfile(directory,file_name);
cfg.trialfun              = 'ft_trialfun_general';
cfg.trialdef.eventtype    = 'STATUS';
%cfg.trialdef.eventvalue   = [144 145 146 147 148]; % stimulus triggers
%cfg.trialdef.eventvalue   = 144;
cfg.trialdef.eventvalue   = 145;
%cfg.trialdef.eventvalue   = 146;
%cfg.trialdef.eventvalue   = 147;
%cfg.trialdef.eventvalue   = 148;

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

%% filter and rereference EEG data
cfg = [];
cfg.lpfilter        = 'yes';
cfg.lpfreq          = 30;
cfg.hpfilter        = 'yes';
cfg.hpfreq          = 1.5;

cfg.reref         = 'yes';
cfg.refchannel    = (1:64);

cfg.channel    = (1:64);

pre_eeg_data = ft_preprocessing(cfg,epoch_data);
%data_type = ft_senstype(pre_data);
cfg = [];
cfg.viewmode = 'vertical';
ft_databrowser(cfg,pre_eeg_data);

%% read in an external channle for envelope information
cfg              = [];
cfg.dataset      = fullfile(directory,file_name);
cfg.trl          = epoch_data.cfg.trl;
cfg.channel      = 'EXG8';
exg8 = ft_preprocessing(cfg);
%load env_4hz.mat
load env_5hz.mat
%load env_6hz.mat
%load env_7hz.mat
%load env_8hz.mat

%tmp_envelope = env_4hz_resam(1:end-1);
tmp_envelope = env_5hz_resam(1:end-1);
%tmp_envelope = env_6hz_resam(1:end-1);
%tmp_envelope = env_7hz_resam(1:end-1);
%tmp_envelope = env_8hz_resam(1:end-1);

%exg8.trial = mat2cell(tmp_envelope',1,5734);

exg8.trial = {tmp_envelope'};

cfg = [];
cfg.viewmode = 'vertical';
ft_databrowser(cfg,exg8);

%%
cfg = [];
cfg.lpfilter        = 'yes';
cfg.lpfreq          = 100;
cfg.hpfilter        = 'yes';
cfg.hpfreq          = 1.5;
cfg.reref         = 'no';
pre_envelope_data = ft_preprocessing(cfg,exg8);
cfg = [];
cfg.viewmode = 'vertical';
ft_databrowser(cfg,pre_envelope_data);

%% 
data = ft_appenddata([], pre_eeg_data, pre_envelope_data);

%data = ft_appenddata([], epoch_data, exg8);

figure
subplot(2,1,1);
plot(data.time{1},data.trial{1}(14,:));
axis tight;
legend(data.label(20));

subplot(2,1,2);
plot(data.time{1},data.trial{1}(65,:));
axis tight;
legend(data.label(65));

%% load layout and modify label
cfg = []; 
cfg.layout   = 'biosemi64.lay';
%ft_layoutplot(cfg);
layout = ft_prepare_layout(cfg);
data.label(1:64)= layout.label(1:64,1);
%data.label(1:64)= {'EEG'};
data.label{65} = 'evnelope';
%% frequency and connectivity analysis
% cfg            = [];
% cfg.output     = 'fourier';
% cfg.method     = 'mtmfft';
% cfg.foilim     = [2 100];
% cfg.tapsmofrq  = 5;
% cfg.keeptrials = 'yes';
% cfg.channel    = (1:64);
% freqfourier    = ft_freqanalysis(cfg, pre_data);



cfg            = [];
cfg.output     = 'powandcsd';
cfg.method     = 'mtmfft';
cfg.foilim     = [2 100];
cfg.tapsmofrq  = 5;
cfg.keeptrials = 'yes';
cfg.channel    = (1:65);
%cfg.channelcmb = {'EEG' 'envelope'};
freq           = ft_freqanalysis(cfg, data);

%% 
cfg            = [];
cfg.method     = 'coh';
%cfg.channelcmb = {[1:64] 65};
fd             = ft_connectivityanalysis(cfg, freq);
%fdfourier      = ft_connectivityanalysis(cfg, freqfourier);
%%

cfg                  = [];
cfg.parameter        = 'cohspctrm';
cfg.xlim             = [1 20];
cfg.refchannel       = 65;
cfg.layout           = layout;
cfg.showlabels       = 'yes';
figure; ft_multiplotER(cfg, fd)