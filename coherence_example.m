%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The Coherence spectrum
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get many repetitions of two signals with random phase difference
clear
close all
clc

 
frq = 10; % Hz
len = 1; % seconds
smpfrq = 100; % sampling frequency in Hz
numrpt = 2; % number of repetitions
ranphs = rand(2.*numrpt,2);
phsdif = 45 / 360; % phase difference
noifac = 1 /50; % noise factor
for rptlop = 1:numrpt
    rptlop
  wav(:,rptlop,1) = sin(((0:(len * smpfrq-1))./(smpfrq).*(frq.*2.*pi))+(ranphs(rptlop,1).*2*pi)) + ...
    randn(1,len.*smpfrq).*noifac;
  wav(:,rptlop,2) = sin(((0:(len * smpfrq-1))./(smpfrq).*(frq.*2.*pi))+((ranphs(rptlop,2)+phsdif).*2.*pi)) + ...
    randn(1,len.*smpfrq).*noifac;
end

figure()
subplot(2,1,1)
plot(ranphs(:,1).*2*pi)
hold on
plot((ranphs(:,2)+phsdif).*2.*pi,'r')

subplot(2,1,2)
plot(ranphs(:,1).*2*pi - (ranphs(:,2)+phsdif).*2.*pi)
 
% get the FFT of the waves
for rptlop = 1:numrpt
  fftwav(:,rptlop,1) = fft(wav(:,rptlop,1));
  fftwav(:,rptlop,2) = fft(wav(:,rptlop,2));
end
 
% calculate the power-spectral densities (psd) and the cross-spectral
% densities (csd) and sum them over repetitions
numsmp = length(wav);
psd = 2.*abs(fftwav).^2./(numsmp.^2);
csd = 2.*(fftwav(:,:,1).*conj(fftwav(:,:,2)))./(numsmp.^2);
sumpsd = squeeze(sum(psd,2));
sumcsd = squeeze(sum(csd,2));
 
% calculate coherence
coh = abs(sumcsd ./ sqrt(sumpsd(:,1) .* sumpsd(:,2)));
 
figure;
plot(squeeze(wav(:,:,1)));
figure;
plot(squeeze(wav(:,:,2)));
figure;
plot(squeeze(sum(wav,2)));

figure;
plot(coh);

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get many repetitions of two signals with somewhat consistent phase difference
clear
close all
 
frq = 10; % Hz
len = 1; % seconds
smpfrq = 100; % Hz
numrpt = 8000;
phsspreadfac = 0.5;
circulran = mod(randn(2.*numrpt,2).*phsspreadfac + pi, 2 * pi) - pi;
ranphs = circulran ./ (2 .* pi);
phsdif = 45 ./ 360;
noifac = 1./50;

% for rptlop = 1:numrpt
%   wav(:,rptlop,1) = sin(((0:(len.*smpfrq-1))./(smpfrq).*(frq.*2.*pi))+(ranphs(rptlop,1).*2.*pi)) + ...
%     randn(1,len.*smpfrq).*noifac;
%   wav(:,rptlop,2) = sin(((0:(len.*smpfrq-1))./(smpfrq).*(frq.*2.*pi))+((ranphs(rptlop,2)+phsdif).*2.*pi)) + ...
%     randn(1,len.*smpfrq).*noifac;
% end

for rptlop = 1:numrpt
  wav(:,rptlop,1) = sin(((0:(len * smpfrq-1))./(smpfrq).*(frq.*2.*pi))+(ranphs(rptlop,1).*2.*pi)) + ...
    randn(1,len.*smpfrq).*noifac;
  wav(:,rptlop,2) = sin(((0:(len * smpfrq-1))./(smpfrq).*(frq.*2.*pi))+((ranphs(1,2)+phsdif).*2.*pi)) + ...
    randn(1,len.*smpfrq).*noifac;
end

% envelope = sin(((0:(len * smpfrq-1))./(smpfrq).*(frq.*2.*pi))+(ranphs(1,2).*2.*pi)) + ...
%     randn(1,len.*smpfrq).*noifac;

% get the FFT of the waves
for rptlop = 1:numrpt
  fftwav(:,rptlop,1) = fft(wav(:,rptlop,1));
  fftwav(:,rptlop,2) = fft(wav(:,rptlop,2));
end
 
% calculate the power-spectral densities (psd) and the cross-spectral
% densities (csd) and sum them over repetitions
numsmp = length(wav);
psd = 2.*abs(fftwav).^2./(numsmp.^2);
csd = 2.*(fftwav(:,:,1).*conj(fftwav(:,:,2)))./(numsmp.^2);
sumpsd = squeeze(sum(psd,2));
sumcsd = squeeze(sum(csd,2));
 
% calculate coherence
coh = abs(sumcsd ./ sqrt(sumpsd(:,1) .* sumpsd(:,2)));
 
figure;
plot(squeeze(wav(:,:,1)));
figure;
plot(squeeze(wav(:,:,2)));
figure;
plot(coh);