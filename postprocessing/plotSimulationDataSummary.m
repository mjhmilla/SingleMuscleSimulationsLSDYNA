function figH = plotSimulationDataSummary(figH,modelName,lsdynaBinout,...
                      lsdynaMuscleUniform, indexColumn,...
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


%switch modelName
%    case 'umat41'
%        indexMuscleTime         = lsdynaMuscle.indexTime;
%        indexMuscleExcitation   = lsdynaMuscle.indexHsvExcitation;
%        indexMuscleActivation   = lsdynaMuscle.indexHsvAct; 
%        indexMuscleFmt          = lsdynaMuscle.indexFmt;
%        indexMuscleFce          = lsdynaMuscle.indexFce;
%        indexMuscleFpee         = lsdynaMuscle.indexFpee;
%        indexMuscleFsee         = lsdynaMuscle.indexFsee;
%        indexMuscleFsde         = lsdynaMuscle.indexFsde;
%        indexMuscleLmt          = lsdynaMuscle.indexLmt;
%        indexMuscleLce          = lsdynaMuscle.indexLce;
%        indexMuscleLmtDot       = lsdynaMuscle.indexLmtDot;
%        indexMuscleLceDot       = lsdynaMuscle.indexLceDot;
%        %scaleForces = 1;
%        scaleCEForces       = 1/maximumIsometricForce;
%        scaleCELength       = 1/optimalFiberLength;
%        scaleTendonLength   = 1/optimalFiberLength;
%
%    case 'umat43'
%        indexMuscleTime         = lsdynaMuscle.indexTime;
%        indexMuscleExcitation   = lsdynaMuscle.indexHsvExcitation;
%        indexMuscleActivation   = lsdynaMuscle.indexHsvActivation; 
%        indexMuscleFmt          = lsdynaMuscle.indexHsvFtN;
%        indexMuscleFce          = lsdynaMuscle.indexHsvFceN;
%        indexMuscleFpee         = lsdynaMuscle.indexHsvFecmHN;
%        indexMuscleFsee         = lsdynaMuscle.indexHsvFtfcnN;
%        indexMuscleFsde         = lsdynaMuscle.indexHsvFtBetaN;
%        indexMuscleLmt          = lsdynaMuscle.indexHsvLp;
%        indexMuscleLce          = lsdynaMuscle.indexHsvLceN;
%        indexMuscleLmtDot       = lsdynaMuscle.indexHsvVp;
%        indexMuscleLceDot       = lsdynaMuscle.indexHsvVceNN;
%        %scaleForces = maximumIsometricForce;
%        scaleCEForces       = 1;
%        scaleCELength       = 1;
%        scaleTendonLength   = tendonSlackLength/optimalFiberLength;
%     
%end
%
%assert(indexMuscleTime ~= 0)

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


text( 0.80, 0.9, seriesNumber,...
      'Units', 'Normalized',...
      'Color', binoutColor);
hold on;

text( 0.9, 0.9, seriesNumber,...
      'Units', 'Normalized',...
      'Color', musoutColor);
hold on;

%text(lsdynaBinout.nodout.time(1,idx)',...
%    -lsdynaBinout.nodout.z_coordinate(idx,1),...
%    seriesNumber);
%hold on;

if(isempty(lsdynaMuscleUniform)==0)
    plot(lsdynaMuscleUniform.time,...
         lsdynaMuscleUniform.lp,...
         'Color',musoutColor);
end

axis tight;
yl = ylim;
yminDes = 0;
ymaxDes = (optimalFiberLength*1.6+tendonSlackLength*1.2);
ymin = min(yminDes, min(yl));
ymax = max(ymaxDes,max(yl));
ylim([ymin,ymax]);


xlabel('Time (s)');
ylabel('Length (m)');
title('Musculotendon Length');
box off;



%% MTC Force
subplot('Position',reshape(subPlotLayout(2,indexColumn,:),1,4));

plot(lsdynaBinout.elout.beam.time',...
     lsdynaBinout.elout.beam.axial ./ maximumIsometricForce,...
     '--','Color',binoutColor,'LineWidth',2);
hold on;

if(isempty(lsdynaMuscleUniform)==0)
    plot(lsdynaMuscleUniform.time,...
         lsdynaMuscleUniform.fmtN,...
         'Color',musoutColor);
    hold on;
end

text( 0.80, 0.9, seriesNumber,...
      'Units', 'Normalized',...
      'Color', binoutColor);
hold on;

text( 0.9, 0.9, seriesNumber,...
      'Units', 'Normalized',...
      'Color', musoutColor);
hold on;

axis tight;
yl = ylim;
yminDes = -0.05;%*maximumIsometricForce;
ymaxDes = 1.5;%maximumIsometricForce*1.5;
ymin = min(yminDes, min(yl));
ymax = max(ymaxDes,max(yl));
ylim([ymin,ymax]);

xlabel('Time (s)');
ylabel('Norm. Force (N/N)');
title('Musculotendon Force');
box off;


%% CE Length

subplot('Position',reshape(subPlotLayout(3,indexColumn,:),1,4));

if(isempty(lsdynaMuscleUniform)==0)
    plot(lsdynaMuscleUniform.time,...
         lsdynaMuscleUniform.lceN,...
         'Color',musoutColor);
    hold on;
end

text( 0.9, 0.9, seriesNumber,...
      'Units', 'Normalized',...
      'Color', musoutColor);
hold on;

axis tight;
yl = ylim;
yminDes = 0;
ymaxDes = 1.6;
ymin = min(yminDes, min(yl));
ymax = max(ymaxDes,max(yl));
ylim([ymin,ymax]);

xlabel('Time (s)');
ylabel('Norm. Length ($$\ell^{M}/\ell^{M}_{\circ}$$)');
title('Contractile Element Norm. Length');
box off;

%% SE Length

subplot('Position',reshape(subPlotLayout(4,indexColumn,:),1,4));

if(isempty(lsdynaMuscleUniform)==0)    
    plot(lsdynaMuscleUniform.time,...
         lsdynaMuscleUniform.ltN ./ optimalFiberLength,...
         'Color',musoutColor);
    hold on;
end

text( 0.9, 0.9, seriesNumber,...
      'Units', 'Normalized',...
      'Color', musoutColor);
hold on;


axis tight;
yl = ylim;
yminDes = (tendonSlackLength*0.9/optimalFiberLength);
ymaxDes = (tendonSlackLength*1.2/optimalFiberLength);
ymin = min(yminDes, min(yl));
ymax = max(ymaxDes,max(yl));
ylim([ymin,ymax]);

xlabel('Time (s)');
ylabel('Norm. Length ($$\ell^{T}/\ell^{M}_{\circ}$$)');
title('Tendon Norm. Length');
box off;

%% CE Velocity

subplot('Position',reshape(subPlotLayout(5,indexColumn,:),1,4));

if(isempty(lsdynaMuscleUniform)==0)
    plot(lsdynaMuscleUniform.time,...
         lsdynaMuscleUniform.lceNDot,...
         'Color',musoutColor);
    hold on;
end

text( 0.9, 0.9, seriesNumber,...
      'Units', 'Normalized',...
      'Color', musoutColor);
hold on;


axis tight;
yl = ylim;
yminDes = -10;
ymaxDes =  10;
ymin = min(yminDes, min(yl));
ymax = max(ymaxDes,max(yl));
ylim([ymin,ymax]);


xlabel('Time (s)');
ylabel('Norm. Velocity ($$\dot{\ell}^{M}/\ell^{M}_{\circ}$$)');
title('Contractile Element Rate of Lengthening');
box off;

%% SE Velocity

subplot('Position',reshape(subPlotLayout(6,indexColumn,:),1,4));

if(isempty(lsdynaMuscleUniform)==0)

    plot(lsdynaMuscleUniform.time,...
         lsdynaMuscleUniform.ltNDot.*(tendonSlackLength / optimalFiberLength),...
         'Color',musoutColor);
    hold on;
end

text( 0.9, 0.9, seriesNumber,...
      'Units', 'Normalized',...
      'Color', musoutColor);
hold on;


axis tight;
yl = ylim;
yminDes = -10;
ymaxDes =  10;
ymin = min(yminDes, min(yl));
ymax = max(ymaxDes,max(yl));
ylim([ymin,ymax]);


xlabel('Time (s)');
ylabel('Norm. Velocity ($$\dot{\ell}^{T}/\ell^{M}_{o}$$)');
title('Tendon Rate of Lengthening');
box off;

%% Stimulation

subplot('Position',reshape(subPlotLayout(7,indexColumn,:),1,4));

if(isempty(lsdynaMuscleUniform)==0)
    plot(lsdynaMuscleUniform.time,...
         lsdynaMuscleUniform.exc,...
         'Color',musoutColor);
    hold on;
end

text( 0.9, 0.9, seriesNumber,...
      'Units', 'Normalized',...
      'Color', musoutColor);
hold on;


axis tight;
yl = ylim;
yminDes = -0.05;
ymaxDes = 1.10;
ymin = min(yminDes, min(yl));
ymax = max(ymaxDes,max(yl));
ylim([ymin,ymax]);


xlabel('Time (s)');
ylabel('Excitation (0-1)');
title('Excitation');
box off;

%% Activation

subplot('Position',reshape(subPlotLayout(8,indexColumn,:),1,4));

if(isempty(lsdynaMuscleUniform)==0)
    plot(lsdynaMuscleUniform.time,...
         lsdynaMuscleUniform.act,...
         'Color',musoutColor);
    hold on;
end

text( 0.9, 0.9, seriesNumber,...
      'Units', 'Normalized',...
      'Color', musoutColor);
hold on;


axis tight;
yl = ylim;
yminDes = -0.05;
ymaxDes = 1.10;
ymin = min(yminDes, min(yl));
ymax = max(ymaxDes,max(yl));
ylim([ymin,ymax]);


xlabel('Time (s)');
ylabel('Activation (0-1)');
title('Activation');
box off;

%% CE Force

subplot('Position',reshape(subPlotLayout(9,indexColumn,:),1,4));

if(isempty(lsdynaMuscleUniform)==0)
    plot(lsdynaMuscleUniform.time,...
         lsdynaMuscleUniform.fceN,...
         'Color',musoutColor);
    hold on;
end

text( 0.9, 0.9, seriesNumber,...
      'Units', 'Normalized',...
      'Color', musoutColor);
hold on;

axis tight;
yl = ylim;
yminDes = -0.05;
ymaxDes = 1.80;
ymin = min(yminDes, min(yl));
ymax = max(ymaxDes,max(yl));
ylim([ymin,ymax]);


xlabel('Time (s)');
ylabel('Norm. Force ($$f^{M}/f^{M}_{\circ}$$)');
title('Contractile Element Force');
box off;

%% PE Force

subplot('Position',reshape(subPlotLayout(10,indexColumn,:),1,4));

if(isempty(lsdynaMuscleUniform)==0)
    plot(lsdynaMuscleUniform.time,...
         lsdynaMuscleUniform.fpeN,...
         'Color',musoutColor);
    hold on;
end

text( 0.9, 0.9, seriesNumber,...
      'Units', 'Normalized',...
      'Color', musoutColor);
hold on;


axis tight;
yl = ylim;
yminDes = -0.05;
ymaxDes = 1.80;
ymin = min(yminDes, min(yl));
ymax = max(ymaxDes,max(yl));
ylim([ymin,ymax]);


xlabel('Time (s)');
ylabel('Norm. Force ($$f^{PE}/f^{M}_{\circ}$$)');
title('Parallel Element Force');
box off;


%% MT Force

subplot('Position',reshape(subPlotLayout(11,indexColumn,:),1,4));

if(isempty(lsdynaMuscleUniform)==0)
    plot(lsdynaMuscleUniform.time,...
         lsdynaMuscleUniform.fmtN,...
         'Color',musoutColor);
    hold on;
end

text( 0.9, 0.9, seriesNumber,...
      'Units', 'Normalized',...
      'Color', musoutColor);
hold on;

axis tight;
yl = ylim;
yminDes = -0.05;
ymaxDes = 1.80;
ymin = min(yminDes, min(yl));
ymax = max(ymaxDes,max(yl));
ylim([ymin,ymax]);



xlabel('Time (s)');
ylabel('Norm. Force ($$f^{M}/f^{M}_{\circ}$$)');
title('Musculotendon Unit Force');
box off;

%% CE force vs length

subplot('Position',reshape(subPlotLayout(12,indexColumn,:),1,4));

if(isempty(lsdynaMuscleUniform)==0)
    plot(lsdynaMuscleUniform.lceN,...
         lsdynaMuscleUniform.fceN,...
         'Color',musoutColor);
    hold on;
end

text( 0.9, 0.9, seriesNumber,...
      'Units', 'Normalized',...
      'Color', musoutColor);
hold on;


axis tight;
xl = xlim;
xminDes = 0.5;
xmaxDes = 1.60;
xmin = min(xminDes, min(xl));
xmax = max(xmaxDes,max(xl));
xlim([xmin,xmax]);

yl = ylim;
yminDes = -0.05;
ymaxDes = 1.80;
ymin = min(yminDes, min(yl));
ymax = max(ymaxDes,max(yl));
ylim([ymin,ymax]);


xlabel('Norm. Length ($$\ell^{M}/\ell^{M}_{\circ}$$)');
ylabel('Norm. Force ($$f^{M}/f^{M}_{\circ}$$)');
title('Contractile Element: $$\tilde{f}^{M}-\tilde{\ell}^{M}$$');
box off;

%% PE force vs length
subplot('Position',reshape(subPlotLayout(13,indexColumn,:),1,4));

if(isempty(lsdynaMuscleUniform)==0)
    plot(lsdynaMuscleUniform.lceN,...
         lsdynaMuscleUniform.fpeN,...
         'Color',musoutColor);
    hold on;
end

text( 0.9, 0.9, seriesNumber,...
      'Units', 'Normalized',...
      'Color', musoutColor);
hold on;

axis tight;
xl = xlim;
xminDes = 0.5;
xmaxDes = 1.60;
xmin = min(xminDes, min(xl));
xmax = max(xmaxDes,max(xl));
xlim([xmin,xmax]);

yl = ylim;
yminDes = -0.05;
ymaxDes = 1.80;
ymin = min(yminDes, min(yl));
ymax = max(ymaxDes,max(yl));
ylim([ymin,ymax]);


xlabel('Norm. Length ($$\ell^{M}/\ell^{M}_{\circ}$$)');
ylabel('Norm. Force ($$f^{PE}/f^{M}_{\circ}$$)');
title('Contractile Element: $$\tilde{f}^{PE}-\tilde{\ell}^{M}$$');

box off;


%% SE force vs length
subplot('Position',reshape(subPlotLayout(14,indexColumn,:),1,4));

if(isempty(lsdynaMuscleUniform)==0)

    plot(lsdynaMuscleUniform.ltN,...
         lsdynaMuscleUniform.fmtN,...
         'Color',musoutColor);
    hold on;
end

text( 0.9, 0.9, seriesNumber,...
      'Units', 'Normalized',...
      'Color', musoutColor);
hold on;


axis tight;
xl = xlim;
xminDes = 0.9;
xmaxDes = 1.20;
xmin = min(xminDes, min(xl));
xmax = max(xmaxDes,max(xl));
xlim([xmin,xmax]);

yl = ylim;
yminDes = -0.05;
ymaxDes = 1.80;
ymin = min(yminDes, min(yl));
ymax = max(ymaxDes,max(yl));
ylim([ymin,ymax]);


xlabel('Norm. Length ($$\ell^{T}/\ell^{T}_{s}$$)');
ylabel('Norm. Force ($$f^{T}/f^{M}_{\circ}$$)');
title('Contractile Element: $$\tilde{f}^{T}-\tilde{\ell}^{T}$$');

box off;


%indexMuscleFce      = getColumnIndex('f_ce',lsdynaMuscle.columnNames);
%indexMuscleFpee     = getColumnIndex('f_pee',lsdynaMuscle.columnNames);
%indexMuscleFsee     = getColumnIndex('f_see',lsdynaMuscle.columnNames);


