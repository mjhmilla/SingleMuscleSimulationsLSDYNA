function figH = plotSimulationDataSummary(figH,lsdynaBinout,lsdynaMuscle, ...
                      indexColumn,...
                      subPlotLayout,subPlotRows,subPlotColumns,...                      
                      simulationFile,indexSimulation, totalSimulations,...  
                      optimalFiberLength, maximumIsometricForce, tendonSlackLength,...
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
     '--','Color',binoutColor,...
     'LineWidth',2);
hold on;


text( 1.20, 0.0+n*0.5, seriesNumber,...
      'Units', 'Normalized',...
      'Color', binoutColor);
hold on;

text( 1.05, 0.0+n*0.5, seriesNumber,...
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
title('Musculotendon Length');
box off;



%% MTC Force
subplot('Position',reshape(subPlotLayout(2,indexColumn,:),1,4));

plot(lsdynaBinout.elout.beam.time',...
     lsdynaBinout.elout.beam.axial,...
     '--','Color',binoutColor,'LineWidth',2);
hold on;


plot(lsdynaMuscle.data(:,indexMusoutTime),...
     lsdynaMuscle.data(:,indexMusoutFmtc),...
     'Color',musoutColor);
hold on;

text( 1.20, n*0.5, seriesNumber,...
      'Units', 'Normalized',...
      'Color', binoutColor);
hold on;

text( 1.05, n*0.5, seriesNumber,...
      'Units', 'Normalized',...
      'Color', musoutColor);
hold on;


xlabel('Time (s)');
ylabel('Force (N)');
title('Musculotendon Force');
box off;


%% CE Length

subplot('Position',reshape(subPlotLayout(3,indexColumn,:),1,4));

plot(lsdynaMuscle.data(:,indexMusoutTime),...
     lsdynaMuscle.data(:,indexMusoutLce)./optimalFiberLength,...
     'Color',musoutColor);
hold on;

text( 1.05, n*0.5, seriesNumber,...
      'Units', 'Normalized',...
      'Color', musoutColor);
hold on;

xlabel('Time (s)');
ylabel('Norm. Length ($$\ell^{M}/\ell^{M}_{\circ}$$)');
title('Contractile Element Norm. Length');
box off;

%% SE Length

subplot('Position',reshape(subPlotLayout(4,indexColumn,:),1,4));

ltN = ((lsdynaMuscle.data(:,indexMusoutLmtc)...
       -lsdynaMuscle.data(:,indexMusoutLce) ) ./ optimalFiberLength);

plot(lsdynaMuscle.data(:,indexMusoutTime),...
     ltN,...
     'Color',musoutColor);
hold on;

text( 1.05, n*0.5, seriesNumber,...
      'Units', 'Normalized',...
      'Color', musoutColor);
hold on;

xlabel('Time (s)');
ylabel('Norm. Length ($$\ell^{T}/\ell^{M}_{\circ}$$)');
title('Tendon Norm. Length');
box off;

%% CE Velocity

subplot('Position',reshape(subPlotLayout(5,indexColumn,:),1,4));

plot(lsdynaMuscle.data(:,indexMusoutTime),...
     lsdynaMuscle.data(:,indexMusoutLceDot)./optimalFiberLength,...
     'Color',musoutColor);
hold on;

text( 1.05, n*0.5, seriesNumber,...
      'Units', 'Normalized',...
      'Color', musoutColor);
hold on;

xlabel('Time (s)');
ylabel('Norm. Velocity ($$\dot{\ell}^{M}/\ell^{M}_{\circ}$$)');
title('Contractile Element Rate of Lengthening');
box off;

%% SE Velocity

subplot('Position',reshape(subPlotLayout(6,indexColumn,:),1,4));

ltN = ((lsdynaMuscle.data(:,indexMusoutLmtcDot)...
       -lsdynaMuscle.data(:,indexMusoutLceDot) ) ./ optimalFiberLength);

plot(lsdynaMuscle.data(:,indexMusoutTime),...
     ltN,...
     'Color',musoutColor);
hold on;

text( 1.05, n*0.5, seriesNumber,...
      'Units', 'Normalized',...
      'Color', musoutColor);
hold on;

xlabel('Time (s)');
ylabel('Norm. Velocity ($$\dot{\ell}^{T}/\ell^{M}_{o}$$)');
title('Tendon Rate of Lengthening');
box off;


%% Activation

subplot('Position',reshape(subPlotLayout(7,indexColumn,:),1,4));

plot(lsdynaMuscle.data(:,indexMusoutTime),...
     lsdynaMuscle.data(:,indexMusoutQ).*100,...
     'Color',musoutColor);
hold on;

text( 1.05, n*0.5, seriesNumber,...
      'Units', 'Normalized',...
      'Color', musoutColor);
hold on;

xlabel('Time (s)');
ylabel('Activation (0-1)');
title('Activation');
box off;

%% CE Force

subplot('Position',reshape(subPlotLayout(8,indexColumn,:),1,4));

plot(lsdynaMuscle.data(:,indexMusoutTime),...
     lsdynaMuscle.data(:,indexMusoutFce)./maximumIsometricForce,...
     'Color',musoutColor);
hold on;

text( 1.05, n*0.5, seriesNumber,...
      'Units', 'Normalized',...
      'Color', musoutColor);
hold on;

xlabel('Time (s)');
ylabel('Norm. Force ($$f^{M}/f^{M}_{\circ}$$)');
title('Contractile Element Force');
box off;

%% PE Force

subplot('Position',reshape(subPlotLayout(9,indexColumn,:),1,4));

plot(lsdynaMuscle.data(:,indexMusoutTime),...
     lsdynaMuscle.data(:,indexMusoutFpee)./maximumIsometricForce,...
     'Color',musoutColor);
hold on;

text( 1.05, n*0.5, seriesNumber,...
      'Units', 'Normalized',...
      'Color', musoutColor);
hold on;

xlabel('Time (s)');
ylabel('Norm. Force ($$f^{PE}/f^{M}_{\circ}$$)');
title('Parallel Element Force');
box off;


%% SE Force

subplot('Position',reshape(subPlotLayout(10,indexColumn,:),1,4));


plot(lsdynaMuscle.data(:,indexMusoutTime),...
     lsdynaMuscle.data(:,indexMusoutFsee)./maximumIsometricForce,...
     'Color',musoutColor);
hold on;

text( 1.05, n*0.5, seriesNumber,...
      'Units', 'Normalized',...
      'Color', musoutColor);
hold on;

xlabel('Time (s)');
ylabel('Norm. Force ($$f^{T}/f^{M}_{\circ}$$)');
title('Tendon Force');
box off;

%% CE force vs length

subplot('Position',reshape(subPlotLayout(11,indexColumn,:),1,4));


plot(lsdynaMuscle.data(:,indexMusoutLce)./optimalFiberLength,...
     lsdynaMuscle.data(:,indexMusoutFce)./maximumIsometricForce,...
     'Color',musoutColor);
hold on;

text( 1.05, n*0.5, seriesNumber,...
      'Units', 'Normalized',...
      'Color', musoutColor);
hold on;

xlabel('Norm. Length ($$\ell^{M}/\ell^{M}_{\circ}$$)');
ylabel('Norm. Force ($$f^{M}/f^{M}_{\circ}$$)');
title('Contractile Element: $$\tilde{f}^{M}-\tilde{\ell}^{M}$$');
box off;

%% PE force vs length
subplot('Position',reshape(subPlotLayout(12,indexColumn,:),1,4));


plot(lsdynaMuscle.data(:,indexMusoutLce)./optimalFiberLength,...
     lsdynaMuscle.data(:,indexMusoutFpee)./maximumIsometricForce,...
     'Color',musoutColor);
hold on;

text( 1.05, n*0.5, seriesNumber,...
      'Units', 'Normalized',...
      'Color', musoutColor);
hold on;

xlabel('Norm. Length ($$\ell^{M}/\ell^{M}_{\circ}$$)');
ylabel('Norm. Force ($$f^{PE}/f^{M}_{\circ}$$)');
title('Contractile Element: $$\tilde{f}^{PE}-\tilde{\ell}^{M}$$');

box off;


%% SE force vs length
subplot('Position',reshape(subPlotLayout(13,indexColumn,:),1,4));

ltN = (lsdynaMuscle.data(:,indexMusoutLmtc)...
      -lsdynaMuscle.data(:,indexMusoutLce))./tendonSlackLength;

plot(ltN,...
     lsdynaMuscle.data(:,indexMusoutFsee)./maximumIsometricForce,...
     'Color',musoutColor);
hold on;

text( 1.05, n*0.5, seriesNumber,...
      'Units', 'Normalized',...
      'Color', musoutColor);
hold on;

xlabel('Norm. Length ($$\ell^{T}/\ell^{T}_{s}$$)');
ylabel('Norm. Force ($$f^{T}/f^{M}_{\circ}$$)');
title('Contractile Element: $$\tilde{f}^{T}-\tilde{\ell}^{T}$$');

box off;


%indexMusoutFce      = getColumnIndex('f_ce',lsdynaMuscle.columnNames);
%indexMusoutFpee     = getColumnIndex('f_pee',lsdynaMuscle.columnNames);
%indexMusoutFsee     = getColumnIndex('f_see',lsdynaMuscle.columnNames);


