function err = calcScalingError(arg, ...
                    createMusculoTendonFcn, ...
                    curvinessActiveForceLength,...
                    shiftLengthActiveForceLengthCurveDescendingCurve,...
                    flag_compensateForCrossbridgeStiffness,...                    
                    flag_enableNumericallyNonZeroGradients,...
                    smallNumericallyNonZeroValue,...
                    smallNumericallyNonZeroSlope,...
                    flag_useOctave)

scaleOptimalFiberLength      = arg;
scaleMaximumIsometricTension = 1;%arg(2,1);




[musculotendonProperties, ...
 sarcomereProperties,...
 activeForceLengthData,...
 passiveForceLengthData] = ...
    createMusculoTendonFcn(scaleOptimalFiberLength,...
                           scaleMaximumIsometricTension);

assert(isempty(activeForceLengthData)==0);
assert(isempty(passiveForceLengthData)==0);

flag_enableNumericallyNonZeroGradients=1;
shiftLengthActiveForceLengthCurveDescendingCurve = 0.;

activeForceLengthCurve ...
    = createFiberActiveForceLengthCurve(...
          sarcomereProperties.normMyosinHalfLength*2,...
          sarcomereProperties.normMyosinBareHalfLength*2,...
          sarcomereProperties.normActinLength,...
          sarcomereProperties.normZLineLength,...
          sarcomereProperties.normSarcomereLengthZeroForce,...
          sarcomereProperties.normCrossBridgeStiffness,... 
          curvinessActiveForceLength, ...
          shiftLengthActiveForceLengthCurveDescendingCurve,...
          flag_compensateForCrossbridgeStiffness,...
          flag_enableNumericallyNonZeroGradients,...
          smallNumericallyNonZeroValue,...
          smallNumericallyNonZeroSlope,...          
          '',...
          flag_useOctave); 
        
y = zeros(size(activeForceLengthData,1),1);

for i=1:1:size(activeForceLengthData,1)
  y(i,1) = calcBezierYFcnXDerivative( activeForceLengthData(i,1),...
                                      activeForceLengthCurve,0);
end

err = sum( (activeForceLengthData(:,2)-y(:,1)).^2 ,1).*100;
        
        
                          
                          