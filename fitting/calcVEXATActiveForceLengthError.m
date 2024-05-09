function errVec = calcVEXATActiveForceLengthError(args,...
                                    defaultSoln,...
                                    umat43,...
                                    keyPointsExp,...
                                    keyPointsScaling,...
                                    activeForceLengthCurve,...
                                    tendonForceLengthInverseNormCurve)



lceOptAT    = defaultSoln.lceOptAT*args(1,1);
fceOptAT    = defaultSoln.fceOptAT*args(2,1);
lceNATZero  = args(3,1);

lceOpt = lceOptAT/cos(umat43.penOpt);
fceOpt = fceOptAT/cos(umat43.penOpt);

lt = calcVEXATTendonLength(...
            (keyPointsExp.fl.fmt).*(keyPointsScaling.force),...
            fceOpt,...
            tendonForceLengthInverseNormCurve,...
            umat43.et,...
            umat43.ltSlk);
dlt = lt-umat43.ltSlk;

lceAT = (keyPointsExp.fl.l).*(keyPointsScaling.length) ...
        -dlt + lceNATZero*lceOpt;

lceNAT = lceAT./lceOpt;

% deltaLt = zeros(size(keyPointsExp.fl.l));
% for i=1:1:length(keyPointsExp.fl.f)
%     ft      = keyPointsExp.fl.fmt(i,1)*keyPointsScaling.force;
%     ftN     = ft/fceOpt;
%     etN     = calcQuadraticBezierYFcnXDerivative(ftN,...
%                 tendonForceLengthInverseNormCurve,0);
%     et              = etN*umat43.et;
%     deltaLt(i,1)    = et*umat43.ltSlk;
% end
% 
% lceNAT = ( (keyPointsExp.fl.l).*keyPointsScaling.length - deltaLt ...
%          + lceNATZero*lceOpt)./lceOpt;
% 
fceNAT= ((keyPointsExp.fl.f).*(keyPointsScaling.force))./fceOpt;

errVec = zeros(size(lceNAT));


for i=1:1:length(errVec)
    
    fibKin = calcFixedWidthPennatedFiberKinematics(lceNAT(i,1)*lceOpt,...
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