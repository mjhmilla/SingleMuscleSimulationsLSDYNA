function eqSoln = calcEHTMMIsometricEquilibrium(...
                        activation,...
                        pathLength,...
                        umat41)


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
        lceATN= lceAT/umat41.lceOptAT;


        falN = calcFisomUmat41(lceAT, ...
                    umat41.lceOptAT,...
                    umat41.dWdes,...
                    umat41.nuCEdes, ...
                    umat41.dWasc, ...
                    umat41.nuCEasc);


        %Evaluate the passive force length relation
        fpe = calcFpeeUmat41(lceAT, ...
                umat41.lceOptAT,...
                umat41.dWdes,...
                umat41.fceOptAT,...
                umat41.FPEE,...
                umat41.LPEE0,...
                umat41.nuPEE);

        %Evaluate the tendon force
        lt  = pathLength - lceAT;
        ft  = calcFseeUmat41(...
                lt,...
                umat41.ltSlk,...
                umat41.dUSEEnll,...
                umat41.duSEEl,...
                umat41.dFSEE0);

        fceAT = activation*(falN)*umat41.fceOptAT + fpe;

        %Evaluate the error
        errTest = abs(fceAT - ft);

        iter=iter+1;

        if(errTest < errBest)
                varBest=varTest;
                errBest=errTest;
                eqSoln.lceNAT           = lceAT/umat41.lceOptAT;
                eqSoln.fceNAT           = fceAT/umat41.fceOptAT;
                eqSoln.ftN              = ft/umat41.fceOptAT;
                eqSoln.falN             = falN;
                eqSoln.fpeN             = fpe/umat41.fceOptAT; 
                eqSoln.ferr             = errBest;
            break
        end
    end
    if(iterBisection > 1)
        delta=delta*0.5;
    end
end





