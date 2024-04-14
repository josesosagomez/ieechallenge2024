close all; clear all; clc

%%

exercise = 1;
path = "sample_exercises\knee\good_technique\exercise_"+ exercise +".mat";
load(path);

%%

fc = 10e9;
c = physconst("LightSpeed");
lambda = physconst("LightSpeed")/fc;
maxRange = 3.5;
maxSpeed = 2.5;
rampbandwidth = 500e6;
pri = 2e-3;
prf = 1/pri;
nPulses = 256;
tpulse = 0.512e-3;
tsweep = getFMCWSweepTime(tpulse,tpulse);
sweepslope = rampbandwidth / tsweep;
fmaxbeat = sweepslope * range2time(maxRange);
fs = max(ceil(2*fmaxbeat),520834);

%%

rd = phased.RangeDopplerResponse(DopplerOutput="Speed",...
     OperatingFrequency=fc,SampleRate=fs,RangeMethod="FFT",...
     SweepSlope=sweepslope,PRFSource="Property",PRF=prf);

f1 = figure;
ax = axes(f1);

for j = 1:size(framesRadar,3)
    frame = framesRadar(:,:,j);
    
    figure(f1);
    rd.plotResponse(frame);
    xlim(ax,[-maxSpeed,maxSpeed]); ylim(ax,[0,maxRange]);
    drawnow;
    pause(0.3);
end
