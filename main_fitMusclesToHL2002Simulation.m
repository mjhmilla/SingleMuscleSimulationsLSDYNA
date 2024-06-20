flag_outerLoopMode=1;

if(flag_outerLoopMode==0)
    clc;
    close all;
    clear all;
    flag_fitInitialLength  = 0; 
    flag_fitTitinProperties= 1;
end



flag_testing  = 0;
maxIterations = 12;



addpath(genpath('fitting'));
addpath(genpath('postprocessing'));
addpath(genpath('ReferenceExperiments'));

%This script is to be run after main_fitMuscles has been used to 
%establish the broad fit of all of the curves. This script fits parameters
%that can only be determined numerically:
%
% 1. The initial path length s.t. lceNAT of all models is the same
%    just prior to the ramp when simulating HL2002 ramp_9mmps_9mm
% 2. The final passive when simulating the ramp_passive_9mmps_9mm
% 3. The values of lPevkPtN and beta1AHN which can only be determined
%    through simulation.

releaseName             = 'MPP_R931';

lsdynaBin = fullfile( filesep,  'scratch','tmp','mmillard',...
                       'lsdynaCompilation',releaseName,'mppdyna');

%Test to see if the Matlab terminal is in the correct directory
currDirContents = dir;
[pathToParent,parentFolderName,ext] = fileparts(currDirContents(1).folder);
rootFolderName = 'SingleMuscleSimulationsLSDYNA';
rootFolderPath = '';
if(strcmp(currDirContents(1).name,'.') ...
        && contains(parentFolderName,rootFolderName))
    rootFolderPath = pwd;
end 



%typeOfFitting
% 0. All: initial length
% 1. All: final passive force 
% 2. umat43: lPevkN
% 3. umat43: betaA

if(flag_fitInitialLength==1)
    %Initial length
    modelName     = 'mat156';
    typeOfFitting = 0;
    success = fittingSimulationHL2002(typeOfFitting, modelName, ...
                                      lsdynaBin, releaseName, rootFolderPath,...
                                      flag_testing, maxIterations);
    modelName     = 'umat41';
    typeOfFitting = 0;
    success = fittingSimulationHL2002(typeOfFitting, modelName, ...
                                      lsdynaBin, releaseName, rootFolderPath,...
                                      flag_testing, maxIterations);
    
    modelName     = 'umat43';
    typeOfFitting = 0;
    success = fittingSimulationHL2002(typeOfFitting, modelName, ...
                                      lsdynaBin, releaseName, rootFolderPath,...
                                      flag_testing, maxIterations);
end


if(flag_fitTitinProperties==1)
    typeOfFittingList = [2;3];
    %Titin properties
    modelName     = 'umat43';
    typeOfFitting = typeOfFittingList(1,1);
    success = fittingSimulationHL2002(typeOfFitting, modelName, ...
                                      lsdynaBin, releaseName, rootFolderPath,...
                                      flag_testing, maxIterations);
    modelName     = 'umat43';
    typeOfFitting = typeOfFittingList(2,1);
    success = fittingSimulationHL2002(typeOfFitting, modelName, ...
                                      lsdynaBin, releaseName, rootFolderPath,...
                                      flag_testing, maxIterations);

    %Update all umat43 files to have the same titin parameters

    %Load the updated umat43HL2002 file
    commonParameterFolder = fullfile('MPP_R931','common');
    umat43HL2002File      = fullfile(commonParameterFolder,...
                                ['catsoleusHL2002Umat43Parameters.k']);  

    umat43HL2002 = getAllParameterFieldsAndValues(umat43HL2002File);

    filesToUpdate = {'catsoleusHL1997Umat43Parameters.k',...
                     'catsoleusKBR1994Fig3Umat43Parameters.k',...
                     'catsoleusKBR1994Fig12Umat43Parameters.k'};

    for i=1:1:length(filesToUpdate)
      %Load the file, update, and write the titin parameters
      umat43File      = fullfile(commonParameterFolder,...
                                 filesToUpdate{i});  

      umat43 = getAllParameterFieldsAndValues(umat43File);

      for j=1:1:length(typeOfFittingList)
        fitInfo.model = 'umat43';
        fitInfo = getHL2002OptimizationSettings(...
                    umat43,fitInfo,typeOfFittingList(j,1));
        umat43.(fitInfo.optimizationVariable) = umat43HL2002.(fitInfo.optimizationVariable);
      end

      successUmat43  = writeLSDYNAMuscleParameterFile(umat43File,...
                                                      umat43,[]);    

    end
end





