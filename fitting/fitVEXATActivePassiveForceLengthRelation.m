function [umat43, ...
        keyPointsHL1997, ...
        keyPointsHL2002, ...
        keyPointsVEXATFpe,...
        vexatCurves] = ...
        fitVEXATActivePassiveForceLengthRelation(...
           expData, ...
           umat43, ...
           umat43SarcomereParams,...
           umat43QuadraticCurves,...
           umat43QuadraticTitinCurves,...
           keyPointsHL1997,...
           keyPointsHL2002,...
           vexatCurves,...
           flag_plotVEXATActivePassiveForceLengthFitting)


lceOptHL2002Exp = (27/0.63)/1000; % From the text: pg 1277 paragraph 2;

% Sacks RD, Roy RR. Architecture of the hind limb muscles of cats: functional 
% significance. Journal of Morphology. 1982 Aug;173(2):185-95.
%
% Scott SH, Loeb GE. Mechanical properties of aponeurosis and tendon of the 
% cat soleus muscle during whole‐muscle isometric contractions. Journal of 
% Morphology. 1995 Apr;224(1):73-86.
%
% Herzog W, Leonard TR. Depression of cat soleus forces following 
% isokinetic shortening. Journal of biomechanics. 1997 Sep 1;30(9):865-72.
%
% Herzog W, Leonard TR. Force enhancement following stretching of skeletal 
% muscle: a new mechanism. Journal of Experimental Biology. 2002 
% May 1;205(9):1275-83.

%%
% HL 2002
%%

%To avoid scaling problems, I'm scaling every variable so that the 
%optimization variables are all approximately -1 to 1.
[fceOptATGuess, idxFceOptAT] = max(keyPointsHL2002.fl.fmt ...
                              -keyPointsHL2002.fl.fpe);
lceOptATGuess = lceOptHL2002Exp;
ltSlkGuess = lceOptATGuess*umat43.tdnToCe;

scaleSoln.fceOptAT = fceOptATGuess;
scaleSoln.lceOptAT = lceOptATGuess;
%scaleSoln.lp0      = lceOptATGuess + ltSlkGuess;
scaleSoln.shiftPEE = 0.5;
scaleSoln.scalePEE = 1;

%Unknown quantities are allowed to vary +/- 20%
lb = [1;1;1;1;1].*0.8;
ub = [1;1;1;1;1].*1.2;

%Except the path length variable which is restricted such that all
%trials begin on the near the peak to the descending limb.
ub(3,1)=1.2;
lb(3,1)=0.95;

%Un reported quantites and model parameters are allowed to vary by
% 50% to 200% of the original value
lb(4,1) = -0.5;
ub(4,1) =  0.5;
lb(5,1) =  0.5;
ub(5,1) =  2.0;

x0 = [1;1;1;0;1];
flag_fittingHL1997=0;

errFcnHL2002 = @(arg)calcVEXATActivePassiveForceLengthError(arg,...
                        scaleSoln,...
                        umat43,...
                        umat43SarcomereParams,...
                        umat43QuadraticCurves,...
                        umat43QuadraticTitinCurves,...
                        keyPointsHL2002.fl,...
                        keyPointsHL2002.fpe,...
                        flag_fittingHL1997);


options=optimset('Display','off');
[x1, resnorm,residualHL1997,exitflag] = ...
    lsqnonlin(errFcnHL2002,x0,lb,ub,options);

[errVec, ...
 expActiveIsometricPtsNorm, ...
 expPassiveIsometricPtsNorm] = ...
    calcVEXATActivePassiveForceLengthError(x1,...
                        scaleSoln,...
                        umat43,...
                        umat43SarcomereParams,...
                        umat43QuadraticCurves,...
                        umat43QuadraticTitinCurves,...
                        keyPointsHL2002.fl,...
                        keyPointsHL2002.fpe,...
                        flag_fittingHL1997);


keyPointsHL2002.fl.lceNAT   = expActiveIsometricPtsNorm.lceNAT;
keyPointsHL2002.fl.fceNAT   = expActiveIsometricPtsNorm.fceNAT;
keyPointsHL2002.fpe.lceNAT  = expPassiveIsometricPtsNorm.lceNAT;
keyPointsHL2002.fpe.fceNAT  = expPassiveIsometricPtsNorm.fceNAT;

