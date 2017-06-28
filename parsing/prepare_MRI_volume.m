% qmeng-300117

clear
close all
clc

addpath ../../fieldtrip-20160515
ft_defaults

%%
directory                   = '../raw_data/mri/01-YL-840110/DICOM';
file_name                   = 'IM000001';
mri_file                    = fullfile(directory,file_name);
mri_orig                    = ft_read_mri(mri_file);

cfg                         = [];
cfg.dim                     = [256 256 256];
mri_resliced                = ft_volumereslice(cfg,mri_orig);
mri_resliced                = ft_convert_units(mri_resliced, 'cm');

cfg                         = [];
cfg.method                  = 'interactive';
cfg.coordsys                = 'ctf';
mri_realigned               = ft_volumerealign(cfg, mri_resliced);
save mri_realigned.mat mri_realigned

%%
cfg                         = [];
mri_segmented               = ft_volumesegment(cfg, mri_realigned);
save mri_segmented.mat mri_segmented
%%
cfg                         = [];
cfg.method                  = 'singleshell';
headmodel                   = ft_prepare_headmodel(cfg, mri_segmented);

%%
grad_con                    = ft_read_sens('../raw_data/MEG/01-YL-840110/2016_12_12_2407_ME149_YL_B5.con'); % sensor location: standard

grad_pos                    = ft_read_sens('../raw_data/MEG/01-YL-840110/2016_12_12_2407_ME149_YL_B5.pos','fileformat','besa_pos'); % sensor location: coregistered (BESA coordinates)
grad_pos                    = ft_convert_units(grad_pos, 'cm');

fid_sfp                     = ft_read_sens('../raw_data/MEG/01-YL-840110/2407_ME149_YL_2016_12_12.sfp','fileformat','besa_sfp'); % get fiducials from SFP (BESA coordinates)
fid_sfp                     = ft_convert_units(fid_sfp, 'cm');

grad_sfp.chanpos            = [fid_sfp.chanpos(1:3,:);grad_pos.chanpos]; % combine fiducials with sensor locations
grad_sfp.elecpos            = grad_sfp.chanpos;
grad_sfp.label              = [fid_sfp.label(1:3);grad_pos.label];
grad_sfp.unit               = fid_sfp.unit;

figure;
ft_plot_mesh(headmodel.bnd(1), 'edgecolor','none','facealpha',0.8,'facecolor',[0.6 0.6 0.8]); % head surface (scalp)
hold on;
ft_plot_sens(grad_sfp,'style', 'sk');  % sensor location: coregistered
ft_plot_sens(grad_con,'style', 'g*');  % sensor location: standard
legend ('head model', 'actual sensor position','default sensor position')

% get fiducials from MRI
nas                         = mri_realigned.cfg.fiducial.nas;
lpa                         = mri_realigned.cfg.fiducial.lpa;
rpa                         = mri_realigned.cfg.fiducial.rpa;
transm                      = mri_realigned.transform;

nas                         = ft_warp_apply(transm,nas, 'homogenous');
lpa                         = ft_warp_apply(transm,lpa, 'homogenous');
rpa                         = ft_warp_apply(transm,rpa, 'homogenous');

% create a structure similar to a template set of electrodes
fid.elecpos                 = [ lpa; nas; rpa];       % ctf-coordinates of fiducials
fid.label                   = {'fidt9','fidnz','fidt10'};    % same labels as in elec
fid.unit                    = 'cm';

% alignment
cfg                         = [];
cfg.method                  = 'fiducial';
cfg.target                  = fid;                           % see above
cfg.elec                    = grad_sfp;                      % sensor information
cfg.fiducial                = {'fidt9','fidnz','fidt10'};  % labels of fiducials in fid and in elec
grad_sfp_aligned            = ft_electroderealign(cfg);

% assign the aligned senseor position back to the a file has same structure as the one read from .con file
grad_con_aligned            = grad_con;
grad_con_aligned.chanpos    = grad_sfp_aligned.chanpos(4:end,:); % only take sensor locations

figure;
ft_plot_mesh(headmodel.bnd(1), 'edgecolor','none','facealpha',0.8,'facecolor',[0.6 0.6 0.8]); % head surface (scalp)
hold on;
ft_plot_sens(grad_con_aligned,'style', 'sk');  % electrodes
ft_plot_sens(grad_con,'style', 'g*');  % electrodes
legend ('head model', 'actual sensor position - realigned','default sensor position')

cfg                         = [];
cfg.grad                    = grad_con_aligned;
cfg.headmodel               = headmodel; 
leadfield                   = ft_prepare_leadfield(cfg);
