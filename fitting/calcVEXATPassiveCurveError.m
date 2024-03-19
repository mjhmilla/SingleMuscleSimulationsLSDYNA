function errVec = calcVEXATPassiveCurveError(arg,umat43,umat43QuadraticBezierCurves,...
                        expDataFpe,errorScaling)

shiftPEE = arg(1,1);
scalePEE = arg(2,1);

errVec = zeros(size(expDataFpe.lmt));

for i=1:1:length(expDataFpe.lmt)

    lmt = expDataFpe.lmt(i,1);
    fmt = expDataFpe.fmt(i,1);

    ltN = calcQuadraticBezierYFcnXDerivative(fmt/umat43.fceOpt,...
          umat43QuadraticBezierCurves.tendonForceLengthInverseCurve,0); 

    lceAT = lmt-(ltN-1)*umat43.ltSlk;
    fibKin = calcFixedWidthPennatedFiberKinematics(lceAT,0,umat43.lceOpt,umat43.penOpt);

    lce = fibKin.fiberLength;
    alpha=fibKin.pennationAngle;
    lceN = lce/umat43.lceOpt;

    %This is a close approximation of the curve produced by the 
    % prox-distal titin spring in parallel with the ECM.
    fpeN = calcQuadraticBezierYFcnXDerivative(lceN-shiftPEE,...
          umat43QuadraticBezierCurves.fiberForceLengthCurve,0); 
    fpeN = fpeN*scalePEE;

    errVec(i,1)=(fpeN*cos(alpha))*umat43.fceOpt - expDataFpe.fmt(i,1);
end
errVec = errVec./errorScaling;