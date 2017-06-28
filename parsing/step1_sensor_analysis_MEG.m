close all
clear
clc

preparation_MEG
%%
switch test_name
    
    case {'parsing'}
        
        for iSubject = 1:length(allSubjects_parsing)            
            subject                         = allSubjects_parsing{iSubject};

            raw_SubjectdataDir              = fullfile(raw_dataDir_MEG,subject);
            sensor_resultsDir               = fullfile(sensor_dataDir,subject);
            
            for iCondition = 1:length(allConditions_parsing)
                condition = allConditions_parsing{iCondition};            
                
                % output data directory
                if ~isdir(sensor_resultsDir)
                    mkdir(sensor_resultsDir); % make directory if it doesn't exist
                end
                
                disp('*******************************')
                disp(['processing ' subject,'_', test_name,'_', condition]);
                disp('*******************************')
                
                switch test_group
                    case {'English'}
                        
                        % define trials and read in raw MEG data
                        if strcmp(condition,'B2')
                            file_name               = cell2mat(allFiles_parsing((iSubject-1)*4+1));
                        elseif strcmp(condition,'B3')
                            file_name               = cell2mat(allFiles_parsing((iSubject-1)*4+2));
                        elseif strcmp(condition,'B4')
                            file_name               = cell2mat(allFiles_parsing((iSubject-1)*4+3));
                        elseif strcmp(condition,'B5')
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
                
                cfg                             = [];
                cfg.dataset                     = fullfile(raw_SubjectdataDir,[file_name,'.con']);
                cfg.continuous                  = 'yes';
                cfg.channel                     = 'all';
                data_meg_continuous             = ft_preprocessing(cfg);
                
                if exist(fullfile(sensor_resultsDir,'layout_meg_orig.mat'),'file')==2 % this sensor layout does not change across conditions
                    load (fullfile(sensor_resultsDir,'layout_meg_orig.mat'));
                else
                    cfg                             = [];
                    cfg.grad                        = data_meg_continuous.grad;
                    layout_meg_orig                 = ft_prepare_layout(cfg,data_meg_continuous);
                    save(fullfile(sensor_resultsDir,'layout_meg_orig.mat'), 'layout_meg_orig');
                end
              
                                
                if exist(fullfile(sensor_resultsDir,['layout_meg_',test_name,'_',condition,'.mat']),'file')==2 % coregistered sensor layout (with the 1st condition)
                    load (fullfile(sensor_resultsDir,['layout_meg_',test_name,'_',condition,'.mat']))
                    
                else
                    
                    %pos                         = ft_read_sens(fullfile(raw_SubjectdataDir,[file_name(1:end-5),'B2.pos']),'fileformat','besa_pos'); % sensor location: coregistered (BESA coordinates)
                    pos                         = ft_read_sens(fullfile(raw_SubjectdataDir,[file_name,'.pos']),'fileformat','besa_pos');
                    pos                         = ft_convert_units(pos, 'cm');
                    
                    pos.type                    = data_meg_continuous.grad.type;
                    pos.label                   = data_meg_continuous.grad.label; % get the lable in continuous data
                    data_meg_continuous.grad    = pos; % replace the .grad field to get coregistered
                    
                    cfg                         = [];
                    cfg.grad                    = data_meg_continuous.grad;
                    layout_meg                  = ft_prepare_layout(cfg,data_meg_continuous);
                    
                    save(fullfile(sensor_resultsDir,['layout_meg_',test_name,'_',condition,'.mat']), 'layout_meg');
                    
                end
                             
                switch use_ICA
                    
                    case {'Y'}
                                                                       
                        if exist(fullfile(sensor_resultsDir,['data_meg_prep_',test_name,'_',condition,'_ICA.mat']),'file')==2
                            
                            disp ('**************************************************************')
                            disp (['data_meg_prep_',test_name,'_',condition,'_ICA.mat exist, please load file to plot']);
                            disp ('**************************************************************')
                            
                        elseif exist(fullfile(sensor_resultsDir,['data_meg_comp_',test_name,'_',condition,'.mat']),'file')==2
                            
                            load(fullfile(sensor_resultsDir,['data_meg_comp_',test_name,'_',condition,'.mat']));
                            
                            cfg                          = [];
                            cfg.layout                   = layout_meg_orig;
                            ft_databrowser(cfg, data_meg_comp);
                            pause
                            
                            cfg                          = []; %remove the bad components and backproject the data
                            prompt                       = {'Which components to be rejected? (separated by space, Ok for none):'};
                            ICA_component                = inputdlg(prompt);
                            cfg.component                = str2num(cell2mat(ICA_component));
                            data_meg_prep                = ft_rejectcomponent(cfg, data_meg_comp, data_meg_visual);
                            save(fullfile(sensor_resultsDir,['data_meg_prep_',test_name,'_',condition,'.mat']), 'data_meg_prep');
                            
                        else
                            
                            % filter MEG data
                            cfg                          = [];
                            cfg.demean                   = 'yes';
                            cfg.detrend                  = 'yes';
                            cfg.channel                  = 'MEG';
                            cfg.hpfiltord                = 4;
                            cfg.hpfilter                 = 'yes';
                            cfg.hpfreq                   = 0.1;
                            cfg.lpfilter                 = 'yes';
                            cfg.lpfreq                   = 30;
                            cfg.dftfilter                = 'yes'; % line noise removal using discrete fourier transform, default = [50 100 150]Hz
                            data_meg_filt                = ft_preprocessing(cfg,data_meg_continuous);
                            
                            % create trial definition
                            cfg                          = [];
                            cfg.dataset                  = fullfile(raw_SubjectdataDir,[file_name,'.con']);
                            cfg.trialfun                 = 'mytrialfun_MEG';
                            
                            switch test_group
                                
                                case {'English'}
                                    if strcmp(condition,'B2')
                                        cfg.trialdef.trigchannel = '177'; % normal trials
                                    elseif strcmp(condition,'B3')
                                        cfg.trialdef.trigchannel = '179'; %
                                    elseif strcmp(condition,'B4')
                                        cfg.trialdef.trigchannel = '181'; %
                                    elseif strcmp(condition,'B5')
                                        cfg.trialdef.trigchannel = '183'; %
                                    end
                                    
                                    cfg.trialdef.prestim         = -1.28;  % latency in seconds
                                    cfg.trialdef.poststim        = 15.36; % latency in seconds
                                    cfg.trialdef.offset          = -1.28; %
                                    
                                case {'Chinese'}
                                    if strcmp(condition,'B1')
                                        cfg.trialdef.trigchannel = '179'; % normal trials
                                    elseif strcmp(condition,'B2')
                                        cfg.trialdef.trigchannel = '181'; %
                                    end
                                    
                                    cfg.trialdef.prestim         = -1;
                                    cfg.trialdef.poststim        = 10; % latency in seconds
                                    cfg.trialdef.offset          = -1;
                            end
                            
                            cfg_trials                      = ft_definetrial(cfg);
                            trl                             = cfg_trials.trl;
                            
                            cfg                             = [];
                            cfg.trl                         = trl;
                            data_meg_epoch                  = ft_redefinetrial(cfg,data_meg_filt);
                            
                            % ICA!!! perform independent component analysis (i.e., decompose the data)
                            cfg                      = [];
                            cfg.channel              = 'meg';
                            cfg.method               = 'runica'; % this is the default and uses the implementation from EEGLAB
                            data_meg_comp            = ft_componentanalysis(cfg, data_meg_epoch);
                            
                            save(fullfile(sensor_resultsDir,['data_meg_comp_',test_name,'_',condition,'.mat']), 'data_meg_comp');
                            
                            % plot the components for visual inspection
                            cfg                          = [];
                            cfg.layout                   = layout_meg_orig;
                            ft_databrowser(cfg, data_meg_comp);
                            pause
                            
                            cfg                          = []; %remove the bad components and backproject the data
                            prompt                       = {'Which components to be rejected? (separated by space, Ok for none):'};
                            ICA_component                = inputdlg(prompt);
                            cfg.component                = str2num(cell2mat(ICA_component));
                            data_meg_prep                = ft_rejectcomponent(cfg, data_meg_comp, data_meg_epoch);
                            save(fullfile(sensor_resultsDir,['data_meg_prep_',test_name,'_',condition,'_ICA.mat']), 'data_meg_prep');
                        end
                        
                    case {'N'} % ICA not used
                        
                        if exist(fullfile(sensor_resultsDir,['data_meg_prep_',test_name,'_',condition,'.mat']),'file')==2
                            disp ('*********************************************************************')
                            disp ([subject,': data_meg_prep_',test_name,'_',condition,'.mat exist, please load file to plot']);
                            disp ('*********************************************************************')
                            
                        else
                            % filter MEG data
                            cfg                             = [];
                            cfg.demean                      = 'yes';
                            cfg.detrend                     = 'yes';
                            cfg.channel                     = 'MEG';
                            cfg.hpfiltord                   = 4;
                            cfg.hpfilter                    = 'yes';
                            cfg.hpfreq                      = 0.1;
                            cfg.lpfilter                    = 'yes';
                            cfg.lpfreq                      = 30;
                            cfg.dftfilter                   = 'yes'; % line noise removal using discrete fourier transform, default = [50 100 150]Hz
                            data_meg_filt                   = ft_preprocessing(cfg,data_meg_continuous);
                            
                            % create trial definition
                            cfg                             = [];
                            cfg.dataset                     = fullfile(raw_SubjectdataDir,[file_name,'.con']);
                            cfg.trialfun                    = 'mytrialfun_MEG';
                            
                            switch test_group
                                case {'English'}
                                    if strcmp(condition,'B2')
                                        cfg.trialdef.trigchannel = '177'; % normal trials
                                    elseif strcmp(condition,'B3')
                                        cfg.trialdef.trigchannel = '179'; %
                                    elseif strcmp(condition,'B4')
                                        cfg.trialdef.trigchannel = '181'; %
                                    elseif strcmp(condition,'B5')
                                        cfg.trialdef.trigchannel = '183'; %
                                    end
                                    
                                    cfg.trialdef.prestim         = -1.28;  % latency in seconds
                                    cfg.trialdef.poststim        = 15.36; % latency in seconds
                                    cfg.trialdef.offset          = -1.28; %
                                    
                                    
                                case {'Chinese'}
                                    if strcmp(condition,'B1')
                                        cfg.trialdef.trigchannel = '179'; % normal trials
                                    elseif strcmp(condition,'B2')
                                        cfg.trialdef.trigchannel = '181'; %
                                    end
                                    
                                    cfg.trialdef.prestim         = -1;
                                    cfg.trialdef.poststim        = 10; % latency in seconds
                                    cfg.trialdef.offset          = -1;
                                    
                            end
                            
                            cfg_trials                   = ft_definetrial(cfg);
                            trl                          = cfg_trials.trl;
                            
                            cfg                          = [];
                            cfg.trl                      = trl;
                            data_meg_epoch               = ft_redefinetrial(cfg,data_meg_filt);
                            
                            data_meg_prep                = data_meg_epoch; % no ICA
                            save(fullfile(sensor_resultsDir,['data_meg_prep_',test_name,'_',condition,'.mat']), 'data_meg_prep');
                            
                        end
                end
                
            end
        end
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
    case {'tone_1000'}
        
        for iSubject = 1:length(allSubjects_tone_1000)
            subject                         = allSubjects_tone_1000{iSubject};
            % output data directory
            raw_SubjectdataDir              = fullfile(raw_dataDir_MEG,subject);
            sensor_resultsDir               = fullfile(sensor_dataDir,subject);
            
            if ~isdir(sensor_resultsDir)
                mkdir(sensor_resultsDir); % make directory if it doesn't exist
            end
            
            disp('***************************')
            disp(['processing ' subject, '_', test_name]);
            disp('***************************')
            
            % define trials and read in raw MEG data
            
            file_name                       = cell2mat(allFiles_tone_1000((iSubject-1) + 1));
            
            cfg                             = [];
            cfg.dataset                     = fullfile(raw_SubjectdataDir,[file_name,'.con']);
            cfg.continuous                  = 'yes';
            cfg.channel                     = 'all';
            data_meg_continuous             = ft_preprocessing(cfg);
            
            if exist(fullfile(sensor_resultsDir,'layout_meg_orig.mat'),'file')==2 % default sensor layout
                load (fullfile(sensor_resultsDir,'layout_meg_orig.mat'));
            else
                
                cfg                         = [];
                cfg.grad                    = data_meg_continuous.grad;
                layout_meg_orig             = ft_prepare_layout(cfg,data_meg_continuous);
                save(fullfile(sensor_resultsDir,'layout_meg_orig.mat'), 'layout_meg_orig');
            end
            
            
            if exist(fullfile(sensor_resultsDir,['layout_meg_',test_name,'.mat']),'file')==2 % coregistered sensor layout
                load (fullfile(sensor_resultsDir,['layout_meg_',test_name,'.mat']))
                
            else
                
                pos                         = ft_read_sens(fullfile(raw_SubjectdataDir,[file_name,'.pos']),'fileformat','besa_pos'); % sensor location: coregistered (BESA coordinates)
                pos                         = ft_convert_units(pos, 'cm');
                
                pos.type                    = data_meg_continuous.grad.type;
                pos.label                   = data_meg_continuous.grad.label; % get the lable in continuous data
                data_meg_continuous.grad    = pos; % replace the .grad field to get coregistered
                
                cfg                         = [];
                cfg.grad                    = data_meg_continuous.grad;
                layout_meg                  = ft_prepare_layout(cfg,data_meg_continuous);
                
                save(fullfile(sensor_resultsDir,['layout_meg_',test_name,'.mat']), 'layout_meg');
                
            end
            
            
            switch use_ICA
                
                case {'Y'}
                    
                    if exist(fullfile(sensor_resultsDir,['data_meg_prep_',test_name,'_ICA.mat']),'file')==2
                        
                        disp ('**************************************************************')
                        disp (['data_meg_prep_',test_name,'_ICA.mat exist, please load file to plot']);
                        disp ('**************************************************************')
                        
                    elseif exist(fullfile(sensor_resultsDir,['data_meg_comp_',test_name,'.mat']),'file')==2 && exist(fullfile(sensor_resultsDir,['data_meg_visual_',test_name,'.mat']),'file')==2
                        
                        load(fullfile(sensor_resultsDir,['data_meg_comp_',test_name]));
                        load(fullfile(sensor_resultsDir,['data_meg_visual_',test_name]));
                        
                        % plot the components for visual inspection
                        cfg                          = [];
                        cfg.layout                   = layout_meg_orig;
                        ft_databrowser(cfg, data_meg_comp);
                        pause
                        
                        cfg                          = []; %remove the bad components and backproject the data
                        prompt                       = {'Which components to be rejected? (separated by space, Ok for none):'};
                        ICA_component                = inputdlg(prompt);
                        cfg.component                = str2num(cell2mat(ICA_component));
                        data_meg_prep                = ft_rejectcomponent(cfg, data_meg_comp, data_meg_visual);
                        save(fullfile(sensor_resultsDir,['data_meg_prep_',test_name,'.mat']), 'data_meg_prep');
                        
                    else
                        
                        % filter MEG data
                        cfg                          = [];
                        cfg.demean                   = 'yes';
                        cfg.detrend                  = 'yes';
                        cfg.channel                  = 'MEG';
                        cfg.hpfiltord                = 4;
                        cfg.hpfilter                 = 'yes';
                        cfg.hpfreq                   = 0.1;
                        cfg.lpfilter                 = 'yes';
                        cfg.lpfreq                   = 30;
                        cfg.dftfilter                = 'yes';
                        data_meg_filt                = ft_preprocessing(cfg,data_meg_continuous);
                        
                        % create trial definition
                        cfg                          = [];
                        cfg.dataset                  = fullfile(raw_SubjectdataDir,[file_name,'.con']);
                        cfg.trialfun                 = 'mytrialfun_MEG';
                        cfg.trialdef.trigchannel     = '177'; % normal trials
                        
                        
                        cfg.trialdef.prestim         = 0.2;  % latency in seconds
                        cfg.trialdef.poststim        = 0.5; % latency in seconds
                        cfg.trialdef.offset          = 0.2;
                        
                        cfg_trials                   = ft_definetrial(cfg);
                        trl                          = cfg_trials.trl;
                        
                        cfg                          = [];
                        cfg.trl                      = trl;
                        data_meg_epoch               = ft_redefinetrial(cfg,data_meg_filt);
                        
                        if exist(fullfile(sensor_resultsDir,['data_meg_visual_',test_name,'.mat']),'file')==2
                            load(fullfile(sensor_resultsDir,['data_meg_visual_',test_name,'.mat']));
                        else
                            
                            cfg                         = [];
                            cfg.method                  = 'summary';
                            data                        = ft_rejectvisual(cfg,data_meg_epoch); % press quit when done
                            
                            cfg                         = [];
                            cfg.viewmode                = 'vertical';
                            art                         = ft_databrowser(cfg,data);
                            data                        = ft_rejectartifact(art,data);
                            
                            % display the summary again and save the resulting data
                            cfg                         = [];
                            cfg.method                  = 'summary';
                            data_meg_visual             = ft_rejectvisual(cfg,data);
                            
                            save(fullfile(sensor_resultsDir,['data_meg_visual_',test_name,'.mat']), 'data_meg_visual');
                            
                        end
                        
                        %perform independent component analysis (i.e., decompose the data)
                        cfg                      = [];
                        cfg.channel              = 'meg';
                        cfg.method               = 'runica'; % this is the default and uses the implementation from EEGLAB
                        data_meg_comp            = ft_componentanalysis(cfg, data_meg_visual);
                        
                        save(fullfile(sensor_resultsDir,['data_meg_comp_',test_name,'.mat']), 'data_meg_comp');
                        
                        % plot the components for visual inspection
                        cfg                          = [];
                        cfg.layout                   = layout_meg_orig;
                        ft_databrowser(cfg, data_meg_comp);
                        pause
                        
                        cfg                          = []; %remove the bad components and backproject the data
                        prompt                       = {'Which components to be rejected? (separated by space, Ok for none):'};
                        ICA_component                = inputdlg(prompt);
                        cfg.component                = str2num(cell2mat(ICA_component));
                        data_meg_prep                = ft_rejectcomponent(cfg, data_meg_comp, data_meg_visual);
                        save(fullfile(sensor_resultsDir,['data_meg_prep_',test_name,'_ICA.mat']), 'data_meg_prep');                        
                    end
                    
                case {'N'}
                    
                    if exist(fullfile(sensor_resultsDir,['data_meg_prep_',test_name,'.mat']),'file')==2
                        
                        disp ('**************************************************************')
                        disp (['data_meg_prep_',test_name,'.mat exist, please load file to plot']);
                        disp ('**************************************************************')
                        
                    else
                        
                        % filter MEG data
                        cfg                          = [];
                        cfg.demean                   = 'yes';
                        cfg.detrend                  = 'yes';
                        cfg.channel                  = 'MEG';
                        cfg.hpfiltord                = 4;
                        cfg.hpfilter                 = 'yes';
                        cfg.hpfreq                   = 0.1;
                        cfg.lpfilter                 = 'yes';
                        cfg.lpfreq                   = 30;
                        cfg.dftfilter                = 'yes';
                        data_meg_filt                = ft_preprocessing(cfg,data_meg_continuous);
                        
                        % create trial definition
                        cfg                          = [];
                        cfg.dataset                  = fullfile(raw_SubjectdataDir,[file_name,'.con']);
                        cfg.trialfun                 = 'mytrialfun_MEG';
                        cfg.trialdef.trigchannel     = '177'; % normal trials
                                                
                        cfg.trialdef.prestim         = 0.2;  % latency in seconds
                        cfg.trialdef.poststim        = 0.5; % latency in seconds
                        cfg.trialdef.offset          = 0.2;
                        
                        cfg_trials                   = ft_definetrial(cfg);
                        trl                          = cfg_trials.trl;
                        
                        cfg                          = [];
                        cfg.trl                      = trl;
                        data_meg_epoch               = ft_redefinetrial(cfg,data_meg_filt);                       
                        
                        if exist(fullfile(sensor_resultsDir,['data_meg_visual_',test_name,'.mat']),'file')==2                          
                            load(fullfile(sensor_resultsDir,['data_meg_visual_',test_name,'.mat']));
                        else
                            
                            cfg                         = [];
                            cfg.method                  = 'summary';
                            data                        = ft_rejectvisual(cfg,data_meg_epoch); % press quit when done
                            
                            cfg                         = [];
                            cfg.viewmode                = 'vertical';
                            art                         = ft_databrowser(cfg,data);
                            data                        = ft_rejectartifact(art,data);
                            
                            % display the summary again and save the resulting data
                            cfg                         = [];
                            cfg.method                  = 'summary';
                            data_meg_visual             = ft_rejectvisual(cfg,data);
                            
                            save(fullfile(sensor_resultsDir,['data_meg_visual_',test_name,'.mat']), 'data_meg_visual');
                            
                        end
                        
                        data_meg_prep                   = data_meg_visual;
                        save(fullfile(sensor_resultsDir,['data_meg_prep_',test_name,'.mat']), 'data_meg_prep');
                    end
                    
            end
            
        end
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %{
    case {'masanori'}
        for iSubject = 1:length(allSubjects_tone_masa)
            subject                         = allSubjects_tone_masa{iSubject};
            % output data directory
            raw_SubjectdataDir              = fullfile(raw_dataDir_MEG,subject);
            sensor_resultsDir               = fullfile(sensor_dataDir,subject);
            
            if ~isdir(sensor_resultsDir)
                mkdir(sensor_resultsDir); % make directory if it doesn't exist
            end
            
            disp('***************************')
            disp(['processing ' subject, '_', test_name]);
            disp('***************************')
            
            % define trials and read in raw MEG data
            
            file_name                       = cell2mat(allFiles_tone_masa((iSubject-1) + 1));
            
            cfg                             = [];
            cfg.dataset                     = fullfile(raw_SubjectdataDir,[file_name,'.con']);
            cfg.continuous                  = 'yes';
            cfg.channel                     = 'all';
            data_meg_continuous             = ft_preprocessing(cfg);
            
            cfg                             = [];
            cfg.grad                        = data_meg_continuous.grad;
            layout_meg_orig                 = ft_prepare_layout(cfg,data_meg_continuous);
            
            if exist(fullfile(sensor_resultsDir,['layout_meg_',test_name,'.mat']),'file')==2
                load (fullfile(sensor_resultsDir,['layout_meg_',test_name,'.mat']));
            else
                pos                             = ft_read_sens(fullfile(raw_SubjectdataDir,[file_name,'.pos']),'fileformat','besa_pos'); % sensor location: coregistered (BESA coordinates)
                pos                             = ft_convert_units(pos, 'cm');
                
                pos.type                        = data_meg_continuous.grad.type;
                pos.label                       = data_meg_continuous.grad.label; % get the lable in continuous data
                data_meg_continuous.grad        = pos; % replace the .grad field to get coregistered
                
                cfg                             = [];
                cfg.grad                        = data_meg_continuous.grad;
                layout_meg                      = ft_prepare_layout(cfg,data_meg_continuous);
                
                save(fullfile(sensor_resultsDir,['layout_meg_',test_name,'.mat']), 'layout_meg');
            end
            
            if exist(fullfile(sensor_resultsDir,['data_meg_prep_',test_name,'.mat']),'file')==2
                load(fullfile(sensor_resultsDir,['data_meg_prep_',test_name]));
                
            elseif exist(fullfile(sensor_resultsDir,['data_meg_comp_',test_name,'.mat']),'file')==2
                load(fullfile(sensor_resultsDir,['data_meg_comp_',test_name]));
                load (fullfile(sensor_resultsDir,['data_meg_visual_',test_name]));
                
                % plot the components for visual inspection
                cfg                          = [];
                cfg.layout                   = layout_meg_orig;
                ft_databrowser(cfg, data_meg_comp);
                pause
                
                cfg                          = []; %remove the bad components and backproject the data
                prompt                       = {'Which components to be rejected? (separated by space, Ok for none):'};
                ICA_component                = inputdlg(prompt);
                cfg.component                = str2num(cell2mat(ICA_component));
                data_meg_prep                = ft_rejectcomponent(cfg, data_meg_comp, data_meg_visual);
                save(fullfile(sensor_resultsDir,['data_meg_prep_',test_name,'.mat']), 'data_meg_prep');
                
            else
                % filter MEG data
                cfg                          = [];
                cfg.demean                   = 'yes';
                cfg.detrend                  = 'yes';
                cfg.channel                  = 'MEG';
                cfg.hpfiltord                = 4;
                cfg.hpfilter                 = 'yes';
                cfg.hpfreq                   = 0.1;
                cfg.lpfilter                 = 'yes';
                cfg.lpfreq                   = 30;
                cfg.dftfilter                = 'yes';
                data_meg_filt                = ft_preprocessing(cfg,data_meg_continuous);
                
                % create trial definition
                cfg                          = [];
                cfg.dataset                  = fullfile(raw_SubjectdataDir,[file_name,'.con']);
                cfg.trialfun                 = 'mytrialfun_MEG';
                cfg.trialdef.trigchannel     = '167'; % normal trials
                
                
                cfg.trialdef.prestim         = 0.3;  % latency in seconds
                cfg.trialdef.poststim        = 0.6; % latency in seconds
                cfg.trialdef.offset          = 0.3;
                
                
                cfg_trials                   = ft_definetrial(cfg);
                trl                          = cfg_trials.trl;
                
                cfg                          = [];
                cfg.trl                      = trl;
                data_meg_epoch               = ft_redefinetrial(cfg,data_meg_filt);
                
                cfg                         = [];
                cfg.method                  = 'summary';
                data                        = ft_rejectvisual(cfg,data_meg_epoch); % press quit when done
                
                cfg                         = [];
                cfg.viewmode                = 'vertical';
                art                         = ft_databrowser(cfg,data);
                data                        = ft_rejectartifact(art,data);
                
                pause
                
                % display the summary again and save the resulting data
                cfg                         = [];
                cfg.method                  = 'summary';
                data_meg_visual             = ft_rejectvisual(cfg,data);
                
                save(fullfile(sensor_resultsDir,['data_meg_visual_',test_name,'.mat']), 'data_meg_visual');
                
                %perform independent component analysis (i.e., decompose the data)
                cfg                      = [];
                cfg.channel              = 'meg';
                cfg.method               = 'runica'; % this is the default and uses the implementation from EEGLAB
                data_meg_comp            = ft_componentanalysis(cfg, data_meg_visual);
                
                save(fullfile(sensor_resultsDir,['data_meg_comp_',test_name,'.mat']), 'data_meg_comp');
                
                % plot the components for visual inspection
                cfg                          = [];
                cfg.layout                   = layout_meg_orig;
                ft_databrowser(cfg, data_meg_comp);
                pause
                
                cfg                          = []; %remove the bad components and backproject the data
                prompt                       = {'Which components to be rejected? (separated by space, Ok for none):'};
                ICA_component                = inputdlg(prompt);
                cfg.component                = str2num(cell2mat(ICA_component));
                data_meg_prep                = ft_rejectcomponent(cfg, data_meg_comp, data_meg_visual);
                save(fullfile(sensor_resultsDir,['data_meg_prep_',test_name,'.mat']), 'data_meg_prep');
                
            end
            
            cfg                                 = [];
            cfg.covariance                      = 'yes';
            cfg.covariancewindow                = [-inf 0]; % 3 s before the spike
            data_meg_ave                        = ft_timelockanalysis(cfg,data_meg_prep);
            
            figure
            plot(data_meg_ave.time, data_meg_ave.avg)
            
            figure
            cfg                                 = [];
            cfg.showlabels                      = 'yes';
            cfg.fontsize                        = 6;
            cfg.layout                          = layout_meg_orig;
            
            ft_multiplotER(cfg, data_meg_ave);
            
            cfg          = [];
            cfg.layout   = layout_meg_orig;
            cfg.baseline = [-0.3 0];
            
            cfg.xlim = [0.08 0.12];
            ft_topoplotER(cfg, data_meg_ave);
            
            if exist(fullfile(sensor_resultsDir,['data_meg_ave_',test_name,'.mat']),'file')==0
                save(fullfile(sensor_resultsDir,['data_meg_ave_',test_name,'.mat']), 'data_meg_ave');
            end
            
        end
        %}
        
end