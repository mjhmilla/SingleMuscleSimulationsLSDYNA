function val = getLsdynaCardFieldValue(fileName, fieldName)

val = NaN;

fid=fopen(fileName);

line = fgetl(fid);
lineFound = 0;

indexFieldStart = 0;
indexFieldEnd = 0;
while ~feof(fid) && lineFound == 0 
    indexFieldStart = strfind(line,fieldName);
    if(isempty(indexFieldStart) == 0)
        lineFound=1;
        indexFieldEnd = indexFieldStart + length(fieldName)-1;

        if(indexFieldStart > 1)
            characterFound = 0;

            while indexFieldStart > 1 && characterFound == 0
                if(  strcmp(line(  indexFieldStart),' ')==0 ...
                  && strcmp(line(indexFieldStart+1),' ')==1)
                    indexFieldStart = indexFieldStart+1;
                    characterFound=1;
                else
                    indexFieldStart = indexFieldStart-1;
                end
            end
        end
    else
        line=fgetl(fid);
    end
end

line=fgetl(fid);
val = str2double(line(indexFieldStart:indexFieldEnd));

fclose(fid);