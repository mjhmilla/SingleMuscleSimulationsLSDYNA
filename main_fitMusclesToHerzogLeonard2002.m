clc;
close all;
clear all;

flag_fitPassiveForceLength   =1;
scaleExpFpeData= 1;%6.52/8.1573;

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


