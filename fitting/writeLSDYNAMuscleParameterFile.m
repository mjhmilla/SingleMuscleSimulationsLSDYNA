function success = writeLSDYNAMuscleParameterFile(filePathAndName,...
                                                  parameters,...
                                                  extraLines)

fid = fopen(filePathAndName,'w');

fieldNames = fields(parameters);


fprintf(fid,'*KEYWORD\n');
fprintf(fid,'*PARAMETER\n');
fprintf(fid,'$#   prmr1      val1     prmr2      val2     prmr3      val3     prmr4      val4\n');
for i=1:1:length(fieldNames)
    if(contains(fieldNames{i},'extraLines')==0)
        fieldNameStr = fieldNames{i};
        if(length(fieldNameStr)<9)
            while(length(fieldNameStr)<9)
                fieldNameStr =[' ',fieldNameStr];
            end
        end
    
        n = 9;
        fieldValStr =sprintf(['%1.',num2str(n),'f'],...
                             parameters.(fieldNames{i}));
        
        if(length(fieldValStr)>9)
            while(length(fieldValStr)>9)
                n=n-1;
                fieldValStr = sprintf(['%1.',num2str(n),'f'],...
                                      parameters.(fieldNames{i}));
            end
        end
    
        lineEntry = 'R%s %s';
        if(i > 1)
            lineEntry = '\nR%s %s';
        end

        fprintf(fid,lineEntry,fieldNameStr,fieldValStr);   
    end
end

if(isempty(extraLines)==0)
    for i=1:1:length(extraLines)
        if(length(extraLines{i})>0)
            fprintf(fid,'\n%s',extraLines{i});
        end
    end
end

fprintf(fid,'\n*END\n');
fclose(fid);

success=1;