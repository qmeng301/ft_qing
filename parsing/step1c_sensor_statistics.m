clear
close all
clc

use_ICA                 = 'N';
sensor_dataDir          = './sensor_space/MEG/Adult/English';

condition               = {'natural','voc_16','voc_8','shuffled'};
%%

switch use_ICA
    
    case {'Y'}       
        file_to_load_1 = fullfile(sensor_dataDir,'group_result/all_itc_spectrum_ICA.mat');
        file_to_load_2 = fullfile(sensor_dataDir,'group_result/all_avg_spectrum_ICA.mat'); 
        disp('use ICA cleaned data');
        
    case{'N'}        
        file_to_load_1 = fullfile(sensor_dataDir,'group_result/all_itc_spectrum.mat');
        file_to_load_2 = fullfile(sensor_dataDir,'group_result/all_avg_spectrum.mat');
        disp('use data without ICA');
end

load (file_to_load_1);
load (file_to_load_2);
load (fullfile(sensor_dataDir,'group_result/frequency_axis.mat'));
fs = 1000;


[syllable_min,syllable_ind] = min(abs(f(1,:) - 3.125));
[phrase_min,phrase_ind] = min(abs(f(1,:) - 1.5625));
[sentence_min,sentence_ind] = min(abs(f(1,:) - 0.78125));


f_points_ind = find (f<5);
% 
h_ave = zeros (67,1);
p_ave = zeros (67,1);

h_itc = zeros (67,1);
p_itc = zeros (67,1);

for cond_i =1:4

    for i = 3:length(f_points_ind)-2
        
        avg_spectrum = squeeze(all_avg_spectrum(cond_i,:,f_points_ind(i)))';
        itc_spectrum = squeeze(all_itc_spectrum(cond_i,:,f_points_ind(i)))';
        
        neighbour_ind = [f_points_ind(i)-2, f_points_ind(i)-1, f_points_ind(i)+1, f_points_ind(i)+2];
        
        neighbour_avg_spectrum = mean(squeeze(all_avg_spectrum(1,:,neighbour_ind)),2);
        neighbour_itc_spectrum = mean(squeeze(all_itc_spectrum(1,:,neighbour_ind)),2);
        
        [h_ave(i,1),p_ave(i,1)] = ttest(avg_spectrum,neighbour_avg_spectrum,'dim',1,'Tail','right');
        [h_itc(i,1),p_itc(i,1)] = ttest(itc_spectrum,neighbour_itc_spectrum,'dim',1,'Tail','right');
        
    end
    
    
    p_ave_fdr = fdr0(p_ave,0.05);
    p_itc_fdr = fdr0(p_itc,0.05);
    
    [rows_ave,cols_ave,vals_ave] = find(p_ave_fdr ==1);
    [rows_itc,cols_itc,vals_itc] = find(p_itc_fdr ==1);
    
    
    if find (rows_ave == syllable_ind)
        
        disp ([condition{cond_i}, ': syllable response significant after correction, p = ', num2str(p_ave (syllable_ind))])

        
    end
    
    if find (rows_ave == phrase_ind)
       
        disp ([condition{cond_i}, ': phrase response significant after correction, p = ', num2str(p_ave (phrase_ind))])
    end
        
    if find (rows_ave == sentence_ind)
        
        disp ([condition{cond_i}, ': sentence response significant after correction, p = ',  num2str(p_ave (sentence_ind))])
    end
    
    
    
    if find (rows_itc == syllable_ind)
        
        disp ([condition{cond_i}, ': syllable ITC significant after correction, p = ',num2str(p_itc (syllable_ind))])
    end
    
    if find (rows_itc == phrase_ind)
       
        disp ([condition{cond_i}, ': phrase ITC significant after correction, p = ',num2str(p_itc (phrase_ind))])
    end
        
    if find (rows_itc == sentence_ind)
        
        disp ([condition{cond_i}, ': sentence ITC significant after correction, p = ',num2str(p_itc (sentence_ind))])
    end
    
    

end
