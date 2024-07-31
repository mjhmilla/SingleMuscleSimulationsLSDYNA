%%
% SPDX-FileCopyrightText: 2024 Matthew Millard <millard.matthew@gmail.com>
%
% SPDX-License-Identifier: MIT
%%
function [figH,impedancePlotCounter]...
    = plotImpedanceSimulationData(figH,...
                      inputFunctions,...
                      lsdynaBinout,lsdynaMuscleUniform,d3hspFileName, ...
                      indexColumn,...
                      subPlotLayout,subPlotRows,subPlotColumns,...                      
                      simulationFile,indexSimulation, totalSimulations,... 
                      referenceDataFolder,...   
                      optimalFiberLength, maximumIsometricForce, tendonSlackLength,...
                      flag_addReferenceData,...
                      flag_addSimulationData,...
                      impedancePlotCounter)

figure(figH);


%% Get the columns of musout
config=getConfiguration();

assert(length(lsdynaBinout.nodout.time) ...
    ==length(lsdynaBinout.elout.beam.time));

nominalLength = getParameterValueFromD3HSPFile(d3hspFileName,'PATHLENN'); % by construction
nominalForce  = lsdynaBinout.elout.beam.axial(end,1);    
activation    = lsdynaMuscleUniform.act(end,1);



% Add the simulation data
if(flag_addSimulationData==1)
    n = (indexSimulation-1)/(totalSimulations-1);
    %simulationColor = (1-n).*simulationColorA + (n).*simulationColorB;
    


    
    dt= max(diff(lsdynaBinout.elout.beam.time));
    freqRelErr = ((1/dt)-inputFunctions.sampleFrequency)/inputFunctions.sampleFrequency;   
    assert(freqRelErr <= 1e-5);


    referenceForce = 5;
    forceError = abs(referenceForce-nominalForce)/referenceForce;
        
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
                                inputFunctions);
            

            figH = plotFrequencyResponse(...
                                  figH,...
                                  config,...
                                  inputFunctions,...                                           
                                  freqSimData,... 
                                  nominalForce,...
                                  indexColumn,...
                                  subPlotLayout,...
                                  referenceDataFolder,...
                                  0,...
                                  flag_addSimulationData); 
        end


    end
    if(config.bandwidthHz == 35 && config.amplitudeMM == 0.8)

        
        
        if( nominalForce <= 12)    
          freqSimData = calcSignalGainAndPhase(...
                                lsdynaBinout.elout.beam.axial(2:end,1),...
                                nominalLength,...
                                nominalForce,...                        
                                activation,...
                                config.amplitudeMM,...
                                config.bandwidthHz,...
                                inputFunctions);
                        
          flag_addStiffnessDampingReferenceData=0;
          flag_atTargetNominalForce = 0;
          
          if(impedancePlotCounter==1)
             flag_addStiffnessDampingReferenceData=1; 
          end
          
          if(forceError < 0.1)
             flag_atTargetNominalForce=1; 
          end
          
          figH = plotStiffnessDamping(...
                      figH,...
                      config,...
                      inputFunctions,...                      
                      freqSimData,...
                      nominalForce,...
                      indexColumn,...
                      subPlotLayout,...
                      referenceDataFolder,...
                      flag_atTargetNominalForce,...
                      flag_addStiffnessDampingReferenceData,...
                      flag_addSimulationData);
          impedancePlotCounter=impedancePlotCounter+1;
          
        end

    end

    %flag_frequencyAnalysisMuscleModelsPlotKD,...
    %flag_frequencyAnalysisMuscleModelsPlotAll,...
end

if(flag_addReferenceData==1)
    freqSimData = [];

    figH = plotFrequencyResponse(...
                          figH,...
                          config,...
                          inputFunctions,...                                           
                          freqSimData,... 
                          nominalForce,...
                          indexColumn,...
                          subPlotLayout,...
                          referenceDataFolder,...
                          flag_addReferenceData,...
                          0); 

                                                                  
end


