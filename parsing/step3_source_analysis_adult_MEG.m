%% source analysis
close all
clear
clc

preparation_MEG
%%
switch test_name
    
    case {'parsing'}
        
        for iSubject = 1:length(allSubjects_parsing)
            subject = allSubjects_parsing{iSubject};
            
            for iCondition = 1:length(allConditions_parsing)
                condition = allConditions_parsing{iCondition};
                                
                source_SubjectDir           = fullfile(source_dataDir,[subject '-FS']);
                source_resultsDir           = fullfile(source_SubjectDir,'MEG','SUMA');
                sensor_resultsDir           = fullfile(sensor_dataDir,subject);
                
                switch use_ICA
                    
                    case {'Y'}
                        load (fullfile(sensor_resultsDir,['data_meg_prep_',test_name,'_',condition,'_ICA.mat']));
                        
                    case {'N'}
                        load (fullfile(sensor_resultsDir,['data_meg_prep_',test_name,'_',condition,'.mat']));
                end
                
                load (fullfile(source_resultsDir,'hdm.mat'));
                load (fullfile(source_resultsDir,'sourcespace_smoothwm_SUMA.mat'));
                load (fullfile(source_resultsDir,['leadfield_',test_name,'_',condition,'.mat']));
                                
                %eval (['data_meg_prep_',test_name,'_',subject,'_',condition,' = data_meg_prep;']);
                               
                disp('*******************************')
                disp(['processing ' subject,'_', test_name,'_', condition]);
                disp('*******************************')
                               
                if exist(fullfile(source_resultsDir,['data_meg_powcsd_',test_name,'_',condition,'.mat']),'file')==2
                    load (fullfile(source_resultsDir,['data_meg_powcsd_',test_name,'_',condition,'.mat']))
                    %eval (['data_meg_powcsd_',test_name,'_',subject,'_',condition,' = data_meg_powcsd;']);                   
                else                    
                    cfg                     = [];
                    cfg.method              = 'mtmfft';
                    cfg.output              = 'powandcsd';
                    cfg.foilim              = [f_source(1) f_source(1)]; %[3.12 1.56 0.78]
                    cfg.taper               = 'hanning';
                    %cfg.tapsmofrq           = 4;
                    cfg.channel             = 'meg' ;
                    data_meg_powcsd         = ft_freqanalysis(cfg, data_meg_prep);
                    save(fullfile(source_resultsDir,['data_meg_powcsd_',test_name,'_',condition,'.mat']), 'data_meg_powcsd');
                end
                

                if exist(fullfile(source_resultsDir,['data_meg_source_nocon_',test_name,'_',condition,'.mat']),'file')==2                 
                    load (fullfile(source_resultsDir,['data_meg_source_nocon_',test_name,'_',condition,'.mat']))
                else                   
                    cfg                     = [];
                    cfg.channel             = 'meg';
                    cfg.method              = 'dics';
                    cfg.frequency           = f_source(1);%[3.12 1.56  0.78]
                    cfg.grid                = leadfield;
                    cfg.headmodel           = hdm;
                    cfg.dics.projectnoise   = 'yes';
                    cfg.dics.lambda         = '5%';
                    %cfg.dics.lambda         = 0;
                    data_meg_source_nocon        = ft_sourceanalysis(cfg, data_meg_powcsd);                   
                    save(fullfile(source_resultsDir,['data_meg_source_nocon_',test_name,'_',condition,'.mat']), 'data_meg_source_nocon');
                end
                
                
                if exist(fullfile(source_resultsDir,['data_meg_source_NAI_',test_name,'_',condition,'.mat']),'file')==2
                    
                    load (fullfile(source_resultsDir,['data_meg_source_NAI_',test_name,'_',condition,'.mat']))
                else
                    disp ('hahaha')
                    data_meg_source_NAI                 = data_meg_source_nocon;
                    data_meg_source_NAI.avg.pow         = data_meg_source_nocon.avg.pow ./ data_meg_source_nocon.avg.noise;
                    save(fullfile(source_resultsDir,['data_meg_source_NAI_',test_name,'_',condition,'.mat']), 'data_meg_source_NAI');
 
                    %save(fullfile(source_resultsDir,['sourceNAIInt_',test_name,'_',condition,'.mat']), 'sourceNAIInt')
                end
                
                cfg                                         = [];
                cfg.downsample                              = 2;
                cfg.parameter                               = 'pow';
                sourceNAIInt                                = ft_sourceinterpolate(cfg, data_meg_source_NAI, sourcespace_smoothwm_SUMA);
                
                cfg = [];
                cfg.method         = 'surface';
                cfg.funparameter   = 'pow';
                cfg.maskparameter  = cfg.funparameter;
                cfg.funcolormap    = 'jet';
                cfg.opacitymap     = 'rampup';
                cfg.projmethod     = 'nearest';
                cfg.surffile       = 'sourcespace_smoothwm_SUMA';
                cfg.surfdownsample = 10;
                ft_sourceplot(cfg, sourceNAIInt);
                view ([90 0])
                
