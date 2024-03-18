function errVec = calcEHTMMPassiveCurveError(arg,umat41,expDataFpe,errorScaling)

LPEE0 = arg(1,1);
%FPEE = arg(2,1);
%nuPEE = arg(3,1);

errVec = zeros(size(expDataFpe.lmtNAT));

for i=1:1:length(expDataFpe.lmtNAT)

    expFpee = expDataFpe.fmtNAT(i,1)*umat41.fceOptAT;

    lceAT = calcFpeeInverseUmat41(expFpee, umat41.lceOptAT, umat41.dWdes,...
                                    umat41.fceOptAT,umat41.FPEE,LPEE0,umat41.nuPEE);
    lceNAT = lceAT/umat41.lceOptAT;

    lt = calcFseeInverseUmat41(expFpee,umat41.ltSlk,umat41.dUSEEnll,...
                               umat41.duSEEl,umat41.dFSEE0);
    
    lceNAT_dltN = lceNAT + (lt-umat41.ltSlk)/umat41.lceOptAT;

    errVec(i,1)= lceNAT_dltN-expDataFpe.lmtNAT(i,1);    
end

errVec = errVec./errorScaling;