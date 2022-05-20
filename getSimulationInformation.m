function [simulationType, simulationInformation]=...
    getSimulationInformation(modelName,...
            flag_enableIsometricExperiment,...
            flag_enableConcentricExperiment,...
            flag_enableQuickReleaseExperiment,...
            flag_enableEccentricExperiment,...
            flag_enableImpedanceExperiment,...
            flag_enableForceLengthExperiment)

numberOfSimulationTypes = flag_enableIsometricExperiment ...
                     +flag_enableConcentricExperiment ... 
                     +flag_enableQuickReleaseExperiment...
                     +flag_enableEccentricExperiment...
                     +flag_enableImpedanceExperiment...
                     +flag_enableForceLengthExperiment;

if(numberOfSimulationTypes==0)
    numberOfSimulationTypes=1;
end

simulationType(numberOfSimulationTypes) = struct('type',[]);

simulationInformation(numberOfSimulationTypes) = ...
    struct('type',[],'musclePropertyFile',[],...
          'optimalFiberLength','',...
          'maximumIsometricForce','',...
          'tendonSlackLength','',...
          'parametersInMuscleCard',0,...
          'pennationAngleDegrees',0,...
          'maximumContractionVelocity',0,...
          'model',[]);
idx=0;

%% umat41 
%% Kleinbach et al.

%umat41 has no pennation model: the pennation angle is zero.
if(strcmp(modelName,'umat41')==1)

    if(flag_enableIsometricExperiment==1)
      idx=idx+1;
      simulationType(idx).type = 'isometric';
      simulationInformation(idx).type               = simulationType(idx).type;

      simulationInformation(idx).musclePropertyFile = 'matpiglet.k';
      simulationInformation(idx).optimalFiberLength     = 'lCEopt';
      simulationInformation(idx).maximumIsometricForce  = 'Fmax';
      simulationInformation(idx).tendonSlackLength      = 'lSEE0';
      simulationInformation(idx).parametersInMuscleCard = 1;
      simulationInformation(idx).model = modelName;

    end
    
    if(flag_enableConcentricExperiment==1)
      idx=idx+1;
      simulationType(idx).type = 'concentric';
      simulationInformation(idx).type               = simulationType(idx).type;

      simulationInformation(idx).type               = simulationInformation(idx).type;
      simulationInformation(idx).musclePropertyFile = 'matpiglet.k';
      simulationInformation(idx).optimalFiberLength     = 'lCEopt';
      simulationInformation(idx).maximumIsometricForce  = 'Fmax';
      simulationInformation(idx).tendonSlackLength      = 'lSEE0';
      simulationInformation(idx).parametersInMuscleCard = 1;
      simulationInformation(idx).model = modelName;  


    end 

    if(flag_enableQuickReleaseExperiment==1)
      idx=idx+1;
      simulationType(idx).type = 'quickrelease';
      simulationInformation(idx).type               = simulationType(idx).type;

      simulationInformation(idx).type               = 'quickrelease';
      simulationInformation(idx).musclePropertyFile = 'matpiglet.k';
      simulationInformation(idx).optimalFiberLength     = 'lCEopt';
      simulationInformation(idx).maximumIsometricForce  = 'Fmax';
      simulationInformation(idx).tendonSlackLength      = 'lSEE0';
      simulationInformation(idx).parametersInMuscleCard = 1;
      simulationInformation(idx).model = modelName;  
    end 

    if(flag_enableEccentricExperiment==1)
      idx=idx+1;
      simulationType(idx).type = 'eccentric';
      simulationInformation(idx).type               = simulationType(idx).type;

      simulationInformation(idx).type                   = 'eccentric';
      simulationInformation(idx).musclePropertyFile     = 'eccentric.k';
      simulationInformation(idx).optimalFiberLength     = 'lopt';
      simulationInformation(idx).maximumIsometricForce  = 'fiso';
      simulationInformation(idx).tendonSlackLength      = 'ltslk';
      simulationInformation(idx).parametersInMuscleCard = 0;
      simulationInformation(idx).model = modelName;  

    end 

    if(flag_enableImpedanceExperiment==1)
      idx=idx+1;
      simulationType(idx).type = 'impedance';
      simulationInformation(idx).type               = simulationType(idx).type;

      simulationInformation(idx).type                   = 'impedance';
      simulationInformation(idx).musclePropertyFile     = 'impedance.k';
      simulationInformation(idx).optimalFiberLength     = 'lopt';
      simulationInformation(idx).maximumIsometricForce  = 'fiso';
      simulationInformation(idx).tendonSlackLength      = 'ltslk';
      simulationInformation(idx).pennationAngleDegrees  = 'alphaDeg';
      simulationInformation(idx).parametersInMuscleCard = 0;
      simulationInformation(idx).model = modelName;  

    end

    
