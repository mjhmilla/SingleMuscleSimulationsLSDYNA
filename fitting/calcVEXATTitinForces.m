%%
% SPDX-FileCopyrightText: 2024 Matthew Millard <millard.matthew@gmail.com>
%
% SPDX-License-Identifier: MIT
%
%%
function eqSoln = calcVEXATTitinForces(...
                    lceN, lPH,...
                    shiftPEE, ...
                    scalePEE, ...
                    sarcomere, ...
                    vexatQuadraticCurves, ...
                    vexatQuadraticTitinCurves)

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




f1N = scalePEE*(1-lambda)*calcQuadraticBezierYFcnXDerivative(...
                        lPH-shift1THN,...
                        vexatQuadraticTitinCurves.forceLengthProximalTitinCurve,0);

lDH = lceN*0.5 ...
    - lPH ...
    - sarcomere.ZLineToT12NormLengthAtOptimalFiberLength ...
    - sarcomere.IGDFixedNormLengthAtOptimalFiberLength;

f2N = scalePEE*(1-lambda)*calcQuadraticBezierYFcnXDerivative(...
                        lDH-shift2THN,...
                        vexatQuadraticTitinCurves.forceLengthDistalTitinCurve,0);

fecmN = scalePEE*lambda*calcQuadraticBezierYFcnXDerivative(...
                    lceN*0.5-shiftECM,...
                    vexatQuadraticCurves.forceLengthECMHalfCurve,0);    


eqSoln.l1N = lPH;
eqSoln.l2N = lDH;
eqSoln.f1N = f1N;
eqSoln.f2N = f2N;
eqSoln.fecmN=fecmN;


