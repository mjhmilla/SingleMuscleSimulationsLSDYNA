clc;
close all;
clear all;

expData = 'HL2002';
% HL1997 (Herzog & Leonard 1997)
% HL2002 (Herzog & Leonard 2002)

flag_zeroMAT156TendonSlackLength=1;
flag_plotHL1997AnnotationData=0;
flag_plotHL2002AnnotationData=0;

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
expAbbrv = expData;
modelFolder = fullfile('MPP_R931','common');
flag_assertCommonParamsIdentical=1;
[mat156,umat41,umat43] = getModelParameters(modelFolder,expAbbrv,...
                          flag_assertCommonParamsIdentical);

%%
% Load fitting data
%%

% Tendon
%
ft.ktNIso = 30;        %Scott & Loeb (1995)
%Scott SH, Loeb GE. Mechanical properties of aponeurosis and tendon of the 
% cat soleus muscle during whole‐muscle isometric contractions. 
% Journal of Morphology. 1995 Apr;224(1):73-86.

keyPointsHL1997 = getHerzogLeonard1997KeyPoints(matlabScriptPath,...
                    refExperimentFolder,flag_plotHL1997AnnotationData);

keyPointsHL2002 = getHerzogLeonard2002KeyPoints(matlabScriptPath,...
                    refExperimentFolder,flag_plotHL2002AnnotationData);

%%
%Starting architectural parameters
%%
modelParams = setArchitecturalParameters(modelParams,...
           dataHL1997Length,dataHL1997Force,dataHL2002KeyPoints);

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
%Fit the models
%%

%%
% Tendon
%%

% 1.
%The VEXAT tendon model is a template that is scaled by 1 parameter: the
%tendon strain at 1 isometric force. We solve for that tendon strain that
%results in the desired stiffness at 1 isometric force

[params.umat43Upd] = ...
    fitVEXATTendon(...
        params.umat43Upd,...
        ft,...
        felineSoleusNormMuscleQuadraticCurves.tendonForceLengthNormCurve);

% 2.
% The EHTMM has many parameters. To make it as similar to the VEXAT tendon
% as possible (so that we're comparing the formulations rather than the 
% curves) we adjust it to develop the same ktNIso at the same strain
ft.etIso=params.umat43Upd.et;

%And we add a single sample in the middle of the toe region
ft.etSample = (1/2)*(2/3)*(params.umat43Upd.et);
ft.ftNSample=zeros(size(ft.etSample));
for i=1:1:length(ft.etSample)
    ft.ftNSample(i,1)=...
        calcQuadraticBezierYFcnXDerivative(...
            ft.etSample(i,1)/params.umat43Upd.et,...
            felineSoleusNormMuscleQuadraticCurves.tendonForceLengthNormCurve,0);
end

[params.umat41Upd, umat41ftError] =...
        fitEHTMMTendon(...
            params.umat41Upd, ...
            ft);

%%
% Active force-length relation
%%
params.umat43Upd = ...
        fitVEXATActiveForceLengthRelation(params.umat43Upd,...
                    dataHL2002KeyPoints, dataHL1997Length,dataHL1997Force);
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
        params.umat41Upd,...
        params.umat43Upd,...
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
