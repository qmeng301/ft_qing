
close all
clear
clc

source_dataDir              = './source_space/Adult/English';

source_SubjectDir       = fullfile(source_dataDir,'fsaverage');

% output data directory
source_resultsDir = fullfile(source_SubjectDir,'MEG','SUMA');
if ~isdir(source_resultsDir)
    mkdir(source_resultsDir); % make directory if it doesn't exist
end

if exist(fullfile(source_resultsDir,'mri_ctf.mat'),'file')==2
    load(fullfile(source_resultsDir,'mri_ctf'));
else
    mriDir = fullfile(source_SubjectDir,'SUMA');
    mri = ft_read_mri(fullfile(mriDir,'T1.nii')); % already aligned to Tal space in Freesurfer
    
    % using reslice here to bring the mri to fieldtrip view
    cfg = [];
    cfg.dim  = [256 256 256];
    mri_rs = ft_volumereslice(cfg, mri);
    mri_rs = ft_convert_units(mri_rs, 'cm');
    
    % ft_sourceplot([],mri_rs);
    
    % realign to the MEG sensor space using the fiducials
    cfg = [];
    cfg.method  = 'interactive';
    mri_ctf = ft_volumerealign(cfg, mri_rs);
    save(fullfile(source_resultsDir,'mri_ctf.mat'), 'mri_ctf');
    
end
% ft_sourceplot([],mri_ctf);

if exist(fullfile(source_resultsDir,'sourcespace_smoothwm_SUMA_T.mat'),'file')==2
    load(fullfile(source_resultsDir,'sourcespace_smoothwm_SUMA_T.mat'));
else
    
    % read in the reduced standard mesh file processed from SUMA
    file_LH = fullfile(source_SubjectDir,'SUMA','std.10.lh.smoothwm.gii');
    file_RH = fullfile(source_SubjectDir,'SUMA','std.10.rh.smoothwm.gii');
    if exist(file_LH,'file')==2
        
        sourcespace_smoothwm_SUMA_T = ft_read_headshape({file_LH file_RH }, 'format', 'gifti');
    else
        
        disp ('humm.......');
        
    end
    
    % trisurf(sourcespace_S_SUMA.tri,sourcespace_S_SUMA.pnt(:,1),sourcespace_S_SUMA.pnt(:,2),sourcespace_S_SUMA.pnt(:,3));
    
    sourcespace_smoothwm_SUMA_T = ft_convert_units(sourcespace_smoothwm_SUMA_T, 'cm');
    
    T = mri_ctf.transform*inv(mri_ctf.transformorig); % note the transformation difference between MNE and SUMA
    sourcespace_smoothwm_SUMA_T = ft_transform_geometry(T, sourcespace_smoothwm_SUMA_T);
    
    if exist(fullfile(source_resultsDir,'sourcespace_smoothwm_SUMA_T.mat'),'file')==0
        save(fullfile(source_resultsDir,'sourcespace_smoothwm_SUMA_T.mat'), 'sourcespace_smoothwm_SUMA_T');
    end
    
    if exist(fullfile(source_resultsDir,'transformationM.mat'),'file')==0
        save(fullfile(source_resultsDir,'transformationM.mat'), 'T');
    end
end

% create head model using single shell
if exist(fullfile(source_resultsDir,'hdm.mat'),'file')==2
    load(fullfile(source_resultsDir,'hdm.mat'));
else
    
    cfg           = [];
    cfg.method    = 'singleshell';
    hdm           = ft_prepare_headmodel(cfg,sourcespace_smoothwm_SUMA_T);
    save(fullfile(source_resultsDir,'hdm.mat'), 'hdm');
    
end

figure
hold on;
ft_plot_vol(hdm, 'facecolor', 'none');alpha 0.5;
ft_plot_mesh(sourcespace_smoothwm_SUMA_T, 'edgecolor', 'none'); camlight
ft_plot_mesh(sourcespace_smoothwm_SUMA_T.pos,'vertexcolor', 'r'); camlight
title('Template');
hold off

