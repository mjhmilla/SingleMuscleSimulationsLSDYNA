%%
% SPDX-FileCopyrightText: 2024 Matthew Millard <millard.matthew@gmail.com>
%
% SPDX-License-Identifier: MIT
%
%%
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

    lp0     = keyPointsHL1997.fv.l(idx,1)+keyPointsHL1997.lp0;
    vceAT   = keyPointsHL1997.fv.v(idx,1);
    
    fv = calcFvUmat41(vceAT,umat41.lceOpt,umat41.lceOpt,...
                      umat41.fceOptAT,Fisom,q,Arel,Brel,Fecc,Secc);

    fvN = fv/umat41.fceOptAT;
    fvNATExp = keyPointsHL1997.fv.fmt(idx,1) / keyPointsHL1997.fv.fmtMid;

    errVec(i,1)=fvN-fvNATExp;

end

here=1;