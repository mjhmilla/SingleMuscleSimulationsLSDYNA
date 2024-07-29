%%
% SPDX-FileCopyrightText: 2024 Matthew Millard <millard.matthew@gmail.com>
%
% SPDX-License-Identifier: MIT
%
function muscleCurve = readBezierCurveFromCSV(fullFilePath)


muscleCurve = ...
    struct( 'xpts',[],   'ypts',[],...
            'xEnd',[],   'yEnd',[],...
            'dydxEnd',[],'d2ydx2End',[],'integral',[]);

fid = fopen(fullFilePath,'r');

line=fgetl(fid);

assert(contains(line,'xpts'));

[matrix,line] = readMatrixFromCSV(fid,'ypts');
assert(contains(line,'ypts'));
muscleCurve.xpts=matrix;

[matrix,line] = readMatrixFromCSV(fid,'xEnd');
assert(contains(line,'xEnd'));
muscleCurve.ypts=matrix;

[matrix,line] = readMatrixFromCSV(fid,'yEnd');
assert(contains(line,'yEnd'));
muscleCurve.xEnd=matrix;

[matrix,line] = readMatrixFromCSV(fid,'dydxEnd');
assert(contains(line,'dydxEnd'));
muscleCurve.yEnd=matrix;

[matrix,line] = readMatrixFromCSV(fid,'d2ydx2End');
assert(contains(line,'d2ydx2End'));
muscleCurve.dydxEnd=matrix;


