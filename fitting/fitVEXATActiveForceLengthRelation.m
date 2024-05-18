function [umat43, keyPointsHL1997, keyPointsHL2002,vexatCurves] = ...
   fitVEXATActiveForceLengthRelation(expData, ...
           umat43, ...
           activeForceLengthCurve,...
           tendonForceLengthInverseNormCurve,...
           keyPointsHL1997, keyPointsHL2002,...
           vexatCurves,...
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
% During this process the elasticity of the tendon is included by
% subtracting off the expected tendon length change from the experimentally
% measured lengths using a tendon model. Since both the VEXAT and EHTMM fit
% nearly exactly here the VEXAT's tendon-force-length-model is used.
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

[defaultSoln.fceOptAT, idxFceOptAT] = max(keyPointsHL1997.fl.fmt ...
                                         -keyPointsHL1997.fl.fpe);
defaultSoln.lceOptAT                = umat43.lceOptAT;

errFcnHL1997 = @(arg)calcVEXATActiveForceLengthError(arg,....
                                    defaultSoln,...
                                    umat43,...
                                    keyPointsHL1997,...
                                    activeForceLengthCurve,...
                                    tendonForceLengthInverseNormCurve);

%From Mass & Sandercock Figure 4 we know that 80 degrees of ankle angle is 
% around the optimal fiber length for some cats 
%
% Maas H, Sandercock TG. Are skeletal muscles independent actuators? Force 
% transmission from soleus muscle in the cat. Journal of applied physiology. 
% 2008 Jun;104(6):1557-67.


x0 = [1;1;1];
ub = [1;1;1].*1.2;
lb = [1;1;1].*0.2;

options=optimset('Display','off');
[x1, resnorm,residualHL1997,exitflag] = lsqnonlin(errFcnHL1997,x0,lb,ub,options);
assert(exitflag==1 || exitflag==3);

keyPointsHL1997.lceOpt = defaultSoln.lceOptAT*x1(1,1) / cos(umat43.penOpt);
keyPointsHL1997.fceOpt = defaultSoln.fceOptAT*x1(2,1) / cos(umat43.penOpt);
keyPointsHL1997.lceNATZero  = x1(3,1);

keyPointsHL1997.ltSlk  = keyPointsHL1997.lceOpt*umat43.tdnToCe;

disp('fitVEXATActiveForceLengthRelation')
fprintf('\tHL1997 fitted scaling\n\t\t%1.4f\tlce scaling\n\t\t%1.4f\tfce scaling\n\t\t%1.4f\tlceNAT\n',...
    x1(1),x1(2),x1(3));

fprintf('\tHL1997 fitted values\n\t\t%1.4f\tlceOpt\n\t\t%1.4f\tfceOpt\n\t\t%1.4f\tlceNATZero\n\t\t%1.4f\tltSlk\n',...
    keyPointsHL1997.lceOpt,...
    keyPointsHL1997.fceOpt,...
    keyPointsHL1997.lceNATZero,...
    keyPointsHL1997.ltSlk);


%%
%Normalize the keypoint quantities
%%
%Active force-length relation
tendonType_0Umat41_1Umat43=1;


umat43HL1997TendonParams.fceOpt   = keyPointsHL1997.fceOpt;
umat43HL1997TendonParams.et       = umat43.et;
umat43HL1997TendonParams.ltSlk    = keyPointsHL1997.ltSlk;

[falPts,fpePts] = ...
    calcActiveForceLengthWithElasticTendonV2(...
            keyPointsHL1997.fl.l*keyPointsHL1997.nms.l,...
            keyPointsHL1997.fl.fmt*keyPointsHL1997.nms.f,...
            keyPointsHL1997.fl.l*keyPointsHL1997.nms.l,...
            keyPointsHL1997.fl.fpe*keyPointsHL1997.nms.f,...
            keyPointsHL1997.fl.clusters,...
            keyPointsHL1997.lceNATZero*keyPointsHL1997.lceOpt,...
            umat43HL1997TendonParams,...
            tendonForceLengthInverseNormCurve,...
            [],...
            tendonType_0Umat41_1Umat43);

keyPointsHL1997.fl.umat43.lceNAT = falPts.lceAT/keyPointsHL1997.lceOpt;
keyPointsHL1997.fl.umat43.fceNAT = falPts.fceAT./keyPointsHL1997.fceOpt;

%And the passive force-length relation
keyPointsHL1997.fpe.umat43.lceNAT = fpePts.lceAT/keyPointsHL1997.lceOpt;
keyPointsHL1997.fpe.umat43.fceNAT = fpePts.fceAT./keyPointsHL1997.fceOpt;

%Forc-velocity relation
[fvPts, fpePts] = ...
    calcActiveForceLengthWithElasticTendonV2(...
            keyPointsHL1997.fv.l*keyPointsHL1997.nms.l,...
            keyPointsHL1997.fv.fmt*keyPointsHL1997.nms.f,...
            keyPointsHL1997.fpe.l*keyPointsHL1997.nms.l,...
            keyPointsHL1997.fpe.f*keyPointsHL1997.nms.f,...
            keyPointsHL1997.fpe.clusters,...
            keyPointsHL1997.lceNATZero*keyPointsHL1997.lceOpt,...
            umat43HL1997TendonParams,...
            tendonForceLengthInverseNormCurve,...
            [],...
            tendonType_0Umat41_1Umat43);

keyPointsHL1997.fv.umat43.fceNAT = fvPts.fceAT./keyPointsHL1997.fv.fmtMid;
keyPointsHL1997.fv.umat43.vceNAT = ...
    (keyPointsHL1997.fv.v .* keyPointsHL1997.nms.l)...
    ./ keyPointsHL1997.lceOpt;

keyPointsHL1997.fv.umat43.lceAT = fvPts.lceAT*(1/keyPointsHL1997.nms.l);
keyPointsHL1997.fv.umat43.fpeAT = fvPts.fpeAT*(1/keyPointsHL1997.nms.f);

%%
% Descending limb: Herzog & Leonard 2002
%%


%The optimal fiber length is indirectly reported in Herzog and Leonard 
% 2002: 27mm/s is listed as 63\% of 1 optimal fiber length/s
% in Fig 3 caption, and 9mm is listed as 21% of optimal
% fiber length: 9/0.21 = 27/0.63 = 42.8571 mm
mm2m = 0.001;
lceOptAT = (27/0.63)*mm2m;

[defaultSoln.fceOptAT, idxFceOptAT] = max(keyPointsHL2002.fl.fmt...
                                         -keyPointsHL2002.fl.fpe);

defaultSoln.lceOptAT = lceOptAT + keyPointsHL2002.fl.l(idxFceOptAT).*mm2m;

x0 = [1;1;1];
ub = [1;1;1].*1.2; 
lb = [1;1;1].*0.8;

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
                                    activeForceLengthCurve,...
                                    tendonForceLengthInverseNormCurve);

