$# LS-DYNA Keyword file created by LS-PrePost 4.1 - 01Mar2014(10:00)
$# Created on Jul-22-2014 (09:47:10)
$ 
$      Calculation in mm, kg, ms, mN
$ 
$ written by Joerg.Fehr@itm.uni-stuttgart.de
$ 2016-02-10 12:09:42
$ 
$ 
*KEYWORD
$===============================================================================
$ Setup the Simulation by Defining the Parameters 
$===============================================================================
$----------------------------------------------
*PARAMETER 
$ R in_vel  3.0        
$ R t_fin   2.000000  
$ R dt_bi   1.00000  
$ R dt_d3   10.00000  
$ R f_sca   1.0E3
$ Initiale Geschwindigkeit
R in_vel  0.0        
$ Simulationtime
R t_fin     5.e-4  
$ Output \delta t in binout file
R dt_bi   1.e-4  
$ Output \delta t in d3 plot
R dt_d3   0.00100  
$ Scalefactor for Force
R f_sca   1.0E3
$ Scaling factor for Lagrange Multiplier
R t_sfs   0.1
$ Scaling factor for Lagrange Multiplier
I nr_modes10
I eb_form 0
$ Damping Parameter
R dampf   0.001
$ Damping of connection parameter
R rho_con 1e3
$ Stiffness of connection parameter
R k_con   10E3
$ Damping of connection parameter
R d_con   50
$ time delays
R t_act   20e-3
R t_deact 60e-3
R dt      1.0E-04
$----------------------------------------------
*TITLE
$# title
Test Sensor Definitions
*INCLUDE
Calculation_Setup_v2.k
*CONTROL_TERMINATION
$#  endtim    endcyc     dtmin    endeng    endmas    
&t_fin             0      1e-1     0.000     0.000
$...>....1....>....2....>....3....>....4....>....5....>....6....>....7....>....8
*CONTROL_SOLUTION
$...>....1....>....2....>....3....>....4....>....5....>....6....>....7....>....8
$     SOLN       NLQ     ISNAN     LCINT
         0         0         1         0
$----------------------------------------------
$===============================================================================
$# Nodal Section written by dyna_write_nodes.m at 10-Feb-2016
*NODE
$   node               x               y               z      tc      rc
       1+0.000000000E+00+0.000000000E+00+0.000000000E+00
       2+0.000000000E+00+0.000000000E+00+0.000000000E+00
       3+0.000000000E+00+0.000000000E+00+0.000000000E+00
       4+0.000000000E+00+0.000000000E+00+0.000000000E+00
       5+0.000000000E+00+0.000000000E+00+0.000000000E+00
       6+0.000000000E+00+0.000000000E+00+0.000000000E+00
       7+0.000000000E+00+0.000000000E+00+0.000000000E+00
       8+0.000000000E+00+0.000000000E+00+0.000000000E+00
       9+0.000000000E+00+0.000000000E+00+0.000000000E+00
      10+0.000000000E+00+0.000000000E+00+0.000000000E+00
      11+0.000000000E+00+0.000000000E+00+0.000000000E+00
     100+0.000000000E+00+0.000000000E+00+0.000000000E+00
$===============================================================================
*ELEMENT_MASS
$    eid      id            mass      n2      n3      n4      n5      n6      n7      n8
      11      11             1.0
$    
*DEFINE_CURVE_FUNCTION
$   u
$#    lcid      sidr       sfa       sfo      offa      offo    dattyp
         1         0  1.000000  1.000000     0.000     0.000         0
$# function
LC100
*DEFINE_CURVE_FUNCTION
$t
$#    lcid      sidr       sfa       sfo      offa      offo    dattyp
         2         0  1.000000  1.000000     0.000     0.000         0
$# function
SENSORD(2)
*SENSOR_DEFINE_MISC
$CURRENT TIME 
$#  sensid     MTYPE       
         2      TIME
*DEFINE_CURVE_FUNCTION
$ kp=ucont/error
$#    lcid      sidr       sfa       sfo      offa      offo    dattyp
         3         0  1.000000  1.000000     0.000     0.000         0
