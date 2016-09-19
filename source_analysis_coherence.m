%% source analysis
close all
clear
clc

addpath ./fieldtrip-20160515;
ft_defaults

load headmodel_eeg.mat
load elec_aligned.mat
cfg                     = [];
cfg.elec                = elec_aligned;
cfg.headmodel           = headmodel_eeg;
cfg.dics.reducerank     = 3; % default for MEG is 2, for EEG is 3
cfg.grid.resolution     = 1; % use a 3-D grid with a 1 cm resolution
cfg.grid.unit           = 'cm';
[grid]                  = ft_prepare_leadfield(cfg);
save grid.mat grid
%%
load data_eeg_env.mat
load rand_powspctrm.mat
load rand_crsspctrm.mat

cfg                             = [];
cfg.method                      = 'mtmfft';
cfg.output                      = 'powandcsd';
cfg.foilim                      = [6 6];
cfg.taper                       = 'hanning';
cfg.channel                     = {'eeg' 'envelope'};
cfg.channelcmb                  = {'eeg' 'eeg';'eeg' 'envelope'};
data_eeg_spowcsd                = ft_freqanalysis(cfg, data_eeg_env);

data_eeg_ave_rspowcsd           = data_eeg_spowcsd;
data_eeg_ave_rspowcsd.powspctrm = mean (rand_powspctrm,2);
data_eeg_ave_rspowcsd.crsspctrm = mean (rand_crsspctrm,2);

%% source analysis

cfg                     = [];
cfg.channel             = {'eeg','envelope'};
cfg.elec                = elec_aligned;
cfg.method              = 'dics';
cfg.refchan             = 'envelope';
cfg.frequency           = 6;
cfg.grid                = grid;
cfg.headmodel           = headmodel_eeg;
cfg.dics.keepfilter     = 'yes';
cfg.dics.projectnoise   = 'yes';
cfg.dics.lambda         = '5%';
%cfg.inwardshift        = 1;
%cfg.grid.resolution    = 1;
%cfg.grid.unit          = 'cm';
source_eeg              = ft_sourceanalysis(cfg, data_eeg_spowcsd);
source_eeg_random       = ft_sourceanalysis(cfg, data_eeg_ave_rspowcsd);

%% 
load mri_realigned1
% cfg                       = [];
% mri_resliced              = ft_volumereslice(cfg, mri_realigned);
cfg                         = [];
cfg.parameter               = 'coh';
cfg.downsample              = 2;
source_eeg_interp           = ft_sourceinterpolate(cfg, source_eeg, mri_realigned1);
source_eeg_random_interp    = ft_sourceinterpolate(cfg, source_eeg_random, mri_realigned1);

source_eeg_diff_interp      = source_eeg_interp;
%source_eeg_diff_interp.coh  = (source_eeg_interp.coh - source_eeg_random_interp.coh) ./ (source_eeg_interp.coh + source_eeg_random_interp.coh);

source_eeg_diff_interp.coh  = source_eeg_interp.coh - source_eeg_random_interp.coh;

% % read the atlas
% atlas = ft_read_atlas('./fieldtrip-20160515/template/atlas/aal/ROI_MNI_V4.nii');
%  
% % load the template sourcemodel with the resolution you need (i.e. the resolution you used in your beamformer grid)
% load('./fieldtrip-20160515/template/sourcemodel/standard_sourcemodel3d10mm.mat')
%  
% % and call ft_sourceinterpolate: 
% cfg = []; 
% cfg.interpmethod = 'nearest'; 
% cfg.parameter = 'tissue'; 
% sourcemodel2 = ft_sourceinterpolate(cfg, atlas, source_eeg_diff_interp); 


cfg                         = [];
cfg.method                  = 'ortho';
cfg.funparameter            = 'coh';
cfg.funcolorlim             = 'zeromax';
% cfg.opacitylim              = [0 1e-4]; 
% cfg.opacitymap              = 'rampup';  
cfg.interactive             = 'yes';
%cfg.atlas                   = ''
%ft_sourceplot(cfg, source_eeg_interp);
ft_sourceplot(cfg, source_eeg_diff_interp);


