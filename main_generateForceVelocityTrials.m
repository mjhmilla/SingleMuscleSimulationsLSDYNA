clc;
close all;
clear all;

% umat41: Kleinbach et al.'s EHTMM
% umat43: VEXAT
% viva  : The VIVA+ use of MAT_MUSCLE
% thums : The Thums use of MAT_MUSCLE

rootDir = pwd;

modelName       = 'viva';

%Fixed
releaseName     ='MPP_R931';
simulationName  = 'active_passive_force_length';

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

lceNMin     = 0.4;
lceNMax     = 1.8;
lceNDelta   = 0.1;

lceNV = [lceNMin:lceNDelta:lceNMax];

counter=0;

cd(releaseName);
cd(modelName);
cd(simulationName);

for i=1:1:length(lceNV)

    lceN = lceNV(1,i);

    simNumber = num2str(counter);
    if(counter<10)
        simNumber = ['0',simNumber];
    end

    simName = ['active_force_length_',simNumber];
    mkdir(simName);
    cd(simName);
    fid=fopen([simName,'.k'],'w');

    fprintf(fid,'*KEYWORD\n');
    fprintf(fid,'*PARAMETER\n');
    fprintf(fid,'$#    name       val\n');
    fprintf(fid,'RpathLenN0     %1.3f\n',lceN);
    fprintf(fid,'RpathLenN1     %1.3f\n',lceN);
    fprintf(fid,'R   actVal     %1.3f\n',exVal);
    fprintf(fid,'$\n');
    fprintf(fid,'*INCLUDE_PATH_RELATIVE\n');
    fprintf(fid,'../\n');
    fprintf(fid,'$\n');
    fprintf(fid,'*INCLUDE\n');
    fprintf(fid,'../active_passive_force_length.k\n');
    fprintf(fid,'$\n');
    fprintf(fid,'*END\n'); 
    fclose(fid);
    cd ..
    counter=counter+1;


end

cd(rootDir);

disp('Generating: sub-max isometric activations');

exVal = exSubMax;

lceNMin     = 0.9;
lceNMax     = 1.3;
lceNDelta   = 0.1;

lceNVSub = [lceNMin:lceNDelta:lceNMax];

cd(releaseName);
cd(modelName);
cd(simulationName);

for i=1:1:length(lceNVSub)

    lceN = lceNVSub(1,i);

    simNumber = num2str(counter);
    if(counter<10)
        simNumber = ['0',simNumber];
    end

    simName = ['active_force_length_',simNumber];
    mkdir(simName);

    cd(simName);
    fid=fopen([simName,'.k'],'w');
    fprintf(fid,'*KEYWORD\n');
    fprintf(fid,'*PARAMETER\n');
    fprintf(fid,'$#    name       val\n');
    fprintf(fid,'RpathLenN0     %1.3f\n',lceN);
    fprintf(fid,'RpathLenN1     %1.3f\n',lceN);
    fprintf(fid,'R   actVal     %1.3f\n',exVal);
    fprintf(fid,'$\n');
    fprintf(fid,'*INCLUDE_PATH_RELATIVE\n');
    fprintf(fid,'../\n');
    fprintf(fid,'$\n');
    fprintf(fid,'*INCLUDE\n');
    fprintf(fid,'../active_passive_force_length.k\n');
    fprintf(fid,'$\n');
    fprintf(fid,'*END\n'); 
    fclose(fid);
    cd ..

    counter=counter+1;
end

cd(rootDir);

disp('Generating: passive_force_length');

cd(releaseName);
cd(modelName);
cd(simulationName);


simName = ['passive_force_length'];
mkdir(simName);

cd(simName);
fid=fopen([simName,'.k'],'w');
fprintf(fid,'*KEYWORD\n');
fprintf(fid,'*PARAMETER\n');
fprintf(fid,'$#    name       val\n');
fprintf(fid,'RpathLenN0     %1.3f\n',0.4);
fprintf(fid,'RpathLenN1     %1.3f\n',1.8);
fprintf(fid,'R   actVal     %1.3f\n',0);
fprintf(fid,'$\n');
fprintf(fid,'*INCLUDE_PATH_RELATIVE\n');
fprintf(fid,'../\n');
fprintf(fid,'$\n');
fprintf(fid,'*INCLUDE\n');
fprintf(fid,'../active_passive_force_length.k\n');
fprintf(fid,'$\n');
fprintf(fid,'*END\n'); 
fclose(fid);
cd ..

cd(rootDir);
