*KEYWORD
*MAT_USER_DEFINED_MATERIAL_MODELS
$ Hill-type Muscle
$#     mid        ro        mt       lmc       nhv    iortho     ibulk        ig
         11.00000E-6        41        32        50         0         3         4
$#   ivect     ifail    itherm    ihyper      ieos      lmca    unused    unused
         0         1         0         0         0         0
$#  ActOpt   STIM_ID        q0    tauq/c betaq/eta         k         m   lOffset
         1         3      &q0S     &tauA     &tauD                                                            
$#    Fmax    lCEopt     dWdes   nuCEdes     dWasc   nuCEasc     Arel0     Brel0
   &fceOpt   &lceOpt      0.39       1.5      0.39         3       0.5     0.005
$#    Secc      Fecc     LPEE0     nuPEE      FPEE     lSEE0  dUSEEnll    duSEEl
         2       1.5      0.95       2.5         2    &ltSlk    &dUSEE     0.017
$#  dFSEE0                Dsde      Rsde    Output     dtOut
    0.0248                 0.3      0.01       2.0       100
*END