keyPointsHL2002.fceOptAT    = x1(1,1)*scaleSoln.fceOptAT;
keyPointsHL2002.lceOptAT    = x1(2,1)*scaleSoln.lceOptAT;
%keyPointsHL2002.lp0         = x1(3,1)*scaleSoln.lp0     ;
shiftPEE_HL2002             = x1(4,1)*scaleSoln.shiftPEE;
scalePEE_HL2002             = x1(5,1)*scaleSoln.scalePEE;

lceOptHL2002            = keyPointsHL2002.lceOptAT/cos(umat43.penOpt);
keyPointsHL2002.ltSlk   = umat43.tdnToCe*lceOptHL2002;
keyPointsHL2002.lp0     = x1(3,1)*keyPointsHL2002.lceOptAT...
                                + keyPointsHL2002.ltSlk;

umat43HL2002=umat43;
umat43HL2002.fceOptAT    = keyPointsHL2002.fceOptAT;
umat43HL2002.lceOptAT    = keyPointsHL2002.lceOptAT;
umat43HL2002.fceOpt      = keyPointsHL2002.fceOptAT / cos(umat43.penOpt);
umat43HL2002.lceOpt      = keyPointsHL2002.lceOptAT / cos(umat43.penOpt);
umat43HL2002.ltSlk       = keyPointsHL2002.ltSlk;
umat43HL2002.penOpt      = umat43.penOpt;
umat43HL2002.shiftPEE    = shiftPEE_HL2002;
umat43HL2002.scalePEE    = scalePEE_HL2002;
umat43HL2002.lambdaECM   = umat43.lambdaECM;
umat43HL2002.lpHL2002    = keyPointsHL2002.lp0;
umat43HL2002.et          = umat43.et;

activation=1;
pathLength = keyPointsHL2002.lp0;
eqSoln = calcVEXATIsometricEquilibrium(...
            activation,...
            pathLength,...
            umat43HL2002,...
            umat43SarcomereParams,...
            umat43QuadraticCurves,...
            umat43QuadraticTitinCurves);
keyPointsHL2002.lp0_active_lceNAT = eqSoln.lceNAT;

activation=0;
pathLength = keyPointsHL2002.lp0;
eqSoln = calcVEXATIsometricEquilibrium(...
            activation,...
            pathLength,...
            umat43HL2002,...
            umat43SarcomereParams,...
            umat43QuadraticCurves,...
            umat43QuadraticTitinCurves);
keyPointsHL2002.lp0_passive_lceNAT = eqSoln.lceNAT;


%RMSE
idxFpe = [1:1:length(expPassiveIsometricPtsNorm.l)];
idxFl = [1:1:length(expActiveIsometricPtsNorm.l)] + max(idxFpe);
rmseHL2002.fpe = errVec(idxFpe) ./ keyPointsHL2002.fceOptAT;
rmseHL2002.fl  = errVec(idxFl) ./ keyPointsHL2002.fceOptAT;


%%
% HL 1997
%%

%To avoid scaling problems, I'm scaling every variable so that the 
%optimization variables are all approximately -1 to 1.
[fceOptATGuess, idxFceOptAT] = max(keyPointsHL1997.fl.fmt ...
                              -keyPointsHL1997.fl.fpe);
lceOptATGuess = lceOptHL2002Exp;
ltSlkGuess = lceOptATGuess*umat43.tdnToCe;

scaleSoln.fceOptAT = fceOptATGuess;
scaleSoln.lceOptAT = lceOptATGuess;
%scaleSoln.lp0      = lceOptATGuess + ltSlkGuess;
scaleSoln.shiftPEE = 0.5;

umat43HL1997 = umat43;
umat43HL1997.scalePEE = scalePEE_HL2002;

%All each variable is allowed to change within a reasonable amount of 
%error. Here I expect indirectly measured quantities to have up to 20% of
%error 
lb = [1;1;1;1].*0.8;
ub = [1;1;1;1].*1.2;


%The path length is restricted such that all trials begin on the ascending
%limb
lb(3,1) =  0.5;
ub(3,1) =  1 - 0.004/lceOptATGuess;


%Unreported quantites and model parameters are allowed to vary by
% 50% to 200% of the original value
lb(4,1) = -0.5;
ub(4,1) =  0.5;

x0 = [1;1;1;0];

flag_fittingHL1997 = 1;
%When fitting HL1997 we shifte the HL2002 fpe curve, but we do not
%scale it. Why? Not enough data points are present for that.

