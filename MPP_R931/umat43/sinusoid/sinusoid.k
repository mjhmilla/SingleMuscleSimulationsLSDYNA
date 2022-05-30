$
$ Matthew Millard
$ 11/01/2022
$
*KEYWORD
*PARAMETER
$#   prmr1      val1     prmr2      val2     prmr3      val3     prmr4      val4
R    dtout      0.01                                     
R   lceOpt 0.0428571
R   fceOpt 21.506061
R   penOpt 0.1221730
R  penOptD 7.0000000 
R    ltSlk 0.0304511
R       et 0.045833
R   vceMax 4.5
R  padTime 0.5
R  sinTime 0.1
$
*PARAMETER_EXPRESSION
$#    name expression
R        b &lceOpt*cos(penOpt)+&ltSlk
R        a (1.0+&strain)*&lceOpt*cos(penOpt)+&ltSlk-&bias 
R    timeE &padTime*2+&sinTime
$
*TITLE
$#                                                                         title
Muskel
*CONTROL_TERMINATION
$#  endtim    endcyc     dtmin    endeng    endmas      
    &timeE         0       0.0       0.01.000000E8
*CONTROL_TIMESTEP
$#  dtinit    tssfac      isdo    tslimt     dt2ms      lctm     erode     ms1st
       0.00.89999998         0       0.0       0.0         0         0         0
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
            0.000000      0.000000*&a+&b
            0.500000      0.000000*&a+&b
            0.501000      0.062791*&a+&b
            0.502000      0.125333*&a+&b
            0.503000      0.187381*&a+&b
            0.504000      0.248690*&a+&b
            0.505000      0.309017*&a+&b
            0.506000      0.368125*&a+&b
            0.507000      0.425779*&a+&b
            0.508000      0.481754*&a+&b
            0.509000      0.535827*&a+&b
            0.510000      0.587785*&a+&b
            0.511000      0.637424*&a+&b
            0.512000      0.684547*&a+&b
            0.513000      0.728969*&a+&b
            0.514000      0.770513*&a+&b
            0.515000      0.809017*&a+&b
            0.516000      0.844328*&a+&b
            0.517000      0.876307*&a+&b
            0.518000      0.904827*&a+&b
            0.519000      0.929776*&a+&b
            0.520000      0.951057*&a+&b
            0.521000      0.968583*&a+&b
            0.522000      0.982287*&a+&b
            0.523000      0.992115*&a+&b
            0.524000      0.998027*&a+&b
            0.525000      1.000000*&a+&b
            0.526000      0.998027*&a+&b
            0.527000      0.992115*&a+&b
            0.528000      0.982287*&a+&b
            0.529000      0.968583*&a+&b
            0.530000      0.951057*&a+&b
            0.531000      0.929776*&a+&b
            0.532000      0.904827*&a+&b
            0.533000      0.876307*&a+&b
            0.534000      0.844328*&a+&b
            0.535000      0.809017*&a+&b
            0.536000      0.770513*&a+&b
            0.537000      0.728969*&a+&b
            0.538000      0.684547*&a+&b
            0.539000      0.637424*&a+&b
            0.540000      0.587785*&a+&b
            0.541000      0.535827*&a+&b
            0.542000      0.481754*&a+&b
            0.543000      0.425779*&a+&b
            0.544000      0.368125*&a+&b
            0.545000      0.309017*&a+&b
            0.546000      0.248690*&a+&b
            0.547000      0.187381*&a+&b
            0.548000      0.125333*&a+&b
            0.549000      0.062791*&a+&b
            0.550000     -0.000000*&a+&b
            0.551000     -0.062791*&a+&b
            0.552000     -0.125333*&a+&b
            0.553000     -0.187381*&a+&b
            0.554000     -0.248690*&a+&b
            0.555000     -0.309017*&a+&b
            0.556000     -0.368125*&a+&b
            0.557000     -0.425779*&a+&b
            0.558000     -0.481754*&a+&b
            0.559000     -0.535827*&a+&b
            0.560000     -0.587785*&a+&b
            0.561000     -0.637424*&a+&b
            0.562000     -0.684547*&a+&b
            0.563000     -0.728969*&a+&b
            0.564000     -0.770513*&a+&b
            0.565000     -0.809017*&a+&b
            0.566000     -0.844328*&a+&b
            0.567000     -0.876307*&a+&b
            0.568000     -0.904827*&a+&b
            0.569000     -0.929776*&a+&b
            0.570000     -0.951057*&a+&b
            0.571000     -0.968583*&a+&b
            0.572000     -0.982287*&a+&b
            0.573000     -0.992115*&a+&b
            0.574000     -0.998027*&a+&b
            0.575000     -1.000000*&a+&b
            0.576000     -0.998027*&a+&b
            0.577000     -0.992115*&a+&b
            0.578000     -0.982287*&a+&b
            0.579000     -0.968583*&a+&b
            0.580000     -0.951057*&a+&b
            0.581000     -0.929776*&a+&b
            0.582000     -0.904827*&a+&b
            0.583000     -0.876307*&a+&b
            0.584000     -0.844328*&a+&b
            0.585000     -0.809017*&a+&b
            0.586000     -0.770513*&a+&b
            0.587000     -0.728969*&a+&b
            0.588000     -0.684547*&a+&b
            0.589000     -0.637424*&a+&b
            0.590000     -0.587785*&a+&b
            0.591000     -0.535827*&a+&b
            0.592000     -0.481754*&a+&b
            0.593000     -0.425779*&a+&b
            0.594000     -0.368125*&a+&b
            0.595000     -0.309017*&a+&b
            0.596000     -0.248690*&a+&b
            0.597000     -0.187381*&a+&b
            0.598000     -0.125333*&a+&b
            0.599000     -0.062791*&a+&b
            0.600000     -0.000000*&a+&b
            0.601000      0.000000*&a+&b
            1.100000      0.000000*&a+&b

$
*NODE
$#   nid               x               y               z      tc      rc
       1             0.0             0.0             0.0       7       7
       2             0.0             0.0             -&b       7       7
*END
