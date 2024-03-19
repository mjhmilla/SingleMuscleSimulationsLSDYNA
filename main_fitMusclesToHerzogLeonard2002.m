clc;
close all;
clear all;

flag_fitPassiveForceLength   =1;

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
    ( keyPtsHL2002.data([4,7],keyPtsHL2002.colLengthA).*mm2m ...
    + keyPtsHL2002.lceRef );

expKeyPtsDataFpe.fmt =...
     keyPtsHL2002.data([4,7],keyPtsHL2002.colForceFirst+2*3);
expKeyPtsDataFpe.name = 'HL2002';

[maxVal, idxMax] = max(expDataFpe.fmt);
expKeyPtsDataFpe.lmt =...
    [expKeyPtsDataFpe.lmt;expDataFpe.lmt(end)];
expKeyPtsDataFpe.fmt = ...
    [expKeyPtsDataFpe.fmt;expDataFpe.fmt(end)];


%
% fit umat43
%
if(flag_fitPassiveForceLength==1)
    x0 = [umat43.shiftPEE;umat43.scalePEE];
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
    umat43upd.scalePEE = x1(2,1);

    fprintf('umat43 passive curve fitted\n');
    fprintf('\t%1.6f\tshiftPEE\n',umat43upd.shiftPEE);
    fprintf('\t%1.6f\tscalePEE\n' ,umat43upd.scalePEE);

    %Use the model to generate a point near fpe=1. THis gets appended
    %to the points that umat41's fpe curve is fit to. Why? Otherwise 
    %the optimization routine changes nuPEE by a lot. The result is a good
    %fit for low forces but a terrible fit for higher forces.
    lceNX = 1.4039;
    fpeNX = calcQuadraticBezierYFcnXDerivative(lceNX-umat43upd.shiftPEE,...
              felineSoleusNormMuscleQuadraticCurves.fiberForceLengthCurve,0); 
    fpeNX = fpeNX*umat43upd.scalePEE;
    
    fibKin = calcFixedWidthPennatedFiberKinematicsAlongTendon(...
        lceNX*umat43.lceOpt,0,umat43.lceOpt,umat43.penOpt);
    
    lceATX = fibKin.fiberLengthAlongTendon; 
    alphaX = fibKin.pennationAngle;
    
    ltNX = calcQuadraticBezierYFcnXDerivative(fpeNX*cos(alphaX),...
              felineSoleusNormMuscleQuadraticCurves.tendonForceLengthInverseCurve,0);
    
    lmtX = lceATX + (ltNX-1)*umat43.ltSlk;
    fmtX = fpeNX*umat43.fceOpt*cos(alphaX);
    
    %
    % fit umat41
    %
    expKeyPtsDataFpeUpd = expKeyPtsDataFpe;
    
    expKeyPtsDataFpeUpd.lmt=[expKeyPtsDataFpe.lmt;lmtX];
    expKeyPtsDataFpeUpd.fmt=[expKeyPtsDataFpe.fmt;fmtX];
    
    x0      = [umat41.LPEE0;umat41.FPEE;umat41.nuPEE];
    error0  = calcEHTMMPassiveCurveError(x0,umat41,expKeyPtsDataFpeUpd,1);
    error0Mag= sum(error0.^2);
    calcUmat41FpeErr = @(arg)calcEHTMMPassiveCurveError(arg,umat41,...
                                            expKeyPtsDataFpeUpd,error0Mag);
    
    [x1,resnorm]=lsqnonlin(calcUmat41FpeErr,x0);
    error1  = calcEHTMMPassiveCurveError(x1,umat41,expKeyPtsDataFpeUpd,1);
    error1Mag= sum(error1.^2);
    
    umat41upd       = umat41;
    umat41upd.LPEE0 = x1(1,1);
    umat41upd.FPEE  = x1(2,1);
    umat41upd.nuPEE = x1(3,1);

    fprintf('umat41 passive curve fitted\n');
    fprintf('\t%1.6f\tLPEE0\n',umat41upd.LPEE0);
    fprintf('\t%1.6f\tFPEE\n' ,umat41upd.FPEE);
    fprintf('\t%1.6f\tnuPEE\n',umat41upd.nuPEE);

else
    umat43upd=umat43;
    umat41upd=umat41;
end



[figFitting,umat41Curves,umat43Curves] = ...
    addPassiveForceLengthFittingInfo(figFitting,umat41upd,umat43upd,...
                            felineSoleusNormMuscleQuadraticCurves,...
                            umat41Curves,umat43Curves,...                            
                            umat41Color,umat43Color,...
                            expKeyPtsDataFpe,expDataFpe);


