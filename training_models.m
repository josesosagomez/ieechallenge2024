close all; 
clc; 
clear;
clearvars -global;

%% Exercise variables 

training_exercise = "squad";
folderPath = "sample_exercises\" + training_exercise;
load("var\" + training_exercise + "_var.mat");
total_num_samples = 0;

%% Getting data of exercise and normalizing

for i = 1:length(exe_technique)
    dir_samples = folderPath + "\" + exe_technique(i);
    total_num_samples = total_num_samples + length(dir(fullfile(dir_samples, '*.mat')));
end

label_samples = zeros(total_num_samples,1);
count = 1;

fc = 10e9;
maxRange = 4;
rampbandwidth = 500e6;
pri = 2e-3;
prf = 1/pri;
tpulse = 0.512e-3;
tsweep = getFMCWSweepTime(tpulse,tpulse);
sweepslope = rampbandwidth / tsweep;
fmaxbeat = sweepslope * range2time(maxRange);
fs = max(ceil(2*fmaxbeat),520834);

rd = phased.RangeDopplerResponse(DopplerOutput="Speed",...
    OperatingFrequency=fc,SampleRate=fs,RangeMethod="FFT",...
    SweepSlope=sweepslope,PRFSource="Property",PRF=prf);

for j = 1:length(exe_technique)
    dir_samples = folderPath + "\" + exe_technique(j);
    for h = 1:length(dir(fullfile(dir_samples, '*.mat'))) 
        sample = load(dir_samples + "\exercise_" + h + ".mat");
        if contains(exe_technique(j), "good")
            label_samples(count,1) = 1;
        elseif contains(exe_technique(j), "bad")
            label_samples(count,1) = 2;
        else
            label_samples(count,1) = 3;
        end
        temp = rangeNormalizedFiltered(sample.framesRadar, rd);
        if ~exist('exercise_samples', 'var')
            exercise_samples = zeros([size(temp),total_num_samples]);
            idx = repmat({':'}, 1, ndims(temp));
            exercise_samples(idx{:}, 1) = temp;
        else
            exercise_samples(idx{:}, count) = temp;
        end
        count = count + 1;
        clear sample;
        clear temp;
    end
end

label_samples = categorical(label_samples);

%% Data splitting

testRatio = 0.20;
cv1 = cvpartition(total_num_samples, 'HoldOut', testRatio);

trainData = exercise_samples(idx{:},cv1.training);
trainLabels = label_samples(cv1.training,1);

testData = exercise_samples(idx{:},cv1.test);
testLabels = label_samples(cv1.test,1);

%% Layers

numClasses = length(exe_technique);
inputSize = [size(exercise_samples,1:ndims(exercise_samples)-1) 1];

layers = [
    image3dInputLayer(inputSize, 'Name', 'input')

    convolution3dLayer(3, 16, 'Padding', 'same')
    batchNormalizationLayer
    reluLayer

    maxPooling3dLayer(2, 'Stride', 2)

    convolution3dLayer(3, 32, 'Padding', 'same')
    batchNormalizationLayer

    reluLayer

    fullyConnectedLayer(128)
    reluLayer

    fullyConnectedLayer(numClasses)
    softmaxLayer
    classificationLayer];

%% Options for training

options = trainingOptions('sgdm', ...
    'InitialLearnRate',0.001, ...
    'MaxEpochs',40, ...
    'MiniBatchSize', 64, ...
    'Shuffle','every-epoch', ...
    'Verbose',false, ...
    'Plots','training-progress',...
    'ExecutionEnvironment','cpu');

%%

trainDataCell = zeros([size(exercise_samples,1:ndims(exercise_samples)-1) 1 size(trainData,ndims(trainData))]);

for i = 1:size(trainData,ndims(trainData))
    trainDataCell(idx{:},1,i) = trainData(idx{:},i);
end

testDataCell = zeros([size(exercise_samples,1:ndims(exercise_samples)-1) 1 size(testData,ndims(testData))]);

for i = 1:size(testData,ndims(testData))
    testDataCell(idx{:},1,i) = testData(idx{:},i);
end

%% Training

[net, info] = trainNetwork(trainDataCell,trainLabels,layers,options);
[Pred, scores] = classify(net,testDataCell);

%% Accuracy

Accuracy = sum(Pred == testLabels)/numel(testLabels)*100;

%%

save("squad_CNN","net","info");


