function [umat43,vexatCurves]= fitVEXATTendon(umat43,ktNIso,...
                                  tendonNormCurve,vexatCurves)

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
etIso   = ktNNIso/ktNIso;
umat43.et=etIso;

%%
%Sample the curves
%%

npts=100;
etN = [0:(etIso/(npts-1)):etIso]';
ltN = 1+etN;
ltN = [0;ltN];
ftN = zeros(size(ltN));
ktN = zeros(size(ltN));

for i=1:1:length(ltN)
    etN = (ltN(i,1)-1)/etIso;
    ftN(i,1)=calcQuadraticBezierYFcnXDerivative(etN,tendonNormCurve,0);
    ktN(i,1)=calcQuadraticBezierYFcnXDerivative(etN,tendonNormCurve,1)*(1/umat43.et);
end

vexatCurves.ft.ltN=ltN;
vexatCurves.ft.ftN=ftN;
vexatCurves.ft.ktN=ktN;

