%% This script performs the validation tests isometric, concentric and quick release 
%% for different release version of the referenceDataPath EHTMM
clc;
clear all;
close all;
opengl('save','software');
%%
% User-defined script variables
%%


% Define which Releases shall be tested
Releases    =  {'MPP_R931'};


greyA = [0,0,0];
greyB = [1,1,1].*0.5;

blueA  = [0, 0.4470, 0.7410];
blueB  = blueA.*0.5;% + [1,1,1].*0.5;

greenA = [0, 0.75, 0.75];
greenB = greenA.*0.5;% + [1,1,1].*0.5;

maroonA= [0.6350, 0.0780, 0.1840];
maroonB= maroonA.*0.5;% + [1,1,1].*0.5;

magentaA = [0.75, 0, 0.75];
magentaB = magentaA.*0.5;% + [1,1,1].*0.5;

redA = [193, 39, 45]./255;
redB = redA.*0.5;% + [1,1,1].*0.5;

dataColorA=greyA;
dataColorB=greyB;

models(1) = struct('id',0,'name','');

%indexVIVA              = 1;
%models(indexVIVA).id   = 1;
%models(indexVIVA).name ='viva';
%models(indexVIVA).colors= [greenA;greenB];

indexMat56                = 1;
models(indexMat56).id     = 1;
models(indexMat56).name   ='mat156';
models(indexMat56).colors = [redA;redB];
 
% indexUmat41              = 2;
% models(indexUmat41).id   = 2;
% models(indexUmat41).name ='umat41';
% models(indexUmat41).colors= [magentaA;magentaB];
%   
% indexUmat43              = 3;
% models(indexUmat43).id   = 3;
% models(indexUmat43).name ='umat43';
% models(indexUmat43).colors= [blueA;blueB];


flag_preProcessSimulationData       = 0; 
%Setting this to 1 will perform any preprocessing needed of the enabled 
%experiments. At the moment this is limited to generating the random perturbation
%signals used in the impedance experiments.

flag_runSimulations                 = 0;
%Setting this to 1 will run the simulations that have been enabled

flag_postProcessSimulationData      = 1;
%Setting this to 1 will generate plots of the enabled experiments

flag_sizePlotsForSlides = 0; %0: means use journal paper slides
excludeSimulationsNamesThatContain = [];%[{'52mm'}];

flag_generateGenericPlots           = 0;
flag_generateSpecificPlots          = 0;
flag_generatePublicationPlots       = 1;

flag_enableIsometricExperiment          = 0;
flag_enableConcentricExperiment         = 0;
flag_enableQuickReleaseExperiment       = 0;
flag_enableEccentricExperiment          = 0;
flag_enableImpedanceExperiment          = 0;
flag_enableSinusoidExperiment           = 0;
flag_enableReflexExperiment             = 0;
flag_enableReflexExperiment_kN_mm_ms    = 0;

flag_enableActivePassiveForceLengthExperimentViva   = 0;
flag_enableForceVelocityExperimentViva              = 0;
flag_enableActivePassiveForceLengthExperiment       = 0;
flag_enableForceVelocityExperiment                  = 1;

if(flag_enableForceVelocityExperimentViva ...
        || flag_enableActivePassiveForceLengthExperimentViva)
    disp('Warning: The VIVA SCM element simulated is not');
    disp('         the strongest. Update the architectural');
    disp('         properties before using these results in');
    disp('         a publication.');
end

runOneTrial = [];

flag_sinusoid_aniType = 0; 
% This is only relevant when post-processing SinusoidExperiment
%0. human
%1. feline

%Lengthens muscle to sample force-length curves
flag_enableForceLengthExperiment        = 0; 


%Test to see if the Matlab terminal is in the correct directory
currDirContents = dir;
[pathToParent,parentFolderName,ext] = fileparts(currDirContents(1).folder);
matlabScriptPath = '';
rootFolderName = 'SingleMuscleSimulationsLSDYNA';
if(strcmp(currDirContents(1).name,'.') ...
        && contains(parentFolderName,rootFolderName))
    matlabScriptPath = pwd;
