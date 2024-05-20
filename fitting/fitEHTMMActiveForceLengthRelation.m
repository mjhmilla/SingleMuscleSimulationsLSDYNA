function [umat41, keyPointsHL1997, keyPointsHL2002, ehtmmCurves]= ...
    fitEHTMMActiveForceLengthRelation(expData, ...
                       umat41, ...
                       keyPointsHL1997, keyPointsHL2002,...
                       ehtmmCurves,...
                       flag_plotEHTMMActiveForceLengthFitting)



errFcn = @(arg)calcEHTMMActiveCurveErrorV2(arg,umat41,...
                    keyPointsHL1997, keyPointsHL2002);

x0          = [1;1;1;1];
options     = optimset('Display','off');
[x1, resnorm,residual,exitflag]   = lsqnonlin(errFcn,x0,[],[],options);
assert(exitflag==1 || exitflag==3);

ehtmmCurves.fl.rmse = sqrt(mean(residual.^2));

dWdes       = x1(1,1)*umat41.dWdes;
nuCEdes     = x1(2,1)*umat41.nuCEdes;
dWasc       = x1(3,1)*umat41.dWasc;
nuCEasc     = x1(4,1)*umat41.nuCEasc;

umat41.dWdes       = dWdes;
umat41.nuCEdes     = nuCEdes;
umat41.dWasc       = dWasc;
umat41.nuCEasc     = nuCEasc;


disp('fitEHTMMActiveForceLengthRelation')
fprintf('\tScaling\n');
fprintf('\t\t%1.4f\t%s\n\t\t%1.4f\t%s\n\t\t%1.4f\t%s\n\t\t%1.4f\t%s\n',...
    x1(1),'dWdes',x1(2),'nuCEdes',x1(3),'dWasc',x1(4),'nuCEasc');
fprintf('\tValues\n');
fprintf('\t\t%1.4f\t%s\n\t\t%1.4f\t%s\n\t\t%1.4f\t%s\n\t\t%1.4f\t%s\n',...
    dWdes,'dWdes',nuCEdes,'nuCEdes',dWasc,'dWasc',nuCEasc,'nuCEasc');

umat41HL1997TendonParams.dUSEEnll =umat41.dUSEEnll;
umat41HL1997TendonParams.duSEEl   =umat41.duSEEl;
umat41HL1997TendonParams.dFSEE0   =umat41.dFSEE0;
umat41HL1997TendonParams.ltSlk    =keyPointsHL1997.ltSlk;

tendonType_0Umat41_1Umat43=0;
[fal1997Pts,fpe1997Pts] = ...
    calcActiveForceLengthWithElasticTendonV2(...
            keyPointsHL1997.fl.l*keyPointsHL1997.nms.l,...
            keyPointsHL1997.fl.fmt*keyPointsHL1997.nms.f,...
            keyPointsHL1997.fl.l*keyPointsHL1997.nms.l,...
            keyPointsHL1997.fl.fpe*keyPointsHL1997.nms.f,...
            keyPointsHL1997.fl.clusters,...
            keyPointsHL1997.lceNAT0a*keyPointsHL1997.lceOpt,...
            [],...
            [],...
            umat41HL1997TendonParams,...
            tendonType_0Umat41_1Umat43);

keyPointsHL1997.fl.umat41.lceNAT = fal1997Pts.lceAT ./ keyPointsHL1997.lceOpt;
keyPointsHL1997.fl.umat41.fceNAT = fal1997Pts.fceAT ./ keyPointsHL1997.fceOpt;

keyPointsHL1997.fpe.umat41.lceNAT = fpe1997Pts.lceAT ./ keyPointsHL1997.lceOpt;
keyPointsHL1997.fpe.umat41.fceNAT = fpe1997Pts.fceAT ./ keyPointsHL1997.fceOpt;

%Forc-velocity relation
tendonType_0Umat41_1Umat43=0;
[fvPts, fpePts] = ...
    calcActiveForceLengthWithElasticTendonV2(...
            keyPointsHL1997.fv.l*keyPointsHL1997.nms.l,...
            keyPointsHL1997.fv.fmt*keyPointsHL1997.nms.f,...
            keyPointsHL1997.fpe.l*keyPointsHL1997.nms.l,...
            keyPointsHL1997.fpe.f*keyPointsHL1997.nms.f,...
            keyPointsHL1997.fpe.clusters,...
            keyPointsHL1997.lceNAT0a*keyPointsHL1997.lceOpt,...
            [],...
            [],...
            umat41HL1997TendonParams,...
            tendonType_0Umat41_1Umat43);

