function [fig,umat41Curves,umat43Curves]= addTendonFittingInfo(fig,umat41,umat43,...
    umat43QuadraticBezierCurves,umat41Color,umat43Color)

npts=100;
umat41Curves.ltN = [1:(umat41.et)/(npts-1):(1+umat41.et)]';
umat41Curves.ftN =zeros(size(umat41Curves.ltN));
umat41Curves.ktN =zeros(size(umat41Curves.ltN));

umat43Curves.ltN = [1:(umat43.et)/(npts-1):(1+umat43.et)]';
umat43Curves.ftN =zeros(size(umat43Curves.ltN));
umat43Curves.ktN =zeros(size(umat43Curves.ltN));

for i=1:1:npts
    umat41Curves.ftN(i,1)=calcFseeUmat41(...
        umat41.ltSlk*umat41Curves.ltN(i,1),...
        umat41.ltSlk,umat41.dUSEEnll,umat41.duSEEl,umat41.dFSEE0);
    umat41Curves.ftN(i,1)=umat41Curves.ftN(i,1)*(1/umat41.fceOptAT);

    umat43Curves.ftN(i,1)= ...
        calcQuadraticBezierYFcnXDerivative(umat43Curves.ltN(i,1),...
          umat43QuadraticBezierCurves.tendonForceLengthCurve,0);
end

umat41Curves.ktN = ...
    calcCentralDifferenceDataSeries(umat41Curves.ltN,umat41Curves.ftN);

umat43Curves.ktN = ...
    calcCentralDifferenceDataSeries(umat43Curves.ltN,umat43Curves.ftN);

figure(fig);
subplot(2,2,1);
    plot(umat41Curves.ltN,umat41Curves.ftN,'-','Color',umat41Color,...
        'DisplayName','umat41');
    hold on;
    plot(umat43Curves.ltN,umat43Curves.ftN,'-','Color',umat43Color,...
        'DisplayName','umat43');
    hold on;
    box off;

    ltNOne41=interp1(umat41Curves.ftN,umat41Curves.ltN,1,"linear","extrap");
    ltNOne43=interp1(umat43Curves.ftN,umat43Curves.ltN,1,"linear","extrap");

    ktNOne41=interp1(umat41Curves.ltN,umat41Curves.ktN,ltNOne41,"linear","extrap");
    ktNOne43=interp1(umat43Curves.ltN,umat43Curves.ktN,ltNOne43,"linear","extrap");

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