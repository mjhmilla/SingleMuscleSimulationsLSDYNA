function errVec = calcEHTMMForceVelocityError(arg,...
                                        umat41,...
                                        keyPointsHL1997,...
                                        keyPointsVEXATFv)


%Arel = arg(1,1)*umat41.Arel;
Brel = umat41.Brel*arg(1,1);
Arel = Brel/keyPointsVEXATFv.vceMaxAT;
Fecc = umat41.Fecc*arg(2,1);
Secc = umat41.Secc*arg(3,1);

%idxShortening = find(keyPointsHL1997.fv.v <= 0);
%errVec        = zeros(length(idxShortening),1);

errVec        = zeros(length(keyPointsHL1997.fv.v),1);
q = 1;
Fisom=1;


for i=1:1:length(errVec)

    idx=i;%idxShortening(i);

    lceAT = keyPointsHL1997.fv.umat41.lceAT(idx,1)*keyPointsHL1997.nms.l;
    vceNAT = keyPointsHL1997.fv.umat41.vceNAT(idx,1);
    vceAT  = vceNAT*umat41.lceOptAT;
    
    fv = calcFvUmat41(vceAT,umat41.lceOpt,umat41.lceOpt,...
                      umat41.fceOptAT,Fisom,q,Arel,Brel,Fecc,Secc);

    fvN = fv/umat41.fceOptAT;

    errVec(i,1)=fvN-keyPointsHL1997.fv.umat41.fceNAT(idx,1);

end

here=1;