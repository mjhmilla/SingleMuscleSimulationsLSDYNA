function success = writeAllLSDYNAMuscleParameterFiles(...
                        commonParameterFolder,expAbbrv,...
                        mat156,umat41,umat43)

mat156ParameterFile = fullfile(commonParameterFolder,...
                      ['catsoleus',expAbbrv,'Mat156Parameters.k']);

umat41ParameterFile = fullfile(commonParameterFolder,...
                      ['catsoleus',expAbbrv,'Umat41Parameters.k']);

umat43ParameterFile = fullfile(commonParameterFolder,...
                      ['catsoleus',expAbbrv,'Umat43Parameters.k']);



success156  = writeLSDYNAMuscleParameterFile(mat156ParameterFile,...
                                             mat156,mat156.extraLines);
success41   = writeLSDYNAMuscleParameterFile(umat41ParameterFile,...
                                             umat41,umat41.extraLines);
success43   = writeLSDYNAMuscleParameterFile(umat43ParameterFile,...
                                             umat43,umat43.extraLines);

success = (success156 && success41 && success43);






