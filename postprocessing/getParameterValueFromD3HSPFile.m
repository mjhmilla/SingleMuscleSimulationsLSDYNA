function value = getParameterValueFromD3HSPFile(fileName, parameterName)

fid = fopen(fileName);
line=fgetl(fid);
[msg,err]=ferror(fid);

while contains(line,parameterName)==0 && err~=-1
   line=fgetl(fid); 
   [msg,err]=ferror(fid);
end
fclose(fid);
assert(contains(line,parameterName));
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
assert(length(numberText) > 0);
value = str2double(numberText);
