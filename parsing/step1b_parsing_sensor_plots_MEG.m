close all
clear
clc

preparation_MEG
%%

switch test_name
    
    case {'parsing'}

        switch use_ICA
            
            case {'Y'}
                file_to_load_itc_all = fullfile(sensor_dataDir,'group_result/all_itc_spectrum_ICA.mat');
                file_to_load_ave_all = fullfile(sensor_dataDir,'group_result/all_avg_spectrum_ICA.mat');
                disp('generating averaged plots with ICA');
                
            case{'N'}
                file_to_load_itc_all = fullfile(sensor_dataDir,'group_result/all_itc_spectrum.mat');
                file_to_load_ave_all = fullfile(sensor_dataDir,'group_result/all_avg_spectrum.mat');
                disp('generating averaged plots without ICA');
        end
        
        if exist(file_to_load_itc_all,'file')==2 && exist(file_to_load_ave_all,'file')==2 && strcmp(individual_plots,'N') == 1
            load (file_to_load_itc_all);
            load (file_to_load_ave_all);
            load (fullfile(sensor_dataDir,'group_result/frequency_axis.mat'));
            %f=1:size(all_itc_spectrum,3);f=f-1;f=f/size(all_itc_spectrum,3);f=f*fs;            
            
        else            
            all_itc_spectrum = zeros (length(allConditions_parsing),length(allSubjects_parsing),14081);
            all_avg_spectrum = zeros (length(allConditions_parsing),length(allSubjects_parsing),14081);
            
            for iCondition = 1:length(allConditions_parsing)
                condition = allConditions_parsing{iCondition};
                
                for iSubject = 1:length(allSubjects_parsing)
                    
                    subject                         = allSubjects_parsing{iSubject};
                    sensor_resultsDir               = fullfile(sensor_dataDir,subject);
                    
                    switch use_ICA
                        
                        case {'Y'}
                            file_to_load_itc_individual = fullfile(sensor_resultsDir,'itc_spectrum_ICA.mat');
                            file_to_load_ave_individual = fullfile(sensor_resultsDir,'avg_spectrum_ICA.mat');
                            disp([subject,': generating individual plots with ICA']);
                            
                        case{'N'}
                            file_to_load_itc_individual = fullfile(sensor_resultsDir,'itc_spectrum.mat');
                            file_to_load_ave_individual = fullfile(sensor_resultsDir,'avg_spectrum.mat');
                            disp([subject,': generating individual plots without ICA']);
                    end
                    
                     if exist(file_to_load_itc_individual,'file')==2 && exist(file_to_load_ave_individual,'file')==2                         

                         load (file_to_load_itc_individual);
                         load (file_to_load_ave_individual);
                         load (fullfile(sensor_dataDir,'group_result/frequency_axis.mat'));                         
                     else
                         
                         switch use_ICA
                             
                             case {'Y'}
                                 load ([sensor_resultsDir,'/data_meg_prep_',test_name,'_',condition,'_ICA.mat']);
                                 disp('*******************************')
                                 disp(['processing ' subject,'_', test_name,'_', condition,' with ICA']);
                                 disp('*******************************')
                             case {'N'}
                                 load ([sensor_resultsDir,'/data_meg_prep_',test_name,'_',condition,'.mat']);
                                 disp('*******************************')
                                 disp(['processing ' subject,'_', test_name,'_', condition]);
                                 disp('*******************************')
                         end
                         
                         meg_data = zeros (14081,160,22); %  160 channels x 22 trials
                         
                         for i = 1:22
                             
                             meg_data (:,:,i) = transpose(data_meg_prep.trial{1,i});
                             
                         end
                         
                         [itc_spectrum,avg_spectrum,f] = plot_itc_avg_spectrum(meg_data,fs); % fs 1000 Hz                                                 
                         
                     end
                    
                    load ([sensor_resultsDir,'/layout_meg_orig.mat'])
                    
                    
                    %{
                    display_frequency_range = [0.5,4.5];
                    f_label = 1:4;
                    figure;
                    
                    subplot(211);
                    plot(f,itc_spectrum);
                    xlim(display_frequency_range);
                    xlabel('frequency (Hz)')
                    ylabel('inter-trial phase coherence')
                    set(gca,'xtick',f_label);
                    title(['itc_spectrum: ',subject,'_', test_name,'_', condition],'interpreter','none');
                    
                    subplot(212);
                    plot(f,avg_spectrum);
                    xlim(display_frequency_range);
                    title(['avg_spectrum: ',subject,'_', test_name,'_', condition],'interpreter','none');
                    xlabel('frequency (Hz)')
                    ylabel('power (a.u.)')
                    set(gca,'xtick',f_label);
                    %}
                    all_itc_spectrum (iCondition,iSubject,:) = mean(itc_spectrum,2);
                    all_avg_spectrum (iCondition,iSubject,:) = mean(avg_spectrum,2);
                    
