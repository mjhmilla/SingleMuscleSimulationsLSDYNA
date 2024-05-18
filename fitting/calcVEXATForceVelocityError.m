function errVec = calcVEXATForceVelocityError(arg,...
                                        umat43,...
                                        keyPointsHL1997,...
                                        fiberForceVelocityCurve)

vceMax = arg(1,1)*umat43.vceMax;

%idxShortening = find(keyPointsHL1997.fv.v <= 0);
%errVec=zeros(length(idxShortening),1);
errVec = zeros(length(keyPointsHL1997.fv.v),1);

for i=1:1:length(errVec)

    idx=i;%idxShortening(i);

    lceAT  = keyPointsHL1997.fv.umat43.lceAT(idx,1)*keyPointsHL1997.nms.l;
    vceNAT = keyPointsHL1997.fv.umat43.vceNAT(idx,1);
    vceAT  = vceNAT*umat43.lceOpt;

    fibKin = calcFixedWidthPennatedFiberKinematics(lceAT,...
                                        vceAT,...
                                        umat43.lceOpt,...
                                        umat43.penOpt);

    lce   = fibKin.fiberLength;
    dlce  = fibKin.fiberVelocity;
    alpha = fibKin.pennationAngle;
    dalpha= fibKin.pennationAngularVelocity;

    dlceNN = dlce/(umat43.lceOpt*vceMax);

    fvN = calcQuadraticBezierYFcnXDerivative(dlceNN,...
                    fiberForceVelocityCurve,0);
    fvNAT = fvN*cos(alpha);
    errVec(i,1)=fvNAT-keyPointsHL1997.fv.umat43.fceNAT(idx,1);

end

here=1;