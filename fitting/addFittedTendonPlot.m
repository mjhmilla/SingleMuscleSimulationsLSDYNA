function [fig,umat41Curves,umat43Curves]= addFittedTendonPlot(fig,umat41,umat43,...
    umat43QuadraticBezierCurves,subPlotPanel,umat41Color,umat43Color)

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

figure(fig);
if(length(subPlotPanel)==3)
    subplot(subPlotPanel(1,1),subPlotPanel(1,2),subPlotPanel(1,3));
end
if(length(subPlotPanel)==4)
    subplot('Position',subPlotPanel);
end
    plot(umat41Curves.ft.ltN,umat41Curves.ft.ftN,'-','Color',umat41Color,...
        'DisplayName','umat41');
    hold on;
    plot(umat43Curves.ft.ltN,umat43Curves.ft.ftN,'-','Color',umat43Color,...
        'DisplayName','umat43');
    hold on;
    box off;

    ltNOne41=interp1(umat41Curves.ft.ftN,umat41Curves.ft.ltN,1,"linear","extrap");
    ltNOne43=interp1(umat43Curves.ft.ftN,umat43Curves.ft.ltN,1,"linear","extrap");

    ktNOne41=interp1(umat41Curves.ft.ltN,umat41Curves.ft.ktN,ltNOne41,"linear","extrap");
    ktNOne43=interp1(umat43Curves.ft.ltN,umat43Curves.ft.ktN,ltNOne43,"linear","extrap");

    plot(ltNOne41,1,'o','Color',umat41Color,'HandleVisibility','off');
    hold on;
    plot(ltNOne43,1,'o','Color',umat43Color,'HandleVisibility','off');
    hold on;
    text(ltNOne41,1-0.05,sprintf('%1.4f, %1.4f',ltNOne41,ktNOne41),...
            'HorizontalAlignment','left',...
            'VerticalAlignment','bottom',...
            'Color',umat41Color,...
            'FontSize',8);
    hold on;
    text(ltNOne43,1-0.075,sprintf('%1.4f, %1.4f',ltNOne43, ktNOne43),...
            'HorizontalAlignment','left',...
            'VerticalAlignment','top',...
            'Color',umat43Color,...
            'FontSize',8);
    hold on;

    legend('Location','northwest');

    xlabel('Norm. Length ($$\ell^T/\ell^T_s$$)');
    ylabel('Norm. Force ($$f^T/f^M_o$$)');
    title('Tendon Force-Length Curve');