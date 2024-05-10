function [umat41,ehtmmCurves]= ...
            fitEHTMMForceVelocityRelation(...
                    umat41,...
                    keyPointsHL1997,...
                    ehtmmCurves,...
                    flag_plotVEXATForceVelocityFitting)

mm2m=0.001;
keyPointsScaling.length = mm2m;
keyPointsScaling.force = 1;
keyPointsScaling.velocity = mm2m;

errFcn = @(arg)calcEHTMMForceVelocityError(arg,...
                        umat41,...
                        keyPointsHL1997,...
                        keyPointsScaling);

x0 = [1;1];
lb = [0.5;0.5];
ub = [2;2];
[x1, resnorm,residual,exitflag]   = lsqnonlin(errFcn,x0,lb,ub);

Arel = x1(1,1)*umat41.Arel;
Brel = x1(2,1)*umat41.Brel;
umat41.Arel=Arel;
umat41.Bsrel=Brel;


disp('fitVEXATForceVelocityRelation')
fprintf('\t\t%1.4f\t%s\n\t\t%1.4f\t%s\n',...
        Arel,'Arel',Brel,'Brel');

vceMax = abs(Brel/Arel);
vceNAT    = ([-1:0.01:1]') .* abs(vceMax);
fceNAT    = zeros(size(vceNAT));


for i=1:1:length(vceNAT)


    vceAT = vceNAT(i,1)*(umat41.lceOpt);
    
    Fisom=1;
    q=1;
    fv = calcFvUmat41(vceAT,umat41.lceOpt,umat41.lceOpt,...
                      umat41.fceOptAT,Fisom,q,...
                      umat41.Arel,umat41.Brel,umat41.Fecc,umat41.Secc);

    fvNAT = fv/umat41.fceOptAT;

    fceNAT(i,1)=fvNAT;

end

ehtmmCurves.fv.vceNAT   = vceNAT;
ehtmmCurves.fv.fceNAT   = fceNAT;
ehtmmCurves.fv.rmse = sqrt(mean(residual.^2));

if(flag_plotVEXATForceVelocityFitting==1)    
    figVEXATFv = figure;
        plot(vceNAT,fceNAT,'-k','DisplayName','VEXAT');
        hold on;
        plot(keyPointsHL1997.fv.v .*(keyPointsScaling.velocity/umat41.lceOpt),...
             keyPointsHL1997.fv.fvN,'ok',...
             'DisplayName','HL1997');
        hold on;
        xlabel('Norm. Length ($$\ell/\ell^M_o$$');
        ylabel('Norm. Force ($$f/f^M_o$$');
        title('VEXAT fore-velocity relation fitting');        
end

