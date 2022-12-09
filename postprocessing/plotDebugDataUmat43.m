function figDebug = plotDebugDataUmat43(figDebug,musout,musdebug,...
                                subPlotLayout,...
                                numberOfPlotRows,...
                                numberOfPlotColumns)


simulationColor = [0,0,1];%simulationColorA;
lineType = '-';

if( max(musout.data(:,musout.indexAct)) > 0.5 )
    simulationColor = [1,0,0];
    referenceColor=[1,1,1].*0.75;
    lineType = '-';    
end

figure(figDebug);

idxPlot=1;

idxRow = ceil(idxPlot/numberOfPlotColumns);
idxColumn = idxPlot-(idxRow-1)*numberOfPlotColumns;
subplot('Position',reshape( subPlotLayout(idxRow,idxColumn,:),1,4 ));

plot(musdebug.data(:,musdebug.indexTime),...
     musdebug.data(:,musdebug.indexPwrTi1K),...
     lineType,'Color',simulationColor);
    hold on;
    xlabel('Time (s)');
    ylabel('Power (Nm/s)');
    title('Titin Element: 1');
    box off;

idxPlot=idxPlot+1;    
idxRow = ceil(idxPlot/numberOfPlotColumns);
idxColumn = idxPlot-(idxRow-1)*numberOfPlotColumns;
subplot('Position',reshape( subPlotLayout(idxRow,idxColumn,:),1,4 ));

plot(musdebug.data(:,musdebug.indexTime),...
     musdebug.data(:,musdebug.indexPwrTi2K),...
     lineType,'Color',simulationColor);
    hold on;
    xlabel('Time (s)');
    ylabel('Power (Nm/s)');
    title('Titin Element: 2');
    box off;

idxPlot=idxPlot+1;
idxRow = ceil(idxPlot/numberOfPlotColumns);
idxColumn = idxPlot-(idxRow-1)*numberOfPlotColumns;
subplot('Position',reshape( subPlotLayout(idxRow,idxColumn,:),1,4 ));

plot(musdebug.data(:,musdebug.indexTime),...
     musdebug.data(:,musdebug.indexPwrTi12),...
     lineType,'Color',simulationColor);
    hold on;
    xlabel('Time (s)');
    ylabel('Power (Nm/s)');
    title('Titin-Actin Bond');
    box off;

idxPlot=idxPlot+1;
idxRow = ceil(idxPlot/numberOfPlotColumns);
idxColumn = idxPlot-(idxRow-1)*numberOfPlotColumns;
subplot('Position',reshape( subPlotLayout(idxRow,idxColumn,:),1,4 ));

plot(musdebug.data(:,musdebug.indexTime),...
     musdebug.data(:,musdebug.indexPwrEcmK),...
     lineType,'Color',simulationColor);
    hold on;
    xlabel('Time (s)');
    ylabel('Power (Nm/s)');
    title('Ecm Element: Spring');
    box off;    

idxPlot=idxPlot+1;    
idxRow = ceil(idxPlot/numberOfPlotColumns);
idxColumn = idxPlot-(idxRow-1)*numberOfPlotColumns;
subplot('Position',reshape( subPlotLayout(idxRow,idxColumn,:),1,4 ));

plot(musdebug.data(:,musdebug.indexTime),...
     musdebug.data(:,musdebug.indexPwrEcmD),...
     lineType,'Color',simulationColor);
    hold on;
    xlabel('Time (s)');
    ylabel('Power (Nm/s)');
    title('Ecm Element: Damper');
    box off;    

idxPlot=idxPlot+1;    
idxRow = ceil(idxPlot/numberOfPlotColumns);
idxColumn = idxPlot-(idxRow-1)*numberOfPlotColumns;
subplot('Position',reshape( subPlotLayout(idxRow,idxColumn,:),1,4 ));

plot(musdebug.data(:,musdebug.indexTime),...
     musdebug.data(:,musdebug.indexPwrXeK),...
     lineType,'Color',simulationColor);
    hold on;
    xlabel('Time (s)');
    ylabel('Power (Nm/s)');
    title('XE Element: Spring');
    box off;    
    
idxPlot=idxPlot+1;    
idxRow = ceil(idxPlot/numberOfPlotColumns);
idxColumn = idxPlot-(idxRow-1)*numberOfPlotColumns;
subplot('Position',reshape( subPlotLayout(idxRow,idxColumn,:),1,4 ));

