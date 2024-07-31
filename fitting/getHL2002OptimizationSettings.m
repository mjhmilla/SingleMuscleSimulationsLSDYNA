%%
% SPDX-FileCopyrightText: 2024 Matthew Millard <millard.matthew@gmail.com>
%
% SPDX-License-Identifier: MIT
%
%%
function fitInfo = getHL2002OptimizationSettings(...
                    modelParams,fitInfo,typeOfFitting)



switch typeOfFitting
    case 0
        %Solve for the best starting length
        timeFinal = 2.37;
        timeAnalysis = timeFinal;
        optimizationVariable = 'lp0HL2002';
        optimizationDelta = modelParams.lp0HL2002*0.1; 
        optimizationBounds = ...
            [modelParams.lp0HL2002*0.5,modelParams.lp0HL2002*2];
    case 1
        %Solve for the best passive force
        timeFinal = 12;
        timeAnalysis = timeFinal;

        switch fitInfo.model
            case 'mat156'
                optimizationVariable = '';
                optimizationDelta = 0; 
                optimizationBounds = []; 
                assert(0,'Error: Not yet implemented');
            case 'umat41'
                optimizationVariable = 'FPEE';
                optimizationDelta = modelParams.FPEE*0.25; 
                optimizationBounds = ...
                    [modelParams.FPEE*0.5,modelParams.FPEE*2];
            case 'umat43'
                optimizationVariable = 'scalePEE';
                optimizationDelta = modelParams.scalePEE*0.25; 
                optimizationBounds = ...
                    [modelParams.scalePEE*0.5,modelParams.scalePEE*2];
        end
    case 2
        %umat43: Solve for the best lpevkN
        timeFinal = 3.37;
        timeAnalysis = [2.37,3.37];

        optimizationVariable = 'lPevkPtN';
        optimizationDelta = modelParams.lPevkPtN*0.25;
        optimizationBounds = [0,1];
        
    case 3
        %umat43: Solve for the best betaA
        timeFinal = 8.31;
        timeAnalysis = [3.37,8.31];

        optimizationVariable = 'beta1AHN';
        optimizationDelta = modelParams.beta1AHN*0.25; 
        optimizationBounds = [1,100];
        
end

fitInfo.simulationType          ='eccentric';
fitInfo.timeFinal               = timeFinal;
fitInfo.timeAnalysis            = timeAnalysis;
fitInfo.optimizationVariable    = optimizationVariable;
fitInfo.optimizationDelta       = optimizationDelta;
fitInfo.optimizationBounds      = optimizationBounds;


