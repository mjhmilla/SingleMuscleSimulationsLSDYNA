function figH = plotImpedanceSimulationData(figH,...
                      inputFunctions,...
                      lsdynaBinout,lsdynaMuscle,d3hspFileName, ...
                      indexColumn,...
                      subPlotLayout,subPlotRows,subPlotColumns,...                      
                      simulationFile,indexSimulation, totalSimulations,... 
                      referenceDataFolder,...   
                      optimalFiberLength, maximumIsometricForce, tendonSlackLength,...
                      flag_addReferenceData,...
                      flag_addSimulationData,...
                      simulationColorA, simulationColorB, ...
                      referenceColorA, referenceColorB)

figure(figH);


%% Get the columns of musout
indexMusoutTime     = getColumnIndex('time',lsdynaMuscle.columnNames);
indexMusoutStim     = getColumnIndex('stim_tot',lsdynaMuscle.columnNames);
indexMusoutQ        = getColumnIndex('q',lsdynaMuscle.columnNames); %activation
indexMusoutFmtc     = getColumnIndex('f_mtc',lsdynaMuscle.columnNames);
indexMusoutFce      = getColumnIndex('f_ce',lsdynaMuscle.columnNames);
indexMusoutFpee     = getColumnIndex('f_pee',lsdynaMuscle.columnNames);
indexMusoutFsee     = getColumnIndex('f_see',lsdynaMuscle.columnNames);
indexMusoutFsde     = getColumnIndex('f_sde',lsdynaMuscle.columnNames);
indexMusoutLmtc     = getColumnIndex('l_mtc',lsdynaMuscle.columnNames);
indexMusoutLce      = getColumnIndex('l_ce',lsdynaMuscle.columnNames);
indexMusoutLmtcDot  = getColumnIndex('dot_l_mtc',lsdynaMuscle.columnNames);
indexMusoutLceDot   = getColumnIndex('dot_l_ce',lsdynaMuscle.columnNames);

%subplot('Position', reshape( subPlotLayout(1,indexColumn,:),1,4 ) );

% Add the reference data
%if(flag_addReferenceData==1)


%end

% Add the simulation data
if(flag_addSimulationData)
    n = (indexSimulation-1)/(totalSimulations-1);
    simulationColor = (1-n).*simulationColorA + (n).*simulationColorB;
    
    assert(length(lsdynaBinout.nodout.time) ...
         ==length(lsdynaBinout.elout.beam.time));

    nominalLength = getParameterValueFromD3HSPFile(d3hspFileName,'PATHLENO'); % by construction
    nominalForce    = lsdynaBinout.elout.beam.axial(end,1);    
    activation      = lsdynaMuscle.data(end,indexMusoutQ);

    %Extract this information from the name and the simulation files    
    
    
    dt= max(diff(lsdynaBinout.elout.beam.time));
    freqRelErr = ((1/dt)-inputFunctions.sampleFrequency)/inputFunctions.sampleFrequency;   
    assert(freqRelErr <= 1e-5);

    [success] = calcSignalGainAndPhase(...
                        lsdynaBinout.elout.beam.axial(:,1),...
                        nominalLength,...
                        nominalForce,...                        
                        activation,...
                        amplitudeMM,...
                        bandwidthHz,...
                        inputFunctions);
    %flag_frequencyAnalysisMuscleModelsPlotKD,...
    %flag_frequencyAnalysisMuscleModelsPlotAll,...
end


