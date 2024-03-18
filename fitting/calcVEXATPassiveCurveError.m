function errVec = calcVEXATPassiveCurveError(arg,umat43,umat43QuadraticBezierCurves,...
                        expDataFpe,errorScaling)

shiftPEE = arg(1,1);
%scalePEE = arg(2,1);

errVec = zeros(size(expDataFpe.lmtNAT));

for i=1:1:length(expDataFpe.lmtNAT)
    expFpeN = expDataFpe.fmtNAT(i,1);

    lceN = calcQuadraticBezierYFcnXDerivative(expFpeN/umat43.scalePEE,...
          umat43QuadraticBezierCurves.fiberForceLengthInverseCurve,0);  

    %Ignoring pennation for two reasons:
    %-it complicates this function (iteration would be needed)
    %-a cat soleus has a very small pennation angle

    lceNAT = lceN-shiftPEE;

    ltN = calcQuadraticBezierYFcnXDerivative(expFpeN,...
          umat43QuadraticBezierCurves.tendonForceLengthInverseCurve,0);  

    dltN = ltN - 1;
    lceNAT_dltN = lceNAT  + (dltN*umat43.ltSlk)/umat43.lceOpt;

    errVec(i,1)=lceNAT_dltN - expDataFpe.lmtNAT(i,1);
end
errVec = errVec./errorScaling;