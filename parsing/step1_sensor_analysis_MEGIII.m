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
%             
%             for iSubject = 1:length(allSubjects_parsing)
%                 subject                      = allSubjects_parsing{iSubject};
%                 % output data directory
%                 raw_SubjectdataDir_MEG       = fullfile(raw_dataDir_MEG,subject);
%                 sensor_resultsDir            = fullfile(sensor_dataDir,subject);
%                 
%                 if ~isdir(sensor_resultsDir)
%                     mkdir(sensor_resultsDir); % make directory if it doesn't exist
%                 end
%                 
%                 disp('*****************************')
%                 disp(['processing ' subject]);
%                 disp('*****************************')
%                 
%                 % define trials and read in raw EEG data
%                 if strcmp(condition,'standard')
%                     file_name               = cell2mat(allFiles_parsing((iSubject-1)*2+1));
%                 elseif strcmp(condition,'random')
%                     file_name               = cell2mat(allFiles_parsing((iSubject-1)*2+2));
%                 end
%                 
%                 cfg                             = [];
%                 cfg.dataset                     = fullfile(raw_SubjectdataDir_MEG,[file_name,'.con']);
%                 cfg.continuous                  = 'yes';
%                 cfg.channel                     = 'all';
%                 data_meg_continuous             = ft_preprocessing(cfg);
%                 
%                 cfg                             = [];
%                 cfg.grad                        = data_meg_continuous.grad;
%                 layout_MEG                      = ft_prepare_layout(cfg,data_meg_continuous);
%                 
%                 if exist(fullfile(sensor_resultsDir,['data_meg_prep_',condition,'.mat']),'file')==2
%                     load(fullfile(sensor_resultsDir,['data_meg_prep_',condition]));
%                 else
%                     
%                     % filter MEG data
%                     cfg                          = [];
%                     cfg.demean                   = 'yes';
%                     cfg.detrend                  = 'yes';
%                     cfg.channel                  = 'MEG';
%                     cfg.hpfiltord                = 4;
%                     cfg.hpfilter                 = 'yes';
%                     cfg.hpfreq                   = 0.1;
%                     cfg.lpfilter                 = 'yes';
%                     cfg.lpfreq                   = 30;
%                     cfg.dftfilter                = 'yes';
%                     data_meg_filt                = ft_preprocessing(cfg,data_meg_continuous);
%                     
%                     % create trial definition
%                     cfg                          = [];
%                     cfg.dataset                  = fullfile(raw_SubjectdataDir_MEG,[file_name,'.con']);
%                     cfg.trialfun                 = 'mytrialfun_MEGIII';
%                     if strcmp(condition,'standard')
%                         %cfg.trialdef.trigchannel = '179'; % normal trials
%                         cfg.trialdef.trigchannel = '053'; % normal trials
%                     elseif strcmp(condition,'random')
%                         %cfg.trialdef.trigchannel = '181';
%                         cfg.trialdef.trigchannel = '054'; % outlier trials
%                     end
%                     
%                     cfg.trialdef.prestim         = -1;  % latency in seconds
%                     cfg.trialdef.poststim        = 10; % latency in seconds
%                     cfg.channels                 = (1:20);
%                     cfg_trials                   = ft_definetrial(cfg);
%                     trl                          = cfg_trials.trl;
%                     
%                     cfg                          = [];
%                     cfg.trl                      = trl;
%                     data_meg_epoch               = ft_redefinetrial(cfg,data_meg_filt);
%                     
%                     %perform independent component analysis (i.e., decompose the data)
%                     cfg                      = [];
%                     cfg.channel              = 'meg';
%                     cfg.method               = 'runica'; % this is the default and uses the implementation from EEGLAB
%                     data_meg_comp            = ft_componentanalysis(cfg, data_meg_epoch);
%                     
%                     % plot the components for visual inspection
%                     cfg                          = [];
%                     cfg.layout                   = layout_MEG;
%                     ft_databrowser(cfg, data_meg_comp);
%                     pause
%                     
%                     cfg                          = []; %remove the bad components and backproject the data
%                     prompt                       = {'Which Components?'};
%                     ICA_component                = inputdlg(prompt);
%                     cfg.component                = str2num(cell2mat(ICA_component));
%                     data_meg_prep                = ft_rejectcomponent(cfg, data_meg_comp, data_meg_epoch);
%                     save(fullfile(sensor_resultsDir,['data_meg_prep_',condition,'.mat']), 'data_meg_prep');
%                 end
%                 
%                 % power spectrum
%                 cfg                          = [];
%                 cfg.method                   = 'mtmfft';
%                 cfg.output                   = 'pow';
%                 cfg.foilim                   = [0.6 5];
%                 cfg.taper                    = 'hanning';
%                 cfg.channel                  = 'meg';
%                 data_meg_pow                 = ft_freqanalysis(cfg, data_meg_prep);
%                 % multi plot
%                 cfg                          = [];
%                 cfg.parameter                = 'powspctrm';
%                 cfg.showlabels               = 'yes';
%                 cfg.axes                     = 'yes';
%                 cfg.fontsize                 = 12;
%                 cfg.comment                  = 'no';
%                 cfg.layout                   = layout_MEG;
%                 figure;
%                 ft_multiplotER(cfg, data_meg_pow);
%                 %
%                 cfg                          = [];
%                 cfg.method                   = 'mtmfft';
%                 cfg.output                   = 'fourier';
%                 cfg.foilim                   = [0.6 5];
%                 %cfg.foi                     = (0.8:0.1:5);
%                 %cfg.toi                     = (1:0.1:10);
%                 cfg.taper                    = 'hanning';
%                 cfg.channel                  = 'meg';
%                 data_meg_fourier             = ft_freqanalysis(cfg, data_meg_prep);
%                 
%                 itc = [];
%                 itc.label                    = data_meg_fourier.label;
%                 itc.freq                     = data_meg_fourier.freq;
%                 %itc.time                    = data_meg_fourier.time;
%                 itc.dimord                   = 'chan_freq_time';
%                 
%                 F                            = data_meg_fourier.fourierspctrm;   % copy the Fourier spectrum
%                 N                            = size(F,1);           % number of trials
%                 
%                 % compute inter-trial phase coherence (itpc)
%                 itc.itpc                     = F./abs(F);         % divide by amplitude
%                 itc.itpc                     = sum(itc.itpc,1);   % sum angles over trials
%                 itc.itpc                     = abs(itc.itpc)/N;   % take the absolute value and normalize
%                 itc.itpc                     = squeeze(itc.itpc); % remove the first singleton dimension
%                 
%                 % compute inter-trial linear coherence (itlc)
%                 itc.itlc                     = sum(F) ./ (sqrt(N*sum(abs(F).^2,1)));
%                 itc.itlc                     = abs(itc.itlc);     % take the absolute value, i.e. ignore phase
%                 itc.itlc                     = squeeze(itc.itlc); % remove the first singleton dimension
%                 
%                 figure
%                 subplot(2, 1, 1);
%                 plot(itc.freq, squeeze(sum(itc.itpc(1,:,:),1)));
%                 axis xy
%                 title([allSubjects_parsing{iSubject},' inter-trial phase coherence']);
%                 
%                 subplot(2, 1, 2);
%                 plot(itc.freq, squeeze(sum(itc.itlc(1,:,:),1)));
%                 axis xy
%                 title([allSubjects_parsing{iSubject},'inter-trial linear coherence']);
%             end
%         end
        
    case {'masanori'}
        
        for iCondition = 1%:length(allConditions_tone_masa)
            condition = allConditions_tone_masa{iCondition};
        
            for iSubject = 2%:length(allSubjects_tone_masa)
                subject                         = allSubjects_tone_masa{iSubject};
                % output data directory
                raw_SubjectdataDir              = fullfile(raw_dataDir_MEG,subject);
                sensor_resultsDir               = fullfile(sensor_dataDir,subject);
                
                if ~isdir(sensor_resultsDir)
                    mkdir(sensor_resultsDir); % make directory if it doesn't exist
                end
                                
                if strcmp(condition,'B1')
                    file_name               = cell2mat(allFiles_tone_masa((iSubject-1)*2+1));
                elseif strcmp(condition,'B2')
                    file_name               = cell2mat(allFiles_tone_masa((iSubject-1)*2+2));
                end
                
                disp('*************************************')
                disp(['processing ' subject, '_', test_name,'_',condition]);
                disp('*************************************')
                
                % define trials and read in raw MEG data
                
                cfg                             = [];
                cfg.dataset                     = fullfile(raw_SubjectdataDir,[file_name,'.con']);
                cfg.continuous                  = 'yes';
                cfg.channel                     = 'all';
                data_meg_continuous             = ft_preprocessing(cfg);
                