else
    if(contains(currDirContents(1).folder,rootFolderName))
        idx0 = strfind(currDirContents(1).folder,...
                        rootFolderName);
        idx1 = idx0 + length(rootFolderName);
        pathToRootFolder = currDirContents(1).folder(1,1:idx1);
        cd(pathToRootFolder);
        matlabScriptPath = pwd;
    else
        assert(0, ['Error: script is not starting in the',...
                   ' SingleMuscleSimulationsLSDYNA directory']);
    end
end

lsdynaBin_SMP_931 = fullfile( filesep,  'scratch','tmp','mmillard',...
                                'lsdynaCompilation','SMP_R931','lsdyna');

lsdynaBin_MPP_931 = fullfile( filesep,  'scratch','tmp','mmillard',...
                                'lsdynaCompilation','MPP_R931','mppdyna');

addpath(matlabScriptPath);
cd(matlabScriptPath);


%% path to exp. reference
referenceDataPath= fullfile(matlabScriptPath,'ReferenceExperiments', filesep);

numberOfSimulationTypes = flag_enableIsometricExperiment ...
                     +flag_enableConcentricExperiment ... 
                     +flag_enableQuickReleaseExperiment...
                     +flag_enableEccentricExperiment...
                     +flag_enableImpedanceExperiment...
                     +flag_enableForceLengthExperiment...
                     +flag_enableSinusoidExperiment...
                     +flag_enableReflexExperiment...
                     +flag_enableReflexExperiment_kN_mm_ms...
                     +flag_enableActivePassiveForceLengthExperimentViva...
                     +flag_enableForceVelocityExperimentViva...
                     +flag_enableActivePassiveForceLengthExperiment...
                     +flag_enableForceVelocityExperiment;


if(numberOfSimulationTypes==0)
    numberOfSimulationTypes=1;
end
numberOfSimulations = numberOfSimulationTypes*length(models);







% Define if all all datapoints are used or only some of them?
deltaPoints  = 1; % every 2nd/3rd/...


%% Impedance experiment evaluation
mm2m = 0.001;
sampleTime      = 0.003;
sampleFrequency = 1/sampleTime; % Sampling frequency
paddingPoints   = round(0.5*sampleFrequency);
samplePoints    = 2048;% Number of points in the random sequence
totalPoints     = samplePoints;
amplitudeMM     = [0.4, 0.8, 1.6]'; %Amplitude scaling in mm
bandwidthHz     = [ 15,  35,  90]'; %bandwidth in Hz;

flag_generateRandomBaselineSignal    = 0; %Only needs to be done once
flag_processRandomBaselineSignal     = 0; %Only needs to be done once               

signalFileEnding = sprintf('_%sHz_%s',num2str(round(sampleFrequency,0)),...
                                 num2str(samplePoints));
signalFileName      = [ 'systemIdInputFunctions',signalFileEnding,'.mat'];
baseSignalFileName  = [ 'baseFunction',signalFileEnding,'.mat'];

%% paths
outputFolder            = 'output';
structFolder            = fullfile('output','structs',filesep);

addpath(genpath('numeric'));
addpath(genpath('curves'));
addpath(genpath('preprocessing'));
addpath(genpath('postprocessing'));

%% Plot configuration
plotWidth         = 6;
plotHeight        = 6;        
plotHorizMarginCm = 1.5;
plotVertMarginCm  = 2.;  
baseFontSize      = 8;

if(flag_sizePlotsForSlides==1)
    plotWidth         = 4;
    plotHeight        = 4;        
    plotHorizMarginCm = 1.5;
    plotVertMarginCm  = 2.;  
    baseFontSize      = 6;
end





