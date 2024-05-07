function [umat43, keyPointsHL1997, keyPointsHL2002] = ...
   fitVEXATActiveForceLengthRelation(expData, ...
           umat43, ...
           activeForceLengthCurve,...
           keyPointsHL1997, keyPointsHL2002,...
           flag_plotVEXATActiveForceLengthFitting)
%%
% Prelimiary work suggests that the shape of the the VEXAT template
% (which follows the sarcomere force-length template of Rassier et al.) 
% fits the shape of the maximum isometric force-length relation of
% measurements from: Scott et al., Rack and Westbury, and Rode et al., all
% of which were done from cat soleus studies of whole muscle. The
% measurements of Herzog and Leonard 1997 do not include the maximum
% isometric force, the optimal fiber length, nor the normalized length
% that forms the reference length of 0. While Herzog and Leonard 2002 does
% include the optimal fiber length and the maximum isometric force 
% the values can easily be in error by 5-10% because the plateau region of
% the force length curve was not densley sampled and it is relatively flat.
%
% The fitting approach is thus:
% 1. Solve for fceOptAT and lceOptAT for Herzog and Leonard 1997 to
%   minimize square errors between the normalized data and the template curve
%
% 2. Solve for the small adjustments (5-10%) to fceOptAT and lceOptAT for 
%    Herzog and Leonard 2002 to minimize the errors between the  
%    normalized data and the template curve.
%
% During this process the elasticity of the tendon is ignored because
%
% 1. Cat soleus tendon is short: 27 mm for a 38 mm ce. With a 0.0458 
%    strain at fiso, this assumption will introduction an error of  
%    1.24 mm (27*0.0458) or 3.25% lceOpt. This is well within experimental
%    error.
%
% 2. It is a non-trival complication to include a tendon during the 
%    fitting process: both fl and fpe have to be simultaneously fitted
%    since the tendon affects both of these parallel elements and vice
%    versa. Fitting the force-velocity relation is quite challenging:
%    the experiment has to be simulated to do the fitting unless
%    assumptions are made aboue the distribution of contraction velocity
%    between the CE and the tendon.
%
% Scott SH, Brown IE, Loeb GE. Mechanics of feline soleus: I. Effect of 
% fascicle length and velocity on force output. Journal of Muscle Research 
% & Cell Motility. 1996 Apr;17:207-19.
%
% Rack PM, Westbury DR. The effects of length and stimulus rate on tension 
% in the isometric cat soleus muscle. The Journal of physiology. 
% 1969 Oct;204(2):443.
%
% Rassier DE, MacIntosh BR, Herzog W. Length dependence of active force 
% production in skeletal muscle. Journal of applied physiology. 1999 
% May 1;86(5):1445-57.
%
% Rode C, Siebert T, Herzog W, Blickhan R. The effects of parallel and 
% series elastic components on the active cat soleus force-length 
% relationship. Journal of Mechanics in Medicine and Biology. 2009 
% Mar;9(01):105-22.
%%

%%
% Ascending limb: Herzog & Leonard 1997
%%
mm2m=0.001;
keyPointsScaling.length = mm2m;
keyPointsScaling.force = 1;

[defaultSoln.fceOptAT, idxFceOptAT] = max(keyPointsHL1997.fl.f);
defaultSoln.lceOptAT = umat43.lceOptAT;


errFcnHL1997 = @(arg)calcVEXATActiveForceLengthError(arg,....
                                    defaultSoln,...
                                    umat43,...
                                    keyPointsHL1997,...
                                    keyPointsScaling,...
                                    activeForceLengthCurve);

%From Mass & Sandercock Figure 4 we know that 80 degrees of ankle angle is 
% around the optimal fiber length for some cats 
%
% Maas H, Sandercock TG. Are skeletal muscles independent actuators? Force 
% transmission from soleus muscle in the cat. Journal of applied physiology. 
% 2008 Jun;104(6):1557-67.


x0 = [1;1;0.8];
ub = [1;1;1].*1.2;
lb = [1;1;1].*0.8;

options=optimset('Display','off');
[x1, resnorm,residual,exitflag] = lsqnonlin(errFcnHL1997,x0,lb,ub,options);
assert(exitflag==1);

keyPointsHL1997.lceOptAT    = defaultSoln.lceOptAT*x1(1,1);
keyPointsHL1997.fceOptAT    = defaultSoln.fceOptAT*x1(2,1);

