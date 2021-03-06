% STEP 2: reads the freesurfer and SUMA processed MRI files, do reslice and realign to MEG sensor space
% output the realigned MRI data, head model (single shell on pial matter surface into results folder, subfolder 02-head-anatomy
% use the cog_check_individual_head_sensor_alignment_SUMA.m in the utilities folder to check the sensor alignment
% add create_SUMA_surf_curv also to the individual inf_200 surface 25.01.2016
% add get_SUMA_cortex_ind_for_atlas 25.06.2016; this step is commented
% since fsaverage is used to get the atlas indices for all subjects

% yiwen 14.07.2016, modified 17.01.17 qmeng

close all
clear
clc

preparation_MEGIII
%%


%test_name = 'parsing';
%test_name = 'pantev';
test_name = 'masanori';


switch test_name
    
    case {'parsing'}

%     for iCondition = 1:length(allConditions_parsing) % parsing
%         condition = allConditions_parsing{iCondition};
%         for iSubject = 1:length(allSubjects_parsing)
%             subject                 = allSubjects_parsing{iSubject};
%             raw_SubjectdataDir      = fullfile(raw_dataDir,subject);
%             source_SubjectDir       = fullfile(source_dataDir,[subject '-FS']);
%             sensor_resultsDir       = fullfile(sensor_dataDir,subject);
%             
%             load(fullfile(sensor_resultsDir,['data_meg_prep_',test_name,'_',condition]));
%             grad_ICA_cleaned        = data_meg_prep.grad;
%             
%                 disp('*******************************')
%                 disp(['processing ' subject,'_', test_name,'_', condition]);
%                 disp('*******************************')
%             
%             if strcmp(condition,'B1')
%                 file_name               = cell2mat(allFiles_parsing((iSubject-1)*4+1));
%             elseif strcmp(condition,'B2')
%                 file_name               = cell2mat(allFiles_parsing((iSubject-1)*4+2));
%             elseif strcmp(condition,'B3')
%                 file_name               = cell2mat(allFiles_parsing((iSubject-1)*4+3));
%             elseif strcmp(condition,'B4')
%                 file_name               = cell2mat(allFiles_parsing((iSubject-1)*4+4));
%             end
%             
%             % output data directory
%             source_resultsDir = fullfile(source_SubjectDir,'MEG','SUMA');
%             if ~isdir(source_resultsDir)
%                 mkdir(source_resultsDir); % make directory if it doesn't exist
%             end
%             
%             if exist(fullfile(source_resultsDir,'mri_ctf.mat'),'file')==2
%                 load(fullfile(source_resultsDir,'mri_ctf'));
%             else
%                 mriDir = fullfile(source_SubjectDir,'bem','SUMA');
%                 mri = ft_read_mri(fullfile(mriDir,'T1.nii')); % already aligned to Tal space in Freesurfer
%                 
%                 % using reslice here to bring the mri to fieldtrip view
%                 cfg = [];
%                 cfg.dim  = [256 256 256];
%                 mri_rs = ft_volumereslice(cfg, mri);
%                 mri_rs = ft_convert_units(mri_rs, 'cm');
%                 
%                 % ft_sourceplot([],mri_rs);
%                 
%                 % realign to the MEG sensor space using the fiducials
%                 cfg = [];
%                 cfg.method  = 'interactive';
%                 mri_ctf = ft_volumerealign(cfg, mri_rs);
%                 save(fullfile(source_resultsDir,'mri_ctf.mat'), 'mri_ctf');
%                 
%             end
%             % ft_sourceplot([],mri_ctf);
%             
%             if exist(fullfile(source_resultsDir,'sourcespace_smoothwm_SUMA.mat'),'file')==2
%                 load(fullfile(source_resultsDir,'sourcespace_smoothwm_SUMA.mat'));
%             else
%                 
%                 % read in the reduced standard mesh file processed from SUMA
%                 file_LH = fullfile(source_SubjectDir,'bem','SUMA','std.10.lh.smoothwm.gii');
%                 file_RH = fullfile(source_SubjectDir,'bem','SUMA','std.10.rh.smoothwm.gii');
%                 if exist(file_LH,'file')==2
%                     
%                     sourcespace_smoothwm_SUMA = ft_read_headshape({file_LH file_RH }, 'format', 'gifti');
%                 else
%                     load(fullfile(rootpath2,'utilities','SUMA_sourcespace')); % load the template SUMA sourcespace
%                     file_LH = fullfile(SubjectDir,'bem','SUMA','std.10.lh.smoothwm.asc');
%                     file_RH = fullfile(SubjectDir,'bem','SUMA','std.10.rh.smoothwm.asc');
%                     [S, v, f] = read_asc(file_LH);
%                     sourcespace_smoothwm_SUMA = SUMA_sourcespace;
%                     sourcespace_smoothwm_SUMA.pnt = v(:,1:3);
%                     sourcespace_S_SUMA.tri = f(:,1:3);
%                     [S, v, f] = read_asc(file_RH);
%                     sourcespace_smoothwm_SUMA.pnt = [sourcespace_smoothwm_SUMA.pnt; v(:,1:3)];
%                     sourcespace_smoothwm_SUMA.tri = [sourcespace_smoothwm_SUMA.tri; f(:,1:3)+S(2)];
%                     
%                 end
%                 
%                 % trisurf(sourcespace_S_SUMA.tri,sourcespace_S_SUMA.pnt(:,1),sourcespace_S_SUMA.pnt(:,2),sourcespace_S_SUMA.pnt(:,3));
%                 
%                 sourcespace_smoothwm_SUMA = ft_convert_units(sourcespace_smoothwm_SUMA, 'cm');
%                 
%                 T = mri_ctf.transform*inv(mri_ctf.transformorig); % note the transformation difference between MNE and SUMA
%                 sourcespace_smoothwm_SUMA = ft_transform_geometry(T, sourcespace_smoothwm_SUMA);
%                 
%                 if exist(fullfile(source_resultsDir,'sourcespace_smoothwm_SUMA.mat'),'file')==0
%                     save(fullfile(source_resultsDir,'sourcespace_smoothwm_SUMA.mat'), 'sourcespace_smoothwm_SUMA');
%                     save(fullfile(source_resultsDir,'transformationM.mat'), 'T');
%                 end
%                 
%                 if exist(fullfile(source_resultsDir,'transformationM.mat'),'file')==0
%                     save(fullfile(source_resultsDir,'transformationM.mat'), 'T');
%                 end
%             end
%             
%             % create head model using single shell
%             if exist(fullfile(source_resultsDir,'hdm.mat'),'file')==2
%                 load(fullfile(source_resultsDir,'hdm.mat'));
%             else
%                 
%                 cfg           = [];
%                 cfg.method    = 'singleshell';
%                 hdm           = ft_prepare_headmodel(cfg,sourcespace_smoothwm_SUMA);
%                 save(fullfile(source_resultsDir,'hdm.mat'), 'hdm');
%                 
%             end
%             
%             
% %             figure
% %             hold on;
% %             ft_plot_vol(hdm, 'facecolor', 'none');alpha 0.5;
% %             ft_plot_mesh(sourcespace_smoothwm_SUMA, 'edgecolor', 'none'); camlight
% %             ft_plot_mesh(sourcespace_smoothwm_SUMA.pos,'vertexcolor', 'r'); camlight
% %             title(allSubjects_parsing{iSubject});
% %             hold off
%             
%             %%
%             sfp                 = ft_read_headshape (fullfile(raw_SubjectdataDir,[file_name(1:end-3),'.sfp']),'fileformat','besa_sfp');
%             sfp                 = ft_convert_units(sfp, 'cm');
%             
%             %figure;
%             %ft_plot_mesh(hdm.bnd(1), 'edgecolor','none','facealpha',0.8,'facecolor',[0.6 0.6 0.8]); % head surface (scalp)
%             %hold on;
%             %ft_plot_mesh(sfp,'style', 'sk');  % surface points + fiducial in BESA
%             %ft_plot_sens(grad_ICA_cleaned,'style', 'g*');  % sensor location: co-registered with BESA
%             %legend ('head model','BESA sensor position');
%             
%             % get fiducials from SFP (BESA)
%             nas_sfp             = sfp.fid.pos(strcmp(sfp.fid.label,'fidnz'),:);
%             lpa_sfp             = sfp.fid.pos(strcmp(sfp.fid.label,'fidt9'),:);
%             rpa_sfp             = sfp.fid.pos(strcmp(sfp.fid.label,'fidt10'),:);
%             
%             % get fiducials from MRI
%             nas_mri             = ft_warp_apply(mri_ctf.transform, mri_ctf.cfg.fiducial.nas, 'homogenous');
%             lpa_mri             = ft_warp_apply(mri_ctf.transform, mri_ctf.cfg.fiducial.lpa, 'homogenous');
%             rpa_mri             = ft_warp_apply(mri_ctf.transform, mri_ctf.cfg.fiducial.rpa, 'homogenous');
%             
%             BESA2ctf            = ft_headcoordinates(nas_sfp, lpa_sfp, rpa_sfp,'ctf');
%             %%
%             nas_mri_T           = ft_warp_apply(BESA2ctf, nas_sfp, 'homogeneous');
%             lpa_mri_T           = ft_warp_apply(BESA2ctf, lpa_sfp, 'homogeneous');
%             rpa_mri_T           = ft_warp_apply(BESA2ctf, rpa_sfp, 'homogeneous');
%             
%             dpre  = mean(sqrt(sum(([nas_sfp;lpa_sfp;rpa_sfp] - [nas_mri; lpa_mri; rpa_mri]).^2, 2)));
%             
%             dpost = mean(sqrt(sum(([nas_mri_T; lpa_mri_T; rpa_mri_T] - [nas_mri; lpa_mri; rpa_mri]).^2, 2)));
%             
%             fprintf('mean distance between fiducials prior to realignment %f, after realignment %f\n', dpre, dpost);
%             %%
%             
%             grad_realigned      = ft_transform_sens(BESA2ctf, grad_ICA_cleaned);
%             
%             %figure;
%             %ft_plot_mesh(hdm.bnd(1), 'edgecolor','none','facealpha',0.8,'facecolor',[0.6 0.6 0.8]); % head surface (scalp)
%             %hold on;
%             %ft_plot_mesh(sfp,'style', 'sk');  % surface points + fiducial in BESA
%             %ft_plot_sens(grad_realigned,'style', 'g*');  % electrodes
%             %legend ('head model','sensor position - realigned')
%                   
%             
%             if exist(fullfile(source_resultsDir,['leadfield_',test_name,'_',condition,'.mat']),'file')==2
%                 load(fullfile(source_resultsDir,['leadfield_',test_name,'_',condition]));
%             else
%                 cfg                         = [];
%                 cfg.grad                    = grad_realigned;
%                 cfg.grid.pos                = sourcespace_smoothwm_SUMA.pos;              % source points
%                 cfg.grid.inside             = 1:size(sourcespace_smoothwm_SUMA.pos,1); % all source points are inside of the brain
%                 cfg.headmodel               = hdm; % newer fieldtrip version
%                 %cfg.normalize               ='yes';
%                 leadfield                   = ft_prepare_leadfield(cfg);
%                 save(fullfile(source_resultsDir,['leadfield_',test_name,'_',condition,'.mat']), 'leadfield');
%             end
%             
%             if exist(fullfile(source_resultsDir,['grad_realigned',test_name,'_',condition,'.mat']),'file')==0
%                 save(fullfile(source_resultsDir,['grad_realigned',test_name,'_',condition,'.mat']), 'grad_realigned');
%             end
%             
%             figure
%             hold on     % plot all objects in one figure
%             ft_plot_vol(hdm, 'edgecolor', 'none'); alpha 0.8; % make the headmodel surface transparent
%             ft_plot_mesh(leadfield.pos,'vertexcolor','b');
%             title(allSubjects_parsing{iSubject},'interpreter','none');
%             ft_plot_sens(grad_realigned,'style', 'g*');hold off
%             view([0 -90 0])
%             %create_SUMA_surf_curv(subject);
%             %get_SUMA_cortex_ind_for_atlas(rootpath,subject);
%         end
%         
%     end
    
%     case ('pantev')
%         for iSubject = 1:length(allSubjects_tone_pantev)
%             subject                 = allSubjects_tone_pantev{iSubject};
%             raw_SubjectdataDir      = fullfile(raw_dataDir,subject);
%             source_SubjectDir       = fullfile(source_dataDir,[subject '-FS']);
%             sensor_resultsDir       = fullfile(sensor_dataDir,subject);
%             
%             load(fullfile(sensor_resultsDir,['data_meg_prep_',test_name]));
%             grad_ICA_cleaned        = data_meg_prep.grad;
%             
%             disp('***********************************')
%             disp(['processing ' subject,'_',test_name]);
%             disp('***********************************')
%             
%             file_name               = cell2mat(allFiles_tone_pantev((iSubject-1)+1));
%  
%             
%             % output data directory
%             source_resultsDir = fullfile(source_SubjectDir,'MEG','SUMA');
%             if ~isdir(source_resultsDir)
%                 mkdir(source_resultsDir); % make directory if it doesn't exist
%             end
%             
%             if exist(fullfile(source_resultsDir,'mri_ctf.mat'),'file')==2
%                 load(fullfile(source_resultsDir,'mri_ctf'));
%             else
%                 mriDir = fullfile(source_SubjectDir,'bem','SUMA');
%                 mri = ft_read_mri(fullfile(mriDir,'T1.nii')); % already aligned to Tal space in Freesurfer
%                 
%                 % using reslice here to bring the mri to fieldtrip view
%                 cfg = [];
%                 cfg.dim  = [256 256 256];
%                 mri_rs = ft_volumereslice(cfg, mri);
%                 mri_rs = ft_convert_units(mri_rs, 'cm');
%                 
%                 % ft_sourceplot([],mri_rs);
%                 
%                 % realign to the MEG sensor space using the fiducials
%                 cfg = [];
%                 cfg.method  = 'interactive';
%                 mri_ctf = ft_volumerealign(cfg, mri_rs);
%                 save(fullfile(source_resultsDir,'mri_ctf.mat'), 'mri_ctf');
%                 
%             end
%             % ft_sourceplot([],mri_ctf);
%             
%             if exist(fullfile(source_resultsDir,'sourcespace_smoothwm_SUMA.mat'),'file')==2
%                 load(fullfile(source_resultsDir,'sourcespace_smoothwm_SUMA.mat'));
%             else
%                 
%                 % read in the reduced standard mesh file processed from SUMA
%                 file_LH = fullfile(source_SubjectDir,'bem','SUMA','std.10.lh.smoothwm.gii');
%                 file_RH = fullfile(source_SubjectDir,'bem','SUMA','std.10.rh.smoothwm.gii');
%                 if exist(file_LH,'file')==2
%                     
%                     sourcespace_smoothwm_SUMA = ft_read_headshape({file_LH file_RH }, 'format', 'gifti');
%                 else
%                     load(fullfile(rootpath2,'utilities','SUMA_sourcespace')); % load the template SUMA sourcespace
%                     file_LH = fullfile(SubjectDir,'bem','SUMA','std.10.lh.smoothwm.asc');
%                     file_RH = fullfile(SubjectDir,'bem','SUMA','std.10.rh.smoothwm.asc');
%                     [S, v, f] = read_asc(file_LH);
%                     sourcespace_smoothwm_SUMA = SUMA_sourcespace;
%                     sourcespace_smoothwm_SUMA.pnt = v(:,1:3);
%                     sourcespace_S_SUMA.tri = f(:,1:3);
%                     [S, v, f] = read_asc(file_RH);
%                     sourcespace_smoothwm_SUMA.pnt = [sourcespace_smoothwm_SUMA.pnt; v(:,1:3)];
%                     sourcespace_smoothwm_SUMA.tri = [sourcespace_smoothwm_SUMA.tri; f(:,1:3)+S(2)];
%                     
%                 end
%                 
%                 % trisurf(sourcespace_S_SUMA.tri,sourcespace_S_SUMA.pnt(:,1),sourcespace_S_SUMA.pnt(:,2),sourcespace_S_SUMA.pnt(:,3));
%                 
%                 sourcespace_smoothwm_SUMA = ft_convert_units(sourcespace_smoothwm_SUMA, 'cm');
%                 
%                 T = mri_ctf.transform*inv(mri_ctf.transformorig); % note the transformation difference between MNE and SUMA
%                 sourcespace_smoothwm_SUMA = ft_transform_geometry(T, sourcespace_smoothwm_SUMA);
%                 
%                 if exist(fullfile(source_resultsDir,'sourcespace_smoothwm_SUMA.mat'),'file')==0
%                     save(fullfile(source_resultsDir,'sourcespace_smoothwm_SUMA.mat'), 'sourcespace_smoothwm_SUMA');
%                     save(fullfile(source_resultsDir,'transformationM.mat'), 'T');
%                 end
%                 
%                 if exist(fullfile(source_resultsDir,'transformationM.mat'),'file')==0
%                     save(fullfile(source_resultsDir,'transformationM.mat'), 'T');
%                 end
%             end
%             
%             % create head model using single shell
%             if exist(fullfile(source_resultsDir,'hdm.mat'),'file')==2
%                 load(fullfile(source_resultsDir,'hdm.mat'));
%             else
%                 
%                 cfg           = [];
%                 cfg.method    = 'singleshell';
%                 hdm           = ft_prepare_headmodel(cfg,sourcespace_smoothwm_SUMA);
%                 save(fullfile(source_resultsDir,'hdm.mat'), 'hdm');
%                 
%             end
%             
%             
% %             figure
% %             hold on;
% %             ft_plot_vol(hdm, 'facecolor', 'none');alpha 0.5;
% %             ft_plot_mesh(sourcespace_smoothwm_SUMA, 'edgecolor', 'none'); camlight
% %             ft_plot_mesh(sourcespace_smoothwm_SUMA.pos,'vertexcolor', 'r'); camlight
% %             title(allSubjects_parsing{iSubject});
% %             hold off
%             
%             %%
%             if exist(fullfile(source_resultsDir,'grad_realigned.mat'),'file')==2
%                 load(fullfile(source_resultsDir,'grad_realigned.mat'));
%             else
%             
%                 sfp                 = ft_read_headshape (fullfile(raw_SubjectdataDir,[file_name(1:end-7),'.sfp']),'fileformat','besa_sfp');
%                 sfp                 = ft_convert_units(sfp, 'cm');
%                 
%                 %figure;                
%                 %ft_plot_mesh(hdm.bnd(1), 'edgecolor','none','facealpha',0.8,'facecolor',[0.6 0.6 0.8]); % head surface (scalp)
%                 %hold on;
%                 %ft_plot_mesh(sfp,'style', 'sk');  % surface points + fiducial in BESA
%                 %ft_plot_sens(grad_ICA_cleaned,'style', 'g*');  % sensor location: co-registered with BESA
%                 %legend ('head model','BESA sensor position');
%                 
%                 % get fiducials from SFP (BESA)
%                 nas_sfp             = sfp.fid.pos(strcmp(sfp.fid.label,'fidnz'),:);
%                 lpa_sfp             = sfp.fid.pos(strcmp(sfp.fid.label,'fidt9'),:);
%                 rpa_sfp             = sfp.fid.pos(strcmp(sfp.fid.label,'fidt10'),:);
%                 
%                 % get fiducials from MRI
%                 nas_mri             = ft_warp_apply(mri_ctf.transform, mri_ctf.cfg.fiducial.nas, 'homogenous');
%                 lpa_mri             = ft_warp_apply(mri_ctf.transform, mri_ctf.cfg.fiducial.lpa, 'homogenous');
%                 rpa_mri             = ft_warp_apply(mri_ctf.transform, mri_ctf.cfg.fiducial.rpa, 'homogenous');
%                 
%                 BESA2ctf            = ft_headcoordinates(nas_sfp, lpa_sfp, rpa_sfp,'ctf');
%                 %%
%                 nas_mri_T           = ft_warp_apply(BESA2ctf, nas_sfp, 'homogeneous');
%                 lpa_mri_T           = ft_warp_apply(BESA2ctf, lpa_sfp, 'homogeneous');
%                 rpa_mri_T           = ft_warp_apply(BESA2ctf, rpa_sfp, 'homogeneous');
%                 
%                 dpre  = mean(sqrt(sum(([nas_sfp;lpa_sfp;rpa_sfp] - [nas_mri; lpa_mri; rpa_mri]).^2, 2)));
%                 
%                 dpost = mean(sqrt(sum(([nas_mri_T; lpa_mri_T; rpa_mri_T] - [nas_mri; lpa_mri; rpa_mri]).^2, 2)));
%                 
%                 fprintf('mean distance between fiducials prior to realignment %f, after realignment %f\n', dpre, dpost);
%                 %%
%                 
%                 grad_realigned      = ft_transform_sens(BESA2ctf, grad_ICA_cleaned);
%             end
%             
%             %figure;
%             %ft_plot_mesh(hdm.bnd(1), 'edgecolor','none','facealpha',0.8,'facecolor',[0.6 0.6 0.8]); % head surface (scalp)
%             %hold on;
%             %ft_plot_mesh(sfp,'style', 'sk');  % surface points + fiducial in BESA
%             %ft_plot_sens(grad_realigned,'style', 'g*');  % electrodes
%             %legend ('head model','sensor position - realigned')
%                   
%             
%             if exist(fullfile(source_resultsDir,['leadfield_',test_name,'.mat']),'file')==2
%                 load(fullfile(source_resultsDir,['leadfield_',test_name]));
%             else
%                 cfg                         = [];
%                 cfg.grad                    = grad_realigned;
%                 cfg.grid.pos                = sourcespace_smoothwm_SUMA.pos;              % source points
%                 cfg.grid.inside             = 1:size(sourcespace_smoothwm_SUMA.pos,1); % all source points are inside of the brain
%                 cfg.headmodel               = hdm; % newer fieldtrip version
%                 cfg.normalize               ='yes';
%                 leadfield                  = ft_prepare_leadfield(cfg);
%                 save(fullfile(source_resultsDir,['leadfield_',test_name,'.mat']), 'leadfield');
%             end
%             
%             if exist(fullfile(source_resultsDir,['grad_realigned_',test_name,'.mat']),'file')==0
%                 save(fullfile(source_resultsDir,['grad_realigned_',test_name,'.mat']), 'grad_realigned');
%             end
%             
%             figure
%             hold on     % plot all objects in one figure
%             ft_plot_vol(hdm, 'edgecolor', 'none'); alpha 0.8; % make the headmodel surface transparent
%             ft_plot_mesh(leadfield.pos,'vertexcolor','b');
%             title(allSubjects_parsing{iSubject},'interpreter','none');
%             ft_plot_sens(grad_realigned,'style', 'g*');hold off
%             view([0 -90 0])
%             %create_SUMA_surf_curv(subject);
%             %get_SUMA_cortex_ind_for_atlas(rootpath,subject);
%         end
        
        case {'masanori'}
                        
            for iCondition = 1%:length(allConditions_tone_masa)
                condition = allConditions_tone_masa{iCondition};
                
                for iSubject = 2%1:length(allSubjects_tone_masa)
                    subject                 = allSubjects_tone_masa{iSubject};
                    raw_SubjectdataDir      = fullfile(raw_dataDir_MEG,subject);
                    source_SubjectDir       = fullfile(source_dataDir,[subject '-FS']);
                    sensor_resultsDir       = fullfile(sensor_dataDir,subject);
                    
                    load(fullfile(sensor_resultsDir,['data_meg_prep_',test_name,'_',condition]));
                    grad_ICA_cleaned        = data_meg_prep.grad;
                    
                    disp('***********************************')
                    disp(['processing ' subject,'_',test_name,'_',condition]);
                    disp('***********************************')
                    
                    %file_name               = cell2mat(allFiles_tone_masa((iSubject-1)*2+1));
                    
                    if strcmp(condition,'B1')
                        file_name               = cell2mat(allFiles_tone_masa((iSubject-1)*2+1));
                    elseif strcmp(condition,'B2')
                        file_name               = cell2mat(allFiles_tone_masa((iSubject-1)*2+2));
                    end
                                        
                    % output data directory
                    source_resultsDir = fullfile(source_SubjectDir,'MEG','SUMA');
                    if ~isdir(source_resultsDir)
                        mkdir(source_resultsDir); % make directory if it doesn't exist
                    end
                    
                    if exist(fullfile(source_resultsDir,'mri_ctf.mat'),'file')==2
                        load(fullfile(source_resultsDir,'mri_ctf'));
                    else
                        mriDir = fullfile(source_SubjectDir,'bem','SUMA');
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
                    
                    if exist(fullfile(source_resultsDir,'sourcespace_smoothwm_SUMA.mat'),'file')==2
                        load(fullfile(source_resultsDir,'sourcespace_smoothwm_SUMA.mat'));
                    else
                        
                        % read in the reduced standard mesh file processed from SUMA
                        file_LH = fullfile(source_SubjectDir,'bem','SUMA','std.10.lh.smoothwm.gii');
                        file_RH = fullfile(source_SubjectDir,'bem','SUMA','std.10.rh.smoothwm.gii');
                        if exist(file_LH,'file')==2
                            
                            sourcespace_smoothwm_SUMA = ft_read_headshape({file_LH file_RH }, 'format', 'gifti');
                        else
                            load(fullfile(rootpath2,'utilities','SUMA_sourcespace')); % load the template SUMA sourcespace
                            file_LH = fullfile(SubjectDir,'bem','SUMA','std.10.lh.smoothwm.asc');
                            file_RH = fullfile(SubjectDir,'bem','SUMA','std.10.rh.smoothwm.asc');
                            [S, v, f] = read_asc(file_LH);
                            sourcespace_smoothwm_SUMA = SUMA_sourcespace;
                            sourcespace_smoothwm_SUMA.pnt = v(:,1:3);
                            sourcespace_S_SUMA.tri = f(:,1:3);
                            [S, v, f] = read_asc(file_RH);
                            sourcespace_smoothwm_SUMA.pnt = [sourcespace_smoothwm_SUMA.pnt; v(:,1:3)];
                            sourcespace_smoothwm_SUMA.tri = [sourcespace_smoothwm_SUMA.tri; f(:,1:3)+S(2)];
                            
                        end
                        
                        % trisurf(sourcespace_S_SUMA.tri,sourcespace_S_SUMA.pnt(:,1),sourcespace_S_SUMA.pnt(:,2),sourcespace_S_SUMA.pnt(:,3));
                        
                        sourcespace_smoothwm_SUMA = ft_convert_units(sourcespace_smoothwm_SUMA, 'cm');
                        
                        T = mri_ctf.transform*inv(mri_ctf.transformorig); % note the transformation difference between MNE and SUMA
                        sourcespace_smoothwm_SUMA = ft_transform_geometry(T, sourcespace_smoothwm_SUMA);
                        
                        if exist(fullfile(source_resultsDir,'sourcespace_smoothwm_SUMA.mat'),'file')==0
                            save(fullfile(source_resultsDir,'sourcespace_smoothwm_SUMA.mat'), 'sourcespace_smoothwm_SUMA');
                            save(fullfile(source_resultsDir,'transformationM.mat'), 'T');
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
                        hdm           = ft_prepare_headmodel(cfg,sourcespace_smoothwm_SUMA);
                        save(fullfile(source_resultsDir,'hdm.mat'), 'hdm');
                        
                    end
                    
                    
                    %                 figure
                    %                 hold on;
                    %                 ft_plot_vol(hdm, 'facecolor', 'none');alpha 0.5;
                    %                 ft_plot_mesh(sourcespace_smoothwm_SUMA, 'edgecolor', 'none'); camlight
                    %                 ft_plot_mesh(sourcespace_smoothwm_SUMA.pos,'vertexcolor', 'r'); camlight
                    %                 title(allSubjects_tone_masa{iSubject},'interpreter','none');
                    %                 hold off
                    
                    %%
                    if exist(fullfile(source_resultsDir,'grad_realigned.mat'),'file')==2
                        load(fullfile(source_resultsDir,'grad_realigned.mat'));
                    else
                        
                        if strcmp(condition,'B1')
                            sfp                 = ft_read_headshape (fullfile(raw_SubjectdataDir,[file_name(1:end-5),'.sfp']),'fileformat','besa_sfp');
                        elseif strcmp(condition,'B2')
                            sfp                 = ft_read_headshape (fullfile(raw_SubjectdataDir,[file_name(1:end-8),'.sfp']),'fileformat','besa_sfp');
                        end
                        sfp                 = ft_convert_units(sfp, 'cm');
                        
                        figure;
                        ft_plot_mesh(hdm.bnd(1), 'edgecolor','none','facealpha',0.8,'facecolor',[0.6 0.6 0.8]); % head surface (scalp)
                        hold on;
                        %ft_plot_mesh(sfp,'style', 'sk');  % surface points + fiducial in BESA
                        ft_plot_sens(grad_ICA_cleaned,'style', 'g*');  % sensor location: co-registered with BESA
                        legend ('head model','BESA sensor position');
                        
                        % get fiducials from SFP (BESA)
                        nas_sfp             = sfp.fid.pos(strcmp(sfp.fid.label,'fidnz'),:);
                        lpa_sfp             = sfp.fid.pos(strcmp(sfp.fid.label,'fidt9'),:);
                        rpa_sfp             = sfp.fid.pos(strcmp(sfp.fid.label,'fidt10'),:);
                        
                        % get fiducials from MRI
                        nas_mri             = ft_warp_apply(mri_ctf.transform, mri_ctf.cfg.fiducial.nas, 'homogenous');
                        lpa_mri             = ft_warp_apply(mri_ctf.transform, mri_ctf.cfg.fiducial.lpa, 'homogenous');
                        rpa_mri             = ft_warp_apply(mri_ctf.transform, mri_ctf.cfg.fiducial.rpa, 'homogenous');
                        
                        BESA2ctf            = ft_headcoordinates(nas_sfp, lpa_sfp, rpa_sfp,'ctf');
                        %%
                        nas_mri_T           = ft_warp_apply(BESA2ctf, nas_sfp, 'homogeneous');
                        lpa_mri_T           = ft_warp_apply(BESA2ctf, lpa_sfp, 'homogeneous');
                        rpa_mri_T           = ft_warp_apply(BESA2ctf, rpa_sfp, 'homogeneous');
                        
                        dpre  = mean(sqrt(sum(([nas_sfp;lpa_sfp;rpa_sfp] - [nas_mri; lpa_mri; rpa_mri]).^2, 2)));
                        
                        dpost = mean(sqrt(sum(([nas_mri_T; lpa_mri_T; rpa_mri_T] - [nas_mri; lpa_mri; rpa_mri]).^2, 2)));
                        
                        fprintf('mean distance between fiducials prior to realignment %f, after realignment %f\n', dpre, dpost);
                        %%
                        
                        grad_realigned      = ft_transform_sens(BESA2ctf, grad_ICA_cleaned);
                    end
                    
                    figure;
                    ft_plot_mesh(hdm.bnd(1), 'edgecolor','none','facealpha',0.8,'facecolor',[0.6 0.6 0.8]); % head surface (scalp)
                    hold on;
                    %ft_plot_mesh(sfp,'style', 'sk');  % surface points + fiducial in BESA
                    ft_plot_sens(grad_realigned,'style', 'go');  % electrodes
                    legend ('head model','sensor position - realigned')
                    
                    
                    if exist(fullfile(source_resultsDir,['leadfield_',test_name,'_',condition,'.mat']),'file')==2
                        load(fullfile(source_resultsDir,['leadfield_',test_name,'_',condition]));
                    else
                        cfg                         = [];
                        cfg.grad                    = grad_realigned;
                        cfg.grid.pos                = sourcespace_smoothwm_SUMA.pos;              % source points
                        cfg.grid.inside             = 1:size(sourcespace_smoothwm_SUMA.pos,1); % all source points are inside of the brain
                        cfg.headmodel               = hdm; % newer fieldtrip version
                        cfg.normalize               ='yes';
                        leadfield                   = ft_prepare_leadfield(cfg);
                        save(fullfile(source_resultsDir,['leadfield_',test_name,'.mat']), 'leadfield');
                    end
                    
                    if exist(fullfile(source_resultsDir,['grad_realigned_',test_name,'.mat']),'file')==0
                        save(fullfile(source_resultsDir,['grad_realigned_',test_name,'.mat']), 'grad_realigned');
                    end
                    
                    figure
                    hold on     % plot all objects in one figure
                    ft_plot_vol(hdm, 'edgecolor', 'none'); alpha 0.8; % make the headmodel surface transparent
                    ft_plot_mesh(leadfield.pos,'vertexcolor','b');
                    title(allSubjects_tone_masa{iSubject},'interpreter','none');
                    ft_plot_sens(grad_realigned,'style', 'go');hold off
                    view([0 -90 0])
                    
                end
            end
        
end