close all
clear 

addpath (genpath('./fieldtrip-20160515'));
clc
%% define trials and read in raw EEG data
directory = './raw_recording/am_noise/EEG';
file_name = '0005_XL_AM_sine_repeated_02.bdf';

% create the trial definition
cfg = [];
cfg.dataset = fullfile(directory,file_name);
cfg.trialfun              = 'ft_trialfun_general';
cfg.trialdef.eventtype    = 'STATUS';
%cfg.trialdef.eventvalue   = [144 145 146 147 148]; % stimulus triggers
%cfg.trialdef.eventvalue   = 144;
%cfg.trialdef.eventvalue   = 145;
cfg.trialdef.eventvalue   = 146;
%cfg.trialdef.eventvalue   = 147;
%cfg.trialdef.eventvalue   = 148;

cfg.trialdef.prestim      = 0; % latency in seconds
cfg.trialdef.poststim     = 2.5; % latency in seconds

cfg = ft_definetrial(cfg);
cfg.channel    = 'all';
[epoch_data] = ft_preprocessing(cfg);
%%
cfg = [];
cfg.layout   = 'biosemi64.lay'; % specify the layout file that should be used for plotting
layout = ft_prepare_layout(cfg);
epoch_data.label(1:64)= layout.label(1:64,1);
epoch_data.label{72} = 'envelope';
%% filter and rereference EEG data
cfg = [];
cfg.lpfilter        = 'yes';
cfg.lpfreq          = 30;
cfg.hpfilter        = 'yes';
cfg.hpfreq          = 1.5;

cfg.reref         = 'yes';
cfg.refchannel    = {'EXG1','EXG2'};
cfg.channel    = 'all';
cfg.trials  = randi(20,1); % choose a random trial
cfg.trials
pre_eeg_data = ft_preprocessing(cfg,epoch_data);
cfg = [];
cfg.viewmode = 'vertical';
cfg.blocksize = 2.5;
ft_databrowser(cfg,pre_eeg_data);
%% read in an external channle for envelope information

%load env_4hz.mat;
%load env_5hz.mat;
load env_6hz.mat;
%load env_7hz.mat;
%load env_8hz.mat;
%figure 
%plot(env_6hz);

%env_4hz_resam = resample(env_4hz,2048,44100);
%env_5hz_resam = resample(env_5hz,2048,44100);
env_6hz_resam = resample(env_6hz,2048,44100);
%env_7hz_resam = resample(env_7hz,2048,44100);
%env_8hz_resam = resample(env_8hz,2048,44100);

%envelope.env4hz = env_4hz_resam;
%envelope.env5hz = env_5hz_resam;
envelope.env6hz = env_6hz_resam;
%envelope.env7hz = env_7hz_resam;
%envelope.env8hz = env_8hz_resam;


% pre_eeg_data.trial{1}(72,:) = 50 * envelope.env4hz;
% pre_eeg_data.trial{1}(72,:) = 50 * envelope.env5hz;
 pre_eeg_data.trial{1}(72,:) = 50 * envelope.env6hz;
% pre_eeg_data.trial{1}(72,:) = 50 * envelope.env7hz;
% pre_eeg_data.trial{1}(72,:) = 50 * envelope.env8hz;

cfg = [];
cfg.viewmode = 'vertical';
cfg.blocksize = 2.5;
ft_databrowser(cfg,pre_eeg_data);

%% 
data = pre_eeg_data;

%data.trial{1}(15,:) = data.trial{1}(15,:) + data.trial{1}(72,:);
cfg.length = 0.5;   % to be determined
cfg.overlap = 0.75; % to be determined
data = ft_redefinetrial(cfg, data); % creat sudo trials by creating segments in the original trial

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
plot(data.trial{1}(72,:));
grid on
legend(data.label(72));

%% frequency analysis
cfg            = [];
cfg.method = 'mtmfft';
cfg.output     = 'powandcsd';
cfg.taper      = 'hanning';
cfg.foilim     = [0 200];
cfg.channel    = {'eeg' 'envelope'};
cfg.channelcmb = {'eeg' 'envelope'};
freq           = ft_freqanalysis(cfg, data);

%% connectivity analysis
cfg            = [];
cfg.method     = 'coh';
cfg.channelcmb = {'eeg' 'envelope'};
fd             = ft_connectivityanalysis(cfg, freq);
%% multi plot
cfg                  = [];
cfg.parameter        = 'cohspctrm';
cfg.xlim             = [1 30];
cfg.refchannel       = 'envelope';
cfg.layout           = layout;
cfg.showlabels       = 'yes';
cfg.interactive = 'yes';
cfg.axes = 'yes';
cfg.fontsize = 12;
figure
ft_multiplotER(cfg, fd);

%% topographic plot
cfg                  = [];
cfg.parameter        = 'cohspctrm';
cfg.xlim             = [1 30];
cfg.zlim             = [0 0.5];
cfg.refchannel       = 'envelope';
cfg.layout           = layout;
figure; 
ft_topoplotER(cfg, fd)
