$
$ Matthew Millard
$
*INCLUDE_PATH_RELATIVE
../../../common/
$
*INCLUDE
catsoleusHL2002Mat156Parameters.k
$
*KEYWORD
*PARAMETER
$#   prmr1      val1     prmr2      val2     prmr3      val3     prmr4      val4
R   dtOut2 0.003
R dtSignal 0.003                                   
R   points 2048.0
*PARAMETER_EXPRESSION
$#    name expression
R     freq 1/&dtSignal
R   fceNom (&fceOptAT)*&stim
R   lceNom &lceOptAT
R  fceNomN &fceNom/&fceOptAT
R  lceNomN &lceNom/&lceOptAT
R pathLenO &lceNom+&ltSlk*(&stim*&et+1.0)
R pathLenN &pathLenO
R    timeE &points/&freq
R      sno &pathLenO/&lceOptAT
R      srm &vceMax*&lceOptAT/(&lceOptAT+&ltSlk)
R  stimLow &stim
R stimHigh &stim 
RstimTimeA 0.01
RstimTimeS 0.02
RstimTimeE &timeE-0.02
RstimTimeB &timeE-0.01

*TITLE
$#                                                                         title
Muskel
*CONTROL_TERMINATION
$#  endtim    endcyc     dtmin    endeng    endmas      
    &timeE         0       0.0       0.01.000000E8
*CONTROL_TIMESTEP
$#  dtinit    tssfac      isdo    tslimt     dt2ms      lctm     erode     ms1st
       0.00.89999998         0       0.0       0.0         5         0         0
$#  dt2msf   dt2mslc     imscl    unused    unused     rmscl     
       0.0         0         0                           0.0
*DEFINE_CURVE
$#    lcid      sidr       sfa       sfo      offa      offo    dattyp     lcint
         5         0       1.0       1.0       0.0       0.0         0         0
$#                a1                  o1  
                 0.0              &dtInt
              &timeE              &dtInt       
$---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8
$                                                                              $
$                             DATABASE (OUTPUT)                                $
$                                                                              $
$---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8
*DATABASE_GLSTAT
$#      dt    binary      lcur     ioopt     
&dtOut2            0         0         1
*DATABASE_MATSUM
$#      dt    binary      lcur     ioopt     
&dtOut2            0         0         1
*DATABASE_NODOUT
$#      dt    binary      lcur     ioopt   option1   option2       
&dtOut2            3         0         1       0.0         0
*DATABASE_SPCFORC
$#      dt    binary      lcur     ioopt     
&dtOut2            0         0         1
*DATABASE_BINARY_D3PLOT
$#      dt      lcdt      beam     npltc    psetid      
&dtOut2            0         0         0         0
$#   ioopt     
         0
*DATABASE_HISTORY_NODE
$#     id1       id2       id3       id4       id5       id6       id7       id8
         2         0         0         0         0         0         0         0
*PART
$#                                                                         title
Beam2
$#     pid     secid       mid     eosid      hgid      grav    adpopt      tmid
         2         1         1         0         0         0         0         0
*SECTION_BEAM
$#   secid    elform      shrf   qr/irid       cst     scoor       nsm   
         1         3       1.0         2         0       0.0       0.0
$#       a     rampt    stress      
       1.0       0.0       0.0
*DATABASE_HISTORY_BEAM
$#     id1       id2       id3       id4       id5       id6       id7       id8
         1         0         0         0         0         0         0         0       
*DATABASE_ELOUT
    &dtOut         2
$#
*DEFINE_CURVE
$#    lcid      sidr       sfa       sfo      offa      offo    dattyp     lcint
         3         0       1.0       1.0       0.0       0.0         0         0
$#                a1                  o1  
                 0.0               &stim
              &timeE               &stim
*ELEMENT_BEAM
$#   eid     pid      n1      n2      n3     rt1     rr1     rt2     rr2   local
       1       2       1       2       0       0       0       0       0       2
*BOUNDARY_PRESCRIBED_MOTION_NODE
$#  typeid       dof       vad      lcid        sf       vid     death     birth
         2         3         2         4       1.0
*NODE
$#   nid               x               y               z      tc      rc
       1             0.0             0.0      -&pathLenN       7       7
       2             0.0             0.0             0.0       7       7
$
*INCLUDE
catsoleusHL2002Mat156.k   
*END
