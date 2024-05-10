*KEYWORD
*MAT_USER_DEFINED_MATERIAL_MODELS
$ Hill-type Muscle
$#     mid        ro        mt       lmc       nhv    iortho     ibulk        ig
         1       1.0        41        32        50         0         3         4
$#   ivect     ifail    itherm    ihyper      ieos      lmca    unused    unused
         0         0         0         0         0         0                    
$#  ActOpt   STIM_ID        q0    tauq/c betaq/eta         k         m
         1        -3    1.0E-4     0.025       0.5                
$#    Fmax    lCEopt     dWdes   nuCEdes     dWasc   nuCEasc     Arel0     Brel0      
 &fceOptAT &lceOptAT    &dWdes  &nuCEdes    &dWasc  &nuCEasc     &Arel     &Brel
$#    Secc      Fecc     LPEE0     nuPEE      FPEE     lSEE0  dUSEEnll    duSEEl
     &Secc     &Fecc    &LPEE0    &nuPEE     &FPEE    &ltSlk &dUSEEnll   &duSEEl
$#  dFSEE0   Damping    Param1    Param2    Output     dtOut
   &dFSEE0       3.0       0.3      0.01         2    &dtOut    
$#
*END