$# function
LC6/LC11
*DEFINE_CURVE_FUNCTION
$ u - a
$#    lcid      sidr       sfa       sfo      offa      offo    dattyp
         4         0  1.000000  1.000000     0.000     0.000         0
$# function
LC100-DELAY(LC6,-1,0) 
$ *DEFINE_CURVE_FUNCTION
$ $ Define a
$ $#    lcid      sidr       sfa       sfo      offa      offo    dattyp
$          5         0  1.000000  1.000000     0.000     0.000         0
$ $# function
$ 1*LC11
*DEFINE_CURVE_FUNCTION
$  USE PID Controller to dadt
$#    lcid      sidr       sfa       sfo      offa      offo    dattyp
         5         0  1.000000  1.000000     0.000     0.000         0
$PIDCTL(meas,  lref, kp,  ki, kd,   tf,  ei0, sint, umin, umax)
1
$PIDCTL(lfeed, ref, lref, kp, lkp, ki,     lki, kd, lkd,tf, ltf, ei0)
*DEFINE_CURVE_FUNCTION
$  USE PID Controller to calculate e
$#    lcid      sidr       sfa       sfo      offa      offo    dattyp
         6         0  1.000000  1.000000     0.000     0.000         0
$PIDCTL(meas,  lref, kp,  ki, kd,    tf,  ei0, sint, umin, umax)
PIDCTL(LC11,  0.0,  LC16,  1,   , 0.005,    0, 0.0, -1000, 1000)

$PIDCTL(lfeed, ref, lref, kp, lkp, ki,     lki, kd, lkd,tf, ltf, ei0)
$ PIDCTL(11   ,  0.0,  0,  1,    13,  1,       0,  0,   0,0.005,0,0.0)
$ Syntax for newest LS-Dyna Version
$ PIDCTL(LC11 ,   0.0,  1,   0,  1, 0.001,   0, 0.001, -10000,10000)
*DEFINE_CURVE_FUNCTION
$IF u-a > 0
$#    lcid      sidr       sfa       sfo      offa      offo    dattyp
         7         0  1.000000  1.000000     0.000     0.000         0
$# function
&t_act*(0.5+1.5*LC6)
*DEFINE_CURVE_FUNCTION
$IF u-a<= 0
$#    lcid      sidr       sfa       sfo      offa      offo    dattyp
         8         0  1.000000  1.000000     0.000     0.000         0
$# function
&t_deact/(0.5+1.5*LC6)
*DEFINE_CURVE_FUNCTION
$da/dt
$#    lcid      sidr       sfa       sfo      offa      offo    dattyp
        09         0  1.000000  1.000000     0.000     0.000         0
$# function
LC4/LC7
*DEFINE_CURVE_FUNCTION
$da/dt
$#    lcid      sidr       sfa       sfo      offa      offo    dattyp
        10         0  1.000000  1.000000     0.000     0.000         0
$# function
LC4/LC8
$ 1
*DEFINE_CURVE_FUNCTION
$IF Abfrage Tau
$#    lcid      sidr       sfa       sfo      offa      offo    dattyp
        11         0  1.000000  1.000000     0.000     0.000         0
$# function
IF(LC1-LC6 ,LC10,LC10,LC9)
*DEFINE_CURVE_FUNCTION
$  USE PID Controller p onnly ucont
$#    lcid      sidr       sfa       sfo      offa      offo    dattyp
        12         0  1.000000  1.000000     0.000     0.000         0
$PIDCTL(meas,  lref, kp,  ki, kd,   tf,  ei0, sint, umin, umax)
PIDCTL(LC11,  0.0,  LC16, 0,   , 0.005,    0, 0.0, -1000, 1000)
$PIDCTL(lfeed, ref, lref, kp, lkp, ki,     lki, kd, lkd,tf, ltf, ei0)
*DEFINE_CURVE_FUNCTION
$ Initialization
$#    lcid      sidr       sfa       sfo      offa      offo    dattyp
        13         0  1.000000  1.000000     0.000     0.000         0
