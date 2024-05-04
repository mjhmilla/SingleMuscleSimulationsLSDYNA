function [umat43]= fitVEXATTendon(umat43,fitTendonParams,...
                                                tendonNormCurve)

%The tendon curve is normalized so that at a strain of 1 it reaches
%a force of 1. This is used using an argument of 
% tendonStrain/tendonStrainAtOneNormForce. And so, this is pretty
% easy to fit since
% 
% etN = et/etIso
% ft = fcn(etN)
%
% Applying the chain rule:
%
% kt = (d/detN)fcn(etN) * d(etN)/d(et)
%    = (d/detN)fcn(etN) * (1/etIso)

etN     = 1;
ktNNIso = calcQuadraticBezierYFcnXDerivative(etN,tendonNormCurve,1);
etIso   = ktNNIso/fitTendonParams.ktNIso;
umat43.et=etIso;


