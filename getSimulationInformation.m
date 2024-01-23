function [simulationType, simulationInformation]=...
    getSimulationInformation(modelName,...
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
            flag_enableForceVelocityExperiment)

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

simulationType(numberOfSimulationTypes) = struct('type',[]);

simulationInformation(numberOfSimulationTypes) = ...
    struct('type',[],'simulationConstantFile',[],...
          'musclePropertyCard',[],...
          'optimalFiberLength','',...
          'maximumIsometricForce','',...
          'tendonSlackLength','',...
          'parametersInMuscleCard',0,...
          'pennationAngleDegrees',0,...
          'maximumContractionVelocity',0,...
          'model',[]);
idx=0;


if(strcmp(modelName,'viva')==1)

    if(flag_enableActivePassiveForceLengthExperiment==1)
      assert(0, 'Error: Experiment is not yet implemented');
    end
    if(flag_enableForceVelocityExperiment==1)
      assert(0, 'Error: Experiment is not yet implemented');
    end    

    if(flag_enableActivePassiveForceLengthExperimentViva==1)
      idx=idx+1;
      simulationType(idx).type = 'active_passive_force_length_viva';
      simulationInformation(idx).type               = simulationType(idx).type;

      simulationInformation(idx).simulationConstantFile     = 'active_passive_force_length.k';      
      simulationInformation(idx).musclePropertyCard         = 'muscle_viva50f_scm_s_clavicle_1.k';      
      simulationInformation(idx).optimalFiberLength         = 'lceOpt';
      simulationInformation(idx).maximumIsometricForce      = 'fceOpt';
      simulationInformation(idx).tendonSlackLength          = 'ltSlk';
      simulationInformation(idx).pennationAngleDegrees      = 'penOptD';
      simulationInformation(idx).maximumContractionVelocity = 'vceMax';
      simulationInformation(idx).parametersInMuscleCard     = 0;
      simulationInformation(idx).model                      = modelName;  

    end
    if(flag_enableForceVelocityExperimentViva==1)
      idx=idx+1;
      simulationType(idx).type = 'force_velocity_viva';
      simulationInformation(idx).type               = simulationType(idx).type;

      simulationInformation(idx).simulationConstantFile     = 'force_velocity.k';      
      simulationInformation(idx).musclePropertyCard         = 'muscle_viva50f_scm_s_clavicle_1.k';      
      simulationInformation(idx).optimalFiberLength         = 'lceOpt';
      simulationInformation(idx).maximumIsometricForce      = 'fceOpt';
      simulationInformation(idx).tendonSlackLength          = 'ltSlk';
      simulationInformation(idx).pennationAngleDegrees      = 'penOptD';
      simulationInformation(idx).maximumContractionVelocity = 'vceMax';
      simulationInformation(idx).parametersInMuscleCard     = 0;
      simulationInformation(idx).model                      = modelName;  

    end     
end


%% umat41 
%% Kleinbach et al.