%                 cfg                             = [];
%                 cfg.grad                        = data_meg_continuous.grad;
%                 layout_meg_orig                 = ft_prepare_layout(cfg,data_meg_continuous);

                load (fullfile(sensor_dataDir,'layout_typeB.mat'));                
                layout_meg_orig = layout;
                clear layout;
                               
                if exist(fullfile(sensor_resultsDir,['layout_meg_',test_name,'_',condition,'.mat']),'file')==2
                    load (fullfile(sensor_resultsDir,['layout_meg_',test_name,'_',condition,'.mat']));
                else
                    pos                             = ft_read_sens(fullfile(raw_SubjectdataDir,[file_name,'.pos']),'fileformat','besa_pos'); % sensor location: coregistered (BESA coordinates)
                    pos                             = ft_convert_units(pos, 'cm');
                    
                    pos.type                        = data_meg_continuous.grad.type;
                    pos.label                       = data_meg_continuous.grad.label; % get the lable in continuous data
                    data_meg_continuous.grad        = pos; % replace the .grad field to get coregistered
                    
                    cfg                             = [];
                    cfg.grad                        = data_meg_continuous.grad;
                    layout_meg                      = ft_prepare_layout(cfg,data_meg_continuous);
                    
                    save(fullfile(sensor_resultsDir,['layout_meg_',test_name,'_',condition,'.mat']), 'layout_meg');
                end
                
                if exist(fullfile(sensor_resultsDir,['data_meg_prep_',test_name,'_',condition,'.mat']),'file')==2
                    load(fullfile(sensor_resultsDir,['data_meg_prep_',test_name,'_',condition]));
                    
                elseif exist(fullfile(sensor_resultsDir,['data_meg_comp_',test_name,'_',condition,'.mat']),'file')==2
                    load(fullfile(sensor_resultsDir,['data_meg_comp_',test_name,'_',condition]));
                    
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
                    cfg.dftfilter                = 'yes';
                    data_meg_filt                = ft_preprocessing(cfg,data_meg_continuous);
                    
                    % create trial definition
                    cfg                          = [];
                    cfg.dataset                  = fullfile(raw_SubjectdataDir,[file_name,'.con']);
                    cfg.trialfun                 = 'mytrialfun_MEGIII';
                    cfg.trialdef.trigchannel     = '051'; % normal trials
                                        
                    cfg.trialdef.prestim         = 0.4;  % latency in seconds
                    cfg.trialdef.poststim        = 0.6; % latency in seconds
                    cfg.trialdef.offset          = -0.4;                        
                    cfg_trials                   = ft_definetrial(cfg);
                    
                    trl                          = cfg_trials.trl;
                    
                    cfg                          = [];
                    cfg.trl                      = trl;
                    data_meg_epoch               = ft_redefinetrial(cfg,data_meg_filt);                    
                    %%
                    cfg                         = [];
                    cfg.method                  = 'summary';
                    data                        = ft_rejectvisual(cfg,data_meg_epoch); % press quit when done
                    
                    cfg                         = [];
                    cfg.viewmode                = 'butterfly';
                    art                         = ft_databrowser(cfg,data);
                    data                        = ft_rejectartifact(art,data);
                    
                    % display the summary again and save the resulting data
                    cfg                         = [];
                    cfg.method                  = 'summary';
                    data_meg_visual             = ft_rejectvisual(cfg,data);
                    
                    %perform independent component analysis (i.e., decompose the data)
                    cfg                      = [];
                    cfg.channel              = 'meg';
                    cfg.method               = 'runica'; % this is the default and uses the implementation from EEGLAB
                    data_meg_comp            = ft_componentanalysis(cfg, data_meg_visual);
                    
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
                    save(fullfile(sensor_resultsDir,['data_meg_prep_',test_name,'_',condition,'.mat']), 'data_meg_prep');
                    
                end
                
                cfg                                 = [];
                cfg.covariance                      = 'yes';
                cfg.covariancewindow                = [-inf 0]; % 3 s before the spike
                data_meg_ave                        = ft_timelockanalysis(cfg,data_meg_prep);
                
                figure
                plot(data_meg_ave.time, data_meg_ave.avg)
                title (sprintf('%s_ %s',subject,condition),'interpreter','none');
                
                figure
                cfg                                 = [];
                cfg.showlabels                      = 'yes';
                cfg.fontsize                        = 6;
                cfg.layout                          = layout_meg_orig;
                
                ft_multiplotER(cfg, data_meg_ave);
                
                cfg                     = [];
                cfg.layout              = layout_meg_orig;
                cfg.baseline            = [-0.3 0];
                cfg.markersize          = 4; 
                cfg.xlim                = [0.09 0.1];
                cfg.colorbar            = 'yes';
                ft_topoplotER(cfg, data_meg_ave);
                title (sprintf('%s_ %s',subject,condition),'interpreter','none');
                
                
                if exist(fullfile(sensor_resultsDir,['data_meg_ave_',test_name,'_',condition,'.mat']),'file')==0
                    save(fullfile(sensor_resultsDir,['data_meg_ave_',test_name,'_',condition,'.mat']), 'data_meg_ave');
                end
                
            end
        end

end