function figH= addFittedTendonPlot(figH,umat41,umat43,...
    umat43QuadraticBezierCurves,subPlotPanel,plotSettings)

umat41Color = plotSettings.umat41.color;
umat43Color = plotSettings.umat43.color;

umat41Label = plotSettings.umat41.label;
umat43Label = plotSettings.umat43.label;

umat41LineWidth = plotSettings.umat41.lineWidth;
umat43LineWidth = plotSettings.umat43.lineWidth;


npts=100;
umat41Curves.ft.ltN = [1:(umat41.et)/(npts-1):(1+umat41.et)]';
umat41Curves.ft.ftN =zeros(size(umat41Curves.ft.ltN));
umat41Curves.ft.ktN =zeros(size(umat41Curves.ft.ltN));

umat43Curves.ft.ltN = [1:(umat43.et)/(npts-1):(1+umat43.et)]';
umat43Curves.ft.ftN =zeros(size(umat43Curves.ft.ltN));
umat43Curves.ft.ktN =zeros(size(umat43Curves.ft.ltN));

for i=1:1:npts
    umat41Curves.ft.ftN(i,1)=calcFseeUmat41(...
        umat41.ltSlk*umat41Curves.ft.ltN(i,1),...
        umat41.ltSlk,umat41.dUSEEnll,umat41.duSEEl,umat41.dFSEE0);
    umat41Curves.ft.ftN(i,1)=umat41Curves.ft.ftN(i,1)*(1/umat41.fceOptAT);

    umat43Curves.ft.ftN(i,1)= ...
        calcQuadraticBezierYFcnXDerivative(umat43Curves.ft.ltN(i,1),...
          umat43QuadraticBezierCurves.tendonForceLengthCurve,0);
end

umat41Curves.ft.ktN = ...
    calcCentralDifferenceDataSeries(umat41Curves.ft.ltN,umat41Curves.ft.ftN);

umat43Curves.ft.ktN = ...
    calcCentralDifferenceDataSeries(umat43Curves.ft.ltN,umat43Curves.ft.ftN);

figure(figH);
    if(length(subPlotPanel)==3)
        subplot(subPlotPanel(1,1),subPlotPanel(1,2),subPlotPanel(1,3));
    end
    if(length(subPlotPanel)==4)
        subplot('Position',subPlotPanel);
    end
    plot(umat41Curves.ft.ltN,...
         umat41Curves.ft.ftN,...
         plotSettings.umat41.lineType,...
        'Color',umat41Color,...
        'DisplayName',[umat41Label,' $$\mathbf{f}^\mathrm{T}$$'],...
        'LineWidth',umat41LineWidth);
    hold on;
    plot(umat43Curves.ft.ltN,...
        umat43Curves.ft.ftN,...
        plotSettings.umat43.lineType,...
        'Color',umat43Color,...
        'DisplayName',[umat43Label,' $$\mathbf{f}^\mathrm{T}$$'],...
        'LineWidth',umat43LineWidth*0.5);
    hold on;
    box off;

    ltNOne41=interp1(umat41Curves.ft.ftN,umat41Curves.ft.ltN,1,"linear","extrap");
    ltNOne43=interp1(umat43Curves.ft.ftN,umat43Curves.ft.ltN,1,"linear","extrap");

    ktNOne41=interp1(umat41Curves.ft.ltN,umat41Curves.ft.ktN,ltNOne41,"linear","extrap");
    ktNOne43=interp1(umat43Curves.ft.ltN,umat43Curves.ft.ktN,ltNOne43,"linear","extrap");

    %plot(ltNOne41,1,'o','Color',umat41Color,'HandleVisibility','off');
    %hold on;
    %plot(ltNOne43,1,'o','Color',umat43Color,'HandleVisibility','off');
    %hold on;
    
    text(1+(ltNOne41-1)*0.8,1-0.075,...
        sprintf('%s %1.4f, %s %1.1f %s',...
            '$$e^{T}_o$$',ltNOne41-1,'$$k^{T}_o$$',ktNOne41,'$$f^M_o/\ell^T_s$$'),...
            'HorizontalAlignment','right',...
            'VerticalAlignment','top',...
            'Color',umat41Color,...
            'FontSize',6);
    hold on;
    text(1+(ltNOne43-1)*0.8,1,...
        sprintf('%s %1.4f, %s %1.1f %s',...
        '$$e^{T}_o$$',ltNOne43-1,'$$k^{T}_o$$',ktNOne43,'$$f^M_o/\ell^T_s$$'),...
        'HorizontalAlignment','right',...
        'VerticalAlignment','top',...
        'Color',umat43Color,...
        'FontSize',6);
    hold on;

    xticks(round([1,ltNOne43],4));
    yticks(round([0,1],2));
    xlim([[1-eps,ltNOne43+eps]]);
    ylim([0-eps,1+eps]);

%    [lgdH, lgdIcons, lgdPlots, lgdTxt]=...
        legend('Location','southeast','FontSize',6);
% 
%     [lgdH, lgdIcons, lgdPlots, lgdTxt,xDataOrig,xDataUpd] = ...
%         scaleLegendLines(0.5,lgdH, lgdIcons, lgdPlots, lgdTxt);    
    
    legend box off;

    xlabel('Norm. Length ($$\ell^T/\ell^T_s$$)');
    ylabel('Norm. Force ($$f^T/f^M_o$$)');
    title('C. Tendon force length fitting $$\mathbf{f}^\mathrm{T}$$');