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

ltSlk = umat43.tdnToCe*lceOpt;

% The experimental data to measure the passive and active force length
% relation has measurments at the same musculotendon length. Due to
% tendon elasticity unfortunately these measurements are not at the 
% same CE length. Here I'll fit a temporary quadratic model to the
% passive data and use it to evaluate the passive curve at the CE
% lengths of the active measurements.

[fal,fpeUpd,lrefUpd] = calcActiveForceLengthWithElasticTendon(...
            keyPointsExp.fl.l*keyPointsScaling.length,...
            keyPointsExp.fl.fmt*keyPointsScaling.force,...
            keyPointsExp.fl.fpe*keyPointsScaling.force,...
            keyPointsExp.fl.clusters,...
            lceNATZero*lceOpt,...
            tendonForceLengthInverseNormCurve,...
            umat43.et,ltSlk,fceOpt);

expLceNAT = lrefUpd ./ lceOpt;
%expFceNAT = (keyPointsExp.fl.fmt*keyPointsScaling.force...
%             - exp.fl.fpe)./fceOpt;
expFceNAT = fal./fceOpt;

errVec = zeros(size(expLceNAT));

for i=1:1:length(errVec)
    
    fibKin = calcFixedWidthPennatedFiberKinematics(expLceNAT(i,1)*lceOpt,...
                                        0,...
                                        lceOpt,...
                                        umat43.penOpt);

    lce     = fibKin.fiberLength;
    alpha   = fibKin.pennationAngle;
    lceN    = lce/lceOpt;

    falN = calcQuadraticBezierYFcnXDerivative(lceN,activeForceLengthCurve,0);

    errVec(i,1)= falN*cos(alpha)-expFceNAT(i,1);
end
here=1;