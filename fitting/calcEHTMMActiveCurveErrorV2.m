function errVec = calcEHTMMActiveCurveErrorV2(arg,umat41,...
                    keyPointsHL1997, keyPointsHL2002)


dWdes       = umat41.dWdes;
nuCEdes     = umat41.nuCEdes;
dWasc       = umat41.dWasc;
nuCEasc     = umat41.nuCEasc;

dWdes       = arg(1,1)*dWdes;
nuCEdes     = arg(2,1)*nuCEdes;
dWasc       = arg(3,1)*dWasc;
nuCEasc     = arg(4,1)*nuCEasc;

errVec = zeros(length(keyPointsHL1997.fl.l)+length(keyPointsHL2002.fl.l),1);

idx=1;
for i=1:1:length(keyPointsHL1997.fl.l)
    %The EHTMM has no pennation model and so I'm using lceAT directly
    lceOptAT = keyPointsHL1997.lceOptAT;
    lceATExp = keyPointsHL1997.fl.lceNAT(i,1)*lceOptAT;
    fceNATExp = keyPointsHL1997.fl.fceNAT(i,1);


    falNAT = calcFisomUmat41(lceATExp,lceOptAT,dWdes,nuCEdes,dWasc,nuCEasc);
    errVec(idx,1)=falNAT - fceNATExp;
    idx=idx+1;
end
for i=1:1:length(keyPointsHL2002.fl.l)
    lceOptAT = keyPointsHL2002.lceOptAT;    
    lceATExp = keyPointsHL2002.fl.lceNAT(i,1)*lceOptAT;
    fceNATExp = keyPointsHL2002.fl.fceNAT(i,1);

    falNAT = calcFisomUmat41(lceATExp,lceOptAT,dWdes,nuCEdes,dWasc,nuCEasc);
    errVec(idx,1)=falNAT - fceNATExp;
    idx=idx+1;
end
here=1;