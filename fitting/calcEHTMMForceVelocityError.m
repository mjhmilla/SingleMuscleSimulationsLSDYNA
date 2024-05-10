function errVec = calcEHTMMForceVelocityError(arg,...
                                        umat41,...
                                        keyPointsHL1997,...
                                        keyPointsScaling)


Arel = arg(1,1)*umat41.Arel;
Brel = arg(2,1)*umat41.Brel;
Fecc=umat41.Fecc;
Secc=umat41.Secc;

idxShortening = find(keyPointsHL1997.fv.v <= 0);
errVec        = zeros(length(idxShortening),1);

q = 1;
Fisom=1;


for i=1:1:length(idxShortening)

    idx=idxShortening(i);

    lceAT = keyPointsHL1997.fv.lce(idx,1)*keyPointsScaling.length;
    vceAT = keyPointsHL1997.fv.v(idx,1)*keyPointsScaling.velocity;

    fv = calcFvUmat41(vceAT,umat41.lceOpt,umat41.lceOpt,...
                      umat41.fceOptAT,Fisom,q,Arel,Brel,Fecc,Secc);

    fvN = fv/umat41.fceOptAT;

    errVec(i,1)=fvN-keyPointsHL1997.fv.fvN(idx,1);

end

here=1;