errFcnHL1997 = @(arg)calcVEXATActivePassiveForceLengthError(arg,...
                        scaleSoln,...
                        umat43HL1997,...
                        umat43SarcomereParams,...
                        umat43QuadraticCurves,...
                        umat43QuadraticTitinCurves,...
                        keyPointsHL1997.fl,...
                        keyPointsHL1997.fpe,...
                        flag_fittingHL1997);


options=optimset('Display','off');
[x1, resnorm,residualHL1997,exitflag] = ...
    lsqnonlin(errFcnHL1997,x0,lb,ub,options);

[errVec, ...
 expActiveIsometricPtsNorm, ...
 expPassiveIsometricPtsNorm] = ...
    calcVEXATActivePassiveForceLengthError(x1,...
                        scaleSoln,...
                        umat43HL1997,...
                        umat43SarcomereParams,...
                        umat43QuadraticCurves,...
                        umat43QuadraticTitinCurves,...
                        keyPointsHL1997.fl,...
                        keyPointsHL1997.fpe,...
                        flag_fittingHL1997);

keyPointsHL1997.fl.lceNAT   = expActiveIsometricPtsNorm.lceNAT;
keyPointsHL1997.fl.fceNAT   = expActiveIsometricPtsNorm.fceNAT;
keyPointsHL1997.fpe.lceNAT  = expPassiveIsometricPtsNorm.lceNAT;
keyPointsHL1997.fpe.fceNAT  = expPassiveIsometricPtsNorm.fceNAT;



keyPointsHL1997.fceOptAT    = x1(1,1)*scaleSoln.fceOptAT;
keyPointsHL1997.lceOptAT    = x1(2,1)*scaleSoln.lceOptAT;
%keyPointsHL1997.lp0         = x1(3,1)*scaleSoln.lp0     ;
shiftPEE_HL1997             = x1(4,1)*scaleSoln.shiftPEE;
scalePEE_HL1997             = umat43HL1997.scalePEE;

lceOptHL1997            = keyPointsHL1997.lceOptAT/cos(umat43.penOpt);
keyPointsHL1997.ltSlk   = umat43.tdnToCe*lceOptHL1997;

keyPointsHL1997.lp0     = x1(3,1)*keyPointsHL1997.lceOptAT...
                                + keyPointsHL1997.ltSlk;

%Update umat43HL1997
umat43HL1997.fceOptAT = keyPointsHL1997.fceOptAT; 
umat43HL1997.lceOptAT = keyPointsHL1997.lceOptAT;
umat43HL1997.fceOpt   = keyPointsHL1997.fceOptAT / cos(umat43.penOpt);        
umat43HL1997.lceOpt   = keyPointsHL1997.lceOptAT / cos(umat43.penOpt);
umat43HL1997.ltSlk    = keyPointsHL1997.ltSlk;
umat43HL1997.penOpt   = umat43.penOpt;
umat43HL1997.shiftPEE = shiftPEE_HL1997;
umat43HL1997.scalePEE = scalePEE_HL1997;
umat43HL1997.lambdaECM = umat43.lambdaECM;
umat43HL1997.et        = umat43.et;
umat43HL1997.lp0HL1997 = keyPointsHL1997.lp0;

activation=1;
pathLength = keyPointsHL1997.lp0;
eqSoln = calcVEXATIsometricEquilibrium(...
            activation,...
            pathLength,...
            umat43HL1997,...
            umat43SarcomereParams,...
            umat43QuadraticCurves,...
            umat43QuadraticTitinCurves);
keyPointsHL1997.lp0_active_lceNAT = eqSoln.lceNAT;

activation=0;
pathLength = keyPointsHL1997.lp0;
eqSoln = calcVEXATIsometricEquilibrium(...
            activation,...
            pathLength,...
            umat43HL1997,...
            umat43SarcomereParams,...
            umat43QuadraticCurves,...
            umat43QuadraticTitinCurves);
keyPointsHL1997.lp0_passive_lceNAT = eqSoln.lceNAT;


%RMSE
idxFpe = [1:1:length(expPassiveIsometricPtsNorm.l)];
idxFl = [1:1:length(expActiveIsometricPtsNorm.l)] + max(idxFpe);
rmseHL1997.fpe = errVec(idxFpe) ./ keyPointsHL1997.fceOptAT;
rmseHL1997.fl  = errVec(idxFl) ./ keyPointsHL1997.fceOptAT;



