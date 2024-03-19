function umat41upd = fitUmat41PassiveForceLengthRelation(...
                        umat41,expKeyPtsDataFpe, scaleExpFpeData)

    
    x0      = [umat41.LPEE0;umat41.FPEE;umat41.nuPEE];
    error0  = calcEHTMMPassiveCurveError(x0,umat41,expKeyPtsDataFpe,1,...
                    scaleExpFpeData);
    error0Mag= sum(error0.^2);
    calcUmat41FpeErr = @(arg)calcEHTMMPassiveCurveError(arg,umat41,...
                             expKeyPtsDataFpe,error0Mag,...
                             scaleExpFpeData);
    
    [x1,resnorm]=lsqnonlin(calcUmat41FpeErr,x0);
    error1  = calcEHTMMPassiveCurveError(x1,umat41,expKeyPtsDataFpe,1,...
                                            scaleExpFpeData);
    error1Mag= sum(error1.^2);
    
    umat41upd       = umat41;
    umat41upd.LPEE0 = x1(1,1);
    umat41upd.FPEE  = x1(2,1);
    umat41upd.nuPEE = x1(3,1);