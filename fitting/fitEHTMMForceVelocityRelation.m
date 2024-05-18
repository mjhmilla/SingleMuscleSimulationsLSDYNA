function [umat41,ehtmmCurves]= ...
            fitEHTMMForceVelocityRelation(...
                    umat41,...
                    keyPointsHL1997,...
                    keyPointsVEXATFv,...
                    ehtmmCurves,...
                    flag_plotVEXATForceVelocityFitting)


errFcn = @(arg)calcEHTMMForceVelocityError(arg,...
                        umat41,...
                        keyPointsHL1997,...
                        keyPointsVEXATFv);

x0 = [1;1;1];
lb = [];%[0.5;0.5];
ub = [];%[2;2];
[x1, resnorm,residual,exitflag]   = lsqnonlin(errFcn,x0,lb,ub);

%Arel = x1(1,1)*umat41.Arel;
%Brel = x1(2,1)*umat41.Brel;

Brel = umat41.Brel*x1(1,1);
Arel = Brel/keyPointsVEXATFv.vceMaxAT;
Fecc = umat41.Fecc*x1(2,1);
Secc = umat41.Secc*x1(3,1);

umat41.Arel=Arel;
umat41.Brel=Brel;
umat41.Fecc=Fecc;
umat41.Secc=Secc;
umat41.vceMax = abs(Brel/Arel);

disp('fitVEXATForceVelocityRelation')
fprintf('\t\t%1.4f\t%s\n\t\t%1.4f\t%s\n',...
        Arel,'Arel',Brel,'Brel');

vceMax = abs(Brel/Arel);
vceNNAT    = ([-1:0.01:1]');
fceNAT    = zeros(size(vceNNAT));


for i=1:1:length(vceNNAT)


    vceAT = vceNNAT(i,1)*(vceMax*umat41.lceOpt);
    
    Fisom=1;
    q=1;
    fv = calcFvUmat41(vceAT,umat41.lceOpt,umat41.lceOpt,...
                      umat41.fceOptAT,Fisom,q,...
                      umat41.Arel,umat41.Brel,umat41.Fecc,umat41.Secc);

    fvNAT = fv/umat41.fceOptAT;

    fceNAT(i,1)=fvNAT;

end

ehtmmCurves.fv.vceNNAT   = vceNNAT;
ehtmmCurves.fv.fceNAT    = fceNAT;
ehtmmCurves.fv.rmse = sqrt(mean(residual.^2));

if(flag_plotVEXATForceVelocityFitting==1)    
    figVEXATFv = figure;
        plot(vceNNAT.*vceMax,fceNAT,'-k','DisplayName','VEXAT');
        hold on;
        plot(keyPointsHL1997.fv.umat41.vceNAT,...
             keyPointsHL1997.fv.umat41.fceNAT,'ok',...
             'DisplayName','HL1997');
        hold on;
        xlabel('Norm. Velocity ($$\ell/(\ell^M_o v^M_{max})$$');
        ylabel('Norm. Force ($$f/f^M_o$$');
        title('EHTMM fore-velocity relation fitting');        
end

