clear
close all
clc

addpath /Users/mq20132881/Desktop/analysis_software/Fieldtrip/fieldtrip-20151119;

directory = './raw_recording/ERP';
file_name = '0002_HH_AEP_run2.bdf';
    
% create the trial definition
cfg = [];
cfg.dataset = fullfile(directory,file_name);
%cfg.ylim = [-50, 50];
%cfg.eegscale = 10;
%cfg.blocksize = 10;
%cfg.viewmode = 'vertical';
%ft_databrowser(cfg);

cfg.trialfun              = 'ft_trialfun_general';
cfg.trialdef.eventtype    = 'STATUS';
cfg.trialdef.eventvalue   = 16; % stimulus triggers
cfg.trialdef.prestim      = 0.1; % latency in seconds
cfg.trialdef.poststim     = 0.5; % latency in seconds
    
cfg = ft_definetrial(cfg);
%disp(cfg.trl);


%%
% Re-referencing 
%trl = cfg.trl;
%cfg=[];
%cfg.dataset = fullfile(directory,file_name);
%cfg.trl           = trl;
cfg.reref         = 'yes';
cfg.refchannel    = 'all';

% Fitering options
cfg.lpfilter        = 'yes';
cfg.lpfreq          = 30;
cfg.hpfilter        = 'yes';
cfg.hpfreq          = 2;
    
data = ft_preprocessing(cfg);

%%
cfg = [];  % use only default options  
cfg.viewmode = 'vertical';
ft_databrowser(cfg, data);

%cfg.channel  = data.label(1:64);
cfg.layout   = 'biosemi64.lay';
cfg.feedback = 'yes';
lay = ft_prepare_layout(cfg);
disp(lay)
%%
% artifact rejection 
%cfg        = [];
%cfg.method = 'channel';
%ft_rejectvisual(cfg, data)

% artifact rejection
%cfg = [];
%cfg.method   = 'summary';
%cfg.layout   = lay;       % this allows for plotting
%cfg.channel  = (1:64);    % do not show EOG channels
%data_clean   = ft_rejectvisual(cfg, data);

%%
cfg = [];
cfg.trials = find(data.trialinfo==16);
task = ft_timelockanalysis(cfg, data);
%ft_singleplotER([],task);

cfg = [];
cfg.layout = lay;
cfg.interactive = 'yes';
ft_multiplotER(cfg, task)
