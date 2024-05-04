function umat41upd = fitUmat41ActiveForceLengthRelation(...
                        umat41,expKeyPtsDataFal,...
                        umat43,umat43QuadraticBezierCurves)

    flag_fitToUmat43=1;
    
    x0      = [umat41.dWdes;umat41.nuCEdes];
    error0  = calcEHTMMActiveCurveError(x0,umat41,expKeyPtsDataFal,...
                                umat43,umat43QuadraticBezierCurves,flag_fitToUmat43);
    error0Mag= sum(error0.^2);
    calcUmat41FlErr =...
        @(arg)calcEHTMMActiveCurveError(arg,umat41,expKeyPtsDataFal,...
                        umat43,umat43QuadraticBezierCurves,error0Mag);
    
    [x1,resnorm]=lsqnonlin(calcUmat41FlErr,x0);
    error1  = calcEHTMMActiveCurveError(x1,umat41,expKeyPtsDataFal,...
                        umat43,umat43QuadraticBezierCurves,flag_fitToUmat43);
    error1Mag= sum(error1.^2);
    
    umat41upd       = umat41;
    umat41upd.dWdes   = x1(1,1);
    umat41upd.nuCEdes = x1(2,1);
