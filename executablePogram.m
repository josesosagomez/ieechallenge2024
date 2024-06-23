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
load("availableExercises.mat");

%%

typeExer = 0;
exercises = [];
repetitions = [];

while typeExer ~= 7
    fprintf(' \n');
    disp('1. Arms Raise');
    disp('2. Leg Raise');
    disp('3. Bow');
    disp('4. Squads');
    disp('5. Lounges');
    disp('6. Elbow to Knee');
    disp('7. Done');
    typeExer = input('Which exercise?: ');

    if typeExer ~= 7
        numExe = input('Number of repetitions: ');
        exercises = [exercises typeExer];
        repetitions = [repetitions numExe];
    end
end

%%

chosenExercises = {};
for i = 1:size(exercises,2)
    chosenExercises{i} = char(availableExercises(exercises(i)));
end

doneCorrectly = zeros(size(repetitions));

%%
fprintf("\n");
disp('Starting radar connection...')

% See fmcw demo for these setup steps
[rx,tx,bf,bf_TDD,model] = setupFMCWRadar(fc,fs,tpulse,tsweep,nPulses,rampbandwidth);

% Clear cache
rx();

% Use constant amplitude baseband transmit data
amp = 0.9 * 2^15;
txWaveform = amp*ones(rx.SamplesPerFrame,2);

disp('Radar connected.')
fprintf("\n");

%% Next, run continuously for nCaptures

numberFrames = 20;
rd = phased.RangeDopplerResponse(DopplerOutput="Speed",...
    OperatingFrequency=fc,SampleRate=fs,RangeMethod="FFT",...
   SweepSlope=sweepslope,PRFSource="Property",PRF=prf);

f1 = figure;
ax = axes(f1);

exerciseTable = table(chosenExercises', repetitions', doneCorrectly', ...
                      'VariableNames', {'Exercise', 'Repetitions', 'DoneCorrectly'});
displayCenteredTable(exerciseTable);

fprintf('\n');
fprintf('Please perfom exercise: %s', upper(char(availableExercises(exercises(1)))));
fprintf('\n');

fprintf('\n');
fprintf('Starting in.. 3 ');
pause(1);
fprintf('2 ');
pause(1);
fprintf('1 \n');
pause(1);
fprintf('\n');

h = 1;

for t = 1:length(exercises)
    modelName = availableExercises(exercises(t));
    model = load("models\" + modelName + "_CNN.mat");
    load("exercise_levels\" + modelName + "_level.mat");
    nCaptures = repetitions(t)*numberFrames + 10;
    radarFrames = zeros(267,256,20);
    i = 1;

    while i <= nCaptures
        data = captureTransmitWaveform(txWaveform,rx,tx,bf);
        
        if i > 10
            fprintf('Frame: %d \n', i-10);
            data = arrangePulseData(data,rx,bf,bf_TDD);
            radarFrames(:,:,h) = data;
            h = h + 1;
            figure(f1);
            rd.plotResponse(data);
            xlim(ax,[-maxSpeed,maxSpeed]); ylim(ax,[0,maxRange]);
            drawnow;
            pause(0.1);
                
            if (i-10) > 0 
                if rem((i-10),20) == 0
                    temp = rangeNormalizedFiltered(radarFrames, rd);
                    dataNet(:,:,:,1) = temp;
                    [Pred, ~] = classify(model.net,dataNet);
                    Pred = str2double(cellstr(Pred));
                    fprintf('\n');
                    fprintf('Result: %s', resExe(Pred));
                    fprintf('\n');
                    h = 1;

                    if(Pred == 1)
                        doneCorrectly(t) = doneCorrectly(t) + 1; 
                    end

                    exerciseTable = table(chosenExercises', repetitions', doneCorrectly', ...
                      'VariableNames', {'Exercise', 'Repetitions', 'DoneCorrectly'});
                    displayCenteredTable(exerciseTable);

                    if(Pred ~= 1)
                        fprintf("Let's try again!");
                        fprintf('\n');
                        nCaptures = nCaptures + 20;
                        fprintf('\n');
                        fprintf('Please perfom exercise again: %s', upper(char(availableExercises(exercises(t)))));
                        fprintf('\n');
                    end
                    
                    if t ~= length(exercises) || i ~= nCaptures
                        if(Pred == 1)
                            fprintf('\n');
                            fprintf('Please perfom exercise: %s', upper(char(availableExercises(exercises(t+1)))));
                            fprintf('\n');
                        end
                        fprintf('\n');
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
                        fprintf('\n');
                    end
                end
            end
        end

        i = i + 1;

    end
end

fprintf('\n');
fprintf('End of routine.');
fprintf('\n');

% Disable TDD Trigger so we can operate in Receive only mode
disableTddTrigger(bf_TDD)
