%% This script performs the validation tests isometric, concentric and quick release 
%% for different release version of the referenceDataPath EHTMM
clc;
clear all;
close all;

%%
% User-defined script variables
%%

% Define which Releases shall be tested
Releases    =  {'MPP_R931'};

models(1) = struct('id',0,'name','');

%indexUmat41             = 1;
%models(indexUmat41).id  = 1;
%models(indexUmat41).name='umat41';

indexUmat43             = 1;
models(indexUmat43).id  = 1;
models(indexUmat43).name='umat43';

flag_preProcessSimulationData       = 0; 
%Setting this to 1 will perform any preprocessing needed of the enabled 
%experiments. At the moment this is limited to generating the random perturbation
%signals used in the impedance experiments.

flag_runSimulations                 = 1;
%Setting this to 1 will run the simulations that have been enabled

flag_postProcessSimulationData      = 1;
%Setting this to 1 will generate plots of the enabled experiments

flag_generateGenericPlots           = 0;
flag_generateSpecificPlots          = 1;


flag_enableIsometricExperiment          = 0;
flag_enableConcentricExperiment         = 0;
flag_enableQuickReleaseExperiment       = 0;
flag_enableEccentricExperiment          = 0;
flag_enableImpedanceExperiment          = 0;
flag_enableSinusoidExperiment           = 1;
flag_enableReflexExperiment             = 0;
flag_enableReflexExperiment_kN_mm_ms    = 0;

flag_aniType = 1; 
% This is only relevant when post-processing SinusoidExperiment
%0. human
%1. feline


%Lengthens muscle to sample force-length curves
flag_enableForceLengthExperiment        = 0; 


matlabScriptPath    = '/scratch/tmp/mmillard/muscleModeling/SingleMuscleSimulationsLSDYNA';
%matlabScriptPath = ['/home/mmillard/work/code/stuttgart/riccati/',...
%      'scratch/mmillard/muscleModeling/SingleMuscleSimulationsLSDYNA'];

lsdynaBin_SMP_931 = '/scratch/tmp/mmillard/lsdynaCompilation/SMP_R931/lsdyna';
lsdynaBin_MPP_931 = '/scratch/tmp/mmillard/lsdynaCompilation/MPP_R931/mppdyna';


addpath(matlabScriptPath);
cd(matlabScriptPath);


%% path to exp. reference
referenceDataPath= fullfile(matlabScriptPath,'ReferenceExperiments/');

numberOfSimulationTypes = flag_enableIsometricExperiment ...
                     +flag_enableConcentricExperiment ... 
                     +flag_enableQuickReleaseExperiment...
                     +flag_enableEccentricExperiment...
                     +flag_enableImpedanceExperiment...
                     +flag_enableForceLengthExperiment...
                     +flag_enableSinusoidExperiment...
                     +flag_enableReflexExperiment...
                     +flag_enableReflexExperiment_kN_mm_ms;


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
structFolder            = 'output/structs/';

numericDirectoryTree = genpath('numeric');
addpath(numericDirectoryTree);


preprocessingDirectoryTree = genpath('preprocessing');
addpath(preprocessingDirectoryTree);

postprocessingDirectoryTree = genpath('postprocessing');
addpath(postprocessingDirectoryTree);

%% Plot configuration
plotWidth         = 6;
plotHeight        = 6;        
plotHorizMarginCm = 1.5;
plotVertMarginCm  = 2.;  


simulationColorA = [0,0,1].*(0.9)+[1,1,1].*(0.1);
simulationColorB = [0,0,1].*(0.5)+[1,1,1].*(0.5);

dataColorA = [0,0,0].*(0.5)+[1,1,1].*(0.5);
dataColorB = [0,0,0].*(0.2)+[1,1,1].*(0.8);

binoutColorA = dataColorA;
binoutColorB = dataColorB;

musoutColorA = [1,0,0].*(1)+[0,0,1].*(0.);
musoutColorB = [1,0,0].*(0)+[0,0,1].*(1);


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
                        flag_enableReflexExperiment_kN_mm_ms);

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
                        flag_enableReflexExperiment_kN_mm_ms);
                    
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
            end
        end
    end
end

