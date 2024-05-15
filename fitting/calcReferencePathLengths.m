function [mat156,umat41,umat43]=calcReferencePathLengths(expData,...
                                    mat156,umat41,umat43,...
                                    keyPointsHL1997,...
                                    keyPointsHL2002,...
                                    umat43QuadraticCurves,... 
                                    vexatCurves,...
                                    ehtmmCurves,...
                                    modeReferenceLength,...
                                    flag_addTendonLengthChangeToMat156)

switch expData
    case 'HL1997'
        idx = kmeans(keyPointsHL1997.fpe.f,keyPointsHL1997.fpe.clusters);
        fpeExp.lp = zeros(keyPointsHL1997.fpe.clusters,1);
        fpeExp.fmt = zeros(keyPointsHL1997.fpe.clusters,1);
        for i=1:1:keyPointsHL1997.fpe.clusters
            cIdx = find(idx == i);
            fpeExp.lp(i,1)  = mean(keyPointsHL1997.fpe.l(cIdx));
            fpeExp.fmt(i,1) = mean(keyPointsHL1997.fpe.f(cIdx));
        end
        [val,sIdx]=sort(fpeExp.fmt);
        fpeExp.lp=fpeExp.lp(sIdx);        
        fpeExp.fmt=fpeExp.fmt(sIdx);

        fpeExp.lp =keyPointsHL1997.nms.l;
        fpeExp.fmt=keyPointsHL1997.nms.f;

        fpeExp.lpN = fpeExp.lp ./ keyPointsHL1997lceOpt;
        fpeExp.fmtN = fpeExp.fmt ./ keyPointsHL1997.fceOpt;
        

    case 'HL2002'
        idx = kmeans(keyPointsHL2002.fpe.f,keyPointsHL2002.fpe.clusters);
        fpeExp.lp = zeros(keyPointsHL2002.fpe.clusters,1);
        fpeExp.fmt = zeros(keyPointsHL2002.fpe.clusters,1);
        for i=1:1:keyPointsHL2002.fpe.clusters
            cIdx = find(idx == i);
            fpeExp.lp(i,1)  = mean(keyPointsHL2002.fpe.l(cIdx));
            fpeExp.fmt(i,1) = mean(keyPointsHL2002.fpe.f(cIdx));
        end
        [val,sIdx]=sort(fpeExp.fmt);
        fpeExp.lp=fpeExp.lp(sIdx);        
        fpeExp.fmt=fpeExp.fmt(sIdx); 

        fpeExp.lp   = fpeExp.lp.*keyPointsHL2002.nms.l;
        fpeExp.fmt  = fpeExp.fmt.*keyPointsHL2002.nms.f;
        fpeExp.lpN  = fpeExp.lp ./ keyPointsHL2002.lceOpt;
        fpeExp.fmtN = fpeExp.fmt ./ keyPointsHL2002.fceOpt;
        
end

[fpeMaxN,idx]    = max(fpeExp.fmtN);
fpeExp.fit.lpN   = fpeExp.lpN(idx);
fpeExp.fit.fmtN  = fpeMaxN;


%From the 9mm/s 9mm stretch trial
% fpe.lpAT   = 0.009;   %target values
% fpe.fmtAT  = 6.33634; %target values
% fpe.mat156 = 0;
% fpe.umat41 = 9.37132;
% fpe.umat43 = 9.42862;



lceNATStart = 0;
switch expData
    case 'HL1997'
        lceNATStart = keyPointsHL1997.lceNATZero;
    case 'HL2002'
        lceNATStart = keyPointsHL2002.lceNATZero;        
end

lp0Str= ['lp0',expData];

%MAT156 has no tendon
switch modeReferenceLength
    case 0
        mat156.(lp0Str) = lceNATStart*mat156.lceOptAT;
    case 1
        idxMin = find(vexatCurves.fpe.fceNAT>0.05);
        

        lceNAT = interp1(vexatCurves.fpe.fceNAT(idxMin:end),...
                         vexatCurves.fpe.lceNAT(idxMin:end),...
                         fpeExp.fit.fmtN);
        lceAT = lceNAT*mat156.lceOptAT;
        dlt = 0;
        if(flag_addTendonLengthChangeToMat156==1)
            etN = calcQuadraticBezierYFcnXDerivative(fpeExp.fit.fmtN,...
                    umat43QuadraticCurves.tendonForceLengthInverseNormCurve,0);
            et = etN*umat43.et;
            dlt = et*umat43.ltSlk;
        end


        mat156.(lp0Str) = lceAT+dlt;
end
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


switch modeReferenceLength
    case 0
        umat41.(lp0Str) = lceAT + lsee;
    case 1
        umat41.(lp0Str) = nan;
end

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



switch modeReferenceLength
    case 0
        umat43.(lp0Str) = lce*cos(alpha) + (1+et)*umat43.ltSlk;
    case 1
        umat41.(lp0Str) = nan;
end


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












