%% This script performs the validation tests isometric, concentric and quick release 
%% for different release version of thereferenceDataPath EHTMM

clear all;
close all;

%%
% User-defined script variables
%%
flag_runSimulations               = 0;
flag_postProcessSimulationData    = 1;


%matlabScriptPath    = '/scratch/tmp/mmillard/SingleMuscleSimulationsLSDYNA';
matlabScriptPath = ['/home/mjhmilla/dev/projectsBig/stuttgart/scholze',...
                    '/scratch/mmillard/SingleMuscleSimulationsLSDYNA'];

addpath(matlabScriptPath);

%binoutreaderPath='/home/itm/institut/tools/matlab/Apps/LS_Dyna/';
%addpath(binoutreaderPath);

%% path to exp. reference
referenceDataPath= fullfile(matlabScriptPath,'ReferenceExperiments/');

simulationInformation(1) = struct('type',[],'musclePropertyFile',[],...
                                  'optimalFiberLength','',...
                                  'maximumIsometricForce','',...
                                  'tendonSlackLength','',...
                                  'parametersInMuscleCard',0);
idx=1;
% simulationInformation(idx).type               = 'quickrelease';
% simulationInformation(idx).musclePropertyFile = 'matpiglet.k';
% simulationInformation(idx).optimalFiberLength     = 'lCEopt';
% simulationInformation(idx).maximumIsometricForce  = 'Fmax';
% simulationInformation(idx).tendonSlackLength      = 'lSEE0';
% simulationInformation(idx).parametersInMuscleCard = 1;
% 
% idx=idx+1;
% simulationInformation(idx).type               = 'isometric';
% simulationInformation(idx).musclePropertyFile = 'matpiglet.k';
% simulationInformation(idx).optimalFiberLength     = 'lCEopt';
% simulationInformation(idx).maximumIsometricForce  = 'Fmax';
% simulationInformation(idx).tendonSlackLength      = 'lSEE0';
% simulationInformation(idx).parametersInMuscleCard = 1;
% 
% idx=idx+1;
% simulationInformation(idx).type               = 'concentric';
% simulationInformation(idx).musclePropertyFile = 'matpiglet.k';
% simulationInformation(idx).optimalFiberLength     = 'lCEopt';
% simulationInformation(idx).maximumIsometricForce  = 'Fmax';
% simulationInformation(idx).tendonSlackLength      = 'lSEE0';
% simulationInformation(idx).parametersInMuscleCard = 1;

%idx=idx+1;
simulationInformation(idx).type                   = 'eccentric';
simulationInformation(idx).musclePropertyFile     = 'eccentric.k';
simulationInformation(idx).optimalFiberLength     = 'lopt';
simulationInformation(idx).maximumIsometricForce  = 'fiso';
simulationInformation(idx).tendonSlackLength      = 'ltslk';
simulationInformation(idx).parametersInMuscleCard = 0;

%simulationInformation(1).type               = 'concentric';
%simulationInformation(1).musclePropertyFile = 'matpiglet.k';
%simulationInformation(1).muscleProperties   = {'lCEopt','Fmax'};

%simulationInformation(1).type               = 'isometric';
%simulationInformation(1).musclePropertyFile = 'matpiglet.k';
%simulationInformation(1).muscleProperties   = {'lCEopt','Fmax'};

%simulationInformation(1).type               = 'eccentric';
%simulationInformation(1).musclePropertyFile = 'matpiglet.k';
%simulationInformation(1).muscleProperties   = {'lCEopt','Fmax'};


% Define which Releases shall be tested
Releases    =  {'SMP_R931'};
% Releases    = {'EHTM10','EHTM20'}; % Releases    = {'EHTM21'};

% Define if all all datapoints are used or only some of them?
deltaPoints  = 1; % every 2nd/3rd/...

%% paths
outputFolder            = 'output';
postprocessingDirectoryTree = genpath('postprocessing');
addpath(postprocessingDirectoryTree);

%% Plot configuration

numberOfHorizontalPlotColumnsGeneric = 3;
numberOfVerticalPlotRowsGeneric      = 13;
plotWidth         = 6;
plotHeight        = 6;        
plotHorizMarginCm = 1.5;
plotVertMarginCm  = 2.;                  