keyPointsHL1997.fv.umat41.fceNAT = fvPts.fceAT./keyPointsHL1997.fv.fmtMid;
keyPointsHL1997.fv.umat41.vceNAT = ...
    (keyPointsHL1997.fv.v .* keyPointsHL1997.nms.l)...
    ./ keyPointsHL1997.lceOpt;

keyPointsHL1997.fv.umat41.lceAT = fvPts.lceAT*(1/keyPointsHL1997.nms.l);
keyPointsHL1997.fv.umat41.fpeAT = fvPts.fpeAT*(1/keyPointsHL1997.nms.f);



umat41HL2002TendonParams.dUSEEnll =umat41.dUSEEnll;
umat41HL2002TendonParams.duSEEl   =umat41.duSEEl;
umat41HL2002TendonParams.dFSEE0   =umat41.dFSEE0;
umat41HL2002TendonParams.ltSlk    =keyPointsHL2002.ltSlk;

tendonType_0Umat41_1Umat43=0;
[fal2002Pts,fpe2002Pts] = ...
    calcActiveForceLengthWithElasticTendonV2(...
            keyPointsHL2002.fl.l*keyPointsHL2002.nms.l,...
            keyPointsHL2002.fl.fmt*keyPointsHL2002.nms.f,...
            keyPointsHL2002.fl.l*keyPointsHL2002.nms.l,...
            keyPointsHL2002.fl.fpe*keyPointsHL2002.nms.f,...
            keyPointsHL2002.fl.clusters,...
            keyPointsHL2002.lceNAT0a*keyPointsHL2002.lceOpt,...
            [],...
            [],...
            umat41HL2002TendonParams,...
            tendonType_0Umat41_1Umat43);

keyPointsHL2002.fl.umat41.lceNAT = fal2002Pts.lceAT ./ keyPointsHL2002.lceOpt;
keyPointsHL2002.fl.umat41.fceNAT = fal2002Pts.fceAT ./ keyPointsHL2002.fceOpt;

keyPointsHL2002.fpe.umat41.lceNAT = fpe2002Pts.lceAT ./ keyPointsHL2002.lceOpt;
keyPointsHL2002.fpe.umat41.fceNAT = fpe2002Pts.fceAT ./ keyPointsHL2002.fceOpt;



lceNAT = [0.45:0.01:1.6]';
falNAT = zeros(size(lceNAT));
for i=1:1:length(lceNAT)
    falNAT(i,1)=calcFisomUmat41(lceNAT(i,1)*umat41.lceOptAT,...
                umat41.lceOptAT,dWdes,nuCEdes,dWasc,nuCEasc);        
end    
ehtmmCurves.fl.lceNAT=lceNAT;
ehtmmCurves.fl.fceNAT=falNAT;
    
if(flag_plotEHTMMActiveForceLengthFitting==1)
    figEHTMMFalFitting=figure;
    plot(lceNAT,falNAT,'-','Color',[1,1,1].*0.5,'DisplayName','EHTMM');
    hold on;
    plot(keyPointsHL1997.fl.umat41.lceNAT,keyPointsHL1997.fl.umat41.fceNAT,...
        'o','Color',[0,0,0],'DisplayName','HL1997 (umat41 tdn)');
    hold on;
    plot(keyPointsHL2002.fl.umat41.lceNAT,keyPointsHL2002.fl.umat41.fceNAT,...
        'x','Color',[0,0,0],'DisplayName','HL2002 (umat41 tdn)');
    hold on;    
    box off;

    plot(keyPointsHL1997.fl.umat43.lceNAT,keyPointsHL1997.fl.umat43.fceNAT,...
        'o','Color',[1,0,0],'DisplayName','HL1997 (umat43 tdn)');
    hold on;
    plot(keyPointsHL2002.fl.umat43.lceNAT,keyPointsHL2002.fl.umat43.fceNAT,...
        'x','Color',[1,0,0],'DisplayName','HL2002 (umat43 tdn)');
    hold on;    
    box off;

    legend;

    xlabel('Norm. Length ($$\ell / \ell^M_o$$)');
    ylabel('Norm. Force ($$f / f^M_o$$)');
    title('Fitting: Active-force-length relation (EHTMM)');    

end