%%
%Normalize the force-velocity curve:
% This is a little involved because the passive forces need to be
% estimated and removed from the experimental data
%%
tendonType_0Umat41_1Umat43=1;
umat43HL1997TendonParams.fceOpt = keyPointsHL1997.fceOptAT;
umat43HL1997TendonParams.et = umat43.et;
umat43HL1997TendonParams.ltSlk = keyPointsHL1997.ltSlk;

activation=0;
pathLength = keyPointsHL1997.lp0;
eqSoln = calcVEXATIsometricEquilibrium(...
            activation,...
            pathLength,...
            umat43HL1997,...
            umat43SarcomereParams,...
            umat43QuadraticCurves,...
            umat43QuadraticTitinCurves);

[fvPts, fpePts] = ...
    calcActiveForceLengthWithElasticTendonV2(...
            keyPointsHL1997.fv.l,...
            keyPointsHL1997.fv.fmt,...
            keyPointsHL1997.fpe.l,...
            keyPointsHL1997.fpe.fmt,...
            keyPointsHL1997.fpe.clusters,...
            eqSoln.lceNAT*keyPointsHL1997.lceOptAT,...
            umat43HL1997TendonParams,...
            umat43QuadraticCurves.tendonForceLengthInverseNormCurve,...
            [],...
            tendonType_0Umat41_1Umat43);

keyPointsHL1997.fv.fceNAT = ...
     fvPts.fceAT./...
     ( keyPointsHL1997.fv.fmtMid.*ones(size(fvPts.fceAT))-fvPts.fpeAT);
keyPointsHL1997.fv.vceNAT = ...
    (keyPointsHL1997.fv.v) ./ keyPointsHL1997.lceOptAT;



%%
% Update the model's parameters
%%

switch expData
    case 'HL1997'
        umat43.lceOptAT = keyPointsHL1997.lceOptAT;
        umat43.fceOptAt = keyPointsHL1997.fceOptAT;        
        umat43.lp0HL1997= keyPointsHL1997.lp0; 
        umat43.lp0HL2002= keyPointsHL2002.lp0; 
        umat43.shiftPEE = shiftPEE_HL1997;
        umat43.scalePEE = scalePEE_HL1997;
        umat43.lceOpt   = umat43.lceOptAT / cos(umat43.penOpt);
        umat43.fceOpt   = umat43.fceOptAT / cos(umat43.penOpt);        
        umat43.ltSlk    = keyPointsHL1997.ltSlk;

    case 'HL2002'
        umat43.lceOptAT = keyPointsHL2002.lceOptAT;
        umat43.fceOptAT = keyPointsHL2002.fceOptAT; 
        umat43.lp0HL1997= keyPointsHL1997.lp0; 
        umat43.lp0HL2002= keyPointsHL2002.lp0;     
        umat43.shiftPEE = shiftPEE_HL2002;
        umat43.scalePEE = scalePEE_HL2002;

        umat43.lceOpt   = umat43.lceOptAT / cos(umat43.penOpt);
        umat43.fceOpt   = umat43.fceOptAT / cos(umat43.penOpt);        
        umat43.ltSlk    = keyPointsHL2002.ltSlk;        
    otherwise
        assert(0,'Error: expData must be HL1997 or HL2002');
end



%%
% Sample the curves of the model:
%  fal, f1, f2, fecm, ft
%%
npts=100;

lceNMin = umat43QuadraticCurves.activeForceLengthCurve.xEnd(1,1)-0.1;
lceNMax = umat43QuadraticCurves.activeForceLengthCurve.xEnd(1,2)+0.1;
lceN   = [lceNMin:((lceNMax-lceNMin)/(npts-1)):lceNMax]';

vexatCurves.fl.lceNAT   = zeros(size(lceN));
vexatCurves.fl.fceNAT   = zeros(size(lceN));
vexatCurves.fl.rmse = sqrt(mean([rmseHL1997.fl;rmseHL2002.fl].^2));

vexatCurves.fpe.lceNAT  = zeros(size(lceN));
vexatCurves.fpe.fceNAT  = zeros(size(lceN));

switch expData
    case 'HL1997'
        vexatCurves.fpe.rmse    = sqrt(mean(rmseHL1997.fpe.^2));
    case 'HL2002'
        vexatCurves.fpe.rmse    = sqrt(mean(rmseHL2002.fpe.^2));
    otherwise
        assert(0,'Error: expData must be HL1997 or HL2002');
end

