function value = getParameterValueFromD3HSPFile(fileName, parameterName)

value=NaN;

fid = fopen(fileName);
line=fgetl(fid);
[msg,err]=ferror(fid);

flag_found=1;
while contains(line,parameterName)==0
   line=fgetl(fid); 
   if ~ischar(line) 
       flag_found=0;
       break;
   end
end
fclose(fid);

if(flag_found==1)    
    tag  = parameterName;
    idx0 = strfind(line,tag)+length(tag);
    idx1=idx0+1;
    numberText='';
    while idx1 < length(line)
       if( line(idx1-1) ~= ' ' && line(idx1) == ' ')
           numberText=line(idx0:idx1);
           break;
       end
       idx1=idx1+1;
    end
    assert(~isempty(numberText));
    value = str2double(numberText);
end