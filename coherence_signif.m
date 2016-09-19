clear
close all
clc

x = rand(20,1)

y = rand(20,1)

p = 0.95;

nb = 100;


[sl, slf, df, F] = cohere_bootstrap_signif_level( x, y, p, nb)