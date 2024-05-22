function success = writeMAT156ModelFileV2(...
                        modelFolder,...
                        expAbbrv,...
                        mat156,...
                        umat43,...
                        vexatRTCurves,...
                        flag_plotMAT156Curves)

success = 0;

%%
% Generate the values along the tendon
%%

fceOpt      = umat43.fceOpt;
lceOpt      = umat43.lceOpt;
alphaOpt    = umat43.penOpt;
vceMax      = umat43.vceMax;
vceMaxAT    = mat156.vceMax;

lceOptAT    = lceOpt*cos(alphaOpt);
fceOptAT    = fceOpt*cos(alphaOpt);


assert(abs(lceOptAT-mat156.lceOptAT)                < 1e-6);
assert(abs(fceOpt*cos(alphaOpt)-mat156.fceOptAT)    < 1e-6);

alphaDotOpt = -(vceMax/lceOpt)*tan(alphaOpt);
vceMaxAT    = vceMax*cos(alphaOpt)-lceOpt*sin(alphaOpt)*alphaDotOpt;

falValues.xAT   = zeros(size(vexatRTCurves.fl.lceNAT));
falValues.yAT   = zeros(size(vexatRTCurves.fl.lceNAT));

fpeValues.xAT   = zeros(size(vexatRTCurves.fpe.lceNAT));
fpeValues.yAT   = zeros(size(vexatRTCurves.fpe.lceNAT));

fvValues.xAT    = zeros(size(vexatRTCurves.fv.vceNNAT));
fvValues.yAT    = zeros(size(vexatRTCurves.fv.fceNAT));


for i=1:1:length(falValues.xAT)
    falValues.xAT(i,1) = vexatRTCurves.fl.lceNAT(i,1)* (umat43.lceOpt / mat156.lceOptAT);
    falValues.yAT(i,1) = vexatRTCurves.fl.fceNAT(i,1)* (umat43.fceOpt / mat156.fceOptAT);
end

for i=1:1:length(fpeValues.xAT)
    fpeValues.xAT(i,1) = vexatRTCurves.fpe.lceNAT(i,1)* (umat43.lceOpt / mat156.lceOptAT);
    fpeValues.yAT(i,1) = vexatRTCurves.fpe.fceNAT(i,1)* (umat43.fceOpt / mat156.fceOptAT);
end

for i=1:1:length(fvValues.xAT)
    fvValues.xAT(i,1) = vexatRTCurves.fv.vceNNAT(i,1);
    fvValues.yAT(i,1) = vexatRTCurves.fv.fceNAT(i,1)*(umat43.fceOpt / mat156.fceOptAT);
end



fmFiles = [];

mat156PrePostFolder = fullfile(modelFolder,'mat156');

switch expAbbrv
    case 'HL1997'
        fmFiles={['catsoleus',expAbbrv,'Mat156']};
    case 'HL2002'
        fmFile1 = ['catsoleus',expAbbrv,'Mat156'];
        fmFile2 = ['catsoleusKBR1994Mat156'];
        fmFiles = {fmFile1,fmFile2};
end

% falFile = fullfile(modelFolder,...
%             ['mat156_',expAbbrv,'_activeForceLengthCurve.f']);
% fpeFile = fullfile(modelFolder,...
%             ['mat156_',expAbbrv,'_passiveForceLengthCurve.f']);
% fvFile  = fullfile(modelFolder,...
%             ['mat156_',expAbbrv,'_forceVelocityCurve.f']);

for idx=1:1:length(fmFiles)
    preFile  = fullfile(mat156PrePostFolder,[fmFiles{idx},'_pre.k']);
    postFile = fullfile(mat156PrePostFolder,[fmFiles{idx},'_post.k']);
    fileName = fullfile(modelFolder,[fmFiles{idx},'.k']);

    success = copyfile(preFile,fileName);
    assert(success==1,['Error: failed to copy ',preFile]);

    success = writeFortranVector(...
                falValues.xAT, falValues.yAT, 10, fileName,'a');
    assert(success==1,['Error: failed to write fal to',preFile]);

    success = writeFortranVector(...
                fpeValues.xAT, fpeValues.yAT, 11, fileName,'a');
    assert(success==1,['Error: failed to write fpe to',preFile]);
    
    success = writeFortranVector(...
                fvValues.xAT,  fvValues.yAT, 12, fileName,'a');
    assert(success==1,['Error: failed to write fv to',preFile]);

    strPost = fileread(postFile);
    fid = fopen(fileName,'a');
    fprintf(fid,'%s',strPost);
    fclose(fid);
    
end


if(flag_plotMAT156Curves==1)
    fig=figure;
    subplot(1,3,1);        
        plot(falValues.xAT,falValues.yAT,'-','Color',[1,0,0]);
        hold on;
        
        xlabel('$$\tilde{\ell}^{M}$$');
        ylabel('$$\tilde{f}^{L}$$');
        box off;

    subplot(1,3,2);        
        plot(fpeValues.xAT,fpeValues.yAT,'-','Color',[0,0,1]);
        hold on;


        xlabel('$$\tilde{\ell}^{M}$$');
        ylabel('$$\tilde{f}^{PE}$$');
        box off;
        
    subplot(1,3,3);        
        plot(fvValues.xAT,fvValues.yAT,'--','Color',[1,0,0]);
        hold on;
        
        xlabel('$$\tilde{v}^{M}$$');
        ylabel('$$\tilde{f}^{V}$$');
        box off;
end