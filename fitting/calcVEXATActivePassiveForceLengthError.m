function [errVec, ...
          expActiveIsometricPtsNorm, ...
          expPassiveIsometricPtsNorm]...
            = calcVEXATActivePassiveForceLengthError(x,...
                scaleSoln,...               
                umat43,...
                umat43SarcomereParams,...
                umat43QuadraticCurves,...
                umat43QuadraticTitinCurves,...
                expActiveIsometricPts,...
                expPassiveIsometricPts,...
                flag_fittingHL1997)

fceOptAT = x(1,1)*scaleSoln.fceOptAT;
lceOptAT = x(2,1)*scaleSoln.lceOptAT;

lceOpt = lceOptAT/cos(umat43.penOpt);
fceOpt = fceOptAT/cos(umat43.penOpt);
ltSlk = umat43.tdnToCe*lceOpt;
lp0       = x(3,1)*lceOptAT + ltSlk;

if(flag_fittingHL1997 == 0)
    shiftPEE = x(4,1)*scaleSoln.shiftPEE;
    scalePEE = x(5,1)*scaleSoln.scalePEE;
else
    shiftPEE = x(4,1)*scaleSoln.shiftPEE;
    scalePEE = umat43.scalePEE;
    
end

errVec = zeros(length(expActiveIsometricPts.l)...
              +length(expPassiveIsometricPts.l), 1);
idx=1;

%A reduced set of parameters to evaluate the isometric equilbrium of 
%the model
modelParams.fceOpt      = fceOpt;
modelParams.lceOpt      = lceOpt;
modelParams.ltSlk       = ltSlk;
modelParams.penOpt      = umat43.penOpt;
modelParams.shiftPEE    = shiftPEE;
modelParams.scalePEE    = scalePEE;
modelParams.lambdaECM   = umat43.lambdaECM;
modelParams.et          = umat43.et;

expActiveIsometricPtsNorm=expActiveIsometricPts;
expActiveIsometricPtsNorm.lceNAT= zeros(size(expActiveIsometricPtsNorm.l));
expActiveIsometricPtsNorm.fceNAT= zeros(size(expActiveIsometricPtsNorm.fmt));

expPassiveIsometricPtsNorm        = expPassiveIsometricPts;
expPassiveIsometricPtsNorm.lceNAT = zeros(size(expPassiveIsometricPtsNorm.l));
expPassiveIsometricPtsNorm.fceNAT = zeros(size(expPassiveIsometricPtsNorm.fmt));

%For every passive point and active point evaluate the isometric
%equilibrium at each path length and evaluate the difference in force
%between the experimental data and the model
if(isempty(length(expPassiveIsometricPts.l))==0)
    for i=1:1:length(expPassiveIsometricPts.l)
        activation=0;
        pathLength = lp0 + expPassiveIsometricPtsNorm.l(i);
        eqSoln = calcVEXATIsometricEquilibrium(...
                    activation,...
                    pathLength,...
                    modelParams,...
                    umat43SarcomereParams,...
                    umat43QuadraticCurves,...
                    umat43QuadraticTitinCurves);
        errVec(idx,1) = eqSoln.fceNAT*modelParams.fceOpt...
                      - expPassiveIsometricPtsNorm.fmt(i); 
        expPassiveIsometricPtsNorm.lceNAT(i,1) = eqSoln.lceNAT;
        expPassiveIsometricPtsNorm.fceNAT(i,1) = ...
            expPassiveIsometricPtsNorm.fmt(i)./modelParams.fceOpt;
        idx=idx+1;
    end
end

if(isempty(length(expActiveIsometricPts.l))==0)
    for i=1:1:length(expActiveIsometricPts.l)
        activation=1;
        pathLength = lp0 + expActiveIsometricPtsNorm.l(i);
        eqSoln = calcVEXATIsometricEquilibrium(...
                    activation,...
                    pathLength,...
                    modelParams,...
                    umat43SarcomereParams,...
                    umat43QuadraticCurves,...
                    umat43QuadraticTitinCurves);
        errVec(idx,1) = eqSoln.fceNAT*modelParams.fceOpt ...
                      - expActiveIsometricPtsNorm.fmt(i);                                    
        expActiveIsometricPtsNorm.lceNAT(i,1) = eqSoln.lceNAT;
        expActiveIsometricPtsNorm.fceNAT(i,1) = eqSoln.fceNAT;
        expActiveIsometricPtsNorm.fceNAT(i,1) = ...
            expActiveIsometricPtsNorm.fmt(i)./modelParams.fceOpt;        
        
        idx=idx+1;
    end
end

here=1;
