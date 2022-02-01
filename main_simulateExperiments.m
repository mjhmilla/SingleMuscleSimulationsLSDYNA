%% This script performs the validation tests isometric, concentric and quick release 
%% for different release version of thereferenceDataPath EHTMM

clear all;
close all;

%%
% User-defined script variables
%%
disp('Delete impedance subfolders');
disp('Re-run preprocessing');
flag_preProcessSimulationData     = 0; 
%Setting this to 1 will perform any preprocessing needed of the enabled 
%experiments. At the moment this is limited to generating the random perturbation
%signals used in the impedance experiments.

flag_runSimulations               = 1;
%Setting this to 1 will run the simulations that have been enabled

flag_postProcessSimulationData    = 0;
%Setting this to 1 will generate plots of the enabled experiments



flag_enableIsometricExperiment          = 0;
flag_enableConcentricExperiment         = 0;
flag_enableQuickReleaseExperiment       = 0;
flag_enableEccentricExperiment          = 0;
flag_enableImpedanceExperiment          = 1;
    


matlabScriptPath    = '/scratch/tmp/mmillard/SingleMuscleSimulationsLSDYNA';
%matlabScriptPath = ['/home/mjhmilla/dev/projectsBig/stuttgart/scholze',...
%                    '/scratch/mmillard/SingleMuscleSimulationsLSDYNA'];
lsdynaBin_SMP_931 = '/scratch/tmp/mmillard/SMP_R931/lsdyna';

addpath(matlabScriptPath);
cd(matlabScriptPath);


%% path to exp. reference
referenceDataPath= fullfile(matlabScriptPath,'ReferenceExperiments/');

numberOfSimulations = flag_enableIsometricExperiment ...
                     +flag_enableConcentricExperiment ... 
                     +flag_enableQuickReleaseExperiment...
                     +flag_enableEccentricExperiment...
                     +flag_enableImpedanceExperiment;
if(numberOfSimulations==0)
    numberOfSimulations=1;
end

simulationInformation(numberOfSimulations) = ...
    struct('type',[],'musclePropertyFile',[],...
          'optimalFiberLength','',...
          'maximumIsometricForce','',...
          'tendonSlackLength','',...
          'parametersInMuscleCard',0);
idx=0;

if(flag_enableIsometricExperiment==1)
  idx=idx+1;
  simulationInformation(idx).type               = 'isometric';
  simulationInformation(idx).musclePropertyFile = 'matpiglet.k';
  simulationInformation(idx).optimalFiberLength     = 'lCEopt';
  simulationInformation(idx).maximumIsometricForce  = 'Fmax';
  simulationInformation(idx).tendonSlackLength      = 'lSEE0';
  simulationInformation(idx).parametersInMuscleCard = 1;
end

if(flag_enableConcentricExperiment==1)
  idx=idx+1;
  simulationInformation(idx).type               = 'concentric';
  simulationInformation(idx).musclePropertyFile = 'matpiglet.k';
  simulationInformation(idx).optimalFiberLength     = 'lCEopt';
  simulationInformation(idx).maximumIsometricForce  = 'Fmax';
  simulationInformation(idx).tendonSlackLength      = 'lSEE0';
  simulationInformation(idx).parametersInMuscleCard = 1;
end 

if(flag_enableQuickReleaseExperiment==1)
  idx=idx+1;
  simulationInformation(idx).type               = 'quickrelease';
  simulationInformation(idx).musclePropertyFile = 'matpiglet.k';
  simulationInformation(idx).optimalFiberLength     = 'lCEopt';
  simulationInformation(idx).maximumIsometricForce  = 'Fmax';
  simulationInformation(idx).tendonSlackLength      = 'lSEE0';
  simulationInformation(idx).parametersInMuscleCard = 1;
end 

if(flag_enableEccentricExperiment==1)
  idx=idx+1;
  simulationInformation(idx).type                   = 'eccentric';
  simulationInformation(idx).musclePropertyFile     = 'eccentric.k';
  simulationInformation(idx).optimalFiberLength     = 'lopt';
  simulationInformation(idx).maximumIsometricForce  = 'fiso';
  simulationInformation(idx).tendonSlackLength      = 'ltslk';
  simulationInformation(idx).parametersInMuscleCard = 0;
end 

if(flag_enableImpedanceExperiment==1)
  idx=idx+1;
  simulationInformation(idx).type                   = 'impedance';
  simulationInformation(idx).musclePropertyFile     = 'impedance.k';
  simulationInformation(idx).optimalFiberLength     = 'lopt';
  simulationInformation(idx).maximumIsometricForce  = 'fiso';
  simulationInformation(idx).tendonSlackLength      = 'ltslk';
  simulationInformation(idx).parametersInMuscleCard = 0;
end 


% Define which Releases shall be tested
Releases    =  {'SMP_R931'};
% Releases    = {'EHTM10','EHTM20'}; % Releases    = {'EHTM21'};

