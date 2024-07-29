%%
% SPDX-FileCopyrightText: 2024 Matthew Millard <millard.matthew@gmail.com>
%
% SPDX-License-Identifier: MIT
%
%%
flag_outerLoopMode=1;

if(flag_outerLoopMode==0)
    clc;
    close all;
    clear all;
    flag_enablePlotting=1;    
    expData = 'HL2002';
    flag_fitFromScratch=1;

else
    switch simMode
        case 'run'
            flag_enablePlotting=0;    
            flag_fitFromScratch=1;                           
        case 'plot'
            flag_enablePlotting=1;    
            flag_fitFromScratch=0;
        otherwise
            assert(0,'Error: simMode must be either run/plot');
    end
    
end

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
%%


% HL1997 (Herzog & Leonard 1997)
% HL2002 (Herzog & Leonard 2002)

switch expData
    case 'HL1997'
        modeReferenceLength=1;
    case 'HL2002'
        modeReferenceLength=1;
end
%0. Evaluate the reference length for HL1997 and HL2002 using the target 
%   value of lceN when active at the reference length
%1. Evaluate the reference length for for HL1997 and HL2002 using the 
%   target passive force at the longest length
%2. Use the average of 1 and 2
%

flag_writeLSDYNAFiles=1;

flag_addTendonLengthChangeToMat156    = 0;
flag_plotMAT156Curves                 = 1*flag_enablePlotting;

flag_assertCommonParamsIdentical=0;

flag_zeroMAT156TendonSlackLength        =1;

flag_plotHL1997AnnotationData           = 0*flag_enablePlotting;
flag_plotHL2002AnnotationData           = 0*flag_enablePlotting;

flag_plotVEXATActivePassiveForceLengthFitting = 1*flag_enablePlotting;
flag_plotEHTMMActivePassiveForceLengthFitting = 1*flag_enablePlotting;
flag_plotVEXATRigidTendonActivePassiveForceLengthFitting= 1*flag_enablePlotting;

flag_plotVEXATActiveForceLengthFitting  = 1*flag_enablePlotting;
flag_plotEHTMMActiveForceLengthFitting  = 1*flag_enablePlotting;

flag_addHL1997PassiveCurveToHL2002Figure= 1*flag_enablePlotting;
flag_plotVEXATPassiveForceLengthFitting = 1*flag_enablePlotting;
flag_plotEHTMMPassiveForceLengthFitting = 1*flag_enablePlotting;

flag_plotVEXATTitinForceLengthCurves    = 0*flag_enablePlotting;

flag_plotVEXATForceVelocityFitting      = 1*flag_enablePlotting;
flag_plotEHTMMForceVelocityFitting      = 1*flag_enablePlotting;

flag_plotMAT156Curves                 = 1*flag_enablePlotting;

%Default titin properties used across all simulations
titin.lambdaECM = 0.56;
titin.lPevkPtN  = 0.5;
titin.beta1AHN  = 55;

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

figFileNameToUpdate = 'fig_MuscleFitting_HL2002_Publication.fig';
figFilePathToUpdate = ...
    [matlabScriptPath,'/',outputFolder,'/',figFileNameToUpdate];

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

plotSettings.ylim = [0,1.33];
plotSettings.fpe.xlim = [0];
mm2m=0.001;


numberOfHorizontalPlotColumnsGeneric =3;
numberOfVerticalPlotRowsGeneric      =2;
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
modelParams.umat43RT =umat43;


titinFields=fields(titin);
for i=1:1:length(titinFields)
    disp(titinFields{i});
   modelParams.umat43Upd.(titinFields{i})= ...
       titin.(titinFields{i});
end
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
                    refExperimentFolder,...
                    flag_plotHL2002AnnotationData);

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
%Default feline soleus, but with quintic curves
load('output/structs/defaultFelineSoleus.mat');

%Default quadratic Bezier splines curve versions
tmp=load('output/structs/defaultFelineSoleusQuadraticCurves.mat');
umat43QuadraticCurves = tmp.felineSoleusNormMuscleQuadraticCurves;

%Bezier splines with the titin curves evaluated  for
% lPevkPtN = 0
% and
% lPevkPtN = 1
%
% These curves are interpolated using lPevkPtN to form, on the fly
% the correct titin curves for a specific titin-actin attachement point
load('output/structs/defaultFelineSoleusTitinQuadraticCurvesZero.mat');
load('output/structs/defaultFelineSoleusTitinQuadraticCurvesOne.mat');


