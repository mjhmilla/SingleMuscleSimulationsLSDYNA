clc;
close all;
clear all;

%%
%
% The elasticity of the tendon is ignored when fitting
%
% 1. The tendon is in the toe region (which is compliant) for all recorded 
%    data points. For a cat soleus this will introduce upto 3.47% ltSlk
%    or 1.1mm in unaccounted tendon length change. This may be noticeable
%
% 2. Active-force-length relation:
%    The cat soleus tendon is short: 27 mm for a 38 mm CE. With a stiffness
%    of 30 fiso/ltSlk, or 42 fiso/lceOpt, the variation of force in these 
%    experiments (0.73 - 1.0 fiso) will introduce an unaccounted for length 
%    change in the tendon of 1 fiso/42 - 0.73 fiso/42 = 0.6% or 0.25mm. 
%    Note, I can use 42 fiso/lceOpt as the tendon stiffness for this 
%    estimate because the forces of 0.73-1 fiso are within the linear range 
%    of the tendon.
%
%
% 3. Force-velocity relation: 
%    Fitting the force-velocity relation is quite challenging:
%    the experiment has to be simulated to do the fitting unless
%    assumptions are made aboue the distribution of contraction velocity
%    between the CE and the tendon.
%
%%

expData = 'HL2002';
% HL1997 (Herzog & Leonard 1997)
% HL2002 (Herzog & Leonard 2002)

flag_zeroMAT156TendonSlackLength=1;

flag_plotHL1997AnnotationData           =0;
flag_plotHL2002AnnotationData           =0;
flag_plotVEXATActiveForceLengthFitting  =0;
flag_plotEHTMMActiveForceLengthFitting  =0;
flag_plotVEXATPassiveForceLengthFitting =1;
flag_plotEHTMMPassiveForceLengthFitting =1;

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
plotSettings.mat156.lineType= '-';

plotSettings.umat41.color = cs.yellow;
plotSettings.umat41.label = 'EHTMM';
plotSettings.umat41.lineWidth = 2;
plotSettings.umat41.lineType = '-';

plotSettings.umat43.color = cs.blue;
plotSettings.umat43.label = 'VEXAT';
plotSettings.umat43.lineWidth =2;
plotSettings.umat43.lineType = '-';

plotSettings.HL1997.color       = [0,0,0];
plotSettings.HL1997.label       = 'Exp: HL1997';
plotSettings.HL1997.lineWidth   = 1;
plotSettings.HL1997.lineType    = 's';

plotSettings.HL2002.color       = [1,1,1];
plotSettings.HL2002.label       = 'Exp: HL2002';
plotSettings.HL2002.lineWidth   = 1;
plotSettings.HL2002.lineType    = 'o';

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
%Not changed
modelParams.mat156=mat156;
modelParams.umat41=umat41;
modelParams.umat43=umat43;

%Updated
modelParams.mat156Upd=mat156;
modelParams.umat41Upd=umat41;
modelParams.umat43Upd=umat43;
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
                    expData,keyPointsHL1997,keyPointsHL2002,...
                    flag_zeroMAT156TendonSlackLength);
   
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
% Active force-length relation
%  This must be fitted first since lceOpt and fceOpt are adjusted
%  when fitting the active-force-length relation.
%%

% VEXAT:
%  Adjust lceOpt and fceOpt to best fit either HL1997 or HL2002.
[modelParams.umat43Upd, keyPointsHL1997, keyPointsHL2002]= ...
        fitVEXATActiveForceLengthRelation(expData,...
            modelParams.umat43Upd,...
            felineSoleusNormMuscleQuadraticCurves.activeForceLengthCurve,...
            keyPointsHL1997, keyPointsHL2002,...
            flag_plotVEXATActiveForceLengthFitting);

fieldsToUpdate = {'lceOptAT','fceOptAT','lceOpt','fceOpt'};
for i=1:1:length(fieldsToUpdate)
    modelParams.umat41Upd.(fieldsToUpdate{i})= ...
        modelParams.umat43Upd.(fieldsToUpdate{i});
    modelParams.umat156Upd.(fieldsToUpdate{i})= ...
        modelParams.umat43Upd.(fieldsToUpdate{i});
