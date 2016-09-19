close all
clear 
clc

addpath ./fieldtrip-20151119;
%% define trials and read in raw EEG data
directory = './raw_recording/MEG3_data/03-2016/0015/data_analysis';
file_name = '2016_03_23_0015_MN_resting_state_run1_analysis_01.con';
%directory = './raw_recording/MEG3_data/03-2016/0038/data_analysis';
%file_name = '2016_03_24_0038_BD_silence_5mins_analysis_01.con';
% create the trial definition
cfg = [];
cfg.dataset = fullfile(directory,file_name);
cfg.trialfun              = 'mytrialfun_MEG';
cfg.trialdef.trigchannel    = '049';
cfg.trialdef.prestim      = 0; % latency in seconds
cfg.trialdef.poststim     = 300; % latency in seconds

cfg = ft_definetrial(cfg);
cfg.trl = cfg.trl(1,:); % get rid of the second "trial"
epoch_data = ft_preprocessing(cfg);
%% filter 
cfg = [];
cfg.channel        = (1:20);
%cfg.lpfilter        = 'yes';
%cfg.lpfreq          = 30;
%cfg.hpfilter        = 'yes';
%cfg.hpfreq          = 1.5;
pre_meg_data = ft_preprocessing(cfg,epoch_data);

ave_data = sum(pre_meg_data.trial{1}())./20;

half_length = (length(ave_data)-1)/2;

freq_data = abs(fft(ave_data));

f_res = 1000/length(ave_data);

f_axis = (1:half_length)*f_res;

figure(1)

semilogx(f_axis, freq_data(1:half_length).^2)
grid on
xlim ([8, 30]);

% cfg = [];
% cfg.blocksize = 300;
% cfg.viewmode = 'vertical';
% ft_databrowser(cfg,pre_meg_data);
%% time-frequency analysis

cfg              = [];
cfg.output       = 'pow';
cfg.channel      = (1:20);
cfg.method       = 'mtmfft';
cfg.taper        = 'hanning';
cfg.foilim     = [2 20];
% cfg.foi          = 2:0.5:20;                         % analysis 2 to 30 Hz in steps of 2 Hz 
% cfg.t_ftimwin    = ones(length(cfg.foi),1).*0.5;   % length of time window = 0.5 sec
% cfg.toi          = 0:0.5:300;                  % time window "slides" from -0.5 to 1.5 sec in steps of 0.05 sec (50 ms)
Freq_hann = ft_freqanalysis(cfg, pre_meg_data);
%% Visuallization
cfg = [];
%cfg.baseline     = [-0.5 -0.1]; 
%cfg.baselinetype = 'absolute'; 
%cfg.zlim         = [-3e30 3e30];	        
cfg.showlabels   = 'yes';	
%cfg.layout       = 'vertical';
figure 
ft_multiplotER(cfg, Freq_hann);
