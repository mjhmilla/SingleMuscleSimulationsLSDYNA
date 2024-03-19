function errVec = calcEHTMMPassiveCurveError(arg,umat41,expDataFpe,...
                    errorScaling,scaleExpFpeData)

LPEE0 = arg(1,1);
FPEE = arg(2,1);
nuPEE = arg(3,1);

errVec = zeros(size(expDataFpe.lmt));

for i=1:1:length(expDataFpe.lmt)

    lmt = expDataFpe.lmt(i,1);
    fmt = expDataFpe.fmt(i,1);

    lsee = calcFseeInverseUmat41(fmt,...
             umat41.ltSlk,umat41.dUSEEnll,umat41.duSEEl,umat41.dFSEE0);  

    lceAT = lmt-(lsee-umat41.ltSlk);

    fpeAT= calcFpeeUmat41( lceAT,...
                        umat41.lceOptAT,...
                        umat41.dWdes,...
                        umat41.fceOptAT,...
                        FPEE,...
                        LPEE0,...
                        nuPEE);

    errVec(i,1) = fpeAT - expDataFpe.fmt(i,1).*scaleExpFpeData;

end

errVec = errVec./errorScaling;