%% PostProcessing 
if(flag_postProcessSimulationData==1)

    cd(matlabScriptPath);

    figGeneric  = figure;
    figSpecific = figure;      
    
    %load inputFunctions
    load([structFolder,signalFileName]);

    for indexRelease = 1:length(Releases)
        cd(matlabScriptPath);

        Release = cell2mat(Releases(indexRelease));

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
                        flag_enableReflexExperiment_kN_mm_ms);            
              
            for indexSimulationType = 1:length(simulationType)
                

                simulationTypeStr = simulationType(indexSimulationType).type;
                clf(figGeneric);
                flag_figGenericDirty=0;
                clf(figSpecific);
                flag_figSpecificDirty=0;

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

                if(contains(simulationType(indexSimulationType).type,...
                           'sinusoid'))
                    switch flag_aniType
                        case 0
                            referenceDataFolder = [referenceDataFolder,...
                                            '/QuadraticBezierHumanCurves'];
                        case 1
                            referenceDataFolder = [referenceDataFolder,...
                                            '/QuadraticBezierFelineCurves'];
                        otherwise 
                            assert(0,'flag_aniType should be 0 (human) or 1 (feline)');
                    end
                end

                numberOfHorizontalPlotColumnsGeneric = length(simulationDirectories)-3+1;
                numberOfVerticalPlotRowsGeneric      = 14;
                                              
                [subPlotPanelGeneric, pageWidthGeneric,pageHeightGeneric]= ...
                      plotConfigGeneric(  numberOfHorizontalPlotColumnsGeneric,...
                                          numberOfVerticalPlotRowsGeneric,...
                                          plotWidth,plotHeight,...
                                          plotHorizMarginCm,plotVertMarginCm); 

                
                numberOfHorizontalPlotColumnsSpecific = 1;
                numberOfVerticalPlotRowsSpecific      = 1;
                switch (simulationTypeStr)
                    case 'eccentric'
                      numberOfHorizontalPlotColumnsSpecific = 1;
                      numberOfVerticalPlotRowsSpecific      = 6;
                    case 'isometric'
                      numberOfHorizontalPlotColumnsSpecific = 1;
                      numberOfVerticalPlotRowsSpecific      = 1;
                    case 'concentric'
                      numberOfHorizontalPlotColumnsSpecific = 1;
                      numberOfVerticalPlotRowsSpecific      = 1;
                    case 'quickrelease'
                      numberOfHorizontalPlotColumnsSpecific = 1;
                      numberOfVerticalPlotRowsSpecific      = 1;                 
                    case 'impedance'
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
                      numberOfVerticalPlotRowsSpecific      = 10; 
                    case 'reflex_kN_mm_ms'
                      numberOfHorizontalPlotColumnsSpecific = 3;
                      numberOfVerticalPlotRowsSpecific      = 10;    
                      
                end


                [subPlotPanelSpecific, pageWidthSpecific,pageHeightSpecific]= ...
                      plotConfigGeneric(  numberOfHorizontalPlotColumnsSpecific,...
                                          numberOfVerticalPlotRowsSpecific,...
                                          plotWidth,...
                                          plotHeight,...
                                          plotHorizMarginCm,...
                                          plotVertMarginCm);

                for indexSimulationTrial=3:deltaPoints:length(simulationDirectories)                    
                    cd(simulationTypePath);

                    flag_lastTrial=0;
                    if(indexSimulationTrial==length(simulationDirectories))
                      flag_lastTrial=1;
                    end
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
                    assert(musoutCount == 1);
                    
                    %% Load the muscle data
                    switch models(indexModel).name
                        case 'umat41'
                            [musout,success] = ...
                                readUmat41MusoutData(musoutFileList{1});  
                        case 'umat43'
                            [musout,success] = ...
                                readUmat43MusoutData(musoutFileList{1});  
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
                    if(flag_figGenericDirty==0)
                      flag_figGenericDirty=1;
                    end
                    
                    uniformModelData = createUniformMuscleModelData(...
                        models(indexModel).name,...
                        musout, lceOpt,fiso,ltslk,alpha);

                    if(flag_generateGenericPlots==1)
                        figGeneric =plotSimulationDataSummary(figGeneric,...
                            models(indexModel).name, binout,uniformModelData,...
                            indexColumn,subPlotPanelGeneric,...
                            numberOfVerticalPlotRowsGeneric,...
                            numberOfHorizontalPlotColumnsGeneric,...                              
                            simulationDirectories(indexSimulationTrial).name,...
                            indexSimulationTrial, length(simulationDirectories),...
                            lceOpt,fiso,ltslk,...
                            binoutColorA,binoutColorB,...
                            musoutColorA,musoutColorB);
                    end
                    
                    %% Add to the simulation specific plots
                    if(flag_generateSpecificPlots==1)
                        switch (simulationTypeStr)
                            case 'eccentric'
                                flag_addSimulationData=1;
                                if(flag_figSpecificDirty==0)
                                  flag_addReferenceData=1;
                                  flag_figSpecificDirty=1;
                                else
                                  flag_addReferenceData = 0;
                                end
                                indexColumn=1;
                                figSpecific =...
                                    plotEccentricSimulationData(figSpecific,...
                                        binout,uniformModelData,d3hspFileName,...
                                        indexColumn,subPlotPanelSpecific,...
                                        numberOfVerticalPlotRowsSpecific,...
                                        numberOfHorizontalPlotColumnsSpecific,...                              
                                        simulationDirectories(indexSimulationTrial).name,...
                                        indexSimulationTrial, length(simulationDirectories),...
                                        referenceDataFolder,...         
                                        lceOpt,fiso,ltslk,...
                                        flag_addReferenceData,flag_addSimulationData,...
                                        simulationColorA,simulationColorB,...
                                        dataColorA,dataColorB);
                            case 'concentric'
                                flag_addSimulationData=1;
                                if(flag_figSpecificDirty==0)
                                  flag_addReferenceData=1;
                                  flag_figSpecificDirty=1;
                                else
                                  flag_addReferenceData = 0;
                                end
                                indexColumn=1;
                                figSpecific =...
                                    plotConcentricSimulationData(figSpecific,binout,uniformModelData,...
                                        indexColumn,subPlotPanelSpecific,...
                                        numberOfVerticalPlotRowsSpecific,...
                                        numberOfHorizontalPlotColumnsSpecific,...                              
                                        simulationDirectories(indexSimulationTrial).name,...
                                        indexSimulationTrial, length(simulationDirectories),...
                                        referenceDataFolder,...
                                        flag_addReferenceData,flag_addSimulationData,...
                                        simulationColorA,simulationColorB,...
                                        dataColorA,dataColorB);
                            case 'isometric'
                                flag_addSimulationData=1;
                                if(flag_figSpecificDirty==0)
                                  flag_addReferenceData=1;
                                  flag_figSpecificDirty=1;
                                else
                                  flag_addReferenceData = 0;
                                end
                                indexColumn=1;
                                figSpecific =...
                                    plotIsometricSimulationData(figSpecific,binout,uniformModelData,...
                                        indexColumn,subPlotPanelSpecific,...
                                        numberOfVerticalPlotRowsSpecific,...
                                        numberOfHorizontalPlotColumnsSpecific,...                              
                                        simulationDirectories(indexSimulationTrial).name,...
                                        indexSimulationTrial, length(simulationDirectories),...
                                        referenceDataFolder,...
                                        flag_addReferenceData,flag_addSimulationData,...
                                        simulationColorA,simulationColorB,...
                                        dataColorA,dataColorB);

                            case 'quickrelease'
                                flag_addSimulationData=1;
                                if(flag_figSpecificDirty==0)
                                  flag_addReferenceData=1;
                                  flag_figSpecificDirty=1;
                                else
                                  flag_addReferenceData = 0;
                                end
                                indexColumn=1;
                                figSpecific =...
                                    plotQuickReleaseSimulationData(figSpecific,binout,uniformModelData,...
                                        indexColumn,subPlotPanelSpecific,...
                                        numberOfVerticalPlotRowsSpecific,...
                                        numberOfHorizontalPlotColumnsSpecific,...                              
                                        simulationDirectories(indexSimulationTrial).name,...
                                        indexSimulationTrial, length(simulationDirectories),...
                                        referenceDataFolder,...
                                        flag_addReferenceData,flag_addSimulationData,...
                                        simulationColorA,simulationColorB,...
                                        dataColorA,dataColorB);   
                            case 'impedance'
                                flag_addSimulationData=1;
                                if(flag_figSpecificDirty==0)                        
                                  flag_figSpecificDirty=1;
                                end
                                flag_addReferenceData = flag_lastTrial;
                                indexColumn=1;
                                [figSpecific,impedancePlotCounterUpd] =...
                                    plotImpedanceSimulationData(figSpecific,...
                                        inputFunctions,...
                                        binout,uniformModelData,d3hspFileName,...
                                        indexColumn,subPlotPanelSpecific,...
                                        numberOfVerticalPlotRowsSpecific,...
                                        numberOfHorizontalPlotColumnsSpecific,...                              
                                        simulationDirectories(indexSimulationTrial).name,...
                                        indexSimulationTrial, length(simulationDirectories),...
                                        referenceDataFolder,...         
                                        lceOpt,fiso,ltslk,...
                                        flag_addReferenceData,flag_addSimulationData,...
                                        impedancePlotCounter);
                                 impedancePlotCounter=impedancePlotCounterUpd;
                            case 'force_length'
                                %Only umat43 produces the curve-specific files right now.
                                if( strcmp( models(indexModel).name, 'umat43' ) )
                                    %Get the curve files
                                    curveSubstr = {'fal','fecmH','f1H','f2H'};
                                    curveCount=0;
                                    curveFileList ={''};
                                    for indexFile=1:1:length(fileList)
                                      for indexCurveType=1:1:length(curveSubstr)
                                          if(contains(fileList(indexFile).name,curveSubstr{indexCurveType}))
                                            curveCount=curveCount+1;
                                            if curveCount == 1
                                              curveFileList = {fileList(indexFile).name};
                                            else
                                              curveFileList = [curveFileList;fileList(indexFile).name];
                                            end                                            
                                          end
                                      end
                                    end
                                    assert(curveCount == 4);

                                    flag_addSimulationData=1;
                                    if(flag_figSpecificDirty==0)                        
                                      flag_figSpecificDirty=1;
                                      flag_addReferenceData=1;
                                    else
                                      flag_addReferenceData=0;
                                    end
                                    indexColumn=1;

                                    for indexCurve=1:1:length(curveFileList)
                                        curveData=curvereader(curveFileList{indexCurve});
                                        figSpecific =...
                                            plotForceLengthSimulationData(...
                                                figSpecific,curveData,...
                                                indexColumn,subPlotPanelSpecific,...
                                                numberOfVerticalPlotRowsSpecific,...
                                                numberOfHorizontalPlotColumnsSpecific,...                              
                                                simulationDirectories(indexSimulationTrial).name,...
                                                indexSimulationTrial, length(simulationDirectories),...
                                                referenceDataFolder,...
                                                flag_addReferenceData,flag_addSimulationData,...
                                                simulationColorA,simulationColorB,...
                                                dataColorA,dataColorB);
                                            flag_addReferenceData=0;
                                    end

                                end
                            case 'sinusoid'
                                %Only umat43 produces the curve-specific files right now.                                
                                if( strcmp( models(indexModel).name, 'umat43' ) )
                                   %Get the curve files
                                    curveSubstr = {'fal','fecmH','f1H','f2H','fv',...
                                                    'ftFcnN','ktFcnN','fCpFcnN'};
                                    curveCount=0;
                                    curveFileList ={''};
                                    for indexFile=1:1:length(fileList)
                                      for indexCurveType=1:1:length(curveSubstr)
                                          if(contains(fileList(indexFile).name,curveSubstr{indexCurveType}))
                                            curveCount=curveCount+1;
                                            if curveCount == 1
                                              curveFileList = {fileList(indexFile).name};
                                            else
                                              curveFileList = [curveFileList;fileList(indexFile).name];
                                            end                                            
                                          end
                                      end
                                    end
                                    assert(curveCount == length(curveSubstr)); 
                                    
                                    flag_addSimulationCurveData=1;
                                    flag_addSimulationOutputData=0;
                                    if(flag_figSpecificDirty==0)                        
                                      flag_figSpecificDirty=1;
                                      flag_addReferenceData=1;
                                    else
                                      flag_addReferenceData=0;
                                    end
                                    indexColumn=1;                                    

                                 
                                    for indexCurve=1:1:length(curveFileList)
                                        curveData=curvereader(curveFileList{indexCurve});
                                        figSpecific =...
                                            plotSinusoidSimulationDataUmat43(...
                                                figSpecific,musout,curveData,...
                                                indexColumn,subPlotPanelSpecific,...
                                                numberOfVerticalPlotRowsSpecific,...
                                                numberOfHorizontalPlotColumnsSpecific,...                              
                                                simulationDirectories(indexSimulationTrial).name,...
                                                indexSimulationTrial, length(simulationDirectories),...
                                                referenceDataFolder,...
                                                flag_addReferenceData,...
                                                flag_addSimulationCurveData,...
                                                flag_addSimulationOutputData);
                                            flag_addReferenceData=0;
                                    end
                                    flag_addReferenceData      =0;
                                    flag_addSimulationCurveData=0;
                                    flag_addSimulationOutputData=1;
                                    figSpecific =...
                                            plotSinusoidSimulationDataUmat43(...
                                                figSpecific,musout,curveData,...
                                                indexColumn,subPlotPanelSpecific,...
                                                numberOfVerticalPlotRowsSpecific,...
                                                numberOfHorizontalPlotColumnsSpecific,...                              
                                                simulationDirectories(indexSimulationTrial).name,...
                                                indexSimulationTrial, length(simulationDirectories),...
                                                referenceDataFolder,...
                                                flag_addReferenceData,...
                                                flag_addSimulationCurveData,...
                                                flag_addSimulationOutputData);
                                    here=1;
                                    
                                end
                            case 'reflex'    
                                if(flag_figSpecificDirty==0)                        
                                    flag_figSpecificDirty=1;
                                end

                                normCERefLength = 0;
                                lengthThreshold = 0;

                                workingDirectory = pwd;
                                switch models(indexModel).name
                                    case 'umat41'
                                        normCERefLength = musout.data(end,musout.indexLceRef);
                                        normCERefLength = normCERefLength/lceOpt;
                                        cd ..
                                        lengthThreshold = getLsdynaCardFieldValue(...
                                            simulationInformation(indexSimulationInfo).musclePropertyCard,...
                                            'thresh');
                                        
                                        %disp('Note: matching the reflex switching time of umat41 by ');
                                        %disp('  post-processing is not possible because the muscle ');
                                        %disp('  rapidly shortens and the data is often too coarsely');
                                        %disp('  sampled to catch the point where the threshold is ');
                                        %disp('  crossed.');
                                        
                                        %lengthThreshold = lengthThreshold;%*0.999; 
                                        cd(workingDirectory)
                                    case 'umat43'
                                        normCERefLength = musout.data(end,musout.indexLceNRef);                                        
                                        cd ..
                                        lengthThreshold = getLsdynaCardFieldValue(...
                                            simulationInformation(indexSimulationInfo).musclePropertyCard,...
                                            'ctrlThrsh');
                                        cd(workingDirectory);
                                        
                                end

                                
                                figSpecific = plotReflexSimulationData(...
                                                figSpecific,...
                                                models(indexModel).name, ...
                                                lceOpt,...
                                                musout,...                                                
                                                uniformModelData,...
                                                normCERefLength,...
                                                lengthThreshold,...
                                                indexColumn,subPlotPanelSpecific,...
                                                numberOfVerticalPlotRowsSpecific,...
                                                numberOfHorizontalPlotColumnsSpecific,...                              
                                                simulationDirectories(indexSimulationTrial).name,...
                                                indexSimulationTrial,...
                                                length(simulationDirectories));
                                            
                            case 'reflex_kN_mm_ms'    
                                if(flag_figSpecificDirty==0)                        
                                    flag_figSpecificDirty=1;
                                end

                                normCERefLength = 0;
                                lengthThreshold = 0;

                                workingDirectory = pwd;
                                switch models(indexModel).name
                                    case 'umat41'
                                        normCERefLength = musout.data(end,musout.indexLceRef);
                                        normCERefLength = normCERefLength/lceOpt;
                                        cd ..
                                        lengthThreshold = getLsdynaCardFieldValue(...
                                            simulationInformation(indexSimulationInfo).musclePropertyCard,...
                                            'thresh');
                                        
                                        %disp('Note: matching the reflex switching time of umat41 by ');
                                        %disp('  post-processing is not possible because the muscle ');
                                        %disp('  rapidly shortens and the data is often too coarsely');
                                        %disp('  sampled to catch the point where the threshold is ');
                                        %disp('  crossed.');
                                        
                                        lengthThreshold = lengthThreshold*0.999; 
                                        cd(workingDirectory)
                                    case 'umat43'
                                        normCERefLength = musout.data(end,musout.indexLceNRef);                                        
                                        cd ..
                                        lengthThreshold = getLsdynaCardFieldValue(...
                                            simulationInformation(indexSimulationInfo).musclePropertyCard,...
                                            'ctrlThrsh');
                                        cd(workingDirectory);
                                        
                                end

                                
                                figSpecific = plotReflexSimulationData(...
                                                figSpecific,...
                                                models(indexModel).name, ...
                                                lceOpt,...
                                                musout,...                                                
                                                uniformModelData,...
                                                normCERefLength,...
                                                lengthThreshold,...
                                                indexColumn,subPlotPanelSpecific,...
                                                numberOfVerticalPlotRowsSpecific,...
                                                numberOfHorizontalPlotColumnsSpecific,...                              
                                                simulationDirectories(indexSimulationTrial).name,...
                                                indexSimulationTrial,...
                                                length(simulationDirectories));                                            
                                
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
            end
        end
    end

end



rmpath(matlabScriptPath);

