function [fal,fpeUpd,lrefUpd] = calcActiveForceLengthWithElasticTendon(...
                        lref,fmt,fpe,clusters,...
                        loffset,...
                        tendonForceLengthInverseNormCurve,...
                        etIso,ltSlk,fceOpt)

%%
% Fit a model to the passive-force-length data clusters
%%
modelType = 1;
interpolant='linear';
if(clusters > 3)
    interpolant='spline';
end

%0: quadratic
%1: linear interpolation

ltFpe = calcVEXATTendonLength(...
            fpe,...
            fceOpt,...
            tendonForceLengthInverseNormCurve,...
            etIso,...
            ltSlk);

lceFpe = lref-(ltFpe-ltSlk) + loffset;

k = kmeans(lceFpe, clusters);
fpeModel.lce = zeros(max(k),1);
fpeModel.f = zeros(max(k),1);
for i=1:1:max(k)
    idx = find(k==i);
    fpeModel.lce(i)=mean(lceFpe(idx));
    fpeModel.f(i)=mean(fpe(idx));    
end

A = [fpeModel.lce.^2,fpeModel.lce, ones(size(fpeModel.lce))];
b = [fpeModel.f];
fpeModel.coeff = pinv((A'*A))*(A'*b);

flag_plotQuadraticFpeModel=0;
if(flag_plotQuadraticFpeModel==1)
    figFpeModel=figure;
    l0=min(fpeModel.lce);
    l1=max(fpeModel.lce);
    lvec = [l0:((l1-l0)/(99)):l1]';
    fvec=zeros(size(lvec));
    for i=1:1:length(lvec)
        lce = lvec(i,1);
        switch modelType
            case 0
                fvec(i,1)=[lce*lce, lce, 1]*fpeModel.coeff;
            case 1
                fvec(i,1) = interp1(fpeModel.lce,fpeModel.f,lce,...
                                    interpolant,'extrap');
        end
    end

    plot(lceFpe,fpe,'.m');
    hold on;    
    plot(fpeModel.lce,fpeModel.f,'xr');
    hold on;    
    plot(lvec,fvec,'-k');
    hold on;

    xlabel('Length');
    ylabel('Force');
    title('Quadratic Passive force length model');
end


%%
% Evaluate the ce length during the active trials
%%
ltFmt = calcVEXATTendonLength(...
            fmt,...
            fceOpt,...
            tendonForceLengthInverseNormCurve,...
            etIso,...
            ltSlk);

lrefUpd = lref -(ltFmt-ltSlk) + loffset;

%%
% Evaluate the fpe model at these lengths
%%
fpeUpd = zeros(size(lrefUpd));
for i=1:1:length(lrefUpd)
    switch modelType
        case 0
            fpeUpd(i,1) =  [lrefUpd(i,1).^2,lrefUpd(i,1),1]*fpeModel.coeff;
        case 1
            fpeUpd(i,1) = interp1(fpeModel.lce,fpeModel.f,lrefUpd(i,1),...
                            interpolant,'extrap');
    end    
    
end

%%
% Subtract off the fpe data
%%
fal = fmt - fpeUpd;
