%%
% SPDX-FileCopyrightText: 2024 Matthew Millard <millard.matthew@gmail.com>
%
% SPDX-License-Identifier: MIT
%%
function errorSumSq = calcActiveTitinParameterError(...
                        params,...
                        paramNorm, ...
                        errorSumSqNorm,...
                        typeCostFunction,...
                        musculotendonPropertiesOpus31, ...
                        sarcomerePropertiesOpus31,...
                        normMuscleCurves,...
                        passiveCurveSettings,...
                        expConfigHerzogLeonard2002,...
                        flag_useElasticTendon,...
                        dataFolder,...
                        flag_plot,...
                        flag_useOctave)




parameterA = params(1,1)*paramNorm(1,1);
parameterB = params(2,1)*paramNorm(2,1);

switch sarcomerePropertiesOpus31.titinModelType
    case 0
        parameterA = min(parameterA,1);
        parameterA = max(parameterA,0);
        parameterB = max(parameterB,0);

        sarcomerePropertiesOpus31.normPevkToActinAttachmentPoint = ...
            parameterA;
        sarcomerePropertiesOpus31.normMaxActiveTitinToActinDamping = ...
            parameterB;
    case 1
        parameterA = min(parameterA,1);
        parameterA = max(parameterA,0);
        parameterB = max(parameterB,0);

        sarcomerePropertiesOpus31.extraCellularMatrixPassiveForceFraction = ...
            parameterA;
        sarcomerePropertiesOpus31.normActivePevkDamping = ...
            parameterB;

        flag_computeCurveIntegrals=0;
        flag_computeIntegral=0;
         

        normMuscleCurvesUpd.forceLengthECMHalfCurve  = ...
          createFiberForceLengthCurve2021((passiveCurveSettings.normLengthZero)*0.5,...
                                      (passiveCurveSettings.normLengthToe)*0.5,...
                                      parameterA,...
                                      passiveCurveSettings.yZero*(lambdaECM*2),...
                                      passiveCurveSettings.kZero*(lambdaECM*2),...
                                      passiveCurveSettings.kLow*(lambdaECM*2),...
                                      passiveCurveSettings.kToe*(lambdaECM*2),...
                                      passiveCurveSettings.curviness,...
                                      flag_computeCurveIntegrals,...
                                      musculotendonPropertiesOpus31.name,...
                                      flag_useOctave);  
    otherwise
        assert(0,'titinModelType must be 0 (sticky-spring) or 1 (stiff spring');
end




flag_useElasticIgD        = 1;
flag_createTwoSidedCurves = 0;
flag_computeCurveIntegrals=0;

[normMuscleCurves.forceLengthProximalTitinCurve, ...
    normMuscleCurves.forceLengthProximalTitinInverseCurve,...
 normMuscleCurves.forceLengthDistalTitinCurve, ...
    normMuscleCurves.forceLengthDistalTitinInverseCurve,...
 normMuscleCurves.forceLengthIgPTitinCurve, ...
    normMuscleCurves.forceLengthIgPTitinInverseCurve,...
 normMuscleCurves.forceLengthPevkTitinCurve, ...
    normMuscleCurves.forceLengthPevkTitinInverseCurve,...
 normMuscleCurves.forceLengthIgDTitinCurve, ...
    normMuscleCurves.forceLengthIgDTitinInverseCurve] ...
          = createTitinCurves2022( normMuscleCurves.fiberForceLengthCurve,...                                   
                                   passiveCurveSettings,...
                                   normMuscleCurves.forceLengthECMHalfCurve,...
                                   sarcomerePropertiesOpus31,...
                                   musculotendonPropertiesOpus31.name,...
                                   flag_createTwoSidedCurves,...
                                   flag_computeCurveIntegrals,...
                                   flag_useElasticIgD,...
                                   sarcomerePropertiesOpus31.titinModelType,...
                                   flag_useOctave);






%% Run the simulation of Herzog & Leonard


tmp = load('output/structs/normalizedFiberLengthStartHerzogLeonard2002.mat',...
 'lceNStart');

