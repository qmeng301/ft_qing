close all
clear 
clc

preparation_MEG

%%

for iSubject = 1:length(allSubjects_parsing)
    
    subject                         = allSubjects_parsing{iSubject};
    raw_SubjectdataDir              = fullfile(raw_dataDir_MEG,subject);
    sensor_resultsDir               = fullfile(sensor_dataDir,subject);
    
    for iCondition = 1:length(allConditions_parsing)
        condition = allConditions_parsing{iCondition};
        
        load (fullfile(sensor_resultsDir,['data_meg_pow_',test_name,'_',condition]));
        
    end
    
end
cfg                          = [];
cfg.method                   = 'mtmfft';
cfg.output                   = 'fourier';
cfg.foilim                   = [0.6 4.5];
cfg.taper                    = 'hanning';
cfg.channel                  = 'MEG';
data_meg_fourier             = ft_freqanalysis(cfg, data_meg_prep);
%data_meg_fourier             = ft_freqanalysis(cfg, data_meg_visual);

itc                          = [];
itc.label                    = data_meg_fourier.label;
itc.freq                     = data_meg_fourier.freq;
%itc.time                    = data_meg_fourier.time;
itc.dimord                   = 'chan_freq_time';

F                            = data_meg_fourier.fourierspctrm;   % copy the Fourier spectrum
N                            = size(F,1);           % number of trials

% compute inter-trial phase coherence (itpc)
itc.itpc                     = F./abs(F);         % divide by amplitude
itc.itpc                     = sum(itc.itpc,1);   % sum angles over trials
itc.itpc                     = abs(itc.itpc)/N;   % take the absolute value and normalize
itc.itpc                     = squeeze(itc.itpc); % remove the first singleton dimension

% compute inter-trial linear coherence (itlc)
itc.itlc                     = sum(F) ./ (sqrt(N*sum(abs(F).^2,1)));
itc.itlc                     = abs(itc.itlc);     % take the absolute value, i.e. ignore phase
itc.itlc                     = squeeze(itc.itlc); % remove the first singleton dimension

figure
subplot(2,1,1);
plot(itc.freq, squeeze(sum(itc.itpc(1,:,:),1)));
axis xy
title([allSubjects_parsing{iSubject},'_',condition,': inter-trial phase coherence'],'interpreter','none');
ylim ([0, 1])
grid on

subplot(2,1,2);
plot(itc.freq, squeeze(sum(itc.itlc(1,:,:),1)));
axis xy
title([allSubjects_parsing{iSubject},condition,': inter-trial linear coherence'],'interpreter','none');
ylim ([0, 1])
grid on

