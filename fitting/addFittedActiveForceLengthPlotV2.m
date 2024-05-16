function [figH]= addFittedActiveForceLengthPlotV2(...
                    figH,vexatCurves,ehtmmCurves,... 
                    umat41,umat43,...
                    sarcomere,...
                    umat43QuadraticBezierCurves,...
                    keyPointsHL1997,keyPointsHL2002,...
                    subPlotPanel,plotSettings)

umat41Color     = plotSettings.umat41.color;
umat41Label     = plotSettings.umat41.label;
umat41LineWidth = plotSettings.umat41.lineWidth;
umat41LineType  = plotSettings.umat41.lineType;

umat43Color     = plotSettings.umat43.color;
umat43Label     = plotSettings.umat43.label;
umat43LineWidth = plotSettings.umat43.lineWidth;
umat43LineType  = plotSettings.umat43.lineType;

HL1997Color     = plotSettings.HL1997.color;
HL1997Label     = plotSettings.HL1997.label;
HL1997LineWidth = plotSettings.HL1997.lineWidth;
HL1997LineType  = plotSettings.HL1997.lineType;

HL2002Color     = plotSettings.HL2002.color;
HL2002Label     = plotSettings.HL2002.label;
HL2002LineWidth = plotSettings.HL2002.lineWidth;
HL2002LineType  = plotSettings.HL2002.lineType;



umat41FalRMSE = ehtmmCurves.fl.rmse;
umat43FalRMSE = vexatCurves.fl.rmse;

npts=100;

lceN0 = umat43QuadraticBezierCurves.activeForceLengthCurve.xEnd(1,1);
lceN1 = umat43QuadraticBezierCurves.activeForceLengthCurve.xEnd(1,2);

umat41Curves.fl.lceN   = [lceN0:((lceN1-lceN0)/(npts-1)):lceN1]';
umat41Curves.fl.fceN   = zeros(size(umat41Curves.fl.lceN));
umat41Curves.fl.lceNAT = zeros(size(umat41Curves.fl.lceN));
umat41Curves.fl.fceNAT = zeros(size(umat41Curves.fl.lceN));

umat43Curves.fl.lceNAT = zeros(size(umat41Curves.fl.lceN));
umat43Curves.fl.fceNAT = zeros(size(umat41Curves.fl.lceN));

for i=1:1:npts
    lceN=umat41Curves.fl.lceN(i,1);
    lceOpt = umat43.lceOpt;

    fibKin= calcFixedWidthPennatedFiberKinematicsAlongTendon(...
                                        lceN*lceOpt,...
                                        0,...
                                        lceOpt,...
                                        umat43.penOpt);

    lceAT = fibKin.fiberLengthAlongTendon;
    alpha = fibKin.pennationAngle;

    falN43 = calcQuadraticBezierYFcnXDerivative(lceN,...
                umat43QuadraticBezierCurves.activeForceLengthCurve,0);

    umat43Curves.fl.fceN(i,1) = falN43;
    umat43Curves.fl.lceNAT(i,1) = lceN*cos(alpha);
    umat43Curves.fl.fceNAT(i,1) = falN43*cos(alpha);

    umat41Curves.fl.lceNAT(i,1) = lceN*cos(alpha);

    falN41 =calcFisomUmat41(umat41Curves.fl.lceNAT(i,1)*umat41.lceOptAT,...
                umat41.lceOptAT,...
                umat41.dWdes,umat41.nuCEdes,umat41.dWasc,umat41.nuCEasc);

    umat41Curves.fl.fceNAT(i,1) = falN41;

end


figure(figH);
    if(length(subPlotPanel)==3)
        subplot(subPlotPanel(1,1),subPlotPanel(1,2),subPlotPanel(1,3));
    end
    if(length(subPlotPanel)==4)
        subplot('Position',subPlotPanel);
    end



    plot(umat41Curves.fl.lceNAT,...
         umat41Curves.fl.fceNAT,...
         plotSettings.umat41.lineType,...
        'Color',umat41Color,...
        'DisplayName',[umat41Label,' $$\mathbf{f}^\mathrm{L}$$'],...
        'LineWidth',umat41LineWidth);
    hold on;

    plot(umat43Curves.fl.lceNAT,...
        umat43Curves.fl.fceNAT,...
        plotSettings.umat43.lineType,...
        'Color',umat43Color,...
        'DisplayName',[umat43Label,' $$\mathbf{f}^\mathrm{L}$$'],...
        'LineWidth',umat43LineWidth*0.5);
    hold on;

    plot(keyPointsHL1997.fl.lceNAT,...
         keyPointsHL1997.fl.fceNAT,...
         HL1997LineType,...
         'LineWidth',0.5,...
         'MarkerSize',3,...
         'Color',[1,1,1],...
         'MarkerFaceColor',HL1997Color,...
         'DisplayName',HL1997Label);
    hold on;

    hold on;
    plot(keyPointsHL2002.fl.lceNAT,...
         keyPointsHL2002.fl.fceNAT,...
         HL2002LineType,...
         'LineWidth',0.5,'Color',[0,0,0],...
         'MarkerSize',3,...
         'MarkerFaceColor',HL2002Color,...
         'DisplayName',HL2002Label);
    hold on;

    text(1.8,1-0.075,...
        sprintf('%s %1.4f',...
            'RMSE',umat41FalRMSE),...
            'HorizontalAlignment','right',...
            'VerticalAlignment','top',...
            'Color',umat41Color,...
            'FontSize',6);
    hold on;

    text(1.8,1,...
        sprintf('%s %1.4f',...
            'RMSE',umat43FalRMSE),...
            'HorizontalAlignment','right',...
            'VerticalAlignment','top',...
            'Color',umat43Color,...
            'FontSize',6);
    hold on;    

    %Points used in the construction of the feline 
    lceN0=sarcomere.normSarcomereLengthZeroForce;
    lceN1=(sarcomere.normActinLength ...
             +sarcomere.normMyosinHalfLength ...
             +sarcomere.normZLineLength)*2;

    xticks(round([lceN0,1,lceN1],2));
    yticks([0,1]);

    box off;
    
    xlim([min(umat43Curves.fl.lceNAT),max(umat43Curves.fl.lceNAT)]);
    ylim(plotSettings.ylim);

    xlabel('Norm. Length ($$\ell/\ell^M_o$$)');
    ylabel('Norm. Force ($$f/f^M_o$$)');    
    title('C. Active force length fitting $$\mathbf{f}^\mathrm{L}$$');

    [lgdH, lgdIcons, lgdPlots, lgdTxt]=...
        legend('Location','southeast','FontSize',6);

    [lgdH, lgdIcons, lgdPlots, lgdTxt,xDataOrig,xDataUpd] = ...
    scaleLegendLines(0.5,lgdH, lgdIcons, lgdPlots, lgdTxt);

    legend boxoff;
