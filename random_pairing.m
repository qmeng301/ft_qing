close all
clear 
clc

addpath ./fieldtrip-20160515;
ft_defaults
%% read in eeg_env data and randomize enve data

load env_6hz_resam.mat;
load data_eeg_env.mat

num_randomization                       = 100;
num_trial                               = 200;
rand_powspctrm                          = zeros(65,num_randomization);
rand_crsspctrm                          = zeros(2080,num_randomization);
cohspectrm_random                       = zeros (64,51,num_randomization); % random coherence calculated at num_iteration times
    
for i = 1:num_randomization

    for j = 1:num_trial        
        index_random                    = unidrnd(length(env_6hz_resam),length(env_6hz_resam),1);
        data_eeg_env.trial{i}(65,:)     = 50 * env_6hz_resam(index_random)';
    end
    
    cfg                                 = [];
    cfg.method                          = 'mtmfft';
    cfg.output                          = 'powandcsd';
    cfg.foilim                          = [0 20];
    cfg.taper                           = 'hanning';
    cfg.channel                         = {'eeg' 'envelope'};
    cfg.channelcmb                      = {'eeg' 'envelope'};
    data_eeg_rpowcsd                    = ft_freqanalysis(cfg, data_eeg_env);
    
    
    cfg                                 = [];
    cfg.method                          = 'mtmfft';
    cfg.output                          = 'powandcsd';
    cfg.foilim                          = [6 6];
    cfg.taper                           = 'hanning';
    cfg.channel                         = {'eeg' 'envelope'};
    cfg.channelcmb                      = {'eeg' 'eeg';'eeg' 'envelope'};
    data_eeg_rspowcsd                    = ft_freqanalysis(cfg, data_eeg_env);
    
    cfg                                 = [];
    cfg.method                          = 'coh';
    cfg.channel                         = {'eeg' 'envelope'};
    cfg.channelcmb                      = {'eeg' 'envelope'};
    data_eeg_rcoh                       = ft_connectivityanalysis(cfg, data_eeg_rpowcsd);
    
    
    rand_powspctrm(:,i)                 = data_eeg_rspowcsd.powspctrm;
    rand_crsspctrm(:,i)                 = data_eeg_rspowcsd.crsspctrm;
    cohspectrm_random(:,:,i)            = data_eeg_rcoh.cohspctrm;
    
end

save rand_powspctrm.mat rand_powspctrm
save rand_crsspctrm.mat rand_crsspctrm
% save cohspectrm_random_no_env.mat cohspectrm_random

%% calculate significance level

%plot (squeeze(cohspectrm_random(15,16,:))') % 5000 random paring coherence value
%hist(squeeze(cohspectrm_random(15,16,:))',10000);

[coh_val_counts,coh_val_bin]            = hist(squeeze(cohspectrm_random(15,:,:))',10000); % T7 and 6Hz
coh_val_cum_sum                         = cumsum(coh_val_counts,1);
p_value                                 = [0.95,0.995];
sig_coh_val_f                           = zeros(2,51);

for pi = 1:2

    for k = 1:51
        [cum_sum_unique,ind_coh_unique] = unique(coh_val_cum_sum(:,k));
        sig_coh_val_f(pi,k)             = interp1( cum_sum_unique, coh_val_bin(ind_coh_unique), num_randomization*p_value(pi), 'linear', 0 );
    end

end

figure (1)
plot(sig_coh_val_f(1,:),'--r')
hold on
plot(sig_coh_val_f(2,:),'-.g')
legend ('p< 0.05', 'p<0.005')

figure (2)
plot(cum_sum_unique, coh_val_bin(ind_coh_unique))

%save sig_coh_val_f_no_env.mat sig_coh_val_f