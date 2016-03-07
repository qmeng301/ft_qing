%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The Fourier Transform
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear
close all
 
% get a sine and cosine wave of equal frequency and plot them
frq = 20; % Hz
len = 1; % seconds
smpfrq = 1000; % Hz
phs = 0;
ind = ((0:(len * smpfrq-1))./(smpfrq).*(frq.*2.*pi))+(phs.*2.*pi);
sinwav = sin(ind);
coswav = cos(ind);
figure;
plot(sinwav);
hold on;
plot(coswav,'r');
 
% get the FFT of the waves and plot the real and imaginary components
fftsin = fft(sinwav);
figure;
subplot(2,1,1);
plot(real(fftsin));
subplot(2,1,2);
plot(imag(fftsin),'r');
 
fftcos = fft(coswav);
figure;
subplot(2,1,1);
plot(real(fftcos));
subplot(2,1,2);
plot(imag(fftcos),'r');


% calculate the FFT results at the signal frequency "by hand" and plot the result as a vector
figure;
subplot(2,1,1);
sigsinwav = sinwav;
plot(sigsinwav .* coswav)
subplot(2,1,2);
plot(sigsinwav .* sinwav)
coscmpsin = sum(sigsinwav .* coswav);
sincmpsin = sum(sigsinwav .* sinwav);
figure;
plot([0,coscmpsin],[0,sincmpsin]);
set(gca,'xlim',[-600 600],'ylim',[-600 600])
 
figure;
subplot(2,1,1);
plot(coswav .* coswav)
subplot(2,1,2);
plot(coswav .* sinwav)
coscmpcos = sum(coswav .* coswav);
sincmpcos = sum(coswav .* sinwav);
figure;
plot([0,coscmpcos],[0,sincmpcos]);
set(gca,'xlim',[-600 600],'ylim',[-600 600])


frq = 20; % Hz
len = 1; % seconds
smpfrq = 1000; % Hz
phs = 45 ./360; % the relative phase advance in fraction of radiants
ind = ((0:(len.*smpfrq-1))./(smpfrq).*(frq.*2.*pi))+(phs.*2.*pi);
wav = sin(ind);
figure;
plot(wav);

% get the FFT of the wave
fftwav = fft(wav);
figure;
subplot(2,1,1);
plot(real(fftwav));
subplot(2,1,2);
plot(imag(fftwav),'r');


% calculate the FFT results at the signal frequency "by hand" and plot the result as a vector
figure;
subplot(2,1,1);
plot(wav .* coswav)
subplot(2,1,2);
plot(wav .* sinwav)
coscmpwav = sum(wav .* coswav)
sincmpwav = sum(wav .* sinwav)
figure;
plot([0,coscmpwav],[0,sincmpwav]);
set(gca,'xlim',[-600 600],'ylim',[-600 600])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% generate a wave of a different frequency
frq = 10; % Hz
len = 1; % seconds
smpfrq = 1000; % Hz
phs = 0; % the relative phase advance in fraction of radiants
ind = ((0 : (len.*smpfrq -1))./(smpfrq).*(frq.*2.*pi))+(phs.*2.*pi);
wav = sin(ind);
figure;
plot(wav);
 
% get the FFT of the wave
fftwav = fft(wav);
figure;
subplot(2,1,1);
plot(real(fftwav));
subplot(2,1,2);
plot(imag(fftwav),'r');
 
% calculate the FFT result OF THE SIGNAL FREQUENCY "by hand"
figure;
subplot(2,1,1);
plot(wav .* coswav)
subplot(2,1,2);
plot(wav .* sinwav)
 
coscmpwav = sum(wav .* coswav)
sincmpwav = sum(wav .* sinwav)
