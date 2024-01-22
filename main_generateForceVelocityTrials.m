clc;
close all;
clear all;

% umat41: Kleinbach et al.'s EHTMM
% umat43: VEXAT
% viva  : The VIVA+ use of MAT_MUSCLE
% thums : The Thums use of MAT_MUSCLE

rootDir = pwd;

modelName       = 'umat41';

%Fixed
releaseName     ='MPP_R931';
simulationName  = 'force_velocity';

exMax       = 1.0;
exSubMax    = 0.7;

switch modelName
    case 'umat41'
        exSubMax = 0.2;
    case 'umat43'
        exSubMax = 0.7;
    case 'viva'
        exSubMax = 0.7;
    case 'thums'
        exSubMax = 0.7;
    otherwise
        assert(0,'Error: invalid modelName selection');
end


disp('Generating: max. isometric activations');

exVal = exMax;
 
% This is the set of velocities that are the union of the velocities
% evaluated in Herzog & Leonard (1997) and Siebert et al. (2015)
%
% Herzog and Leonard shortened a cat soleus (lce opt approx. 42.9 mm) 
% by 4mm, and so, I'm going to shorten the CE by 4/42.9 = 0.09324 lopt
%
% Herzog W, Leonard TR. Depression of cat soleus forces following isokinetic 
% shortening. Journal of biomechanics. 1997 Sep 1;30(9):865-72.
%
% Siebert T, Leichsenring K, Rode C, Wick C, Stutzig N, Schubert H, 
% Blickhan R, Böl M. Three-dimensional muscle architecture and 
% comprehensive dynamic properties of rabbit gastrocnemius, plantaris and 
% soleus: input for simulation studies. PLoS one. 2015 Jun 26;10(6):e0130985.
%           00         01     02     03   04   05   06  
%           07         08     09     10   11   12   13  
vceNVPos = [0.0583, 0.117, 0.233, 0.350, 0.7, 1.4, 2.8 ];

vceNV = [-1.*vceNVPos,vceNVPos];

dlopt = 0.09324;

counter=0;

cd(releaseName);
cd(modelName);
cd(simulationName);

for i=1:1:length(vceNV)

    vceN = vceNV(1,i);

    simNumber = num2str(counter);
    if(counter<10)
        simNumber = ['0',simNumber];
    end

    simName = ['force_velocity_',simNumber];
    if(exist(simName)~=7)
        mkdir(simName);
    end
    cd(simName);
    fid=fopen([simName,'.k'],'w');

    if(vceN > 0)
        lceN0 = 1 - dlopt;
        lceN1 = 1;
    else
        lceN0 = 1 + dlopt;
        lceN1 = 1;
    end

    timeRamp = abs((lceN0-lceN1)/vceN)*1000;

    fprintf(fid,'*KEYWORD\n');
    fprintf(fid,'*PARAMETER\n');
    fprintf(fid,'$#    name       val\n');
    fprintf(fid,'RpathLenN0    %1.4f\n',lceN0);
    fprintf(fid,'RpathLenN1    %1.4f\n',lceN1);
    vceStr = sprintf('%1.4f',vceN);
    spStr = ' ';
    for j=length(vceStr):1:8
        spStr = [spStr,' '];
    end
    fprintf(fid,'R  pathVel%s%1.4f\n',spStr,vceN);
    fprintf(fid,'R rampTime    %1.1f\n',timeRamp);
    fprintf(fid,'R   actVal    %1.4f\n',exVal);
    fprintf(fid,'$\n');
    fprintf(fid,'*INCLUDE_PATH_RELATIVE\n');
    fprintf(fid,'../\n');
    fprintf(fid,'$\n');
    fprintf(fid,'*INCLUDE\n');
    fprintf(fid,'../force_velocity.k\n');
    fprintf(fid,'$\n');
    fprintf(fid,'*END\n'); 
    fclose(fid);
    cd ..
    counter=counter+1;


end

cd(rootDir);

disp('Generating: sub-max force-velocity trials');

exVal = exSubMax;

%vceNVPos = [0.350, 0.7, 1.4];
%vceNV = [-1.*vceNVPos,vceNVPos];

vceNVPos = [0.0583, 0.117, 0.233, 0.350, 0.7, 1.4, 2.8];
vceNV = [-1.*vceNVPos,vceNVPos];

cd(releaseName);
cd(modelName);
cd(simulationName);

