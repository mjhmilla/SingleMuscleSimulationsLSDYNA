function success = writeForceVelocityLSDYNAFile(fname, excitation,...
                        length0,length1,lceOpt,time0,time1,...
                        flag_lengthsNormalized)

fid = fopen([fname],'w');


vce = (length1-length0)/(time1-time0);

lceN0=length0/lceOpt;
lceN1=length1/lceOpt;
vceN = ((length1-length0)/lceOpt)/(time1-time0);



fprintf(fid,'*KEYWORD\n');
fprintf(fid,'*PARAMETER\n');
fprintf(fid,'$#    name       val\n');

if(flag_lengthsNormalized==1)
    spStr0 = '  ';
    spStr1 = '  ';    
    if(lceN0 < 0)
        spStr0=' ';
    end
    if(lceN1 < 0)
        spStr1=' ';
    end

    fprintf(fid,'RpathLenN0%s%1.6f\n',spStr0,lceN0);
    fprintf(fid,'RpathLenN1%s%1.6f\n',spStr0lceN1);
    vceStr = sprintf('%1.6f',vceN);
else
    spStr0 = '  ';
    spStr1 = '  ';    
    if(length0 < 0)
        spStr0=' ';
    end
    if(length1 < 0)
        spStr1=' ';
    end
    
    fprintf(fid,'R     len0%s%1.6f\n',spStr0,length0);
    fprintf(fid,'R     len1%s%1.6f\n',spStr1,length1);
    vceStr = sprintf('%1.6f',vce);
end
spStr = ' ';
for j=length(vceStr):1:8
    spStr = [spStr,' '];
end
fprintf(fid,'R  pathVel%s%s\n',spStr,vceStr);
fprintf(fid,'RrampStart  %1.6f\n',time0);
fprintf(fid,'R  rampEnd  %1.6f\n',time1);
fprintf(fid,'R rampTime  %1.6f\n',(time1-time0));

fprintf(fid,'R   actVal  %1.6f\n',excitation);
fprintf(fid,'$\n');
fprintf(fid,'*INCLUDE_PATH_RELATIVE\n');
fprintf(fid,'../\n');
fprintf(fid,'$\n');
fprintf(fid,'*INCLUDE\n');
fprintf(fid,'../force_velocity.k\n');
fprintf(fid,'$\n');
fprintf(fid,'*END\n'); 
fclose(fid);

success = 1;