%                 figure
%                 bnd.pos                 = sourcespace_smoothwm_SUMA.pos;
%                 bnd.tri                 = sourcespace_smoothwm_SUMA.tri;
%                 m                       = sourceNAI.avg.pow(:,1); % no time points, all segment
%                 ft_plot_mesh(bnd, 'vertexcolor', m);
                
                %                 pause
            end
            
%             %              contrast with another condition
%             cfg                          = [];
%             data_meg_B2_B5_con           = ft_appenddata(cfg, data_meg_prep_parsing_2533_SP_B2, data_meg_prep_parsing_2533_SP_B5);
%             
%             %
% %             cfg                     = [];
% %             cfg.method              = 'mtmfft';
% %             cfg.output              = 'powandcsd';
% %             cfg.foilim              = [0.78 0.78];
% %             cfg.tapsmofrq           = 4;
% %             %cfg.taper               = 'hanning';
% %             cfg.channel             = 'meg' ;
% %             data_meg_B2_powcsd      = ft_freqanalysis(cfg, data_meg_prep_parsing_2533_SP_B2);
%             
% %             cfg                     = [];
% %             cfg.method              = 'mtmfft';
% %             cfg.output              = 'powandcsd';
% %             cfg.foilim              = [0.78 0.78];
% %             cfg.tapsmofrq           = 4;
% %             %cfg.taper               = 'hanning';
% %             cfg.channel             = 'meg' ;
% %             data_meg_B5_powcsd      = ft_freqanalysis(cfg, data_meg_prep_parsing_2533_SP_B5);
%             
%             
%             % %
%             
%             if exist(fullfile(source_resultsDir,'data_meg_B2_B5_con_powcsd.mat'),'file')==2
%                 load (fullfile(source_resultsDir,'data_meg_B2_B5_con_powcsd.mat'))
%             else
%                 cfg                     = [];
%                 cfg.method              = 'mtmfft';
%                 cfg.output              = 'powandcsd';
%                 cfg.foilim              = [0.78 0.78];
%                 cfg.tapsmofrq           = 4;
%                 %cfg.taper               = 'hanning';
%                 cfg.channel             = 'meg' ;
%                 data_meg_B2_B5_con_powcsd    = ft_freqanalysis(cfg, data_meg_B2_B5_con);
%                 save (fullfile(source_resultsDir,'data_meg_B2_B5_con_powcsd.mat'),'data_meg_B2_B5_con_powcsd')
%             end
%             
%             % %
%             % %
%             % source analysis
%             cfg                             = [];
%             cfg.channel                     = 'meg';
%             cfg.method                      = 'dics';
%             cfg.headmodel                   = hdm;
%             cfg.grid                        = leadfield;
%             cfg.frequency                   = 0.78;
%             cfg.dics.lambda                 = '5%';
%             cfg.dics.keepfilter             = 'yes';
%             %cfg.dics.fixedori              = 'yes';
%             %cfg.dics.realfilter            = 'yes';
%             cfg.dics.projectnoise           = 'yes';
%             source_meg_B2_B5_con            = ft_sourceanalysis(cfg, data_meg_B2_B5_con_powcsd);
%             
% %%%%%%%            
%             % project all trials through common spatial filter %
%             cfg                         =[];
%             cfg.method                  = 'dics';
%             cfg.grid                    = leadfield;        % previously computed grid
%             cfg.headmodel               = hdm;              % previously computed volume conduction model
%             cfg.grid.filter             = source_meg_B2_B5_con.avg.filter; % use the common filter computed in the previous step!
%             cfg.frequency               = 0.78;
%             %cfg.rawtrial               = 'yes';      % project each single trial through the filter. Only necessary if you are interested in reconstructing single trial data
%             
%             data_meg_B2_powcsd          =  load (fullfile(source_resultsDir,['data_meg_powcsd_',test_name,'_B2.mat']));
%             data_meg_B5_powcsd          =  load (fullfile(source_resultsDir,['data_meg_powcsd_',test_name,'_B5.mat']));
%             source_meg_B2               = ft_sourceanalysis(cfg, data_meg_B2_powcsd); % contains the source estimates for all trials/both conditions
%             source_meg_B5               = ft_sourceanalysis(cfg, data_meg_B5_powcsd);
%           
%             sourceDiff                  = source_meg_B2;
%             sourceDiff.avg.pow          = (source_meg_B2.avg.pow - source_meg_B5.avg.pow) ./ source_meg_B5.avg.pow;
%             
%             
%             cfg                         = [];
%             cfg.downsample              = 2;
%             cfg.parameter               = 'avg.pow';
%             sourceDiffInt               = ft_sourceinterpolate(cfg, sourceDiff , sourcespace_smoothwm_SUMA);
%             
%             cfg                         = [];
%             cfg.method                  = 'surface';
%             cfg.funparameter            = 'avg.pow';
%             cfg.maskparameter           = cfg.funparameter;
%             cfg.funcolormap             = 'jet';
%             cfg.opacitymap              = 'rampup';
%             cfg.projmethod              = 'nearest';
%             cfg.surffile                = 'sourcespace_smoothwm_SUMA';
%             cfg.surfdownsample          = 10;
%             ft_sourceplot(cfg, sourceDiffInt);
%             view ([90 0])
%             
%             %             cfg = [];
%             %             cfg.method              = 'surface';
%             %             cfg.funparameter        = 'pow';
%             %             cfg.maskparameter       = cfg.funparameter;
%             %             cfg.maskparameter       = 'mask';
%             %
%             %             ft_sourceplot(cfg,sourceNAI);
%             %             ft_sourceplot(cfg,source_meg);
%             %            pause
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
    case {'tone_1000'}
        
        load (fullfile(source_dataDir,'fsaverage','MEG','SUMA','sourcespace_smoothwm_SUMA_T.mat'))
        
        for iSubject = 1:length(allSubjects_tone_1000)
            
            subject                     = allSubjects_tone_1000{iSubject};
            source_SubjectDir           = fullfile(source_dataDir,[subject '-FS']);
            source_resultsDir           = fullfile(source_SubjectDir,'MEG','SUMA');
            sensor_resultsDir           = fullfile(sensor_dataDir,subject);
            
            load (fullfile(source_resultsDir,'hdm.mat'));
            load (fullfile(source_resultsDir,'sourcespace_smoothwm_SUMA.mat'));
            
            switch use_ICA
                
                case {'Y'}
                    
                    disp('*******************************')
                    disp(['processing ' subject,'_', test_name,' with ICA']);
                    disp('*******************************')
                    
                    load (fullfile(sensor_resultsDir,['data_meg_ave_',test_name,'_ICA.mat']));
                    load (fullfile(source_resultsDir,['leadfield_',test_name,'_ICA.mat']));
                    
