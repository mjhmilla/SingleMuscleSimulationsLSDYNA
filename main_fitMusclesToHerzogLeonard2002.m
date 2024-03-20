clc;
close all;
clear all;

flag_fitPassiveForceLength   =1;
flag_fitActiveForceLength    =1;

scaleExpFpeData= 1;

addpath(genpath('models'));
addpath(genpath('fitting'));
addpath(genpath('numeric'));
addpath(genpath('curves'));
addpath(genpath('preprocessing'));
addpath(genpath('postprocessing'));
addpath(genpath('ReferenceExperiments'));

mat156Color = [193, 39, 45]./255;
umat41Color = [0.75, 0, 0.75];
umat43Color = [0, 0.4470, 0.7410];

mm2m=0.001;

dataHL2002File = ...
    fullfile('ReferenceExperiments','eccentric_HerzogLeonard2002',...
             'digitizedKeyPointsHerzogLeonard2002.csv');

keyPtsHL2002.data= dlmread(dataHL2002File,',',1,0);
keyPtsHL2002.colVelocity      =1;
keyPtsHL2002.colLengthA       =2;
keyPtsHL2002.colLengthB       =3;
keyPtsHL2002.colTimeFirst     =4;
keyPtsHL2002.colForceFirst    =5;
keyPtsHL2002.colTimeLast      =20;
keyPtsHL2002.colForceLast     =21;
keyPtsHL2002.colTimeDelta     =2;
keyPtsHL2002.colForceDelta    =2;
keyPtsHL2002.lceRef   = nan;
keyPtsHL2002.lceNRef  = nan;

dataFiles = {'dataHerzogLeonard2002Figure7A.dat',...
             'dataHerzogLeonard2002Figure7B.dat',...
             'dataHerzogLeonard2002Figure7C.dat'};

dataLabels = {'3mm/s','9mm/s','27mm/s'};

dataHL2002FigA = importdata(['ReferenceExperiments',filesep,...
                                'eccentric_HerzogLeonard2002',filesep,...
                                'dataHerzogLeonard2002Figure7A.dat']);

dataHL2002FigA.colTime            =  1;
dataHL2002FigA.colIsoForce_0mm    =  2;
dataHL2002FigA.colIsoLength_0mm   =  3;
dataHL2002FigA.colIsoForce_9mm    =  4;
dataHL2002FigA.colIsoLength_9mm   =  5;
dataHL2002FigA.colActForce_6_9mm  =  6;
dataHL2002FigA.colActLength_6_9mm =  7;
dataHL2002FigA.colActForce_3_9mm  =  8;
dataHL2002FigA.colActLength_3_9mm =  9;
dataHL2002FigA.colPasForce_0_9mm  = 10;
dataHL2002FigA.colPasLength_0_9mm = 11;
dataHL2002FigA.colActForce_0_9mm  = 12;
dataHL2002FigA.colActLength_0_9mm = 13;



%%
% Plotting properties
%%
set(groot, 'defaultAxesFontSize',8);
set(groot, 'defaultTextFontSize',8);
set(groot, 'defaultAxesLabelFontSizeMultiplier',1.2);
set(groot, 'defaultAxesTitleFontSizeMultiplier',1.2);
set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultLegendInterpreter','latex');
set(groot, 'defaultTextInterpreter','latex');
set(groot, 'defaultAxesTitleFontWeight','bold');  
set(groot, 'defaultFigurePaperUnits','centimeters');
set(groot,'defaultFigurePaperType','A4');

figFitting=figure;

%%
% Reference Bezier Curves used for umat43 and mat156
%   Generated using: 
%       main_createExplicitBezierSplineMuscleCurves.m
%   From:
%       https://github.com/mjhmilla/FastMuscleCurves
%%
load('output/structs/defaultFelineSoleusQuadraticCurves.mat');
load('output/structs/defaultFelineSoleus.mat');

%%
% Architectural properties (NMS)
%%
expAbbrv = 'HL2002';
modelFolder = fullfile('MPP_R931','common');
flag_assertCommonParamsIdentical=1;
[mat156,umat41,umat43] = getCommonModelParameters(modelFolder,expAbbrv,...
                          flag_assertCommonParamsIdentical);

catSoleusHL2002.lceOpt  =umat43.lceOpt;
catSoleusHL2002.fceOpt  =umat43.fceOpt;
catSoleusHL2002.lceOptAT=umat43.lceOptAT;
catSoleusHL2002.fceOptAT=umat43.fceOptAT;
catSoleusHL2002.lmtOptAT=umat43.lmtOptAT;
catSoleusHL2002.penOpt  =umat43.penOpt;
catSoleusHL2002.penOptD =umat43.penOptD;
catSoleusHL2002.ltSlk   =umat43.ltSlk;
catSoleusHL2002.et      =umat43.et;
catSoleusHL2002.vceMax  =umat43.vceMax;

