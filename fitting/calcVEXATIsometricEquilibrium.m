%%
% SPDX-FileCopyrightText: 2024 Matthew Millard <millard.matthew@gmail.com>
%
% SPDX-License-Identifier: MIT
%
%%
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
        useElasticTendon=1;
        modelState = calcVEXATIsometricState(...
                            activation,...
                            lceAT,...
                            pathLength,...
                            params,...
                            sarcomere,...
                            vexatQuadraticCurves,...
                            vexatQuadraticTitinCurves,...
                            useElasticTendon);        

        %Evaluate the error
        errTest = abs(modelState.fceNAT - modelState.ftN);

        iter=iter+1;

        if(errTest < errBest)
                varBest=varTest;
                errBest=errTest;
                eqSoln.lceNAT           = modelState.lceNAT;
                eqSoln.fceNAT           = modelState.fceNAT;
                eqSoln.ftN              = modelState.ftN;
                eqSoln.lceN             = modelState.lceN;
                eqSoln.pennationAngle   = modelState.pennationAngle;
                eqSoln.falN             = modelState.falN;
                eqSoln.fvN              = modelState.fvN;
                eqSoln.fecmN            = modelState.fecmN;
                eqSoln.f1N              = modelState.f1N;
                eqSoln.f2N              = modelState.f2N;
                eqSoln.ltN              = modelState.ltN;
                eqSoln.ferr             = errBest;
            break
        end
    end
    if(iterBisection > 1)
        delta=delta*0.5;
    end
end