vexatCurves.f1.lceNAT   = zeros(size(lceN));
vexatCurves.f1.fceNAT   = zeros(size(lceN));

vexatCurves.f2.lceNAT   = zeros(size(lceN));
vexatCurves.f2.fceNAT   = zeros(size(lceN));

vexatCurves.fecm.lceNAT = zeros(size(lceN));
vexatCurves.fecm.fceNAT = zeros(size(lceN));

vexatCurves.fpeActiveTitin.lceNAT = zeros(size(lceN));
vexatCurves.fpeActiveTitin.fceNAT = zeros(size(lceN));

l1NFixed=0;

for i=1:1:npts
    fibKin = calcFixedWidthPennatedFiberKinematicsAlongTendon(...
                lceN(i,1)*umat43.lceOpt, 0, umat43.lceOpt,umat43.penOpt);
    lceAT = fibKin.fiberLengthAlongTendon;
    alpha = fibKin.pennationAngle;
    lceNAT = lceAT / umat43.lceOpt;

    flN = calcQuadraticBezierYFcnXDerivative(lceN(i,1),...
            umat43QuadraticCurves.activeForceLengthCurve,0);
    
    tol=1e-6;
    iterMax=100;
    eqSoln = calcVEXATTitinPassiveEquilibrium(lceN(i,1), ...
                    umat43.shiftPEE, ...
                    umat43.scalePEE,...
                    umat43SarcomereParams, ...
                    umat43QuadraticCurves, ...
                    umat43QuadraticTitinCurves,...
                    tol,iterMax);
    
    assert(eqSoln.err < tol,['Error: Failed to meet tolerance',...
                             ' when solving for titin lengths']);

    lceNAT(i,1)=lceAT / umat43.lceOpt;

    f1N = eqSoln.f1N;
    f2N = eqSoln.f2N;
    fecmN=eqSoln.fecmN;

    cosAlpha = cos(alpha); %Silly for a matlab script, but waste not ...
    vexatCurves.fl.lceNAT(i,1)=lceNAT(i,1);
    vexatCurves.fl.fceNAT(i,1)=flN*cosAlpha;

    vexatCurves.f1.lceNAT(i,1)=lceNAT(i,1);
    vexatCurves.f1.fceNAT(i,1)=f1N*cosAlpha;

    vexatCurves.f2.lceNAT(i,1)=lceNAT(i,1);
    vexatCurves.f2.fceNAT(i,1)=f2N*cosAlpha;

    vexatCurves.fecm.lceNAT(i,1)=lceNAT(i,1);
    vexatCurves.fecm.fceNAT(i,1)=fecmN*cosAlpha;

    vexatCurves.fpe.lceNAT(i,1)=lceNAT(i,1);
    vexatCurves.fpe.fceNAT(i,1)=(fecmN+f2N)*cosAlpha;

    %Evaluate active titin forces
    
    if(lceN(i,1) <= umat43.lceHNLb1A*2)
        l1NFixed = eqSoln.l1N;
        vexatCurves.fpeActiveTitin.lceNAT(i,1) = lceNAT(i,1);
        vexatCurves.fpeActiveTitin.fceNAT(i,1) = vexatCurves.fpe.fceNAT(i,1);
    else
        activeTitinSoln = calcVEXATTitinForces(...
                                lceN(i,1), l1NFixed,...
                                umat43.shiftPEE, ...
                                umat43.scalePEE, ...
                                umat43SarcomereParams, ...
                                umat43QuadraticCurves, ...
                                umat43QuadraticTitinCurves);
        vexatCurves.fpeActiveTitin.lceNAT(i,1) = lceNAT(i,1);

        fpeNActive = (activeTitinSoln.f2N ...
                    + activeTitinSoln.fecmN)*cosAlpha;

        vexatCurves.fpeActiveTitin.fceNAT(i,1) = fpeNActive;

    end

end

vexatCurves.fpe.kceNAT = calcCentralDifferenceDataSeries(...
                            vexatCurves.fpe.lceNAT,...
                            vexatCurves.fpe.fceNAT);

%%
% Set keyPointsVEXATFpe
%%
idxMin=find(vexatCurves.fpe.fceNAT>0.01,1,'first');
keyPointsVEXATFpe.lceNAT = interp1(vexatCurves.fpe.fceNAT(idxMin:end,1),...
                                   vexatCurves.fpe.lceNAT(idxMin:end,1),...
                                   1);
