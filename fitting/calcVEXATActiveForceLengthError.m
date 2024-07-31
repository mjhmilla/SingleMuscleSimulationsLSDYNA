%%
% SPDX-FileCopyrightText: 2024 Matthew Millard <millard.matthew@gmail.com>
%
% SPDX-License-Identifier: MIT
%
%%
function errVec = calcVEXATActiveForceLengthError(args,...
                                    defaultSoln,...
                                    umat43,...
                                    keyPointsExp,...
                                    activeForceLengthCurve,...
                                    tendonForceLengthInverseNormCurve)



lceOptAT    = defaultSoln.lceOptAT*args(1,1);
fceOptAT    = defaultSoln.fceOptAT*args(2,1);
lceNAT0a  = args(3,1);

lceOpt = lceOptAT/cos(umat43.penOpt);
fceOpt = fceOptAT/cos(umat43.penOpt);

ltSlk = umat43.tdnToCe*lceOpt;

umat43TendonParams.fceOpt   = fceOpt;
umat43TendonParams.et       = umat43.et;
umat43TendonParams.ltSlk    = ltSlk;


% The experimental data to measure the passive and active force length
% relation has measurments at the same musculotendon length. Due to
% tendon elasticity unfortunately these measurements are not at the 
% same CE length. Here I'll fit a temporary quadratic model to the
% passive data and use it to evaluate the passive curve at the CE
% lengths of the active measurements.
tendonType_0Umat41_1Umat43=1;
[falPts,fpePts] = ...
    calcActiveForceLengthWithElasticTendonV2(...
            keyPointsExp.fl.l*keyPointsExp.nms.l,...
            keyPointsExp.fl.fmt*keyPointsExp.nms.f,...
            keyPointsExp.fl.l*keyPointsExp.nms.l,...
            keyPointsExp.fl.fpe*keyPointsExp.nms.f,...
            keyPointsExp.fl.clusters,...
            lceNAT0a*lceOpt,...
            umat43TendonParams,...
            tendonForceLengthInverseNormCurve,...
            [],...
            tendonType_0Umat41_1Umat43);

expLceNAT = falPts.lceAT ./ lceOpt;
%expFceNAT = (keyPointsExp.fl.fmt*keyPointsExp.nms.f...
%             - exp.fl.fpe)./fceOpt;
expFceNAT = falPts.fceAT./fceOpt;

errVec = zeros(size(expLceNAT));

for i=1:1:length(errVec)
    
    fibKin = calcFixedWidthPennatedFiberKinematics(expLceNAT(i,1)*lceOpt,...
                                        0,...
                                        lceOpt,...
                                        umat43.penOpt);

    lce     = fibKin.fiberLength;
    alpha   = fibKin.pennationAngle;
    lceN    = lce/lceOpt;

    falN = calcQuadraticBezierYFcnXDerivative(lceN,activeForceLengthCurve,0);

    errVec(i,1)= falN*cos(alpha)-expFceNAT(i,1);
end
here=1;