function success = writeMAT156ModelFile(...
                        modelFolder,...
                        expAbbrv,...
                        mat156,...
                        umat43,...
                        umat43QuadraticCurves,...
                        flag_addTendonLengthChangeToMat156,...
                        flag_plotMAT156Curves)

success = 0;

npts  = 100;
domain= [] ; %Take the default extended range

falValues = calcQuadraticBezierYFcnXCurveSampleVector(...
                  umat43QuadraticCurves.activeForceLengthCurve,...
                  npts, domain);

%This approximates the passive curve created by the ECM and titin within 
%a 2% error or around 0.4N
fpeValues = calcQuadraticBezierYFcnXCurveSampleVector(...
                  umat43QuadraticCurves.fiberForceLengthCurve,...
                  npts, domain);

fpeFields=fields(fpeValues);

fpeValues.x = fpeValues.x + umat43.shiftPEE;
for i=1:1:length(fpeFields)
    if(contains(fpeFields{i},'y'))
        fpeValues.(fpeFields{i})=fpeValues.(fpeFields{i}).*umat43.scalePEE;
    end
end

fvValues = calcQuadraticBezierYFcnXCurveSampleVector(...
              umat43QuadraticCurves.fiberForceVelocityCurve,...
              npts, [-1.1,1.1]);

%%
% Generate the values along the tendon
%%

fceOpt      = umat43.fceOpt;
lceOpt      = umat43.lceOpt;
alphaOpt    = umat43.penOpt;
vceMax      = umat43.vceMax;
vceMaxAT    = mat156.vceMax;

lceOptAT    = lceOpt*cos(alphaOpt);

assert(abs(lceOptAT-mat156.lceOptAT)                < 1e-6);
assert(abs(fceOpt*cos(alphaOpt)-mat156.fceOptAT)    < 1e-6);



alphaDotOpt = -(vceMax/lceOpt)*tan(alphaOpt);
vceMaxAT    = vceMax*cos(alphaOpt)-lceOpt*sin(alphaOpt)*alphaDotOpt;
fceOptAT    = fceOpt*cos(alphaOpt);

falValues.xAT   = zeros(size(falValues.x));
falValues.yAT   = zeros(size(falValues.y));

fpeValues.xAT   = zeros(size(fpeValues.x));
fpeValues.yAT   = zeros(size(fpeValues.y));

fvValues.xAT    = zeros(size(fvValues.x));
fvValues.yAT    = zeros(size(fvValues.y));

for i=1:1:length(falValues.x)

    fibKin = calcFixedWidthPennatedFiberKinematicsAlongTendon(...
                                                falValues.x(i,1).*lceOpt,...
                                                0,...
                                                lceOpt,...
                                                alphaOpt);
    alpha = fibKin.pennationAngle;
    lceAT = fibKin.fiberLengthAlongTendon;

    dlt   = 0;
    falAT = fceOpt*falValues.y(i,1)*cos(alpha);

    if(flag_addTendonLengthChangeToMat156==1)
        ftN  = falAT/umat43.fceOpt;
        ftN0 = umat43QuadraticCurves.tendonForceLengthInverseNormCurve.xEnd(1,1);
        etN  = 0;

        if(ftN>ftN0)
            etN = calcQuadraticBezierYFcnXDerivative(ftN,...
                    umat43QuadraticCurves.tendonForceLengthInverseNormCurve,0);
        end
        et = etN*umat43.et;
        lt = umat43.ltSlk*(1+et);
        dlt = lt - umat43.ltSlk;
    end
   

    falValues.xAT(i,1) = (lceAT+dlt)/lceOptAT;
    falValues.yAT(i,1) = falAT/fceOptAT;

end

%Evaluate the passive-force-length curve along the tendon
for i=1:1:length(fpeValues.x)
    fibKin = calcFixedWidthPennatedFiberKinematicsAlongTendon(...
                                                fpeValues.x(i,1).*lceOpt,...
                                                0,...
                                                lceOpt,...
                                                alphaOpt);

    alpha = fibKin.pennationAngle;
    lceAT = fibKin.fiberLengthAlongTendon;

    dlt   = 0;
    fpeAT = fceOpt*fpeValues.y(i,1)*cos(alpha);

    if(flag_addTendonLengthChangeToMat156==1)
        ftN = fpeAT/umat43.fceOpt;

        ftN0 = umat43QuadraticCurves.tendonForceLengthInverseNormCurve.xEnd(1,1);
        etN  = 0;
        if(ftN>ftN0)
            etN = calcQuadraticBezierYFcnXDerivative(ftN,...
                    umat43QuadraticCurves.tendonForceLengthInverseNormCurve,0);
        end
        et  = etN*umat43.et;
        lt  = umat43.ltSlk*(1. + et);
        dlt = lt - umat43.ltSlk;
    end

    fpeValues.xAT(i,1) = (dlt+lceAT)/lceOptAT;
    fpeValues.yAT(i,1) = fpeAT/fceOptAT;
end


%Evaluate the force-velocity curve along the tendon
for i=1:1:length(fvValues.x)
    fiberKinematics = calcFixedWidthPennatedFiberKinematicsAlongTendon(...
                                                lceOpt,...
                                                fvValues.x(i,1)*(vceMax),...
                                                lceOpt,...
                                                alphaOpt);
    alpha = fiberKinematics.pennationAngle;
    lceAT = fiberKinematics.fiberLengthAlongTendon;
    vceAT = fiberKinematics.fiberVelocityAlongTendon;

    fvValues.xAT(i,1) = vceAT/vceMaxAT;
    fvValues.yAT(i,1) = fceOpt*fvValues.y(i,1)*cos(alpha)/fceOptAT;
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
        plot(falValues.x,falValues.y,'-','Color',[1,1,1].*0.5,'LineWidth',2);
        hold on;
        plot(falValues.xAT,falValues.yAT,'-','Color',[1,0,0]);
        hold on;
        
        xlabel('$$\tilde{\ell}^{M}$$');
        ylabel('$$\tilde{f}^{L}$$');
        box off;

    subplot(1,3,2);
        plot(fpeValues.x,fpeValues.y,'--','Color',[1,1,1].*0.5,'LineWidth',2);
        hold on;
        plot(fpeValues.xAT,fpeValues.yAT,'-','Color',[0,0,1]);
        hold on;


        xlabel('$$\tilde{\ell}^{M}$$');
        ylabel('$$\tilde{f}^{PE}$$');
        box off;
        
    subplot(1,3,3);
        plot(fvValues.x,fvValues.y,'-','Color',[0,0,0]);
        hold on;
        plot(fvValues.xAT,fvValues.yAT,'--','Color',[1,0,0]);
        hold on;
        
        xlabel('$$\tilde{v}^{M}$$');
        ylabel('$$\tilde{f}^{V}$$');
        box off;
end