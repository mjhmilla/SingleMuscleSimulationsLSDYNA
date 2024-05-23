function success = writeSingleImpedanceSimulationFile(...
                            amplitudeMM, bandwidthHz, excitation,...
                            inputFunctions,...
                            lsdynaImpedanceFcnName,...
                            impedanceFolder)
success = 0;

workingDirectory = pwd;
cd(impedanceFolder);
impedanceFolderContents=dir;

epsSqrt=sqrt(eps);
idxWave = 0;
for i = 1:1:length(inputFunctions.amplitudeMM)
    errAmp = inputFunctions.amplitudeMM(1,i)-amplitudeMM;
    errBw  = inputFunctions.bandwidthHz(1,i)-bandwidthHz;
    if(abs(errAmp) < epsSqrt && abs(errBw) < epsSqrt )
        idxWave=i;
    end
end
assert(idxWave ~= 0, 'Error: could not find the desired waveform');


%Generate the folder name
waveformName = inputFunctions.labels{idxWave};
idx = strfind(waveformName,'.');
waveformName(1,idx)='p';
idx = strfind(waveformName,' ');        
waveformName(1,idx)='_';

excitationStr = sprintf('%1.3f',excitation);
idx = strfind(excitationStr,'.');
excitationStr(1,idx)='p';

seriesName = ['impedance_',excitationStr,'stim_',waveformName];

%Check if the folder exists, and if it doesn't, make it
flag_folderExists=0;
for indexItems=1:1:length(impedanceFolderContents)
    if(impedanceFolderContents(indexItems).isdir)
        if( contains(impedanceFolderContents(indexItems).name, seriesName)...
                && ( length(impedanceFolderContents(indexItems).name) ...
                   == length(seriesName)) ) 
            flag_folderExists=1;
        end
    end
end
if flag_folderExists==0
    mkdir(seriesName);
end

%Write the simulation files
cd(seriesName);

%Write the k file for this simulation
fid=fopen([seriesName,'.k'],'w');
fprintf(fid,'*KEYWORD\n');
fprintf(fid,'*PARAMETER\n');
fprintf(fid,'$#    name       val\n');
fprintf(fid,'R     stim  %1.6f\n',excitation);
fprintf(fid,'$\n');
fprintf(fid,'*INCLUDE_PATH_RELATIVE\n');
fprintf(fid,'../\n');
fprintf(fid,'$\n');
fprintf(fid,'*INCLUDE\n');
fprintf(fid,'../%s\n',lsdynaImpedanceFcnName);
fprintf(fid,'$\n');
fprintf(fid,'*INCLUDE\n');
fprintf(fid,'perturbation_curve_lcid4.k\n');            
fprintf(fid,'$\n');
fprintf(fid,'*END\n');
fclose(fid);

npts = length(inputFunctions.x(:,idxWave));
nptsStr = num2str(npts-1);
while length(nptsStr) < 10
    nptsStr=  [' ',nptsStr];
end


fid=fopen('perturbation_curve_lcid4.k','w');
fprintf(fid,'*DEFINE_CURVE\n');
fprintf(fid,'$#    lcid      sidr       sfa       sfo      offa      offo    dattyp     lcint\n');
fprintf(fid,'         4         0       1.0       1.0       0.0       0.0         1%s\n',nptsStr);
fprintf(fid,'$#                a1                  o1\n');
for indexTime=1:1:length(inputFunctions.time)
    if( inputFunctions.x(indexTime,idxWave) >= 0)
        fprintf(fid,'           %1.7f           %1.7f\n',...
            inputFunctions.time(indexTime,1),...
            inputFunctions.x(indexTime,idxWave));
        
    else
        fprintf(fid,'           %1.7f          %1.7f\n',...
            inputFunctions.time(indexTime,1),...
            inputFunctions.x(indexTime,idxWave));
    end
end
fclose(fid);


fid = fopen('getConfiguration.m','w');
fprintf(fid,'function config = getConfiguration()\n');
fprintf(fid,['config=struct(''amplitudeMM'',%e,''bandwidthHz'',',...
    '%e,...\n''excitation'',%e,''indexWaveform'',%i);\n'],...
    inputFunctions.amplitudeMM(1,idxWave),...
    inputFunctions.bandwidthHz(1,idxWave),...
    excitation,...
    idxWave);
fclose(fid);

cd(impedanceFolder);



cd(workingDirectory);
success = 1;
