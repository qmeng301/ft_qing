cd /Users/mq20132881/qing/phd/projects/ME148/parsing_analysis
addpath ../../fieldtrip-20160515;
ft_defaults


%% Masanori: tone in noise

allSubjects_tone_masa       = {'0021_RG','0045_RH'};
allConditions_tone_masa     = {'B1','B2'};

% MEG data file names and directory
allFiles_tone_masa  = {'MEGIII_0021_RG_2017_03_31_masa', 'MEGIII_0021_RG_2017_03_31_masa_ci',...
    'MEGIII_0045_RH_2017_04_06_masa', 'MEGIII_0045_RH_2017_04_06_masa_ci'};

raw_dataDir_MEG     = '../raw_data/MEG/MEGIII/English';
raw_dataDir_MRI     = '../raw_data/MRI/English';

sensor_dataDir      = './sensor_space/MEG/MEGIII/English';
source_dataDir      = './source_space/MEGIII/English';

