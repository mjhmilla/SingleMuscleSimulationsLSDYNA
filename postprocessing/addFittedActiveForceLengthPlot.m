%%
% SPDX-FileCopyrightText: 2024 Matthew Millard <millard.matthew@gmail.com>
%
% SPDX-License-Identifier: MIT
%
%%
function [fig,umat41Curves,umat43Curves] = ...
    addFittedActiveForceLengthPlot(fig,umat41,umat43,...
                                    umat43QuadraticBezierCurves,...
                                    umat41Curves,umat43Curves,...
                                    subPlotPanel,umat41Color,umat43Color,...
                                    expKeyPointsFal,lineType)


lengthA = min(expKeyPointsFal.lmt);
lengthB = max(expKeyPointsFal.lmt);

npts = 50;

umat41Curves.fal.lceAT = [lengthA:(lengthB-lengthA)/(npts-1):(lengthB)]';
umat41Curves.fal.lceAT = umat41Curves.fal.lceAT;

umat41Curves.fal.falAT = zeros(size(umat41Curves.fal.lceAT));
umat41Curves.fal.fpeAT = zeros(size(umat41Curves.fal.lceAT));
umat41Curves.fal.lt    = zeros(size(umat41Curves.fal.lceAT));
umat41Curves.fal.lmt    = zeros(size(umat41Curves.fal.lceAT));
umat41Curves.fal.fmt    = zeros(size(umat41Curves.fal.lceAT));

umat43Curves.fal.lceAT = [lengthA:(lengthB-lengthA)/(npts-1):(lengthB)]';
umat43Curves.fal.lceAT = umat43Curves.fal.lceAT;

umat43Curves.fal.falAT = zeros(size(umat43Curves.fal.lceAT));
umat43Curves.fal.fpeAT = zeros(size(umat41Curves.fal.lceAT));
umat43Curves.fal.lt    = zeros(size(umat41Curves.fal.lceAT));
umat43Curves.fal.lmt    = zeros(size(umat41Curves.fal.lceAT));
umat43Curves.fal.fmt    = zeros(size(umat41Curves.fal.lceAT));


for i=1:1:length(umat41Curves.fal.lceAT)

    %Evaluate EHTM
    lceAT41 = umat41Curves.fal.lceAT(i,1);
    falNAT41 = calcFisomUmat41(lceAT41,umat41.lceOptAT,umat41.dWdes,umat41.nuCEdes, ...
        umat41.dWasc, umat41.nuCEasc);
    falAT41 = falNAT41*umat41.fceOptAT;
    fpeAT41 = calcFpeeUmat41(lceAT41, umat41.lceOptAT, umat41.dWdes,...
                            umat41.fceOptAT,umat41.FPEE,umat41.LPEE0,...
                            umat41.nuPEE);

    fmtAT41= falAT41 + fpeAT41;
    
    lt41 = calcFseeInverseUmat41(fmtAT41,umat41.ltSlk,umat41.dUSEEnll,...
                                umat41.duSEEl,umat41.dFSEE0);
    lmtAT41 = lceAT41+lt41;
    
    umat41Curves.fal.lceAT(i,1) = lceAT41;
    umat41Curves.fal.falAT(i,1) = falAT41;
    umat41Curves.fal.fpeAT(i,1) = fpeAT41;
    umat41Curves.fal.lt(i,1)    = lt41;
    umat41Curves.fal.lmt(i,1)   = lmtAT41;
    umat41Curves.fal.fmt(i,1)   = fmtAT41;

    %Evaluate umat43
    lceAT43 = umat43Curves.fal.lceAT(i,1);

    fibKin = calcFixedWidthPennatedFiberKinematics(...
                lceAT43,0,umat43.lceOpt,umat43.penOpt);    

    lce43  = fibKin.fiberLength;
    alpha43 = fibKin.pennationAngle;
    
    lceN43 = lce43/umat43.lceOpt;

    falN43 = calcQuadraticBezierYFcnXDerivative(lceN43,...
                umat43QuadraticBezierCurves.activeForceLengthCurve,0);

    fpeN43 = calcQuadraticBezierYFcnXDerivative(lceN43-umat43.shiftPEE,...
                umat43QuadraticBezierCurves.fiberForceLengthCurve,0);
    fpeN43  = fpeN43*umat43.scalePEE;

    fmtNAT43  = (falN43+fpeN43)*cos(alpha43);
    
    ltN43 = calcQuadraticBezierYFcnXDerivative(fmtNAT43,...
                umat43QuadraticBezierCurves.tendonForceLengthInverseCurve,0);

    lmt43 = lce43*cos(alpha43) + ltN43*umat43.ltSlk;
    
    umat43Curves.fal.lceAT(i,1) = lceAT43;
    umat43Curves.fal.falAT(i,1) = falN43*cos(alpha43)*umat43.fceOpt;
    umat43Curves.fal.fpeAT(i,1) = fpeN43*cos(alpha43)*umat43.fceOpt;
    umat43Curves.fal.lt(i,1)    = ltN43*umat43.ltSlk;
    umat43Curves.fal.lmt(i,1)   = lmt43;
    umat43Curves.fal.fmt(i,1)   = fmtNAT43*umat43.fceOpt;    
end

figure(fig);
subplot(subPlotPanel(1,1),subPlotPanel(1,2),subPlotPanel(1,3));

plot(umat41Curves.fal.lceAT(:,1),...
     umat41Curves.fal.falAT(:,1),...
     lineType,'Color',umat41Color.*0.5+[1,1,1].*0.5,...
    'DisplayName','umat41');
hold on;
plot(umat41Curves.fal.lceAT(:,1),...
     umat41Curves.fal.fmt(:,1),...
     lineType,'Color',umat41Color.*0.5+[1,1,1].*0.5,...
    'DisplayName','umat41');
hold on;

plot(umat43Curves.fal.lceAT(:,1),...
     umat43Curves.fal.falAT(:,1),...
     lineType,'Color',umat43Color,...
    'DisplayName','umat43');
hold on;
plot(umat43Curves.fal.lceAT(:,1),...
     umat43Curves.fal.fmt(:,1),...
     lineType,'Color',umat43Color,...
    'DisplayName','umat43');
hold on;
box off;

assert(abs(umat43.ltSlk-umat41.ltSlk)<sqrt(eps));

plot(expKeyPointsFal.lmt,expKeyPointsFal.fmt,'o','Color',[0,0,0],...
     'MarkerFaceColor',[1,1,1].*0.5,'DisplayName',expKeyPointsFal.name);
hold on;

legend('Location','southwest');

xlabel('Length ($$\ell^{P}-\ell^T_s$$)');
ylabel('Force ($$f^T$$)');
title('Active Force-Length Curve');
