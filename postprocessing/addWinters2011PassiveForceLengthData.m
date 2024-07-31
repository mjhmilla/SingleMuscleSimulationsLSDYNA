%%
% SPDX-FileCopyrightText: 2024 Matthew Millard <millard.matthew@gmail.com>
%
% SPDX-License-Identifier: MIT
%%
function figH = addWinters2011PassiveForceLengthData(...
    figH,subplotPosition, labelWTLW2011, expColorA,expColorB, ...
    muscleArchitecture, ...
    flag_plotInNormalizedCoordinates)

optimalFiberLength      =muscleArchitecture.lceOpt;
maximumIsometricForce   =muscleArchitecture.fiso;
tendonSlackLength       =muscleArchitecture.ltslk;
pennationAngle          =muscleArchitecture.alpha;

figure(figH);
subplot('Position',subplotPosition);

fileWTLW2011EDLIIfpeN = ['..',filesep,'..',filesep,'..',filesep,'..',filesep,...
           'ReferenceExperiments',filesep,...
           'active_passive_force_length',filesep,...
           'TMWinters2011_EDLII_fpeN.csv'];

fileWTLW2011EDLfpeN = ['..',filesep,'..',filesep,'..',filesep,'..',filesep,...
       'ReferenceExperiments',filesep,...
       'active_passive_force_length',filesep,...
       'TMWinters2011_EDL_fpeN.csv']; 

fileWTLW2011TAfpeN = ['..',filesep,'..',filesep,'..',filesep,'..',filesep,...
           'ReferenceExperiments',filesep,...
           'active_passive_force_length',filesep,...
           'TMWinters2011_TA_fpeN.csv']; 

dataWTLW2011EDLIIFpeN   = csvread(fileWTLW2011EDLIIfpeN,1,0);
dataWTLW2011EDLFpeN     = csvread(fileWTLW2011EDLfpeN,1,0);
dataWTLW2011TAFpeN      = csvread(fileWTLW2011TAfpeN,1,0);

if(flag_plotInNormalizedCoordinates==1)
    lceExpEDLIIFpeN  = (dataWTLW2011EDLIIFpeN(:,1).*(1/100) + 1);
    fceExpEDLIIFpeN  =  dataWTLW2011EDLIIFpeN(:,2).*(1/100);

    lceExpEDLFpeN  = (dataWTLW2011EDLFpeN(:,1).*(1/100) + 1);
    fceExpEDLFpeN  =  dataWTLW2011EDLFpeN(:,2).*(1/100);   

    lceExpTAFpeN  = (dataWTLW2011TAFpeN(:,1).*(1/100) + 1);
    fceExpTAFpeN  = dataWTLW2011TAFpeN(:,2).*(1/100);      
else
    lceExpEDLIIFpeN  = ...
        (dataWTLW2011EDLIIFpeN(:,1).*(1/100) + 1)*optimalFiberLength...
       +tendonSlackLength;
    fceExpEDLIIFpeN   = ...
        dataWTLW2011EDLIIFpeN(:,2).*(1/100).*(maximumIsometricForce*scaleF);

    lceExpEDLFpeN  = ...
        (dataWTLW2011EDLFpeN(:,1).*(1/100) + 1)*optimalFiberLength...
       +tendonSlackLength;
    fceExpEDLFpeN   = ...
        dataWTLW2011EDLFpeN(:,2).*(1/100).*(maximumIsometricForce*scaleF);

    lceExpTAFpeN  = ...
        (dataWTLW2011TAFpeN(:,1).*(1/100) + 1)*optimalFiberLength...
       +tendonSlackLength;
    fceExpTAFpeN   = ...
        dataWTLW2011TAFpeN(:,2).*(1/100).*(maximumIsometricForce*scaleF);        
       
end

n = 0;
expColor = expColorA.*(1-n) + expColorB.*n;

subplot('Position',subplotPosition);
plot(lceExpEDLIIFpeN,...
     fceExpEDLIIFpeN,...
     '.',...
     'Color',expColor,...
     'MarkerFaceColor',expColor,...
     'MarkerSize',8,...         
     'DisplayName',[labelWTLW2011,'EDLII']',...
     'HandleVisibility','off');
hold on 

n = 0.5;
expColor = expColorA.*(1-n) + expColorB.*n;

plot(lceExpEDLFpeN,...
     fceExpEDLFpeN,...
     '.',...
     'Color',expColor,...
     'MarkerFaceColor',expColor,...
     'MarkerSize',8,...         
     'DisplayName',[labelWTLW2011,'(EDL)'],...
     'HandleVisibility','off');
hold on 

n = 1;
expColor = expColorA.*(1-n) + expColorB.*n;

plot(lceExpTAFpeN,...
     fceExpTAFpeN,...
     '.',...
     'Color',expColor,...
     'MarkerFaceColor',expColor,...
     'MarkerSize',8,...         
     'DisplayName',labelWTLW2011);
hold on 