clear
close all
clc
addpath ./fieldtrip-20151119;

load data

% cfg            = [];
% cfg.output     = 'fourier';
% cfg.method     = 'mtmfft';
% cfg.foilim     = [5 100];
% cfg.tapsmofrq  = 5;
% cfg.keeptrials = 'yes';
% cfg.channel    = {'MEG' 'EMGlft' 'EMGrgt'};
% freqfourier    = ft_freqanalysis(cfg, data);


cfg            = [];
cfg.output     = 'powandcsd';
cfg.method     = 'mtmfft';
cfg.foilim     = [5 100];
cfg.tapsmofrq  = 5;
cfg.keeptrials = 'yes';
cfg.channel    = {'MEG' 'EMGlft' 'EMGrgt'};
cfg.channelcmb = {'MEG' 'EMGlft'; 'MEG' 'EMGrgt'};
freq           = ft_freqanalysis(cfg, data);


cfg            = [];
cfg.method     = 'coh';
cfg.channelcmb = {'MEG' 'EMG'};
fd             = ft_connectivityanalysis(cfg, freq);
%fdfourier      = ft_connectivityanalysis(cfg, freqfourier);

cfg                  = [];
cfg.parameter        = 'cohspctrm';
cfg.xlim             = [5 80];
cfg.refchannel       = 'EMGlft';
cfg.layout           = 'CTF151.lay';
cfg.showlabels       = 'yes';
figure; ft_multiplotER(cfg, fd)

cfg.channel = 'MRC21';
figure; ft_singleplotER(cfg, fd);

cfg                  = [];
cfg.parameter        = 'cohspctrm';
cfg.xlim             = [15 20];
cfg.zlim             = [0 0.1];
cfg.refchannel       = 'EMGlft';
cfg.layout           = 'CTF151.lay';
figure; ft_topoplotER(cfg, fd)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cfg            = [];
cfg.output     = 'powandcsd';
cfg.method     = 'mtmfft';
cfg.foilim     = [5 100];
cfg.tapsmofrq  = 5;
cfg.keeptrials = 'yes';
cfg.channel    = {'MEG' 'EMGlft'};
cfg.channelcmb = {'MEG' 'EMGlft'};
cfg.trials     = 1;  
freq50         = ft_freqanalysis(cfg,data);

cfg            = [];
cfg.method     = 'coh';
cfg.channelcmb = {'MEG' 'EMG'};
fd50           = ft_connectivityanalysis(cfg,freq50);


cfg                  = [];
cfg.parameter        = 'cohspctrm';
cfg.xlim             = [5 100];
%cfg.ylim             = [0 0.2];
cfg.refchannel       = 'EMGlft';
cfg.channel          = 'MRC21';
figure; ft_singleplotER(cfg, fd50);


cfg                  = [];
cfg.parameter        = 'cohspctrm';
cfg.xlim             = [15 20];
cfg.zlim             = [0 0.1];
cfg.refchannel       = 'EMGlft';
cfg.layout           = 'CTF151.lay';
figure; ft_topoplotER(cfg, fd50)