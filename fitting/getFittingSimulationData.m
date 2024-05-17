function uniformModelData = getFittingSimulationData(matParams,...
                                fittingInfo,rootFolderPath)

cd(fittingInfo.simulationFolder);


%%
%Load the musout and binout files and convert it to uniform
%%
musout =[]; 
musoutCount = 0;
musoutFileList = [];

binout = [];
binoutCount = 0;
binoutFileList = {};

fileList = dir;

for indexFile =1:1:length(fileList)
  if(contains(fileList(indexFile).name,'musout'))
    musoutCount=musoutCount+1;
    if musoutCount == 1
      musoutFileList = {fileList(indexFile).name};
    else
      musoutFileList = {musoutFileList{:};fileList(indexFile).name};
    end    
  end
  if(contains(fileList(indexFile).name,'binout'))
    binoutCount=binoutCount+1;
    if binoutCount == 1
      binoutFileList = {fileList(indexFile).name};
    else
      binoutFileList = {binoutFileList{:};fileList(indexFile).name};
    end    
  end
end

if( contains(fittingInfo.model,'umat') )              
  assert(musoutCount == 1,'Error: could not find musout files');
end

switch fittingInfo.model
    case 'umat41'
        [musout,success] = ...
            readUmat41MusoutData(musoutFileList{1});  
    case 'umat43'
        [musout,success] = ...
            readUmat43MusoutData(musoutFileList{1}); 
    case 'mat156'
        disp('  mat156: does not have any musout files');
    case 'viva'
        disp('  viva: does not have any musout files');
    otherwise assert(0)
end

[binout,status] = binoutreader('dynaOutputFile',binoutFileList{1},...
                               'ignoreUnknownDataError',true);

d3hspFileName = 'd3hsp';

if(contains(fittingInfo.model,'umat43')==1)
    lceOpt=matParams.lceOpt;
    fceOpt=matParams.fceOpt;
else
    lceOpt=matParams.lceOptAT;
    fceOpt=matParams.fceOptAT;
end
ltSlk=matParams.ltSlk;
penOpt=matParams.penOpt;

uniformModelData = createUniformMuscleModelData(...
                   fittingInfo.model,...
                   musout, binout, d3hspFileName, ...
                   lceOpt,fceOpt,ltSlk,penOpt,...
                   fittingInfo.type);


cd(rootFolderPath);