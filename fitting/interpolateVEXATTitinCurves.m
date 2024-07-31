%%
% SPDX-FileCopyrightText: 2024 Matthew Millard <millard.matthew@gmail.com>
%
% SPDX-License-Identifier: MIT
%
%%
function titinCurves = interpolateVEXATTitinCurves(lPevkPtN,...
                                titinCurvesZero,...
                                titinCurvesOne)

A = 1-lPevkPtN;
B = lPevkPtN;

titinCurveNames = fields(titinCurvesZero);
titinCurves = titinCurvesZero;

for i=1:1:length(titinCurveNames)
    titinCurves.(titinCurveNames{i}) = ...
        interpolateQuadraticBezierCurve(...
            titinCurvesZero.(titinCurveNames{i}),...
            titinCurvesOne.(titinCurveNames{i}),A,B);
end


