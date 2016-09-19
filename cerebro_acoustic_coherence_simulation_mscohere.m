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
cfg.trialdef.eventvalue   = 144;
%cfg.trialdef.eventvalue   = 145;
%cfg.trialdef.eventvalue   = 146;
%cfg.trialdef.eventvalue   = 147;
%cfg.trialdef.eventvalue   = 148;

cfg.trialdef.prestim      = 0; % latency in seconds
cfg.trialdef.poststim     = 2.5; % latency in seconds

cfg = ft_definetrial(cfg);
trl = cfg.trl;
%ft_databrowser(cfg);
cfg=[];
cfg.dataset = fullfile(directory,file_name);
cfg.trl = trl;
cfg.channel    = 'all';
epoch_data = ft_preprocessing(cfg);
%%
cfg = []; 
cfg.layout   = 'biosemi64.lay';
%ft_layoutplot(cfg);
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
cfg.trials  = 1;
pre_eeg_data = ft_preprocessing(cfg,epoch_data);
cfg = [];
cfg.viewmode = 'vertical';
cfg.blocksize = 2.5;
ft_databrowser(cfg,pre_eeg_data);

%% read in an external channle for envelope information

%load env_4hz.mat;
%load env_5hz.mat;
%load env_6hz.mat;
%load env_7hz.mat;
load env_8hz.mat;

%env_4hz_resam = resample(env_4hz,2048,44100);
%env_5hz_resam = resample(env_5hz,2048,44100);
%env_6hz_resam = resample(env_6hz,2048,44100);
%env_7hz_resam = resample(env_7hz,2048,44100);
env_8hz_resam = resample(env_8hz,2048,44100);

%envelope.env4hz = env_4hz_resam;
%envelope.env5hz = env_5hz_resam;
%envelope.env6hz = env_6hz_resam;
%envelope.env7hz = env_7hz_resam;
envelope.env8hz = env_8hz_resam;

% pre_eeg_data.trial{1}(72,:) = 50 * envelope.env4hz;
% pre_eeg_data.trial{1}(72,:) = 50 * envelope.env5hz;
% pre_eeg_data.trial{1}(72,:) = 50 * envelope.env6hz;
% pre_eeg_data.trial{1}(72,:) = 50 * envelope.env7hz;
 pre_eeg_data.trial{1}(72,:) = 50 * envelope.env8hz;

cfg = [];
cfg.viewmode = 'vertical';
cfg.blocksize = 2.5;

ft_databrowser(cfg,pre_eeg_data);

%% 
data = pre_eeg_data;

data.trial{1}(15,:) =  data.trial{1}(15,:) + data.trial{1}(72,:);

figure
    
subplot(3,1,1);
plot(data.time{1},data.trial{1}(15,:));
axis tight;
legend(data.label(15));
xlabel('time (s)')
grid

subplot(3,1,2);
plot(data.time{1},data.trial{1}(52,:));
axis tight;
legend(data.label(52));
xlabel('time (s)')
grid

subplot(3,1,3);
plot(data.time{1},data.trial{1}(72,:));
axis tight;
legend(data.label(72));
xlabel('time (s)')
grid
    

l_chanel = length(data.trial{1}(15,:));
f_res = 2048/l_chanel;
f_axis = (1:l_chanel)*f_res;
  
    
figure
subplot(3,1,1);
semilogx(f_axis,abs(fft(data.trial{1}(15,:))));
axis tight;
legend(data.label(15));
grid

subplot(3,1,2);
semilogx(f_axis,abs(fft(data.trial{1}(20,:))));
axis tight;
legend(data.label(20));
grid


subplot(3,1,3);
semilogx(f_axis,abs(fft(data.trial{1}(72,:))));
axis tight;
legend(data.label(72));
grid
 

[P1,f1] = periodogram(data.trial{1}(15,:),[],[],data.fsample,'power');
[P2,f2] = periodogram(data.trial{1}(52,:),[],[],data.fsample,'power');
[P3,f3] = periodogram(data.trial{1}(72,:),[],[],data.fsample,'power');

figure
subplot(3,1,1);
semilogx(f1,P1);
axis tight;
legend(data.label(15));
xlabel('Frequency (Hz)')
grid

subplot(3,1,2);
semilogx(f2,P2);
axis tight;
legend(data.label(52));
xlabel('Frequency (Hz)')
grid

subplot(3,1,3);
semilogx(f3,P3);
axis tight;
legend(data.label(72));
xlabel('Frequency (Hz)')
grid


[Cxy1,f1] = mscohere(data.trial{1}(15,:),data.trial{1}(72,:),hanning(2048),512,2048,data.fsample);
[Cxy2,f2] = mscohere(data.trial{1}(52,:),data.trial{1}(72,:),hanning(2048),512,2048,data.fsample);
[Cxy3,f3] = mscohere(data.trial{1}(72,:),data.trial{1}(72,:),hanning(2048),512,2048,data.fsample);

% [Cxy1,f1] = mscohere(data.trial{1}(15,:),data.trial{1}(72,:),[],[],[],data.fsample);
% [Cxy2,f2] = mscohere(data.trial{1}(52,:),data.trial{1}(72,:),[],[],[],data.fsample);
% [Cxy3,f3] = mscohere(data.trial{1}(72,:),data.trial{1}(72,:),[],[],[],data.fsample);
figure
ax = gca;

subplot(3,1,1)
semilogx(f1,Cxy1)
legend(data.label(15));
grid
xlabel('Frequency (Hz)')

subplot(3,1,2)
semilogx(f2,Cxy2)
legend(data.label(52));
grid
xlabel('Frequency (Hz)')

subplot(3,1,3)
semilogx(f3,Cxy3)
legend(data.label(72));
grid
xlabel('Frequency (Hz)')

%% frequency analysis
cfg            = [];
cfg.method     = 'mtmfft';
cfg.output     = 'powandcsd';
cfg.foilim     = [0 200];
cfg.taper      = 'hanning';

%cfg.keeptrials = 'yes';
cfg.channel    = {'eeg' 'envelope'};
cfg.channelcmb = {'eeg' 'envelope'};
freq           = ft_freqanalysis(cfg, data);

%% connectivity analysis
cfg            = [];
cfg.method     = 'coh';
cfg.channelcmb = {'eeg' 'envelope'};
fd             = ft_connectivityanalysis(cfg, freq);

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