%umat41 has no pennation model: the pennation angle is zero.
if(strcmp(modelName,'umat41')==1)

    if(flag_enableIsometricExperiment==1)
      idx=idx+1;
      simulationType(idx).type = 'isometric_Guenther2007';
      simulationInformation(idx).type               = simulationType(idx).type;

      simulationInformation(idx).simulationConstantFile = 'isometric.k';
      simulationInformation(idx).musclePropertyCard     = 'matpiglet.k';      
      simulationInformation(idx).optimalFiberLength     = 'lCEopt';
      simulationInformation(idx).maximumIsometricForce  = 'Fmax';
      simulationInformation(idx).tendonSlackLength      = 'lSEE0';
      simulationInformation(idx).parametersInMuscleCard = 1;
      simulationInformation(idx).model = modelName;

    end
    
    if(flag_enableConcentricExperiment==1)
      idx=idx+1;
      simulationType(idx).type = 'concentric_Guenther2007';
      simulationInformation(idx).type               = simulationType(idx).type;

      simulationInformation(idx).type               = simulationInformation(idx).type;

      simulationInformation(idx).simulationConstantFile = 'concentric.k';
      simulationInformation(idx).musclePropertyCard     = 'matpiglet.k';      
      simulationInformation(idx).optimalFiberLength     = 'lCEopt';
      simulationInformation(idx).maximumIsometricForce  = 'Fmax';
      simulationInformation(idx).tendonSlackLength      = 'lSEE0';
      simulationInformation(idx).parametersInMuscleCard = 1;
      simulationInformation(idx).model = modelName;  


    end 

    if(flag_enableQuickReleaseExperiment==1)
      idx=idx+1;
      simulationType(idx).type = 'quickrelease_Guenther2007';
      simulationInformation(idx).type               = simulationType(idx).type;

      simulationInformation(idx).type                   = 'quickrelease';
      simulationInformation(idx).simulationConstantFile = 'quick_release.k';
      simulationInformation(idx).musclePropertyCard     = 'matpiglet.k';      
      simulationInformation(idx).optimalFiberLength     = 'lCEopt';
      simulationInformation(idx).maximumIsometricForce  = 'Fmax';
      simulationInformation(idx).tendonSlackLength      = 'lSEE0';
      simulationInformation(idx).parametersInMuscleCard = 1;
      simulationInformation(idx).model = modelName;  
    end 

    if(flag_enableEccentricExperiment==1)
      idx=idx+1;
      simulationType(idx).type = 'eccentric_HerzogLeonard2002';
      simulationInformation(idx).type               = simulationType(idx).type;

      simulationInformation(idx).type                   = 'eccentric';
      simulationInformation(idx).musclePropertyCard     = 'catsoleus.k';
      simulationInformation(idx).simulationConstantFile = 'eccentric.k';
      simulationInformation(idx).optimalFiberLength     = 'lopt';
      simulationInformation(idx).maximumIsometricForce  = 'fiso';
      simulationInformation(idx).tendonSlackLength      = 'ltslk';
      simulationInformation(idx).pennationAngleDegrees  = 'alphaDeg';
      simulationInformation(idx).parametersInMuscleCard = 0;
      simulationInformation(idx).model = modelName;  

    end 

    if(flag_enableImpedanceExperiment==1)
      idx=idx+1;
      simulationType(idx).type = 'impedance_Kirsch1997';
      simulationInformation(idx).type               = simulationType(idx).type;

      simulationInformation(idx).type                   = 'impedance';
      simulationInformation(idx).simulationConstantFile = 'impedance.k';
      simulationInformation(idx).musclePropertyCard     = 'catsoleus.k';
      simulationInformation(idx).optimalFiberLength     = 'lopt';
      simulationInformation(idx).maximumIsometricForce  = 'fiso';
      simulationInformation(idx).tendonSlackLength      = 'ltslk';
      simulationInformation(idx).pennationAngleDegrees  = 'alphaDeg';
      simulationInformation(idx).parametersInMuscleCard = 0;
      simulationInformation(idx).model = modelName;  

    end

    if(flag_enableSinusoidExperiment==1)
        assert(0);
    end
    
    if(flag_enableReflexExperiment==1)
      idx=idx+1;
      simulationType(idx).type = 'reflex';
      simulationInformation(idx).type               = simulationType(idx).type;

      simulationInformation(idx).type                   = 'reflex';
      simulationInformation(idx).simulationConstantFile = 'reflex.k';
      simulationInformation(idx).musclePropertyCard     = 'catsoleus.k';      
      simulationInformation(idx).optimalFiberLength     = 'lopt';
      simulationInformation(idx).maximumIsometricForce  = 'fiso';
      simulationInformation(idx).tendonSlackLength      = 'ltslk';
      simulationInformation(idx).pennationAngleDegrees  = 'alphaDeg';
      simulationInformation(idx).parametersInMuscleCard = 0;
      simulationInformation(idx).model = modelName;  

    end

    if(flag_enableReflexExperiment_kN_mm_ms==1)
      idx=idx+1;
      simulationType(idx).type = 'reflex_kN_mm_ms';
      simulationInformation(idx).type               = simulationType(idx).type;

      simulationInformation(idx).type                   = 'reflex_kN_mm_ms';
      simulationInformation(idx).simulationConstantFile = 'reflex_kN_mm_ms.k';
      simulationInformation(idx).musclePropertyCard     = 'catsoleus.k';      
      simulationInformation(idx).optimalFiberLength     = 'lopt';
      simulationInformation(idx).maximumIsometricForce  = 'fiso';
      simulationInformation(idx).tendonSlackLength      = 'ltslk';
      simulationInformation(idx).pennationAngleDegrees  = 'alphaDeg';
      simulationInformation(idx).parametersInMuscleCard = 0;
      simulationInformation(idx).model = modelName;  

    end

    if(flag_enableActivePassiveForceLengthExperimentViva==1)
      idx=idx+1;
      simulationType(idx).type = 'active_passive_force_length_viva';
      simulationInformation(idx).type               = simulationType(idx).type;

      simulationInformation(idx).simulationConstantFile     = 'active_passive_force_length.k';      
      simulationInformation(idx).musclePropertyCard         = 'muscle_viva50f_scm_s_clavicle_1.k';      
      simulationInformation(idx).optimalFiberLength         = 'lceOpt';
      simulationInformation(idx).maximumIsometricForce      = 'fceOpt';
      simulationInformation(idx).tendonSlackLength          = 'ltSlk';
      simulationInformation(idx).pennationAngleDegrees      = 'penOptD';
      simulationInformation(idx).maximumContractionVelocity = 'vceMax';
      simulationInformation(idx).parametersInMuscleCard     = 0;
      simulationInformation(idx).model                      = modelName;  

    end 

    if(flag_enableForceVelocityExperimentViva==1)
      idx=idx+1;
      simulationType(idx).type = 'force_velocity_viva';
      simulationInformation(idx).type               = simulationType(idx).type;

      simulationInformation(idx).simulationConstantFile     = 'force_velocity.k';      
      simulationInformation(idx).musclePropertyCard         = 'muscle_viva50f_scm_s_clavicle_1.k';      
      simulationInformation(idx).optimalFiberLength         = 'lceOpt';
      simulationInformation(idx).maximumIsometricForce      = 'fceOpt';
      simulationInformation(idx).tendonSlackLength          = 'ltSlk';
      simulationInformation(idx).pennationAngleDegrees      = 'penOptD';
      simulationInformation(idx).maximumContractionVelocity = 'vceMax';
      simulationInformation(idx).parametersInMuscleCard     = 0;
      simulationInformation(idx).model                      = modelName;  

    end       

    if(flag_enableActivePassiveForceLengthExperiment==1)
      idx=idx+1;
      simulationType(idx).type = 'active_passive_force_length';
      simulationInformation(idx).type               = simulationType(idx).type;

      simulationInformation(idx).simulationConstantFile     = 'active_passive_force_length.k';      
      simulationInformation(idx).musclePropertyCard         = 'muscle_generic.k';      
      simulationInformation(idx).optimalFiberLength         = 'lceOpt';
      simulationInformation(idx).maximumIsometricForce      = 'fceOpt';
      simulationInformation(idx).tendonSlackLength          = 'ltSlk';
      simulationInformation(idx).pennationAngleDegrees      = 'penOptD';
      simulationInformation(idx).maximumContractionVelocity = 'vceMax';
      simulationInformation(idx).parametersInMuscleCard     = 0;
      simulationInformation(idx).model                      = modelName;  

    end 

    if(flag_enableForceVelocityExperiment==1)
      idx=idx+1;
      simulationType(idx).type = 'force_velocity';
      simulationInformation(idx).type               = simulationType(idx).type;

      simulationInformation(idx).simulationConstantFile     = 'force_velocity.k';      
      simulationInformation(idx).musclePropertyCard         = 'muscle_generic.k';      
      simulationInformation(idx).optimalFiberLength         = 'lceOpt';
      simulationInformation(idx).maximumIsometricForce      = 'fceOpt';
      simulationInformation(idx).tendonSlackLength          = 'ltSlk';
      simulationInformation(idx).pennationAngleDegrees      = 'penOptD';
      simulationInformation(idx).maximumContractionVelocity = 'vceMax';
      simulationInformation(idx).parametersInMuscleCard     = 0;
      simulationInformation(idx).model                      = modelName;  

    end       

