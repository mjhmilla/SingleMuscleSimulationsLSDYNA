function modelState = calcVEXATIsometricState(...
                            activation,...
                            fiberLengthAlongTendon,...
                            pathLength,...
                            params,...
                            sarcomere,...
                            vexatQuadraticCurves,...
                            vexatQuadraticTitinCurves,...
                            useElasticTendon)

lceAT = fiberLengthAlongTendon;

%Evaluate the CE length and pennation angle
fibKin = calcFixedWidthPennatedFiberKinematics(...
            lceAT,0,params.lceOpt,params.penOpt);

lce     = fibKin.fiberLength;
alpha   = fibKin.pennationAngle;        
lceN    = lce/params.lceOpt;

%Active force length relation
falN = calcQuadraticBezierYFcnXDerivative(lceN,...
   vexatQuadraticCurves.activeForceLengthCurve,0);

%Force-velocity relation: isometric:
fvN = 1;

%Evaluate the force equilibrium between the two titin segments
titinTol = 1e-8;
titinIterMax=100;
titinSoln = calcVEXATTitinPassiveEquilibrium(lceN, ...
        params.shiftPEE, ...
        params.scalePEE,...
        sarcomere, ...
        vexatQuadraticCurves, ...
        vexatQuadraticTitinCurves,...
        titinTol, titinIterMax);    

f1N=titinSoln.f1N;
f2N=titinSoln.f2N;
fecmN=titinSoln.fecmN;

%Evaluate the ce force
fceN  = activation*falN*fvN + (fecmN+f2N);
fceNAT= fceN*cos(alpha);

%Evaluate the tendon force
if(useElasticTendon==1)
    lt  = pathLength - lceAT;
    ltN = lt / params.ltSlk;
    et = ltN - 1;
    etN = et / params.et;
    ftN = calcQuadraticBezierYFcnXDerivative(etN,...
            vexatQuadraticCurves.tendonForceLengthNormCurve,0);
else
    lt = params.ltSlk;
    ltN= 1;
    ftN=fceNAT;
end
modelState.lce      = lce;
modelState.lceN     = lceN;
modelState.lceNAT   = lceN*cos(alpha);
modelState.fceN     = fceN;
modelState.fceNAT   = fceNAT;
modelState.pennationAngle    = alpha;
modelState.falN     = falN;
modelState.fvN      = fvN;
modelState.l1N      = titinSoln.l1N;
modelState.l2N      = titinSoln.l2N;
modelState.f1N      = titinSoln.f1N;
modelState.f2N      = titinSoln.f2N;
modelState.fecmN    = titinSoln.fecmN;
modelState.lt       = lt;
modelState.ltN      = ltN;
modelState.ftN      = ftN;

