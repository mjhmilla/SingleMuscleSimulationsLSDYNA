clc;
close all;
clear all;

addpath(genpath('models'));
addpath(genpath('fitting'));
addpath(genpath('numeric'));
addpath(genpath('curves'));
addpath(genpath('preprocessing'));
addpath(genpath('postprocessing'));
addpath(genpath('ReferenceExperiments'));

cs = getPaulTolColourSchemes('highContrast');

plotSettings.mat156.color = cs.red;
plotSettings.umat41.color = cs.yellow;
plotSettings.umat43.color = cs.blue;

mm2m=0.001;


numberOfHorizontalPlotColumnsGeneric =3;
numberOfVerticalPlotRowsGeneric      =1;
plotWidth = 4.5;
plotHeight= 4.5;
plotHorizMarginCm= 1.0;
plotVertMarginCm = 1.5;
baseFontSize     = 6;

%%
% Plotting properties
%%
set(groot, 'defaultAxesFontSize',baseFontSize);
set(groot, 'defaultTextFontSize',baseFontSize);
set(groot, 'defaultAxesLabelFontSizeMultiplier',1.2);
set(groot, 'defaultAxesTitleFontSizeMultiplier',1.2);
set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultLegendInterpreter','latex');
set(groot, 'defaultTextInterpreter','latex');
set(groot, 'defaultAxesTitleFontWeight','bold');  
set(groot, 'defaultFigurePaperUnits','centimeters');
set(groot,'defaultFigurePaperType','A4');



%%
%Load parameters
%%
expAbbrv = 'HL2002';
modelFolder = fullfile('MPP_R931','common');
flag_assertCommonParamsIdentical=1;
[mat156,umat41,umat43] = getModelParameters(modelFolder,expAbbrv,...
                          flag_assertCommonParamsIdentical);

%Not changed
params.HL2002.mat156=mat156;
params.HL2002.umat41=umat41;
params.HL2002.umat43=umat43;

%These values will be updated during the fitting process
params.HL2002.mat156Upd=mat156;
params.HL2002.umat41Upd=umat41;
params.HL2002.umat43Upd=umat43;


expAbbrv = 'HL1997';
modelFolder = fullfile('MPP_R931','common');
flag_assertCommonParamsIdentical=1;
[mat156,umat41,umat43] = getModelParameters(modelFolder,expAbbrv,...
                          flag_assertCommonParamsIdentical);

%Not changed
params.HL1997.mat156=mat156;
params.HL1997.umat41=umat41;
params.HL1997.umat43=umat43;

%These values will be updated during the fitting proces
params.HL1997.mat156Upd=mat156;
params.HL1997.umat41Upd=umat41;
params.HL1997.umat43Upd=umat43;

disp('Add function to set the architectural parameters');

%%
% Load the reference Bezier curves for umat43 and mat156
%
%   Generated using: 
%       main_createExplicitBezierSplineMuscleCurves.m
%   From:
%       https://github.com/mjhmilla/FastMuscleCurves
%%

load('output/structs/defaultFelineSoleusQuadraticCurves.mat');
load('output/structs/defaultFelineSoleus.mat');

%%
% Load fitting data
%%

% Tendon
%
fit.HL1997.ft.ktNIso = 30;        %Scott & Loeb (1995)
%Scott SH, Loeb GE. Mechanical properties of aponeurosis and tendon of the 
% cat soleus muscle during whole‐muscle isometric contractions. 
% Journal of Morphology. 1995 Apr;224(1):73-86.

% Active-force-length relation
%

% Passive-force-length relation
%

% Force-velocity relation
%

%%
%Fit the models
%%

%The VEXAT tendon model is a template that is scaled by 1 parameter: the
%tendon strain at 1 isometric force. We solve for that tendon strain that
%results in the desired stiffness at 1 isometric force

[params.HL1997.umat43Upd] = ...
    fitVEXATTendon(...
        params.HL1997.umat43Upd,...
        fit.HL1997.ft,...
        felineSoleusNormMuscleQuadraticCurves.tendonForceLengthNormCurve);

% The EHTMM has many parameters. To make it as similar to the VEXAT tendon
% as possible we adjust it to develop the same ktNIso at the same strain
fit.HL1997.ft.etIso=params.HL1997.umat43Upd.et;

[params.HL1997.umat41Upd, umat41ftError] =...
        fitEHTMMTendon(...
            params.HL1997.umat41Upd, ...
            fit.HL1997.ft);



%%
%Plot the fitted results
%%
[subPlotPanel, pageWidth,pageHeight]= ...
  plotConfigGeneric(  numberOfHorizontalPlotColumnsGeneric,...
                      numberOfVerticalPlotRowsGeneric,...
                      plotWidth,plotHeight,...
                      plotHorizMarginCm,plotVertMarginCm,...
                      baseFontSize); 

figFitting=figure;

[fig,umat41Curves,umat43Curves]= ...
    addFittedTendonPlot(...
        figFitting,...
        params.HL1997.umat41Upd,...
        params.HL1997.umat43Upd,...
        felineSoleusNormMuscleQuadraticCurves,...
        reshape(subPlotPanel(1,1,:),1,4),...
        plotSettings.umat41.color,...
        plotSettings.umat43.color);





