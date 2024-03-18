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



catSoleusHL2002.lceOpt  =mat156.lceOpt;
catSoleusHL2002.fceOpt  =mat156.fceOpt;
catSoleusHL2002.lceOptAT=mat156.lceOptAT;
catSoleusHL2002.fceOptAT=mat156.fceOptAT;
catSoleusHL2002.lmtOptAT=mat156.lmtOptAT;
catSoleusHL2002.penOpt  =mat156.penOpt;
catSoleusHL2002.penOptD =mat156.penOptD;
catSoleusHL2002.ltSlk   =mat156.ltSlk;
catSoleusHL2002.et      =mat156.et;
catSoleusHL2002.vceMax  =mat156.vceMax;

keyPtsHL2002.lceRef  = catSoleusHL2002.lceOptAT*umat43.lceNScale;
keyPtsHL2002.lceNRef = umat43.lceNScale;


%%
%Tendon curve (manually fitted)
%%
[figFitting,umat41Curves,umat43Curves] = ...
    addTendonFittingInfo(figFitting,umat41,umat43,...
                            felineSoleusNormMuscleQuadraticCurves,...
                            umat41Color,umat43Color);



%%
% Passive force-length curve
%%

%data
expDataFpe.time   = dataHL2002FigA.data(:,dataHL2002FigA.colTime);
expDataFpe.lmtNAT = ...
    (dataHL2002FigA.data(:,dataHL2002FigA.colPasLength_0_9mm).*mm2m ...
   + keyPtsHL2002.lceRef)./catSoleusHL2002.lceOptAT;

expDataFpe.fmtNAT = dataHL2002FigA.data(:,dataHL2002FigA.colPasForce_0_9mm)...
                ./catSoleusHL2002.fceOptAT;
expDataFpe.name='HL2002';

%keypoints
expKeyPtsDataFpe.time = [];

expKeyPtsDataFpe.lmtNAT =...
    ( keyPtsHL2002.data([4,7],keyPtsHL2002.colLengthA).*mm2m ...
    + keyPtsHL2002.lceRef ) /catSoleusHL2002.lceOptAT;

expKeyPtsDataFpe.fmtNAT =...
     keyPtsHL2002.data([4,7],keyPtsHL2002.colForceFirst+2*3) ...
     / catSoleusHL2002.fceOptAT;
expKeyPtsDataFpe.name = 'HL2002';

[maxVal, idxMax] = max(expDataFpe.fmtNAT);
expKeyPtsDataFpe.lmtNAT =...
    [expKeyPtsDataFpe.lmtNAT;expDataFpe.lmtNAT(end)];
expKeyPtsDataFpe.fmtNAT = ...
    [expKeyPtsDataFpe.fmtNAT;expDataFpe.fmtNAT(end)];

%
% fit umat43
%
x0 = [umat43.shiftPEE];%;umat43.scalePEE];
error0 = calcVEXATPassiveCurveError(x0,umat43,...
                           felineSoleusNormMuscleQuadraticCurves,...
                           expKeyPtsDataFpe,1);
error0Mag = sum(error0.^2);

calcUmat43FpeErr = @(arg)calcVEXATPassiveCurveError(arg,umat43,...
                           felineSoleusNormMuscleQuadraticCurves,...
                           expKeyPtsDataFpe,error0Mag);
[x1,resnorm]=lsqnonlin(calcUmat43FpeErr,x0);

error1 = calcVEXATPassiveCurveError(x1,umat43,...
                           felineSoleusNormMuscleQuadraticCurves,...
                           expKeyPtsDataFpe,1);
error1Mag = sum(error1.^2);

umat43upd = umat43;
umat43upd.shiftPEE = x1(1,1);
%umat43upd.scalePEE = x1(2,1);

%
% fit umat41
%
expKeyPtsDataFpeUpd = expKeyPtsDataFpe;

expKeyPtsDataFpeUpd.lmtNAT=[expKeyPtsDataFpe.lmtNAT;1.3747];
expKeyPtsDataFpeUpd.fmtNAT=[expKeyPtsDataFpe.fmtNAT;1];

x0      = [umat41.LPEE0];%;umat41.FPEE];
error0  = calcEHTMMPassiveCurveError(x0,umat41,expKeyPtsDataFpeUpd,1);
error0Mag= sum(error0.^2);
calcUmat41FpeErr = @(arg)calcEHTMMPassiveCurveError(arg,umat41,...
                                        expKeyPtsDataFpeUpd,error0Mag);

[x1,resnorm]=lsqnonlin(calcUmat41FpeErr,x0);
error1  = calcEHTMMPassiveCurveError(x1,umat41,expKeyPtsDataFpeUpd,1);
error1Mag= sum(error1.^2);

umat41upd       = umat41;
umat41upd.LPEE0 = x1(1,1);
%umat41upd.FPEE  = x1(2,1);



[figFitting,umat41Curves,umat43Curves] = ...
    addPassiveForceLengthFittingInfo(figFitting,umat41upd,umat43upd,...
                            felineSoleusNormMuscleQuadraticCurves,...
                            umat41Curves,umat43Curves,...                            
                            umat41Color,umat43Color,...
                            expKeyPtsDataFpe,expDataFpe);