end
  

%% umat43 
%% Kleinbach et al.

if(strcmp(modelName,'umat43')==1)

    if(flag_enableIsometricExperiment==1)
      idx=idx+1;
      simulationType(idx).type = 'isometric';
      simulationInformation(idx).type               = simulationType(idx).type;
      simulationInformation(idx).musclePropertyFile = 'matpiglet.k';
      simulationInformation(idx).optimalFiberLength     = 'lceOpt';
      simulationInformation(idx).maximumIsometricForce  = 'fceOptIso';
      simulationInformation(idx).tendonSlackLength      = 'ltSlk';
      simulationInformation(idx).pennationAngleDegrees  = 'alphaOptD';
      simulationInformation(idx).parametersInMuscleCard = 1;
      simulationInformation(idx).model = modelName;

    end

    if(flag_enableConcentricExperiment==1)
      idx=idx+1;
      simulationType(idx).type = 'concentric';
      simulationInformation(idx).type               = simulationType(idx).type;
      simulationInformation(idx).musclePropertyFile = 'matpiglet.k';
      simulationInformation(idx).optimalFiberLength     = 'lceOpt';
      simulationInformation(idx).maximumIsometricForce  = 'fceOptIso';
      simulationInformation(idx).tendonSlackLength      = 'ltSlk';
      simulationInformation(idx).pennationAngleDegrees  = 'alphaOptD';
      simulationInformation(idx).parametersInMuscleCard = 1;
      simulationInformation(idx).model = modelName;  


    end 

    if(flag_enableQuickReleaseExperiment==1)
      idx=idx+1;
      simulationType(idx).type = 'quickrelease';
      simulationInformation(idx).type               = simulationType(idx).type;
      simulationInformation(idx).musclePropertyFile = 'matpiglet.k';
      simulationInformation(idx).optimalFiberLength     = 'lceOpt';
      simulationInformation(idx).maximumIsometricForce  = 'fceOptIso';
      simulationInformation(idx).tendonSlackLength      = 'ltSlk';    
      simulationInformation(idx).pennationAngleDegrees  = 'alphaOptD';
      simulationInformation(idx).parametersInMuscleCard = 1;
      simulationInformation(idx).model = modelName;  
    end 

    if(flag_enableEccentricExperiment==1)
      idx=idx+1;
      simulationType(idx).type = 'eccentric';
      simulationInformation(idx).type               = simulationType(idx).type;
      simulationInformation(idx).musclePropertyFile     = 'eccentric.k';
      simulationInformation(idx).optimalFiberLength     = 'lceOpt';
      simulationInformation(idx).maximumIsometricForce  = 'fceOpt';
      simulationInformation(idx).tendonSlackLength      = 'ltSlk';
      simulationInformation(idx).pennationAngleDegrees  = 'penOptD';
      simulationInformation(idx).maximumContractionVelocity = 'vceMax';
      simulationInformation(idx).parametersInMuscleCard = 0;
      simulationInformation(idx).model = modelName;  

    end 

    if(flag_enableImpedanceExperiment==1)
      idx=idx+1;
      simulationType(idx).type = 'impedance';
      simulationInformation(idx).type               = simulationType(idx).type;
      simulationInformation(idx).musclePropertyFile     = 'impedance.k';
      simulationInformation(idx).optimalFiberLength     = 'lceOpt';
      simulationInformation(idx).maximumIsometricForce  = 'fceOptIso';
      simulationInformation(idx).tendonSlackLength      = 'ltSlk';
      simulationInformation(idx).pennationAngleDegrees  = 'alphaOptD';
      simulationInformation(idx).parametersInMuscleCard = 1;
      simulationInformation(idx).model = modelName;  

    end
    
    
    if(flag_enableForceLengthExperiment==1)
      idx=idx+1;
      simulationType(idx).type = 'force_length';
      simulationInformation(idx).type               = simulationType(idx).type;

      simulationInformation(idx).type                   = 'force_length';
      simulationInformation(idx).musclePropertyFile     = 'force_length.k';
      simulationInformation(idx).optimalFiberLength     = 'lceOpt';
      simulationInformation(idx).maximumIsometricForce  = 'fceOpt';
      simulationInformation(idx).tendonSlackLength      = 'ltSlk';
      simulationInformation(idx).pennationAngleDegrees  = 'penOptD';
      simulationInformation(idx).maximumContractionVelocity = 'vceMax';
      simulationInformation(idx).parametersInMuscleCard = 0;
      simulationInformation(idx).model = modelName;        
    end    
end
  

  
end 