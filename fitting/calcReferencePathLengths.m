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
        idx = kmeans(keyPointsHL1997.fpe.fceNAT,...
                     keyPointsHL1997.fpe.clusters);
        fpeExp.lceNAT  = zeros(keyPointsHL1997.fpe.clusters,1);
        fpeExp.fceNAT  = zeros(keyPointsHL1997.fpe.clusters,1);
        fpeExp.l       = zeros(keyPointsHL1997.fpe.clusters,1);
        fpeExp.f       = zeros(keyPointsHL1997.fpe.clusters,1);
        
        for i=1:1:keyPointsHL1997.fpe.clusters
            cIdx = find(idx == i);
            fpeExp.lceNAT(i,1)  = mean(keyPointsHL1997.fpe.lceNAT(cIdx));
            fpeExp.fceNAT(i,1)  = mean(keyPointsHL1997.fpe.fceNAT(cIdx));
            fpeExp.l(i,1)       = mean(keyPointsHL1997.fpe.l(cIdx));
            fpeExp.f(i,1)       = mean(keyPointsHL1997.fpe.f(cIdx));
        end
        [val,sIdx]=sort(fpeExp.fceNAT);
        fpeExp.lceNAT=fpeExp.lceNAT(sIdx);        
        fpeExp.fceNAT=fpeExp.fceNAT(sIdx);
        fpeExp.l=fpeExp.l(sIdx).*keyPointsHL1997.nms.l;        
        fpeExp.f=fpeExp.f(sIdx).*keyPointsHL1997.nms.f;
       
    case 'HL2002'
        idx = kmeans(keyPointsHL2002.fpe.fceNAT,...
                     keyPointsHL2002.fpe.clusters);

        fpeExp.lceNAT  = zeros(keyPointsHL2002.fpe.clusters,1);
        fpeExp.fceNAT  = zeros(keyPointsHL2002.fpe.clusters,1);
        fpeExp.l       = zeros(keyPointsHL2002.fpe.clusters,1);
        fpeExp.f       = zeros(keyPointsHL2002.fpe.clusters,1);        
        for i=1:1:keyPointsHL2002.fpe.clusters
            cIdx = find(idx == i);
            fpeExp.lceNAT(i,1)  = mean(keyPointsHL2002.fpe.lceNAT(cIdx));
            fpeExp.fceNAT(i,1) = mean(keyPointsHL2002.fpe.fceNAT(cIdx));
            fpeExp.l(i,1)  = mean(keyPointsHL2002.fpe.l(cIdx));
            fpeExp.f(i,1) = mean(keyPointsHL2002.fpe.f(cIdx));
        end
        [val,sIdx]    = sort(fpeExp.fceNAT);
        fpeExp.lceNAT = fpeExp.lceNAT(sIdx);        
        fpeExp.fceNAT = fpeExp.fceNAT(sIdx); 
        fpeExp.l      = fpeExp.l(sIdx).*keyPointsHL2002.nms.l;        
        fpeExp.f      = fpeExp.f(sIdx).*keyPointsHL2002.nms.f; 
end

[fpeMaxN,idx]       = max(fpeExp.fceNAT);
fpeExp.fit.lceNAT   = fpeExp.lceNAT(idx);
fpeExp.fit.fceNAT   = fpeExp.fceNAT(idx);
fpeExp.fit.l        = fpeExp.l(idx);
fpeExp.fit.f        = fpeExp.f(idx);


%From the 9mm/s 9mm stretch trial
% fpe.lpAT   = 0.009;   %target values
% fpe.fmtAT  = 6.33634; %target values
% fpe.mat156 = 0;
% fpe.umat41 = 9.37132;
% fpe.umat43 = 9.42862;



lceATStart = 0;
switch expData
    case 'HL1997'
        lceATStart = keyPointsHL1997.lceNATZero*keyPointsHL1997.lceOpt;
    case 'HL2002'
        lceATStart = keyPointsHL2002.lceNATZero*keyPointsHL2002.lceOpt;        
end

lp0Str= ['lp0',expData];
lp0StrA= ['lpA',expData];
lp0StrB= ['lpB',expData];

%MAT156 has no tendon
%switch modeReferenceLength
%    case 0
        
mat156.(lp0StrA) = lceATStart;
%    case 1

idxMin = find(vexatCurves.fecm.fceNAT>0.01);        
lceNAT = interp1(vexatCurves.fecm.fceNAT(idxMin:end) ...
               + vexatCurves.f2.fceNAT(idxMin:end),...
                 vexatCurves.fecm.lceNAT(idxMin:end),...
                 fpeExp.fit.fceNAT);
lceAT = lceNAT*mat156.lceOptAT;
dlt = 0;
if(flag_addTendonLengthChangeToMat156==1)
    etN = calcQuadraticBezierYFcnXDerivative(fpeExp.fit.fceNAT,...
            umat43QuadraticCurves.tendonForceLengthInverseNormCurve,0);
    et = etN*umat43.et;
    dlt = et*umat43.ltSlk;
end

mat156.(lp0StrB) = lceAT+dlt - fpeExp.fit.l;

%end
mat156.(lp0Str) = 0.5*(mat156.(lp0StrA)+mat156.(lp0StrB));

mat156.lmtOptAT = mat156.lceOptAT;
mat156.lp0K1994 = mat156.lceOptAT;

%%
%umat41 (EHTMM) has a tendon
%   HL1997 & HL2002 starting lengths (max activation)
%%
lceAT = lceATStart;

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


%switch modeReferenceLength
%    case 0
umat41.(lp0StrA) = lceAT + lsee;
%    case 1

lceAT = calcFpeeInverseUmat41(fpeExp.fit.f,...
                      umat41.lceOptAT,...
                      umat41.dWdes,...
                      umat41.fceOptAT,...
                      umat41.FPEE,...
                      umat41.LPEE0,...
                      umat41.nuPEE);

lsee = calcFseeInverseUmat41(fpeExp.fit.f,...
                        umat41.ltSlk,...
                        umat41.dUSEEnll,...
                        umat41.duSEEl,...
                        umat41.dFSEE0);

umat41.(lp0StrB)=lceAT+lsee - fpeExp.fit.l;

umat41.(lp0Str) = 0.5*(umat41.(lp0StrA)+umat41.(lp0StrB));

%end

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
lceAT = lceATStart;

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



%switch modeReferenceLength
%    case 0
umat43.(lp0StrA) = lce*cos(alpha) + (1+et)*umat43.ltSlk;
%    case 1


%Use pre-calculated values along the tendon 
idxMin = find(vexatCurves.fecm.fceNAT > 0.01,1,'first');
lceNAT = interp1(vexatCurves.fecm.fceNAT(idxMin:end) ...
               + vexatCurves.f2.fceNAT(idxMin:end),...
                 vexatCurves.fecm.lceNAT(idxMin:end),...
                 fpeExp.fit.fceNAT);


idxMin = find(vexatCurves.ft.ftN > 0.01,1,'first');
ltN    = interp1(vexatCurves.ft.ftN(idxMin:end),...
                 vexatCurves.ft.ltN(idxMin:end),...
                 fpeExp.fit.fceNAT);
        
umat43.(lp0StrB) = lceNAT*umat43.lceOpt+ltN*umat43.ltSlk-fpeExp.fit.l;
%end

umat43.(lp0Str) = 0.5*(umat43.(lp0StrA)+umat43.(lp0StrB)); 

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