keyPtsHL2002.lceRef  = catSoleusHL2002.lceOptAT*umat43.lceNScale ...
                      + (catSoleusHL2002.et)*catSoleusHL2002.ltSlk;
keyPtsHL2002.lceNRef = keyPtsHL2002.lceRef/catSoleusHL2002.lceOpt;


%%
%Tendon curve (manually fitted)
%%
[figFitting,umat41Curves,umat43Curves] = ...
    addFittedTendonPlot(figFitting,umat41,umat43,...
                            felineSoleusNormMuscleQuadraticCurves,...
                            [2,2,1],umat41Color,umat43Color);

%%
% Passive force-length curve
%%
%%
%time series data
%%
expDataFpe.time   = dataHL2002FigA.data(:,dataHL2002FigA.colTime);

expDataFpe.lmt    = ...
     dataHL2002FigA.data(:,dataHL2002FigA.colPasLength_0_9mm).*mm2m ...
   + keyPtsHL2002.lceRef;

expDataFpe.fmt = dataHL2002FigA.data(:,dataHL2002FigA.colPasForce_0_9mm);

expDataFpe.name='HL2002';

%%
%keypoints
%%
expKeyPtsDataFpe.time = [];

expKeyPtsDataFpe.lmt =...
    ( [keyPtsHL2002.data([4,7],keyPtsHL2002.colLengthA); ...
       keyPtsHL2002.data([1],keyPtsHL2002.colLengthB)].*mm2m ...
    + keyPtsHL2002.lceRef );

expKeyPtsDataFpe.fmt =...
     [keyPtsHL2002.data([4,7],keyPtsHL2002.colForceFirst+2*3);...
      keyPtsHL2002.data([1],keyPtsHL2002.colForceFirst+2*2)];

expKeyPtsDataFpe.name = 'HL2002';

[maxVal, idxMax] = max(expDataFpe.fmt);
expKeyPtsDataFpe.lmt =...
    [expKeyPtsDataFpe.lmt;expDataFpe.lmt(end)];
expKeyPtsDataFpe.fmt = ...
    [expKeyPtsDataFpe.fmt;expDataFpe.fmt(end)];

expKeyPtsDataFpe.weights = ones(size(expKeyPtsDataFpe.lmt));
expKeyPtsDataFpe.weights(1,1)=0.1;


%
% fit umat43
%
if(flag_fitPassiveForceLength==1)


    [umat43upd,expKeyPtsDataFpeUpd]= ...
        fitUmat43PassiveForceLengthRelation(...
                      umat43, felineSoleusNormMuscleQuadraticCurves,...
                      expKeyPtsDataFpe,scaleExpFpeData);

    fprintf('umat43 passive curve fitted\n');
    fprintf('\t%1.6f\tshiftPEE\n',umat43upd.shiftPEE);
    fprintf('\t%1.6f\tscalePEE\n' ,umat43upd.scalePEE);
    
    %
    % fit umat41
    %
    umat41upd = fitUmat41PassiveForceLengthRelation(...
                        umat41,expKeyPtsDataFpeUpd, scaleExpFpeData);
    
    fprintf('umat41 passive curve fitted\n');
    fprintf('\t%1.6f\tLPEE0\n',umat41upd.LPEE0);
    fprintf('\t%1.6f\tFPEE\n' ,umat41upd.FPEE);
    fprintf('\t%1.6f\tnuPEE\n',umat41upd.nuPEE);

else
    umat43upd=umat43;
    umat41upd=umat41;
end


[figFitting,umat41Curves,umat43Curves] = ...
    addFittedPassiveForceLengthPlot(figFitting,umat41upd,umat43upd,...
                            felineSoleusNormMuscleQuadraticCurves,...
                            umat41Curves,umat43Curves,...                            
                            [2,2,2],umat41Color,umat43Color,...
                            expKeyPtsDataFpe,expDataFpe,...
                            '--');


%%
% Active force length
%%
expKeyPtsDataFal.time = [];

expKeyPtsDataFal.lmt =...
    ( [keyPtsHL2002.data([1,4,7,10,11],keyPtsHL2002.colLengthA)].*mm2m ...
    + keyPtsHL2002.lceRef );

