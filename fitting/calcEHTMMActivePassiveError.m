%%
% SPDX-FileCopyrightText: 2024 Matthew Millard <millard.matthew@gmail.com>
%
% SPDX-License-Identifier: MIT
%
%%
function errVec = calcEHTMMActivePassiveError(...
                    arg,...
                    umat41,...
                    keyPointsHL1997,...
                    keyPointsHL2002,...
                    keyPointsVEXATFpe,...
                    vexatFpeSample,...
                    expData)



umat41Fit = umat41;

switch expData
    case 'HL1997'
        assert(length(arg)==3,'Error: argument incorrectly sized');
        
        %Just fit the passive terms
        umat41Fit.LPEE0    = arg(1,1)*umat41.LPEE0;
        umat41Fit.FPEE     = arg(2,1)*umat41.FPEE;
        umat41Fit.nuPEE    = arg(3,1)*umat41.nuPEE;  


        errVec = zeros(  length(keyPointsHL1997.fl.l) ...
                       + length(keyPointsHL1997.fpe.l) ...
                       + 3,1);         

    case 'HL2002'
        assert(length(arg)==7,'Error: argument incorrectly sized');

        %Fit the active and passive terms.
        umat41Fit.dWdes    = arg(1,1)*umat41.dWdes;
        umat41Fit.nuCEdes  = arg(2,1)*umat41.nuCEdes;
        umat41Fit.dWasc    = arg(3,1)*umat41.dWasc;
        umat41Fit.nuCEasc  = arg(4,1)*umat41.nuCEasc;
        umat41Fit.LPEE0    = arg(5,1)*umat41.LPEE0;
        umat41Fit.FPEE     = arg(6,1)*umat41.FPEE;
        umat41Fit.nuPEE    = arg(7,1)*umat41.nuPEE; 

        errVec = zeros( length(keyPointsHL2002.fl.l) ...
                       + length(keyPointsHL1997.fl.l) ...
                       + length(keyPointsHL2002.fpe.l) ...
                       + 2,1);        
end

%%
%HL2002 active force length
%%
idx=1;
if(contains(expData,'HL2002')==1)
    activation=1;
    umat41Fit.lceOptAT  = keyPointsHL2002.lceOptAT;
    umat41Fit.lceOpt    = nan; %shouldn't be used 
    umat41Fit.fceOptAT  = keyPointsHL2002.fceOptAT;
    umat41Fit.fceOpt    = nan; %shouldn't be used 
    umat41Fit.ltSlk     =keyPointsHL2002.ltSlk;
    

    for i=1:1:length(keyPointsHL2002.fl.l)
        
        pathLength = keyPointsHL2002.lp0 + keyPointsHL2002.fl.l(i,1);
    
    
        eqSoln = calcEHTMMIsometricEquilibrium(activation,pathLength,...
                                                umat41Fit);
        errVec(idx,1) = eqSoln.fceNAT*umat41Fit.fceOptAT ...
                        -keyPointsHL2002.fl.fmt(i,1);
        errVec(idx,1) = errVec(idx,1)/umat41Fit.fceOptAT;                
        idx=idx+1;
    end
end


%%
%HL1997 active force length
%%

umat41Fit.lceOptAT  = keyPointsHL1997.lceOptAT;
umat41Fit.lceOpt    = nan; %shouldn't be used 
umat41Fit.fceOptAT  = keyPointsHL1997.fceOptAT;
umat41Fit.fceOpt    = nan; %shouldn't be used 
umat41Fit.ltSlk     =keyPointsHL1997.ltSlk;
activation=1;
for i=1:1:length(keyPointsHL1997.fl.l)

    pathLength = keyPointsHL1997.lp0 + keyPointsHL1997.fl.l(i,1);

    eqSoln = calcEHTMMIsometricEquilibrium(activation,pathLength,...
                                            umat41Fit);

    fceATExp = keyPointsHL1997.fl.fmt(i,1);

    %This is an approximation of the active force since, due to the
    %tendon, the values of fpe and fmt are taken at different CE lengths
    %even though the path length is the same. In this case this is 
    %acceptable because:
    % 1. The passive forces are very low so fmt and fpe are at almost
    %    the same length.
    % 2. The passive curve for HL2002 is zero at this point
    %
    %In the HL1997 case this approximation isn't needed because we
    %are also fitting the passive curve.
    if(contains(expData,'HL2002'))
        fceATExp =  keyPointsHL1997.fl.fmt(i,1)...
                   -keyPointsHL1997.fl.fpe(i,1);
    end
    errVec(idx,1) = eqSoln.fceNAT*umat41Fit.fceOptAT ...
                    -fceATExp;
    errVec(idx,1) = errVec(idx,1)/umat41Fit.fceOptAT;                 
    idx=idx+1;
end

%%
% HL2002 passive error
%%