keyPointsVEXATFpe.fceNAT = 1;
keyPointsVEXATFpe.kceNAT = interp1(vexatCurves.fpe.lceNAT,... 
                                   vexatCurves.fpe.kceNAT,...
                                   keyPointsVEXATFpe.lceNAT);


%%
% If requested, plot the curves and the experimental data
%%
if(flag_plotVEXATActivePassiveForceLengthFitting==1)
    figActivePassiveForceLength=figure;

        plot(vexatCurves.fl.lceNAT,...
             vexatCurves.fl.fceNAT,'-',...
             'Color',[1,1,1].*0.25,...
             'DisplayName','fl');
        hold on;
        plot(vexatCurves.fpe.lceNAT,...
             vexatCurves.fpe.fceNAT,...
             '-','Color',[1,1,1].*0.5,...
             'DisplayName','fpe');
        hold on;        
        plot(vexatCurves.fl.lceNAT,...
             vexatCurves.fl.fceNAT+vexatCurves.fpe.fceNAT,...
             '-','Color',[1,1,1].*0,...
             'DisplayName','fl+fpe');
        hold on;        

        plot(keyPointsHL1997.fl.lceNAT,...
             keyPointsHL1997.fl.fceNAT,'xr',...
             'DisplayName','HL1997 fl');
        hold on;
        plot(keyPointsHL1997.fpe.lceNAT,...
             keyPointsHL1997.fpe.fceNAT,'or',...
             'DisplayName','HL1997 fpe');
        hold on;
        
        plot(keyPointsHL2002.fl.lceNAT,...
             keyPointsHL2002.fl.fceNAT,'xb',...
             'DisplayName','HL2002 fl');
        hold on;

        plot(keyPointsHL2002.fpe.lceNAT,...
             keyPointsHL2002.fpe.fceNAT,'ob',...
             'DisplayName','HL2002 fpe');
        hold on;   

        plot(keyPointsVEXATFpe.lceNAT,keyPointsVEXATFpe.fceNAT,'.m',...
             'HandleVisibility','off');
        hold on;
        text(keyPointsVEXATFpe.lceNAT,keyPointsVEXATFpe.fceNAT,...
             sprintf('%1.2f %s',keyPointsVEXATFpe.kceNAT,'$$f^M_o/\ell^M_o$$'),...
             'HorizontalAlignment','left',...
             'VerticalAlignment','top',...
             'FontSize',8);
        hold on;
        text(0.45,1.15,...
             sprintf('%1.2e RMSE fl\n%1.2e RMSE fpe\n',...
                        vexatCurves.fl.rmse,...
                        vexatCurves.fpe.rmse),...
             'HorizontalAlignment','left',...
             'VerticalAlignment','top',...
             'FontSize',8)
        hold on;
        switch expData
            case 'HL1997'
                text(0.75,0.8,...
                    sprintf('%1.3f %s\n%1.3f %s\n%1.3f %s\n%1.3f %s\n%1.3f %s\n%1.3f %s\n',...
                    umat43.fceOpt,'$$f^M_o$$',umat43.lceOpt,'$$\ell^M_o$$',...
                    umat43.ltSlk,'$$\ell^T_s$$',umat43.lp0HL1997,'$$\ell^P_0$$',...
                    umat43.shiftPEE,'$$\Delta^{PEE}$$',umat43.scalePEE,'$$s^{PEE}$$'),...
                    'FontSize',12,...
                    'VerticalAlignment','top');
                hold on;

            case 'HL2002'
                text(0.75,0.8,...
                    sprintf('%1.3f %s\n%1.3f %s\n%1.3f %s\n%1.3f %s\n%1.3f %s\n%1.3f %s\n',...
                    umat43.fceOpt,'$$f^M_o$$',umat43.lceOpt,'$$\ell^M_o$$',...
                    umat43.ltSlk,'$$\ell^T_s$$',umat43.lp0HL2002,'$$\ell^P_0$$',...
                    umat43.shiftPEE,'$$\Delta^{PEE}$$',umat43.scalePEE,'$$s^{PEE}$$'),...
                    'FontSize',12,...
                    'VerticalAlignment','top');
                hold on;
        end
        box off;
        xlabel('Norm. Length ($$\ell/\ell^M_o$$)');
        ylabel('Norm. Force ($$f/f^M_o$$)');
        xlim([0.4,1.6]);
        ylim([0,1.2]);
        here=1;
end
