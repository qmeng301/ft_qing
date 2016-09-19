%% source analysis AEP
close all
clear
clc

addpath ./fieldtrip-20160515
ft_defaults

load headmodel_eeg.mat
load elec_aligned.mat

cfg                 = [];
cfg.elec            = elec_aligned;
cfg.headmodel       = headmodel_eeg;
cfg.lcmv.reducerank = 3; % default for MEG is 2, for EEG is 3
cfg.grid.resolution = 1;   % use a 3-D grid with a 1 cm resolution
cfg.grid.unit       = 'cm';
cfg.grid.tight      = 'yes';
[grid] = ft_prepare_leadfield(cfg);
%save grid.mat grid
%%

%load grid.mat
load AEP_avg_data
load AEP_avg_data_pre
load AEP_avg_data_post

cfg                 = [];
cfg.method          = 'lcmv';
cfg.grid            = grid;
cfg.elec            = elec_aligned;
cfg.headmodel       = headmodel_eeg;
cfg.lcmv.keepfilter = 'yes';
cfg.lcmv.lambda     = '5%';
cfg.channel         = {'eeg'};
cfg.senstype        = 'EEG';
sourceavg           = ft_sourceanalysis(cfg, avg);
 
%%
cfg                 = [];
cfg.method          = 'lcmv';
cfg.elec            = elec_aligned;
cfg.grid            = grid;
%cfg.grid.filter     = sourceavg.avg.filter; %
cfg.headmodel       = headmodel_eeg;
%cfg.lcmv.lambda     = '5%';
%cfg.channel         = {'eeg'};
cfg.senstype        = 'EEG';
source_pre          = ft_sourceanalysis(cfg, avg_pre);
source_pst          = ft_sourceanalysis(cfg, avg_pst);

%%
M1eeg=source_pst;
M1eeg.avg.pow=(source_pst.avg.pow-source_pre.avg.pow)./source_pre.avg.pow;

load mri_realigned;

cfg              = [];
cfg.voxelcoord   = 'no';
cfg.parameter    = 'pow';
cfg.interpmethod = 'nearest';
%source_int  = ft_sourceinterpolate(cfg, M1eeg, mri_realigned);
source_int  = ft_sourceinterpolate(cfg, sourceavg, mri_realigned);


source_int.mask     = source_int.pow > max(source_int.pow(:))*.3;% 50 % of maximum
cfg                 = [];
cfg.method          = 'ortho';
cfg.funparameter    = 'pow';
cfg.maskparameter   = 'mask';
cfg.location        = [-28 -17 67]; 
cfg.funcolorlim     = [-.2 .2];
cfg.funcolormap     = 'jet';
ft_sourceplot(cfg,source_int);

