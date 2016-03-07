close all
clear 
clc

addpath ./fieldtrip-20151119;
%% define trials and read in raw EEG data
directory = './raw_recording/am_noise';
file_name = '0005_XL_AM_sine_repeated_01.bdf';

% create the trial definition
cfg = [];
cfg.dataset = fullfile(directory,file_name);
cfg.trialfun              = 'ft_trialfun_general';
cfg.trialdef.eventtype    = 'STATUS';
%cfg.trialdef.eventvalue   = [144 145 146 147 148]; % stimulus triggers
cfg.trialdef.eventvalue   = 144;
%cfg.trialdef.eventvalue   = 145;
%cfg.trialdef.eventvalue   = 146;
%cfg.trialdef.eventvalue   = 147;
%cfg.trialdef.eventvalue   = 148;

cfg.trialdef.prestim      = 0; % latency in seconds
cfg.trialdef.poststim     = 2.5; % latency in seconds
cfg = ft_definetrial(cfg);
cfg.channel    = 'all';
epoch_data = ft_preprocessing(cfg);

%% downsampling raw data
% cfg = [];
% cfg.resamplefs = 512;
% cfg.detrend = 'no';
% down_data = ft_resampledata(cfg, epoch_data);



%% filter and rereference EEG data
cfg = [];
cfg.lpfilter        = 'yes';
cfg.lpfreq          = 30;
cfg.hpfilter        = 'yes';
cfg.hpfreq          = 1.5;
cfg.reref         = 'yes';
%cfg.refchannel    = {'EXG1','EXG2'};
cfg.refchannel    = {'EEG'};
cfg.channel    = 'all';
pre_eeg_data = ft_preprocessing(cfg,epoch_data);
%data_type = ft_senstype(pre_data);
cfg = [];
cfg.viewmode = 'vertical';
cfg.blocksize = 2.5;
ft_databrowser(cfg,pre_eeg_data);
%%
% perform the independent component analysis (i.e., decompose the data)
cfg        = [];
cfg.method = 'runica'; % this is the default and uses the implementation from EEGLAB

comp = ft_componentanalysis(cfg, pre_eeg_data);
%%
% plot the components for visual inspection
figure
cfg = [];
cfg.component = (1:20);       % specify the component(s) that should be plotted
cfg.layout   = 'biosemi64.lay'; % specify the layout file that should be used for plotting

layout = ft_prepare_layout(cfg);
pre_eeg_data.label(1:64)= layout.label(1:64,1);
cfg.comment   = 'no';
ft_topoplotIC(cfg, comp)
%%
cfg.viewmode = 'component';
ft_databrowser(cfg, comp);

% remove the bad components and backproject the data
% cfg = [];
% cfg.component = [9 10 14 24]; % to be removed component(s)
% data = ft_rejectcomponent(cfg, comp, data)

%% read in an external channle for envelope information

load env_4hz.mat;
load env_5hz.mat;
load env_6hz.mat;
load env_7hz.mat;
load env_8hz.mat;


% env_4hz_resam = resample(env_4hz,512,44100);
% env_5hz_resam = resample(env_5hz,512,44100);
% env_6hz_resam = resample(env_6hz,512,44100);
% env_7hz_resam = resample(env_7hz,512,44100);
% env_8hz_resam = resample(env_8hz,512,44100);

env_4hz_resam = resample(env_4hz,2048,44100);
env_5hz_resam = resample(env_5hz,2048,44100);
env_6hz_resam = resample(env_6hz,2048,44100);
env_7hz_resam = resample(env_7hz,2048,44100);
env_8hz_resam = resample(env_8hz,2048,44100);

envelope.env4hz = env_4hz_resam;
envelope.env5hz = env_5hz_resam;
envelope.env6hz = env_6hz_resam;
envelope.env7hz = env_7hz_resam;
envelope.env8hz = env_8hz_resam;

for i = 1:20
 pre_eeg_data.trial{i}(72,:) = 50 * envelope.env4hz;
% pre_eeg_data.trial{i}(72,:) = 50 * envelope.env5hz;
% pre_eeg_data.trial{i}(72,:) = 50 * envelope.env6hz;
% pre_eeg_data.trial{i}(72,:) = 50 * envelope.env7hz;
% pre_eeg_data.trial{i}(72,:) =  50 * envelope.env8hz;

end

cfg = [];
cfg.viewmode = 'vertical';
cfg.blocksize = 2.5;
cfg.ylim = [-0.05 0.25];
%ft_databrowser(cfg,exg8);
ft_databrowser(cfg,pre_eeg_data);

%% 
data = pre_eeg_data;

for i = 1:20
    
 data.trial{i}(15,:) = data.trial{i}(15,:) + data.trial{i}(72,:);

end

% figure
%     
% subplot(3,1,1);
% plot(data.time{1},data.trial{1}(15,:));
% axis tight;
% legend(data.label(15));
% xlabel('time (s)')
% grid
% 
% subplot(3,1,2);
% plot(data.time{1},data.trial{1}(52,:));
% axis tight;
% legend(data.label(52));
% xlabel('time (s)')
% grid
% 
% subplot(3,1,3);
% plot(data.time{1},data.trial{1}(72,:));
% axis tight;
% legend(data.label(72));
% xlabel('time (s)')
% grid

%% load layout and modify label
cfg = []; 
cfg.layout   = 'biosemi64.lay';
%ft_layoutplot(cfg);
layout = ft_prepare_layout(cfg);
data.label(1:64)= layout.label(1:64,1);
data.label{72} = 'envelope';
%% frequency analysis
cfg            = [];
cfg.method     = 'mtmfft';
cfg.output     = 'powandcsd';
cfg.foilim     = [0 200];
cfg.taper      = 'hanning';
cfg.keeptrials = 'yes';
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
figure; 
ft_multiplotER(cfg, fd);
%% topographic plot
cfg                  = [];
cfg.parameter        = 'cohspctrm';
cfg.xlim             = [1 10];
cfg.zlim             = [0 0.3];
cfg.refchannel       = 'envelope';
cfg.layout           = layout;
figure; 
ft_topoplotER(cfg, fd)