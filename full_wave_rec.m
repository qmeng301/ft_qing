close all
clear
clc

fs = 44100;
t_length = 2.5;

am_4hz = audioread('./am_sound_files/4hz_am.wav');
am_5hz = audioread('./am_sound_files/5hz_am.wav');
am_6hz = audioread('./am_sound_files/6hz_am.wav');
am_7hz = audioread('./am_sound_files/7hz_am.wav');
am_8hz = audioread('./am_sound_files/8hz_am.wav');

t_axis = (1:t_length*fs)/fs;

f_res = fs/(t_length*fs);

f_axis = (1:t_length*fs)*f_res;

figure(1)
plot(t_axis,am_8hz)

rec_4hz = abs(am_4hz);
rec_5hz = abs(am_5hz);
rec_6hz = abs(am_6hz);
rec_7hz = abs(am_7hz);
rec_8hz = abs(am_8hz);

figure(2)
plot(t_axis,abs(am_8hz))

[b,a] = butter(6,30*2*pi/fs,'low');
env_4hz = filter(b,a,rec_4hz);
env_5hz = filter(b,a,rec_5hz);
env_6hz = filter(b,a,rec_6hz);
env_7hz = filter(b,a,rec_7hz);
env_8hz = filter(b,a,rec_8hz);

figure(3)
% plot(t_axis,env_4hz)
%plot(t_axis,env_5hz)
% plot(t_axis,env_6hz)
% plot(t_axis,env_7hz)
plot(t_axis,env_8hz)

f_env_4hz = fft(env_4hz);
f_env_5hz = fft(env_5hz);
f_env_6hz = fft(env_6hz);
f_env_7hz = fft(env_7hz);
f_env_8hz = fft(env_8hz);


figure(4)
% loglog(f_axis(1:length(f_axis)/2+1),abs(f_env_4hz(1:length(f_env_4hz)/2+1)));
% loglog(f_axis(1:length(f_axis)/2+1),abs(f_env_5hz(1:length(f_env_5hz)/2+1)));
% loglog(f_axis(1:length(f_axis)/2+1),abs(f_env_6hz(1:length(f_env_6hz)/2+1)));
% loglog(f_axis(1:length(f_axis)/2+1),abs(f_env_7hz(1:length(f_env_7hz)/2+1)));
loglog(f_axis(1:length(f_axis)/2+1),abs(f_env_8hz(1:length(f_env_8hz)/2+1)));

total = [zeros(0.2*fs,1);env_4hz;zeros(0.1*fs,1);zeros(0.2*fs,1);env_5hz;zeros(0.1*fs,1);...
    zeros(0.2*fs,1);env_6hz;zeros(0.1*fs,1);zeros(0.2*fs,1);env_7hz;zeros(0.1*fs,1);...
    zeros(0.2*fs,1);env_8hz;zeros(0.1*fs,1)];

save env_4-8hz.mat total;
% save env_5hz.mat env_5hz;
% save env_6hz.mat env_6hz;
% save env_7hz.mat env_7hz;
% save env_8hz.mat env_8hz;

