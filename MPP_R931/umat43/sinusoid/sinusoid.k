$
$ Matthew Millard
$ 30/05/2022
$
*KEYWORD
*PARAMETER
$#   prmr1      val1     prmr2      val2     prmr3      val3     prmr4      val4
R    dtout     0.001                                     
R   lceOpt 0.0428571
R   fceOpt 21.506061
R   penOpt 0.1221730
R  penOptD 7.0000000 
R    ltSlk 0.0304511
R       et 0.045833
R   vceMax 4.5
R       tp 0.0
R       ts 1.0
$
*PARAMETER_EXPRESSION
$#    name expression
R        a (&mstr)*(&lceOpt)*cos(&penOpt) 
R        b (&lceOpt*(1.-&mstr))*cos(&penOpt)+&ltSlk
R    timeE (&tp)*2.0+&ts
$
*TITLE
$#                                                                         title
Muskel
*CONTROL_TERMINATION
$#  endtim    endcyc     dtmin    endeng    endmas      
    &timeE         0       0.0       0.01.000000E8
*CONTROL_TIMESTEP
$#  dtinit    tssfac      isdo    tslimt     dt2ms      lctm     erode     ms1st
       0.00.89999998         0       0.0       0.0         9         0         0
$#  dt2msf   dt2mslc     imscl    unused    unused     rmscl     
       0.0         0         0                           0.0
$---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8
$                                                                              $
$                             DATABASE (OUTPUT)                                $
$                                                                              $
$---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8
*DATABASE_GLSTAT
$#      dt    binary      lcur     ioopt     
&dtout             0         0         1
*DATABASE_MATSUM
$#      dt    binary      lcur     ioopt     
&dtout             0         0         1
*DATABASE_NODOUT
$#      dt    binary      lcur     ioopt   option1   option2       
&dtout             3         0         1       0.0         0
*DATABASE_SPCFORC
$#      dt    binary      lcur     ioopt     
&dtout             0         0         1
*DATABASE_BINARY_D3PLOT
$#      dt      lcdt      beam     npltc    psetid      
    &dtout         0         0         0         0
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
    &dtout         2
$#
*INCLUDE
catsoleus.k
*DEFINE_CURVE
$#    lcid      sidr       sfa       sfo      offa      offo    dattyp
         9         0  1.000000  1.000000     0.000     0.000         0
$#                a1                  o1
            0.000000               0.001
              &timeE               0.001
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
*DEFINE_CURVE
$#    lcid      sidr       sfa       sfo      offa      offo    dattyp
         4         0       1.0       1.0       0.0       0.0
