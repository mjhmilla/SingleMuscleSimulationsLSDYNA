clc;
close all;
clear all;

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


flag_testing=0;

modelName     = 'umat43';
typeOfFitting =2;
% 0. All: initial length
% 1. All: final passive force
% 2. umat43: lPevkN
% 3. umat43: betaA

success = fittingSimulationHL2002(typeOfFitting, modelName, ...
                                  lsdynaBin, releaseName, rootFolderPath,...
                                  flag_testing);






