close all
clear 

addpath (genpath('./fieldtrip-20160515'));
clc
%% define trials and read in raw EEG data
directory = './raw_recording/am_noise/MEG/';
file_name = '2016_03_09_0020_YP_AM_20_trials_run1_analysis_01.con';
    
% create the trial definition
cfg = [];
cfg.dataset = fullfile(directory,file_name);
cfg.trialfun              = 'mytrialfun_MEG';
cfg.trialdef.trigchannel    = '049';
cfg.trialdef.prestim      = 0; % latency in seconds
cfg.trialdef.poststim     = 2.499; % latency in seconds

cfg = ft_definetrial(cfg);

%cfg.channel = {'meggrad', '033'};
epoch_data = ft_preprocessing(cfg);


cfg = [];
cfg.grad = epoch_data.grad;
cfg.channel = (1:20);
layout = ft_prepare_layout(cfg, epoch_data);


cfg = [];
cfg.viewmode = 'vertical';
ft_databrowser(cfg,epoch_data);
%% filter 
cfg = [];
cfg.lpfilter        = 'yes';
cfg.lpfreq          = 30;
cfg.hpfilter        = 'yes';
cfg.hpfreq          = 1.5;

pre_meg_data = ft_preprocessing(cfg,epoch_data);
cfg = [];
cfg.viewmode = 'vertical';
cfg.blocksize = 2.5;
ft_databrowser(cfg,pre_meg_data);

%% read in an external channle for envelope information

load env_4hz.mat;
load env_5hz.mat;
load env_6hz.mat;
load env_7hz.mat;
load env_8hz.mat;

env_4hz_resam = resample(env_4hz,1000,44100);
env_5hz_resam = resample(env_5hz,1000,44100);
env_6hz_resam = resample(env_6hz,1000,44100);
env_7hz_resam = resample(env_7hz,1000,44100);
env_8hz_resam = resample(env_8hz,1000,44100);

envelope.env4hz = env_4hz_resam;
envelope.env5hz = env_5hz_resam;
envelope.env6hz = env_6hz_resam;
envelope.env7hz = env_7hz_resam;
envelope.env8hz = env_8hz_resam;

for i = 1:20
 pre_meg_data.trial{i}(33,:) =  envelope.env4hz/1000000000000;
% pre_eeg_data.trial{i}(33,:) = envelope.env5hz;
% pre_eeg_data.trial{i}(33,:) = envelope.env6hz;
% pre_eeg_data.trial{i}(33,:) = envelope.env7hz;
% pre_eeg_data.trial{i}(33,:) =  envelope.env8hz;

end

cfg = [];
cfg.viewmode = 'vertical';
cfg.blocksize = 2.5;
ft_databrowser(cfg,pre_meg_data);

%% 
data = pre_meg_data;

for i = 1:20
    
 data.trial{i}(15,:) = data.trial{i}(15,:) + data.trial{i}(33,:);

end

figure

subplot(3,1,1)
plot(data.trial{1}(15,:));
grid on
legend(data.label(15));

subplot(3,1,2)
plot(data.trial{1}(16,:));
grid on
legend(data.label(16));

subplot(3,1,3)
plot(data.trial{1}(21,:));
grid on
legend(data.label(21));

cfg = [];
cfg.viewmode = 'vertical';
cfg.blocksize = 2.5;
%cfg.channels = {'meggrad'};
ft_databrowser(cfg,data);

%% frequency analysis
cfg            = [];
cfg.method     = 'mtmfft';
cfg.output     = 'powandcsd';
cfg.foilim     = [0 100];
cfg.taper      = 'hanning';
%cfg.keeptrials = 'yes';
cfg.channel    = {'meggrad','033'};
cfg.channelcmb = {'meggrad', '033'};
freq           = ft_freqanalysis(cfg, data);
%% connectivity analysis
cfg            = [];
cfg.method     = 'coh';
cfg.channelcmb = {'meggrad' '033'};
fd             = ft_connectivityanalysis(cfg, freq);
%% multi plot
cfg                  = [];
cfg.parameter        = 'cohspctrm';
cfg.xlim             = [1 30];
cfg.refchannel       = '033';
cfg.layout           = layout;
cfg.showlabels       = 'yes';
cfg.interactive = 'yes';
cfg.axes = 'yes';
cfg.fontsize = 12;
cfg.channel = (1:20);
figure; 
%ft_singleplotER(cfg, fd);
ft_multiplotER(cfg, fd);
%% topographic plot
% cfg                  = [];
% cfg.parameter        = 'cohspctrm';
% cfg.xlim             = [1 10];
% cfg.zlim             = [0 0.4];
% cfg.refchannel       = 'envelope';
% cfg.layout           = layout;
% figure; 
% ft_topoplotER(cfg, fd)