function [musout,success] = readUmat43MusoutData(fileName)

success = 0;

musout  = struct('data',[],'columnNames','','PartID','',...
                    'indexTime'            ,0,...
                    'indexHsvLp'           ,0,...  
                    'indexHSvVp'           ,0,...  
                    'indexHsvExcitation'   ,0,...  
                    'indexHsvAct'          ,0,...  
                    'indexHsvLceATN'       ,0,...  
                    'indexHsvL1HN'         ,0,...  
                    'indexHsvLsHN'         ,0,...  
                    'indexHsvVsHNN'        ,0,...  
                    'indexHsvActDot'       ,0,...  
                    'indexHsvLceATNDot'    ,0,...  
                    'indexHsvL1HNDot'      ,0,...  
                    'indexHsvLsHNDot'      ,0,...  
                    'indexHsvVsHNNDot'     ,0,...  
                    'indexHsvLceN'         ,0,...  
                    'indexHsvVceNN'        ,0,...  
                    'indexHsvFceN'         ,0,...  
                    'indexHsvAlpha'        ,0,...  
                    'indexHsvAlphaDot'     ,0,...  
                    'indexHsvFceATN'       ,0,...  
                    'indexHsvLtN'          ,0,...  
                    'indexHsvVtN'          ,0,...  
                    'indexHsvFtN'          ,0,...  
                    'indexHsvLaN'          ,0,...  
                    'indexHsvFalN'         ,0,...  
                    'indexHsvVaNN'         ,0,...  
                    'indexHsvFvN'          ,0,...  
                    'indexHsvLceHN'        ,0,...  
                    'indexHsvFecmHN'       ,0,...  
                    'indexHsvF1HN'         ,0,...  
                    'indexHsvL2HN'         ,0,...  
                    'indexHsvF2HN'         ,0,...  
                    'indexHsvLxHN'         ,0,...  
                    'indexHsvVxHN'         ,0,...  
                    'indexHsvFxHN'         ,0,...  
                    'indexHsvFtfcnN'       ,0,...  
                    'indexHsvFtBetaN'      ,0,...  
                    'indexHsvDvsHNHill'    ,0,...  
                    'indexHsvDvsHNDamping' ,0,... 
                    'indexHsvDvsHNTracking',0);



fid = fopen(fileName);

%Get the part id
line=fgetl(fid);
tag = '(PartID):';
idx = strfind(line,tag)+length(tag);
musout.PartID = cell2mat(textscan(line(idx:end),'%f'));

%Count the number of column headers
line=fgetl(fid);
numberOfColumns=0;
headerFormat = '';
dataFormat = '';
for i=2:1:length(line)
  if(strcmp(line(i-1),' ')==1 && strcmp(line(i),' ')==0)
    numberOfColumns = numberOfColumns+1;
    headerFormat    = [headerFormat,'%s'];
    dataFormat      = [dataFormat,'%f'];
  end
end

%Get the header data
musout.columnNames = textscan(line,headerFormat);

%Get the numeric data
%musout.data = cell2mat(textscan(fid,dataFormat,'collectoutput',1));
while ~feof(fid)
    cellData = textscan(fid, dataFormat, 'CollectOutput',true);
    matrixData = cell2mat(cellData);
    if isempty(matrixData)                                      
        break
    end
    musout.data = [musout.data; matrixData]; 
    fseek(fid, 0, 0);
end

fclose(fid);

musout.indexHsvTime          = getColumnIndex('time',       musout.columnNames);  

musout.indexHsvLp            = getColumnIndex('lp',         musout.columnNames);  
musout.indexHSvVp            = getColumnIndex('vp',         musout.columnNames);  
musout.indexHsvExcitation    = getColumnIndex('e',          musout.columnNames);  

musout.indexHsvAct           = getColumnIndex('a',          musout.columnNames);  
musout.indexHsvLceATN        = getColumnIndex('lceATN',     musout.columnNames);  
musout.indexHsvL1HN          = getColumnIndex('l1HN',       musout.columnNames);  
musout.indexHsvLsHN          = getColumnIndex('lsHN',       musout.columnNames);  
musout.indexHsvVsHNN         = getColumnIndex('vsHNN',      musout.columnNames);  

musout.indexHsvActDot        = getColumnIndex('aDot',       musout.columnNames);  
musout.indexHsvLceATNDot     = getColumnIndex('vceATN',     musout.columnNames);  
musout.indexHsvL1HNDot       = getColumnIndex('v1HN',       musout.columnNames);  
musout.indexHsvLsHNDot       = getColumnIndex('vsHN',       musout.columnNames);  
musout.indexHsvVsHNNDot      = getColumnIndex('vsHNNDot',   musout.columnNames);  

musout.indexHsvLceN          = getColumnIndex('lceN',       musout.columnNames);  
musout.indexHsvVceNN         = getColumnIndex('vceNN',      musout.columnNames);  
musout.indexHsvFceN          = getColumnIndex('fceN',       musout.columnNames);  
musout.indexHsvAlpha         = getColumnIndex('alpha',      musout.columnNames);  
musout.indexHsvAlphaDot      = getColumnIndex('dalpha',     musout.columnNames);  

musout.indexHsvFceATN        = getColumnIndex('fceATN',     musout.columnNames);  
musout.indexHsvLtN           = getColumnIndex('ltN',        musout.columnNames);  
musout.indexHsvVtN           = getColumnIndex('vtN',        musout.columnNames);  
musout.indexHsvFtN           = getColumnIndex('ftN',        musout.columnNames);  
musout.indexHsvLaN           = getColumnIndex('laN',        musout.columnNames);  
musout.indexHsvFalN          = getColumnIndex('falN',       musout.columnNames);  
musout.indexHsvVaNN          = getColumnIndex('vaNN',       musout.columnNames);  
musout.indexHsvFvN           = getColumnIndex('fvN',        musout.columnNames);
  
musout.indexHsvLceHN         = getColumnIndex('lceHN',      musout.columnNames);  
musout.indexHsvFecmHN        = getColumnIndex('fecmHN',     musout.columnNames);  
musout.indexHsvF1HN          = getColumnIndex('f1HN',       musout.columnNames);  
musout.indexHsvL2HN          = getColumnIndex('l2HN',       musout.columnNames);  
musout.indexHsvF2HN          = getColumnIndex('f2HN',       musout.columnNames);  
musout.indexHsvLxHN          = getColumnIndex('lxHN',       musout.columnNames);  
musout.indexHsvVxHN          = getColumnIndex('vxHN',       musout.columnNames);  
musout.indexHsvFxHN          = getColumnIndex('fxHN',       musout.columnNames);  
musout.indexHsvFtfcnN        = getColumnIndex('ftFcnN',     musout.columnNames);  
musout.indexHsvFtBetaN       = getColumnIndex('ftBetaN',    musout.columnNames);  
musout.indexHsvDvsHNHill     = getColumnIndex('dvsHNHill',  musout.columnNames);  
musout.indexHsvDvsHNDamping  = getColumnIndex('dvsHNDamp',  musout.columnNames); 
musout.indexHsvDvsHNTracking = getColumnIndex('dvsHNTrak',  musout.columnNames);


success   = 1;