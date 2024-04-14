% This script lets you run an FMCW Radar continuously for a certain number
% of steps.
% 
% % Setup:
%
% Connect the Vivaldi antenna to Phaser SMA Out2. Place the Vivaldi antenna
% in the field of view of the Phaser and point it at the Phaser.
%
% Notes:
%
% Run this script to continuously run the FMCW radar for demonstration.
% The first time this script is run, the data collection may not occur
% properly.
%
% Copyright 2023 The MathWorks, Inc.

% Max Sampling Rate Phaser          = 61.44 MHz

% Carrier frequency                 = 10 GHz
% Light speed                       = 299 792 458 m/s
% Lambda                            = 3 cm
% Maximum range                     = 5 m
% % % Range resolution                  = 0.3 m
% % % Maximum velocity                  = 149.89 m/s
% % % Speed resolution                  = 1.17 m/s
% Ramp Bandwidth                    = 500 MHz
% % % Maximum Doppler Frequency shift   = 10 KHz
% PRF (Pulse Repetition Frequency)  = 500 Hz
% PRI (Pulse Repetition Interval)   = 2 ms
% Number of Pulses per Frame        = 256
% Pulse Duration                    = 512 us
% Sweep Duration                    = 512 us
% Sweep Slope                       = 9.76 GHz/ms
% Maximum Beat Frequency            = 32.575 KHz
% Sampling Frequency                = 520.834 KHz
% Number of frames                  = 100 frames
% Number of samples per pulse       = 534
% Time frame                        = 131 ms
   
%% Clear workspace and load calibration weights

clear; close all; clc;

%% First, setup the system, see fmcwDemo.m for more details

% Carrier frequency
fc = 10e9;
c = physconst("LightSpeed");
lambda = physconst("LightSpeed")/fc;

% Put some requirements on the system
maxRange = 5;
% rangeResolution = 0.3;
maxSpeed = 3;
% speedResolution = 0.001175;

% Determine some parameter values
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

typeExer = input('Which exercise?: ', 's');
numExe = input('Number of sample: ');
state = input('Good or bad?: ', 's');

%%

% See fmcw demo for these setup steps
[rx,tx,bf,bf_TDD,model] = setupFMCWRadar(fc,fs,tpulse,tsweep,nPulses,rampbandwidth);

% Clear cache
rx();

% Use constant amplitude baseband transmit data
amp = 0.9 * 2^15;
txWaveform = amp*ones(rx.SamplesPerFrame,2);

%% Next, run continuously for nCaptures

nCaptures = 410;

framesRadar = zeros([267,256,20]);
framesRadarIQ = zeros([68267,2,20]);
 
% Create a range doppler plot
rd = phased.RangeDopplerResponse(DopplerOutput="Speed",...
    OperatingFrequency=fc,SampleRate=fs,RangeMethod="FFT",...
   SweepSlope=sweepslope,PRFSource="Property",PRF=prf);

f1 = figure;
ax = axes(f1);
h = 1;

for i = 1:nCaptures
    data = captureTransmitWaveform(txWaveform,rx,tx,bf);
    fprintf('Frame: %d \n', i);
    
    if i > 10
        framesRadarIQ(:,:,h) = data;

        if (i-10) > 0 
            if rem((i-10),20) == 0
                for j = 1:20
                    data = framesRadarIQ(:,:,j);
                    data = arrangePulseData(data,rx,bf,bf_TDD);
                    framesRadar(:,:,j) = data;

                    figure(f1);
                    rd.plotResponse(data);
                    xlim(ax,[-maxSpeed,maxSpeed]); ylim(ax,[0,maxRange]);
                    drawnow;
                    pause(0.1);
                end

                answer = input('Is it okay?: ', 's');
                if answer == 'y'
                    saveExercise(framesRadar, framesRadarIQ, numExe, typeExer, state)
                    fprintf("Saved: " + num2str(numExe) + "\n");
                    numExe = numExe + 1;
                end
                
                if i ~= nCaptures
                    fprintf('Starting in.. 6 ');
                    pause(1);
                    fprintf('5 ');
                    pause(1);
                    fprintf('4 ');
                    pause(1);
                    fprintf('3 ');
                    pause(1);
                    fprintf('2 ');
                    pause(1);
                    fprintf('1 \n');
                    pause(1);
                end
            end
        end

        if h < 20
            h = h + 1;
        else
            framesRadarIQ = zeros([68267,2,20]);
            h = 1;
        end
    end
end

% Disable TDD Trigger so we can operate in Receive only mode
disableTddTrigger(bf_TDD)

%%
%save("subject8_3_20_4pm_ov_1m.mat","framesRadar", "framesRadarIQ");
%save("subject8_3_20_4pm_ov_05m.mat","framesRadar", "framesRadarIQ");

