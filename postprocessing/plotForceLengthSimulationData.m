function figH = plotForceLengthSimulationData(figH, curveData, indexColumn,...
                      subPlotLayout,subPlotRows,subPlotColumns,...                      
                      simulationFile,indexSimulation, totalSimulations,... 
                      referenceDataFolder,...                      
                      flag_addReferenceData,...
                      flag_addSimulationData,...
                      simulationColorA, simulationColorB, ...
                      referenceColorA, referenceColorB)

figure(figH);



% Add the reference data
if(flag_addReferenceData==1)


    files = dir(referenceDataFolder);
    for indexFiles=3:1:length(files)
        if( contains( files(indexFiles).name, 'feline_activeForceLength'))
            data = csvread([referenceDataFolder,'/',files(indexFiles).name],1,0);
            subplot('Position', reshape( subPlotLayout(1,1,:),1,4 ) );
            plot(   data(:,1),...
                    data(:,2),...
                    'LineWidth',3,...
                    'Color',referenceColorB);
            hold on;
            plot(   [0.,0.15],...
                    [1,1],...
                    'LineWidth',3,...
                    'Color',referenceColorB);
            hold on;
            text(0.2,1,'Matlab');
            hold on;
            box off;        
            xlabel('Norm. Length ($\ell^{\mathrm{M}}/\ell^{\mathrm{M}}_{\circ}$)');
            ylabel( 'Norm. Force ($f^{\mathrm{M}}/f^{\mathrm{M}}_{\circ}$)');
            title('Active-Force Length')
    
            subplot('Position', reshape( subPlotLayout(1,2,:),1,4 ) );
            plot(   data(:,1),...
                    data(:,3),...
                    'LineWidth',3,...
                    'Color',referenceColorB);
            hold on;
            box off;        
            xlabel('Norm. Length ($\ell^{\mathrm{M}}/\ell^{\mathrm{M}}_{\circ}$)');
            ylabel( '$d f^{\mathrm{M}} /d  \ell^{\mathrm{M}}$');
            title('Active-Force Length: $1^{st}$ Der');
    
            subplot('Position', reshape( subPlotLayout(1,3,:),1,4 ) );
            plot(   data(:,1),...
                    data(:,4),...
                    'LineWidth',3,...
                    'Color',referenceColorB);
            hold on;
            box off;        
            xlabel('Norm. Length ($\ell^{\mathrm{M}}/\ell^{\mathrm{M}}_{\circ}$)');
            ylabel( '$d^2 (f^{\mathrm{M}}) / d (\ell^{\mathrm{M}})^2$');
            title('Active-Force Length: $2^{nd}$ Der');            
        end
    end


end

% Add the simulation data
if(flag_addSimulationData)
    n = (indexSimulation-1)/(totalSimulations-1);
    simulationColor = (1-n).*simulationColorA + (n).*simulationColorB;

    if(contains(curveData.name,'fal')==1)
        subplot('Position', reshape( subPlotLayout(1,1,:),1,4 ) );
        plot(   curveData.data(:,curveData.indexArg),...
                curveData.data(:,curveData.indexValue),...
                'Color',simulationColor);
        hold on;  
        plot(   [0.,0.15],...
                [1,1].*(1-0.05*indexSimulation),...
                'Color',simulationColor );
        hold on;
        text( 0.2, 1-0.05*indexSimulation,'Fortran');
        hold on;

        subplot('Position', reshape( subPlotLayout(1,2,:),1,4 ) );
        plot(   curveData.data(:,curveData.indexArg),...
                curveData.data(:,curveData.index1stDer),...
                'Color',simulationColor)
        hold on;
        box off;        

        subplot('Position', reshape( subPlotLayout(1,3,:),1,4 ) );
        plot(   curveData.data(:,curveData.indexArg),...
                curveData.data(:,curveData.index2ndDer),...
                'Color',simulationColor)
        hold on;
        box off;        
    end

 
end


