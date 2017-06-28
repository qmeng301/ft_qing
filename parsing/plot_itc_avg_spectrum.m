function [itc_spectrum,avg_spectrum,f]=plot_itc_avg_spectrum(eeg_data,fs)
%     calculate and plot the neural response spectrum
%     input:
%         eeg_data (time * channel * trial)
%         fs (sampling rate in Hz)
%         display_frequency_range (the frequency range that will be plotted)
%         f_label (optional, frequencies being labeled)
%     output:
%         itc_sprectrum (frequency * channel, inter-trial phase coherence spectrum R^2),
%         avg_spectrum (frequency * channel, power spectrum of the response averaged over trials)
%         f (frequency labels)
%     example:
%           plot_itc_avg_spectrum(eeg_data,200,[0.5,4.5],1:4);
%
% Nai Ding & Wen Zhang, 2016
% ding_nai@zju.edu.cn

f=1:size(eeg_data,1);f=f-1;f=f/size(eeg_data,1);f=f*fs;

az = zeros(size(eeg_data,1),size(eeg_data,3),size(eeg_data,2));
for ch = 1:size(eeg_data,2)
  az(:,:,ch) = angle(fft(squeeze(eeg_data(:,ch,:))));
end
itc_spectrum = squeeze(pcoh3(az));
avg_spectrum = abs(fft(mean(eeg_data,3)));
% figure;
% subplot(211);
% plot(f,itc_sprectrum);
% xlim(display_frequency_range);
% xlabel('frequency (Hz)')
% ylabel('inter-trial phase coherence')
% try
%   set(gca,'xtick',f_label);end
% title('itc\_sprectrum');
% subplot(212);
% plot(f,avg_spectrum);
% xlim(display_frequency_range);
% title('avg\_spectrum');
% xlabel('frequency (Hz)')
% ylabel('power (a.u.)')
% try
%   set(gca,'xtick',f_label);end
end

function r=pcoh3(ag)
c=cos(ag);
s=sin(ag);
r=mean(c,2).^2+mean(s,2).^2;
end
