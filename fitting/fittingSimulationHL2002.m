function success = fittingSimulationHL2002(typeOfFitting, modelName, ...
                    lsdynaBin,releaseName, rootFolderPath, flag_testing,...
                    maxIterations)


experimentalFittingDataFolder = ...
    fullfile(rootFolderPath,'ReferenceExperiments',...
                            'eccentric_HerzogLeonard2002');



%Get the fitting information
fittingInfo = getHL2002FittingSimulationInfo(...
                            modelName,...
                            rootFolderPath,...
                            releaseName,...
                            typeOfFitting,...
                            experimentalFittingDataFolder);
%Read in the parameters
matParams = getAllParameterFieldsAndValues(...
                fittingInfo.simulationConstantFile);

fittingInfo = getHL2002OptimizationSettings(...
                    matParams,fittingInfo,typeOfFitting);

fprintf('%s\t%s\n',fittingInfo.model,fittingInfo.optimizationVariable);

%Update the optimization parameter
matParams.(fittingInfo.optimizationVariable) = ...
    matParams.(fittingInfo.optimizationVariable);

%Set the final time
matParams.fitTimeE = fittingInfo.timeFinal;

%Write the parameter file
success = writeLSDYNAMuscleParameterFile(...
            fittingInfo.simulationConstantFile,...
            matParams,...
            '');

%Run the simulation
cd(fittingInfo.simulationFolder);

if(flag_testing==0)
    system('find . -type f -not \( -name ''*k'' -or -name ''*m'' \) -delete');
end

system([lsdynaBin,' i=',...
        fittingInfo.simulationFile]); 
cd(rootFolderPath);

%Post process
uniformModelData = getFittingSimulationData(matParams,...
                                fittingInfo,rootFolderPath);

errDiff = calcFittingSimulationError(fittingInfo,...
                    matParams,uniformModelData,typeOfFitting); 

errBest = sqrt(mean(errDiff.^2));
valBest = matParams.(fittingInfo.optimizationVariable);

fprintf('\t%1.3f\n',errBest);

delta = fittingInfo.optimizationDelta;

for i=1:1:maxIterations
    for j=1:1:2
        step = 0;
        switch j
            case 1
                step=-delta;
            case 2
                step=delta;
        end
        valTest = valBest+step;
        if(valTest < fittingInfo.optimizationBounds(1,1))
            valTest=fittingInfo.optimizationBounds(1,1);
        end
        if(valTest > fittingInfo.optimizationBounds(1,2))
            valTest=fittingInfo.optimizationBounds(1,2);
        end

        matParams.(fittingInfo.optimizationVariable) = valTest;

        success = writeLSDYNAMuscleParameterFile(...
            fittingInfo.simulationConstantFile,...
            matParams,...
            '');

        %Run the simulation
        cd(fittingInfo.simulationFolder);
        
        if(flag_testing==0)
            system('find . -type f -not \( -name ''*k'' -or -name ''*m'' \) -delete');
        end
        
        system([lsdynaBin,' i=',...
                fittingInfo.simulationFile]); 
        cd(rootFolderPath);
        
        %Post process
        uniformModelData = getFittingSimulationData(matParams,...
                                        fittingInfo,rootFolderPath);
        
        errDiff = calcFittingSimulationError(fittingInfo,...
                    matParams,uniformModelData,typeOfFitting);        
        errCurrent = sqrt(mean(errDiff.^2));

        fprintf('\t%i\t%i\t%1.3f\t%1.3f\n',...
            i,j,matParams.(fittingInfo.optimizationVariable),errBest);

        if(errCurrent < errBest)
            errBest=errCurrent;
            valBest = matParams.(fittingInfo.optimizationVariable);            
            break;
        end
    end
    delta=delta*0.5;
end

fprintf('%1.6f\t%s\t%s\n',valBest,fittingInfo.optimizationVariable,'(best)');
matParams.(fittingInfo.optimizationVariable) = valBest;