% Define if all all datapoints are used or only some of them?
deltaPoints  = 1; % every 2nd/3rd/...

%% Impedance experiment evaluation

mm2m = 0.001;
sampleFrequency = 1/0.003; % Sampling frequency
paddingPoints   = round(0.5*sampleFrequency);
samplePoints    = 2048;% Number of points in the random sequence
totalPoints     = samplePoints;
amplitudeMM     = [0.4, 0.8, 1.6]'; %Amplitude scaling in mm
bandwidthHz     = [ 15,  35,  90]'; %bandwidth in Hz;

flag_generateRandomBaselineSignal    = 1; %Only needs to be done once
flag_processRandomBaselineSignal     = 1; %Only needs to be done once               


signalFileEnding = sprintf('_%sHz_%s',num2str(round(sampleFrequency,0)),...
                                 num2str(samplePoints));
signalFileName      = [ 'systemIdInputFunctions',signalFileEnding,'.mat'];
baseSignalFileName  = [ 'baseFunction',signalFileEnding,'.mat'];

%% paths
outputFolder            = 'output';
structFolder            = 'output/structs/';

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

        Release = cell2mat(Releases(indexRelease));
        simulationReleasePath = fullfile(matlabScriptPath,Release);
                
        for indexSimulationType = 1:length(simulationInformation)
            simulationType = simulationInformation(indexSimulationType).type;


            switch simulationType
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
                    excitationSeries = [0.05, 0.234238575712566, 0.5, 1.];
                    impedanceFolder = [simulationReleasePath,'/',simulationType];

                    [success] = writeImpedanceSimulationFiles(...
                                excitationSeries,...
                                inputFunctions,...
                                impedanceFolder);

                    [success] = plotPerturbationWaveforms( inputFunctions,...
                                                plotWidth,...
                                                plotHeight,...
                                                plotHorizMarginCm,...
                                                plotVertMarginCm,...
                                                [outputFolder,'/',Release]);

                otherwise
                    disp(['Preprocessing not required: ', simulationType]);
            end

            
        end
  end

end

%% Simulation

if(flag_runSimulations==1)
  for indexRelease = 1:length(Releases)

      Release = cell2mat(Releases(indexRelease));
      switch Release
          case 'SMP_R931'
              lsdynaBin = lsdynaBin_SMP_931;
              
          otherwise
              error('Release not specified yet')
      end
      simulationReleasePath = fullfile(matlabScriptPath,Release);
      
      
      for indexSimulationType = 1:length(simulationInformation)
          simulationType = simulationInformation(indexSimulationType).type;
          simulationTypePath = fullfile(simulationReleasePath,simulationType);

          cd(simulationTypePath);
          simulationDirectories = dir;
          simulationDirectories = ...
            simulationDirectories([simulationDirectories.isdir]==true);

          for indexSimulationTrial=3:deltaPoints:length(simulationDirectories)
              
              cd(simulationDirectories(indexSimulationTrial).name);
              
              %% generate output signals                        
              system(['rm -f *.csv d3* matsum musout* messag* glstat',...
                       ' nodout spcforc lspost*']);
              system([lsdynaBin,' i=',...
                      simulationDirectories(indexSimulationTrial).name,...
                      '.k']);
              
              cd(simulationTypePath);
          end
      end
  end
end

