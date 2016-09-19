clear
close all
clc

addpath ./fieldtrip-20160515
ft_defaults
%%
directory                   = './mri/XL/';
file_name                   = 'IM000001';
mri_file                    = fullfile(directory,file_name);
mri_orig                    = ft_read_mri(mri_file);
save mri_orig.mat mri_orig
% cfg                       = [];
% ft_sourceplot(cfg, mri_orig);
%%
cfg                         = [];
cfg.method                  = 'interactive';
cfg.coordsys                = 'ctf';
[mri_realigned1]            = ft_volumerealign(cfg, mri_orig);
save mri_realigned1.mat mri_realigned1
% cfg                         = [];
% ft_sourceplot(cfg,mri_realigned)
%%
% cfg                       = [];
% cfg.method                = 'headshape';
% cfg.headshape             = shape;
% [mri_realigned2]          = ft_volumerealign(cfg, mri_realigned1);
%%
% cfg                       = [];
% cfg.resolution            = 1;
% cfg.xrange                = [-100 100];
% cfg.yrange                = [-110 140];
% cfg.zrange                = [-80 120];
% mri_resliced              = ft_volumereslice(cfg,mri_realigned2);
% cfg                       = [];
% ft_sourceplot(cfg,mri_resliced)
%%
mri_resliced                = mri_realigned1; % temp
cfg                         = [];
cfg.output                  = {'brain','skull','scalp'};
cfg.scalpthreshold          = 0.03;
[mri_segmented]             = ft_volumesegment(cfg, mri_resliced);
mri_segmented.anatomy       = mri_resliced.anatomy;

cfg                         = [];
cfg.funparameter            = 'brain';
ft_sourceplot(cfg, mri_segmented);

cfg.funparameter            = 'skull';
ft_sourceplot(cfg, mri_segmented);

cfg.funparameter            = 'scalp';
ft_sourceplot(cfg, mri_segmented);

save mri_segmented.mat mri_segmented
%%
cfg                         = [];
cfg.method                  = 'projectmesh';
cfg.tissue                  = 'brain';
cfg.numvertices             = 3000;
mesh_eeg(1)                 = ft_prepare_mesh(cfg, mri_segmented);

cfg                         = [];
cfg.method                  = 'projectmesh';
cfg.tissue                  = 'skull';
cfg.numvertices             = 2000;
mesh_eeg(2)                 = ft_prepare_mesh(cfg, mri_segmented);

cfg                         = [];
cfg.method                  = 'projectmesh';
cfg.tissue                  = 'scalp';
cfg.numvertices             = 1000;
mesh_eeg(3)                 = ft_prepare_mesh(cfg, mri_segmented);

figure
ft_plot_mesh(mesh_eeg(1), 'edgecolor', 'none', 'facecolor', 'r')
ft_plot_mesh(mesh_eeg(2), 'edgecolor', 'none', 'facecolor', 'g')
ft_plot_mesh(mesh_eeg(3), 'edgecolor', 'none', 'facecolor', 'b')

material dull
camlight
lighting phong
alpha 0.3

save mesh_eeg.mat mesh_eeg

%%
cfg                         = [];
cfg.method                  ='dipoli'; % You can also specify 'openmeeg', 'bemcp', or another method.
headmodel_eeg               = ft_prepare_headmodel(cfg, mesh_eeg);

ft_plot_mesh(headmodel_eeg.bnd(1),'facecolor',[0.2 0.2 0.2],'facealpha', 0.3,'edgecolor', [1 1 1],'edgealpha', 0.05);
hold on;
ft_plot_mesh(headmodel_eeg.bnd(2),'edgecolor','none','facealpha',0.4);
hold on;
ft_plot_mesh(headmodel_eeg.bnd(3),'edgecolor','none','facecolor',[0.4 0.6 0.4]);

save headmodel_eeg.mat headmodel_eeg

%%
elec                        = ft_read_sens('MEG_EEG.sfp');
figure;
ft_plot_mesh(headmodel_eeg.bnd(1), 'edgecolor','none','facealpha',0.8,'facecolor',[0.6 0.6 0.8]); % head surface (scalp)
hold on;
ft_plot_sens(elec,'style', 'sk');  % electrodes

nas                         = mri_realigned1.cfg.fiducial.nas;
lpa                         = mri_realigned1.cfg.fiducial.lpa;
rpa                         = mri_realigned1.cfg.fiducial.rpa;
transm                      = mri_realigned1.transform;
 
nas                         = ft_warp_apply(transm,nas, 'homogenous');
lpa                         = ft_warp_apply(transm,lpa, 'homogenous');
rpa                         = ft_warp_apply(transm,rpa, 'homogenous');

% create a structure similar to a template set of electrodes
fid.elecpos                 = [nas; lpa; rpa];       % ctf-coordinates of fiducials
fid.label                   = {'FidNz','FidT9','FidT10'};    % same labels as in elec 
fid.unit                    = 'mm';                  % same units as mri
 
% alignment
cfg                         = [];
cfg.method                  = 'fiducial';            
cfg.target                  = fid;                   % see above
cfg.elec                    = elec;
cfg.fiducial                = {'FidNz','FidT9','FidT10'};  % labels of fiducials in fid and in elec
elec_aligned                = ft_electroderealign(cfg);

figure;
ft_plot_sens(elec_aligned,'style','sk');
hold on;
ft_plot_mesh(headmodel_eeg.bnd(1),'facealpha', 0.85, 'edgecolor', 'none', 'facecolor', [0.65 0.65 0.65]); %scalp
save elec_aligned elec_aligned;

%%
cfg                         = [];
cfg.method                  = 'interactive';
cfg.elec                    = elec_aligned;
cfg.headshape               = headmodel_eeg.bnd(1);
elec_aligned                = ft_electroderealign(cfg);