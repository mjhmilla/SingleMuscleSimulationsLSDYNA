function errVec = calcVEXATPassiveForceLengthError(arg,umat43,...
                        keyPointsHL2002,fiberForceLengthCurve)

shiftPE = arg(1,1);
scalePE = arg(2,1);

errVec = zeros(length(keyPointsHL2002.fpe.lceNAT),1);

for i=1:1:length(keyPointsHL2002.fpe.lceNAT)
    
    lceNAT = keyPointsHL2002.fpe.lceNAT(i,1);

    lceAT = lceNAT*umat43.lceOpt;
    fibKin = calcFixedWidthPennatedFiberKinematics(lceAT,...
                                        0,...
                                        umat43.lceOpt,...
                                        umat43.penOpt);
    lce     = fibKin.fiberLength;
    alpha   = fibKin.pennationAngle;
    lceN    = lce/umat43.lceOpt; 

    fpeN = scalePE * calcQuadraticBezierYFcnXDerivative(lceN-shiftPE,...
                                            fiberForceLengthCurve,0);

    fpeNAT = fpeN*cos(alpha);

    errVec(i,1) = fpeNAT - keyPointsHL2002.fpe.fceNAT(i,1);

end

here=1;