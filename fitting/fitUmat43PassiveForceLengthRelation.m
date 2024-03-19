function [umat43Upd, expKeyPtsDataFpeUpd]= ...
    fitUmat43PassiveForceLengthRelation(...
                      umat43, umat43QuadraticBezierCurves, ...
                      expKeyPtsDataFpe,scaleExpFpeData)

    x0 = [umat43.shiftPEE;umat43.scalePEE];
    error0 = calcVEXATPassiveCurveError(x0,umat43,...
                               umat43QuadraticBezierCurves,...
                               expKeyPtsDataFpe,1,...
                               scaleExpFpeData);
    error0Mag = sum(error0.^2);
    
    calcUmat43FpeErr = @(arg)calcVEXATPassiveCurveError(arg,umat43,...
                               umat43QuadraticBezierCurves,...
                               expKeyPtsDataFpe,error0Mag,...
                               scaleExpFpeData);
    [x1,resnorm]=lsqnonlin(calcUmat43FpeErr,x0);
    
    error1 = calcVEXATPassiveCurveError(x1,umat43,...
                               umat43QuadraticBezierCurves,...
                               expKeyPtsDataFpe,1,...
                               scaleExpFpeData);
    error1Mag = sum(error1.^2);
    
    umat43Upd = umat43;
    umat43Upd.shiftPEE = x1(1,1);
    umat43Upd.scalePEE = x1(2,1);


    expKeyPtsDataFpeUpd=expKeyPtsDataFpe;

        %Use the model to generate a point near fpe=1. THis gets appended
    %to the points that umat41's fpe curve is fit to. Why? Otherwise 
    %the optimization routine changes nuPEE by a lot. The result is a good
    %fit for low forces but a terrible fit for higher forces.
    lceNX = 1.4039;
    fpeNX = calcQuadraticBezierYFcnXDerivative(lceNX-umat43Upd.shiftPEE,...
              umat43QuadraticBezierCurves.fiberForceLengthCurve,0); 
    fpeNX = fpeNX*umat43Upd.scalePEE;
    
    fibKin = calcFixedWidthPennatedFiberKinematicsAlongTendon(...
        lceNX*umat43.lceOpt,0,umat43.lceOpt,umat43.penOpt);
    
    lceATX = fibKin.fiberLengthAlongTendon; 
    alphaX = fibKin.pennationAngle;
    
    ltNX = calcQuadraticBezierYFcnXDerivative(fpeNX*cos(alphaX),...
              umat43QuadraticBezierCurves.tendonForceLengthInverseCurve,0);
    
    lmtX = lceATX + (ltNX-1)*umat43.ltSlk;
    fmtX = fpeNX*umat43.fceOpt*cos(alphaX);

    expKeyPtsDataFpeUpd.lmt=[expKeyPtsDataFpe.lmt;lmtX];
    expKeyPtsDataFpeUpd.fmt=[expKeyPtsDataFpe.fmt;fmtX*(1/scaleExpFpeData)];