%                     figure
%                     cfg          = [];
%                     cfg.layout   = layout_meg_orig;
%                     ft_topoplotER(cfg, avg_spectrum);
%                     title([allSubjects_tone_1000{iSubject},': AEF'],'interpreter','none');
                    
                    switch use_ICA
                        
                        case {'Y'}
                            save (fullfile(sensor_resultsDir,[test_name,'_',condition,'_itc_spectrum_ICA.mat']), 'itc_spectrum');                                                                                           
                            save (fullfile(sensor_resultsDir,[test_name,'_',condition,'_avg_spectrum_ICA.mat']), 'avg_spectrum');
                            
                        case{'N'}
                            save (fullfile(sensor_resultsDir,[test_name,'_',condition,'_itc_spectrum.mat']), 'itc_spectrum');
                            save (fullfile(sensor_resultsDir,[test_name,'_',condition,'_avg_spectrum.mat']), 'avg_spectrum');
                            
                    end
                    
                end
                
            end
            
            switch use_ICA
                
                case {'Y'}
                    save (fullfile(sensor_dataDir,'group_result/all_itc_spectrum_ICA.mat'), 'all_itc_spectrum');
                    save (fullfile(sensor_dataDir,'group_result/all_avg_spectrum_ICA.mat'), 'all_avg_spectrum');
                    save (fullfile(sensor_dataDir,'group_result/frequency_axis.mat'), 'f');
                    
                case{'N'}
                    save (fullfile(sensor_dataDir,'group_result/all_itc_spectrum.mat'), 'all_itc_spectrum');
                    save (fullfile(sensor_dataDir,'group_result/all_avg_spectrum.mat'), 'all_avg_spectrum');
                    save (fullfile(sensor_dataDir,'group_result/frequency_axis.mat'), 'f');
            end
        end
        
        for iCondition = 1:length(allConditions_parsing)
            condition = allConditions_parsing{iCondition};
            
            display_frequency_range = [0.5,4.5];
            f_label = 1:4;
            figure;
            
            subplot(211);
            plot(f,squeeze(all_itc_spectrum(iCondition,:,:)));
            hold on
            grid on
            plot(f,mean(squeeze(all_itc_spectrum(iCondition,:,:)),1),'k','Linewidth',3);
            xlim(display_frequency_range);
            ylim([0,0.5]);
            xlabel('frequency (Hz)')
            ylabel('inter-trial phase coherence')
            set(gca,'xtick',f_label,'FontSize',20);
            title(['individual_itc_spectrum: ', test_name,'_', condition],'interpreter','none');
            
            %     ax1 = gca;
            %     ax1.XTickMode = 'manual';
            %     ax1.YTickMode = 'manual';
            %     ax1.XLimMode = 'manual';
            %     ax1.YLimMode = 'manual';
            %
            %     %set(gcf,'paperunits','inches');
            %     set(gcf,'PaperPositionMode', 'manual');
            %     set(gcf,'papersize',[6,8]);
            %     set(gcf,'paperposition',[0,0,6,8])
            
            
            subplot(212);
            plot(f,20*log10(squeeze(all_avg_spectrum(iCondition,:,:))));
            hold on
            grid on
            plot(f,20*log10(mean(squeeze(all_avg_spectrum(iCondition,:,:)),1)),'k','Linewidth',3)
            xlim(display_frequency_range);
            title(['individual_avg_spectrum: ', test_name,'_', condition],'interpreter','none');
            xlabel('frequency (Hz)')
            ylabel('power (dB)')
            set(gca,'xtick',f_label,'FontSize',20);
            
            
            %     ax2 = gca;
            %     ax2.XTickMode = 'manual';
            %     ax2.YTickMode = 'manual';
            %     ax2.XLimMode = 'manual';
            %     ax2.YLimMode = 'manual';
            %
            %     %set(gcf,'paperunits','inches');
            %     set(gcf,'PaperPositionMode', 'manual');
            %     set(gcf,'papersize',[6,8]);
            %     set(gcf,'paperposition',[0,0,6,8])
            
            %print(fullfile(sensor_dataDir,['plots/',test_name,'_',condition,'.eps']), '-depsc', '-r600');
            
        end
        
        % all levels
        
        display_frequency_range = [0.5,4.5];
        f_label = 1:4;
        figure;
        
        subplot(211);
        plot(f,squeeze(mean(all_itc_spectrum,2)),'Linewidth',2);
        grid on
        xlim(display_frequency_range);
        ylim([0,0.35]);
        xlabel('frequency (Hz)')
        ylabel('inter-trial phase coherence')
        set(gca,'xtick',f_label,'FontName','Times New Roman','FontSize',20);
        title('all_itc_spectrum','interpreter','none');
        legend ('Natural','Voc:16', 'Voc:8', 'Shuffled');
        
        subplot(212);
        plot(f,20*log10(squeeze(mean(all_avg_spectrum,2))),'Linewidth',2);
        grid on
        xlim(display_frequency_range);
        title('all_avg_spectrum','interpreter','none');
        xlabel('frequency (Hz)')
        ylabel('power (dB)')
        set(gca,'xtick',f_label,'FontName','Times New Roman','FontSize',20);
        legend ('Natural','Voc:16', 'Voc:8', 'Shuffled');
        
        
        % sentence level
        display_frequency_range = [0.5,1];
        f_label = 0.5:0.1:1;
        figure;
        
        subplot(211);
        plot(f,squeeze(mean(all_itc_spectrum,2)),'Linewidth',2);
        grid on
        xlim(display_frequency_range);
        ylim([0,0.2]);
        xlabel('frequency (Hz)')
        ylabel('inter-trial phase coherence')
        set(gca,'xtick',f_label,'FontName','Times New Roman','FontSize',20);
        title('all_itc_spectrum','interpreter','none');
        legend ('Natural','Voc:16', 'Voc:8', 'Shuffled');
        
        subplot(212);
        plot(f,20*log10(squeeze(mean(all_avg_spectrum,2))),'Linewidth',2);
        grid on
        xlim(display_frequency_range);
        title('all_avg_spectrum','interpreter','none');
        xlabel('frequency (Hz)')
        ylabel('power (dB)')
        set(gca,'xtick',f_label,'FontName','Times New Roman','FontSize',20);
        legend ('Natural','Voc:16', 'Voc:8', 'Shuffled');
        
        % phrase level
        display_frequency_range = [1.2,1.8];
        f_label = 1.2:0.1:1.8;
        figure;
        
        subplot(211);
        plot(f,squeeze(mean(all_itc_spectrum,2)),'Linewidth',2);
        grid on
        xlim(display_frequency_range);
        ylim([0,0.2]);
        xlabel('frequency (Hz)')
        ylabel('inter-trial phase coherence')
        set(gca,'xtick',f_label,'FontName','Times New Roman','FontSize',20);
        title('all_itc_spectrum','interpreter','none');
        legend ('Natural','Voc:16', 'Voc:8', 'Shuffled');
        
        subplot(212);
        plot(f,20*log10(squeeze(mean(all_avg_spectrum,2))),'Linewidth',2);
        grid on
        xlim(display_frequency_range);
        title('all_avg_spectrum','interpreter','none');
        xlabel('frequency (Hz)')
        ylabel('power (dB)')
        set(gca,'xtick',f_label,'FontName','Times New Roman','FontSize',20);
        legend ('Natural','Voc:16', 'Voc:8', 'Shuffled');
        
        % syllable level
        display_frequency_range = [2.8,3.4];
        f_label = 2.8:0.1:3.4;
        figure;
        
        subplot(211);
        plot(f,squeeze(mean(all_itc_spectrum,2)),'Linewidth',2);
        grid on
        xlim(display_frequency_range);
        title('all_itc_spectrum','interpreter','none');
        ylim([0,0.35]);
        xlabel('frequency (Hz)')
        ylabel('inter-trial phase coherence')
        set(gca,'xtick',f_label,'FontName','Times New Roman','FontSize',20);
        legend ('Natural','Voc:16', 'Voc:8', 'Shuffled');
        
        subplot(212);
        plot(f,20*log10(squeeze(mean(all_avg_spectrum,2))),'Linewidth',2);
        grid on
        xlim(display_frequency_range);
        title('all_avg_spectrum','interpreter','none');
        xlabel('frequency (Hz)')
        ylabel('power (dB)')
        set(gca,'xtick',f_label,'FontName','Times New Roman','FontSize',20);
        legend ('Natural','Voc:16', 'Voc:8', 'Shuffled');
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    case{'tone_1000'}
        
        grand_ave = zeros (20,160,701);
         
        for iSubject = 1:length(allSubjects_tone_1000)
            
            subject                         = allSubjects_tone_1000{iSubject};
            sensor_resultsDir               = fullfile(sensor_dataDir,subject);            
            load ([sensor_resultsDir,'/layout_meg_orig.mat']);
                    
            switch use_ICA
                
                case {'Y'}
                    
                    load ([sensor_resultsDir,'/data_meg_prep_',test_name,'_ICA.mat']);
                    disp('*******************************')
                    disp(['processing ' subject,'_', test_name,' with ICA']);
                    disp('*******************************')
                    
                    if exist(fullfile(sensor_resultsDir,['data_meg_ave_',test_name,'_ICA.mat']),'file')==2
                        load (fullfile(sensor_resultsDir,['data_meg_ave_',test_name,'_ICA.mat']))
                        
                    else
                        
                        cfg                                 = [];
                        cfg.covariance                      = 'yes';
                        cfg.covariancewindow                = [-inf 0]; % 3 s before the spike
                        data_meg_ave                        = ft_timelockanalysis(cfg,data_meg_prep);
                        save(fullfile(sensor_resultsDir,['data_meg_ave_',test_name,'_ICA.mat']), 'data_meg_ave');
                    end
                    
                case{'N'}
                    
                    load ([sensor_resultsDir,'/data_meg_prep_',test_name,'.mat']);
                    disp('*******************************')
                    disp(['processing ' subject,'_', test_name]);
                    disp('*******************************')
                    
                    if exist(fullfile(sensor_resultsDir,['data_meg_ave_',test_name,'.mat']),'file')==2
                        load (fullfile(sensor_resultsDir,['data_meg_ave_',test_name,'.mat']))
                        
                    else
                        
                        cfg                                 = [];
                        cfg.covariance                      = 'yes';
                        cfg.covariancewindow                = [-inf 0]; % 0.2 s before trigger
                        data_meg_ave                        = ft_timelockanalysis(cfg,data_meg_prep);
                        save(fullfile(sensor_resultsDir,['data_meg_ave_',test_name,'.mat']), 'data_meg_ave');
                    end
            end
                                    
%             figure
%             plot(data_meg_ave.time, data_meg_ave.avg)
%             title([allSubjects_tone_1000{iSubject},': AEF'],'interpreter','none');
%             
%             figure           
%             cfg          = [];
%             cfg.layout   = layout_meg_orig;
%             cfg.baseline = [-0.3 0];
%             
%             cfg.xlim = [0.08 0.12];
%             ft_topoplotER(cfg, data_meg_ave);
%             title([allSubjects_tone_1000{iSubject},': AEF'],'interpreter','none');
            
            grand_ave (iSubject,:,:) = data_meg_ave.avg;
            
        end
        
        data_meg_ave.avg = squeeze(mean(grand_ave,1));
        
        figure
        plot(data_meg_ave.time,  data_meg_ave.avg)
        title('Grand average AEF');
               
        
        figure
        cfg          = [];
        cfg.layout   = layout_meg_orig;
        cfg.baseline = [-0.3 0];
        
        cfg.xlim = [0.08 0.12];
        ft_topoplotER(cfg, data_meg_ave);
        title('Grand average AEF','interpreter','none');        
       
end