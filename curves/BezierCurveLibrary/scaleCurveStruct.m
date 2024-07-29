%%
% SPDX-FileCopyrightText: 2024 Matthew Millard <millard.matthew@gmail.com>
%
% SPDX-License-Identifier: MIT
%
function curveStruct = scaleCurveStruct(xScale,yScale,curveStruct)

curveStruct.xpts=curveStruct.xpts.*xScale;
curveStruct.ypts=curveStruct.ypts.*yScale;

curveStruct.xEnd=curveStruct.xEnd.*xScale;
curveStruct.yEnd=curveStruct.yEnd.*yScale;

curveStruct.dydxEnd=curveStruct.dydxEnd.*(yScale/xScale);
curveStruct.dydxEnd=curveStruct.dydxEnd.*((yScale/xScale)*(yScale/xScale));

assert(isempty(curveStruct.integral)==1);