keyPointsHL1997.lceOpt      = keyPointsHL1997.lceOptAT / cos(umat43.penOpt);
keyPointsHL1997.fceOpt      = keyPointsHL1997.fceOptAT / cos(umat43.penOpt);

keyPointsHL1997.lceNATZero  = x1(3,1);


disp('fitVEXATActiveForceLengthRelation')
fprintf('\tHL1997 fitted scaling\n\t\t%1.4f\tlce scaling\n\t\t%1.4f\tfce scaling\n\t\t%1.4f\tlceNAT\n',...
    x1(1),x1(2),x1(3));

fprintf('\tHL1997 fitted values\n\t\t%1.4f\tlceOptAT\n\t\t%1.4f\tfceOptAT\n\t\t%1.4f\tlceNATZero\n',...
    keyPointsHL1997.lceOptAT,...
    keyPointsHL1997.fceOptAT,...
    keyPointsHL1997.lceNATZero);

%%
%Normalize the keypoint quantities
%%

%Update the active force length relation
keyPointsHL1997.fl.lceNAT = ...
    ((keyPointsHL1997.fl.l).*mm2m ...
      + keyPointsHL1997.lceNATZero*keyPointsHL1997.lceOptAT...
      )./keyPointsHL1997.lceOptAT;
keyPointsHL1997.fl.fceNAT = keyPointsHL1997.fl.f ./ keyPointsHL1997.fceOptAT;

%And the passive force-length relation
keyPointsHL1997.fpe.lceNAT = ...
    ((keyPointsHL1997.fpe.l).*mm2m ...
      + keyPointsHL1997.lceNATZero*keyPointsHL1997.lceOptAT...
      )./keyPointsHL1997.lceOptAT;
keyPointsHL1997.fpe.fceNAT = keyPointsHL1997.fpe.f ./ keyPointsHL1997.fceOptAT;

keyPointsHL1997.fv.vN = keyPointsHL1997.fv.v./keyPointsHL1997.lceOptAT;

%Project data on the fiber
for i=1:1:length(keyPointsHL1997.fl.lceNAT)
    lceOpt  = keyPointsHL1997.lceOpt;
    fceOpt  = keyPointsHL1997.fceOpt;
    lceOptAT = keyPointsHL1997.lceOptAT;
    fceOptAT = keyPointsHL1997.fceOptAT;

    lceAT  = keyPointsHL1997.fl.lceNAT(i,1)*lceOptAT;
    fceAT  = keyPointsHL1997.fl.fceNAT(i,1)*fceOptAT;

    fibKin  = calcFixedWidthPennatedFiberKinematics(lceAT,...
                                    0,...
                                    lceOpt,...
                                    umat43.penOpt);
    lce     = fibKin.fiberLength;
    alpha   = fibKin.pennationAngle;   
    fce     = fceAT/cos(alpha);

    keyPointsHL1997.fl.lceN(i,1) = lce/lceOpt;
    keyPointsHL1997.fl.fceN(i,1) = fce/fceOpt; 
end

%%
% Descending limb: Herzog & Leonard 2002
%%
keyPointsScaling.length = mm2m;
keyPointsScaling.force = 1;

%The optimal fiber length is indirectly reported in Herzog and Leonard 
% 2002: 27mm/s is listed as 63\% of 1 optimal fiber length/s
% in Fig 3 caption, and 9mm is listed as 21% of optimal
% fiber length: 9/0.21 = 27/0.63 = 42.8571 mm

lceOptAT = (27/0.63)*mm2m;

[defaultSoln.fceOptAT, idxFceOptAT] = max(keyPointsHL2002.fl.f);
defaultSoln.lceOptAT = lceOptAT + keyPointsHL2002.fl.l(idxFceOptAT).*mm2m;

x0 = [1;1;1];
ub = [1.2;1.05;1.05]; 
lb = [0.8;0.95;0.95];

%
% lceOptAT +/- 20% error is allowed because this parameter was not reported
%                 directly.
% fceOptAT +/- 5% error is allowed because this parameter was collected
% lceNATZero +/- 5% error is allowed due to the narrow range where the
%                   optimal fiber length is a bit ambiguous
%

errFcnHL2002 = @(arg)calcVEXATActiveForceLengthError(arg,....
                                    defaultSoln,...
                                    umat43,...
                                    keyPointsHL2002,...
                                    keyPointsScaling,...
                                    activeForceLengthCurve);