for i=1:1:length(vceNV)

    vceN = vceNV(1,i);

    simNumber = num2str(counter);
    if(counter<10)
        simNumber = ['0',simNumber];
    end

    simName = ['force_velocity_',simNumber];
    if(exist(simName)~=7)
        mkdir(simName);
    end
    cd(simName);
    fid=fopen([simName,'.k'],'w');

    if(vceN > 0)
        lceN0 = 1 - dlopt;
        lceN1 = 1;
    else
        lceN0 = 1 + dlopt;
        lceN1 = 1;
    end

    timeRamp = abs((lceN0-lceN1)/vceN)*1000;

    fprintf(fid,'*KEYWORD\n');
    fprintf(fid,'*PARAMETER\n');
    fprintf(fid,'$#    name       val\n');
    fprintf(fid,'RpathLenN0    %1.4f\n',lceN0);
    fprintf(fid,'RpathLenN1    %1.4f\n',lceN1);
    vceStr = sprintf('%1.4f',vceN);
    spStr = ' ';
    for j=length(vceStr):1:8
        spStr = [spStr,' '];
    end
    fprintf(fid,'R  pathVel%s%1.4f\n',spStr,vceN);
    fprintf(fid,'R rampTime    %1.1f\n',timeRamp);
    fprintf(fid,'R   actVal    %1.4f\n',exVal);
    fprintf(fid,'$\n');
    fprintf(fid,'*INCLUDE_PATH_RELATIVE\n');
    fprintf(fid,'../\n');
    fprintf(fid,'$\n');
    fprintf(fid,'*INCLUDE\n');
    fprintf(fid,'../force_velocity.k\n');
    fprintf(fid,'$\n');
    fprintf(fid,'*END\n'); 
    fclose(fid);
    cd ..
    counter=counter+1;


end

cd(rootDir);

disp('Generating: isometric max');

cd(releaseName);
cd(modelName);
cd(simulationName);


simName = 'isometric_max';
if(exist(simName)~=7)
    mkdir(simName);
end

cd(simName);
fid=fopen([simName,'.k'],'w');

timeRamp = 1;

lceNIso = lceN1;
vceNIso = 0;

fprintf(fid,'*KEYWORD\n');
fprintf(fid,'*PARAMETER\n');
fprintf(fid,'$#    name       val\n');
fprintf(fid,'RpathLenN0    %1.4f\n',lceNIso);
fprintf(fid,'RpathLenN1    %1.4f\n',lceNIso);
vceStr = sprintf('%1.4f',vceN);
spStr = ' ';
for j=length(vceStr):1:8
    spStr = [spStr,' '];
end
fprintf(fid,'R  pathVel%s%1.4f\n',spStr,vceN);
fprintf(fid,'R rampTime    %1.1f\n',timeRamp);
fprintf(fid,'R   actVal    %1.4f\n',exMax);
fprintf(fid,'$\n');
fprintf(fid,'*INCLUDE_PATH_RELATIVE\n');
fprintf(fid,'../\n');
fprintf(fid,'$\n');
fprintf(fid,'*INCLUDE\n');
fprintf(fid,'../force_velocity.k\n');
fprintf(fid,'$\n');
fprintf(fid,'*END\n'); 
fclose(fid);
cd ..

cd(rootDir);

disp('Generating: isometric sub-max');

cd(releaseName);
cd(modelName);
cd(simulationName);


simName = 'isometric_sub_max';
if(exist(simName)~=7)
    mkdir(simName);
end

cd(simName);
fid=fopen([simName,'.k'],'w');

timeRamp = 1;

lceNIso = lceN1;
vceNIso = 0;

fprintf(fid,'*KEYWORD\n');
fprintf(fid,'*PARAMETER\n');
fprintf(fid,'$#    name       val\n');
fprintf(fid,'RpathLenN0    %1.4f\n',lceNIso);
fprintf(fid,'RpathLenN1    %1.4f\n',lceNIso);
vceStr = sprintf('%1.4f',vceN);
spStr = ' ';
for j=length(vceStr):1:8
    spStr = [spStr,' '];
end
fprintf(fid,'R  pathVel%s%1.4f\n',spStr,vceN);
fprintf(fid,'R rampTime    %1.1f\n',timeRamp);
fprintf(fid,'R   actVal    %1.4f\n',exSubMax);
fprintf(fid,'$\n');
fprintf(fid,'*INCLUDE_PATH_RELATIVE\n');
fprintf(fid,'../\n');
fprintf(fid,'$\n');
fprintf(fid,'*INCLUDE\n');
fprintf(fid,'../force_velocity.k\n');
fprintf(fid,'$\n');
fprintf(fid,'*END\n'); 
fclose(fid);
cd ..

cd(rootDir);