%% PostProcessing 
if(flag_postProcessSimulationData==1)


  figGeneric  = figure;
  figSpecific = figure;      
  
  load([structFolder,signalFileName]);

  for indexRelease = 1:length(Releases)


      Release = cell2mat(Releases(indexRelease));
      simulationReleasePath = fullfile(matlabScriptPath,Release);
        

      for indexSimulationType = 1:length(simulationInformation)
          
          clf(figGeneric);
          flag_figGenericDirty=0;
          clf(figSpecific);
          flag_figSpecificDirty=0;

        
          simulationType   = simulationInformation(indexSimulationType).type;
          simulationTypePath  ...
            = fullfile(simulationReleasePath,simulationType);
  
          cd(simulationTypePath);
          simulationDirectories           = dir;
          simulationDirectories           = ...
            simulationDirectories([simulationDirectories.isdir]==true);
  
          %Set the path for the reference data
          referenceDataFolder = [referenceDataPath,simulationType];

          numberOfHorizontalPlotColumnsGeneric = length(simulationDirectories)-3+1;
          numberOfVerticalPlotRowsGeneric      = 13;
                                        
          [subPlotPanelGeneric, pageWidthGeneric,pageHeightGeneric]= ...
                plotConfigGeneric(  numberOfHorizontalPlotColumnsGeneric,...
                                    numberOfVerticalPlotRowsGeneric,...
                                    plotWidth,plotHeight,...
                                    plotHorizMarginCm,plotVertMarginCm); 

          
          numberOfHorizontalPlotColumnsSpecific = 1;
          numberOfVerticalPlotRowsSpecific      = 1;
          switch (simulationType)
              case 'eccentric'
                numberOfHorizontalPlotColumnsSpecific = 2;
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
                numberOfHorizontalPlotColumnsSpecific = ...
                    length(simulationDirectories)-3+1;
                numberOfVerticalPlotRowsSpecific      = 5;                  
          end


          [subPlotPanelSpecific, pageWidthSpecific,pageHeightSpecific]= ...
                plotConfigGeneric(  numberOfHorizontalPlotColumnsSpecific,...
                                    numberOfVerticalPlotRowsSpecific,...
                                    plotWidth,plotHeight,...
                                    plotHorizMarginCm,plotVertMarginCm);

          for indexSimulationTrial=3:deltaPoints:length(simulationDirectories)
              cd(simulationTypePath);

              %% Load the muscle properties
              lceOpt=NaN;
              fiso=NaN;
              ltslk=NaN;
              if(simulationInformation(indexSimulationType).parametersInMuscleCard==1)
                  lceOpt = ...
                      getLsdynaCardFieldValue(...
                        simulationInformation(indexSimulationType).musclePropertyFile,...
                        simulationInformation(indexSimulationType).optimalFiberLength);
                  fiso = ...
                      getLsdynaCardFieldValue(...
                        simulationInformation(indexSimulationType).musclePropertyFile,...
                        simulationInformation(indexSimulationType).maximumIsometricForce);
                  ltslk = ...
                      getLsdynaCardFieldValue(...
                        simulationInformation(indexSimulationType).musclePropertyFile,...
                        simulationInformation(indexSimulationType).tendonSlackLength); 
              else
                  lceOpt = ...
                      getParameterFieldValue(...
                        simulationInformation(indexSimulationType).musclePropertyFile,...
                        simulationInformation(indexSimulationType).optimalFiberLength);
                  fiso = ...
                      getParameterFieldValue(...
                        simulationInformation(indexSimulationType).musclePropertyFile,...
                        simulationInformation(indexSimulationType).maximumIsometricForce);
                  ltslk = ...
                      getParameterFieldValue(...
                        simulationInformation(indexSimulationType).musclePropertyFile,...
                        simulationInformation(indexSimulationType).tendonSlackLength);                   

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
              [musout,success] = musoutreader(musoutFileList{1});              

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
              [binout,status] = binoutreader('dynaOutputFile','binout');


              %% Load the d3hsp file which contains parameters
              d3hspFileName = 'd3hsp';


              %% Add to the generic plots
              indexColumn = (indexSimulationTrial-3)+1;
              if(flag_figGenericDirty==0)
                flag_figGenericDirty=1;
              end
              figGeneric =plotSimulationDataSummary(figGeneric,binout,musout,...
                              indexColumn,subPlotPanelGeneric,...
                              numberOfVerticalPlotRowsGeneric,...
                              numberOfHorizontalPlotColumnsGeneric,...                              
                              simulationDirectories(indexSimulationTrial).name,...
                              indexSimulationTrial, length(simulationDirectories),...
                              lceOpt,fiso,ltslk,...
                              binoutColorA,binoutColorB,...
                              musoutColorA,musoutColorB);

              %% Add to the simulation specific plots
              switch (simulationType)
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
                              binout,musout,d3hspFileName,...
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
                          plotConcentricSimulationData(figSpecific,binout,musout,...
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
                          plotIsometricSimulationData(figSpecific,binout,musout,...
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
                          plotQuickReleaseSimulationData(figSpecific,binout,musout,...
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
                        flag_addReferenceData=1;
                        flag_figSpecificDirty=1;
                      else
                        flag_addReferenceData = 0;
                      end
                      figSpecific =...
                          plotImpedanceSimulationData(figSpecific,...
                              inputFunctions,...
                              binout,musout,d3hspFileName,...
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
              end

          end
        
          if(flag_figGenericDirty==1)
              figure(figGeneric);  
              figGeneric=configPlotExporter(figGeneric, pageWidthGeneric, pageHeightGeneric);
              fileName =    ['fig_',Release,'_',...
                            simulationInformation(indexSimulationType).type,...
                            '_Generic.pdf'];
              print('-dpdf', [matlabScriptPath,'/',outputFolder,'/',Release,'/',fileName]);
          end

          if(flag_figSpecificDirty==1)
              figure(figSpecific);  
              figSpecific=configPlotExporter(figSpecific, pageWidthSpecific, pageHeightSpecific);
              fileName =    ['fig_',Release,'_',...
                            simulationInformation(indexSimulationType).type,...
                            '_Specific.pdf'];
              print('-dpdf', [matlabScriptPath,'/',outputFolder,'/',Release,'/',fileName]);
          end
      end
  end

end



rmpath(matlabScriptPath);