options=optimset('Display','off');
[x1, resnorm,residual,exitflag] = lsqnonlin(errFcnHL2002,x0,lb,ub,options);
assert(exitflag==1);

keyPointsHL2002.lceOptAT    = defaultSoln.lceOptAT*x1(1,1);
keyPointsHL2002.fceOptAT    = defaultSoln.fceOptAT*x1(2,1);
keyPointsHL2002.lceNATZero  = x1(3,1);

keyPointsHL2002.lceOpt    = keyPointsHL2002.lceOptAT/cos(umat43.penOpt);
keyPointsHL2002.fceOpt    = keyPointsHL2002.fceOptAT/cos(umat43.penOpt);

fprintf('\tHL2002 fitting\n\t\t%1.4f\tlce scaling\n\t\t%1.4f\tfce scaling\n\t\t%1.4f\tlceNAT\n',...
    x1(1),x1(2),x1(3));
fprintf('\tHL2002 fitting\n\t\t%1.4f\tlceOptAT\n\t\t%1.4f\tfceOptAT\n\t\t%1.4f\tlceNATZero\n',...
    keyPointsHL2002.lceOptAT,...
    keyPointsHL2002.fceOptAT,...
    keyPointsHL2002.lceNATZero);


%%
%Normalize the keypoint quantities
%%
keyPointsHL2002.fl.lceNAT = ((keyPointsHL2002.fl.l).*mm2m ...
                            + keyPointsHL2002.lceNATZero*keyPointsHL2002.lceOptAT ...
                           )./keyPointsHL2002.lceOptAT;
keyPointsHL2002.fl.fceNAT = keyPointsHL2002.fl.f ./ keyPointsHL2002.fceOptAT;

%And the passive force-length relation
keyPointsHL2002.fpe.lceNAT = ...
    ((keyPointsHL2002.fpe.l).*mm2m ...
      + keyPointsHL2002.lceNATZero*keyPointsHL2002.lceOptAT...
      )./keyPointsHL2002.lceOptAT;
keyPointsHL2002.fpe.fceNAT = keyPointsHL2002.fpe.f ./ keyPointsHL2002.fceOptAT;

%Project data on the fiber
for i=1:1:length(keyPointsHL2002.fl.lceNAT)
    lceOpt  = keyPointsHL2002.lceOpt;
    fceOpt  = keyPointsHL2002.fceOpt;
    lceOptAT = keyPointsHL2002.lceOptAT;
    fceOptAT = keyPointsHL2002.fceOptAT;

    lceAT  = keyPointsHL2002.fl.lceNAT(i,1)*lceOptAT;
    fceAT  = keyPointsHL2002.fl.fceNAT(i,1)*fceOptAT;

    fibKin  = calcFixedWidthPennatedFiberKinematics(lceAT,...
                                    0,...
                                    lceOpt,...
                                    umat43.penOpt);
    lce     = fibKin.fiberLength;
    alpha   = fibKin.pennationAngle;   
    fce     = fceAT/cos(alpha);

    keyPointsHL2002.fl.lceN(i,1) = lce/lceOpt;
    keyPointsHL2002.fl.fceN(i,1) = fce/fceOpt; 
end



switch expData
    case 'HL1997'
        umat43.fceOptAT = keyPointsHL1997.fceOptAT;
        umat43.lceOptAT = keyPointsHL1997.lceOptAT;
        umat43.fceOpt   = keyPointsHL1997.fceOpt;
        umat43.lceOpt   = keyPointsHL1997.lceOpt;        
    case 'HL2002'
        umat43.fceOptAT = keyPointsHL2002.fceOptAT;
        umat43.lceOptAT = keyPointsHL2002.lceOptAT;
        umat43.fceOpt   = keyPointsHL2002.fceOpt;
        umat43.lceOpt   = keyPointsHL2002.lceOpt;            
    otherwise
        assert(0,'Error: expData must be HL1997 or HL2002')
end


if(flag_plotVEXATActiveForceLengthFitting==1)
    figVEXATFalFitting=figure;

    lceN = [0.45:0.01:1.6]';
    falN = zeros(size(lceN));
    for i=1:1:length(lceN)
        falN(i,1)=calcQuadraticBezierYFcnXDerivative(lceN(i,1),...
                    activeForceLengthCurve,0);
    end

    plot(lceN,falN,'-','Color',[1,1,1].*0.5,'DisplayName','VEXAT');
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
    title('Fitting: Active-force-length relation (VEXAT)');
end








