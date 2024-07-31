%%
% SPDX-FileCopyrightText: 2024 Matthew Millard <millard.matthew@gmail.com>
%
% SPDX-License-Identifier: MIT
%%
function val = getParameterFieldValue(fileName,fieldName)

val=NaN;

fid=fopen(fileName);

line            = fgetl(fid);
lineFound       = 0;
inParameterCard = 0;

while ~feof(fid) && lineFound == 0 
    
    if(contains(line,'*PARAMETER')==1)
        inParameterCard=1;
    elseif(strcmp(line(1,1),'*') && contains(line,'*PARAMETER')==0 && inParameterCard==1)
        inParameterCard=0;
    elseif(contains(line,fieldName) == 1 && inParameterCard==1)
        lineFound=1;        
    end
    if(lineFound==0)
        line=fgetl(fid);
    end
end

indexFieldStart = strfind(line,fieldName) + length(fieldName);
val = str2double(line(indexFieldStart:end));

fclose(fid);