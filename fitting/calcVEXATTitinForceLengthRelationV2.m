function vexatCurves = calcVEXATTitinForceLengthRelationV2(...
                                umat43,...
                                sarcomere,...
                                curvesDefault,...
                                titinCurvesZero,...
                                titinCurvesOne,...
                                vexatCurves,...
                                flag_plotVEXATTitinForceLengthCurves)


% assert(abs(umat43.lPevkPtN -sarcomere.normPevkToActinAttachmentPoint)<1e-6,...
%        ['Error: The titin curves used to generate these plots have been',...
%         'made using a fixed value for lPevkPtN that differs from the ',...
%         'the settings of umat43. This can be improved by interpolating',...
%         'the titin curves for lPevkPtN=0 and lPevkPtN=1 as is done in',...
%         'the Fortran model. In the interest of time I have not done this',...
%         'here.']);

fpeDomain = curvesDefault.('fiberForceLengthCurve').xEnd ...
                 +[-0.01,0.01];  
n = 200;

lce0 = min(fpeDomain)*0.4;
lce1 = max(fpeDomain) + (max(fpeDomain)-min(fpeDomain));
samples = [lce0:((lce1-lce0)/(n-1)):lce1]';


%Interpolate the curves
lpevkN = umat43.lPevkPtN;
A = 1-lpevkN;
B = lpevkN;

titinCurveNames = fields(titinCurvesZero);
titinCurves = titinCurvesZero;

for i=1:1:length(titinCurveNames)
    titinCurves.(titinCurveNames{i}) = ...
        interpolateQuadraticBezierCurve(...
            titinCurvesZero.(titinCurveNames{i}),...
            titinCurvesOne.(titinCurveNames{i}),A,B);
end

shiftPEE = umat43.shiftPEE;
scalePEE = umat43.scalePEE;

%%
% The fECM curve is expressed as a half sarcomere element
%%
shiftECM = 0.5*shiftPEE;

%%
% The proximal and distal titin elements are inseries. We distribute
% the shift in accordance to the relative compliance of each element
%%

k1THN = titinCurves.forceLengthProximalTitinCurve.dydxEnd(1,2);
k2THN = titinCurves.forceLengthDistalTitinCurve.dydxEnd(1,2);

shift1THN = (0.5*shiftPEE)*((k2THN)/(k1THN+k2THN));
shift2THN = (0.5*shiftPEE)*((k1THN)/(k1THN+k2THN));

vexatCurves.fecm.lceNAT = zeros(size(samples));
vexatCurves.fecm.fceNAT = zeros(size(samples));

vexatCurves.f1.lceNAT = zeros(size(samples));
vexatCurves.f1.fceNAT = zeros(size(samples));

vexatCurves.f2.lceNAT = zeros(size(samples));
vexatCurves.f2.fceNAT = zeros(size(samples));

lambda = sarcomere.extraCellularMatrixPassiveForceFraction;

