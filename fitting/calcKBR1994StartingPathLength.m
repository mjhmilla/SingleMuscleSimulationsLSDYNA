function [mat156,umat41,umat43]=calcKBR1994StartingPathLength(...
                                    mat156,umat41,umat43,...
                                    umat43QuadraticCurves,... 
                                    vexatCurves)



%KRB1994 takes place at lceN=1 under 5 N of tension

%Rigid tendon: straightforward
mat156.lp0K1994 = mat156.lceOptAT;

fceAT = 5;
fceNAT = fceAT/mat156.fceOptAT;

fpeNAT = interp1(vexatCurves.fpe.lceNAT,...
                 vexatCurves.fpe.fceNAT,...
                 1);
fpeNAT = fpeNAT*(mat156.lceOpt/mat156.lceOptAT);

falNAT = interp1(vexatCurves.fl.lceNAT,...
                 vexatCurves.fl.fceNAT,...
                 1);
falNAT = falNAT*(mat156.lceOpt/mat156.lceOptAT);

actMat156 = (fceNAT-fpeNAT)/falNAT;

assert(actMat156 >= 0 && actMat156 <= 1,...
        'Error: mat156 KBR1994 activation not [0,1]');
fprintf('KBR1994\n');
fprintf('\t%1.4e\tfpeNAT (mat156)\n',fpeNAT);
%%
%umat41 (EHTMM) has a tendon
%%

lceAT = umat41.lceOptAT;

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

fceNAT = 5/umat41.fceOptAT;
actUmat41 = (fceNAT - fpeNAT)/falNAT;

assert(actUmat41 >= 0 && actUmat41 <= 1,...
        'Error: umat41 KBR1994 activation not [0,1]');
fprintf('\t%1.4e\tfpeNAT (umat41)\n',fpeNAT);


lsee = calcFseeInverseUmat41(fceNAT*umat41.fceOptAT,...
                             umat41.ltSlk,...
                             umat41.dUSEEnll,...
                             umat41.duSEEl,...
                             umat41.dFSEE0);

umat41.lp0K1994 = lceAT + lsee;


%%
%umat43 (VEXAT) has a tendon, titin, and is pennated
%%

lceAT = umat43.lceOptAT;

fibKin = calcFixedWidthPennatedFiberKinematics(lceAT,...
                                    0,...
                                    umat43.lceOpt,...
                                    umat43.penOpt);

lce = fibKin.fiberLength;
alpha=fibKin.pennationAngle;

lceN = lce/umat43.lceOpt;
lceNAT = lceAT/umat43.lceOpt;

idxMin = find(vexatCurves.fpe.fceNAT>0.001);        
fpeNAT = interp1(vexatCurves.fpe.lceNAT(idxMin:end),...
                 vexatCurves.fpe.fceNAT(idxMin:end),...                 
                 lceNAT);

flN = calcQuadraticBezierYFcnXDerivative(lceN,...
        umat43QuadraticCurves.activeForceLengthCurve, 0);

falNAT = flN*cos(alpha);

fceNAT = (5/umat43.fceOpt)*cos(umat43.penOpt);

actUmat43  = (fceNAT-fpeNAT)/falNAT;

assert(actUmat43 >= 0 && actUmat43 <= 1,...
        'Error: umat43 KBR1994 activation not [0,1]');
fprintf('\t%1.4e\tfpeNAT (umat43)\n',fpeNAT);


fceNAT      = falNAT+fpeNAT;

etN = calcQuadraticBezierYFcnXDerivative(fceNAT,....
                umat43QuadraticCurves.tendonForceLengthInverseNormCurve,0);
et = etN*umat43.et;

umat43.lp0K1994 = lceAT + (1+et)*umat43.ltSlk;












