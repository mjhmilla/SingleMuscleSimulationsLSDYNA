%%
% SPDX-FileCopyrightText: 2024 Matthew Millard <millard.matthew@gmail.com>
%
% SPDX-License-Identifier: MIT
%
%%
function figH = addGollapudiLin2009PassiveForceLength(...
    figH,subplotPosition, labelGL2009, expColor,...
    lceOptHuman,muscleArchitecture,...
    flag_plotInNormalizedCoordinates)

optimalFiberLength      =muscleArchitecture.lceOpt;
maximumIsometricForce   =muscleArchitecture.fiso;
tendonSlackLength       =muscleArchitecture.ltslk;
pennationAngle          =muscleArchitecture.alpha;

figure(figH);
subplot('Position',subplotPosition);

fileGL2009fpeN = ['..',filesep,'..',filesep,'..',filesep,'..',filesep,...
           'ReferenceExperiments',filesep,...
           'active_passive_force_length',filesep,...
           'GollapudiLin2009_Fig6.csv'];


dataGL2009FpeN= csvread(fileGL2009fpeN,1,0);

if(flag_plotInNormalizedCoordinates==1)
    lceExpFpeN  = (dataGL2009FpeN(:,1)./lceOptHuman);
    fceExpFpeN  = dataGL2009FpeN(:,2);
else
    lceExpFpeN  = ...
        (dataGL2009FpeN(:,1)./lceOptHuman)*optimalFiberLength...
       +tendonSlackLength;
    fceExpFpeN   = ...
        dataGL2009FpeN(:,2).*(maximumIsometricForce);
end

plot(lceExpFpeN,...
     fceExpFpeN,...
     'o',...
     'LineWidth',0.5,...         
     'Color',expColor,...
     'MarkerFaceColor',[1,1,1],...
     'MarkerSize',4,...         
     'DisplayName',labelGL2009);
hold on