options=optimset('Display','off');
[x1, resnorm,residualHL2002,exitflag] = lsqnonlin(errFcnHL2002,x0,lb,ub,options);
assert(exitflag==1 || exitflag==2 || exitflag==3);

vexatCurves.fl.rmse = sqrt(mean([residualHL1997;residualHL2002].^2));

keyPointsHL2002.lceOpt    = defaultSoln.lceOptAT*x1(1,1)/cos(umat43.penOpt);
keyPointsHL2002.fceOpt    = defaultSoln.fceOptAT*x1(2,1)/cos(umat43.penOpt);
keyPointsHL2002.lceNATZero  = x1(3,1);

keyPointsHL2002.ltSlk  = keyPointsHL2002.lceOpt*umat43.tdnToCe;

fprintf('\tHL2002 fitting\n\t\t%1.4f\tlce scaling\n\t\t%1.4f\tfce scaling\n\t\t%1.4f\tlceNAT\n',...
    x1(1),x1(2),x1(3));
fprintf('\tHL2002 fitting\n\t\t%1.4f\tlceOpt\n\t\t%1.4f\tfceOpt\n\t\t%1.4f\tlceNATZero\n\t\t%1.4f\tltSlk\n',...
    keyPointsHL2002.lceOpt,...
    keyPointsHL2002.fceOpt,...
    keyPointsHL2002.lceNATZero,...
    keyPointsHL2002.ltSlk);

umat43HL2002TendonParams.fceOpt   = keyPointsHL2002.fceOpt;
umat43HL2002TendonParams.et       = umat43.et;
umat43HL2002TendonParams.ltSlk    = keyPointsHL2002.ltSlk;

