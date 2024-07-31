%%
% SPDX-FileCopyrightText: 2024 Matthew Millard <millard.matthew@gmail.com>
%
% SPDX-License-Identifier: MIT
%%
function figH = addSimulationPassiveForceLength(...
            figH,subplotPosition,lsdynaMuscleUniform,...
            muscleArchitecture,...
            lineAndMarkerSettings,...
            plotSettings,...
            flag_plotInNormalizedCoordinates)

optimalFiberLength      =muscleArchitecture.lceOpt;
maximumIsometricForce   =muscleArchitecture.fiso;
tendonSlackLength       =muscleArchitecture.ltslk;
pennationAngle          =muscleArchitecture.alpha;

lineType        = lineAndMarkerSettings.lineType        ;
lineColor       = lineAndMarkerSettings.lineColor       ;
lineWidth       = lineAndMarkerSettings.lineWidth       ;
markerType      = lineAndMarkerSettings.mark            ;
markerFaceColor = lineAndMarkerSettings.markerFaceColor ;
markerLineWidth = lineAndMarkerSettings.markerLineWidth ;
markerSize      = lineAndMarkerSettings.markerSize      ;

figure(figH);
subplot('Position',subplotPosition);

idxA = 1;
if(length(lsdynaMuscleUniform.eloutAxialBeamForceNorm) ...
        > length(lsdynaMuscleUniform.lceATN))
    idxA=2;
end

if(flag_plotInNormalizedCoordinates==1)
    lengthPlot = lsdynaMuscleUniform.lceN;
    forcePlot  = lsdynaMuscleUniform.eloutAxialBeamForceNorm(idxA:end,1);
else
    lengthPlot  = lsdynaMuscleUniform.lp;
    forcePlot   = lsdynaMuscleUniform.eloutAxialBeamForceNorm(idxA:end,1).*maximumIsometricForce;
end

displayNameStr=lsdynaMuscleUniform.nameLabel;

plot(lengthPlot,...
     forcePlot,...
     '-',...
    'Color',[1,1,1],...
    'LineWidth',lineWidth+2,...
    'DisplayName',displayNameStr,...
    'HandleVisibility','off');
hold on;        
plot(lengthPlot,...
     forcePlot,...
     '-',...
    'Color',lineColor,...
    'LineWidth',lineWidth,...
    'DisplayName',displayNameStr,...
    'HandleVisibility','on');
hold on;


if(flag_plotInNormalizedCoordinates==1)
    fpeN = lsdynaMuscleUniform.eloutAxialBeamForceNorm(idxA:end,1);
    lceN = lsdynaMuscleUniform.lceN;
    fpeMin = 0.01;
    fpeIso = 1;            
else
    fpeN = lsdynaMuscleUniform.eloutAxialBeamForceNorm(idxA:end,1).*maximumIsometricForce;
    lceN = lsdynaMuscleUniform.lp;            
    fpeMin = 0.01*maximumIsometricForce;
    fpeIso = maximumIsometricForce;
end
fpeMinNewton = 0.001*maximumIsometricForce;
fpeIsoNewton = 1*maximumIsometricForce;


fpeMax = max(fpeN);
[idxValid] = find(fpeN >= fpeMin);
idxMin = min(idxValid)-1;

while(fpeN(idxMin,1) > fpeMin*0.5 && idxMin > 1)
    idxMin=idxMin-1;
end    
idxMin=idxMin-1;

lp0 = lceN(idxMin,1);
fp0 = fpeN(idxMin,1); 

lp1 = interp1(fpeN(idxValid,:), ...
              lceN(idxValid,:), fpeIso);

lp0MM       = lsdynaMuscleUniform.lp(idxMin,1)*1000;
lce0MM      = lp0MM-tendonSlackLength*1000;
fp0Newton   = lsdynaMuscleUniform.eloutAxialBeamForceNorm(idxA+idxMin,1);                    
fp0Newton   = fp0Newton*maximumIsometricForce;

idxValidElout  = (idxValid)+(idxA-1);

lp1MM       = ...
   interp1(lsdynaMuscleUniform.eloutAxialBeamForceNorm(idxValidElout,1).*maximumIsometricForce, ...
            lsdynaMuscleUniform.lp(idxValid,:)*1000, ...
             fpeIsoNewton);
lce1MM = lp1MM-tendonSlackLength*1000;

fp1Newton   = fpeIsoNewton; 


dfdl = calcCentralDifferenceDataSeries(...
         lsdynaMuscleUniform.lp(idxValid,:).*1000,...
         lsdynaMuscleUniform.eloutAxialBeamForceNorm(idxValidElout,1).*maximumIsometricForce);

dfdl1 = interp1(lceN(idxValid,:),...
                dfdl,lp1);


idx=1;
lpLeft= min(plotSettings(idx).xLim);

xDelta=abs(diff(plotSettings(idx).xLim))*0.05;
yDelta=abs(diff(plotSettings(idx).yLim))*0.05;

plot(lp0,fp0,...
     markerType,...
     'Color',lineColor,...
     'MarkerFaceColor',lineColor,...
     'LineWidth',lineWidth,...
     'MarkerSize',markerSize,...
     'HandleVisibility','off');
hold on;
plot([lp0,lp0],[fp0,fp0+3*yDelta],...
     'Color',[1,1,1],...
     'LineWidth',1,...
     'HandleVisibility','off');
hold on;
plot([lp0,lp0],[fp0,fp0+3*yDelta],...
     'Color',[0,0,0],...
     'LineWidth',0.5,...
     'HandleVisibility','off');
hold on;

text(lp0,fp0+3*yDelta,...
      sprintf('(%1.0f mm, %1.1f N)', lce0MM, fp0Newton),...
     'HorizontalAlignment','right',...
     'VerticalAlignment','bottom',...
     'FontSize',6);
hold on;

plot(lp1,fpeIso,...
     lsdynaMuscleUniform.mark,...
     'Color',lineColor,...
     'MarkerFaceColor',lineColor,...
     'LineWidth',lineWidth,...
     'MarkerSize',markerSize,...
     'HandleVisibility','off');
hold on;
plot([lp1-3*xDelta,lp1],[fpeIso,fpeIso],...
     'Color',[1,1,1],...
     'LineWidth',1,...
     'HandleVisibility','off');
hold on;
plot([lp1-3*xDelta,lp1],[fpeIso,fpeIso],...
     'Color',[0,0,0],...
     'LineWidth',0.5,...
     'HandleVisibility','off');
hold on;        
text(lp1-3*xDelta,fpeIso,...
      sprintf('(%1.0f mm, %1.1f N)\n %1.2f N/mm', lce1MM, fp1Newton, dfdl1),...
     'HorizontalAlignment','right',...
     'VerticalAlignment','top',...
     'FontSize',6);
hold on;


box off;    
idx=1;
xlim(plotSettings(idx).xLim);
ylim(plotSettings(idx).yLim);
xticks(plotSettings(idx).xTicks);
yticks(plotSettings(idx).yTicks); 

if(flag_plotInNormalizedCoordinates==1)
    xlabel('Norm. Length ($$\ell/\ell^{M}_o$$)');
    ylabel('Norm. Force ($$f/f^{M}_o$$)');             
else
    xlabel('Path Length (mm)');
    ylabel('Tendon Force (N)');             
end

title([plotSettings(idx).titleLabel,' ',lsdynaMuscleUniform.nameLabel,' $$f^{PE}$$']);


