%%
% SPDX-FileCopyrightText: 2024 Matthew Millard <millard.matthew@gmail.com>
%
% SPDX-License-Identifier: MIT
%
%%
function eqSoln = calcVEXATTitinPassiveEquilibrium(...
                    lceN, ...
                    shiftPEE, ...
                    scalePEE, ...
                    sarcomere, ...
                    vexatQuadraticCurves, ...
                    vexatQuadraticTitinCurves,...
                    tol, iterMax)

lambda=sarcomere.extraCellularMatrixPassiveForceFraction;

%%
% The proximal and distal titin elements are in series. We distribute
% the shift in accordance to the relative compliance of each element
%%
k1THN = vexatQuadraticTitinCurves.forceLengthProximalTitinCurve.dydxEnd(1,2);
k2THN = vexatQuadraticTitinCurves.forceLengthDistalTitinCurve.dydxEnd(1,2);

shift1THN = (0.5*shiftPEE)*((k2THN)/(k1THN+k2THN));
shift2THN = (0.5*shiftPEE)*((k1THN)/(k1THN+k2THN));
shiftECM  = 0.5*shiftPEE;

xH      = lceN*0.5;
f       = 0.1;
df      = 0;
lerr    = Inf;
iter    = 0;
%iterMax = 100;

while(abs(lerr) > tol && iter < iterMax)

    lPH   = calcQuadraticBezierYFcnXDerivative(f/scalePEE,...
                vexatQuadraticTitinCurves.forceLengthProximalTitinInverseCurve,0)+shift1THN;
    dPH   = calcQuadraticBezierYFcnXDerivative(f/scalePEE,...
                vexatQuadraticTitinCurves.forceLengthProximalTitinInverseCurve,1)*(1/scalePEE);

    lDH   = calcQuadraticBezierYFcnXDerivative(f/scalePEE,...
                vexatQuadraticTitinCurves.forceLengthDistalTitinInverseCurve,0)+shift2THN;
    dDH  = calcQuadraticBezierYFcnXDerivative(f/scalePEE,...
                vexatQuadraticTitinCurves.forceLengthDistalTitinInverseCurve,1)*(1/scalePEE);

    lerr = (lPH + lDH ...
            + sarcomere.ZLineToT12NormLengthAtOptimalFiberLength ...
            + sarcomere.IGDFixedNormLengthAtOptimalFiberLength)...
            -xH;
    dlerr= dPH + dDH;
    df   = -lerr/dlerr;
    f    = f+df;

    if(f<=0)
        f = calcQuadraticBezierYFcnXDerivative(0,...
             vexatQuadraticTitinCurves.forceLengthDistalTitinCurve,0)*scalePEE;
    end

    iter=iter+1;
end
assert(abs(lerr)<=1e-6);

f1N = scalePEE*(1-lambda)*calcQuadraticBezierYFcnXDerivative(...
                        lPH-shift1THN,...
                        vexatQuadraticTitinCurves.forceLengthProximalTitinCurve,0);

f2N = scalePEE*(1-lambda)*calcQuadraticBezierYFcnXDerivative(...
                        lDH-shift2THN,...
                        vexatQuadraticTitinCurves.forceLengthDistalTitinCurve,0);

fecmN = scalePEE*lambda*calcQuadraticBezierYFcnXDerivative(...
                    lceN*0.5-shiftECM,...
                    vexatQuadraticCurves.forceLengthECMHalfCurve,0);    

eqSoln.err = abs(lerr);
eqSoln.iter=iter;
eqSoln.l1N = lPH;
eqSoln.l2N = lDH;
eqSoln.f1N = f1N;
eqSoln.f2N = f2N;
eqSoln.fecmN=fecmN;


