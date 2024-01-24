*KEYWORD
*PARAMETER
$#   prmr1      val1     prmr2      val2     prmr3      val3     prmr4      val4
R    dtout      0.01                                     
R   lceOpt 0.0428571
R   fceOpt 21.612138
R lceOptAT 0.0425376
R fceOptAT 21.451044
R lmtOptAT 0.0729888
R   penOpt 0.122173047639603
R  penOptD 7.0 
R    ltSlk 0.0304511
R       et 0.0458333
R   vceMax 4.50
*PARAMETER_EXPRESSION
$#    name expression
R      sno &pathLen0/(&lceOptAT+&ltSlk)
R      srm &vceMax*&lceOptAT/(&lceOptAT+&ltSlk)