[subPlotPanelGeneric, pageWidthGeneric,pageHeightGeneric]= ...
    plotConfigGeneric(  numberOfHorizontalPlotColumnsGeneric,...
                        numberOfVerticalPlotRowsGeneric,...
                        plotWidth,plotHeight,...
                        plotHorizMarginCm,plotVertMarginCm);

numberOfHorizontalPlotColumnsSpecific = 2;
numberOfVerticalPlotRowsSpecific      = 6;

[subPlotPanelSpecific, pageWidthSpecific,pageHeightSpecific]= ...
    plotConfigGeneric(  numberOfHorizontalPlotColumnsSpecific,...
                        numberOfVerticalPlotRowsSpecific,...
                        plotWidth,plotHeight,...
                        plotHorizMarginCm,plotVertMarginCm);


simulationColorA = [0,0,1].*(0.9)+[1,1,1].*(0.1);
simulationColorB = [0,0,1].*(0.5)+[1,1,1].*(0.5);

dataColorA = [0,0,0].*(0.5)+[1,1,1].*(0.5);
dataColorB = [0,0,0].*(0.2)+[1,1,1].*(0.8);

binoutColorA = dataColorA;
binoutColorB = dataColorB;

musoutColorA = [1,0,0].*(1)+[0,0,1].*(0.);
musoutColorB = [1,0,0].*(0)+[0,0,1].*(1);

%%
% Run each simulation and extract the desired output data
%%
for indexRelease = 1:length(Releases)

    Release = cell2mat(Releases(indexRelease));
    switch Release
        case 'SMP_R931'
            lsdynaBin = '/scratch/tmp/mmillard/SMP_R931/lsdyna';
            
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
            if(flag_runSimulations==1)
                system(['rm -f *.csv d3* matsum musout* messag* glstat',...
                         ' nodout spcforc lspost*']);
                system([lsdynaBin,' i=',...
                        simulationDirectories(indexSimulationTrial).name,...
                        '.k']);
            end
            
            %if(flag_postProcessSimulationData==1)
            %    system('lspp43 c=ausw.cfile -nographics');
            %end
            
            %% import output signal
