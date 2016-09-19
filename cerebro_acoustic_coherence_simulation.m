close all
clear 
clc

addpath ./fieldtrip-20160515;
ft_defaults
%% define trials and read in raw EEG data
directory                   = './raw_recording/am_noise/EEG';
file_name                   = '0002_XL_AM_6Hz_test02.bdf';

% create the trial definition
cfg                         = [];
cfg.dataset                 = fullfile(directory,file_name);
cfg.trialfun                = 'ft_trialfun_general';
cfg.trialdef.eventtype      = 'STATUS';
cfg.trialdef.eventvalue     = 18;
cfg.trialdef.prestim        = 0; % latency in seconds
cfg.trialdef.poststim       = 2.5; % latency in seconds
cfg                         = ft_definetrial(cfg);

cfg.continuous              = 'yes';
cfg.demean                  = 'yes';
cfg.channel                 = 'all';
data_all_epoch              = ft_preprocessing(cfg);

cfg                         = [];
cfg.viewmode                = 'vertical';
ft_databrowser(cfg,data_all_epoch);
%%
% cfg                         = [];
% cfg.channel                 = 'EEG';
% cfg.metric                  = 'zvalue';
% data_eeg_visual              = ft_rejectvisual(cfg,data_all_epoch);

data_eeg_visual = data_all_epoch;

%% filter and rereference EEG data
cfg = [];
cfg.lpfilter                = 'yes';
cfg.lpfreq                  = 30;
cfg.reref                   = 'yes';
cfg.channel                 = 'EEG';
cfg.refchannel              = 'all';
data_eeg_filt               = ft_preprocessing(cfg,data_eeg_visual);
cfg                         = [];
cfg.viewmode                = 'vertical';

ft_databrowser(cfg,data_eeg_filt);
save data_eeg_filt.mat data_eeg_filt
%%
% perform the independent component analysis (i.e., decompose the data)
%  cfg                      = [];
%  cfg.channel              = 'eeg';
%  cfg.method               = 'runica'; % this is the default and uses the implementation from EEGLAB
%  data_eeg_comp            = ft_componentanalysis(cfg, data_eeg_filt);
%%
% plot the components for visual inspection
%  figure
%  cfg                      = [];
%  cfg.component            = (1:20);       % specify the component(s) that should be plotted
%  cfg.layout               = layout;
%  cfg.comment              = 'no';
%  ft_topoplotIC(cfg, data_eeg_comp)
%%
% cfg.viewmode              = 'component';
% cfg.layout                = layout;
% ft_databrowser(cfg, data_eeg_comp);
% 
% %remove the bad components and backproject the data
% cfg                       = [];
% cfg.component             = 1; % to be removed component(s)
% data_eeg_prep             = ft_rejectcomponent(cfg, data_eeg_comp, data_eeg_filt);
data_eeg_prep = data_eeg_filt;
save data_eeg_prep.mat data_eeg_prep
%% read in an external channle for envelope information

cfg              = [];
cfg.dataset      = data_all_epoch.cfg.dataset;
cfg.trl          = data_all_epoch.cfg.trl;
cfg.channel      = {'EXG8'};
data_envelope    = ft_preprocessing(cfg);

data_eeg_env = ft_appenddata([], data_eeg_prep, data_envelope);

load env_6hz_resam.mat;
% env_6hz_resam                  = resample(env_6hz,2048,44100);
% save env_6hz_resam.mat env_6hz_resam

for i = 1:200 % number of trials
  data_eeg_env.trial{i}(65,:) = 50 * env_6hz_resam;
end

cfg                         = [];
cfg.layout                  = 'biosemi64.lay'; % specify the layout file that should be used for plotting
layout                      = ft_prepare_layout(cfg);
data_eeg_env.label(1:64)    = layout.label(1:64,1);
data_eeg_env.label{65}      = 'envelope';

save data_eeg_env.mat data_eeg_env

cfg = [];
cfg.viewmode = 'vertical';
cfg.blocksize = 2.5;
ft_databrowser(cfg,data_eeg_env);

%% frequency analysis
cfg                     = [];
cfg.method              = 'mtmfft';
cfg.output              = 'powandcsd';
cfg.foilim              = [0 20];
cfg.taper               = 'hanning';
cfg.channel             = {'eeg' 'envelope'};
cfg.channelcmb          = {'eeg' 'envelope'};
data_eeg_powcsd         = ft_freqanalysis(cfg, data_eeg_env);

save data_eeg_powcsd.mat data_eeg_powcsd
%% connectivity analysis
cfg                     = [];
cfg.method              = 'coh';
cfg.channel             = {'eeg' 'envelope'};
cfg.channelcmb          = {'eeg' 'envelope'};
data_eeg_coh            = ft_connectivityanalysis(cfg, data_eeg_powcsd);

save data_eeg_coh.mat data_eeg_coh
%% multi plot
cfg                     = [];
cfg.parameter           = 'cohspctrm';
cfg.xlim                = [1 20];
cfg.ylim                = [0 0.5];
cfg.refchannel          = 'envelope';
cfg.layout              = layout;
cfg.showlabels          = 'yes';
cfg.axes                = 'yes';
cfg.fontsize            = 12;
cfg.comment             = 'no';
figure; 
ft_multiplotER(cfg, data_eeg_coh);
%% single plot
load sig_coh_val_f_no_env.mat

cfg                  = [];
cfg.parameter        = 'cohspctrm';
cfg.xlim             = [1 20];
cfg.ylim             = [0 0.5];
cfg.channel          = {'T7'};
cfg.refchannel       = 'envelope';
cfg.layout           = layout;
cfg.showlabels       = 'yes';
cfg.interactive      = 'yes';
cfg.axes             = 'yes';
cfg.fontsize         = 12;
figure; 
ft_singleplotER(cfg, data_eeg_coh);

hold on
plot(sig_coh_val_f(1,:),'--r')
plot(sig_coh_val_f(2,:),'-.g')
xlabel ('Frequency (Hz)')

legend ('coherence','p < 0.05', 'p < 0.005')
%% topographic plot

data_eeg_coh_corrected = data_eeg_coh;

for i_channel = 1: 64
    
    data_eeg_coh_corrected.cohspctrm(i_channel,:) = data_eeg_coh_corrected.cohspctrm (i_channel,:) - sig_coh_val_f(1,:);
end

cfg                     = [];
cfg.layout              = layout;
cfg.parameter           = 'cohspctrm';
cfg.refchannel          = 'envelope';
cfg.xlim                = [0 2.5];
cfg.ylim                = [1 20];
cfg.zlim                = 'maxmin';
cfg.comment             = 'no';
cfg.marker              = 'off';
cfg.colorbar            = 'SouthOutside';
cfg.style               = 'straight';
figure; 
ft_topoplotER(cfg, data_eeg_coh)

figure; 
ft_topoplotER(cfg, data_eeg_coh_corrected)
