function umat41 = fitEHTMMActiveForceLengthRelation(expData, ...
                       umat41, ...
                       keyPointsHL1997, keyPointsHL2002,...
                       flag_plotEHTMMActiveForceLengthFitting)



errFcn = @(arg)calcEHTMMActiveCurveErrorV2(arg,umat41,...
                    keyPointsHL1997, keyPointsHL2002);

x0          = [1;1;1;1];
options     = optimset('Display','off');
[x1, resnorm,residual,exitflag]   = lsqnonlin(errFcn,x0,[],[],options);
assert(exitflag==1 || exitflag==3);

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


if(flag_plotEHTMMActiveForceLengthFitting==1)
    figEHTMMFalFitting=figure;
    lceN = [0.45:0.01:1.6]';
    falN = zeros(size(lceN));
    for i=1:1:length(lceN)
        falN(i,1)=calcFisomUmat41(lceN(i,1)*umat41.lceOptAT,...
                    umat41.lceOptAT,dWdes,nuCEdes,dWasc,nuCEasc);        
    end    

    plot(lceN,falN,'-','Color',[1,1,1].*0.5,'DisplayName','EHTMM');
    hold on;
    plot(keyPointsHL1997.fl.lceN,keyPointsHL1997.fl.fceN,...
        'o','Color',[0,0,0],'DisplayName','HL1997');
    hold on;
    plot(keyPointsHL2002.fl.lceN,keyPointsHL2002.fl.fceN,...
        'x','Color',[0,0,0],'DisplayName','HL2002');
    hold on;    
    box off;

    legend;

    xlabel('Norm. Length ($$\ell / \ell^M_o$$)');
    ylabel('Norm. Force ($$f / f^M_o$$)');
    title('Fitting: Active-force-length relation (EHTMM)');    

end
