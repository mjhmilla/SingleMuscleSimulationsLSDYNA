clc;
close all;
clear all;

%%
%
% The elasticity of the tendon is included when fitting active and passive 
% force length relations. To do this I'm using a single tendon model to
% evaluate the tendon's strain: the VEXAT tendon model. Since both the 
% EHTMM and VEXAT tendon-force-lenght models closely match after fitting
% it is acceptable to do this. 
%
% The elasticity of the tendon is ignored when fitting the force-velocity
% relation. Why? We have no way of knowing how fast the tendon is 
% contracting. Lucky for us the amount of error will be small for a 
% cat soleus because the tendon is smaller than the muscle.
%
% 
%%

expData = 'HL2002';
% HL1997 (Herzog & Leonard 1997)
% HL2002 (Herzog & Leonard 2002)

flag_zeroMAT156TendonSlackLength=1;

flag_plotHL1997AnnotationData           =0;
flag_plotHL2002AnnotationData           =0;
flag_plotVEXATActiveForceLengthFitting  =1;
flag_plotEHTMMActiveForceLengthFitting  =1;
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

plotSettings.ylim = [0,1.05];
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

%Add a field tendon slack length to optimal CE length ratio
lceOptScottLoeb1995  = 38/1000;
ltSlkScottLoeb1995   = 27/1000;
mat156.tdnToCe = ltSlkScottLoeb1995/lceOptScottLoeb1995;
umat41.tdnToCe = ltSlkScottLoeb1995/lceOptScottLoeb1995;
umat43.tdnToCe = ltSlkScottLoeb1995/lceOptScottLoeb1995;

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
ktNIso = 30;        %Scott & Loeb (1995)
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
% Fitting
%%
%These structures hold curve samples for later plotting
vexatCurves = [];
ehtmmCurves = [];
%%
% Tendon VEXAT
%%

%The VEXAT tendon model is a template that is scaled by 1 parameter: the
%tendon strain at 1 isometric force. We solve for that tendon strain that
%results in the desired stiffness at 1 isometric force

%Only depends on ktNIso.
[modelParams.umat43Upd,vexatCurves] = ...
    fitVEXATTendon(...
        modelParams.umat43Upd,...
        ktNIso,...
        felineSoleusNormMuscleQuadraticCurves.tendonForceLengthNormCurve,...
        vexatCurves);


%%
% Active force-length relation
%  This must be fitted first since lceOpt and fceOpt are adjusted
%  when fitting the active-force-length relation.
%%

% VEXAT:
%  Adjust lceOpt and fceOpt to best fit either HL1997 or HL2002.
%  Subtract off tendon strain from the experimental key points
%  which works nicely only if the tendon models are similar
[modelParams.umat43Upd, keyPointsHL1997, keyPointsHL2002,vexatCurves]= ...
        fitVEXATActiveForceLengthRelation(expData,...
            modelParams.umat43Upd,...
            felineSoleusNormMuscleQuadraticCurves.activeForceLengthCurve,...
            felineSoleusNormMuscleQuadraticCurves.tendonForceLengthInverseNormCurve,...
            keyPointsHL1997, keyPointsHL2002,...
            vexatCurves,...
            flag_plotVEXATActiveForceLengthFitting);

disp('Setting all models to have the same lceOpt, fceOpt, lceOptAT, fceOptAT');
fieldsToUpdate = {'lceOptAT','fceOptAT','lceOpt','fceOpt','ltSlk'};
for i=1:1:length(fieldsToUpdate)
    modelParams.umat41Upd.(fieldsToUpdate{i})= ...
        modelParams.umat43Upd.(fieldsToUpdate{i});
    modelParams.umat156Upd.(fieldsToUpdate{i})= ...
        modelParams.umat43Upd.(fieldsToUpdate{i});
end

% EHTMM
% Fit the parameters to minimize the squared error with 
% HL1997 and HL2002
[modelParams.umat41Upd,ehtmmCurves] = ...
    fitEHTMMActiveForceLengthRelation(expData, ...
                       modelParams.umat41Upd, ...
                       keyPointsHL1997, keyPointsHL2002,...
                       ehtmmCurves,...
                       flag_plotEHTMMActiveForceLengthFitting);


%%
% Tendon EHTMM
%%

% The EHTMM has many parameters. To make it as similar to the VEXAT tendon
% as possible (so that we're comparing the formulations rather than the 
% curves) we adjust it to develop the same ktNIso at the same strain
keyPointsTendon.ktNIso = ktNIso;
keyPointsTendon.etIso=modelParams.umat43Upd.et;

%And we add a single sample in the middle of the toe region
keyPointsTendon.etSample = (1/2)*(2/3)*(modelParams.umat43Upd.et);
keyPointsTendon.ftNSample=zeros(size(keyPointsTendon.etSample));
for i=1:1:length(keyPointsTendon.etSample)
    keyPointsTendon.ftNSample(i,1)=...
        calcQuadraticBezierYFcnXDerivative(...
            keyPointsTendon.etSample(i,1)/modelParams.umat43Upd.et,...
            felineSoleusNormMuscleQuadraticCurves.tendonForceLengthNormCurve,0);
end

[modelParams.umat41Upd, umat41ftError,ehtmmCurves] =...
        fitEHTMMTendon(...
            modelParams.umat41Upd, ...
            keyPointsTendon,...
            ehtmmCurves);

%%
% Passive force-length relation
%%

[modelParams.umat43Upd, keyPointsVEXATFpe,vexatCurves]= ...
    fitVEXATPassiveForceLengthRelation(...
        expData,...
        modelParams.umat43Upd,...
        keyPointsHL1997, keyPointsHL2002,...
        felineSoleusNormMuscleQuadraticCurves.fiberForceLengthCurve,...
        vexatCurves,...
        flag_plotVEXATPassiveForceLengthFitting);

[modelParams.umat41Upd,ehtmmCurves] = ...
    fitEHTMMPassiveForceLengthRelation(...
        expData,...
        modelParams.umat41Upd,...
        keyPointsHL1997, keyPointsHL2002,...
        keyPointsVEXATFpe,...
        ehtmmCurves,...
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
        vexatCurves,...
        ehtmmCurves,...
        modelParams.umat41Upd,...
        modelParams.umat43Upd,...
        felineSoleusNormMuscleQuadraticCurves,...
        reshape(subPlotPanel(1,3,:),1,4),...
        plotSettings);

[figFitting]= ...
    addFittedActiveForceLengthPlotV2(...
        figFitting,...
        vexatCurves,...
        ehtmmCurves,...        
        modelParams.umat41Upd,...
        modelParams.umat43Upd,...
        felineSoleusNormMuscleQuadraticCurves,...
        keyPointsHL1997, keyPointsHL2002,...
        reshape(subPlotPanel(1,1,:),1,4),...
        plotSettings);

[figFitting]= ...
    addFittedPassiveForceLengthPlotV2(...
        figFitting,...
        vexatCurves,...
        ehtmmCurves,...          
        expData,...        
        modelParams.umat41Upd,...
        modelParams.umat43Upd,...
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
