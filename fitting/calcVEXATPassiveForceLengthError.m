%%
% SPDX-FileCopyrightText: 2024 Matthew Millard <millard.matthew@gmail.com>
%
% SPDX-License-Identifier: MIT
%
%%
function errVec = calcVEXATPassiveForceLengthError(arg,umat43,...
                        keyPointsHL2002,keyPointsHL1997,...
                        fiberForceLengthCurve, fitMode)



if(fitMode==1)
    shiftPEE = arg(1,1);
    scalePEE = arg(2,1);
    errVec = zeros(length(keyPointsHL2002.fpe.umat43.lceNAT),1);
    
    for i=1:1:length(keyPointsHL2002.fpe.umat43.lceNAT)
        
        lceNAT = keyPointsHL2002.fpe.umat43.lceNAT(i,1);
    
        lceAT = lceNAT*umat43.lceOpt;
        fibKin = calcFixedWidthPennatedFiberKinematics(lceAT,...
                                            0,...
                                            umat43.lceOpt,...
                                            umat43.penOpt);
        lce     = fibKin.fiberLength;
        alpha   = fibKin.pennationAngle;
        lceN    = lce/umat43.lceOpt; 
    
        fpeN = scalePEE * calcQuadraticBezierYFcnXDerivative(lceN-shiftPEE,...
                                                fiberForceLengthCurve,0);
    
        fpeNAT = fpeN*cos(alpha);
    
        errVec(i,1) = fpeNAT - keyPointsHL2002.fpe.umat43.fceNAT(i,1);
    
    end
end

if(fitMode==2)
    shiftPEE = arg(1,1);
    scalePEE = umat43.scalePEE;
    %1. Evaluate the length and force of the +4 mm point
    k = kmeans(keyPointsHL1997.fpe.umat43.lceNAT,...
               keyPointsHL1997.fpe.clusters);
    meanLceNAT = zeros(max(k),1);
    meanFceNAT = zeros(max(k),1);
    for i=1:1:max(k)
        idx = find(k==i);
        meanLceNAT(i,1) = mean(keyPointsHL1997.fpe.umat43.lceNAT(idx,1));
        meanFceNAT(i,1) = mean(keyPointsHL1997.fpe.umat43.fceNAT(idx,1));
    end
    [lceNAT1,idx1] =max(meanLceNAT);
    fceNAT1 = meanFceNAT(idx1);

    %2. Evaluate the pennation model
    lceAT1 = lceNAT1*umat43.lceOpt;
    fibKin = calcFixedWidthPennatedFiberKinematics(lceAT1,...
                                        0,...
                                        umat43.lceOpt,...
                                        umat43.penOpt);
    lce1     = fibKin.fiberLength;
    alpha1   = fibKin.pennationAngle;
    lceN1    = lce1/umat43.lceOpt;     

    %3. Evaluate the curve value
    fpeN = scalePEE * calcQuadraticBezierYFcnXDerivative(lceN1-shiftPEE,...
                                            fiberForceLengthCurve,0);

    fpeNAT = fpeN*cos(alpha1);

    errVec = fpeNAT - fceNAT1;
end
here=1;