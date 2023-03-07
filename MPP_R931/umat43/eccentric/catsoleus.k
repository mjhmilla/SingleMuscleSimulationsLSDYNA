*KEYWORD
*MAT_USER_DEFINED_MATERIAL_MODELS
$ Millard 2022 Muscle
$#     mid        ro        mt       lmc       nhv    iortho     ibulk        ig
         11.00000E-6        43        32      1000         0         3         4
$#   ivect     ifail    itherm    ihyper      ieos      lmca    unused    unused
         0         0         0         0         0         0                    
$#  stimId exDefault    tauAct  tauDeact fceOptIso    lceOpt alphaOptD useRgdTdn
         3       0.0     0.010     0.040   &fceOpt   &lceOpt  &penOptD         0
$#   ltSlk     etIso       dtN  scalePEE lambdaECM  lPevkPtN lceHNLb1A   act1AHN
    &ltSlk     0.049    0.0556      1.66      0.56       0.5      0.45       0.1
$#beta1AHN  beta1PHN kxOptIsoN dxOptIsoN gainTrack  actTrack    vceMax   taudvst
      45.0      0.25      47.8     0.354    1000.0      0.05   &vceMax     0.001
$# dvsBeta    dtNumN   aniType  ctrlType ctrlDelay ctrlThrsh    output     dtout    
       1.0    0.0001         1         1     0.025     0.075         2     0.001   
*END
