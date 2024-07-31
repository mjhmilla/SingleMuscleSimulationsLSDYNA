%%
% SPDX-FileCopyrightText: 2024 Matthew Millard <millard.matthew@gmail.com>
%
% SPDX-License-Identifier: MIT
%
%%
function figH = addSiebert2015ActiveForceLength(...
                    figH,subplotPosition, labelSLRWS2015, ...
                    expColor,...
                    muscleArchitecture, ...
                    flag_plotInNormalizedCoordinates)

optimalFiberLength      =muscleArchitecture.lceOpt;
maximumIsometricForce   =muscleArchitecture.fiso;
tendonSlackLength       =muscleArchitecture.ltslk;
pennationAngle          =muscleArchitecture.alpha;

figure(figH);
subplot('Position',subplotPosition);

fileSLRWS2015flN = ['..',filesep,'..',filesep,'..',filesep,'..',filesep,...
           'ReferenceExperiments',filesep,...
           'active_passive_force_length',filesep,...
           'SiebertLeichsenringRodeWickStutzig2015_fig3_falN.csv']; 


dataSLRWS2015FalN = csvread(fileSLRWS2015flN,1,0);
dataSLRWS2015FalN(end,:)=dataSLRWS2015FalN(1,:);


lceOptExp=17.7;
lpee=12.9;    
if(flag_plotInNormalizedCoordinates==1)
    lceExpFalN  =  dataSLRWS2015FalN(:,1);
    fceExpFalN  =  dataSLRWS2015FalN(:,2);    
else
    lceExpFalN  = ...
        (dataSLRWS2015FalN(:,1))*optimalFiberLength...
       +tendonSlackLength;
    fceExpFalN   = ...
        dataSLRWS2015FalN(:,2).*(maximumIsometricForce);
end

fill(lceExpFalN,...
     fceExpFalN,expColor,...
     'DisplayName',labelSLRWS2015,...
     'EdgeColor','none');
hold on