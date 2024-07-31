%%
% SPDX-FileCopyrightText: 2024 Matthew Millard <millard.matthew@gmail.com>
%
% SPDX-License-Identifier: MIT
%
%%
function fitInfo = getHL2002FittingSimulationInfo(modelName,...
                                rootFolderName,...
                                releaseName,...
                                typeOfFitting,...
                                experimentalFittingDataFolder)

fitFolder='fit_HerzogLeonard2002';

flag_passiveSimulation=0;
flag_activeSimulation =0;

timeFinal = 0;
timeAnalysis = 0;

simulationType       = '';
optimizationVariable = '';

switch typeOfFitting
    case 0
        %Solve for the best starting length
        flag_activeSimulation =1;
    case 1
        %Solve for the best passive force
        flag_passiveSimulation=1;        
    case 2
        %umat43: Solve for the best lpevkN
        flag_activeSimulation =1;        
    case 3
        %umat43: Solve for the best betaA
        flag_activeSimulation =1;

end

fitInfo=struct('type','',...
                'simulationFolder',[],...
                'simulationFile',[],...
                'simulationConstantFile',[],...
                'timeFinal',0,...
                'timeAnalysis',0,...
                'optimizationVariable','',...
                'optimizationDelta',0,...
                'optimizationBounds',[],...
                'model',modelName,...
                'expTime',[],...
                'expForce',[],...
                'expLength',[]);

expData = readmatrix([experimentalFittingDataFolder,filesep,...
                         'dataHerzogLeonard2002Figure7B.dat'],...
                         'NumHeaderLines',1);
switch modelName
    case 'mat156'
        if(flag_passiveSimulation==1)

            fitInfo.simulationFolder = ...
                [rootFolderName,filesep,releaseName,filesep,modelName,...
                filesep,fitFolder,filesep,...
                'ramp_passive_9mmps_9mm'];

            fitInfo.simulationFile = ...
                ['ramp_passive_9mmps_9mm.k']; 

            fitInfo.simulationConstantFile     = ...
              [rootFolderName,filesep,releaseName,filesep,'common',...
                 filesep,'catsoleusHL2002Mat156Parameters.k'];

            fitInfo.expTime     =expData(:,1);
            fitInfo.expForce    =expData(:,12);
            fitInfo.expLength   =expData(:,13);

        end
        if(flag_activeSimulation==1)

            fitInfo.type = simulationType;

            fitInfo.simulationFolder = ...
                [rootFolderName,filesep,releaseName,filesep,modelName,...
                filesep,fitFolder,filesep,...
                'ramp_9mmps_9mm'];

            fitInfo.simulationFile = ...
                ['ramp_9mmps_9mm.k']; 

            fitInfo.simulationConstantFile     = ...
              [rootFolderName,filesep,releaseName,filesep,'common',...
                 filesep,'catsoleusHL2002Mat156Parameters.k'];

            fitInfo.expTime     =expData(:,1);
            fitInfo.expForce    =expData(:,10);
            fitInfo.expLength   =expData(:,11);            
        
        end
    case 'umat41'
        if(flag_passiveSimulation==1)

            fitInfo.type  = simulationType;

            fitInfo.simulationFolder = ...
                [rootFolderName,filesep,releaseName,filesep,modelName,...
                filesep,fitFolder,filesep,...
                'ramp_passive_9mmps_9mm'];

            fitInfo.simulationFile = ...
                ['ramp_passive_9mmps_9mm.k']; 

            fitInfo.simulationConstantFile = ...
                [rootFolderName,filesep,releaseName,filesep,'common',...
                 filesep,'catsoleusHL2002Umat41Parameters.k']; 

            fitInfo.expTime     =expData(:,1);
            fitInfo.expForce    =expData(:,12);
            fitInfo.expLength   =expData(:,13);              
            
        end
        if(flag_activeSimulation==1)

            fitInfo.type  = simulationType;

            fitInfo.simulationFolder = ...
                [rootFolderName,filesep,releaseName,filesep,modelName,...
                filesep,fitFolder,filesep,...
                'ramp_9mmps_9mm'];

            fitInfo.simulationFile = ...
                ['ramp_9mmps_9mm.k']; 

            fitInfo.simulationConstantFile = ...
                [rootFolderName,filesep,releaseName,filesep,'common',...
                 filesep,'catsoleusHL2002Umat41Parameters.k']; 

            fitInfo.expTime     =expData(:,1);
            fitInfo.expForce    =expData(:,10);
            fitInfo.expLength   =expData(:,11);
        end        
    case 'umat43'
        if(flag_passiveSimulation==1)

            fitInfo.type = simulationType;

            fitInfo.simulationFolder = ...
              [rootFolderName,filesep,releaseName,filesep,modelName,...
              filesep,fitFolder,filesep,...
              'ramp_passive_9mmps_9mm'];

            fitInfo.simulationFile = ...
              ['ramp_passive_9mmps_9mm.k'];            

            fitInfo.simulationConstantFile = ...
              [rootFolderName,filesep,releaseName,filesep,'common',...
              filesep,'catsoleusHL2002Umat43Parameters.k'];      

            fitInfo.expTime     =expData(:,1);
            fitInfo.expForce    =expData(:,12);
            fitInfo.expLength   =expData(:,13);

        end
        if(flag_activeSimulation==1)

            fitInfo.simulationFolder = ...
              [rootFolderName,filesep,releaseName,filesep,modelName,...
              filesep,fitFolder,filesep,...
              'ramp_9mmps_9mm'];

            fitInfo.simulationFile = ...
              ['ramp_9mmps_9mm.k'];            

            fitInfo.simulationConstantFile = ...
              [rootFolderName,filesep,releaseName,filesep,'common',...
              filesep,'catsoleusHL2002Umat43Parameters.k'];   

            fitInfo.expTime     =expData(:,1);
            fitInfo.expForce    =expData(:,10);
            fitInfo.expLength   =expData(:,11);            

        end        
end