$#                a1                  o1
    0.000000             &a*0.000000+&b
    &ts*0.010000+&tp     &a*-0.001973+&b
    &ts*0.020000+&tp     &a*-0.007885+&b
    &ts*0.030000+&tp     &a*-0.017713+&b
    &ts*0.040000+&tp     &a*-0.031417+&b
    &ts*0.050000+&tp     &a*-0.048943+&b
    &ts*0.060000+&tp     &a*-0.070224+&b
    &ts*0.070000+&tp     &a*-0.095173+&b
    &ts*0.080000+&tp     &a*-0.123693+&b
    &ts*0.090000+&tp     &a*-0.155672+&b
    &ts*0.100000+&tp     &a*-0.190983+&b
    &ts*0.110000+&tp     &a*-0.229487+&b
    &ts*0.120000+&tp     &a*-0.271031+&b
    &ts*0.130000+&tp     &a*-0.315453+&b
    &ts*0.140000+&tp     &a*-0.362576+&b
    &ts*0.150000+&tp     &a*-0.412215+&b
    &ts*0.160000+&tp     &a*-0.464173+&b
    &ts*0.170000+&tp     &a*-0.518246+&b
    &ts*0.180000+&tp     &a*-0.574221+&b
    &ts*0.190000+&tp     &a*-0.631875+&b
    &ts*0.200000+&tp     &a*-0.690983+&b
    &ts*0.210000+&tp     &a*-0.751310+&b
    &ts*0.220000+&tp     &a*-0.812619+&b
    &ts*0.230000+&tp     &a*-0.874667+&b
    &ts*0.240000+&tp     &a*-0.937209+&b
    &ts*0.250000+&tp     &a*-1.000000+&b
    &ts*0.260000+&tp     &a*-1.062791+&b
    &ts*0.270000+&tp     &a*-1.125333+&b
    &ts*0.280000+&tp     &a*-1.187381+&b
    &ts*0.290000+&tp     &a*-1.248690+&b
    &ts*0.300000+&tp     &a*-1.309017+&b
    &ts*0.310000+&tp     &a*-1.368125+&b
    &ts*0.320000+&tp     &a*-1.425779+&b
    &ts*0.330000+&tp     &a*-1.481754+&b
    &ts*0.340000+&tp     &a*-1.535827+&b
    &ts*0.350000+&tp     &a*-1.587785+&b
    &ts*0.360000+&tp     &a*-1.637424+&b
    &ts*0.370000+&tp     &a*-1.684547+&b
    &ts*0.380000+&tp     &a*-1.728969+&b
    &ts*0.390000+&tp     &a*-1.770513+&b
    &ts*0.400000+&tp     &a*-1.809017+&b
    &ts*0.410000+&tp     &a*-1.844328+&b
    &ts*0.420000+&tp     &a*-1.876307+&b
    &ts*0.430000+&tp     &a*-1.904827+&b
    &ts*0.440000+&tp     &a*-1.929776+&b
    &ts*0.450000+&tp     &a*-1.951057+&b
    &ts*0.460000+&tp     &a*-1.968583+&b
    &ts*0.470000+&tp     &a*-1.982287+&b
    &ts*0.480000+&tp     &a*-1.992115+&b
    &ts*0.490000+&tp     &a*-1.998027+&b
    &ts*0.500000+&tp     &a*-2.000000+&b
    &ts*0.510000+&tp     &a*-1.998027+&b
    &ts*0.520000+&tp     &a*-1.992115+&b
    &ts*0.530000+&tp     &a*-1.982287+&b
    &ts*0.540000+&tp     &a*-1.968583+&b
    &ts*0.550000+&tp     &a*-1.951057+&b
    &ts*0.560000+&tp     &a*-1.929776+&b
    &ts*0.570000+&tp     &a*-1.904827+&b
    &ts*0.580000+&tp     &a*-1.876307+&b
    &ts*0.590000+&tp     &a*-1.844328+&b
    &ts*0.600000+&tp     &a*-1.809017+&b
    &ts*0.610000+&tp     &a*-1.770513+&b
    &ts*0.620000+&tp     &a*-1.728969+&b
    &ts*0.630000+&tp     &a*-1.684547+&b
    &ts*0.640000+&tp     &a*-1.637424+&b
    &ts*0.650000+&tp     &a*-1.587785+&b
    &ts*0.660000+&tp     &a*-1.535827+&b
    &ts*0.670000+&tp     &a*-1.481754+&b
    &ts*0.680000+&tp     &a*-1.425779+&b
    &ts*0.690000+&tp     &a*-1.368125+&b
    &ts*0.700000+&tp     &a*-1.309017+&b
    &ts*0.710000+&tp     &a*-1.248690+&b
    &ts*0.720000+&tp     &a*-1.187381+&b
    &ts*0.730000+&tp     &a*-1.125333+&b
    &ts*0.740000+&tp     &a*-1.062791+&b
    &ts*0.750000+&tp     &a*-1.000000+&b
    &ts*0.760000+&tp     &a*-0.937209+&b
    &ts*0.770000+&tp     &a*-0.874667+&b
    &ts*0.780000+&tp     &a*-0.812619+&b
    &ts*0.790000+&tp     &a*-0.751310+&b
    &ts*0.800000+&tp     &a*-0.690983+&b
    &ts*0.810000+&tp     &a*-0.631875+&b
    &ts*0.820000+&tp     &a*-0.574221+&b
    &ts*0.830000+&tp     &a*-0.518246+&b
    &ts*0.840000+&tp     &a*-0.464173+&b
    &ts*0.850000+&tp     &a*-0.412215+&b
    &ts*0.860000+&tp     &a*-0.362576+&b
    &ts*0.870000+&tp     &a*-0.315453+&b
    &ts*0.880000+&tp     &a*-0.271031+&b
    &ts*0.890000+&tp     &a*-0.229487+&b
    &ts*0.900000+&tp     &a*-0.190983+&b
    &ts*0.910000+&tp     &a*-0.155672+&b
    &ts*0.920000+&tp     &a*-0.123693+&b
    &ts*0.930000+&tp     &a*-0.095173+&b
    &ts*0.940000+&tp     &a*-0.070224+&b
    &ts*0.950000+&tp     &a*-0.048943+&b
    &ts*0.960000+&tp     &a*-0.031417+&b
    &ts*0.970000+&tp     &a*-0.017713+&b
    &ts*0.980000+&tp     &a*-0.007885+&b
    &ts*0.990000+&tp     &a*-0.001973+&b
    &ts*1.000000+&tp      &a*0.000000+&b
$#        &tp*0.000000      &a*0.000000+&b
$#        &tp*1.000000      &a*0.000000+&b    
$#      &ts+&tp*1.0100      &a*0.000000+&b
$#      &ts+&tp*2.0000      &a*0.000000+&b
$
*NODE
$#   nid               x               y               z      tc      rc
       1             0.0             0.0             0.0       7       7
       2             0.0             0.0             -&b       7       7
*END
