function [falPts,fpePts] = ...
        calcActiveForceLengthWithElasticTendonV3(...
                        lmtRef,...
                        fmt,...
                        lpeRef, ...
                        fpe, ...
                        fpeClusters,...
                        lp0,...
                        umat43TendonParams,...
                        tendonForceLengthInverseNormCurve,...
                        umat41TendonParams,...
                        tendonType_0Umat41_1Umat43_2Mat156)

%%
% Fit a model to the passive-force-length data fpeClusters
%%


switch tendonType_0Umat41_1Umat43_2Mat156
    case 0
        %Solve for lce at lp0 with a passive muscle

        ltFpe = calcEHTMMTendonLength(fpe,...
                    umat41TendonParams.ltSlk,...
                    umat41TendonParams.dUSEEnll,...
                    umat41TendonParams.duSEEl,...
                    umat41TendonParams.dFSEE0);

        lceFpe = lpeRef-(ltFpe-umat41TendonParams.ltSlk) + loffset;
    case 1
        %Solve for lce at lp0 with a passive muscle
        
        ltFpe = calcVEXATTendonLength(...
                    fpe,...
                    umat43TendonParams.fceOpt,...
                    tendonForceLengthInverseNormCurve,...
                    umat43TendonParams.et,...
                    umat43TendonParams.ltSlk);
        lceFpe = lpeRef-(ltFpe-umat43TendonParams.ltSlk) + loffset;
    case 2
        %Solve for lce at lp0 with a passive muscle
        lce0 = lp0 - umat43TendonParams.ltSlk;
        lceFpe = lpeRef + loffset;        
end

%Evaluate the mean values for lce and fpe
k = kmeans(lceFpe, fpeClusters);
fpeModel.lce = zeros(max(k),1);
fpeModel.f = zeros(max(k),1);
for i=1:1:max(k)
    idx = find(k==i);
    fpeModel.lce(i)=mean(lceFpe(idx));
    fpeModel.f(i)=mean(fpe(idx));    
end

fpePts.fceAT = fpe;
fpePts.lceAT = lceFpe;

%%
% Evaluate the ce length during the active trials
%%
switch tendonType_0Umat41_1Umat43
    case 0
        ltFpe = calcEHTMMTendonLength(fmt,...
                    umat41TendonParams.ltSlk,...
                    umat41TendonParams.dUSEEnll,...
                    umat41TendonParams.duSEEl,...
                    umat41TendonParams.dFSEE0);
        lrefUpd = lpeRef-(ltFpe-umat41TendonParams.ltSlk) + loffset;        
    case 1
        ltFmt = calcVEXATTendonLength(...
                    fmt,...
                    umat43TendonParams.fceOpt,...
                    tendonForceLengthInverseNormCurve,...
                    umat43TendonParams.et,...
                    umat43TendonParams.ltSlk);
        
        lrefUpd = lmtRef -(ltFmt-umat43TendonParams.ltSlk) + loffset;        
end

%%
% Evaluate the fpe model at these lengths
%%
interpolant='linear';
if(fpeClusters > 3)
    interpolant='spline';
end

fpeUpd = zeros(size(lrefUpd));
for i=1:1:length(lrefUpd)
    fpeUpd(i,1) = interp1(fpeModel.lce,fpeModel.f,lrefUpd(i,1),...
                    interpolant,'extrap');
end

%%
% Subtract off the fpe data
%%
falPts.fceAT = fmt - fpeUpd;
falPts.lceAT = lrefUpd;
falPts.fpeAT=fpeUpd;