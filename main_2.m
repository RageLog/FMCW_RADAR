clc;clear;close all;
%% Parameters;
a = Parameters;
a.DeltaR = 0.1; % m
a.DeltaV = 1; % m/s
a.Rmax = 150; % m
a.Vmax = 450; % m/s

a.TRate = 0;
a.Ts = 1e-6;
a.Ts_Up = a.Ts * a.TRate;
a.Ts_Dawn = a.Ts *(1- a.TRate);
a.To = 1*a.Ts ;

a.Fc = 10e9;
Fmin = a.Fc - a.C0/(2*a.DeltaR);
Fmax = a.Fc + a.C0/(2*a.DeltaR);

a.Fd = Fmax - Fmin;
a.Fs = 2*(((a.Fd*a.Rmax)/(a.C0*a.Ts_Dawn))+(a.Fc*a.Vmax/a.C0));
a.Lambda = a.C0/a.Fc;

a.VCO = VCO(5,Fmin,Fmax,0,12,0,0);

a.NumOfMod = floor(a.To / a.Ts);
a.SampPerMod = floor(a.Ts*a.Fs);

a.PowerAmplifierGain  = 20;
a.PowerSplitterRate = 0.5;
a.LnaGain = 20;

a.VcomMin = 0;
a.VcomMax = 12;

b = SignalGenerator(a);