end
  

%% umat43 
%% Proposed model

if(strcmp(modelName,'umat43')==1)

    if(flag_enableIsometricExperiment==1)
      idx=idx+1;
      simulationType(idx).type = 'isometric_Guenther2007';
      simulationInformation(idx).type               = simulationType(idx).type;
      simulationInformation(idx).simulationConstantFile = 'isometric.k';
      simulationInformation(idx).musclePropertyCard     = 'matpiglet.k';
      simulationInformation(idx).optimalFiberLength     = 'lceOpt';
      simulationInformation(idx).maximumIsometricForce  = 'fceOptIso';
      simulationInformation(idx).tendonSlackLength      = 'ltSlk';
      simulationInformation(idx).pennationAngleDegrees  = 'alphaOptD';
      simulationInformation(idx).parametersInMuscleCard = 1;
      simulationInformation(idx).model = modelName;

    end

    if(flag_enableConcentricExperiment==1)
      idx=idx+1;
      simulationType(idx).type = 'concentric_Guenther2007';
      simulationInformation(idx).type               = simulationType(idx).type;
      simulationInformation(idx).simulationConstantFile = 'concentric.k';
      simulationInformation(idx).musclePropertyCard     = 'matpiglet.k';      
      simulationInformation(idx).optimalFiberLength     = 'lceOpt';
      simulationInformation(idx).maximumIsometricForce  = 'fceOptIso';
      simulationInformation(idx).tendonSlackLength      = 'ltSlk';
      simulationInformation(idx).pennationAngleDegrees  = 'alphaOptD';
      simulationInformation(idx).parametersInMuscleCard = 1;
      simulationInformation(idx).model = modelName;  


    end 

    if(flag_enableQuickReleaseExperiment==1)
      idx=idx+1;
      simulationType(idx).type = 'quickrelease_Guenther2007';
      simulationInformation(idx).type               = simulationType(idx).type;
      simulationInformation(idx).simulationConstantFile = 'quick_release.k';      
      simulationInformation(idx).musclePropertyCard     = 'matpiglet.k';
      simulationInformation(idx).optimalFiberLength     = 'lceOpt';
      simulationInformation(idx).maximumIsometricForce  = 'fceOptIso';
      simulationInformation(idx).tendonSlackLength      = 'ltSlk';    
      simulationInformation(idx).pennationAngleDegrees  = 'alphaOptD';
      simulationInformation(idx).parametersInMuscleCard = 1;
      simulationInformation(idx).model = modelName;  
    end 

    if(flag_enableEccentricExperiment==1)
      idx=idx+1;
      simulationType(idx).type = 'eccentric_HerzogLeonard2002';
      simulationInformation(idx).type               = simulationType(idx).type;

      simulationInformation(idx).simulationConstantFile = 'eccentric.k';      
      simulationInformation(idx).musclePropertyCard     = 'catsoleus.k';      
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
      simulationType(idx).type = 'impedance_Kirsch1997';
      simulationInformation(idx).type               = simulationType(idx).type;
      simulationInformation(idx).simulationConstantFile = 'impedance.k';  
      simulationInformation(idx).musclePropertyCard     = 'catsoleus.k';      
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
      simulationInformation(idx).simulationConstantFile = 'force_length.k';  
      simulationInformation(idx).musclePropertyCard     = 'matpiglet.k';            
      simulationInformation(idx).optimalFiberLength     = 'lceOpt';
      simulationInformation(idx).maximumIsometricForce  = 'fceOpt';
      simulationInformation(idx).tendonSlackLength      = 'ltSlk';
      simulationInformation(idx).pennationAngleDegrees  = 'penOptD';
      simulationInformation(idx).maximumContractionVelocity = 'vceMax';
      simulationInformation(idx).parametersInMuscleCard = 0;
      simulationInformation(idx).model = modelName;        
    end    
    
    if(flag_enableSinusoidExperiment==1)
      idx=idx+1;
      simulationType(idx).type = 'sinusoid';
      simulationInformation(idx).type               = simulationType(idx).type;

      simulationInformation(idx).type                   = 'sinusoid';
      simulationInformation(idx).simulationConstantFile = 'sinusoid.k';
      simulationInformation(idx).musclePropertyCard     = 'catsoleus.k';
      simulationInformation(idx).optimalFiberLength     = 'lceOpt';
      simulationInformation(idx).maximumIsometricForce  = 'fceOpt';
      simulationInformation(idx).tendonSlackLength      = 'ltSlk';
      simulationInformation(idx).pennationAngleDegrees  = 'penOptD';
      simulationInformation(idx).maximumContractionVelocity = 'vceMax';
      simulationInformation(idx).parametersInMuscleCard = 0;
      simulationInformation(idx).model = modelName; 
    end
    
    if(flag_enableReflexExperiment==1)
      idx=idx+1;
      simulationType(idx).type = 'reflex';
      simulationInformation(idx).type               = simulationType(idx).type;

      simulationInformation(idx).type                   = 'reflex';
      simulationInformation(idx).simulationConstantFile = 'reflex.k';
      simulationInformation(idx).musclePropertyCard     = 'catsoleus.k';
      simulationInformation(idx).optimalFiberLength     = 'lceOpt';
      simulationInformation(idx).maximumIsometricForce  = 'fceOpt';
      simulationInformation(idx).tendonSlackLength      = 'ltSlk';
      simulationInformation(idx).pennationAngleDegrees  = 'penOptD';
      simulationInformation(idx).parametersInMuscleCard = 0;
      simulationInformation(idx).model = modelName;  

    end

    if(flag_enableReflexExperiment_kN_mm_ms==1)
      idx=idx+1;
      simulationType(idx).type                          = 'reflex_kN_mm_ms';
      simulationInformation(idx).type                   = simulationType(idx).type;

      simulationInformation(idx).type                   = 'reflex_kN_mm_ms';
      simulationInformation(idx).simulationConstantFile = 'reflex_kN_mm_ms.k';
      simulationInformation(idx).musclePropertyCard     = 'catsoleus.k';
      simulationInformation(idx).optimalFiberLength     = 'lceOpt';
      simulationInformation(idx).maximumIsometricForce  = 'fceOpt';
      simulationInformation(idx).tendonSlackLength      = 'ltSlk';
      simulationInformation(idx).pennationAngleDegrees  = 'penOptD';
      simulationInformation(idx).parametersInMuscleCard = 0;
      simulationInformation(idx).model = modelName;  

    end

    if(flag_enableActivePassiveForceLengthExperimentViva==1)
      idx=idx+1;
      simulationType(idx).type = 'active_passive_force_length_viva';
      simulationInformation(idx).type               = simulationType(idx).type;

      simulationInformation(idx).simulationConstantFile     = 'active_passive_force_length.k';      
      simulationInformation(idx).musclePropertyCard         = 'muscle_viva50f_scm_s_clavicle_1.k';      
      simulationInformation(idx).optimalFiberLength         = 'lceOpt';
      simulationInformation(idx).maximumIsometricForce      = 'fceOpt';
      simulationInformation(idx).tendonSlackLength          = 'ltSlk';
      simulationInformation(idx).pennationAngleDegrees      = 'penOptD';
      simulationInformation(idx).maximumContractionVelocity = 'vceMax';
      simulationInformation(idx).parametersInMuscleCard     = 0;
      simulationInformation(idx).model                      = modelName;  

    end

    if(flag_enableForceVelocityExperimentViva==1)
      idx=idx+1;
      simulationType(idx).type = 'force_velocity_viva';
      simulationInformation(idx).type               = simulationType(idx).type;

      simulationInformation(idx).simulationConstantFile     = 'force_velocity.k';      
      simulationInformation(idx).musclePropertyCard         = 'muscle_viva50f_scm_s_clavicle_1.k';      
      simulationInformation(idx).optimalFiberLength         = 'lceOpt';
      simulationInformation(idx).maximumIsometricForce      = 'fceOpt';
      simulationInformation(idx).tendonSlackLength          = 'ltSlk';
      simulationInformation(idx).pennationAngleDegrees      = 'penOptD';
      simulationInformation(idx).maximumContractionVelocity = 'vceMax';
      simulationInformation(idx).parametersInMuscleCard     = 0;
      simulationInformation(idx).model                      = modelName;  
    end

    if(flag_enableActivePassiveForceLengthExperiment==1)
      idx=idx+1;
      simulationType(idx).type = 'active_passive_force_length';
      simulationInformation(idx).type               = simulationType(idx).type;

      simulationInformation(idx).simulationConstantFile     = 'active_passive_force_length.k';      
      simulationInformation(idx).musclePropertyCard         = 'muscle_generic.k';      
      simulationInformation(idx).optimalFiberLength         = 'lceOpt';
      simulationInformation(idx).maximumIsometricForce      = 'fceOpt';
      simulationInformation(idx).tendonSlackLength          = 'ltSlk';
      simulationInformation(idx).pennationAngleDegrees      = 'penOptD';
      simulationInformation(idx).maximumContractionVelocity = 'vceMax';
      simulationInformation(idx).parametersInMuscleCard     = 0;
      simulationInformation(idx).model                      = modelName;  

    end

    if(flag_enableForceVelocityExperiment==1)
      idx=idx+1;
      simulationType(idx).type = 'force_velocity';
      simulationInformation(idx).type               = simulationType(idx).type;

      simulationInformation(idx).simulationConstantFile     = 'force_velocity.k';      
      simulationInformation(idx).musclePropertyCard         = 'muscle_generic.k';      
      simulationInformation(idx).optimalFiberLength         = 'lceOpt';
      simulationInformation(idx).maximumIsometricForce      = 'fceOpt';
      simulationInformation(idx).tendonSlackLength          = 'ltSlk';
      simulationInformation(idx).pennationAngleDegrees      = 'penOptD';
      simulationInformation(idx).maximumContractionVelocity = 'vceMax';
      simulationInformation(idx).parametersInMuscleCard     = 0;
      simulationInformation(idx).model                      = modelName;  
    end 