umat43QuadraticTitinCurves = ...
    interpolateVEXATTitinCurves(umat43.lPevkPtN,...
                    zeroFelineTitinQuadraticCurves,...
                    oneFelineTitinQuadraticCurves);

flag_checkBezierCurveInterpolation=0;
if(flag_checkBezierCurveInterpolation==1)
    curveC = interpolateQuadraticBezierCurve( ...
                zeroFelineTitinQuadraticCurves.forceLengthDistalTitinCurve,...
                oneFelineTitinQuadraticCurves.forceLengthDistalTitinCurve,...
                0.5,...
                0.5);
    
    curveFields = fields(curveC);
    errField=zeros(length(curveFields),1);
    for i=1:1:length(curveFields)
        errMatrix= curveC.(curveFields{i}) ...
            - umat43QuadraticCurves.forceLengthDistalTitinCurve.(curveFields{i});
        errField(i)=norm(errMatrix);
        assert(errField(i) < 1e-11);
    end
end
here=1;
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
        umat43QuadraticCurves.tendonForceLengthNormCurve,...
        vexatCurves);

%%
% Active force-length relation
%  This must be fitted first since lceOpt and fceOpt are adjusted
%  when fitting the active-force-length relation.
%%

if(flag_fitFromScratch==1)

    [modelParams.umat43Upd, ...
        keyPointsHL1997, ...
        keyPointsHL2002, ...
        keyPointsVEXATFpe,...
        vexatCurves]= ...
            fitVEXATActivePassiveForceLengthRelation(...
                expData,...
                modelParams.umat43Upd,...
                defaultFelineSoleus.sarcomere,...
                umat43QuadraticCurves,...
                umat43QuadraticTitinCurves,...
                keyPointsHL1997,...
                keyPointsHL2002,...
                vexatCurves,...
                flag_plotVEXATActivePassiveForceLengthFitting);

    fitFileName = fullfile('output','structs',['vexatActivePassiveFit_',expData]);
    fitStruct.umat43            =   modelParams.umat43Upd;
    fitStruct.keyPointsHL1997   =   keyPointsHL1997;
    fitStruct.keyPointsHL2002   =   keyPointsHL2002;
    fitStruct.keyPointsVEXATFpe =   keyPointsVEXATFpe;
    fitStruct.vexatCurves       =   vexatCurves;
    
    save([fitFileName,'.mat'],'-struct','fitStruct');
else

    fitFileName = fullfile('output','structs',['vexatActivePassiveFit_',expData]);
    fitStruct=load([fitFileName,'.mat']);

    modelParams.umat43Upd   = fitStruct.umat43;
    keyPointsHL1997         = fitStruct.keyPointsHL1997;
    keyPointsHL2002         = fitStruct.keyPointsHL2002;
    keyPointsVEXATFpe       = fitStruct.keyPointsVEXATFpe;
    vexatCurves             = fitStruct.vexatCurves;
    
end


disp(['Setting all models to have the same lceOpt, fceOpt, lceOptAT, fceOptAT,']);
fieldsToUpdate = {'lceOptAT','fceOptAT','lceOpt','fceOpt',...
                  'ltSlk','lp0HL2002','lp0HL1997'};
for i=1:1:length(fieldsToUpdate)
    modelParams.umat41Upd.(fieldsToUpdate{i})= ...
        modelParams.umat43Upd.(fieldsToUpdate{i});
    modelParams.mat156Upd.(fieldsToUpdate{i})= ...
        modelParams.umat43Upd.(fieldsToUpdate{i});
    modelParams.umat43RT.(fieldsToUpdate{i})= ...
        modelParams.umat43Upd.(fieldsToUpdate{i});
end

disp(['Setting all umat43 models to have the same titin and XE properties']);
fieldsToUpdate = {'lPevkPtN','beta1AHN'};
for i=1:1:length(fieldsToUpdate)
    modelParams.umat43RT.(fieldsToUpdate{i})= ...
        modelParams.umat43Upd.(fieldsToUpdate{i});
end

modelParams.mat156Upd.ltSlk = 0;
modelParams.mat156Upd.et    = 0;

modelParams.umat43RT.ltSlk  = 0;
modelParams.umat43RT.et     = 0;




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
            umat43QuadraticCurves.tendonForceLengthNormCurve,0);
end

[modelParams.umat41Upd, ...
 umat41ftError,ehtmmCurves] =...
        fitEHTMMTendon(...
            modelParams.umat41Upd, ...
            keyPointsTendon,...
            ehtmmCurves);
