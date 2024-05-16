$
$--------------------------------------------------------------------------------
$ Activation dynamics code (below) comes from the OpenHBM model and specifically
$ the code of Putra et al. that is released as part of the OpenHBM project under
$ the lgpl3 license.
$  
$ Putra, I P A, Iraeus J, Thomson R, Svensson M Y, Linder A, Sato F. 2019.
$ Comparison of control strategies for the cervical muscles of an average female 
$ head-neck finite element model. Traffic Injury Prevention
$ https://doi.org/10.1080/15389588.2019.1670818
$
$--------------------------------------------------------------------------------
*DEFINE_FUNCTION_TABULATED
28000015
stimFcn
$#                a1                  o1  
                 0.0            &stimLow
          &stimTimeA            &stimLow                 
          &stimTimeS           &stimHigh
          &stimTimeE           &stimHigh
          &stimTimeB            &stimLow          
              &timeE            &stimLow
$--------------------------------------------------------------------------------
$ 6.2.1.1 activation dynamics filter
$--------------------------------------------------------------------------------
$
*DEFINE_FUNCTION
28990210,1ode Ne/Na filter
float ode28990210(float u,float tne,float tna1,float tna2, float tt)
{
float na,ne,t,tts,dt;
dt=tt-tts;
tts=tt;
ne=ne+dt*(u-ne)/tne;
t=tna1;
if(ne<na) t=tna2;
na=na+dt*(ne-na)/t;
return na;
}
$--------------------------------------------------------------------------------
$ Filtered signal (from the viva 50f model)
$--------------------------------------------------------------------------------
$
*DEFINE_CURVE_FUNCTION
28990310
ode28990210(stimFcn(TIME),0.040,0.040,0.080,TIME)
$--------------------------------------------------------------------------------
$ 6.2.1.3 activation signal going to muscle activation
$--------------------------------------------------------------------------------
$
*DEFINE_CURVE_FUNCTION
2899501
MIN(MAX(LC28990310,0.0),1.0)   
*END