for i=1:1:length(samples)
    lceN = samples(i,1);
    fibKin = calcFixedWidthPennatedFiberKinematicsAlongTendon(lceN*umat43.lceOpt,...
                                    0,...
                                    umat43.lceOpt,...
                                    umat43.penOpt);   

    lceAT   = fibKin.fiberLengthAlongTendon;
    alpha   = fibKin.pennationAngle;
    lceNAT  = lceAT/umat43.lceOpt;

    %Solve for the lengths such that l1+l2 + LFixed = lceN*0.5 and
    % f1=f2;

    xH = lceN*0.5;
    f = 0.1;
    df = 0;
    lerr = Inf;
    iter=0;
    iterMax=100;
    while(abs(lerr) > 1e-6 && iter < iterMax)
    
        lPH   = calcQuadraticBezierYFcnXDerivative(f/scalePEE,...
                    titinCurves.forceLengthProximalTitinInverseCurve,0)+shift1THN;
        dPH   = calcQuadraticBezierYFcnXDerivative(f/scalePEE,...
                    titinCurves.forceLengthProximalTitinInverseCurve,1)*(1/scalePEE);
    
        lDH   = calcQuadraticBezierYFcnXDerivative(f/scalePEE,...
                    titinCurves.forceLengthDistalTitinInverseCurve,0)+shift2THN;
        dDH  = calcQuadraticBezierYFcnXDerivative(f/scalePEE,...
                    titinCurves.forceLengthDistalTitinInverseCurve,1)*(1/scalePEE);
    
        lerr = (lPH + lDH ...
                + sarcomere.ZLineToT12NormLengthAtOptimalFiberLength ...
                + sarcomere.IGDFixedNormLengthAtOptimalFiberLength)...
                -xH;
        dlerr= dPH + dDH;
        df   = -lerr/dlerr;
        f    = f+df;

        if(f<=0)
            f = calcQuadraticBezierYFcnXDerivative(0,...
                 titinCurves.forceLengthDistalTitinCurve,0)*scalePEE;
        end
    
        iter=iter+1;
    end
    assert(abs(lerr)<=1e-6);


    f1N = scalePEE*(1-lambda)*calcQuadraticBezierYFcnXDerivative(...
                                lPH-shift1THN,...
                                titinCurves.forceLengthProximalTitinCurve,0);
    f1NAT = f1N*cos(alpha);

    f2N = scalePEE*(1-lambda)*calcQuadraticBezierYFcnXDerivative(...
                                lDH-shift2THN,...
                                titinCurves.forceLengthDistalTitinCurve,0);
    f2NAT = f2N*cos(alpha);

    fecmN = scalePEE*lambda*calcQuadraticBezierYFcnXDerivative(...
                            lceNAT*0.5-shiftECM,...
                            curvesDefault.forceLengthECMHalfCurve,0);    
    fecmNAT = fecmN*cos(alpha);

    assert(abs(f1N-f2N)<1e-6);

    %Just to check
    fpeN = scalePEE*calcQuadraticBezierYFcnXDerivative(...
                    lceN-shiftPEE,...
                    curvesDefault.fiberForceLengthCurve,...
                    0);

    %fprintf('%1.3f\n',abs(fpeN - (fecmN+f2N)));
    assert(abs(fpeN-(f2N+fecmN))<0.025,...
          ['Error: titin and ECM curves are not equivalent to the',...
          ' target parallel element curve']);

    vexatCurves.fecm.lceNAT(i,1)=lceNAT;
    vexatCurves.fecm.fceNAT(i,1)=fecmNAT;

    vexatCurves.f1.lceNAT(i,1)=lceNAT;
    vexatCurves.f1.fceNAT(i,1)=f1NAT;

    vexatCurves.f2.lceNAT(i,1)=lceNAT;
    vexatCurves.f2.fceNAT(i,1)=f2NAT;

    %When active the f1 section has a fixed length and only the 
    %f2 section stretches, at least in the limit when the titin-actin 
    % damper really fixes titin.
    if(lceN <= 2*umat43.lceHNLb1A || i == 1)
        l12Fixed =  lPH ...
                    + sarcomere.ZLineToT12NormLengthAtOptimalFiberLength ...
                    + sarcomere.IGDFixedNormLengthAtOptimalFiberLength;
    end
    
    lceNActive = (l12Fixed + lDH)*2;

    fibKinActive = calcFixedWidthPennatedFiberKinematicsAlongTendon(lceNActive*umat43.lceOpt,...
                                    0,...
                                    umat43.lceOpt,...
                                    umat43.penOpt);   

    lceATActive   = fibKinActive.fiberLengthAlongTendon;
    alphaActive   = fibKinActive.pennationAngle;
    lceNATActive  = lceATActive/umat43.lceOpt;    

    fecmNActive = scalePEE*lambda*calcQuadraticBezierYFcnXDerivative(...
                            lceNActive*0.5-shiftECM,...
                            curvesDefault.forceLengthECMHalfCurve,0);    

    vexatCurves.active.lceNAT(i,1)= lceNActive*cos(alphaActive);
    vexatCurves.active.fceNAT(i,1)= (fecmNActive+f2N)*cos(alphaActive);

end

here=1;