%             data=[];
%             switch simulationType
%                 case 'eccentric'
%                     %signal = 'con_vel_nod2.csv';
%                     [output, status] = binoutreader('dynaOutputFile','binout');
%                     data  = [output.nodout.time',output.elout.beam.axial];                
%                 case 'isometric'
%                     %signal = 'forc.csv';
%                     [output, status] = binoutreader('dynaOutputFile','binout');
%                     data  = [output.elout.beam.time',output.elout.beam.axial];
%                 case 'concentric'
%                     %signal = 'con_vel_nod2.csv';
%                     [output, status] = binoutreader('dynaOutputFile','binout');
%                     data  = [output.nodout.time',output.nodout.z_velocity];
%                 case 'quickrelease'
%                     %signal = 'quick_release_crossplot.csv';
%                     [output, status] = binoutreader('dynaOutputFile','binout');
%                     data  = [output.nodout.z_velocity,output.elout.beam.axial];
%                 otherwise
%                     error('Check validation type - does not match any of them')
%             end
%             Validation.(Release).(simulationType)(indexSimulationTrial-2).data = data;
%             Validation.(Release).(simulationType)(indexSimulationTrial-2).name = simulationDirectories(indexSimulationTrial).name;            
%                                                
            cd(simulationTypePath);
        end
    end
end

%% PostProcessing 

if(flag_postProcessSimulationData==1)


  figGeneric  = figure;
  figSpecific = figure;      
  
  for indexRelease = 1:length(Releases)

      Release = cell2mat(Releases(indexRelease));

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

          for indexSimulationTrial=3:deltaPoints:length(simulationDirectories)
              cd(simulationTypePath);

              %% Load the muscle properties
              lceOpt=NaN;
              fiso=NaN;
              ltslk=NaN;
              if(simulationInformation(idx).parametersInMuscleCard==1)
                  lceOpt = ...
                      getMuscleCardFieldValue(...
                        simulationInformation(indexSimulationType).musclePropertyFile,...
                        simulationInformation(indexSimulationType).optimalFiberLength);
                  fiso = ...
                      getMuscleCardFieldValue(...
                        simulationInformation(indexSimulationType).musclePropertyFile,...
                        simulationInformation(indexSimulationType).maximumIsometricForce);
                  ltslk = ...
                      getMuscleCardFieldValue(...
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


              


              %% Add to the generic plots
              indexColumn = 1;
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
                          plotEccentricSimulationData(figSpecific,binout,musout,...
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

% simulationTypeList = fieldnames(Validation.(Release));
% for indexSimulationType = 1:length( simulationTypeList)
%     simulationType = cell2mat(simulationTypeList(indexSimulationType));
%     figure(indexSimulationType);
%     hold on;
%     clear h;
%     for dataPoints = 1:deltaPoints:length(Validation.(Release).(simulationType)) % only every 2nd point
%         dataSet = Validation.(Release).(simulationType)(dataPoints);
%         switch(simulationType)
%             case 'eccentric'
%                 x = dataSet.data(find(dataSet.data(:,1), 1 )-1:end,1);
%                 y = dataSet.data(find(dataSet.data(:,1), 1 )-1:end,2);
%                 h(dataPoints)= ...
%                     plot(x,y,...
%                         'DisplayName',dataSet.name);
%                 %axis([0 12 0 35]);
%                 set(gca,'XTick',[1:1:12])
%                 ylabel('Force (N)','interpreter','latex'); 
%                 xlabel('Time (s)','interpreter','latex');
%             case 'quickrelease'
%                 x = dataSet.data(find(dataSet.data(:,1), 1 )-1:end,1);
%                 y = dataSet.data(find(dataSet.data(:,1), 1 )-1:end,2);
%                 h(dataPoints)= ...
%                     plot(x,y,...
%                         'DisplayName',dataSet.name);
%                 axis([0 0.5 0 30]);
%                 set(gca,'XTick',0:0.10:0.5)
%                 ylabel('muscle force in N','interpreter','latex'); 
%                 xlabel('contraction velocity in $\frac{m}{s}$','interpreter','latex');
%                         
%             case 'concentric'
%                 % starttime = time of lift-off
%                 %dataSet.data      = dataSet.data((dataSet.data(:,2)~=0),:);
%                 %dataSet.data(:,1) = dataSet.data(:,1)-dataSet.data(1,1);
%                 indexStart = find(dataSet.data(:,2) > 0,1)-1;
%                 x = dataSet.data(indexStart:end,1)-dataSet.data(indexStart,1);
%                 y = dataSet.data(indexStart:end,2);
%                 
%                 h(dataPoints)=...
%                     plot(   x,y,...
%                             'DisplayName',dataSet.name);
%                 set(groot, 'defaultAxesTickLabelInterpreter','latex'); 
%                 set(groot, 'defaultLegendInterpreter','latex');
%                 grid on
%                 axis([0 0.2 0 0.12]);
%                 set(gca,'XTick',0:0.05:0.2)
%                 set(gca,'YTick',0:0.02:0.12)
%                 ylabel('velocity in $\frac{m}{s}$','interpreter','latex'); 
%                 xlabel('time in s','interpreter','latex');
%                 
%             case 'isometric'
%                 
%                 h(dataPoints)=...
%                     plot(   dataSet.data(:,1),...
%                             dataSet.data(:,2),...
%                             'DisplayName',dataSet.name);
%                         
%                 set(groot, 'defaultAxesTickLabelInterpreter','latex'); 
%                 set(groot, 'defaultLegendInterpreter','latex');
%                 grid on
%                 axis([0 1.5 0 40]);
%                 set(gca,'XTick',0:0.2:1.5)
%                 set(gca,'YTick',0:10:40)
%                 ylabel('muscle force in N','interpreter','latex'); 
%                 xlabel('time in s','interpreter','latex');
%                 
%             otherwise
%                 error('Plot error: validation type does not match ')
%         end
%         
%     end

%     %% Reference
%     contRef = dir(fullfile(referenceDataPath,simulationType,'*.dat'));
%     for refId = 1:deltaPoints:length(contRef) %only every 2nd point
%         refData = importdata(fullfile(contRef(refId).folder,contRef(refId).name));
%         plot(refData.data(:,1),refData.data(:,2),'--k','DisplayName',['Ref' contRef(refId).name]);
%     end
%     %legend([h])
    
% end

rmpath(matlabScriptPath);

