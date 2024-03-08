function success = writeForceVelocityLSDYNAFile(fname, excitation,...
                        length0,length1,lceOpt,time0,time1)

fid = fopen([fname],'w');

lceN0=length0/lceOpt;
lceN1=length1/lceOpt;
vceN = ((length1-length0)/lceOpt)/(time1-time0);



fprintf(fid,'*KEYWORD\n');
fprintf(fid,'*PARAMETER\n');
fprintf(fid,'$#    name       val\n');
fprintf(fid,'RpathLenN0  %1.6f\n',lceN0);
fprintf(fid,'RpathLenN1  %1.6f\n',lceN1);
vceStr = sprintf('%1.6f',vceN);
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