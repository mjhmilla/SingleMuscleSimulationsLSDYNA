function eqSoln = calcVEXATIsometricEquilibrium(...
                        activation,...
                        pathLength,...
                        params,...
                        sarcomere,...
                        vexatQuadraticCurves,...
                        vexatQuadraticTitinCurves)

shiftPEE = params.shiftPEE;
scalePEE = params.scalePEE;



maximumBisections = 20;

errBest = inf;
varBest   = 0.5;

delta = 0.25; %As in a quarter of the path length
iter = 0;
for iterBisection=1:1:maximumBisections
    
    for iterSign = 1:1:2
        step=delta;
        switch iterSign
            case 1
                step = 1*delta;
            case 2
                step =-1*delta;                
        end
        if(iterBisection==1)
            step=0;
        end

        varTest=varBest+step;
        lceAT = pathLength*varTest;
        %%
        %Evaluate the difference in force beween the CE and the tendon
        %at this length.
        %%

        %Evaluate the CE length and pennation angle
        fibKin = calcFixedWidthPennatedFiberKinematics(...
                    lceAT,0,params.lceOpt,params.penOpt);

        lce     = fibKin.fiberLength;
        alpha   = fibKin.pennationAngle;        
        lceN    = lce/params.lceOpt;
        
        %Active force length relation
        falN = calcQuadraticBezierYFcnXDerivative(lceN,...
           vexatQuadraticCurves.activeForceLengthCurve,0);

        %Force-velocity relation: isometric:
        fvN = 1;

        %Evaluate the force equilibrium between the two titin segments
        titinTol = 1e-8;
        titinIterMax=100;
        titinSoln = calcVEXATTitinPassiveEquilibrium(lceN, ...
                shiftPEE, scalePEE,...
                sarcomere, ...
                vexatQuadraticCurves, ...
                vexatQuadraticTitinCurves,...
                titinTol, titinIterMax);    

        f1N=titinSoln.f1N;
        f2N=titinSoln.f2N;
        fecmN=titinSoln.fecmN;

        %Evaluate the ce force
        fceN  = activation*falN*fvN + (fecmN+f2N);
        fceNAT= fceN*cos(alpha);

        %Evaluate the tendon force
        lt  = pathLength - lceAT;
        ltN = lt / params.ltSlk;
        et = ltN - 1;
        etN = et / params.et;
        ftN = calcQuadraticBezierYFcnXDerivative(etN,...
                vexatQuadraticCurves.tendonForceLengthNormCurve,0);

        %Evaluate the error
        errTest = abs(fceNAT - ftN);

        iter=iter+1;

        if(errTest < errBest)
                varBest=varTest;
                errBest=errTest;
                eqSoln.lceNAT           = lceAT/params.lceOpt;
                eqSoln.fceNAT           = fceNAT;
                eqSoln.ftN              = ftN;
                eqSoln.lceN             = lceN;
                eqSoln.pennationAngle   = alpha;
                eqSoln.falN             = falN;
                eqSoln.fvN              = fvN;
                eqSoln.fecmN            = fecmN;
                eqSoln.f1N              = f1N;
                eqSoln.f2N              = f2N;
                eqSoln.ltN              = ltN;
                eqSoln.ferr             = errBest;
                eqSoln.l12Err           = titinSoln.err;
                eqSoln.iter             = titinSoln.iter;
            break
        end
    end
    if(iterBisection > 1)
        delta=delta*0.5;
    end
end