%%
% Active-passive-force length relation EHTMM
%     Fit the parameters to minimize the squared error with 
%     HL1997 and HL2002
%%
umat41HL2002 = [];
if(contains(expData,'HL1997'))
    fitFileName = fullfile('output','structs',['ehtmmActivePassiveFit_HL2002']);
    fitStructUmat41 = load(fitFileName);
    umat41HL2002=fitStructUmat41.umat41;
end


[modelParams.umat41Upd, ...
 ehtmmCurves] = ...
        fitEHTMMActivePassiveForceLengthRelation(...
           expData, ...
           modelParams.umat41Upd, ...
           umat41HL2002,...           
           keyPointsHL1997,...
           keyPointsHL2002,...
           keyPointsVEXATFpe,...
           vexatCurves.fpe,...
           ehtmmCurves,...
           flag_plotEHTMMActivePassiveForceLengthFitting);

if(contains(expData,'HL2002'))
    fitFileName = fullfile('output','structs',['ehtmmActivePassiveFit_',expData]);
    fitStruct.umat41=modelParams.umat41Upd;
    save([fitFileName,'.mat'],'-struct','fitStruct');
end

%%
% Active-passive force length relation MAT156:
%  A rigid tendon version of umat43.
%%
[modelParams.umat43RT, ...
 vexatRTCurves] = ...
    fitVEXATRigidTendonActivePassiveForceLengthRelation(...
       expData, ...
       modelParams.umat43RT, ...
       defaultFelineSoleus.sarcomere,...
       umat43QuadraticCurves,...
       umat43QuadraticTitinCurves,...
       keyPointsHL1997,...
       keyPointsHL2002,...
       flag_plotVEXATRigidTendonActivePassiveForceLengthFitting);


%%
% Force-velocity relation
%%
[modelParams.umat43Upd, vexatCurves, keyPointsVEXATFv]= ...
    fitVEXATForceVelocityRelation(...
        modelParams.umat43Upd,...
        keyPointsHL1997,...
        umat43QuadraticCurves,...
        vexatCurves,...
        flag_plotVEXATForceVelocityFitting);

modelParams.mat156Upd.vceMax    = keyPointsVEXATFv.vceMaxAT;
modelParams.umat43RT.vceMax     = keyPointsVEXATFv.vceMax;
vexatRTCurves.fv                = vexatCurves.fv;

[modelParams.umat41Upd, ehtmmCurves]= ...
    fitEHTMMForceVelocityRelation(...
        modelParams.umat41Upd,...
        keyPointsHL1997,...
        keyPointsVEXATFv,....
        ehtmmCurves,...
        flag_plotEHTMMForceVelocityFitting);


%%
%Reference path lengths
%%

%Copy over starting lengths of umat43RT to mat156
modelParams.mat156Upd.lp0HL2002 = modelParams.umat43RT.lp0HL2002;
modelParams.mat156Upd.lp0HL1997 = modelParams.umat43RT.lp0HL1997;


if(contains(expData,'HL2002'))
    %Get the starting lengths for K1994
    [modelParams.mat156Upd,...
     modelParams.umat41Upd,...
     modelParams.umat43Upd]=calcKBR1994StartingPathLength(...
                                        modelParams.mat156Upd,...
                                        modelParams.umat41Upd,...
                                        modelParams.umat43Upd,...
                                        umat43QuadraticCurves,... 
                                        vexatCurves);
    modelParams.mat156Upd.lp0K1994  = modelParams.umat43RT.lp0HL2002;
end

%%
% Write the new parameter files
%%
if(flag_writeLSDYNAFiles==1)

    %umat43ExtraParams.kbr1994Fig12 = {'R   kxIsoN 49.1','R   dxIsoN 0.347'};
    %umat43ExtraParams.kbr1994Fig3= {'R   kxIsoN 74.5','R   dxIsoN 0.155'};

    kbr1994ExtraParams.Fig3.kxIsoN     = 74.5;
    kbr1994ExtraParams.Fig3.dxIsoN     =  0.155;
    kbr1994ExtraParams.Fig12.kxIsoN    = 49.1;
    kbr1994ExtraParams.Fig12.dxIsoN    =  0.347;

    umat43.kxIsoN = kbr1994ExtraParams.Fig12.kxIsoN;
    umat43.dxIsoN = kbr1994ExtraParams.Fig12.dxIsoN;

    success = writeAllLSDYNAMuscleParameterFiles(...
                modelFolder,...
                expAbbrv,...
                modelParams.mat156Upd,...
                modelParams.umat41Upd,...
                modelParams.umat43Upd,...
                kbr1994ExtraParams);
        

    success = writeMAT156ModelFileV2(...
                modelFolder,...
                expAbbrv,...
                modelParams.mat156Upd,...
                modelParams.umat43RT,...
                vexatRTCurves,...
                flag_plotMAT156Curves);