$# function
DELAY(3, -2, &t_act*(0.5+1.5*LC6))
$ 
*DEFINE_CURVE_FUNCTION
$ Initialization
$#    lcid      sidr       sfa       sfo      offa      offo    dattyp
        14         0  1.000000  1.000000     0.000     0.000         0
$# function
IF(LC2, LC11, LC11,LC3)
*DEFINE_CURVE_FUNCTION
$ One Function
$#    lcid      sidr       sfa       sfo      offa      offo    dattyp
        15         0  1.000000  1.000000     0.000     0.000         0
$# function
1.0
*DEFINE_CURVE_FUNCTION
$ One Function
$#    lcid      sidr       sfa       sfo      offa      offo    dattyp
        16         0  1.000000  1.000000     0.000     0.000         0
$# function
IF(LC11,LC3,LC15,LC3)
*DEFINE_CURVE
$#    lcid      sidr       sfa       sfo      offa      offo    dattyp    
       100         0         1         10.0000e+000.0000e+00         0
$#                a1                  o1    
0.0000000000000e+00  1
2.0000000000000e-01  1
2.0000000000001e-01  0
3.0000000000000e-01  0
$ # Define a Curve Function
$ *DEFINE_CURVE_FUNCTION
$ $a(t-1)
$ $#    lcid      sidr       sfa       sfo      offa      offo    dattyp
$          3         0  1.000000  1.000000     0.000     0.000         0
$ $# function
$ CX(1)
$ *DEFINE_CURVE_FUNCTION
$ $a(t-1)
$ $#    lcid      sidr       sfa       sfo      offa      offo    dattyp
$        100         0  1.000000  1.000000     0.000     0.000         0
$ $# function
$ CX(1)
$ $
$ *DEFINE_CURVE_FUNCTION
$ $ IF Function
$ $#    lcid      sidr       sfa       sfo      offa      offo    dattyp
$          4         0  1.000000  1.000000     0.000     0.000         0
$ $# function
$ IF(4,5,5,6)
$ *DEFINE_CURVE_FUNCTION
$ $ IF Function
$ $#    lcid      sidr       sfa       sfo      offa      offo    dattyp
$          4         0  1.000000  1.000000     0.000     0.000         0
$ $# function
$ IF(4,5,4,6)
*BOUNDARY_PRESCRIBED_MOTION_NODE_ID
$#      id                                                               heading
         1 U
$#     nid       dof       vad      lcid        sf       vid     death     birth
         1         1         2         1  1.000000         0     0.000     0.000
$ *BOUNDARY_PRESCRIBED_MOTION_NODE_ID
$ $#      id                                                               heading
$          2 Current Time
$ $...>....1....>....2....>....3....>....4....>....5....>....6....>....7....>....8
$ $#     nid       dof       vad      lcid        sf       vid     death     birth
$          2         1         2         2  1.000000         0     0.000     0.000
$ *BOUNDARY_PRESCRIBED_MOTION_NODE_ID
$ $#      id                                                               heading
$          3 DT
$ $...>....1....>....2....>....3....>....4....>....5....>....6....>....7....>....8
$ $#     nid       dof       vad      lcid        sf       vid     death     birth
$          3         1         2         3  1.000000         0     0.000     0.000         
$ *BOUNDARY_PRESCRIBED_MOTION_NODE_ID
$ $#      id                                                               heading
$          3 DT
$ $...>....1....>....2....>....3....>....4....>....5....>....6....>....7....>....8
$ $#     nid       dof       vad      lcid        sf       vid     death     birth
$          3         1         2         3  1.000000         0     0.000     0.000         
*BOUNDARY_PRESCRIBED_MOTION_NODE_ID
$#      id                                                               heading
       100Motion_u
$...>....1....>....2....>....3....>....4....>....5....>....6....>....7....>....8
$#     nid       dof       vad      lcid        sf       vid     death     birth
       100         1         2       100  1.000000         0     0.000     0.000 
*END