function [fig,umat41Curves,umat43Curves] = ...
    addPassiveForceLengthFittingInfo(fig,umat41,umat43,...
                                    umat43QuadraticBezierCurves,...
                                    umat41Curves,umat43Curves,...
                                    umat41Color,umat43Color,...
                                    expKeyPointsFpe,expDataFpe)

npts=100;

lpeATZero = 0.9;
lpeATOne  = 1.36;

umat41Curves.lceNAT = [lpeATZero:(lpeATOne-lpeATZero)/(npts-1):(lpeATOne)]';
umat41Curves.lceNAT_dltN= umat41Curves.lceNAT;
umat41Curves.fpeNAT = zeros(size(umat41Curves.lceNAT));
umat41Curves.kpeNAT = zeros(size(umat41Curves.lceNAT));

umat43Curves.lceNAT = [lpeATZero:(lpeATOne-lpeATZero)/(npts-1):(lpeATOne)]';
umat43Curves.lceNAT_dltN = umat43Curves.lceNAT; 
umat43Curves.lceN   = zeros(size(umat43Curves.lceNAT));
umat43Curves.fpeNAT = zeros(size(umat43Curves.lceNAT));
umat43Curves.fpeN   = zeros(size(umat43Curves.lceNAT));

umat43Curves.kpeNAT = zeros(size(umat43Curves.lceNAT));

for i=1:1:npts
    %
    % umat41
    %
    umat41Curves.fpeNAT(i,1)= ...
        calcFpeeUmat41( umat41Curves.lceNAT(i,1)*umat41.lceOptAT,...
                        umat41.lceOptAT,...
                        umat41.dWdes,...
                        umat41.fceOptAT,...
                        umat41.FPEE,...
                        umat41.LPEE0,...
                        umat41.nuPEE);
    umat41Curves.fpeNAT(i,1) = umat41Curves.fpeNAT(i,1)/(umat41.fceOptAT);

    lsee = calcFseeInverseUmat41(umat41Curves.fpeNAT(i,1)*umat41.fceOptAT,...
               umat41.ltSlk,umat41.dUSEEnll,umat41.duSEEl,umat41.dFSEE0);

    umat41Curves.fpeNAT_dltN(i,1) = umat41Curves.fpeNAT(i,1) ...
        + (lsee - umat41.ltSlk)/umat41.lceOptAT;

    %
    % umat43
    %    
    lceNAT = umat43Curves.lceNAT(i,1);
    fibKin = calcFixedWidthPennatedFiberKinematics(lceNAT*umat43.lceOpt, 0, ...
                                    umat43.lceOpt,umat43.penOpt);
    umat43Curves.lceN(i,1) = fibKin.fiberLength/umat43.lceOpt;
    alpha= fibKin.pennationAngle;

    umat43Curves.fpeN(i,1)= ...
        calcQuadraticBezierYFcnXDerivative(umat43Curves.lceN(i,1)-umat43.shiftPEE,...
          umat43QuadraticBezierCurves.fiberForceLengthCurve,0);
    umat43Curves.fpeN(i,1)=umat43Curves.fpeN(i,1).*umat43.scalePEE;

    umat43Curves.fpeNAT(i,1) = umat43Curves.fpeN(i,1)*cos(alpha);

    ltN = calcQuadraticBezierYFcnXDerivative(umat43Curves.fpeNAT(i,1),...
          umat43QuadraticBezierCurves.tendonForceLengthInverseCurve,0);
    dltN = ltN - 1;
    umat43Curves.lceNAT_dltN(i,1) = lceNAT ...
        + (dltN*umat43.ltSlk)/umat43.lceOpt;

end

umat41Curves.kpeNAT = ...
    calcCentralDifferenceDataSeries(umat41Curves.lceNAT,umat41Curves.fpeNAT);

umat43Curves.kpeNAT = ...
    calcCentralDifferenceDataSeries(umat43Curves.lceNAT,umat43Curves.fpeNAT);

figure(fig);
subplot(2,2,2);
    plot(umat41Curves.lceNAT_dltN,umat41Curves.fpeNAT,'-','Color',umat41Color,...
        'DisplayName','umat41');
    hold on;
    plot(umat43Curves.lceNAT_dltN,umat43Curves.fpeNAT,'-','Color',umat43Color,...
        'DisplayName','umat43');
    hold on;
    box off;

    plot(expDataFpe.lmtNAT,expDataFpe.fmtNAT,'-','Color',[0,0,0],...
         'DisplayName',expDataFpe.name);
    hold on;
    plot(expKeyPointsFpe.lmtNAT,expKeyPointsFpe.fmtNAT,'o','Color',[1,1,1].*0.5,...
         'MarkerFaceColor',[1,1,1].*0.5,'DisplayName',expDataFpe.name);
    hold on;

    idxMin41 = find(umat41Curves.fpeNAT>0.01,1);
    lceNATOne41=interp1(umat41Curves.fpeNAT(idxMin41:end),...
                        umat41Curves.lceNAT_dltN(idxMin41:end),1,"linear","extrap");

    idxMin43 = find(umat43Curves.fpeNAT>0.01,1);
    lceNATOne43=interp1(umat43Curves.fpeNAT(idxMin43:end),...
                        umat43Curves.lceNAT_dltN(idxMin43:end),1,"linear","extrap");

    kpeNATOne41=interp1(umat41Curves.lceNAT_dltN(idxMin41:end),...
                        umat41Curves.kpeNAT(idxMin41:end),lceNATOne41,"linear","extrap");

    kpeNATOne43=interp1(umat43Curves.lceNAT_dltN(idxMin43:end),...
                        umat43Curves.kpeNAT(idxMin43:end),lceNATOne43,"linear","extrap");

    plot(lceNATOne41,1,'o','Color',umat41Color,'HandleVisibility','off');
    hold on;
    plot(lceNATOne43,1,'o','Color',umat43Color,'HandleVisibility','off');
    hold on;
    text(lceNATOne41,1-0.05,sprintf('%1.4f, %1.4f',lceNATOne41,kpeNATOne41),...
            'HorizontalAlignment','left',...
            'VerticalAlignment','bottom',...
            'Color',umat41Color,...
            'FontSize',8);
    hold on;
    text(lceNATOne43,1-0.075,sprintf('%1.4f, %1.4f',lceNATOne43, kpeNATOne43),...
            'HorizontalAlignment','left',...
            'VerticalAlignment','top',...
            'Color',umat43Color,...
            'FontSize',8);
    hold on;

    legend('Location','northwest');

    xlabel('Norm. Length ($$\ell^M/\ell^M_o$$)');
    ylabel('Norm. Force ($$f^M/f^M_o$$)');
    title('Passive Force-Length Curve');