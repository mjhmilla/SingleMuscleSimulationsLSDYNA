$ ITM Uni Stutgart
$ File: Standard_Functions.k
$ 
$ In this file standard functions often used for LS_Dyna Calculations are defined
$ Ids of the standard functions start with 20000000
$ 
$ Defined so far
$ ID:           Description
$ 20000001      One Function y=1 for x between 0 and 5e6
$ 
$ 20000002      Zero_Function y=0 for x between 0 and 5e6
$ 
$ 20000003      Linear_Function_y_eq_x y=x for x between 0 and 5e6
$ 
$ written by Joerg.Fehr@itm.uni-stuttgart.de
$ 2015-05-07 08:29:55
*DEFINE_CURVE_TITLE
One_Function
$#    lcid      sidr       sfa       sfo      offa      offo    dattyp
  20000001         0  1.000000  1.000000
$#                a1                  o1
               0.000           1.0000000
               5.0e6           1.0000000
*DEFINE_CURVE_TITLE
Zero_Function
$...>....1....>....2....>....3....>....4....>....5....>....6....>....7....>....8
$     LCID      SIDR       SFA       SFO      OFFA      OFFO    DATTYP
  20000002         0         1         1         0         0         0
$                 A1                  O1
                   0                   0                                        
                   2                   0                                        
               5.0e6                   0    
*DEFINE_CURVE_TITLE
Linear_Function_y_eq_x
$...>....1....>....2....>....3....>....4....>....5....>....6....>....7....>....8
$     LCID      SIDR       SFA       SFO      OFFA      OFFO    DATTYP
  20000003         0         1         1         0         0         0
$                 A1                  O1
                   0                   0                                        
                   1                   1                                        
               5.0e6               5.0e6                       
