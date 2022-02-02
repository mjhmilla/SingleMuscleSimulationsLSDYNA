function success = writeImpedanceSimulationFiles(excitationSeries, ...
                            inputFunctions,impedanceFolder)
success = 0;

workingDirectory = pwd;
cd(impedanceFolder);
impedanceFolderContents=dir;



for indexExcitation=1:1:length(excitationSeries)
    for indexWaveform=1:1:length(inputFunctions.labels)
        waveformName = inputFunctions.labels{indexWaveform};
        idx = strfind(waveformName,'.');
        waveformName(1,idx)='p';
        idx = strfind(waveformName,' ');        
        waveformName(1,idx)='_';

        excitationStr = sprintf('%1.3f',excitationSeries(1,indexExcitation));
        idx = strfind(excitationStr,'.');
        excitationStr(1,idx)='p';
        
        seriesName = ['impedance_',excitationStr,'stim_',waveformName];
    
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
            cd(seriesName);
    
            %Write the k file for this simulation
            fid=fopen([seriesName,'.k'],'w');
            fprintf(fid,'*KEYWORD\n');
            fprintf(fid,'*PARAMETER\n');
            fprintf(fid,'$#    name       val\n');
            fprintf(fid,'R     stim  %1.6f\n',excitationSeries(1,indexExcitation));
            fprintf(fid,'$\n');
            fprintf(fid,'*INCLUDE_PATH_RELATIVE\n');
            fprintf(fid,'../\n');
            fprintf(fid,'$\n');
            fprintf(fid,'*INCLUDE\n');
            fprintf(fid,'../impedance.k\n');
            fprintf(fid,'$\n');
            fprintf(fid,'*INCLUDE\n');
            fprintf(fid,'perturbation_curve_lcid4.k\n');            
            fprintf(fid,'$\n');
            fprintf(fid,'*END\n');
            fclose(fid);

            fid=fopen('perturbation_curve_lcid4.k','w');
            fprintf(fid,'*DEFINE_CURVE\n');
            fprintf(fid,'$#    lcid      sidr       sfa       sfo      offa      offo    dattyp\n');
            fprintf(fid,'         4         0       1.0       1.0       0.0       0.0\n');
            fprintf(fid,'$#                a1                  o1\n');
            for indexTime=1:1:length(inputFunctions.time)
                if( inputFunctions.x(indexTime,indexWaveform) >= 0)
                    fprintf(fid,'           %1.7f           %1.7f\n',...
                        inputFunctions.time(indexTime,1),...
                        inputFunctions.x(indexTime,indexWaveform));
                    
                else
                    fprintf(fid,'           %1.7f          %1.7f\n',...
                        inputFunctions.time(indexTime,1),...
                        inputFunctions.x(indexTime,indexWaveform));
                end
            end
            fclose(fid);


            fid = fopen('getConfiguration.m','w');
            fprintf(fid,'function config = getConfiguration()\n');
            fprintf(fid,['config=struct(''amplitudeMM'',%e,''bandwidthHz'',',...
                '%e,...\n''excitation'',%e,''indexWaveform'',%i);\n'],...
                inputFunctions.amplitudeMM(1,indexWaveform),...
                inputFunctions.bandwidthHz(1,indexWaveform),...
                excitationSeries(1,indexExcitation),...
                indexWaveform);
            fclose(fid);
            
            cd(impedanceFolder);



        else
            disp(['Skipping ',seriesName,' directory exists']);
        end

        here=1;
    end
end

cd(workingDirectory);
success = 1;
