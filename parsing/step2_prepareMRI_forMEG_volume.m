% yiwen 14.07.2016, modified 17.01.17 qmeng
close all
clear
clc

preparation_MEG
%%
switch test_name  
   case {'parsing'}

    for iCondition = 1:length(allConditions_parsing) % parsing
        condition = allConditions_parsing{iCondition};
        for iSubject = 1:length(allSubjects_parsing)
            subject                 = allSubjects_parsing{iSubject};
            raw_SubjectdataDir      = fullfile(raw_dataDir_MEG,subject);
            source_SubjectDir       = fullfile(source_dataDir,[subject '-vol']);
            sensor_resultsDir       = fullfile(sensor_dataDir,subject);
            
            load(fullfile(sensor_resultsDir,['data_meg_prep_',test_name,'_',condition]));
            grad_ICA_cleaned        = data_meg_prep.grad;
            
                disp('*******************************')
                disp(['processing ' subject,'_', test_name,'_', condition]);
                disp('*******************************')
                
                switch test_group
                    case {'English'}
            
                        if strcmp(condition,'B1')
                            file_name               = cell2mat(allFiles_parsing((iSubject-1)*4+1));
                        elseif strcmp(condition,'B2')
                            file_name               = cell2mat(allFiles_parsing((iSubject-1)*4+2));
                        elseif strcmp(condition,'B3')
                            file_name               = cell2mat(allFiles_parsing((iSubject-1)*4+3));
                        elseif strcmp(condition,'B4')
                            file_name               = cell2mat(allFiles_parsing((iSubject-1)*4+4));
                        end         
                        
                    case {'Chinese'}                       
                        % define trials and read in raw MEG data
                        if strcmp(condition,'B1')
                            file_name               = cell2mat(allFiles_parsing((iSubject-1)*2+1));
                        elseif strcmp(condition,'B2')
                            file_name               = cell2mat(allFiles_parsing((iSubject-1)*2+2));
                        end
                end
            
            % output data directory
            source_resultsDir = fullfile(source_SubjectDir);
            if ~isdir(source_resultsDir)
                mkdir(source_resultsDir); % make directory if it doesn't exist
            end
            
            if exist(fullfile(source_resultsDir,'mri_ctf.mat'),'file')==2
                load(fullfile(source_resultsDir,'mri_ctf'));
            else
                mriDir = fullfile(raw_dataDir_MRI,subject,'DICOM');
                
                if exist(fullfile(mriDir,'IM000001'),'file')==2
                    
                    mri = ft_read_mri(fullfile(mriDir,'IM000001')); %
                    
                elseif exist(fullfile(mriDir,'MR000001'),'file')==2
                    
                    mri = ft_read_mri(fullfile(mriDir,'MR000001')); %
                    
                end
                
                
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
             %ft_sourceplot([],mri_ctf);
            
            if exist(fullfile(source_resultsDir,'mri_segmented.mat'),'file')==2
                load(fullfile(source_resultsDir,'mri_segmented.mat'));
            else
                cfg                         = [];
                mri_segmented               = ft_volumesegment(cfg, mri_ctf);
                save (fullfile(source_resultsDir,'mri_segmented.mat'), 'mri_segmented');
              
            end
            
            % create head model using single shell
            if exist(fullfile(source_resultsDir,'hdm.mat'),'file')==2
                load(fullfile(source_resultsDir,'hdm.mat'));
            else
                
                cfg           = [];
                cfg.method    = 'singleshell';
                hdm           = ft_prepare_headmodel(cfg,mri_segmented);
                save(fullfile(source_resultsDir,'hdm.mat'), 'hdm');
                
            end
            
            
%             figure
%             hold on;
%             ft_plot_vol(hdm, 'facecolor', 'none');alpha 0.5;
%             title(allSubjects_parsing{iSubject});
%             hold off
            
            %%
            sfp                 = ft_read_headshape (fullfile(raw_SubjectdataDir,[file_name(1:end-3),'.sfp']),'fileformat','besa_sfp'); % e.g. getrid off _B1
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
            
            if exist(fullfile(source_resultsDir,['grad_realigned_',test_name,'_',condition,'.mat']),'file')==0
                save(fullfile(source_resultsDir,['grad_realigned_',test_name,'_',condition,'.mat']), 'grad_realigned');
            end
            
            %figure;
            %ft_plot_mesh(hdm.bnd(1), 'edgecolor','none','facealpha',0.8,'facecolor',[0.6 0.6 0.8]); % head surface (scalp)
            %hold on;
            %ft_plot_mesh(sfp,'style', 'sk');  % surface points + fiducial in BESA
            %ft_plot_sens(grad_realigned,'style', 'g*');  % electrodes
            %legend ('head model','sensor position - realigned')
                  
            
            if exist(fullfile(source_resultsDir,['leadfield_',test_name,'_',condition,'.mat']),'file')==2
                load(fullfile(source_resultsDir,['leadfield_',test_name,'_',condition]));
            else
                cfg                         = [];
                cfg.grad                    = grad_realigned;
                cfg.headmodel               = hdm; % newer fieldtrip version
                %cfg.normalize               ='yes';
                leadfield                   = ft_prepare_leadfield(cfg);
                save(fullfile(source_resultsDir,['leadfield_',test_name,'_',condition,'.mat']), 'leadfield');
            end
           
            figure
            hold on     % plot all objects in one figure
            ft_plot_vol(hdm, 'edgecolor', 'none'); alpha 0.8; % make the headmodel surface transparent
            ft_plot_mesh(leadfield.pos,'vertexcolor','b');
            title([allSubjects_parsing{iSubject},'_', condition],'interpreter','none');
            ft_plot_sens(grad_realigned,'style', 'g*');hold off
            view([0 -90 0])
            %create_SUMA_surf_curv(subject);
            %get_SUMA_cortex_ind_for_atlas(rootpath,subject);
        end
%         
    end
%             
end