%                     figure
%                     plot(data_meg_ave.time,data_meg_ave.avg)
%                     title([allSubjects_tone_1000{iSubject},': AEF'],'interpreter','none');
                    
                    if exist(fullfile(source_resultsDir,['data_meg_source_',test_name,'_ICA.mat']),'file')==2
                        disp('*******************************')
                        disp([subject,'_',test_name,': source file exist' ]);
                        disp('*******************************')
                        
                        load (fullfile(source_resultsDir,['data_meg_source_',test_name,'_ICA.mat']))                        
                    else                        
                        cfg                                 = [];
                        cfg.method                          = 'mne';
                        cfg.grid                            = leadfield;
                        cfg.headmodel                       = hdm;
                        cfg.mne.prewhiten                   = 'yes';
                        cfg.mne.lambda                      = 3;
                        cfg.mne.scalesourcecov              = 'yes';
                        data_meg_source_tone_1000           = ft_sourceanalysis(cfg,data_meg_ave);
                        
                        save(fullfile(source_resultsDir,['data_meg_source_',test_name,'_ICA.mat']), 'data_meg_source_tone_1000');
                        
                    end
                    
                    data_meg_source_tone_1000.pos           = sourcespace_smoothwm_SUMA_T.pos;
                    
                    eval(['source_',subject,' = data_meg_source_tone_1000;']);
                    
                case {'N'}
                    
                    disp('*******************************')
                    disp(['processing ' subject,'_', test_name]);
                    disp('*******************************')
                    
                    load (fullfile(sensor_resultsDir,['data_meg_ave_',test_name,'.mat']));
                    load (fullfile(source_resultsDir,['leadfield_',test_name,'.mat']));
                    
