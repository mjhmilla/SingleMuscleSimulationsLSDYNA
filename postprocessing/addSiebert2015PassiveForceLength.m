%%
% SPDX-FileCopyrightText: 2024 Matthew Millard <millard.matthew@gmail.com>
%
% SPDX-License-Identifier: MIT
%
%%
function figH = addSiebert2015PassiveForceLength(...
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

fileSLRWS2015fpeN = ['..',filesep,'..',filesep,'..',filesep,'..',filesep,...
           'ReferenceExperiments',filesep,...
           'active_passive_force_length',filesep,...
           'SiebertLeichsenringRodeWickStutzig2015_fig3_fpeN.csv']; 

dataSLRWS2015FpeN= csvread(fileSLRWS2015fpeN,1,0);
dataSLRWS2015FpeN(end,:)=dataSLRWS2015FpeN(1,:);

lceOptExp=17.7;
lpee=12.9;    
if(flag_plotInNormalizedCoordinates==1)
    lceSLRWS2015ExpFpeN = dataSLRWS2015FpeN(:,1)*lpee+lpee;
    lceSLRWS2015ExpFpeN = lceSLRWS2015ExpFpeN./lceOptExp;
    fceExpFpeN  = dataSLRWS2015FpeN(:,2); 
    lceExpFpeN  = lceSLRWS2015ExpFpeN;
    fceExpFpeN  = dataSLRWS2015FpeN(:,2);         
else
    lceSLRWS2015ExpFpeN = dataSLRWS2015FpeN(:,1)*lpee+lpee;
    lceSLRWS2015ExpFpeN = lceSLRWS2015ExpFpeN./lceOptExp;
    lceExpFpeN  = ...
        (lceSLRWS2015ExpFpeN)*optimalFiberLength...
       +tendonSlackLength;
    fceExpFpeN   = ...
        dataSLRWS2015FpeN(:,2).*(maximumIsometricForce);        
end

fill(lceExpFpeN,...
     fceExpFpeN,expColor,...
     'DisplayName',labelSLRWS2015,...
     'EdgeColor','none');
hold on  