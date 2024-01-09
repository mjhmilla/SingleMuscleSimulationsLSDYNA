clc;
close all;
clear all;

disp('Generating: max isometric activations');

aMax = 1.0;

lceNMin = 0.4;
lceNMax = 1.8;
lceNDelta = 0.1;

lceNV = [lceNMin:lceNDelta:lceNMax];
counter=0;
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
    fprintf(fid,'R   actVal     %1.3f\n',aMax);
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

disp('Generating: sub-max isometric activations');

aMax = 0.7;

lceNMin = 0.9;
lceNMax = 1.3;
lceNDelta = 0.1;

lceNVSub = [lceNMin:lceNDelta:lceNMax];

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
    fprintf(fid,'R   actVal     %1.3f\n',aMax);
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


disp('Generating: passive_force_length');
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


