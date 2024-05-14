function [mat156,umat41,umat43]=calcReferencePathLengths(expData,...
                                    mat156,umat41,umat43,...
                                    keyPointsHL1997,...
                                    keyPointsHL2002,...
                                    umat43QuadraticCurves)

lceNATStart = 0;

switch expData
    case 'HL1997'
        lceNATStart = keyPointsHL1997.lceNATZero;
    case 'HL2002'
        lceNATStart = keyPointsHL2002.lceNATZero;        
end

lp0Str= ['lp0',expData];

%MAT156 has no tendon
mat156.(lp0Str) = lceNATStart*mat156.lceOptAT;
mat156.lmtOptAT = mat156.lceOptAT;
mat156.lp0K1994 = mat156.lceOptAT;

%%
%umat41 (EHTMM) has a tendon
%   HL1997 & HL2002 starting lengths (max activation)
%%
lceAT = lceNATStart*umat41.lceOptAT;

fpeAT= calcFpeeUmat41(lceAT,...
                      umat41.lceOptAT,...
                      umat41.dWdes,...
                      umat41.fceOptAT,...
                      umat41.FPEE,...
                      umat41.LPEE0,...
                      umat41.nuPEE);
    
fpeNAT = fpeAT/umat41.fceOptAT;

falNAT =calcFisomUmat41(lceAT,...
            umat41.lceOptAT,...
            umat41.dWdes,...
            umat41.nuCEdes,...
            umat41.dWasc,...
            umat41.nuCEasc);

fceAT = falNAT*umat41.fceOptAT + fpeAT;

lsee = calcFseeInverseUmat41(fceAT,...
                             umat41.ltSlk,...
                             umat41.dUSEEnll,...
                             umat41.duSEEl,...
                             umat41.dFSEE0);

umat41.(lp0Str) = lceAT + lsee;

%%
%And now lmtOptAT: max activation at lceOptAT
%%
lceAT = umat41.lceOptAT;

fpeAT= calcFpeeUmat41(lceAT,...
                      umat41.lceOptAT,...
                      umat41.dWdes,...
                      umat41.fceOptAT,...
                      umat41.FPEE,...
                      umat41.LPEE0,...
                      umat41.nuPEE);

fceAT = umat41.fceOptAT;

lsee = calcFseeInverseUmat41(fceAT+fpeAT,...
                             umat41.ltSlk,...
                             umat41.dUSEEnll,...
                             umat41.duSEEl,...
                             umat41.dFSEE0);

umat41.lmtOptAT = lceAT + lsee;

%%
%5N of activation at lceOptAT
%%
lceAT = umat41.lceOptAT;

fpeAT= calcFpeeUmat41(lceAT,...
                      umat41.lceOptAT,...
                      umat41.dWdes,...
                      umat41.fceOptAT,...
                      umat41.FPEE,...
                      umat41.LPEE0,...
                      umat41.nuPEE);
    
fceAT = 5-fpeAT;

lsee = calcFseeInverseUmat41(fceAT+fpeAT,...
                             umat41.ltSlk,...
                             umat41.dUSEEnll,...
                             umat41.duSEEl,...
                             umat41.dFSEE0);

umat41.lp0K1994 = lceAT + lsee;


%%
%umat43 (VEXAT) also has a tendon and the CE is pennated
%  HL1997 & HL2002 starting lengths (max activation
%%
lceAT = lceNATStart*umat43.lceOpt;

fibKin = calcFixedWidthPennatedFiberKinematics(lceAT,...
                                    0,...
                                    umat43.lceOpt,...
                                    umat43.penOpt);

lce = fibKin.fiberLength;

alpha=fibKin.pennationAngle;

lceN = lce/umat43.lceOpt;

fpeN = umat43.scalePEE * ...
        calcQuadraticBezierYFcnXDerivative(lceN-umat43.shiftPEE,...
                  umat43QuadraticCurves.fiberForceLengthCurve,0);

fpeNAT = fpeN*cos(alpha);

flN = calcQuadraticBezierYFcnXDerivative(lceN,...
        umat43QuadraticCurves.activeForceLengthCurve, 0);

flNAT = flN*cos(alpha);

fceNAT = flNAT+fpeNAT;

etN = calcQuadraticBezierYFcnXDerivative(fceNAT,....
                umat43QuadraticCurves.tendonForceLengthInverseNormCurve,0);
et = etN*umat43.et;

umat43.(lp0Str) = lce*cos(alpha) + (1+et)*umat43.ltSlk;

%%
%Maximum activation
%%
lce = umat43.lceOpt;

fibKin = calcFixedWidthPennatedFiberKinematicsAlongTendon(...
                                    lce,...
                                    0,...
                                    umat43.lceOpt,...
                                    umat43.penOpt);

lceAT   = fibKin.fiberLengthAlongTendon;

alpha   = fibKin.pennationAngle;

lceN    = lce/umat43.lceOpt;

fpeN    = umat43.scalePEE * ...
            calcQuadraticBezierYFcnXDerivative(lceN-umat43.shiftPEE,...
                  umat43QuadraticCurves.fiberForceLengthCurve,0);

fpeNAT = fpeN*cos(alpha);

fceNAT = 1*cos(alpha);

etN = calcQuadraticBezierYFcnXDerivative(fceNAT+fpeNAT,....
                umat43QuadraticCurves.tendonForceLengthInverseNormCurve,0);
et = etN*umat43.et;

umat43.lmtOptAT = lce*cos(alpha) + (1+et)*umat43.ltSlk;

%%
%5N of activation
%%
lce = umat43.lceOpt;

fibKin = calcFixedWidthPennatedFiberKinematicsAlongTendon(...
                                    lce,...
                                    0,...
                                    umat43.lceOpt,...
                                    umat43.penOpt);

lceAT   = fibKin.fiberLengthAlongTendon;

alpha   = fibKin.pennationAngle;

lceN    = lce/umat43.lceOpt;

fpeN    = umat43.scalePEE * ...
            calcQuadraticBezierYFcnXDerivative(lceN-umat43.shiftPEE,...
                  umat43QuadraticCurves.fiberForceLengthCurve,0);

fpeNAT = fpeN*cos(alpha);

fceNAT = (5/cos(alpha))/umat43.fceOpt -fpeNAT;

etN = calcQuadraticBezierYFcnXDerivative(fceNAT+fpeNAT,....
                umat43QuadraticCurves.tendonForceLengthInverseNormCurve,0);
et = etN*umat43.et;

umat43.lp0K1994 = lce*cos(alpha) + (1+et)*umat43.ltSlk;
here=1;












