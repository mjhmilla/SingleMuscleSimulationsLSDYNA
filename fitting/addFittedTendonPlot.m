function figH= addFittedTendonPlot(figH,...
    vexatCurves,ehtmmCurves,...   
    umat41,umat43,...
    umat43QuadraticBezierCurves,subPlotPanel,plotSettings)

umat41Color = plotSettings.umat41.color;
umat43Color = plotSettings.umat43.color;

umat41Label = plotSettings.umat41.label;
umat43Label = plotSettings.umat43.label;

umat41LineWidth = plotSettings.umat41.lineWidth;
umat43LineWidth = plotSettings.umat43.lineWidth;


figure(figH);
    if(length(subPlotPanel)==3)
        subplot(subPlotPanel(1,1),subPlotPanel(1,2),subPlotPanel(1,3));
    end
    if(length(subPlotPanel)==4)
        subplot('Position',subPlotPanel);
    end
    plot(ehtmmCurves.ft.ltN,...
         ehtmmCurves.ft.ftN,...
         plotSettings.umat41.lineType,...
        'Color',umat41Color,...
        'DisplayName',[umat41Label,' $$\mathbf{f}^\mathrm{T}$$'],...
        'LineWidth',umat41LineWidth);
    hold on;
    plot(vexatCurves.ft.ltN,...
        vexatCurves.ft.ftN,...
        plotSettings.umat43.lineType,...
        'Color',umat43Color,...
        'DisplayName',[umat43Label,' $$\mathbf{f}^\mathrm{T}$$'],...
        'LineWidth',umat43LineWidth*0.5);
    hold on;
    box off;

    ltNOne41=interp1(ehtmmCurves.ft.ftN(10:end),...
                     ehtmmCurves.ft.ltN(10:end),1,"linear","extrap");
    ltNOne43=interp1(vexatCurves.ft.ftN(10:end),...
                      vexatCurves.ft.ltN(10:end),1,"linear","extrap");

    ktNOne41=interp1(ehtmmCurves.ft.ltN(10:end),...
                     ehtmmCurves.ft.ktN(10:end),ltNOne41,"linear","extrap");
    ktNOne43=interp1(vexatCurves.ft.ltN(10:end),...
                     vexatCurves.ft.ktN(10:end),ltNOne43,"linear","extrap");

    %plot(ltNOne41,1,'o','Color',umat41Color,'HandleVisibility','off');
    %hold on;
    %plot(ltNOne43,1,'o','Color',umat43Color,'HandleVisibility','off');
    %hold on;
    
%     text(1+(ltNOne41-1)*0.8,1-0.08,...
%         sprintf('%s %1.4f, %s %1.1f %s',...
%             '$$e^{T}_o$$',ltNOne41-1,'$$k^{T}_o$$',ktNOne41,'$$f^M_o/\ell^T_s$$'),...
%             'HorizontalAlignment','right',...
%             'VerticalAlignment','top',...
%             'Color',umat41Color,...
%             'FontSize',6);
%     hold on;
%     text(1+(ltNOne43-1)*0.8,1,...
%         sprintf('%s %1.4f, %s %1.1f %s',...
%         '$$e^{T}_o$$',ltNOne43-1,'$$k^{T}_o$$',ktNOne43,'$$f^M_o/\ell^T_s$$'),...
%         'HorizontalAlignment','right',...
%         'VerticalAlignment','top',...
%         'Color',umat43Color,...
%         'FontSize',6);
%     hold on;

    text(1+(ltNOne41-1)*0.8,1-0.08,...
        sprintf('%s %1.1f %s',...
            '$$k^{T}_o$$',ktNOne41,'$$f^M_o/\ell^T_s$$'),...
            'HorizontalAlignment','right',...
            'VerticalAlignment','top',...
            'Color',umat41Color,...
            'FontSize',6);
    hold on;
    text(1+(ltNOne43-1)*0.8,1,...
        sprintf('%s %1.1f %s',...
        '$$k^{T}_o$$',ktNOne43,'$$f^M_o/\ell^T_s$$'),...
        'HorizontalAlignment','right',...
        'VerticalAlignment','top',...
        'Color',umat43Color,...
        'FontSize',6);
    hold on;    

    xticks(round([1,ltNOne43],4));
    yticks(round([0,1],2));
    xlim([[1-eps,ltNOne43+eps]]);
    ylim(plotSettings.ylim);

%    [lgdH, lgdIcons, lgdPlots, lgdTxt]=...
        legend('Location','southeast','FontSize',6);
% 
%     [lgdH, lgdIcons, lgdPlots, lgdTxt,xDataOrig,xDataUpd] = ...
%         scaleLegendLines(0.5,lgdH, lgdIcons, lgdPlots, lgdTxt);    
    
    legend box off;

    xlabel('Norm. Length ($$\ell^T/\ell^T_s$$)');
    ylabel('Norm. Force ($$f^T/f^M_o$$)');
    title('B. Tendon fitting $$\mathbf{f}^\mathrm{T}$$');