nominalNormalizedFiberLength  = tmp.lceNStart;%0.98;
outputFileEndingOpus31 = 'fitting';

flag_simulateActiveStretch  =1;
flag_simulatePassiveStretch =0;
flag_simulateStatic         =0;

%tstart=tic;
[success] = runHerzogLeonard2002SimulationsOpus31(...
                        nominalNormalizedFiberLength,...
                        expConfigHerzogLeonard2002.nominalForce,...                            
                        expConfigHerzogLeonard2002.timeSpan,...
                        expConfigHerzogLeonard2002.lengthRampKeyPoints,...
                        expConfigHerzogLeonard2002.stimulationKeyTimes,...
                        flag_useElasticTendon,...
                        musculotendonPropertiesOpus31,...
                        sarcomerePropertiesOpus31,...
                        normMuscleCurves,...
                        outputFileEndingOpus31, ...
                        dataFolder,...
                        flag_simulateActiveStretch,...
                        flag_simulatePassiveStretch,...
                        flag_simulateStatic,...
                        flag_useOctave);
%telapsed=toc(tstart);

%% Evaluate the error
sim = load([dataFolder,'benchRecordOpus31_ElasticTendonfitting.mat']);



if(flag_plot==1)
    figDebug=figure;
    plot(expConfigHerzogLeonard2002.dataRamp.time,...
        expConfigHerzogLeonard2002.dataRamp.force,'k');
    hold on;
    plot(sim.benchRecord.time,...
         sim.benchRecord.tendonForce,'b')
    xlabel('Time (s)');
    ylabel('Force (N)'); 

    if(flag_useElasticTendon==1)
        title(['Active Titin Fitting: Elastic Tendon']);
    else
        title(['Active Titin Fitting: Rigid Tendon']);
    end

    
end

npts = 10;
errorSumSqA = 0;
errorSumSqB = 0;

%Sample npts during the ramp
t0 = expConfigHerzogLeonard2002.lengthRampKeyPoints(1,1);
t1 = expConfigHerzogLeonard2002.lengthRampKeyPoints(2,1);

for i=1:1:npts
    n = (i-1)/(npts-1);
    ts = t0 + (t1-t0)*n;

    fsim = interp1(sim.benchRecord.time,...
                   sim.benchRecord.tendonForce,...
                   ts);

    fexp = interp1(expConfigHerzogLeonard2002.dataRamp.time,...
                   expConfigHerzogLeonard2002.dataRamp.force,...
                   ts);
    ferror = fsim-fexp;
    errorSumSqA = errorSumSqA + ferror*ferror;

    if(flag_plot==1)
        figure(figDebug);
        plot([ts;ts],[fexp;fsim],'r');
        hold on;
    end
end

%Sample npts from the end of the ramp to the relaxation
t0 = expConfigHerzogLeonard2002.lengthRampKeyPoints(2,1);
t1 = expConfigHerzogLeonard2002.stimulationKeyTimes(1,2);

for i=1:1:npts
    n = (i-1)/(npts-1);
    ts = t0 + (t1-t0)*n;

    fsim = interp1(sim.benchRecord.time,...
                   sim.benchRecord.tendonForce,...
                   ts);

    fexp = interp1(expConfigHerzogLeonard2002.dataRamp.time,...
                   expConfigHerzogLeonard2002.dataRamp.force,...
                   ts);
    ferror = fsim-fexp;
    errorSumSqB = errorSumSqB + ferror*ferror;
    if(flag_plot==1)
        figure(figDebug);
        plot([ts;ts],[fexp;fsim],'r');
        hold on;
    end
    
end

errorSumSq = 0;
switch typeCostFunction
    case 0
        errorSumSq = errorSumSqA;
    case 1
        errorSumSq = errorSumSqB;
    case 2
        errorSumSq = errorSumSqA+errorSumSqB;
    otherwise
        assert(0,'typeCostFunction: must be 0,1, or 2');
end
errorSumSq = errorSumSq/errorSumSqNorm;