if(contains(expData,'HL2002')==1)
    activation=0;
    umat41Fit.lceOptAT  = keyPointsHL2002.lceOptAT;
    umat41Fit.lceOpt    = nan; %shouldn't be used 
    umat41Fit.fceOptAT  = keyPointsHL2002.fceOptAT;
    umat41Fit.fceOpt    = nan; %shouldn't be used 
    umat41Fit.ltSlk     =keyPointsHL2002.ltSlk;
    
    for i=1:1:length(keyPointsHL2002.fpe.l)
        
        pathLength = keyPointsHL2002.lp0 + keyPointsHL2002.fpe.l(i,1);
    
        eqSoln = calcEHTMMIsometricEquilibrium(activation,pathLength,...
                                                umat41Fit);
        errVec(idx,1) = eqSoln.fceNAT*umat41Fit.fceOptAT ...
                        -keyPointsHL2002.fpe.fmt(i,1);
        errVec(idx,1) = errVec(idx,1)/umat41Fit.fceOptAT;                 
        idx=idx+1;
    end

    lceNAT = keyPointsVEXATFpe.lceNAT;
    lceAT  = lceNAT*umat41Fit.lceOptAT; 
    fpeAT  = calcFpeeUmat41(lceAT,...
                        umat41Fit.lceOptAT,...
                        umat41Fit.dWdes,...
                        umat41Fit.fceOptAT,...
                        umat41Fit.FPEE,...
                        umat41Fit.LPEE0,...
                        umat41Fit.nuPEE);
    fpeNAT = fpeAT/umat41Fit.fceOptAT;
    errVec(idx,1) = fpeNAT - keyPointsVEXATFpe.fceNAT;    
    idx=idx+1;
    
    kpeAT= calcFpeeDerivativeUmat41(lceAT,...
                        umat41Fit.lceOptAT,...
                        umat41Fit.dWdes,...
                        umat41Fit.fceOptAT,...
                        umat41Fit.FPEE,...
                        umat41Fit.LPEE0,...
                        umat41Fit.nuPEE);
    kpeNAT = kpeAT/(umat41Fit.fceOptAT/umat41Fit.lceOptAT);
    
    errVec(idx,1)=kpeNAT - keyPointsVEXATFpe.kceNAT; 
end


%%
% HL1997
%  There are too few passive points in HL1997 and so we add some
%  additional points from the VEXAT passive curve. The VEXAT 
%  passive curve was fit by first fitting to the relatively data
%  rich HL2002 and then just shifting the resulting curve to
%  fit to HL1997
%%

if(contains(expData,'HL1997')==1)
    activation=0;    
    umat41Fit.lceOptAT  = keyPointsHL1997.lceOptAT;
    umat41Fit.lceOpt    = nan; %shouldn't be used 
    umat41Fit.fceOptAT  = keyPointsHL1997.fceOptAT;
    umat41Fit.fceOpt    = nan; %shouldn't be used 
    umat41Fit.ltSlk     =keyPointsHL1997.ltSlk;     
    
    for i=1:1:length(keyPointsHL1997.fpe.l)
        
        pathLength = keyPointsHL1997.lp0 + keyPointsHL1997.fpe.l(i,1);
    
        eqSoln = calcEHTMMIsometricEquilibrium(activation,pathLength,...
                                                umat41Fit);
        errVec(idx,1) = eqSoln.fceNAT*umat41Fit.fceOptAT ...
                        -keyPointsHL1997.fpe.fmt(i,1);
        errVec(idx,1) = errVec(idx,1)/umat41Fit.fceOptAT; 
        idx=idx+1;
    end

    lceNAT = keyPointsVEXATFpe.lceNAT;
    lceAT  = lceNAT*umat41Fit.lceOptAT; 
    fpeAT  = calcFpeeUmat41(lceAT,...
                        umat41Fit.lceOptAT,...
                        umat41Fit.dWdes,...
                        umat41Fit.fceOptAT,...
                        umat41Fit.FPEE,...
                        umat41Fit.LPEE0,...
                        umat41Fit.nuPEE);
    fpeNAT = fpeAT/umat41Fit.fceOptAT;
    errVec(idx,1) = fpeNAT - keyPointsVEXATFpe.fceNAT;    
    idx=idx+1;
    
    kpeAT= calcFpeeDerivativeUmat41(lceAT,...
                        umat41Fit.lceOptAT,...
                        umat41Fit.dWdes,...
                        umat41Fit.fceOptAT,...
                        umat41Fit.FPEE,...
                        umat41Fit.LPEE0,...
                        umat41Fit.nuPEE);
    kpeNAT = kpeAT/(umat41Fit.fceOptAT/umat41Fit.lceOptAT);
    
    errVec(idx,1)=kpeNAT - keyPointsVEXATFpe.kceNAT; 
    
    %%
    % VEXAT Sample
    %%
    idx=idx+1;   
    
    fmin = 0.1;
    fmax = 0.6;
    idxMin = find(vexatFpeSample.fceNAT > fmin*0.5,1,'first');
    idxMax = find(vexatFpeSample.fceNAT > 1,1,'first');
    
    % for k=1:10:idxMax
    k=4;
        
    n = (k-1)/(8-1);
    fsample = fmin + n*(fmax-fmin);        
    lceNAT = interp1(vexatFpeSample.fceNAT(idxMin:end),...
                     vexatFpeSample.lceNAT(idxMin:end),...
                     fsample);
    
    lceAT  = lceNAT*umat41Fit.lceOptAT; 
    fpeAT= calcFpeeUmat41(lceAT,...
                        umat41Fit.lceOptAT,...
                        umat41Fit.dWdes,...
                        umat41Fit.fceOptAT,...
                        umat41Fit.FPEE,...
                        umat41Fit.LPEE0,...
                        umat41Fit.nuPEE);
    fpeNAT = fpeAT/umat41Fit.fceOptAT;
    errVec(idx,1) = fpeNAT - fsample;
     
end



%end

here=1;    
