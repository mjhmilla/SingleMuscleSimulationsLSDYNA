%%
% SPDX-FileCopyrightText: 2024 Matthew Millard <millard.matthew@gmail.com>
%
% SPDX-License-Identifier: MIT
%%
function value = getCurveValueFromLSDYNAInputFile(fileName, curveId)

value=NaN;

fid = fopen(fileName);
line=fgetl(fid);
[msg,err]=ferror(fid);

curveName = '*DEFINE_CURVE';
lcidTag = 'lcid';

flag_found=0;
while ischar(line) && flag_found == 0
   line=fgetl(fid); 
   if ischar(line) 
        if(contains(line,curveName)==1)
            line=fgetl(fid);
            if(contains(line,lcidTag))
                idx = strfind(line,lcidTag);
                idx =min(idx)+length(lcidTag)-1;
                idx0 = idx-9;
                idx1 = idx;
                line=fgetl(fid);
                fieldStr= line(idx0:idx1);
                fieldValue = str2double(strtrim(fieldStr));
                if(abs(fieldValue - curveId) < 1e-6)
                    flag_found=1;
                end
            end
        end
       
   end
end


if(flag_found==1)    
    line=fgetl(fid);
    idxA1 = strfind(line,'a1');
    idxA1 = idxA1 + 2 - 1;
    idxA0 = 1;

    idxB1 = strfind(line,'o1');
    idxB1 = idxB1 + 2 - 1;
    idxB0 = idxA1+1;
        
    value = [];

    while length(line) > 2
        line = fgetl(fid);

       if( length(line) > 2)
           a1 = str2double(strtrim(line(idxA0:idxA1)));
           o1 = str2double(strtrim(line(idxB0:idxB1)));
           value = [value; a1, o1];
       end

    end
end

fclose(fid);