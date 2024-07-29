%%
% SPDX-FileCopyrightText: 2024 Matthew Millard <millard.matthew@gmail.com>
%
% SPDX-License-Identifier: MIT
%%
function errV = calcFittedFiberForceLengthCurveError( params, data, scaling, ...
    fixedParams,flag_useOctave)

xshift = params(1)./scaling;
xwidth = params(2)./scaling;
kLow   = fixedParams(1,1);
kNum   = fixedParams(1,2);

normLengthZero = xshift;
normLengthToe  = xwidth + xshift;
fToe  = 1;
kZero = fixedParams(1,3);
yZero = fixedParams(1,4);

kToe  = kNum/(normLengthToe-normLengthZero);
curviness= fixedParams(1,5);

computeIntegral = 0;

fiberForceLengthCurve = createFiberForceLengthCurve2021(normLengthZero,...
                                                    normLengthToe,...
                                                    fToe,...
                                                    yZero,...
                                                    kZero,...
                                                    kLow,...
                                                    kToe,...
                                                    curviness,...
                                                    0,...
                                                    'fitted',...
                                                    flag_useOctave);
                                                
errV = zeros(size(data,1),1);

for(i=1:1:size(data,1))
   errV(i) = (calcBezierYFcnXDerivative(data(i,1),fiberForceLengthCurve,0)...
             - data(i,2))*scaling;
   
end