%% Preprocessing
if(flag_preProcessSimulationData==1)

    for indexRelease = 1:length(Releases)
        cd(matlabScriptPath); 
        Release = cell2mat(Releases(indexRelease));

        
        for indexModel = 1:1:length(models)        
            [simulationType,simulationInformation]=...
                getSimulationInformation(models(indexModel).name,...
                        flag_enableIsometricExperiment,...
                        flag_enableConcentricExperiment,...
                        flag_enableQuickReleaseExperiment,...
                        flag_enableEccentricExperiment,...
                        flag_enableImpedanceExperiment,...
                        flag_enableForceLengthExperiment,...
                        flag_enableSinusoidExperiment,...
                        flag_enableReflexExperiment,...
                        flag_enableReflexExperiment_kN_mm_ms,...
                        flag_enableActivePassiveForceLengthExperimentViva,...
                        flag_enableForceVelocityExperimentViva,...
                        flag_enableActivePassiveForceLengthExperiment,...
                        flag_enableForceVelocityExperiment);

            for indexSimulationType = 1:length(simulationType)

                simulationTypeStr = simulationType(indexSimulationType).type;
                simulationTypePath  = fullfile( matlabScriptPath,...
                                                Release,...
                                                models(indexModel).name,...
                                                simulationTypeStr);

                switch simulationTypeStr
                    case 'impedance'
                        %Generate the perturbation signals
                        flag_usingOctave= 0;
                        inputFunctions = getPerturbationWaveforms(...
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

                        %The ugly number (0.234238575712566) should yield 5N
                        %0.1327646940142737 for 5 N
                        excitationSeries = [1, 5, 10].*(0.1327646940142737/5);


                        [success] = writeImpedanceSimulationFiles(...
                                    excitationSeries,...
                                    inputFunctions,...
                                    simulationTypePath);

                        [success] = plotPerturbationWaveforms( ...
                                        inputFunctions,...
                                        plotWidth,...
                                        plotHeight,...
                                        plotHorizMarginCm,...
                                        plotVertMarginCm,...
                                        [outputFolder,'/',Release,'/',...
                                         models(indexModel).name,'/']);

                    otherwise
                        disp(['Preprocessing not required: ', simulationTypeStr]);
                end

                
            end
        end
    end

end

%% Simulation

if(flag_runSimulations==1)

    for indexRelease = 1:length(Releases)
        cd(matlabScriptPath);   

        Release = cell2mat(Releases(indexRelease));      

        for indexModel = 1:1:length(models)
            [simulationType,simulationInformation]=...
                getSimulationInformation(models(indexModel).name,...
                        flag_enableIsometricExperiment,...
                        flag_enableConcentricExperiment,...
                        flag_enableQuickReleaseExperiment,...
                        flag_enableEccentricExperiment,...
                        flag_enableImpedanceExperiment,...
                        flag_enableForceLengthExperiment,...
                        flag_enableSinusoidExperiment,...
                        flag_enableReflexExperiment,...
                        flag_enableReflexExperiment_kN_mm_ms,...
                        flag_enableActivePassiveForceLengthExperimentViva,...
                        flag_enableForceVelocityExperimentViva,...
                        flag_enableActivePassiveForceLengthExperiment,...
                        flag_enableForceVelocityExperiment);
                    
            switch Release
                case 'SMP_R931'
                    lsdynaBin = lsdynaBin_SMP_931;
                case 'MPP_R931'
                    lsdynaBin = lsdynaBin_MPP_931;
                    
                otherwise
                    error('Release not specified yet')
            end

            for indexSimulationType = 1:length(simulationType)                  
                simulationTypeStr   = simulationType(indexSimulationType).type;
                simulationTypePath  = fullfile( matlabScriptPath,...
                                                Release,...
                                                models(indexModel).name,...
                                                simulationTypeStr);  
                cd(simulationTypePath);

                simulationDirectories = dir;
                simulationDirectories = ...
                  simulationDirectories([simulationDirectories.isdir]==true);

                if(isempty(runOneTrial)==1)

                    for indexSimulationTrial=3:deltaPoints:length(simulationDirectories)
                        
                        cd(simulationDirectories(indexSimulationTrial).name);
                        
                        %% generate output signals                        
                        %system(['rm -f binout* *.csv d3* matsum musout* messag* glstat',...
                        %         ' nodout spcforc lspost*']);
                        system('find . -type f -not \( -name ''*k'' -or -name ''*m'' \) -delete');
                        system([lsdynaBin,' i=',...
                                simulationDirectories(indexSimulationTrial).name,...
                                '.k']);                    
                        cd(simulationTypePath);
                    end
                else
                     cd(runOneTrial);
                        
                    %% generate output signals                        
                    %system(['rm -f binout* *.csv d3* matsum musout* messag* glstat',...
                    %         ' nodout spcforc lspost*']);
                    system('find . -type f -not \( -name ''*k'' -or -name ''*m'' \) -delete');
                    system([lsdynaBin,' i=',...
                            runOneTrial,...
                            '.k']);                    
                    cd(simulationTypePath);

                end
            end
        end
    end
end

%% PostProcessing 
if(flag_postProcessSimulationData==1)

    cd(matlabScriptPath);

    figGeneric      = figure;
    figSpecific     = figure; 
    figPublication  = figure;
    figDebug        = figure;
    
    %load inputFunctions
    load([structFolder,signalFileName]);

    for indexRelease = 1:length(Releases)
        cd(matlabScriptPath);

        Release = cell2mat(Releases(indexRelease));

        clf(figPublication);
        flag_figPublicationDirty=0;        
        for indexModel = 1:1:length(models)
            impedancePlotCounter=1;

            [simulationType,simulationInformation]=...
                getSimulationInformation(models(indexModel).name,...
                        flag_enableIsometricExperiment,...
                        flag_enableConcentricExperiment,...
                        flag_enableQuickReleaseExperiment,...
                        flag_enableEccentricExperiment,...
                        flag_enableImpedanceExperiment,...
                        flag_enableForceLengthExperiment,...
                        flag_enableSinusoidExperiment,...
                        flag_enableReflexExperiment,...
                        flag_enableReflexExperiment_kN_mm_ms,...
                        flag_enableActivePassiveForceLengthExperimentViva,...
                        flag_enableForceVelocityExperimentViva,...
                        flag_enableActivePassiveForceLengthExperiment,...
                        flag_enableForceVelocityExperiment);            
              
            simulationColorA = models(indexModel).colors(1,:);
            simulationColorB = models(indexModel).colors(2,:);

            for indexSimulationType = 1:length(simulationType)
                

                simulationTypeStr = simulationType(indexSimulationType).type;
                clf(figGeneric);
                flag_figGenericDirty=0;
                clf(figSpecific);
                flag_figSpecificDirty=0;

                if(contains(simulationTypeStr,'active_passive_force_length'))
                    flag_figPublicationDirty=0;  
                end

                clf(figDebug);
                flag_figDebugDirty=0;

                indexSimulationInfo = 1;
                found=0;
                while found==0 && indexSimulationInfo <= length(simulationInformation)
                    simInfoType = simulationInformation(indexSimulationInfo).type;
                    simInfoModel =simulationInformation(indexSimulationInfo).model;

                    if(strcmp(models(indexModel).name,simInfoModel)==1 ...
                       && strcmp(simulationTypeStr,simInfoType)==1)
                        found=1;
                    else
                        indexSimulationInfo=indexSimulationInfo+1;
                    end
                end
                assert(found==1);

                simulationTypePath  = fullfile( matlabScriptPath,...
                                                Release,...
                                                models(indexModel).name,...
                                                simulationTypeStr);        
                cd(simulationTypePath);
                
                simulationDirectories           = dir;
                simulationDirectories           = ...
                  simulationDirectories([simulationDirectories.isdir]==true);
        
                %Set the path for the reference data
                

                referenceDataFolder = [referenceDataPath,simulationTypeStr];
                


                switch simulationType(indexSimulationType).type
                    case 'isometric_Guenther2007'
                        referenceCurveFolder = [];
                    case 'concentric_Guenther2007'
                        referenceCurveFolder = [];
                    case 'quickrelease_Guenther2007'
                        referenceCurveFolder = [];
                    case 'eccentric_HerzogLeonard2002'
                        referenceCurveFolder = fullfile(matlabScriptPath,'ReferenceCurves','eccentric');
                    case 'impedance_Kirsch1997'
                        referenceCurveFolder = [];
                    case 'reflex'
                        referenceCurveFolder = [];
                    case 'reflex_kN_mm_ms'
                        referenceCurveFolder = [];
                    case 'sinusoid'
                        switch flag_sinusoid_aniType
                            case 0
                                referenceDataFolder = [referenceDataFolder,...
                                                '/QuadraticBezierHumanCurves'];
                            case 1
                                referenceDataFolder = [referenceDataFolder,...
                                                '/QuadraticBezierFelineCurves'];
                            otherwise 
                                assert(0,'flag_sinusoid_aniType should be 0 (human) or 1 (feline)');
                        end
                    case 'active_passive_force_length_viva'
                        referenceCurveFolder = [];   
                    case 'force_velocity_viva'
                        referenceCurveFolder = []; 
                    case 'active_passive_force_length'
                        referenceCurveFolder = [];   
                    case 'force_velocity'
                        referenceCurveFolder = [];  
                    otherwise
                        assert(0,'Error: simulation type not yet coded with reference data');
                end


                numberOfHorizontalPlotColumnsGeneric = length(simulationDirectories)-3+1;
                numberOfVerticalPlotRowsGeneric      = 14;
                                              
                [subPlotPanelGeneric, pageWidthGeneric,pageHeightGeneric]= ...
                      plotConfigGeneric(  numberOfHorizontalPlotColumnsGeneric,...
                                          numberOfVerticalPlotRowsGeneric,...
                                          plotWidth,plotHeight,...
                                          plotHorizMarginCm,plotVertMarginCm,...
                                          baseFontSize); 

                
                numberOfHorizontalPlotColumnsSpecific = 1;
                numberOfVerticalPlotRowsSpecific      = 1;
                numberOfHorizontalPlotColumnsDebug    = 3;
                numberOfVerticalPlotRowsDebug         = 6;

                numberOfHorizontalPlotColumnsPublication  = 1; 
                numberOfVerticalPlotRowsPublication       = 1;

                switch (simulationTypeStr)
                    case 'eccentric_HerzogLeonard2002'

                      numberOfHorizontalPlotColumnsSpecific     = 1;
                      numberOfVerticalPlotRowsSpecific          = 6;

                      numberOfHorizontalPlotColumnsPublication  = 15; 
                      numberOfVerticalPlotRowsPublication       = 3;


                    case 'isometric_Guenther2007'
                      numberOfHorizontalPlotColumnsSpecific = 1;
                      numberOfVerticalPlotRowsSpecific      = 1;
                    case 'concentric_Guenther2007'
                      numberOfHorizontalPlotColumnsSpecific = 1;
                      numberOfVerticalPlotRowsSpecific      = 1;
                    case 'quickrelease_Guenther2007'
                      numberOfHorizontalPlotColumnsSpecific = 1;
                      numberOfVerticalPlotRowsSpecific      = 1;                 
                    case 'impedance_Kirsch1997'
                      numberOfHorizontalPlotColumnsSpecific = 1;
                      numberOfVerticalPlotRowsSpecific      = 6; 
                      sampleTimeK = getParameterFieldValue('impedance.k','dtsignal');
                      assert(abs(sampleTimeK-sampleTime)<sqrt(eps));    
                    case 'force_length'
                      numberOfHorizontalPlotColumnsSpecific = 3;
                      numberOfVerticalPlotRowsSpecific      = 4;
                    case 'sinusoid'
                      numberOfHorizontalPlotColumnsSpecific = 3;
                      numberOfVerticalPlotRowsSpecific      = 8+3;
                    case 'reflex'
                      numberOfHorizontalPlotColumnsSpecific = 3;
                      numberOfVerticalPlotRowsSpecific      = 12; 
                    case 'reflex_kN_mm_ms'
                      numberOfHorizontalPlotColumnsSpecific = 3;
                      numberOfVerticalPlotRowsSpecific      = 12; 
                    case 'active_passive_force_length_viva'
                      numberOfHorizontalPlotColumnsSpecific     = 1;
                      numberOfVerticalPlotRowsSpecific          = 2;
                      numberOfHorizontalPlotColumnsPublication  = 3; 
                      numberOfVerticalPlotRowsPublication       = length(models); 
                    case 'force_velocity_viva'
                      numberOfHorizontalPlotColumnsSpecific     = 1;
                      numberOfVerticalPlotRowsSpecific          = 2;
                      numberOfHorizontalPlotColumnsPublication  = 3; 
                      numberOfVerticalPlotRowsPublication       = 1+length(models);
                    case 'active_passive_force_length'
                      numberOfHorizontalPlotColumnsSpecific     = 1;
                      numberOfVerticalPlotRowsSpecific          = 2;
                      numberOfHorizontalPlotColumnsPublication  = 3; 
                      numberOfVerticalPlotRowsPublication       = length(models); 
                    case 'force_velocity'
                      numberOfHorizontalPlotColumnsSpecific     = 1;
                      numberOfVerticalPlotRowsSpecific          = 2;
                      numberOfHorizontalPlotColumnsPublication  = 3; 
                      numberOfVerticalPlotRowsPublication       = 1+length(models);
                end


                [subPlotPanelSpecific,pageWidthSpecific,pageHeightSpecific]= ...
                      plotConfigGeneric(  numberOfHorizontalPlotColumnsSpecific,...
                                          numberOfVerticalPlotRowsSpecific,...
                                          plotWidth,...
                                          plotHeight,...
                                          plotHorizMarginCm,...
                                          plotVertMarginCm,...
                                          baseFontSize);

                [subPlotPanelDebug,pageWidthDebug,pageHeightDebug]= ...
                      plotConfigGeneric(  numberOfHorizontalPlotColumnsDebug,...
                                          numberOfVerticalPlotRowsDebug,...
                                          plotWidth,...
                                          plotHeight,...
                                          plotHorizMarginCm,...
                                          plotVertMarginCm,...
                                          baseFontSize);


                if(flag_generatePublicationPlots==1)
                    [subPlotPanelPublication,pageWidthPublication,pageHeightPublication]= ...
                          plotConfigPublication(numberOfHorizontalPlotColumnsPublication,...
                                              numberOfVerticalPlotRowsPublication,...
                                              plotWidth,...
                                              plotHeight,...
                                              plotHorizMarginCm,...
                                              plotVertMarginCm,...
                                              simulationTypeStr,...
                                              baseFontSize);
                end


                for indexSimulationTrial=3:deltaPoints:length(simulationDirectories)                    
                    cd(simulationTypePath);
                    flag_skipTrial=0;

                    if(isempty(excludeSimulationsNamesThatContain)==0)
                        for indexName=1:1:length(excludeSimulationsNamesThatContain)
                            if(contains(simulationDirectories(indexSimulationTrial).name,...
                                 excludeSimulationsNamesThatContain{1,indexName}))
                                flag_skipTrial=1;
                            end
                        end                        
                    end

                    flag_lastTrial=0;
                    if(indexSimulationTrial==length(simulationDirectories))
                      flag_lastTrial=1;
                    end

                    if(flag_skipTrial==0)
                        %% Load the muscle properties
                        lceOpt = NaN;
                        fiso   = NaN;
                        ltslk  = NaN;
                        alpha  = NaN;
                        if(simulationInformation(indexSimulationInfo).parametersInMuscleCard==1)
                            lceOpt = ...
                                getLsdynaCardFieldValue(...
                                  simulationInformation(indexSimulationInfo).musclePropertyCard,...
                                  simulationInformation(indexSimulationInfo).optimalFiberLength);
                            fiso = ...
                                getLsdynaCardFieldValue(...
                                  simulationInformation(indexSimulationInfo).musclePropertyCard,...
                                  simulationInformation(indexSimulationInfo).maximumIsometricForce);
                            ltslk = ...
                                getLsdynaCardFieldValue(...
                                  simulationInformation(indexSimulationInfo).musclePropertyCard,...
                                  simulationInformation(indexSimulationInfo).tendonSlackLength);
                            alpha = ...
                                getLsdynaCardFieldValue(...
                                  simulationInformation(indexSimulationInfo).musclePropertyCard,...
                                  simulationInformation(indexSimulationInfo).pennationAngleDegrees);
                            alpha = alpha*(pi/180);
                        else
                            lceOpt = ...
                                getParameterFieldValue(...
                                  simulationInformation(indexSimulationInfo).simulationConstantFile,...
                                  simulationInformation(indexSimulationInfo).optimalFiberLength);
                            fiso = ...
                                getParameterFieldValue(...
                                  simulationInformation(indexSimulationInfo).simulationConstantFile,...
                                  simulationInformation(indexSimulationInfo).maximumIsometricForce);
                            ltslk = ...
                                getParameterFieldValue(...
                                  simulationInformation(indexSimulationInfo).simulationConstantFile,...
                                  simulationInformation(indexSimulationInfo).tendonSlackLength);
                            alpha = ...
                                getParameterFieldValue(...
                                  simulationInformation(indexSimulationInfo).simulationConstantFile,...
                                  simulationInformation(indexSimulationInfo).pennationAngleDegrees);
                            alpha = alpha*(pi/180);
    
                        end
                        assert(~isnan(lceOpt));
                        assert(~isnan(fiso));
                        assert(~isnan(ltslk));
    
                        muscleArchitecture.lceOpt = lceOpt;
                        muscleArchitecture.fiso   = fiso;
                        muscleArchitecture.ltslk  = ltslk;
                        muscleArchitecture.alpha  = alpha;
    
                        fprintf('%i. %s\n', ...
                            indexSimulationTrial, ...
                            simulationDirectories(indexSimulationTrial).name);

                        cd(simulationDirectories(indexSimulationTrial).name);
                        fileList = dir;
                      
                        %% Count the number of musout files
                        musout =[];                          
                        musoutCount=0;
                        musoutFileList ={''};
                        for indexFile=1:1:length(fileList)
                          if(contains(fileList(indexFile).name,'musout'))
                            musoutCount=musoutCount+1;
                            if musoutCount == 1
                              musoutFileList = {fileList(indexFile).name};
                            else
                              musoutFileList = {musoutFileList{:};fileList(indexFile).name};
                            end
                            
                          end
                        end      
                        if( contains(models(indexModel).name,'umat') )              
                          assert(musoutCount == 1,'Error: could not find musout files');
                        end
    
                        musdebug=[];
                        musdebugCount=0;
                        musdebugFileList={''};                    
                        if(contains(models(indexModel).name,'umat43'))
                            for indexFile=1:1:length(fileList)
                              if(contains(fileList(indexFile).name,'musdebug'))
                                musdebugCount=musdebugCount+1;
                                if musdebugCount == 1
                                  musdebugFileList = {fileList(indexFile).name};
                                else
                                  musdebugFileList = {musdebugFileList{:};fileList(indexFile).name};
                                end                            
                              end
                            end
                            assert(musdebugCount==1,'Error: could not find umat43 musout files');
                        end
                        %% Load the muscle data
                        switch models(indexModel).name
                            case 'umat41'
                                [musout,success] = ...
                                    readUmat41MusoutData(musoutFileList{1});  
                            case 'umat43'
                                [musout,success] = ...
                                    readUmat43MusoutData(musoutFileList{1}); 
                                [musdebug,success] = ...
                                    readUmat43MusDebugData(musdebugFileList{1});
                            case 'mat156'
                                disp('  mat156: does not have any musout files');
                            case 'viva'
                                disp('  viva: does not have any musout files');
                            otherwise assert(0)
                        end
    
                        %Count the number of binout files        
                        binoutCount=0;
                        binoutFileList={};
                        for indexFile=1:1:length(fileList)
                          if(contains(fileList(indexFile).name,'binout'))
                            binoutCount=binoutCount+1;
                            if binoutCount==1
                              binoutFileList = {fileList(indexFile).name};
                            else
                              binoutFileList = {binoutFileList{:};fileList(indexFile).name};
                            end
                            
                          end
                        end
                        assert(binoutCount == 1);
    
                        %% Load the binout file
                        [binout,status] = binoutreader('dynaOutputFile',binoutFileList{1},'ignoreUnknownDataError',true);
    
    
                        %% Load the d3hsp file which contains parameters
                        d3hspFileName = 'd3hsp';
    
    
                        %% Add to the generic plots
                        indexColumn = (indexSimulationTrial-3)+1;
                        if(flag_figGenericDirty==0 ...
                                && flag_generateGenericPlots==1)
                          flag_figGenericDirty=1;
                        end
                        if(contains(simulationDirectories(indexSimulationTrial).name,'active_force_length_16'))
                            here=1;
                        end
                        uniformModelData = createUniformMuscleModelData(...
                            models(indexModel).name,...
                            musout, binout, d3hspFileName, lceOpt,fiso,ltslk,alpha,...
                            simulationTypeStr);
    
                        if(flag_generateGenericPlots==1)
                            figGeneric =plotSimulationDataSummary(figGeneric,...
                                models(indexModel).name, binout,uniformModelData,...
                                indexColumn,subPlotPanelGeneric,...
                                numberOfVerticalPlotRowsGeneric,...
                                numberOfHorizontalPlotColumnsGeneric,...                              
                                simulationDirectories(indexSimulationTrial).name,...
                                indexSimulationTrial, length(simulationDirectories),...
                                lceOpt,fiso,ltslk,...
                                dataColorA,dataColorB,...
                                simulationColorA,simulationColorB);
                        end
                        
    
                        %% Add to the simulation specific plots
                        if(flag_generateSpecificPlots==1)
    
                            [figSpecific,figDebug,...
                                flag_figSpecificDirty,flag_figDebugDirty,...
                                impedancePlotCounter] ...
                                = generateSpecificPlots(figSpecific,figDebug,...
                                        models(indexModel).name,...
                                        simulationTypeStr,...
                                        simulationInformation(indexSimulationInfo),...
                                        binout,musout,uniformModelData,d3hspFileName,...
                                        indexColumn,...
                                        subPlotPanelSpecific,...
                                        numberOfVerticalPlotRowsSpecific,...
                                        numberOfHorizontalPlotColumnsSpecific,... 
                                        simulationDirectories(indexSimulationTrial).name,...
                                        indexSimulationTrial,...
                                        length(simulationDirectories),...
                                        referenceDataFolder,...
                                        muscleArchitecture,...
                                        flag_figSpecificDirty, flag_figDebugDirty,...
                                        simulationColorA, simulationColorB,...
                                        dataColorA, dataColorB,...
                                        impedancePlotCounter);
                        end
    
                        %% Add to the publication plots
                        if(flag_generatePublicationPlots==1)
                            [figPublication,flag_figPublicationDirty] ...
                                = generatePublicationPlots(figPublication,...
                                        simulationTypeStr,...
                                        binout,uniformModelData,d3hspFileName,...
                                        indexModel,...
                                        subPlotPanelPublication,...
                                        numberOfVerticalPlotRowsPublication,...
                                        numberOfHorizontalPlotColumnsPublication,... 
                                        simulationDirectories(indexSimulationTrial).name,...
                                        indexSimulationTrial,...
                                        length(simulationDirectories),...
                                        referenceDataFolder,...
                                        referenceCurveFolder,...
                                        muscleArchitecture,...
                                        flag_figPublicationDirty,...
                                        simulationColorA, simulationColorB,...
                                        dataColorA, dataColorB);
                        end
                    end

                end
              
                if(flag_figGenericDirty==1)
                    figure(figGeneric);  
                    figGeneric=configPlotExporter(figGeneric,...
                                pageWidthGeneric, pageHeightGeneric);

                    fileName =    ['fig_',Release,'_',...
                                  models(indexModel).name,'_',...
                                  simulationInformation(indexSimulationInfo).type,...
                                  '_Generic.pdf'];
                    print('-dpdf', [matlabScriptPath,'/',outputFolder,'/',...
                          Release,'/',models(indexModel).name,'/',fileName]);
                end

                if(flag_figSpecificDirty==1)
                    figure(figSpecific);      
                    figSpecific=configPlotExporter(figSpecific, ...
                                pageWidthSpecific, pageHeightSpecific);

                    fileName =    ['fig_',Release,'_',...
                                  models(indexModel).name,'_',...                    
                                  simulationInformation(indexSimulationInfo).type,...
                                  '_Specific.pdf'];
                    print('-dpdf', [matlabScriptPath,'/',outputFolder,'/',...
                          Release,'/',models(indexModel).name,'/',fileName]);
                end
                if(flag_figPublicationDirty==1 && indexModel ==length(models))
                    figure(figPublication);      
                    figPublication=configPlotExporter(figPublication, ...
                                pageWidthPublication, pageHeightPublication);
                    fileName =    ['fig_',Release,'_',...                    
                                  simulationInformation(indexSimulationInfo).type,...
                                  '_Publication'];
                    print('-dpdf', [matlabScriptPath,'/',outputFolder,'/',...
                          Release,'/',fileName,'.pdf']);
                   
                    saveas(figPublication,[matlabScriptPath,'/',outputFolder,'/',...
                          Release,'/',fileName],'fig');
                end
                if(flag_figDebugDirty==1)
                    figure(figDebug);      
                    figSpecific=configPlotExporter(figDebug, ...
                                pageWidthDebug, pageHeightDebug);

                    fileName =    ['fig_',Release,'_',...
                                  models(indexModel).name,'_',...                    
                                  simulationInformation(indexSimulationInfo).type,...
                                  '_Debug.pdf'];
                    print('-dpdf', [matlabScriptPath,'/',outputFolder,'/',...
                          Release,'/',models(indexModel).name,'/',fileName]);
                end
            end
        end
    end

end


cd(matlabScriptPath);
rmpath(matlabScriptPath);

