clc;
close all;
clear all;

%Test to see if the Matlab terminal is in the correct directory
currDirContents = dir;
[pathToParent,parentFolderName,ext] = fileparts(currDirContents(1).folder);
matlabScriptPath = '';
rootFolderName = 'SingleMuscleSimulationsLSDYNA';
if(strcmp(currDirContents(1).name,'.') ...
        && contains(parentFolderName,rootFolderName))
    matlabScriptPath = pwd;
end    
outputFolder            = 'output';
refExperimentFolder     = 'ReferenceExperiments';

addpath(genpath('models'));
addpath(genpath('fitting'));
addpath(genpath('numeric'));
addpath(genpath('curves'));
addpath(genpath('preprocessing'));
addpath(genpath('postprocessing'));
addpath(genpath('ReferenceExperiments'));

cs = getPaulTolColourSchemes('highContrast');

plotSettings.mat156.color = cs.red;
plotSettings.mat156.label = 'MAT156';
plotSettings.mat156.lineWidth= 2;

plotSettings.umat41.color = cs.yellow;
plotSettings.umat41.label = 'EHTMM';
plotSettings.umat41.lineWidth = 2;

plotSettings.umat43.color = cs.blue;
plotSettings.umat43.label = 'VEXAT';
plotSettings.umat43.lineWidth =2;
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
ft.ktNIso = 30;        %Scott & Loeb (1995)
%Scott SH, Loeb GE. Mechanical properties of aponeurosis and tendon of the 
% cat soleus muscle during whole‐muscle isometric contractions. 
% Journal of Morphology. 1995 Apr;224(1):73-86.


filePath = fullfile(refExperimentFolder,...
                    'eccentric_HerzogLeonard2002',...
                    'digitizedKeyPointsHerzogLeonard2002.csv');

dataHL2002KeyPoints = readmatrix(filePath,'NumHeaderLines',1);

fileHL1997Length = [matlabScriptPath,filesep,...
                   'ReferenceExperiments',filesep,...
                   'force_velocity',filesep,...
                   'fig_HerzogLeonard1997Fig1A_length.csv'];

fileHL1997Force = [matlabScriptPath,filesep,...
                   'ReferenceExperiments',filesep,...
                   'force_velocity',filesep,...
                   'fig_HerzogLeonard1997Fig1A_forces.csv'];

dataHL1997Length = loadDigitizedData(fileHL1997Length,...
                'Time ($$s$$)','Length ($$mm$$)',...
                {'c01','c02','c03','c04','c05',...
                 'c06','c07','c08','c09','c10','c11'},...
                {'Herzog and Leonard 1997'}); 

dataHL1997Force = loadDigitizedData(fileHL1997Force,...
                'Time ($$s$$)','Force ($$N$$)',...
                {'c01','c02','c03','c04','c05',...
                 'c06','c07','c08','c09','c10','c11'},...
                {'Herzog and Leonard 1997'}); 


%%
%Fit the models
%%

%%
% Tendon
%%

% 1.
%The VEXAT tendon model is a template that is scaled by 1 parameter: the
%tendon strain at 1 isometric force. We solve for that tendon strain that
%results in the desired stiffness at 1 isometric force

[params.HL1997.umat43Upd] = ...
    fitVEXATTendon(...
        params.HL1997.umat43Upd,...
        ft,...
        felineSoleusNormMuscleQuadraticCurves.tendonForceLengthNormCurve);

% 2.
% The EHTMM has many parameters. To make it as similar to the VEXAT tendon
% as possible (so that we're comparing the formulations rather than the 
% curves) we adjust it to develop the same ktNIso at the same strain
ft.etIso=params.HL1997.umat43Upd.et;

%And we add a single sample in the middle of the toe region
ft.etSample = (1/2)*(2/3)*(params.HL1997.umat43Upd.et);
ft.ftNSample=zeros(size(ft.etSample));
for i=1:1:length(ft.etSample)
    ft.ftNSample(i,1)=...
        calcQuadraticBezierYFcnXDerivative(...
            ft.etSample(i,1)/params.HL1997.umat43Upd.et,...
            felineSoleusNormMuscleQuadraticCurves.tendonForceLengthNormCurve,0);
end

[params.HL1997.umat41Upd, umat41ftError] =...
        fitEHTMMTendon(...
            params.HL1997.umat41Upd, ...
            ft);

%%
% Active force-length relation
%%

%%
% Passive force-length relation
%%

%%
% Force-velocity relation
%%


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
        reshape(subPlotPanel(1,3,:),1,4),...
        plotSettings);




%%
%Write the plot to file
%%
figure(figFitting);      
figFitting=configPlotExporter(figFitting, ...
            pageWidth, pageHeight);
fileName =    ['fig_MuscleFitting_Publication'];
print('-dpdf', [matlabScriptPath,'/',outputFolder,'/',...
      fileName,'.pdf']);

saveas(figFitting,[matlabScriptPath,'/',outputFolder,'/',...
      fileName],'fig');
