%% source analysis
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

%         for iCondition = 1:length(allConditions_parsing)
%             condition = allConditions_parsing{iCondition};
%             for iSubject = 3%1:length(allSubjects_parsing)
%                 subject = allSubjects_parsing{iSubject};
%                 
%                 source_SubjectDir           = fullfile(source_dataDir,[subject '-FS']);
%                 source_resultsDir           = fullfile(source_SubjectDir,'MEG','SUMA');
%                 sensor_resultsDir           = fullfile(sensor_dataDir,subject);
%                 
%                 disp('*******************************')
%                 disp(['processing ' subject,'_', test_name,'_', condition]);
%                 disp('*******************************')
%                 
%                 load (fullfile(source_resultsDir,'hdm.mat'));
%                 load (fullfile(source_resultsDir,'sourcespace_smoothwm_SUMA.mat'));
%                 load (fullfile(source_resultsDir,['leadfield_',test_name,'_',condition,'.mat']));
%                 load (fullfile(sensor_resultsDir,['data_meg_prep_',test_name,'_',condition,'.mat']));
%                 
%                 cfg                     = [];
%                 cfg.method              = 'mtmfft';
%                 cfg.output              = 'powandcsd';
%                 cfg.foilim              = [1 5];
%                 %cfg.tapsmofrq          = 4;
%                 cfg.taper               = 'hanning';
%                 cfg.channel             = 'meg' ;
%                 data_meg_spowcsd        = ft_freqanalysis(cfg, data_meg_prep);
%                 
%                 % source analysis
%                 cfg                     = [];
%                 cfg.channel             = 'meg';
%                 cfg.method              = 'dics';
%                 cfg.frequency           = 4;
%                 cfg.headmodel           = hdm;
%                 cfg.grid                = leadfield;
%                 cfg.dics.lambda         = '5%';
%                 cfg.dics.keepfilter     = 'yes';
%                 cfg.dics.fixedori       = 'yes';
%                 cfg.dics.realfilter     = 'yes';
%                 cfg.dics.projectnoise   = 'yes';
%                 source_meg              = ft_sourceanalysis(cfg, data_meg_spowcsd);
%                 
%                 %
%                 bnd.pos                 = sourcespace_smoothwm_SUMA.pos;
%                 bnd.tri                 = sourcespace_smoothwm_SUMA.tri;
%                 %m                       = source_meg.avg.pow(:,1); % no time points, all segment
%                 m                       =  source_meg.avg.pow ./ source_meg.avg.noise;% no time points, all segment
%                 ft_plot_mesh(bnd, 'vertexcolor', m);
%                 
%                 sourceNAI               = source_meg;
%                 sourceNAI.avg.pow       = source_meg.avg.pow ./ source_meg.avg.noise;
%                 sourceNAI.tri           = sourcespace_smoothwm_SUMA.tri;
%                 %source_meg.tri           = sourcespace_smoothwm_SUMA.tri;
%                 
%                 cfg = [];
%                 cfg.method              = 'surface';
%                 cfg.funparameter        = 'pow';
%                 cfg.maskparameter       = 'mask';
%                 
%                 ft_sourceplot(cfg,sourceNAI);
% %                 ft_sourceplot(cfg,source_meg);
%                 pause
%             end
%         end
        
