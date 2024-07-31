%%
% SPDX-FileCopyrightText: 2024 Matthew Millard <millard.matthew@gmail.com>
%
% SPDX-License-Identifier: MIT
%
%%
function curveC = interpolateQuadraticBezierCurve(curveA,curveB,A,B)

assert(abs(A+B-1) < 1e-6);


curveC.xpts = A.*curveA.xpts + B.*curveB.xpts;
curveC.ypts = A.*curveA.ypts + B.*curveB.ypts;
curveC.xEnd = A.*curveA.xEnd + B.*curveB.xEnd;
curveC.yEnd = A.*curveA.yEnd + B.*curveB.yEnd;

dxPts =zeros(2,2);
ncol = size(curveA.xpts,2);
dxPts(1,1) = (curveC.xpts(2,1)   -curveC.xpts(1,1)   )*(ncol-1.0);
dxPts(2,1) = (curveC.xpts(3,1)   -curveC.xpts(2,1)   )*(ncol-1.0);
dxPts(1,2) = (curveC.xpts(2,ncol)-curveC.xpts(1,ncol))*(ncol-1.0);
dxPts(2,2) = (curveC.xpts(3,ncol)-curveC.xpts(2,ncol))*(ncol-1.0);

d2xPts(1,1) = (dxPts(2,1) -dxPts(1,1)  )*(ncol-2.0);
d2xPts(1,2) = (dxPts(2,2) -dxPts(1,2)  )*(ncol-2.0);

dyPts(1,1) = (curveC.ypts(2,1)   -curveC.ypts(1,1)   )*(ncol-1.0);
dyPts(2,1) = (curveC.ypts(3,1)   -curveC.ypts(2,1)   )*(ncol-1.0);
dyPts(1,2) = (curveC.ypts(2,ncol)-curveC.ypts(1,ncol))*(ncol-1.0);
dyPts(2,2) = (curveC.ypts(3,ncol)-curveC.ypts(2,ncol))*(ncol-1.0);

d2yPts(1,1) = (dyPts(2,1) -dyPts(1,1)  )*(ncol-2.0);
d2yPts(1,2) = (dyPts(2,2) -dyPts(1,2)  )*(ncol-2.0);

curveC.dydxEnd(1,1) = dyPts(1,1)/dxPts(1,1);
curveC.dydxEnd(1,2) = dyPts(2,2)/dxPts(2,2);

t1 = 1.0/dxPts(1,1);
t3 = dxPts(1,1)*dxPts(1,1);
curveC.d2ydx2End(1,2) = (d2yPts(1,1)*t1 - dyPts(1,1)/t3*d2xPts(1,1))*t1;

t1 = 1.0/dxPts(2,2);
t3 = dxPts(2,2)*dxPts(2,2);
curveC.d2ydx2End(1,2) = (d2yPts(1,2)*t1 - dyPts(2,2)/t3*d2xPts(1,2))*t1;


curveC.integral = [];