%%
% SPDX-FileCopyrightText: 2024 Matthew Millard <millard.matthew@gmail.com>
%
% SPDX-License-Identifier: MIT
%
%%
function fittedFelineSoleus = fitFelineSoleusPevkActinBondLocation( ...
                                defaultFelineSoleus,...
                                flag_useElasticTendon,...
                                felineSoleusPassiveForceLengthCurveSettings,...
                                flag_useOctave)

%The parameters updated are the 
%  :normPevkToActinAttachmentPoint (default of 0.5)
%  :normMaxActiveTitinToActinDamping (default of 20)
%
%The hand-tuned default values are quite good, but fitting is required to
%minimize the error. Since the process of both force development and 
%relaxation are nonlinear, there is not an elegant and fast way to find 
%these parameters without simulating the model directly. 

figureNumber       = 7;
subFigureNumber    = 2;
trialNumber        = 3;  

expConfigHerzogLeonard2002 =...
 getHerzogLeonard2002Configuration( figureNumber,...
                                    subFigureNumber, ...
                                    trialNumber);

dataFolder = 'experiments/HerzogLeonard2002/fitting/';



fittedFelineSoleus=defaultFelineSoleus;

tendonStr = '';
if(flag_useElasticTendon==1)
    tendonStr = 'ET';
else
    tendonStr = 'RT';
end

fittingStr = sprintf('HL2002_%i%i%i_%s',...
                    figureNumber,subFigureNumber, trialNumber,tendonStr);

fittedFelineSoleus.fitting = [fittedFelineSoleus.fitting;...
                              {fittingStr}];

    
[sarcomerePropertiesUpd,...
 normMuscleCurvesUpd] = ...
    updateActiveTitinParameters(defaultFelineSoleus.musculotendon, ...
                             defaultFelineSoleus.sarcomere,...
                             defaultFelineSoleus.curves,...
                             felineSoleusPassiveForceLengthCurveSettings,...
                             expConfigHerzogLeonard2002,...
                             flag_useElasticTendon,...
                             dataFolder,...
                             flag_useOctave);

fittedFelineSoleus.sarcomere=sarcomerePropertiesUpd;
fittedFelineSoleus.curves=normMuscleCurvesUpd;
