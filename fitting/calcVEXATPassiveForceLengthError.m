function errVec = calcVEXATPassiveForceLengthError(arg,umat43,...
                        keyPointsHL2002,fiberForceLengthCurve,...
                        tendonForceLengthInverseNormCurve)

shiftPE = arg(1,1);
scalePE = arg(2,1);


errVec = zeros(length(keyPointsHL2002.fpe.lceNAT),1);

%fitMode = 1;
% 1 Start from length evaluate force error
% 2 Start from force, evaluate length error

for i=1:1:length(keyPointsHL2002.fpe.lceNAT)
    
    %Approximate the tendon strain using the target force. When the
    %fitting converges this estimated strain will be very close to being
    %correct
    etNNorm = calcQuadraticBezierYFcnXDerivative(...
                keyPointsHL2002.fpe.fceNAT(i,1),...
                tendonForceLengthInverseNormCurve,0);
    et = etNNorm*umat43.et;
    ltDelta = et*umat43.ltSlk;

    lceNAT = keyPointsHL2002.fpe.lceNAT(i,1);

    lceAT = lceNAT*umat43.lceOpt - ltDelta;
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