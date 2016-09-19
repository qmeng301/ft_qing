clear
close all
clc

addpath ./fieldtrip-20160515
ft_defaults
%%
mri_orig = ft_read_mri('./mri/IM000001');

cfg = [];
cfg.method = 'interactive';
cfg.coordsys = 'spm';
mri_spm    = ft_volumerealign(cfg, mri_orig);
%%
cfg            = [];
cfg.resolution = 1;
cfg.dim        = [256 256 256];
mri_rs          = ft_volumereslice(cfg, mri_spm);
transform_vox2spm = mri_rs.transform;

save('Subject01_transform_vox2spm', 'transform_vox2spm');

%%
% save the resliced anatomy in a FreeSurfer compatible format
cfg             = [];
cfg.filename    = 'Subject01';
cfg.filetype    = 'mgz';
cfg.parameter   = 'anatomy';
ft_volumewrite(cfg, mri_rs);

%%
cfg = [];
cfg.method = 'interactive';
cfg.coordsys = 'ctf';
mri_rs_ctf    = ft_volumerealign(cfg, mri_rs);
transform_vox2ctf = mri_rs_ctf.transform;

save('Subject01_transform_vox2ctf', 'transform_vox2ctf');

%%

mri = ft_read_mri('Subject01.mgz');
mri.coordsys = 'spm';

cfg = [];
cfg.output = 'brain';
seg = ft_volumesegment(cfg, mri);
mri.anatomy = mri.anatomy.*double(seg.brain);

cfg             = [];
cfg.filename    = 'Subject01masked';
cfg.filetype    = 'mgz';
cfg.parameter   = 'anatomy';
ft_volumewrite(cfg, mri);

