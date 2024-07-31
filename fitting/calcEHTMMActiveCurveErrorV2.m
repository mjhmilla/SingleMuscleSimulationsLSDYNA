%%
% SPDX-FileCopyrightText: 2024 Matthew Millard <millard.matthew@gmail.com>
%
% SPDX-License-Identifier: MIT
%
%%
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

%Evaluate fal, lref using the EHTMM tendon

umat41TendonParams.dUSEEnll =umat41.dUSEEnll;
umat41TendonParams.duSEEl   =umat41.duSEEl;
umat41TendonParams.dFSEE0   =umat41.dFSEE0;
umat41TendonParams.ltSlk    =keyPointsHL1997.ltSlk;

tendonType_0Umat41_1Umat43=0;
[fal1997Pts,fpe1997Pts] = ...
    calcActiveForceLengthWithElasticTendonV2(...
            keyPointsHL1997.fl.l,...
            keyPointsHL1997.fl.fmt,...
            keyPointsHL1997.fl.l,...
            keyPointsHL1997.fl.fpe,...
            keyPointsHL1997.fl.clusters,...
            keyPointsHL1997.lceNAT0a*keyPointsHL1997.lceOpt,...
            [],...
            [],...
            umat41TendonParams,...
            tendonType_0Umat41_1Umat43);

idx=1;
for i=1:1:length(fal1997Pts)
    %The EHTMM has no pennation model and so I'm using lceAT directly
    lceOptAT    = keyPointsHL1997.lceOpt*cos(umat41.penOpt);
    lceATExp    = fal1997Pts.lceAT(i,1);
    fceNATExp   = fal1997Pts.fceAT(i,1) / keyPointsHL1997.fceOpt;


    falNAT =calcFisomUmat41(lceATExp,lceOptAT,dWdes,nuCEdes,dWasc,nuCEasc);
    errVec(idx,1)=falNAT - fceNATExp;
    idx=idx+1;
end


tendonType_0Umat41_1Umat43=0;
[fal2002Pts,fpe2002Pts] = ...
    calcActiveForceLengthWithElasticTendonV2(...
            keyPointsHL2002.fl.l*keyPointsHL2002.nms.l,...
            keyPointsHL2002.fl.fmt*keyPointsHL2002.nms.f,...
            keyPointsHL2002.fl.l*keyPointsHL2002.nms.l,...
            keyPointsHL2002.fl.fpe*keyPointsHL2002.nms.f,...
            keyPointsHL2002.fl.clusters,...
            keyPointsHL2002.lceNAT0a*keyPointsHL2002.lceOpt,...
            [],...
            [],...
            umat41TendonParams,...
            tendonType_0Umat41_1Umat43);


for i=1:1:length(fal2002Pts.lceAT)
    lceOptAT    = keyPointsHL2002.lceOpt*cos(umat41.penOpt);    
    lceATExp    = fal2002Pts.lceAT(i,1);
    fceNATExp   = fal2002Pts.fceAT(i,1) / keyPointsHL2002.fceOpt;

    falNAT = calcFisomUmat41(lceATExp,lceOptAT,dWdes,nuCEdes,dWasc,nuCEasc);
    errVec(idx,1)=falNAT - fceNATExp;
    idx=idx+1;
end
here=1;