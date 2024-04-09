function [figH] = ...
    plotImpedanceSimulationDataForPublication(figH,...
                      inputFunctions,...
                      lsdynaBinout,lsdynaMuscleUniform,d3hspFileName, ...
                      indexModel,subPlotLayout,subPlotRows,subPlotColumns,...                      
                      simulationDirectoryName,indexSimulation, totalSimulations,... 
                      referenceDataFolder,...                       
                      referenceCurveFolder,...
                      muscleArchitecture,...
                      flag_addReferenceData,...
                      flag_addSimulationData,...
                      lineColorA, lineColorB, ...
                      referenceColorA, referenceColorB)

figure(figH);
disp(simulationDirectoryName);
stiffnessDampingHandleVisibility='off';
firstStiffnessDampingFile=0;
lastStiffnessDampingFile=0;
switch lsdynaMuscleUniform.nameLabel
    case 'MAT156' 
        if(contains(simulationDirectoryName,'impedance_0p528stim_0p8mm_35Hz'))
            stiffnessDampingHandleVisibility='on';
        end
        if(contains(simulationDirectoryName,'impedance_0p019stim_0p8mm_35Hz'))
            firstStiffnessDampingFile=1;
        end
        if(contains(simulationDirectoryName,'impedance_0p528stim_0p8mm_35Hz'))
            lastStiffnessDampingFile=1;
        end        
    case 'EHTMM'
        if(contains(simulationDirectoryName,'impedance_0p319stim_0p8mm_35Hz'))
            stiffnessDampingHandleVisibility='on';
        end
        if(contains(simulationDirectoryName,'impedance_0p027stim_0p8mm_35Hz'))
            firstStiffnessDampingFile=1;
        end
        if(contains(simulationDirectoryName,'impedance_0p319stim_0p8mm_35Hz'))
            lastStiffnessDampingFile=1;
        end

    case 'VEXAT'
        if(contains(simulationDirectoryName,'impedance_0p532stim_0p8mm_35Hz'))
            stiffnessDampingHandleVisibility='on';
        end
        if(contains(simulationDirectoryName,'impedance_0p019stim_0p8mm_35Hz'))
            firstStiffnessDampingFile=1;
        end
        if(contains(simulationDirectoryName,'impedance_0p532stim_0p8mm_35Hz'))
            lastStiffnessDampingFile=1;
        end        

end

minimumFrequency        = 4;
coherenceSqThreshold    = 0.5;

%% Get the columns of musout
config=getConfiguration();



nominalLength = getParameterValueFromD3HSPFile(d3hspFileName,'PATHLENN'); % by construction
nominalForce  = lsdynaBinout.elout.beam.axial(end,1);    
activation    = lsdynaMuscleUniform.act(end,1);

if(flag_addReferenceData==1)
    freqSimData = [];
    


    for i=1:1:subPlotColumns
        figH = plotFrequencyResponsePublication(...
                  figH,...
                  config,...
                  inputFunctions,...                                           
                  freqSimData,... 
                  nominalForce,...
                  coherenceSqThreshold,...
                  i,...
                  subPlotLayout,...
                  referenceDataFolder,...
                  flag_addReferenceData,...
                  0,...
                  lineColorA, lineColorB, ...
                  referenceColorA, referenceColorB,...
                  lsdynaMuscleUniform.nameLabel); 

        if(i <= 3)
          figH = plotStiffnessDampingPublication(...
                      figH,...
                      config,...
                      inputFunctions,...                      
                      freqSimData,...
                      nominalForce,...
                      i,...
                      subPlotLayout,...
                      referenceDataFolder,...
                      0,...
                      flag_addReferenceData,...
                      0,...
                      lineColorA, lineColorB, ...
                      referenceColorA, referenceColorB,...
                      lsdynaMuscleUniform.nameLabel,...
                      stiffnessDampingHandleVisibility,...
                      firstStiffnessDampingFile,...
                      lastStiffnessDampingFile);   
        end

    end

                                                                  
end


% Add the simulation data
if(flag_addSimulationData==1)
    n = (indexSimulation-1)/(totalSimulations-1);
    %simulationColor = (1-n).*simulationColorA + (n).*simulationColorB;
    


    dt= max(diff(lsdynaBinout.elout.beam.time));
    freqRelErr = ((1/dt)-inputFunctions.sampleFrequency)/inputFunctions.sampleFrequency;   
    assert(freqRelErr <= 1e-5);


    referenceForce = 5;
    forceError = abs(referenceForce-nominalForce)/referenceForce;

    indexColumn=indexModel;
    if((config.bandwidthHz == 90 && config.amplitudeMM == 1.6))
        indexColumn=indexColumn+3;
    end    

    if( (config.bandwidthHz == 90 && config.amplitudeMM == 1.6) ...
         || (config.bandwidthHz == 15 && config.amplitudeMM == 1.6) )
        
        if( forceError < 0.1)
            freqSimData = calcSignalGainAndPhase(...
                                lsdynaBinout.elout.beam.axial(2:end,1),...
                                nominalLength,...
                                nominalForce,...                        
                                activation,...
                                config.amplitudeMM,...
                                config.bandwidthHz,...
                                inputFunctions,...
                                minimumFrequency,...
                                coherenceSqThreshold);
            

            figH = plotFrequencyResponsePublication(...
                                  figH,...
                                  config,...
                                  inputFunctions,...                                           
                                  freqSimData,... 
                                  nominalForce,...
                                  coherenceSqThreshold,...
                                  indexColumn,...
                                  subPlotLayout,...
                                  referenceDataFolder,...
                                  0,...
                                  flag_addSimulationData,...
                                  lineColorA, lineColorB, ...
                                  referenceColorA, referenceColorB,...
                                  lsdynaMuscleUniform.nameLabel); 
        end


    end
    if(config.bandwidthHz == 35 && config.amplitudeMM == 0.8)
               
          freqSimData = calcSignalGainAndPhase(...
                                lsdynaBinout.elout.beam.axial(2:end,1),...
                                nominalLength,...
                                nominalForce,...                        
                                activation,...
                                config.amplitudeMM,...
                                config.bandwidthHz,...
                                inputFunctions,...
                                minimumFrequency,...
                                coherenceSqThreshold);
                        
          flag_addStiffnessDampingReferenceData=0;
          flag_atTargetNominalForce = 0;
          

          
          if(forceError < 0.1)
             flag_atTargetNominalForce=1; 
          end
          

          figH = plotStiffnessDampingPublication(...
                      figH,...
                      config,...
                      inputFunctions,...                      
                      freqSimData,...
                      nominalForce,...
                      indexModel,...
                      subPlotLayout,...
                      referenceDataFolder,...
                      flag_atTargetNominalForce,...
                      flag_addStiffnessDampingReferenceData,...
                      flag_addSimulationData,...
                      lineColorA, lineColorB, ...
                      referenceColorA, referenceColorB,...
                      lsdynaMuscleUniform.nameLabel,...
                      stiffnessDampingHandleVisibility,...
                      firstStiffnessDampingFile,...
                      lastStiffnessDampingFile);
         
    end

    %flag_frequencyAnalysisMuscleModelsPlotKD,...
    %flag_frequencyAnalysisMuscleModelsPlotAll,...
end


