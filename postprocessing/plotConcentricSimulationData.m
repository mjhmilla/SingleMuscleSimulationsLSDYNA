function figH = plotConcentricSimulationData(figH,lsdynaBinout,lsdynaMuscle, ...
                      indexColumn,...
                      subPlotLayout,subPlotRows,subPlotColumns,...                      
                      simulationFile,indexSimulation, totalSimulations,... 
                      referenceFiles,referenceData,...                      
                      flag_addReferenceData,...
                      flag_addSimulationData,...
                      simulationColorA, simulationColorB, ...
                      referenceColorA, referenceColorB)

figure(figH);

subplot('Position', reshape( subPlotLayout(1,indexColumn,:),1,4 ) );

% Add the reference data
if(flag_addReferenceData==1)
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
        
        [val,idx]=max(referenceData(indexReference).data(:,2));
        text(referenceData(indexReference).data(idx,1),...
             referenceData(indexReference).data(idx,2),...
             seriesName,...
             'FontSize',6,...
             'VerticalAlignment','bottom',...
             'HorizontalAlignment','center');


        box off;
    end

end

% Add the simulation data
if(flag_addSimulationData)
    n = (indexSimulation-1)/(totalSimulations-1);

    simulationColor = (1-n).*simulationColorA + (n).*simulationColorB;

    
    tag = 'concentric_';
    idxA=strfind(simulationFile,tag)+length(tag);
    seriesName = ['Sim: ',simulationFile(idxA:end)];

    data = [lsdynaBinout.nodout.time',lsdynaBinout.nodout.z_velocity];

    data      = data((data(:,2)~=0),:);
    data(:,1) = data(:,1)-data(1,1);
    %indexStart = find(data(:,2) > 0,1)-1;
    %x = data(indexStart:end,1)-data(indexStart,1);
    %y = data(indexStart:end,2);   

    plot(data(:,1),data(:,2),...
         'Color', simulationColor,...
         'DisplayName','');
    hold on;
    box off;    
end

xlim([0,0.16]);
set(gca, 'XTick', [0:0.02:0.16]);
set(gca, 'YTick', [0:0.02:0.12]);
xlabel('Time (s)');
ylabel('Velocity (m/s)');
title('Guenther, Schmitt, Wank (2007) Fig. 6')
