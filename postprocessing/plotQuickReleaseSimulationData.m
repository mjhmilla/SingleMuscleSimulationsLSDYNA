function figH = plotQuickReleaseSimulationData(figH,lsdynaBinout,lsdynaMuscleUniform, ...
                      indexColumn,...
                      subPlotLayout,subPlotRows,subPlotColumns,...                      
                      simulationFile,indexSimulation, totalSimulations,... 
                      referenceDataFolder,...                      
                      flag_addReferenceData,...
                      flag_addSimulationData,...
                      simulationColorA, simulationColorB, ...
                      referenceColorA, referenceColorB)

figure(figH);

subplot('Position', reshape( subPlotLayout(1,indexColumn,:),1,4 ) );

% Add the reference data
if(flag_addReferenceData==1)

    %Load the reference data
    referenceFiles = dir(fullfile(referenceDataFolder,'*.dat'));
    referenceData=[];
    if(isempty(referenceFiles)==0)                
        for indexReferenceFile=1:1:length(referenceFiles)
            referenceData=[referenceData,...
            importdata(fullfile(referenceFiles(indexReferenceFile).folder,...
                                referenceFiles(indexReferenceFile).name))];
            here=1;
        end
    end     

    for indexReference = 1:1:length(referenceData)
        n = (indexReference-1)/(length(referenceData)-1);
    
        referenceColor = (1-n).*referenceColorA + (n).*referenceColorB;
    
        fileName = referenceFiles(indexReference).name;
        tag = 'guenther';
        idxA=strfind(fileName,tag)+length(tag);
        idxB=strfind(fileName,'.')-1;
        seriesName = [fileName(idxA:idxB),'g'];

        plot(referenceData(indexReference).data(:,1),...
             referenceData(indexReference).data(:,2),...
             'Color', referenceColor,...
             'LineWidth', 1.5);
        hold on;
        

        [val,idx]=max(referenceData(indexReference).data(:,1));
        
        plot(referenceData(indexReference).data(idx,1),...
             referenceData(indexReference).data(idx,2),...
             'o','Color',referenceColor,...
             'LineWidth',1,...
             'MarkerSize',4,...
             'MarkerFaceColor', [1,1,1]);
        hold on; 
        
        text(referenceData(indexReference).data(idx,1),...
             referenceData(indexReference).data(idx,2),...
             seriesName,...
             'FontSize',6,...
             'VerticalAlignment','bottom',...
             'HorizontalAlignment','right');
        hold on;



        box off;
    end

end

% Add the simulation data
if(flag_addSimulationData)
    n = (indexSimulation-1)/(totalSimulations-1);

    simulationColor = (1-n).*simulationColorA + (n).*simulationColorB;

    
    tag = 'quickrelease_';
    idxA=strfind(simulationFile,tag)+length(tag);
    seriesName = ['Sim: ',simulationFile(idxA:end)];
 
    plot(lsdynaBinout.nodout.z_velocity,...
         lsdynaBinout.elout.beam.axial,...
         'Color', simulationColor,...
         'DisplayName','');
    hold on;
    box off;    
end

xlim([0,0.5]);
ylim([0,30]);
set(gca, 'XTick', [0:0.05:0.5]);
set(gca, 'YTick', [0:5:30]);
xlabel('Velocity (m/s)');
ylabel('Force (N)');
title('Guenther, Schmitt, Wank (2007) Fig. 7')