plot(musdebug.data(:,musdebug.indexTime),...
     musdebug.data(:,musdebug.indexPwrXeD),...
     lineType,'Color',simulationColor);
    hold on;
    xlabel('Time (s)');
    ylabel('Power (Nm/s)');
    title('XE Element: Damper');
    box off;    

idxPlot=idxPlot+1;    
idxRow = ceil(idxPlot/numberOfPlotColumns);
idxColumn = idxPlot-(idxRow-1)*numberOfPlotColumns;
subplot('Position',reshape( subPlotLayout(idxRow,idxColumn,:),1,4 ));

plot(musdebug.data(:,musdebug.indexTime),...
     musdebug.data(:,musdebug.indexPwrXeA),...
     lineType,'Color',simulationColor);
    hold on;
    xlabel('Time (s)');
    ylabel('Power (Nm/s)');
    title('XE Element: Bond');
    box off;

idxPlot=idxPlot+1;    
idxRow = ceil(idxPlot/numberOfPlotColumns);
idxColumn = idxPlot-(idxRow-1)*numberOfPlotColumns;
subplot('Position',reshape( subPlotLayout(idxRow,idxColumn,:),1,4 ));

plot(musdebug.data(:,musdebug.indexTime),...
     musdebug.data(:,musdebug.indexPwrCpK),...
     lineType,'Color',simulationColor);
    hold on;
    xlabel('Time (s)');
    ylabel('Power (Nm/s)');
    title('Cp Element: Spring');
    box off;

idxPlot=idxPlot+1;    
idxRow = ceil(idxPlot/numberOfPlotColumns);
idxColumn = idxPlot-(idxRow-1)*numberOfPlotColumns;
subplot('Position',reshape( subPlotLayout(idxRow,idxColumn,:),1,4 ));

plot(musdebug.data(:,musdebug.indexTime),...
     musdebug.data(:,musdebug.indexPwrTK),...
     lineType,'Color',simulationColor);
    hold on;
    xlabel('Time (s)');
    ylabel('Power (Nm/s)');
    title('Tendon: Spring');
    box off;

idxPlot=idxPlot+1;    
idxRow = ceil(idxPlot/numberOfPlotColumns);
idxColumn = idxPlot-(idxRow-1)*numberOfPlotColumns;
subplot('Position',reshape( subPlotLayout(idxRow,idxColumn,:),1,4 ));

plot(musdebug.data(:,musdebug.indexTime),...
     musdebug.data(:,musdebug.indexPwrTD),...
     lineType,'Color',simulationColor);
    hold on;
    xlabel('Time (s)');
    ylabel('Power (Nm/s)');
    title('Tendon: Damper');
    box off;

idxPlot=idxPlot+1;    
idxRow = ceil(idxPlot/numberOfPlotColumns);
idxColumn = idxPlot-(idxRow-1)*numberOfPlotColumns;
subplot('Position',reshape( subPlotLayout(idxRow,idxColumn,:),1,4 ));

plot(musdebug.data(:,musdebug.indexTime),...
     musdebug.data(:,musdebug.indexPwrPP),...
     lineType,'Color',simulationColor);
    hold on;
    xlabel('Time (s)');
    ylabel('Power (Nm/s)');
    title('Path');
    box off;

idxPlot=idxPlot+1;    
idxRow = ceil(idxPlot/numberOfPlotColumns);
idxColumn = idxPlot-(idxRow-1)*numberOfPlotColumns;
subplot('Position',reshape( subPlotLayout(idxRow,idxColumn,:),1,4 ));

plot(musdebug.data(:,musdebug.indexTime),...
     musdebug.data(:,musdebug.indexErrForce),...
     lineType,'Color',simulationColor);
    hold on;
    xlabel('Time (s)');
    ylabel('Norm. Force (N/N)');
    title('CE-Tendon Force Imbalance');
    box off;

idxPlot=idxPlot+1;    
idxRow = ceil(idxPlot/numberOfPlotColumns);
idxColumn = idxPlot-(idxRow-1)*numberOfPlotColumns;
subplot('Position',reshape( subPlotLayout(idxRow,idxColumn,:),1,4 ));

plot(musdebug.data(:,musdebug.indexTime),...
     musdebug.data(:,musdebug.indexErrVel),...
     lineType,'Color',simulationColor);
    hold on;
    xlabel('Time (s)');
    ylabel('Velocity (m/s)');
    title('CE-Tendon-Path Velocity Imbalance');
    box off;

here=1;