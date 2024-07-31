%%
% SPDX-FileCopyrightText: 2024 Matthew Millard <millard.matthew@gmail.com>
%
% SPDX-License-Identifier: MIT
%
%%
function fittedFelineSoleus = fitFelineSoleusCrossbridgeViscoelasticity( ...
                                defaultFelineSoleus,...
                                flag_useElasticTendon,...
                                figNameGainPhase,...
                                frequencyName,...
                                felineSoleusActiveForceLengthDataDefault,...
                                felineSoleusPassiveForceLengthCurveSettings,...
                                flag_useOctave)



flag_figureNumberToFitTo = nan;
if(contains(figNameGainPhase,'Fig3'))
    flag_figureNumberToFitTo=3;
elseif(contains(figNameGainPhase,'Fig12'))
    flag_figureNumberToFitTo=12;
else
    assert(0,sprintf('Error: figNameGainPhase must be Fig3 or Fig12 not %s',figNameGainPhase));
end

flag_frequencyToFitTo = nan;
if(contains(frequencyName,'90Hz'))
    flag_frequencyToFitTo = 90;
elseif(contains(frequencyName,'15Hz'))
    flag_frequencyToFitTo = 15;
else
    assert(0,sprintf('Error: frequencyName must be 15Hz or 90Hz not %s',frequencyName));
end

%%
%% Update the cross-bridge properties of the Opus 31 model to fit the 
%% Frequency response of Kirch, Boskov, & Rymer 1994.
%%

%Since the force response of the model to small perturbations is well 
%approximated as linear we can directly evaluate the visco elastic
%properties of the lumped-cross bridge that best fit the data of Kirsch,
%Boskov, and Rymer. 

%%
% Fitting Data: Kirsch, Boskov, & Rymer 1994
%%
fittingFilesGain      = 'experiments/KirschBoskovRymer1994/data/fig_KirschBoskovRymer1994_Fig3_gain.csv';
fittingFilesPhase     = 'experiments/KirschBoskovRymer1994/data/fig_KirschBoskovRymer1994_Fig3_phase.csv';
fittingFilesCoherence = 'experiments/KirschBoskovRymer1994/data/fig_KirschBoskovRymer1994_Fig3_coherence.csv';
fittingFilesK =        {'experiments/KirschBoskovRymer1994/data/fig_KirschBoskovRymer1994_Fig9A.csv',...
                        'experiments/KirschBoskovRymer1994/data/fig_KirschBoskovRymer1994_Fig9B.csv',...
                        'experiments/KirschBoskovRymer1994/data/fig_KirschBoskovRymer1994_Fig12_K.csv'}; 
fittingFilesD =     {   'experiments/KirschBoskovRymer1994/data/fig_KirschBoskovRymer1994_Fig10.csv',...
                        'experiments/KirschBoskovRymer1994/data/fig_KirschBoskovRymer1994_Fig12_D.csv'}; 



dataKBR1994Fig3Force = 5; %N, as mentioned in the caption%%

dataKBR1994Fig3Gain = loadDigitizedData(fittingFilesGain,...
                        'Frequency (Hz)','Stiffness (N/mm)',...
                        {'1.6mm, 90Hz','1.6mm, 15Hz'},'');
dataKBR1994Fig3Phase = loadDigitizedData(fittingFilesPhase,...
                         'Frequency (Hz)','Phase (deg)',...
                         {'1.6mm, 90Hz','1.6mm, 15Hz'},'');
dataKBR1994Fig3Coherence = loadDigitizedData(fittingFilesCoherence,...
                          'Frequency (Hz)','Coherence$$^2$$',...
                          {'1.6mm, 90Hz','1.6mm, 15Hz'},'');

dataKBR1994Fig9A = loadDigitizedData(fittingFilesK{1},...
                      'Force (N)','K (N/mm)',...
                      {'0.4mm 15Hz','0.8mm 15Hz','1.6mm 15Hz'},'');
                    
dataKBR1994Fig9B = loadDigitizedData(fittingFilesK{2},...
                      'Force (N)','K (N/mm)',...
                      {'0.4mm 15Hz','0.4mm 35Hz','0.4mm 90Hz',...
                       '1.6mm 15Hz','1.6mm 35Hz','1.6mm 90Hz'},'');

dataKBR1994Fig10 = loadDigitizedData(fittingFilesD{1},...
                      'Force (N)','K (N/mm/s)',...
                      {'15Hz','35Hz','90Hz'},'');
                     
dataKBR1994Fig12K = loadDigitizedData(fittingFilesK{3},...
                          'Force (N)','K (N/mm)',...
                          {'Soleus','MG'},'0.8mm 35Hz');
                        
dataKBR1994Fig12D = loadDigitizedData(fittingFilesD{2},...
                          'Force (N)','B (N/mm/s)',...
                          {'Soleus','MG'},'0.8mm 35Hz');

%%

% Load the muscle and sarcomere properties of the cat soleus
% 
% Kirsch, Boskov & Rymer mention that the soleus rest length is
% 13 mm to 6 mm short of the 'maximum physiological length'. I have
% no idea how the 'maximum physiological length' is defined. I'm going
% to start the simulations at the optimal fiber length for now.
%%


nominalNormFiberLengthAtSlack  = 1.0;
nominalForceKDFit              = 5; %Stiffness & damping fit done at 5N tension
scaleSlidingTimeConstant       = 1;
scaleCrossBridgeCyclingDamping = 1;

normTendonDampingConstant = ...
    defaultFelineSoleus.musculotendon.normTendonDampingConstant;
normTendonDampingLinear = ...
    defaultFelineSoleus.musculotendon.normTendonDampingLinear;

flag_updateNormFiberLengthByTendonStretch = 1;