end
  

%% mat56
%% LS-DYNA's built in Hill-type muscle model

if(strcmp(modelName,'mat156')==1)

    if(flag_enableIsometricExperiment==1)
      assert(0, 'Error: Experiment is not yet implemented');
    end

    if(flag_enableConcentricExperiment==1)
      assert(0, 'Error: Experiment is not yet implemented');      
    end 

    if(flag_enableQuickReleaseExperiment==1)
      assert(0, 'Error: Experiment is not yet implemented');
    end 

    if(flag_enableEccentricExperiment==1)
      idx=idx+1;
      simulationType(idx).type = 'eccentric_HerzogLeonard2002';
      simulationInformation(idx).type                   = simulationType(idx).type;

      simulationInformation(idx).simulationConstantFile = 'eccentric.k';      
      simulationInformation(idx).musclePropertyCard     = 'catsoleusMat156.k';      
      simulationInformation(idx).optimalFiberLength     = 'lceOptAT';
      simulationInformation(idx).maximumIsometricForce  = 'fceOptAT';
      simulationInformation(idx).tendonSlackLength      = 'ltSlk';
      simulationInformation(idx).pennationAngleDegrees  = 'penOptD';
      simulationInformation(idx).maximumContractionVelocity = 'vceMax';
      simulationInformation(idx).parametersInMuscleCard = 0;
      simulationInformation(idx).model = modelName;  

    end 

    if(flag_enableActivePassiveForceLengthExperiment==1)
      idx=idx+1;
      simulationType(idx).type = 'active_passive_force_length';
      simulationInformation(idx).type               = simulationType(idx).type;

      simulationInformation(idx).simulationConstantFile     = 'active_passive_force_length.k';      
      simulationInformation(idx).musclePropertyCard         = 'catsoleusMat156.k';      
      simulationInformation(idx).optimalFiberLength         = 'lmtOptAT';
      simulationInformation(idx).maximumIsometricForce      = 'fceOptAT';
      simulationInformation(idx).tendonSlackLength          = 'ltSlk';
      simulationInformation(idx).pennationAngleDegrees      = 'penOptD';
      simulationInformation(idx).maximumContractionVelocity = 'vceMax';
      simulationInformation(idx).parametersInMuscleCard     = 0;
      simulationInformation(idx).model                      = modelName;  

    end
    if(flag_enableForceVelocityExperiment==1)
      idx=idx+1;
      simulationType(idx).type = 'force_velocity';
      simulationInformation(idx).type               = simulationType(idx).type;

      simulationInformation(idx).simulationConstantFile     = 'force_velocity.k';      
      simulationInformation(idx).musclePropertyCard         = 'catsoleusMat156.k';      
      simulationInformation(idx).optimalFiberLength         = 'lmtOptAT';
      simulationInformation(idx).maximumIsometricForce      = 'fceOptAT';
      simulationInformation(idx).tendonSlackLength          = 'ltSlk';
      simulationInformation(idx).pennationAngleDegrees      = 'penOptD';
      simulationInformation(idx).maximumContractionVelocity = 'vceMax';
      simulationInformation(idx).parametersInMuscleCard     = 0;
      simulationInformation(idx).model                      = modelName;  

    end   

    if(flag_enableImpedanceExperiment==1)
      assert(0, 'Error: Experiment is not yet implemented');
    end
    
    
    if(flag_enableForceLengthExperiment==1)
      assert(0, 'Error: Experiment is not yet implemented');    
    end    
    
    if(flag_enableSinusoidExperiment==1)
      assert(0, 'Error: Experiment is not yet implemented');
    end
    
    if(flag_enableReflexExperiment==1)
      assert(0, 'Error: Experiment is not yet implemented');
    end

    if(flag_enableReflexExperiment_kN_mm_ms==1)
      assert(0, 'Error: Experiment is not yet implemented');
    end
end


  
end 