function lt = calcVEXATTendonLength(fmt,fceOpt,...
                        tendonForceLengthInverseNormCurve,etIso,ltSlk)

lt = zeros(size(fmt));
for i=1:1:length(fmt)
    ft      = fmt(i,1);
    ftN     = ft/fceOpt;
    etN     = calcQuadraticBezierYFcnXDerivative(ftN,...
                tendonForceLengthInverseNormCurve,0);
    et      = etN*etIso;
    lt(i,1) = (1+et)*ltSlk;
end
