function figH = plotSimulationDataSummary(figH,lsdynaBinout,lsdynaMuscle, ...
                      indexColumn,...
                      subPlotLayout,subPlotRows,subPlotColumns,...                      
                      simulationFile,indexSimulation, totalSimulations,...          
                      binoutColorA, binoutColorB,...
                      musoutColorA, musoutColorB)

figure(figH);


n = (indexSimulation-1)/(totalSimulations-1);
binoutColor = (1-n).*binoutColorA + (n).*binoutColorB;
musoutColor = (1-n).*musoutColorA + (n).*musoutColorB;

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

%% Extract the numeric values from the simulationFile name

seriesNumber ='';
zero2nine='0123456789';
for i=1:1:length(simulationFile)
    for j=1:1:length(zero2nine)
        if(strcmp(simulationFile(i),zero2nine(j))==1)
            seriesNumber = [seriesNumber,simulationFile(i)];
        end
    end
    if strcmp(simulationFile(i),'.')==1
        seriesNumber=[seriesNumber,simulationFile(i)];
    end

end

%% MTC length
subplot('Position',reshape(subPlotLayout(1,indexColumn,:),1,4));



plot(lsdynaBinout.nodout.time',...
    -lsdynaBinout.nodout.z_coordinate,...
     'Color',binoutColor,...
     'LineWidth',1.5);
hold on;


text( 0.20, 0.0+n*0.5, seriesNumber,...
      'Units', 'Normalized',...
      'Color', binoutColor);
hold on;

text( 0.05, 0.0+n*0.5, seriesNumber,...
      'Units', 'Normalized',...
      'Color', musoutColor);
hold on;

%text(lsdynaBinout.nodout.time(1,idx)',...
%    -lsdynaBinout.nodout.z_coordinate(idx,1),...
%    seriesNumber);
%hold on;


plot(lsdynaMuscle.data(:,indexMusoutTime),...
     lsdynaMuscle.data(:,indexMusoutLmtc),...
     'Color',musoutColor);

xlabel('Time (s)');
ylabel('Length (m)');
title('Musculotendon Length')
box off;




%% MTC Force
subplot('Position',reshape(subPlotLayout(2,indexColumn,:),1,4));

plot(lsdynaBinout.nodout.time',...
     lsdynaBinout.elout.beam.axial,...
     'Color',binoutColor,...
     'DisplayName','$$f^{MT}$$ (nodout)',...
     'LineWidth',1.5);
hold on;


plot(lsdynaMuscle.data(:,indexMusoutTime),...
     lsdynaMuscle.data(:,indexMusoutFmtc),...
     'Color',musoutColor,...
     'DisplayName','$$f^{MT}$$ (musout)');
hold on;

text( 0.20, n*0.5, seriesNumber,...
      'Units', 'Normalized',...
      'Color', binoutColor);
hold on;

text( 0.05, n*0.5, seriesNumber,...
      'Units', 'Normalized',...
      'Color', musoutColor);
hold on;


xlabel('Time (s)');
ylabel('Force (N)');
title('Musculotendon Force')
box off;
%legend('Location','South');
%legend boxoff;

%% CE & SEE Length



%% CE Velcoity & SEE velocity

%% 