expKeyPtsDataFal.fmt =...
     [keyPtsHL2002.data([1,4,7],keyPtsHL2002.colForceFirst+2*4);...
      keyPtsHL2002.data([10,11],keyPtsHL2002.colForceFirst+2*4)];

expKeyPtsDataFal.name = 'HL2002';


if(flag_fitActiveForceLength==1)
     umat41upd = fitUmat41ActiveForceLengthRelation(...
                            umat41upd,expKeyPtsDataFal,...
                            umat43upd,felineSoleusNormMuscleQuadraticCurves);    
    fprintf('umat41 active curve (descending limb) fitted\n');
    fprintf(   '\t%1.6f\tdWdes\n',umat41upd.dWdes);
    fprintf('\t%1.6f\tnuCEdes\n' ,umat41upd.nuCEdes);
end

umat41upd.dWdes=umat41upd.dWdes;
umat41upd.nuCEdes=umat41upd.nuCEdes;
[figFitting,umat41Curves,umat43Curves] = ...
    addFittedActiveForceLengthPlot(figFitting,umat41upd,umat43upd,...
                            felineSoleusNormMuscleQuadraticCurves,...
                            umat41Curves,umat43Curves,...                            
                            [2,2,3],umat41Color,umat43Color,...
                            expKeyPtsDataFal,'-');
%%
% Generate MAT156 curves that fit umat43
%%
npts=100;
domain=[];

falValues = calcQuadraticBezierYFcnXCurveSampleVector(...
  felineSoleusNormMuscleQuadraticCurves.activeForceLengthCurve,...
  npts, domain);


fpeValues = calcQuadraticBezierYFcnXCurveSampleVector(...
  felineSoleusNormMuscleQuadraticCurves.fiberForceLengthCurve,...
  npts, domain);

fvValues = calcQuadraticBezierYFcnXCurveSampleVector(...
  felineSoleusNormMuscleQuadraticCurves.fiberForceVelocityCurve,...
  npts, domain);

%
% Evaluate the active force length curve direction of the tendon
%
falValues.xAT = zeros(size(falValues.x));
falValues.yAT = zeros(size(falValues.x));

for i=1:1:length(falValues.x)
    fibKin = calcFixedWidthPennatedFiberKinematicsAlongTendon(...
                                                falValues.x(i,1).*umat43.lceOpt,...
                                                0,...
                                                umat43.lceOpt,...
                                                umat43.penOpt);
    alpha=fibKin.pennationAngle;
    lceAT=fibKin.fiberLengthAlongTendon;
    falValues.xAT(i,1)=lceAT/umat41.lceOptAT;
    falValues.yAT(i,1)=falValues.y(i,1)*cos(alpha)/cos(umat43.penOpt);
end


%
% Evaluate the passive force length curve direction of the tendon
% and adjust the length for the compliance introduced by the tendon
%
fpeValues.xAT = zeros(size(fpeValues.x));
fpeValues.yAT = zeros(size(fpeValues.x));

dfpeA = calcQuadraticBezierYFcnXDerivative(...
            felineSoleusNormMuscleQuadraticCurves.fiberForceLengthCurve.xEnd(1,2)-1e-6, ...
            felineSoleusNormMuscleQuadraticCurves.fiberForceLengthCurve,1);
dfpeB = calcQuadraticBezierYFcnXDerivative(...
            felineSoleusNormMuscleQuadraticCurves.fiberForceLengthCurve.xEnd(1,2)+1e-6, ...
            felineSoleusNormMuscleQuadraticCurves.fiberForceLengthCurve,1);

dftA = calcQuadraticBezierYFcnXDerivative(...
            felineSoleusNormMuscleQuadraticCurves.tendonForceLengthCurve.xEnd(1,2)-1e-6, ...
            felineSoleusNormMuscleQuadraticCurves.tendonForceLengthCurve,1);
dftB = calcQuadraticBezierYFcnXDerivative(...
            felineSoleusNormMuscleQuadraticCurves.tendonForceLengthCurve.xEnd(1,2)+1e-6, ...
            felineSoleusNormMuscleQuadraticCurves.tendonForceLengthCurve,1);