%%
%Project experimental key point quantities into the CE and normalize
%%

[falPts, fpePts] = ...
    calcActiveForceLengthWithElasticTendonV2(...
            keyPointsHL2002.fl.l*keyPointsHL2002.nms.l,...
            keyPointsHL2002.fl.fmt*keyPointsHL2002.nms.f,...
            keyPointsHL2002.fl.l*keyPointsHL2002.nms.l,...
            keyPointsHL2002.fl.fpe*keyPointsHL2002.nms.f,...
            keyPointsHL2002.fl.clusters,...
            keyPointsHL2002.lceNATZero*keyPointsHL2002.lceOpt,...
            umat43HL2002TendonParams,...
            tendonForceLengthInverseNormCurve,...
            [],...
            tendonType_0Umat41_1Umat43);

keyPointsHL2002.fl.umat43.lceNAT = falPts.lceAT./keyPointsHL2002.lceOpt;
keyPointsHL2002.fl.umat43.fceNAT = falPts.fceAT./keyPointsHL2002.fceOpt;

%And the passive force-length relation
keyPointsHL2002.fpe.umat43.lceNAT = fpePts.lceAT/keyPointsHL2002.lceOpt;
keyPointsHL2002.fpe.umat43.fceNAT = fpePts.fceAT./keyPointsHL2002.fceOpt;


switch expData
    case 'HL1997'
        umat43.fceOptAT = keyPointsHL1997.fceOpt*cos(umat43.penOpt);
        umat43.lceOptAT = keyPointsHL1997.lceOpt*cos(umat43.penOpt);
        umat43.fceOpt   = keyPointsHL1997.fceOpt;
        umat43.lceOpt   = keyPointsHL1997.lceOpt;   
        umat43.ltSlk    = keyPointsHL1997.ltSlk; 
        umat43.lceNAT0  = keyPointsHL1997.lceNATZero;
        
    case 'HL2002'
        umat43.fceOptAT = keyPointsHL2002.fceOpt*cos(umat43.penOpt);
        umat43.lceOptAT = keyPointsHL2002.lceOpt*cos(umat43.penOpt);
        umat43.fceOpt   = keyPointsHL2002.fceOpt;
        umat43.lceOpt   = keyPointsHL2002.lceOpt; 
        umat43.ltSlk    = keyPointsHL2002.ltSlk;     
        umat43.lceNAT0  = keyPointsHL2002.lceNATZero;
                
    otherwise
        assert(0,'Error: expData must be HL1997 or HL2002')
end


lceNAT = [0.45:0.01:1.8]';
falNAT = zeros(size(lceNAT));
for i=1:1:length(lceNAT)
    fibKin = calcFixedWidthPennatedFiberKinematics(...
                lceNAT(i,1)*umat43.lceOpt,...
                0,...
                umat43.lceOpt,...
                umat43.penOpt);   
    lce     = fibKin.fiberLength;
    alpha   = fibKin.pennationAngle;
    lceN    = lce/umat43.lceOpt;        
    falN    =calcQuadraticBezierYFcnXDerivative(lceN,...
                activeForceLengthCurve,0);
    falNAT(i,1) = falN*cos(alpha);
end
vexatCurves.fl.lceNAT=lceNAT;
vexatCurves.fl.fceNAT=falNAT;
    
if(flag_plotVEXATActiveForceLengthFitting==1)
    figVEXATFalFitting=figure;
    plot(lceNAT,falNAT,'-','Color',[1,1,1].*0.5,'DisplayName','VEXAT');
    hold on;
    plot(keyPointsHL1997.fl.umat43.lceNAT,keyPointsHL1997.fl.umat43.fceNAT,...
        'o','Color',[0,0,0],'DisplayName','HL1997');
    hold on;
    plot(keyPointsHL2002.fl.umat43.lceNAT,keyPointsHL2002.fl.umat43.fceNAT,...
        'x','Color',[0,0,0],'DisplayName','HL2002');
    hold on;    
    box off;

    legend;

    xlabel('Norm. Length ($$\ell / \ell^M_o$$)');
    ylabel('Norm. Force ($$f / f^M_o$$)');
    title('Fitting: Active-force-length relation (VEXAT)');
end








