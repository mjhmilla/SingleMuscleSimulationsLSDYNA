    if(flag_subMax == 0)
        cd(fullfile('..','isometric_max'));
        
        [binoutIsometric,status] = ...
            binoutreader('dynaOutputFile','binout0000',...
                            'ignoreUnknownDataError',true);
        timeSampleExcitation1 = getParameterValueFromD3HSPFile('d3hsp', 'TIMES1'); 
    
        switch lsdynaMuscleUniform.name
            case 'umat41'
                [musout,success] = ...
                    readUmat41MusoutData('musout.0000000002');  
            case 'umat43'
                [musout,success] = ...
                    readUmat43MusoutData('musout.0000000002');             
            case 'viva'
                musout=[];
            case 'mat156'
                musout=[];
            otherwise assert(0)
        end
    
        cd(currDir);    
    else
        cd(fullfile('..','isometric_sub_max'));
        [binoutIsometric,status] = ...
            binoutreader('dynaOutputFile','binout0000',...
                            'ignoreUnknownDataError',true);
        timeSampleExcitation1 = getParameterValueFromD3HSPFile('d3hsp', 'TIMES1');  
        switch lsdynaMuscleUniform.name
            case 'umat41'
                [musout,success] = ...
                    readUmat41MusoutData('musout.0000000002');  
            case 'umat43'
                [musout,success] = ...
                    readUmat43MusoutData('musout.0000000002');             
            case 'viva'
                musout=[];
            case 'mat156'
                musout=[];
            otherwise assert(0)
        end    
        cd(currDir);        
    end
    
    switch lsdynaMuscleUniform.name
        case 'umat41'
            lceNSample = musout.data(end,musout.indexLce)./optimalFiberLength; 
        case 'umat43'
            lceNSample = musout.data(end,musout.indexLceN);           
        case 'viva'
            lceNSample = -binoutIsometric.nodout.z_coordinate(idxActiveSample,1)...
                            /optimalFiberLength;
        case 'mat156'
            lceNSample = -binoutIsometric.nodout.z_coordinate(idxActiveSample,1)...
                            /optimalFiberLength;
            
        otherwise assert(0)
    end 

