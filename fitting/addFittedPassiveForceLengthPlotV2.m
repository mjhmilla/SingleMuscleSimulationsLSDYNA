function [figH]= addFittedPassiveForceLengthPlotV2(figH,...
                    vexatCurves,ehtmmCurves,...
                    expData,umat41,umat43,...
                    keyPointsHL1997,keyPointsHL2002,keyPointsVEXATFpe,...
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

%Get the fitting RMSE

umat41FpeRMSE = ehtmmCurves.fpe.rmse;
umat43FpeRMSE = vexatCurves.fpe.rmse;


idxMin = find(ehtmmCurves.fpe.fceNAT > 0.05,1);

lceNATOne = interp1(ehtmmCurves.fpe.fceNAT(idxMin:end),...
                    ehtmmCurves.fpe.lceNAT(idxMin:end),1);
fceNATOne  = interp1(ehtmmCurves.fpe.lceNAT(idxMin:end),...
                    ehtmmCurves.fpe.fceNAT(idxMin:end),lceNATOne);
kceNATOne  = interp1(ehtmmCurves.fpe.lceNAT(idxMin:end),...
                    ehtmmCurves.fpe.kceNAT(idxMin:end),lceNATOne);


figure(figH);
    if(length(subPlotPanel)==3)
        subplot(subPlotPanel(1,1),subPlotPanel(1,2),subPlotPanel(1,3));
    end
    if(length(subPlotPanel)==4)
        subplot('Position',subPlotPanel);
    end

    plot(ehtmmCurves.fpe.lceNAT,...
         ehtmmCurves.fpe.fceNAT,...
         plotSettings.umat41.lineType,...
        'Color',umat41Color,...
        'DisplayName',[umat41Label,' $$\mathbf{f}^\mathrm{PE}$$'],...
        'LineWidth',umat41LineWidth);
    hold on;

    plot(vexatCurves.fpe.lceNAT,...
        vexatCurves.fpe.fceNAT,...
        plotSettings.umat43.lineType,...
        'Color',umat43Color,...
        'DisplayName',[umat43Label,' $$\mathbf{f}^\mathrm{PE}$$'],...
        'LineWidth',umat43LineWidth*0.5);
    hold on;

    if(contains(expData,'HL1997')==1)
        plot(keyPointsHL1997.fpe.lceNAT,...
             keyPointsHL1997.fpe.fceNAT,...
             HL1997LineType,...
             'LineWidth',0.5,...
             'MarkerSize',3,...
             'Color',[1,1,1],...
             'MarkerFaceColor',HL1997Color,...
             'DisplayName',HL1997Label);
        hold on;
    else
        %Add a dummy point that is outside of the plotting area
        %so that the legend entry is added.
        plot(-10,...
             0,...
             HL1997LineType,...
             'LineWidth',0.5,...
             'MarkerSize',3,...
             'Color',[1,1,1],...
             'MarkerFaceColor',HL1997Color,...
             'DisplayName',HL1997Label);
        hold on;

    end

    hold on;
    plot(keyPointsHL2002.fpe.lceNAT,...
         keyPointsHL2002.fpe.fceNAT,...
         HL2002LineType,...
         'LineWidth',0.5,'Color',[0,0,0],...
         'MarkerSize',3,...
         'MarkerFaceColor',HL2002Color,...
         'DisplayName',HL2002Label);
    hold on;
    plot(keyPointsVEXATFpe.lceNAT,...
         keyPointsVEXATFpe.fceNAT,...
         'x',...
         'LineWidth',0.5,'Color',[0,0,0],...
         'MarkerSize',3,...
         'MarkerFaceColor',[0,0,0],...
         'HandleVisibility','off');
    hold on;

    xright= 1.4;

    text(xright,0.3,...
         sprintf('%s%1.2f%s',...
         '$$k^{PE}_o=$$',...
         keyPointsVEXATFpe.kceNAT,...
         '$$f^M_o/\ell^M_o$$'),...
         'HorizontalAlignment','right',...
         'VerticalAlignment','top',...
         'Color',umat43Color,...
         'FontSize',6);
    hold on;

    text(xright,0.3-0.075,...
         sprintf('%s%1.2f%s',...
         '$$k^{PE}_o=$$',...
         kceNATOne,...
         '$$f^M_o/\ell^M_o$$'),...
         'HorizontalAlignment','right',...
         'VerticalAlignment','top',...
         'Color',umat41Color,...
         'FontSize',6);
    hold on;

   
    if(contains(expData,'HL2002'))
        text(xright,0.12-0.075,...
            sprintf('%s %1.4f',...
                'RMSE',umat41FpeRMSE),...
                'HorizontalAlignment','right',...
                'VerticalAlignment','top',...
                'Color',umat41Color,...
                'FontSize',6);
        hold on;
    
        text(xright,0.12,...
            sprintf('%s %1.4f',...
                'RMSE',umat43FpeRMSE),...
                'HorizontalAlignment','right',...
                'VerticalAlignment','top',...
                'Color',umat43Color,...
                'FontSize',6);
        hold on;    
    end

    box off;
    
    xlim([min(vexatCurves.fpe.lceNAT),max(vexatCurves.fpe.lceNAT)]);
    ylim(plotSettings.ylim);

    xlabel('Norm. Length ($$\ell/\ell^M_o$$)');
    ylabel('Norm. Force ($$f/f^M_o$$)');    
    title('B. Passive force length fitting $$\mathbf{f}^\mathrm{PE}$$');

    [lgdH, lgdIcons, lgdPlots, lgdTxt]=...
        legend('Location','northwest','FontSize',6);

    %[lgdH, lgdIcons, lgdPlots, lgdTxt,xDataOrig,xDataUpd] = ...
    %scaleLegendLines(0.5,lgdH, lgdIcons, lgdPlots, lgdTxt);

    legend boxoff;


