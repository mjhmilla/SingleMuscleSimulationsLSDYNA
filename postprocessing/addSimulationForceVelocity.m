function figH = addSimulationForceVelocity(...
                    figH,subplotPosition,...
                    dataFv, ...
                    lsdynaMuscleUniform,...
                    lineAndMarkerSettings,...
                    addLegendEntry)

figure(figH);
subplot('Position',subplotPosition);


[valMap,idxMap] = sort(dataFv(:,4));
act = dataFv(1,2);

%displayNameStr = [lsdynaMuscleUniform.nameLabel, sprintf('(%1.1f)',act)]; 
displayNameStr = lsdynaMuscleUniform.nameLabel; 


plot(dataFv(idxMap,4),...
     dataFv(idxMap,5),...
     '-',...
    'Color',[1,1,1],...
    'LineWidth',lineAndMarkerSettings.lineWidth+1,...
    'DisplayName',displayNameStr,...
    'HandleVisibility','off'); 
hold on;
plot(dataFv(idxMap,4),...
     dataFv(idxMap,5),...
     lsdynaMuscleUniform.mark,...
    'Color',[1,1,1],...
    'LineWidth',lineAndMarkerSettings.lineWidth,...
    'DisplayName',displayNameStr,...
    'HandleVisibility','off',...
    'MarkerFaceColor',[1,1,1],...
    'MarkerSize',lineAndMarkerSettings.markerSize+2);
hold on;

hvis='off';
if(addLegendEntry==1)
    hvis='on';
end

plot(dataFv(idxMap,4),...
     dataFv(idxMap,5),...
     lineAndMarkerSettings.lineType,...
    'Color',lineAndMarkerSettings.lineColor,...
    'LineWidth',lineAndMarkerSettings.lineWidth,...
    'DisplayName',displayNameStr,...
    'HandleVisibility',hvis,...
    'MarkerFaceColor',lineAndMarkerSettings.markerFaceColor,...
    'MarkerSize',lineAndMarkerSettings.markerSize); 
hold on;
plot(dataFv(idxMap,4),...
     dataFv(idxMap,5),...
     lsdynaMuscleUniform.mark,...
    'Color',lineAndMarkerSettings.lineColor,...
    'LineWidth',lineAndMarkerSettings.lineWidth,...
    'DisplayName',displayNameStr,...
    'HandleVisibility','off',...
    'MarkerFaceColor',lineAndMarkerSettings.markerFaceColor,...
    'MarkerSize',lineAndMarkerSettings.markerSize); 
hold on;
box off;  