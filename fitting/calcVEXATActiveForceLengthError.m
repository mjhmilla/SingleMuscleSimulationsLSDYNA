function errVec = calcVEXATActiveForceLengthError(args,...
                                    defaultSoln,...
                                    umat43,...
                                    keyPointsExp,...
                                    keyPointsScaling,...
                                    activeForceLengthCurve)



lceOptAT    = defaultSoln.lceOptAT*args(1,1);
fceOptAT    = defaultSoln.fceOptAT*args(2,1);
lceNATZero  = args(3,1);

lceNAT = ( (keyPointsExp.fl.l).*keyPointsScaling.length ...
         + lceNATZero*lceOptAT)./lceOptAT;

fceNAT= ((keyPointsExp.fl.f).*(keyPointsScaling.force))./fceOptAT;

errVec = zeros(size(lceNAT));

lceOpt = lceOptAT/cos(umat43.penOpt);

for i=1:1:length(errVec)
    
    fibKin = calcFixedWidthPennatedFiberKinematics(lceNAT(i,1)*lceOptAT,...
                                        0,...
                                        lceOpt,...
                                        umat43.penOpt);

    lce     = fibKin.fiberLength;
    alpha   = fibKin.pennationAngle;
    lceN    = lce/lceOpt;

    falN = calcQuadraticBezierYFcnXDerivative(lceN,activeForceLengthCurve,0);

    errVec(i,1)= falN*cos(alpha)-fceNAT(i,1);
end
here=1;