for i=1:1:length(fpeValues.x)
    fibKin = calcFixedWidthPennatedFiberKinematicsAlongTendon(...
                                                fpeValues.x(i,1).*umat43.lceOpt,...
                                                0,...
                                                umat43.lceOpt,...
                                                umat43.penOpt);
    alpha   = fibKin.pennationAngle;
    lceAT   = fibKin.fiberLengthAlongTendon;
    lceNAT  = lceAT/umat43.lceOpt;
    fpeN    = calcQuadraticBezierYFcnXDerivative(fpeValues.x(i,1)-umat43upd.shiftPEE, ...
                felineSoleusNormMuscleQuadraticCurves.fiberForceLengthCurve,0);
    fpeN    = fpeN*umat43upd.scalePEE;
    fpeNAT  = fpeN*cos(alpha);
    ltN     = calcQuadraticBezierYFcnXDerivative(fpeNAT,...
                felineSoleusNormMuscleQuadraticCurves.tendonForceLengthInverseCurve,0);
    %The tendon curve goes to numerical zero very slowly, and so very small
    %postive force values correspond to large negative lengths.
    if(ltN < 1)
        ltN=1;
    end
    lceNAT_dltN = lceNAT + ((ltN-1)*umat43.ltSlk)/umat43.lceOpt;
    fpeValues.xAT(i,1)=lceNAT_dltN;
    fpeValues.yAT(i,1)=fpeNAT;
end

%
% Evaluate the force-velocity curve in the direction of the tendon
%
%Evaluate the force-velocity curve along the tendon

fibKin=calcFixedWidthPennatedFiberKinematicsAlongTendon(...
                                                umat43.lceOpt,...
                                                umat43.vceMax,...
                                                umat43.lceOpt,...
                                                umat43.penOpt);
vceMax156 = fibKin.fiberVelocityAlongTendon;
fprintf('mat156 vceMax that matches umat43 in the direction of the tendon\n');
fprintf(   '\t%1.6f\tvceMax\n',vceMax156);

for i=1:1:length(fvValues.x)
    fiberKinematics = calcFixedWidthPennatedFiberKinematicsAlongTendon(...
                                                umat43.lceOpt,...
                                                fvValues.x(i,1)*(umat43.vceMax),...
                                                umat43.lceOpt,...
                                                umat43.penOpt);

    alpha = fiberKinematics.pennationAngle;
    lceAT = fiberKinematics.fiberLengthAlongTendon;
    vceAT = fiberKinematics.fiberVelocityAlongTendon;


    fvValues.xAT(i,1) = vceAT/vceMax156;
    fvValues.yAT(i,1) = fvValues.y(i,1)*cos(alpha)/cos(umat43.penOpt);
end

figMAT156=figure;
figure(figMAT156);
    subplot(1,3,1);
        plot(falValues.x,...
             falValues.y,...
             '-','Color',[1,1,1].*0.5,...
             'LineWidth',2,...
             'DisplayName','umat43 (along fiber)');
        hold on;
        plot(falValues.xAT,...
             falValues.yAT,...
             '-','Color',[1,0,0],'DisplayName','mat156');
        hold on;
        box off;    
        xlabel('Norm. Length ($$\ell^M/\ell^M_o$$)');
        ylabel('Norm. Force ($$f^M/f^M_o$$)');
        title('Active Force-Length Relation');

    subplot(1,3,2);  
        plot(fpeValues.x-umat43.shiftPEE,...
             fpeValues.y.*umat43.scalePEE,...
             '-','Color',[1,1,1].*0.5,...
             'LineWidth',2,...
             'DisplayName','umat43 (along fiber)');
        hold on;    
        plot(fpeValues.xAT,...
             fpeValues.yAT,...
             '-','Color',[1,0,0],'DisplayName','mat156');
        hold on;
        box off;
        xlabel('Norm. Length ($$\ell^M/\ell^M_o$$)');
        ylabel('Norm. Force ($$f^M/f^M_o$$)');
        title('Passive Force-Length Relation');

    subplot(1,3,3);    
        plot(fvValues.x,...
             fvValues.y,...
             '-','Color',[1,1,1].*0.5,...
             'LineWidth',2,...
             'DisplayName','umat43 (along fiber)');
        hold on;
        plot(fvValues.xAT,...
             fvValues.yAT,...
             '-','Color',[1,0,0],'DisplayName','mat156');
        hold on;
        box off;
        xlabel('Norm. Velocity ($$v^M/v^M_{max}$$)');
        ylabel('Norm. Force ($$f^M/f^M_o$$)');
        title('Force-Velocity Relation');
    

success = writeFortranVector(falValues.xAT, falValues.yAT, 10, ...
    'output/fortran/MAT156Tables/defaultFelineSoleusQ_activeForceLengthCurve.f');
success = writeFortranVector(fpeValues.xAT, fpeValues.yAT, 11, ...
    'output/fortran/MAT156Tables/defaultFelineSoleusQ_forceLengthCurve.f');
success = writeFortranVector(fvValues.xAT, fvValues.yAT, 12, ...
    'output/fortran/MAT156Tables/defaultFelineSoleusQ_forceVelocityCurve.f');
