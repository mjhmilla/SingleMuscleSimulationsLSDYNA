function errVec = calcVEXATForceVelocityError(arg,...
                                        umat43,...
                                        keyPointsHL1997,...
                                        umat43QuadraticCurves)

vceMax = arg(1,1)*umat43.vceMax;

%idxShortening = find(keyPointsHL1997.fv.v <= 0);
%errVec=zeros(length(idxShortening),1);
errVec = zeros(length(keyPointsHL1997.fv.v),1);

for i=1:1:length(errVec)

    idx=i;%idxShortening(i);

    %lceAT  = keyPointsHL1997.fv.umat43.lceAT(idx,1);
    lp0     = keyPointsHL1997.fv.l(idx,1)+keyPointsHL1997.lp0;
    vceAT   = keyPointsHL1997.fv.v(idx,1);

    ft  = keyPointsHL1997.fv.fmt(idx,1);
    ftN = ft/keyPointsHL1997.fceOptAT;
    etN = calcQuadraticBezierYFcnXDerivative(ftN,...
                umat43QuadraticCurves.tendonForceLengthInverseNormCurve,0);
    et = etN*umat43.et;
    lt = (1+et)*keyPointsHL1997.ltSlk;

    lceAT = lp0-lt;

    lceOptHL1997 = keyPointsHL1997.lceOptAT/cos(umat43.penOpt);


    fibKin = calcFixedWidthPennatedFiberKinematics(lceAT,...
                                        vceAT,...
                                        lceOptHL1997,...
                                        umat43.penOpt);

    lce   = fibKin.fiberLength;
    dlce  = fibKin.fiberVelocity;
    alpha = fibKin.pennationAngle;
    dalpha= fibKin.pennationAngularVelocity;


    dlceNN = dlce/(lceOptHL1997*vceMax);

    fvN = calcQuadraticBezierYFcnXDerivative(dlceNN,...
            umat43QuadraticCurves.fiberForceVelocityCurve,0);
    
    fvNATExp = keyPointsHL1997.fv.fmt(idx,1) / keyPointsHL1997.fv.fmtMid;
    errVec(i,1)=fvN*cos(alpha) - fvNATExp;

end

here=1;