end

%%
%Plot the fitted results
%%
if(flag_enablePlotting==1)
    [subPlotPanel, pageWidth,pageHeight]= ...
      plotConfigGeneric(  numberOfHorizontalPlotColumnsGeneric,...
                          numberOfVerticalPlotRowsGeneric,...
                          plotWidth,plotHeight,...
                          plotHorizMarginCm,plotVertMarginCm,...
                          baseFontSize); 
    
    plotSettings.pageHeight=pageHeight;
    plotSettings.pageWidth=pageWidth;
    
    figFitting=figure;
    
    subplot('Position',reshape(subPlotPanel(1,1,:),1,4));
    title('A. Simplified musculotendon geometry');
    
    [figFitting]= ...
        addFittedTendonPlot(...
            figFitting,...
            vexatCurves,...
            ehtmmCurves,...
            modelParams.umat41Upd,...
            modelParams.umat43Upd,...
            umat43QuadraticCurves,...
            reshape(subPlotPanel(1,2,:),1,4),...
            plotSettings);
    
    [figFitting]= ...
        addFittedActiveForceLengthPlotV2(...
            figFitting,...
            vexatCurves,...
            ehtmmCurves,...        
            modelParams.umat41Upd,...
            modelParams.umat43Upd,...
            defaultFelineSoleus.sarcomere,...
            umat43QuadraticCurves,...
            keyPointsHL1997, keyPointsHL2002,...       
            reshape(subPlotPanel(1,3,:),1,4),...
            plotSettings);
    
    [figFitting,fpeXlim]= ...
        addFittedPassiveForceLengthPlotV2(...
            figFitting,...
            vexatCurves,...
            ehtmmCurves,...          
            expData,...        
            modelParams.umat41Upd,...
            modelParams.umat43Upd,...
            keyPointsHL1997, ...
            keyPointsHL2002,...
            keyPointsVEXATFpe,...
            umat43QuadraticCurves.fiberForceLengthCurve,...
            reshape(subPlotPanel(2,1,:),1,4),...
            plotSettings);
    
    plotSettings.fpe.xlim=fpeXlim;
    
    [figFitting]= ...
        addTitinForceLengthPlot(...
            figFitting,...
            vexatCurves,...
            modelParams.umat43Upd,...
            keyPointsHL2002,...
            defaultFelineSoleus.sarcomere,...
            umat43QuadraticCurves.fiberForceLengthCurve,...
            reshape(subPlotPanel(2,2,:),1,4),...
            plotSettings);
    
    
    %Titin
    
    [figFitting]= ...
        addFittedForceVelocityPlot(...
            figFitting,...
            vexatCurves,...
            ehtmmCurves,...          
            expData,...        
            modelParams.umat41Upd,...
            modelParams.umat43Upd,...
            keyPointsHL1997, ...
            keyPointsHL2002,...
            keyPointsVEXATFv,...
            reshape(subPlotPanel(2,3,:),1,4),...
            plotSettings);
    
    
    if(flag_addHL1997PassiveCurveToHL2002Figure==1 && ...
            contains(expData,'HL1997'))
    
          success = updateFittedPassiveForceLengthPlot(...
                        figFilePathToUpdate,...
                        vexatCurves,...
                        ehtmmCurves,...          
                        expData,...        
                        modelParams.umat41Upd,...
                        modelParams.umat43Upd,...
                        keyPointsHL1997,...
                        keyPointsHL2002,...
                        keyPointsVEXATFpe,...
                        reshape(subPlotPanel(2,1,:),1,4),...
                        plotSettings);
    end
    
    
    %%
    %Write the plot to file
    %%
    figure(figFitting);      
    figFitting=configPlotExporter(figFitting, ...
                pageWidth, pageHeight);
    fileName =    ['fig_MuscleFitting_',expData,'_Publication'];
    print('-dpdf', [matlabScriptPath,'/',outputFolder,'/',...
          fileName,'.pdf']);
    
    saveas(figFitting,[matlabScriptPath,'/',outputFolder,'/',...
          fileName],'fig');
end


