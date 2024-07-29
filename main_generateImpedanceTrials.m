%%
% SPDX-FileCopyrightText: 2024 Matthew Millard <millard.matthew@gmail.com>
%
% SPDX-License-Identifier: MIT
%
%%
clc;
close all;
clear all;

flag_plotPerturbationWaveform=0;

rootDir = pwd;
assert(contains(rootDir(1,end-29:end),'SingleMuscleSimulationsLSDYNA'),...
       'Error: must start this with matlab in the main directory');

modelName       = 'umat43';
simulationTypeStr  = 'impedance_Kirsch1994';
releaseName     = 'MPP_R931';

addpath('preprocessing');

units_kNmmms = 0;
units_Nms    = 1; 

%%
%Files and folders
%%
simulationTypePath  = fullfile( rootDir,...
                                releaseName,...
                                modelName,...
                                simulationTypeStr);
outputFolder        = 'output';
structFolder        = fullfile('output','structs',filesep);

%%
% Clean the existing folder of all subfolders
%%
cd(simulationTypePath);
folderContents=dir;

for i=1:1:length(folderContents)
    here=1;
    if(folderContents(i).isdir == 1 && length(folderContents(i).name) > 2)
        system(['rm -rf ', folderContents(i).name]);
    end
end

cd(rootDir);

%%
% Plot configuration
%%
flag_sizePlotsForSlides=0;
plotWidth         = 4.6;
plotHeight        = plotWidth*0.5;        
plotHorizMarginCm = 1.3;
plotVertMarginCm  = 1.3;  
baseFontSize      = 8;

if(flag_sizePlotsForSlides==1)
    plotWidth         = 4;
    plotHeight        = 4;        
    plotHorizMarginCm = 1.5;
    plotVertMarginCm  = 2.;  
    baseFontSize      = 6;
end

%%
% Perturbation Waveforms
%%
mm2m            = 0.001;
sampleTime      = 0.003;
sampleFrequency = 1/sampleTime; % Sampling frequency
paddingPoints   = round(0.5*sampleFrequency);
samplePoints    = 2048;% Number of points in the random sequence


amplitudeMM     = [0.4, 0.8, 1.6]'; %Amplitude scaling in mm
bandwidthHz     = [ 15,  35,  90]'; %bandwidth in Hz;
samplePoints    = 2048;% Number of points in the random sequence

flag_generateRandomBaselineSignal    = 0; %Only needs to be done once
flag_processRandomBaselineSignal     = 0; %Only needs to be done once               

signalFileEnding = sprintf('_%sHz_%s',num2str(round(sampleFrequency,0)),...
                                      num2str(samplePoints));
signalFileName      = [ 'systemIdInputFunctions',signalFileEnding,'.mat'];
baseSignalFileName  = [ 'baseFunction',signalFileEnding,'.mat'];

flag_usingOctave= 0;

impedanceInputFunctions = getPerturbationWaveforms(...
                    amplitudeMM,...
                    bandwidthHz,...
                    samplePoints,...
                    paddingPoints,...
                    sampleFrequency,...
                    structFolder, ...
                    flag_generateRandomBaselineSignal,...
                    flag_processRandomBaselineSignal,...
                    baseSignalFileName,...
                    signalFileName,...
                    flag_usingOctave); 


%%
% Activation settings
%%


