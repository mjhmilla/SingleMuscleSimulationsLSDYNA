function figH = plotIsometricSimulationData(figH,lsdynaBinout,lsdynaMuscleUniform, ...
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
        seriesName = ['$$\tilde{\ell}^{M}=$$',fileName(idxA),'.',fileName((idxA+1):idxB)];


        plot(referenceData(indexReference).data(:,1),...
             referenceData(indexReference).data(:,2),...
             'Color', referenceColor,...
             'LineWidth', 1.5);
        hold on;
        

        %[val,idx]=max(referenceData(indexReference).data(:,2));
        val = Inf;
        idx = 0;
        for z=1:1:length(referenceData(indexReference).data(:,1))
           if( abs(referenceData(indexReference).data(z,1) - 1.0) < val)
              idx=z; 
              val = abs(referenceData(indexReference).data(z,1) - 1.0);
           end
        end

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
             'HorizontalAlignment','center');
        hold on;



        box off;
    end

end

% Add the simulation data
if(flag_addSimulationData)
    n = (indexSimulation-1)/(totalSimulations-1);

    simulationColor = (1-n).*simulationColorA + (n).*simulationColorB;

    
    tag = 'isometric_';
    idxA=strfind(simulationFile,tag)+length(tag);
    seriesName = ['Sim: ',simulationFile(idxA:end)];
 
    plot(lsdynaBinout.elout.beam.time',...
         lsdynaBinout.elout.beam.axial,...
         'Color', simulationColor,...
         'DisplayName','');
    hold on;
    box off;    
end

xlim([0,1.5]);
ylim([0,45]);
set(gca, 'XTick', [0:0.1:1.5]);
set(gca, 'YTick', [0:5:45]);
xlabel('Time (s)');
ylabel('Force (N)');
title('Guenther, Schmitt, Wank (2007) Fig. 7')