%                     figure
%                     plot(data_meg_ave.time,data_meg_ave.avg)
%                     title([allSubjects_tone_1000{iSubject},': AEF'],'interpreter','none');
                    
                    if exist(fullfile(source_resultsDir,['data_meg_source_',test_name,'.mat']),'file')==2
                        
                        disp('*******************************')
                        disp([subject,'_',test_name,': source file exist' ]);
                        disp('*******************************')
                        
                        load (fullfile(source_resultsDir,['data_meg_source_',test_name,'.mat']))
                        
                    else
                        cfg                                 = [];
                        cfg.method                          = 'mne';
                        cfg.grid                            = leadfield;
                        cfg.headmodel                       = hdm;
                        cfg.mne.prewhiten                   = 'yes';
                        cfg.mne.lambda                      = 3;
                        cfg.mne.scalesourcecov              = 'yes';
                        data_meg_source_tone_1000           = ft_sourceanalysis(cfg,data_meg_ave);
                        
                        save(fullfile(source_resultsDir,['data_meg_source_',test_name,'.mat']), 'data_meg_source_tone_1000');
                        
                    end 
                    
                    data_meg_source_tone_1000.pos           = sourcespace_smoothwm_SUMA_T.pos;
                    
                    eval(['source_',subject,' = data_meg_source_tone_1000;']);
            end          
            
            bnd.pos                             = sourcespace_smoothwm_SUMA.pos;
            bnd.tri                             = sourcespace_smoothwm_SUMA.tri;
            
            for t_index = 301%296:5:306
                %pnt_index                      = (t_index/1000)*1000 + 100;
                m                               = data_meg_source_tone_1000.avg.pow(:,t_index); % time points
                figure
                ft_plot_mesh(bnd, 'vertexcolor', m);
                colorbar
                title(sprintf('%s: %dms after stimulus onset',subject, round(data_meg_source_tone_1000.time(t_index)*1000)),'interpreter','none');
            end
