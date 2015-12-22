close all
clear 
clc

cond = '1000Hz';

load('analysis/data_clean', 'data')

for icond = 1:4 % loop over the 4 conditions    
  for istim = 1:3 % loop over standard-before, deviant, standard-after
      
    % compute timelocked averages for each condition
    cfg=[];
    cfg.lpfilter   = 'yes';
    cfg.lpfreq     = 40;
    cfg.trials   = find(data.trialinfo(:,3) == icond & data.trialinfo(:,4) == istim);
    timelock{icond,istim} = ft_timelockanalysis(cfg, data);
      
    % baseline correct
    cfg=[];
    cfg.baseline = [-0.2 0];
    timelock{icond,istim} = ft_timelockbaseline(cfg, timelock{icond,istim});
  end  
end

save('analysis/timelock/timelock_all','timelock');

% plot the ERPs over all sensors
figure
for i = 1:4
  subplot(2,2,i);
  ft_singleplotER([],timelock{i,1},timelock{i,2},timelock{i,3});
  title(cond{i});
  if i==1
    legend('standard-before', 'deviant', 'standard-after', 'Location', 'NorthWest')
  end
end
print(gcf, '-dpng', 'figures/fig1_ERP')

% plot ERP in interactive mode, only for standard-before
cfg = [];
cfg.layout      = 'biosemi160lay.mat';
cfg.interactive = 'yes';
figure; ft_multiplotER(cfg,timelock{1,1});

% compute the contrasts
for icond = 1:4
  % standard before vs deviant
  stb_vs_dev{icond} = timelock{1,1};
  stb_vs_dev{icond}.avg = timelock{icond,2}.avg - timelock{icond,1}.avg;
  
  % standard before vs standard after
  stb_vs_sta{icond} = timelock{1,1};
  stb_vs_sta{icond}.avg = timelock{icond,3}.avg - timelock{icond,1 }.avg;
  
end

% plot the contrasts
figure
for icond = 1:4
  cfg=[];
  cfg.xlim        = [0.5 7];
  cfg.zlim        = 'maxabs';
  cfg.interactive = 'yes';
  cfg.layout      = 'biosemi160lay.mat';
  cfg.colorbar    = 'yes';
  
  subplot(2,2,icond);
  ft_topoplotER(cfg, stb_vs_dev{icond});
end
print(gcf, '-dpng', 'figures/fig2_ERP')

figure
for icond = 1:4
  cfg=[];
  cfg.xlim        = [0.5 7];
  cfg.zlim        = 'maxabs';
  cfg.interactive = 'yes';
  cfg.layout      = 'biosemi160lay.mat';
  cfg.colorbar    = 'yes';
  
  subplot(2,2,icond);
  ft_topoplotER(cfg, stb_vs_sta{icond});
end
print(gcf, '-dpng', 'figures/fig3_ERP')



%% now collapse

% compute averages for pitch and timbre
for istim = 1:3
  cfg=[];
  cfg.lpfilter   = 'yes';
  cfg.lpfreq     = 40;
  cfg.keeptrials = 'yes';
  cfg.trials     = find((data.trialinfo(:,3) == 1 | data.trialinfo(:,3) == 2 ) & data.trialinfo(:,4) == istim);
  timelock_pitch{istim}  = ft_timelockanalysis(cfg, data);
  
  cfg.trials     = find((data.trialinfo(:,3) == 3 | data.trialinfo(:,3) == 4 ) & data.trialinfo(:,4) == istim);
  timelock_timbre{istim} = ft_timelockanalysis(cfg, data);
  
  cfg=[];
  cfg.baseline   = [-0.2 0];
  timelock_pitch{istim}  = ft_timelockbaseline(cfg, timelock_pitch{istim});
  timelock_timbre{istim} = ft_timelockbaseline(cfg, timelock_timbre{istim});
end
save('analysis/timelock/timelock_avg','timelock_*');


% plot contrasts
figure
subplot(1,2,1);
ft_singleplotER([],timelock_pitch{1},timelock_pitch{2},timelock_pitch{3});
title('Pitch');

subplot(1,2,2);
ft_singleplotER([],timelock_timbre{1},timelock_timbre{2},timelock_timbre{3});
title('Timbre');

print(gcf, '-dpng', 'figures/fig4_ERP')