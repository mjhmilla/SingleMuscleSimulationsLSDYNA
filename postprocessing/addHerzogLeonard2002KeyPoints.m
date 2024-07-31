%%
% SPDX-FileCopyrightText: 2024 Matthew Millard <millard.matthew@gmail.com>
%
% SPDX-License-Identifier: MIT
%
%%
function figH = addHerzogLeonard2002KeyPoints(...
                    figH,subplotFl,labelSeries,expColor,...
                    muscleArchitecture,...
                    flag_plotInNormalizedCoordinates,...
                    addPassive0AddActive1)


assert(flag_plotInNormalizedCoordinates==1);
dataHL2002 = getHerzogLeonard2002Keypoints();



figure(figH);

if(addPassive0AddActive1==1)
    subplot('Position',subplotFl);

    plot(dataHL2002.lceN,dataHL2002.faN,...
         '+','Color',expColor,...
         'MarkerFaceColor',expColor,...
         'HandleVisibility','on',...
         'MarkerSize',4,...
         'DisplayName',labelSeries);
    hold on;

%     plot(laN,faN,...
%          'x','Color',expColor,...
%          'MarkerFaceColor',expColor,...
%          'DisplayName',labelSeries);
end
if(addPassive0AddActive1==0)
    subplot('Position',subplotFpe);

    plot(dataHL2002.lceN,dataHL2002.fpeN,...
         '+','Color',expColor,...
         'MarkerFaceColor',expColor,...
         'HandleVisibility','on',...
         'DisplayName',labelSeries);
    hold on;
end