%             
%             cfg = [];
%             cfg.projectmom                  = 'yes';
%             source_mov                      = ft_sourcedescriptives(cfg,source_meg_tone_1000);
%             source_mov.tri                  = sourcespace_smoothwm_SUMA.tri;
%             
%             cfg = [];
%             %cfg.maskparameter               = 'avg.pow';
%             cfg.funparameter                = 'pow';
%             ft_sourcemovie(cfg,source_mov);
        end
        
        cfg                                     =[];        
        cfg.parameter                           ='pow';
        
        [grandavg] = ft_sourcegrandaverage(cfg, source_2533_SP, source_2536_PG, source_2537_JW, source_2539_AA, source_2541_KH,...
            source_2542_LB, source_2543_IL, source_2544_JZ, source_2546_CJ, source_2551_DK, source_2555_MK, source_2556_RS,...
            source_2560_TY, source_2569_MN, source_2572_DD, source_2576_JF, source_2578_MM);
                
        bnd_T.pos                               = sourcespace_smoothwm_SUMA_T.pos;
        bnd_T.tri                               = sourcespace_smoothwm_SUMA_T.tri;
        
        for t_index = 296:5:306
            
            m_T                                 = grandavg.pow(:,t_index); % time points
            figure
            ft_plot_mesh(bnd, 'vertexcolor', m_T);
            colorbar
            title(sprintf('Grand average: %dms after stimulus onset', round(grandavg.time(t_index)*1000)),'interpreter','none');
        end
        
                
        %{
    case {'pantev'}
        
        for iSubject = 1:length(allSubjects_tone_pantev)
            subject = allSubjects_tone_pantev{iSubject};
            
            source_SubjectDir           = fullfile(source_dataDir,[subject '-FS']);
            source_resultsDir           = fullfile(source_SubjectDir,'MEG','SUMA');
            sensor_resultsDir           = fullfile(sensor_dataDir,subject);
            
            disp('*******************************')
            disp(['processing ' subject,'_', test_name,'_', condition]);
            disp('*******************************')
            
            load (fullfile(source_resultsDir,'hdm.mat'));
            load (fullfile(source_resultsDir,'sourcespace_smoothwm_SUMA.mat'));
            load (fullfile(source_resultsDir,['leadfield_',test_name,'.mat']));
            %load (fullfile(sensor_resultsDir,['data_meg_prep_',test_name,'.mat']));
            load (fullfile(sensor_resultsDir,['data_meg_ave_',test_name,'.mat']));
            load (fullfile(sensor_resultsDir,['layout_meg_',test_name,'.mat']));
                    
%             cfg                             = [];
%             cfg.covariance                  = 'yes';
%             cfg.covariancewindow            = [-inf 0];
%             data_meg_ave                    = ft_timelockanalysis(cfg, data_meg_prep);
            
            figure
            plot(data_meg_ave.time,data_meg_ave.avg)
            
            figure
            cfg            = [];
            cfg.showlabels = 'yes';
            cfg.fontsize   = 6;
            cfg.layout     = layout_meg;
            
            ft_multiplotER(cfg, data_meg_ave);
            
            
            cfg                         = [];
            cfg.method                  = 'mne';
            cfg.grid                    = leadfield;
            cfg.headmodel               = hdm;
            cfg.mne.prewhiten           = 'yes';
            cfg.mne.lambda              = 3;
            cfg.mne.scalesourcecov      = 'yes';
            source_meg_con1             = ft_sourceanalysis(cfg,data_meg_ave);
            
            bnd.pos                     = sourcespace_smoothwm_SUMA.pos;
            bnd.tri                     = sourcespace_smoothwm_SUMA.tri;
            
            for t_index = 381:5:411
                
                %pnt_index                   = (t_index/1000)*1000 + 100;
                m                           = source_meg_con1.avg.pow(:,t_index); % time points
                figure
                ft_plot_mesh(bnd, 'vertexcolor', m);
                colorbar
                title(sprintf('%s: %dms after stimulus onset',subject, round(source_meg_con1.time(t_index)*1000)),'interpreter','none');
                pause
            end
            

        end
        
        %}
        
        %{
    case {'masanori'}
        
        for iSubject = 1:length(allSubjects_tone_masa)
            subject = allSubjects_tone_masa{iSubject};
            
            source_SubjectDir           = fullfile(source_dataDir,[subject '-FS']);
            source_resultsDir           = fullfile(source_SubjectDir,'MEG','SUMA');
            sensor_resultsDir           = fullfile(sensor_dataDir,subject);
            
            disp('*******************************')
            disp(['processing ' subject,'_', test_name]);
            disp('*******************************')
            
            load (fullfile(source_resultsDir,'hdm.mat'));
            load (fullfile(source_resultsDir,'sourcespace_smoothwm_SUMA.mat'));
            load (fullfile(source_resultsDir,['leadfield_',test_name,'.mat']));
            %load (fullfile(sensor_resultsDir,['data_meg_prep_',test_name,'.mat']));
            load (fullfile(sensor_resultsDir,['data_meg_ave_',test_name,'.mat']));
            load (fullfile(sensor_resultsDir,['layout_meg_',test_name,'.mat']));
                           
            figure
            plot(data_meg_ave.time,data_meg_ave.avg)
            
%             figure
%             cfg            = [];
%             cfg.showlabels = 'yes';
%             cfg.fontsize   = 6;
%             cfg.layout     = layout_meg;
%
%             ft_multiplotER(cfg, data_meg_ave);
            
            cfg                         = [];
            cfg.method                  = 'mne';
            cfg.grid                    = leadfield;
            cfg.headmodel               = hdm;
            cfg.mne.prewhiten           = 'yes';
            cfg.mne.lambda              = 3;
            cfg.mne.scalesourcecov      = 'yes';
            source_meg_con1                 = ft_sourceanalysis(cfg,data_meg_ave);
            
            bnd.pos                     = sourcespace_smoothwm_SUMA.pos;
            bnd.tri                     = sourcespace_smoothwm_SUMA.tri;
            
            for t_index = 396:5:406
                
                %pnt_index                   = (t_index/1000)*1000 + 100;
                m                           = source_meg_con1.avg.pow(:,t_index); % time points
                figure
                ft_plot_mesh(bnd, 'vertexcolor', m);
                colorbar
                title(sprintf('%s: %dms after stimulus onset',subject, round(source_meg_con1.time(t_index)*1000)),'interpreter','none');
                pause
            end
            

        end
        
        %}
        
end