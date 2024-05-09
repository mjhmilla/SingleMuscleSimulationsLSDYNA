function [umat41, ehtmmCurves]= fitEHTMMActiveForceLengthRelation(expData, ...
                       umat41, ...
                       keyPointsHL1997, keyPointsHL2002,...
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


    figEHTMMFalFitting=figure;
    lceNAT = [0.45:0.01:1.6]';
    falNAT = zeros(size(lceNAT));
    for i=1:1:length(lceNAT)
        falNAT(i,1)=calcFisomUmat41(lceNAT(i,1)*umat41.lceOptAT,...
                    umat41.lceOptAT,dWdes,nuCEdes,dWasc,nuCEasc);        
    end    
    ehtmmCurves.fl.lceNAT=lceNAT;
    ehtmmCurves.fl.fceNAT=falNAT;
    
if(flag_plotEHTMMActiveForceLengthFitting==1)
    plot(lceNAT,falNAT,'-','Color',[1,1,1].*0.5,'DisplayName','EHTMM');
    hold on;
    plot(keyPointsHL1997.fl.lceNAT,keyPointsHL1997.fl.fceNAT,...
        'o','Color',[0,0,0],'DisplayName','HL1997');
    hold on;
    plot(keyPointsHL2002.fl.lceNAT,keyPointsHL2002.fl.fceNAT,...
        'x','Color',[0,0,0],'DisplayName','HL2002');
    hold on;    
    box off;

    legend;

    xlabel('Norm. Length ($$\ell / \ell^M_o$$)');
    ylabel('Norm. Force ($$f / f^M_o$$)');
    title('Fitting: Active-force-length relation (EHTMM)');    

end