%Note:  is updateOpus31CrossBridgeParameters using the tendon damping model that
%       scales with tendon stiffness?
%disp('To do: separate use of KBR1994 from updateOpus31CrossBridgeParameters');
%disp('     : put that code here in fitFelineSoleusCrossbridgeViscoelasticity');
%disp('     : and pass in kmt and dmt here.');
[fittedMusculotendonProperties,fittedSarcomerePropertiesOpus31] = ...
  updateOpus31CrossBridgeParameters(...
    nominalForceKDFit,...
    nominalNormFiberLengthAtSlack,...
    flag_figureNumberToFitTo,...
    flag_frequencyToFitTo,...
    dataKBR1994Fig3Gain,...
    dataKBR1994Fig3Phase,...
    dataKBR1994Fig12K,...
    dataKBR1994Fig12D,...
    defaultFelineSoleus.musculotendon.normTendonDampingConstant,...
    defaultFelineSoleus.musculotendon.normTendonDampingLinear,...
    scaleSlidingTimeConstant,...
    scaleCrossBridgeCyclingDamping,...
    flag_useElasticTendon,...
    defaultFelineSoleus.musculotendon,...
    defaultFelineSoleus.sarcomere,...
    defaultFelineSoleus.curves,...
    flag_useOctave);                                  
                                  
tendonStr = '';
if(flag_useElasticTendon==1)
    tendonStr = 'ET';
else
    tendonStr = 'RT';
end
fittingStr = sprintf('KBR1994_%s_%s_%s',...
    figNameGainPhase,frequencyName,tendonStr);

fittedFelineSoleus = defaultFelineSoleus;
fittedFelineSoleus.curves        = defaultFelineSoleus.curves;
fittedFelineSoleus.musculotendon = fittedMusculotendonProperties;
fittedFelineSoleus.sarcomere     = fittedSarcomerePropertiesOpus31;

%The calibrated active force length curve is affected by the change
%in cross-bridge stiffness. No other curve is.
flag_compensateForCrossbridgeStiffness              = 1;
curvinessActiveForceLength                          = 1;
shiftLengthActiveForceLengthCurveDescendingCurve    = 0;
flag_enableNumericallyNonZeroGradients              = 1;
smallNumericallyNonZeroValue                       = sqrt(sqrt(eps));
smallNumericallyNonZeroSlope                       = smallNumericallyNonZeroValue/1000.;

[fittedFelineSoleus.curves.activeForceLengthCalibratedCurve, ...
  activeForceLengthCurveAnnotationPointsCal] ...
    = createFiberActiveForceLengthCurve(...
          fittedFelineSoleus.sarcomere.normMyosinHalfLength*2,...
          fittedFelineSoleus.sarcomere.normMyosinBareHalfLength*2,...
          fittedFelineSoleus.sarcomere.normActinLength,...
          fittedFelineSoleus.sarcomere.normZLineLength,...
          fittedFelineSoleus.sarcomere.normSarcomereLengthZeroForce,...
          fittedFelineSoleus.sarcomere.normCrossBridgeStiffness,...          
          curvinessActiveForceLength, ...           
          shiftLengthActiveForceLengthCurveDescendingCurve,...
          flag_compensateForCrossbridgeStiffness,...          
          flag_enableNumericallyNonZeroGradients,...
          smallNumericallyNonZeroValue,...
          smallNumericallyNonZeroSlope,...
          fittedFelineSoleus.musculotendon.name,...
          flag_useOctave);  


fittedFelineSoleus.fitting = [fittedFelineSoleus.fitting,{fittingStr}];


flag_skipThisCode = 1;

if(flag_skipThisCode==0)
    figNameGainPhase = 'Fig12';
    if(flag_figureNumberToFitTo==3)
      figNameGainPhase = 'Fig3';  
    end

    save(['output/structs/felineSoleusRigidTendonKBR1994',figNameGainPhase,'.mat'],...
          'felineSoleusRigidTendonKBR1994');

    felineSoleusElasticTendonKBR1994              = defaultFelineSoleus;
    felineSoleusElasticTendonKBR1994.curves       = normMuscleCurves_ET;
    felineSoleusElasticTendonKBR1994.musculotendon= musculotendonPropertiesOpus31_ET;
    felineSoleusElasticTendonKBR1994.sarcomere    = sarcomerePropertiesOpus31_ET;

    save(['output/structs/felineSoleusElasticTendonKBR1994',figNameGainPhase,'.mat'],...
          'felineSoleusElasticTendonKBR1994');


    %%
    % Note the average offset between the active-force-length curve and
    % the transformed data
    %%

    xExp = felineSoleusActiveForceLengthDataDefault(2:end,1);
    yExp = felineSoleusActiveForceLengthDataDefault(2:end,2);
    xCurve = zeros(size(xExp));

    for i=1:1:length(xExp)
    xCurve(i,1) = calcBezierFcnXGivenY(yExp(i,1), ...
      felineSoleusNormMuscleCurvesUpd_ET.activeForceLengthCurve,... 
      xExp(i,1));
    end                                    
    dx = mean(xCurve-xExp);
    %felineSoleusActiveForceLengthDataDefault(:,1)=...
    %  felineSoleusActiveForceLengthDataDefault(:,1)+dx;

    disp('Adjusted optimal fiber length');
    fprintf('%1.6f lce/lopt \n',felineSoleusActiveForceLengthDataDefault(1,1));
    disp('Average error on the descending limb');
    fprintf('%1.6f lce/lopt \n',dx);
    fprintf('%1.6f mm \n',dx*(musculotendonPropertiesOpus31_ET.optimalFiberLength*1000));

    lceNStart = felineSoleusActiveForceLengthDataDefault(1,1);
    save('output/structs/normalizedFiberLengthStartHerzogLeonard2002.mat',...
         'lceNStart');
end