end

% EHTMM
% Fit the parameters to minimize the squared error with 
% HL1997 and HL2002
modelParams.umat41Upd = ...
    fitEHTMMActiveForceLengthRelation(expData, ...
                       modelParams.umat41Upd, ...
                       keyPointsHL1997, keyPointsHL2002,...
                       flag_plotEHTMMActiveForceLengthFitting);


%%
% Tendon
%%

%The VEXAT tendon model is a template that is scaled by 1 parameter: the
%tendon strain at 1 isometric force. We solve for that tendon strain that
%results in the desired stiffness at 1 isometric force

[modelParams.umat43Upd] = ...
    fitVEXATTendon(...
        modelParams.umat43Upd,...
        ft,...
        felineSoleusNormMuscleQuadraticCurves.tendonForceLengthNormCurve);

% The EHTMM has many parameters. To make it as similar to the VEXAT tendon
% as possible (so that we're comparing the formulations rather than the 
% curves) we adjust it to develop the same ktNIso at the same strain
ft.etIso=modelParams.umat43Upd.et;

%And we add a single sample in the middle of the toe region
ft.etSample = (1/2)*(2/3)*(modelParams.umat43Upd.et);
ft.ftNSample=zeros(size(ft.etSample));
for i=1:1:length(ft.etSample)
    ft.ftNSample(i,1)=...
        calcQuadraticBezierYFcnXDerivative(...
            ft.etSample(i,1)/modelParams.umat43Upd.et,...
            felineSoleusNormMuscleQuadraticCurves.tendonForceLengthNormCurve,0);
end

[modelParams.umat41Upd, umat41ftError] =...
        fitEHTMMTendon(...
            modelParams.umat41Upd, ...
            ft);

%%
% Passive force-length relation
%%
vexatCurves=[];
[modelParams.umat43Upd, keyPointsVEXATFpe,vexatCurves]= ...
    fitVEXATPassiveForceLengthRelation(...
        expData,...
        modelParams.umat43Upd,...
        keyPointsHL1997, keyPointsHL2002,...
        felineSoleusNormMuscleQuadraticCurves.fiberForceLengthCurve,...
        felineSoleusNormMuscleQuadraticCurves.tendonForceLengthNormCurve,...        
        felineSoleusNormMuscleQuadraticCurves.tendonForceLengthInverseNormCurve,...
        vexatCurves,...
        flag_plotVEXATPassiveForceLengthFitting);

modelParams.umat41Upd = ...
    fitEHTMMPassiveForceLengthRelation(...
        expData,...
        modelParams.umat41Upd,...
        keyPointsHL1997, keyPointsHL2002,...
        keyPointsVEXATFpe,...
        flag_plotEHTMMPassiveForceLengthFitting);

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



[figFitting]= ...
    addFittedTendonPlot(...
        figFitting,...
        modelParams.umat41Upd,...
        modelParams.umat43Upd,...
        felineSoleusNormMuscleQuadraticCurves,...
        reshape(subPlotPanel(1,3,:),1,4),...
        plotSettings);

[figFitting]= ...
    addFittedActiveForceLengthPlotV2(...
        figFitting,...
        modelParams.umat41Upd,...
        modelParams.umat43Upd,...
        felineSoleusNormMuscleQuadraticCurves,...
        keyPointsHL1997, keyPointsHL2002,...
        reshape(subPlotPanel(1,1,:),1,4),...
        plotSettings);

[figFitting]= ...
    addFittedPassiveForceLengthPlotV2(...
        figFitting,...
        expData,...        
        modelParams.umat41Upd,...
        modelParams.umat43Upd,...
        felineSoleusNormMuscleQuadraticCurves,...
        keyPointsHL1997, keyPointsHL2002,keyPointsVEXATFpe,...
        reshape(subPlotPanel(1,2,:),1,4),...
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
