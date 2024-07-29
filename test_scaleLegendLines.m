%%
% SPDX-FileCopyrightText: 2024 Matthew Millard <millard.matthew@gmail.com>
%
% SPDX-License-Identifier: MIT
%
%%
clc;
close all;
clear all;

addpath('postprocessing/');

omega = [0:0.01:2*pi];
sinOmega = sin(omega);
cosOmega = cos(omega);

fig=figure;
plot(omega,sinOmega,'--b','DisplayName','sinOmega');
hold on;
plot(omega,cosOmega,'-r','DisplayName','cosOmega');
hold on;
plot(0,0,'xg','DisplayName','Zero');
hold on;
plot(pi,0,'.m','DisplayName','Pi');
hold on;
plot(2*pi,0,'oc','DisplayName','2Pi');

xlabel('Omega (radians)');
ylabel('Magnitude');
title('Test Plot');

[lgdH,lgdIcons, lgdPlots, lgdTxt]=legend('Location','NorthWest'); 
[lgdH,lgdIcons, lgdPlots, lgdTxt,XDataOrig,XDataNew] =...
    scaleLegendLines(0.5,lgdH,lgdIcons, lgdPlots, lgdTxt);

legend boxoff;

here=1;