switch modelName
    case 'mat156'
        fiso = ...
            getParameterFieldValue(...
              fullfile(rootDir,releaseName,'common','catsoleusHL2002Mat156Parameters.k'),...
              'fceOpt');        
        fpeNAtLceOpt = 0.046276; 

        scale=(5/4.36008)*(5/4.87);

        ex5N        = (5/fiso-fpeNAtLceOpt)*scale;
        exMin       = max(0,1/fiso-fpeNAtLceOpt)*scale;
        exMax       = (12/fiso-fpeNAtLceOpt)*scale;
        excitationSeries    = [exMin:((exMax-exMin)/(9)):exMax];

    case 'umat41'
        exMax       = 1.0;
        exSubMax    = 0.18;

        q0=1e-4;
        q=exSubMax;
        exSubMax=(0.5*(q-q0))/(1-(1-0.5)*(q-q0));

        scale = (5/5.04897)*(5/4.93);

        newtonToExcitation  = (0.1327646940142737/5);
        ex5N        = 5*newtonToExcitation*scale;
        exMin       = max(0,1*newtonToExcitation)*scale;
        exMax       = 12*newtonToExcitation*scale;
        excitationSeries    = [exMin:((exMax-exMin)/(9)):exMax];

    case 'umat43'
        fiso = ...
            getParameterFieldValue(...
              fullfile(rootDir,releaseName,'common','catsoleusHL2002Umat43Parameters.k'),...
              'fceOpt');  
        penOpt = ...
            getParameterFieldValue(...
              fullfile(rootDir,releaseName,'common','catsoleusHL2002Umat43Parameters.k'),...
              'penOpt');  
        fpeNAtLceOpt = 0.046276; 
        fisoAT = fiso*cos(penOpt);

        scale = 1*(5/4.93);
        ex5N        = (5/fisoAT-fpeNAtLceOpt)*scale;
        exMin       = max(0,(1/fisoAT-fpeNAtLceOpt)*scale);
        exMax       = (12/fisoAT-fpeNAtLceOpt)*scale;
        excitationSeries    = [exMin:((exMax-exMin)/(9)):exMax];

    otherwise
        assert(0,'Error: invalid simulation type chosen');
end

%%
% Series
%%
fig3Series.amplitudeMM = [1.6,1.6];
fig3Series.bandwidthHz = [15,90];
fig3Series.excitation  = [ex5N,ex5N];

fig12Series.amplitudeMM = ones(size(excitationSeries)).*0.8;
fig12Series.bandwidthHz = ones(size(excitationSeries)).*35;
fig12Series.excitation  = excitationSeries; 

for i=1:1:length(fig3Series.amplitudeMM)

    lsdynaImpedanceFcnName='impedance.k';
    if(contains(modelName,'umat43'))
        lsdynaImpedanceFcnName='impedanceKBR1994Fig3.k';
    end

    fileNameId = '';

    success = writeSingleImpedanceSimulationFile(...
                fig3Series.amplitudeMM(i), ...
                fig3Series.bandwidthHz(i), ...
                fig3Series.excitation(i),...
                impedanceInputFunctions, ...
                lsdynaImpedanceFcnName,...
                simulationTypePath,...
                fileNameId);
end

for i=1:1:length(fig12Series.amplitudeMM)
    lsdynaImpedanceFcnName='impedance.k';
    if(contains(modelName,'umat43'))
        lsdynaImpedanceFcnName='impedanceKBR1994Fig12.k';
    end    

    fileNameId = num2str(i);
    while(length(fileNameId) < 2)
        fileNameId = ['0',fileNameId];
    end

    if(i==1)
        fileNameId = [fileNameId,'_first'];
    end
    if(i==length(fig12Series.amplitudeMM))
        fileNameId = [fileNameId,'_last'];        
    end
    fileNameId = ['_',fileNameId];

    success = writeSingleImpedanceSimulationFile(...
                fig12Series.amplitudeMM(i), ...
                fig12Series.bandwidthHz(i), ...
                fig12Series.excitation(i),...
                impedanceInputFunctions, ...
                lsdynaImpedanceFcnName,...
                simulationTypePath,...
                fileNameId);
end

if(flag_plotPerturbationWaveform==1)
    [success] = plotPerturbationWaveforms( ...
                    impedanceInputFunctions,...
                    plotWidth,...
                    plotHeight,...
                    plotHorizMarginCm,...
                    plotVertMarginCm,...
                    [outputFolder,'/',releaseName,'/',...
                     modelName,'/']);
end