%     case {'pantev'}
%             
%         
%         for iSubject = 1:length(allSubjects_tone_pantev)
%             subject = allSubjects_tone_pantev{iSubject};
%             
%             source_SubjectDir           = fullfile(source_dataDir,[subject '-FS']);
%             source_resultsDir           = fullfile(source_SubjectDir,'MEG','SUMA');
%             sensor_resultsDir           = fullfile(sensor_dataDir,subject);
%             
%             disp('*************************')
%             disp(['source processing ', test_name,'_', subject]);
%             disp('*************************')
%             
%             load (fullfile(source_resultsDir,'hdm.mat'));
%             load (fullfile(source_resultsDir,'sourcespace_smoothwm_SUMA.mat'));
%             load (fullfile(source_resultsDir,['leadfield_',test_name,'.mat']));
%             %load (fullfile(sensor_resultsDir,['data_meg_prep_',test_name,'.mat']));
%             load (fullfile(sensor_resultsDir,['data_meg_ave_',test_name,'.mat']));
%             load (fullfile(sensor_resultsDir,['layout_meg_',test_name,'.mat'])); 
%                     
% %             cfg                             = [];
% %             cfg.covariance                  = 'yes';
% %             cfg.covariancewindow            = [-inf 0];
% %             data_meg_ave                    = ft_timelockanalysis(cfg, data_meg_prep);
%             
%             figure
%             plot(data_meg_ave.time,data_meg_ave.avg)
%             
%             figure
%             cfg            = [];
%             cfg.showlabels = 'yes';
%             cfg.fontsize   = 6;
%             cfg.layout     = layout_meg;
%             
%             ft_multiplotER(cfg, data_meg_ave);
%             
%             
%             cfg                         = [];
%             cfg.method                  = 'mne';
%             cfg.grid                    = leadfield;
%             cfg.headmodel               = hdm;
%             cfg.mne.prewhiten           = 'yes';
%             cfg.mne.lambda              = 3;
%             cfg.mne.scalesourcecov      = 'yes';
%             source_meg                 = ft_sourceanalysis(cfg,data_meg_ave);
%             
%             bnd.pos                     = sourcespace_smoothwm_SUMA.pos;
%             bnd.tri                     = sourcespace_smoothwm_SUMA.tri;
%             
%             for t_index = 381:5:411
%                 
%                 %pnt_index                   = (t_index/1000)*1000 + 100; 
%                 m                           = source_meg.avg.pow(:,t_index); % time points
%                 figure
%                 ft_plot_mesh(bnd, 'vertexcolor', m);
%                 colorbar
%                 title(sprintf('%s: %dms after stimulus onset',subject, round(source_meg.time(t_index)*1000)),'interpreter','none');
%                 pause
%             end
%             
% 
%         end
        
        case {'masanori'}
            
            for iCondition = 1%:length(allConditions_tone_masa)
                condition = allConditions_tone_masa{iCondition};
                            
                for iSubject = 2%1:length(allSubjects_tone_masa)
                    subject = allSubjects_tone_masa{iSubject};
                    
                    source_SubjectDir           = fullfile(source_dataDir,[subject '-FS']);
                    source_resultsDir           = fullfile(source_SubjectDir,'MEG','SUMA');
                    sensor_resultsDir           = fullfile(sensor_dataDir,subject);
                    
                    disp('***************************************')
                    disp(['source processing ',subject,'_',test_name,'_',condition]);
                    disp('***************************************')
                    
                    load (fullfile(source_resultsDir,'hdm.mat'));
                    load (fullfile(source_resultsDir,'sourcespace_smoothwm_SUMA.mat'));
                    load (fullfile(source_resultsDir,['leadfield_',test_name,'.mat']));
                    %load (fullfile(sensor_resultsDir,['data_meg_prep_',test_name,'.mat']));
                    load (fullfile(sensor_resultsDir,['data_meg_ave_',test_name,'_',condition,'.mat']));
                    load (fullfile(sensor_resultsDir,['layout_meg_',test_name,'_',condition,'.mat']));
                    
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
                    source_meg                  = ft_sourceanalysis(cfg,data_meg_ave);
                    
                    bnd.pos                     = sourcespace_smoothwm_SUMA.pos;
                    bnd.tri                     = sourcespace_smoothwm_SUMA.tri;
                    
                    for t_index = 496:5:507
                        
                        %pnt_index                   = (t_index/1000)*1000 + 100;
                        m                           = source_meg.avg.pow(:,t_index); % time points
                        figure
                        ft_plot_mesh(bnd, 'vertexcolor', m);
                        colorbar
                        title(sprintf('%s_%s %dms after stimulus onset',subject,condition,round(source_meg.time(t_index)*1000)),'interpreter','none');
                        pause
                    end
                    
                end
            end

end