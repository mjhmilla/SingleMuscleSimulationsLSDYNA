%%
% SPDX-FileCopyrightText: 2024 Institute of Engineering and Computational Mechanics
%
% SPDX-License-Identifier: MIT
%
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Syntax
%  ======
%  [output status]= binoutreader('Property',value,...)
%
%  reads all kind of information from the elout, nodout, secforc, matsum,
%  curvout, glstat and rwforc section of the binout file
%
%
%  Input Arguments
%  ===============
%
%   Input arguments have to be given in parameter-value pairs
%
%   Obligatory parameters
%   ---------------------
%       -'dynaOutputFile':  The binout file of the Dyna simulation, which is
%                           going to be read.
%
%   Optional parameters
%   -------------------
%       -'verbose'                  :   print all notifications
%           (Default: false)
%       -'ignoreUnknownDataError'   :   ignores unknown data and print
%           (Default: false)            warning instead (if in verbose mode)
%       -'ncforc'                   :   define which contactdata will be
%           (Default: '-xzxzNoImport')  imported, (i.e. if 'slave_' all slave
%                                       contact data is imported)
%       -'characterEncoding'        :   characterEncoding as needed for fopen
%                                       default: 'ISO-8859-1'
%           
%
%
%  -----------------------------------------------------------------------
%
% If the binout is built up of many files, you have to use the
% first file 'binout%001' as inputfile, the rest will be loaded automatically.
% The numbering of the parts have to be without gaps
% (binout,binout%001,binout%002,binout%003,...,binout%009(maximum))
%
%
% For Cluster-Binout files (like binout0000, binout0005,...):
% The nodout information is saved in one of the binout files. Therefore some files
% can be 'empty'. You have to load the files severally.
%
% If the Cluster-Binout file is splitted (like
% binout0001,binout0001%001,..) you have to load only the first file
% 'binout0001' like the normal splitted binout files.
%
%  Output Arguments
%  ===============
%  output: structure with
%     'elout'
%     'eloutdet'
%     'nodout'
%     'secforc'
%     'matsum'
%     'curvout'
%     'glstat'
%     'rbdout'
%     'rwforc'
%     'nodfor'
%     'sbtout'
%     'deforc'
%     'abstat_cpm'
%     'ncforc'
%
%  output for eloutdet is refactored, so it looks like thie:
%         eloutdet.elementtype
%         |---title
%         |---version
%         |---...
%         |---elem
%         |---|---elem1
%         |---|---|---nqt
%         |---|---|---|---yield 
%         |---|---|---|---effsg 
%         |---|---|---|---sig_xx 
%         |---|---|---|---... 
%         |---|---|---|---eps_zz 
%         |---|---|---nip
%         |---|---|---|---yield 
%         |---|---|---|---effsg 
%         |---|---|---|---sig_xx 
%         |---|---|---|---... 
%         |---|---|---|---eps_zz 
%         |---|---|... 
%         |---|---elemX
%         |---|---|---nqt
%         |---|---|---|---yield 
%         |---|---|---|---effsg 
%         |---|---|---|---sig_xx 
%         |---|---|---|---... 
%         |---|---|---|---eps_zz 
%         |---|---|---nip
%         |---|---|---|---yield 
%         |---|---|---|---effsg 
%         |---|---|---|---sig_xx 
%         |---|---|---|---... 
%         |---|---|---|---eps_zz 
%
% -!- Destroyed Elements are represented by NaN-Entries -!-
%
% Example
% ----------------------
% [output status] = binoutreader('dynaOutputFile', fullfile('/scratch/','binout'));
% [output status] = binoutreader('dynaOutputFile', fullfile('/scratch/','binout'),'ncforc','slave_99995752');
%
% Example how to plot x acceleration of the second node
% ------------------------------------------------------
% plot(output.nodout.time,output.nodout.x_acceleration(:,2));
%
%
% References:
% ----------------------
% [Livermore Software Data Archival] file_format
% [Livermore Software Data Archival] binascii.txt
%
% See first version of git repo for original authors.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Memory Management:
% Since it is unknown until the end, how much data will be read out, memory
% will be allocated dynamically. It is highly inefficient to append a vector
% by one field after a new data point is added. Instead, we double the
% allocated space once it is overfull.
% Steps:
%  1. _count saves the last index we have written to.
%  2. Available memory is checked depending on _count and doubled if necessary.
%  3. At the end, the _data variable is cut to the actually needed length.

function [output, status]=binoutreader(varargin)

expVals = {'dynaOutputFile',[],@(x) exist(x,'file'),'outputFile,fileName';
    'verbose',false,@islogical,'v';
    'ignoreUnknownDataError',false,@islogical,'ignoreError';
    'ncforc','-xzxzNoImport',@ischar,'ncforce,ncforcname,ncforcename';
    'characterEncoding', 'ISO-8859-1', @ischar, ''};

% Parse the input
inpt = mmParseInput(expVals,varargin,1);

% init
verbose = inpt.verbose;
if verbose
    requestDisp('>>Binoutreader runs in verbose mode<<', verbose,1);
end
ignoreUnknownDataError= inpt.ignoreUnknownDataError;
if ignoreUnknownDataError
    requestDisp('>>Binoutreader runs in ignoreUnknownDataError mode<<', verbose,1);
end

destroyedElements = struct; % so that isempty() works later
elementType = '';

characterEncoding = inpt.characterEncoding;

% define working directory
inputpath_string=inpt.dynaOutputFile;
[work_dir, job_id, file_ext]=fileparts(inpt.dynaOutputFile);

%shell
% define little/big Endian
%'a' for little, 's' for big
% headerreader will correct, if machineformat is wrong
%
machineformat='a';
x=0;

% name, type and element type (only elout) of each readable data
% type: 1 - only read once
%       2 - scalar each time step -> array
%       3 - vector each time step -> matrix
% element type: 1 - shell
%               2 - solid
%               3 - solid and shell
%               4 - discrete
%               7 - both
nodout_names = {
    'title',1
    'version',1
    'revision',1
    'ids',1
    'time',2
    'date',1
    'legend',1
    'legend_ids',1
    'cycle',2
    'x_displacement',3
    'y_displacement',3
    'z_displacement',3
    'x_velocity',3
    'y_velocity',3
    'z_velocity',3
    'x_acceleration',3
    'y_acceleration',3
    'z_acceleration',3
    'x_coordinate',3
    'y_coordinate',3
    'z_coordinate',3
    'rx_displacement',3
    'ry_displacement',3
    'rz_displacement',3
    'rx_velocity',3
    'ry_velocity',3
    'rz_velocity',3
    'rx_acceleration',3
    'ry_acceleration',3
    'rz_acceleration',3
    };
nodout_data  = cell(1,size(nodout_names,1));
nodouthf_data  = cell(1,size(nodout_names,1));
elout_names = {
    'title',1,3
    'version',1,3
    'revision',1,3
    'ids',3,3
    'time',2,3
    'date',1,3
    'legend',1,3
    'legend_ids',1,3
    'states',1,3
    'system',1,3
    'intsts',1,3
    'nodsts',1,3
    'intstn',1,3
    'nodstn',1,3
    'cycle',2,3
    'mat',1,1
    'nip',1,1
    'iop',1,1
    'axial',3,4
    'mtype',3,2
    'yield',3,2
    'state',3,3
    'sig_xx',3,3
    'sig_xy',3,3
    'sig_yy',3,3
    'sig_yz',3,3
    'sig_zx',3,3
    'sig_zz',3,3
    'plastic_strain',3,1
    'lower_eps_xx',3,1
    'lower_eps_xy',3,1
    'lower_eps_yy',3,1
    'lower_eps_yz',3,1
    'lower_eps_zx',3,1
    'lower_eps_zz',3,1
    'upper_eps_xx',3,1
    'upper_eps_xy',3,1
    'upper_eps_yy',3,1
    'upper_eps_yz',3,1
    'upper_eps_zx',3,1
    'upper_eps_zz',3,1
    'eps_xx',3,2
    'eps_xy',3,2
    'eps_yy',3,2
    'eps_yz',3,2
    'eps_zx',3,2
    'eps_zz',3,2
    'effsg',3,2
    'shear_s',3,4
    'shear_t',3,4
    'moment_s',3,4
    'moment_t',3,4
    'torsion',3,4
    'coef_length',3,4
    'visc_force',3,4
    'sigma_11',3,4
    'sigma_12',3,4
    'sigma_31',3,4
    'sigma_22',3,4
    'sigma_23',3,4
    'sigma_33',3,4
    'plastic_eps',3,4
    };

eloutdet_names = {
    'title',1,3
    'version',1,3
    'revision',1,3
    'ids',1,3
    'time',2,3
    'date',1,3
    'states',1,3
    'intsts',1,3
    'nodsts',1,3
    'intstn',1,3
    'nodstn',1,3
    'cycle',2,3
    'mat',1,1
    'nip',1,1
    'nqt',1,1
    'locats',1,3
    'yield',3,2
    'state',3,3
    'sig_xx',3,3
    'sig_xy',3,3
    'sig_yy',3,3
    'sig_yz',3,3
    'sig_zx',3,3
    'sig_zz',3,3
    'eps_xx',3,2
    'eps_xy',3,2
    'eps_yy',3,2
    'eps_yz',3,2
    'eps_zx',3,2
    'eps_zz',3,2
    'effsg',3,2
    'locatn',1,3
    };

matsum_names = {
    'title',1
    'version',1
    'revision',1
    'ids',1
    'time',2
    'date',1
    'legend',1
    'legend_ids',1
    'cycle',2
    'internal_energy',3
    'kinetic_energy',3
    'hourglass_energy',3
    'eroded_kinetic_energy',3
    'eroded_internal_energy',3
    'x_momentum',3
    'y_momentum',3
    'z_momentum',3
    'x_rbvelocity',3
    'y_rbvelocity',3
    'z_rbvelocity',3
    'mass',3
    'max_brick_mass',2
    'brick_id',2
    'max_shell_mass',2
    'shell_id',2
    'max_beam_mass',2
    'beam_id',2
    };
matsum_data  = cell(1,size(matsum_names,1));

curvout_names = {
    'title',1
    'version',1
    'revision',1
    'ids',1
    'time',2
    'date',1
    'legend',1
    'legend_ids',1
    'cycle',2
    'values',3
    };
curvout_data  = cell(1,size(curvout_names,1));

secforc_names = {
    'title',1
    'version',1
    'revision',1
    'date',1
    'ids',1
    'rigidbody', 1
    'accelerometer', 1
    'coordinate_system', 1
    'legend',1
    'legend_ids',1
    'time',2
    'x_force',3
    'y_force',3
    'z_force',3
    'x_moment',3
    'y_moment',3
    'z_moment',3
    'total_force',3
    'total_moment',3
    'x_centroid',3
    'y_centroid',3
    'z_centroid',3
    'area',3
    };
secforc_data  = cell(1,size(secforc_names,1));

glstat_names = {
    'title',1
    'version',1
    'revision',1
    'date',1
    'element_types',1
    'cycle',2
    'ts_eltype',2
    'ts_part',2
    'ts_element',2
    'time',2
    'time_step',2
    'kinetic_energy',2
    'internal_energy',2
    'stonewall_energy',3
    'spring_and_damper_energy',2
    'system_damping_energy',2
    'sliding_interface_energy',2
    'external_work',2
    'eroded_kinetic_energy',2
    'eroded_internal_energy',2
    'eroded_hourglass_energy',2
    'total_energy',2
    'energy_ratio',2
    'energy_ratio_wo_eroded',2
    'global_x_velocity',2
    'global_y_velocity',2
    'global_z_velocity',2
    'nzc',2
    'hourglass_energy',2
    'num_bad_shells',2
    'joint_internal_energy',2
    'added_mass',2
    'percent_increase',2
    };
glstat_data = cell(1,size(glstat_names,1));

rbdout_names = {
    'title',1
    'version',1
    'revision',1
    'date',1
    'ids',1
    'time',2
    'cycle',2
    'num_nodal',2
    'global_x',3
    'global_y',3
    'global_z',3
    'global_dx',3
    'global_dy',3
    'global_dz',3
    'global_rdx',3
    'global_rdy',3
    'global_rdz',3
    'global_vx',3
    'global_vy',3
    'global_vz',3
    'global_rvx',3
    'global_rvy',3
    'global_rvz',3
    'global_ax',3
    'global_ay',3
    'global_az',3
    'global_rax',3
    'global_ray',3
    'global_raz',3
    'dircos_11',3
    'dircos_12',3
    'dircos_13',3
    'dircos_21',3
    'dircos_22',3
    'dircos_23',3
    'dircos_31',3
    'dircos_32',3
    'dircos_33',3 
    'local_dx',3
    'local_dy',3
    'local_dz',3
    'local_rdx',3
    'local_rdy',3
    'local_rdz',3
    'local_vx',3
    'local_vy',3
    'local_vz',3
    'local_rvx',3
    'local_rvy',3
    'local_rvz',3
    'local_ax',3
    'local_ay',3
    'local_az',3
    'local_rax',3
    'local_ray',3
    'local_raz',3
    };
rbdout_data = cell(1,size(rbdout_names,1));

rwforc_names = {
    'title',1
    'version',1
    'revision',1
    'date',1
    'ids',1
    'setid',1
    'time',2
    'normal_force',3
    'x_force',3
    'y_force',3
    'z_force',3
    'cycle',2
    };
rwforc_data = cell(1,size(rwforc_names,1));

nodfor_names = {
    'revision',1
    'title',1
    'version',1
    'date',1
    'legend',1
    'legend_ids',1
    'ids',1
    'time',2
    'groups',2
    'local',2
    'x_force',3
    'y_force',3
    'z_force',3
    'energy',3
    'x_total',2
    'y_total',2
    'z_total',2
    'etotal',2
    'x_local',2
    'y_local',2
    'z_local',2
    };
nodfor_data = cell(1,size(nodfor_names,1));

sbtout_names = {
    'title',1
    'version',1
    'revision',1
    'belt_ids',1
    'slipring_ids',1
    'retractor_ids',1
%    'ids',1
    'time',2
    'date',1
    'legend',1
    'legend_ids',1
    'cycle',2
    'belt_force',3
    'belt_length',3
	'ring_slip',3
	'retractor_pull_out',3
    'retractor_force',3
    };
sbtout_data = cell(1,size(sbtout_names,1));

deforc_names = {
    'title',1
    'version',1
    'revision',1
    'date',1
    'legend',3
    'legend_ids',1
    'ids',1
    'irot',1
    'time',2    
    'x_force',3
    'y_force',3
    'z_force',3
    'resultant_force',3
    'displacement',3    
    };
deforc_data = cell(1,size(deforc_names,1));

abstat_cpm_names = {
    'title',1
    'version',1
    'revision',1
    'date',1
    'legend',3
    'legend_ids',1
    'ids',1
    'mat_counts',1
    'mat_ids',1
    'time',2    
    'volume',3  
    'pressure',3    
    'internal_energy',3    
    'dm_dt_in',3    
    'density',3
    'dm_dt_out',3        
    'total_mass',3   
    'gas_temp',3     
    'surface_area',3
    'reaction',3
    'blocked_area',3
    'unblocked_area',3
    };
abstat_cpm_data = cell(1,size(abstat_cpm_names,1));

ncforc_names = {
    'title',1
    'version',1
    'revision',1
    'ids',1
    'time',2
    'date',1
    'legend',1
    'legend_ids',1
    'cycle',2
    'x_force',3
    'y_force',3
    'z_force',3
    'pressure',3
    'x',3
    'y',3
    'z',3
    };
ncforc_data=struct;

elout_data = struct; % so that isfield() is working later
eloutdet_data = struct; % so that isfield() is working later

% the character encoding of LS-DYNA is unknown so we assume ISO-8859-1 since
% this means one byte per character and therefore no trouble when using
% fread, which may read more bytes than characters with UTF-8
fileID = fopen(inputpath_string,'r','n',characterEncoding);

% memory management: initialize counter (see below for elout)
nodout_count = zeros(1,size(nodout_names,1));
nodouthf_count = zeros(1,size(nodout_names,1));


while(true)
    % read header
    [~,nlength,~,ncommand,~,~,machineformat]=headerreader(machineformat,fileID);
    
    while (true)
        
        % read length field and command field
        [length_field,command_field] = recordtyp(ncommand,nlength,machineformat,fileID);
        if (length_field >= 1e+10)
            requestDisp(['Warning: length_field is too big!. Value ', num2str(length_field), ' at position ', num2str(ftell(fileID))],verbose,1)
        end
        %
        if feof(fileID)    %break while, if file ends
            fclose(fileID);
            break
        end
        %
        % decide which recordtyp
        %
        switch command_field
            case 1 %record_LSDA_NULL skips the record (not important for data)
                skip(ncommand,nlength,machineformat,fileID,length_field);
            case 2 %CD_record - reads path
                [pathread]=record_LSDA_CD (ncommand,nlength,machineformat,fileID,length_field);
                if strncmp(pathread,'..',2)
                    stelle=strfind(pathnew,'/');
                    if strncmp(pathread(4:end),'..',2)
                        pathnew = [pathnew(1:stelle(end-1)),pathread(7:end)];
                    else
                        pathnew = [pathnew(1:stelle(end)),pathread(4:end)];
                    end
                else
                    pathnew = pathread;
                end
            case 3 %reads data
                if ~isempty(regexp(pathnew,'solid', 'once', 'ignorecase'))
                    elementType = 'solid';
                    if ~isfield(elout_data,elementType)
                        elout_data.(elementType) = cell(1,length(elout_names));
                        elout_count.(elementType) = zeros(1,length(elout_names));
                    end
                    if ~isfield(eloutdet_data,elementType)
                        eloutdet_data.(elementType) = cell(1,length(eloutdet_names));
                        eloutdet_count.(elementType) = zeros(1,length(eloutdet_names));
                    end
                elseif ~isempty(regexp(pathnew,'shell', 'once', 'ignorecase'))
                    elementType = 'shell';
                    if ~isfield(elout_data,elementType)
                        elout_data.(elementType) = cell(1,length(elout_names));
                        elout_count.(elementType) = zeros(1,length(elout_names));
                    end
                    if ~isfield(eloutdet_data,elementType)
                        eloutdet_data.(elementType) = cell(1,length(eloutdet_names));
                        eloutdet_count.(elementType) = zeros(1,length(eloutdet_names));
                    end
                else
                    if ~isempty(regexp(pathnew,'beam', 'once', 'ignorecase'))
                        elementType = 'beam';
                        if ~isfield(elout_data,elementType)
                            elout_data.(elementType) = cell(1,length(elout_names));
                            elout_count.(elementType) = zeros(1,length(elout_names));
                        end
                        if ~isfield(eloutdet_data,elementType)
                            eloutdet_data.(elementType) = cell(1,length(eloutdet_names));
                            eloutdet_count.(elementType) = zeros(1,length(eloutdet_names));
                        end
                    end
                end
                
                [name,data]=record_LSDA_DATA (ncommand,nlength,machineformat,fileID,length_field);
                
                if (~isempty(data))
                    if strncmp(pathnew,'/nodout/',8)
                        id = find(strcmp(nodout_names(:,1),name));
                        if ~isempty(id)
                            % seperate by data type
                            switch nodout_names{id,2}
                                case 1 % only read once
                                    if isempty(nodout_data{id})
                                        nodout_data{id} = data;
                                        nodout_count(id) = nodout_count(id) + 1;
                                    end
                                case 2 % scalar each time step -> array
                                    % memory management (see above for global explanation)
                                    counter = nodout_count(id);
                                    if ceil(log2(counter+1)) > ceil(log2(counter))
                                        nodout_data{id}(2^(ceil(log2(counter+1)))) = 0;
                                    end
                                    
                                    nodout_data{id}(counter+1) = data;
                                    nodout_count(id) = counter + 1;
                                case 3 % vector each time step -> matrix
                                    % memory management (see above for global explanation)
                                    counter = nodout_count(id);
                                    if ceil(log2(counter+1)) > ceil(log2(counter))
                                        nodout_data{id}(2^(ceil(log2(counter+1))),:) = zeros(1,length(data));
                                    end
                                    
                                    nodout_data{id}(counter+1,:) = data;
                                    nodout_count(id) = counter + 1;
                            end
                        else
                            % unknown data
                            if ~ignoreUnknownDataError
                                error('binoutreader: Unknown data %s.\n', name);
                            else
                                requestDisp(['Unknown data ', name ,' in ', pathnew , '.'], verbose,0);
                            end
                        end
                                      
                    elseif strncmp(pathnew,'/nodouthf/',10)
                        id = find(strcmp(nodout_names(:,1),name));
                        if ~isempty(id)
                            % seperate by data type
                            switch nodout_names{id,2}
                                case 1 % only read once
                                    if isempty(nodouthf_data{id})
                                        nodouthf_data{id} = data;
                                        nodouthf_count(id) = nodouthf_count(id) + 1;
                                    end
                                case 2 % scalar each time step -> array
                                    % memory management (see above for global explanation)
                                    counter = nodouthf_count(id);
                                    if ceil(log2(counter+1)) > ceil(log2(counter))
                                        nodouthf_data{id}(2^(ceil(log2(counter+1)))) = 0;
                                    end
                                    
                                    nodouthf_data{id}(counter+1) = data;
                                    nodouthf_count(id) = counter + 1;
                                case 3 % vector each time step -> matrix
                                    % memory management (see above for global explanation)
                                    counter = nodouthf_count(id);
                                    if ceil(log2(counter+1)) > ceil(log2(counter))
                                        nodouthf_data{id}(2^(ceil(log2(counter+1))),:) = zeros(1,length(data));
                                    end
                                    
                                    nodouthf_data{id}(counter+1,:) = data;
                                    nodouthf_count(id) = counter + 1;
                            end
                        else
                            % unknown data
                            if ~ignoreUnknownDataError
                                error('binoutreader: Unknown data %s.\n', name);
                            else
                                requestDisp(['Unknown data ', name ,' in ', pathnew , '.'], verbose,0);
                            end
                        end
                    elseif strncmp(pathnew,'/elout/',7)
                        id = find(strcmp(elout_names(:,1),name));
                        if ~isempty(id)
                            % seperate by data type
                            switch elout_names{id,2}
                                case 1 % only read once
                                    if isempty(elout_data.(elementType){id})
                                        elout_data.(elementType){id} = data;
                                        elout_count.(elementType)(id) = elout_count.(elementType)(id) + 1;
                                    end
                                case 2 % scalar each time step -> array
                                    % memory management (see above for global explanation)
                                    counter = elout_count.(elementType)(id);
                                    if ceil(log2(counter+1)) > ceil(log2(counter))
                                        elout_data.(elementType){id}(2^(ceil(log2(counter+1)))) = 0;
                                    end
                                    
                                    elout_data.(elementType){id}(counter+1) = data;
                                    elout_count.(elementType)(id) = counter + 1;
                                case 3 % vector each time step -> matrix
                                    if (id == 4)
                                        counter = elout_count.(elementType)(id);
                                        
                                        % init destroyedElements (0 = not destroyed, 1 = destroyed)
                                        if (~isfield(destroyedElements, elementType))
                                            destroyedElements.(elementType) = zeros(1,length(data));
                                            % keeping track if any destroyed elements exist (faster this way)
                                            existDestroyed = false;
                                        end
                                        
                                        % search for destroyed elements and log them in destroyedElements
                                        if ~isempty(elout_data.(elementType){id}) && length(data) ~= length(elout_data.(elementType){id}(counter,:))
                                            shift = 0;
                                            for j=1:length(destroyedElements.(elementType))
                                                % j-shift is the pointer to the current position of data
                                                if length(data) >= j-shift
                                                    % compare if the current j-th ID from the current data matches the ID of the last data
                                                    if ~isequal(data(j-shift),elout_data.(elementType){id}(counter,j))
                                                        % the IDs don't match -> the element was destroyed
                                                        shift = shift + 1;
                                                        destroyedElements.(elementType)(j) = 1;
                                                        existDestroyed = true;
                                                    end
                                                else
                                                    % element at the end was destroyed
                                                    destroyedElements.(elementType)(j) = 1;
                                                    existDestroyed = true;
                                                end
                                            end
                                        end
                                    end
                                    
                                    % memory management (see above for global explanation)
                                    counter = elout_count.(elementType)(id);
                                    if ceil(log2(counter+1)) > ceil(log2(counter))
                                        elout_data.(elementType){id}(2^(ceil(log2(counter+1))),:) = zeros(1,length(data));
                                    end
                                    
                                    if existDestroyed
                                        % destroyed data will be written as NaN
                                        elout_data.(elementType){id}(counter+1,destroyedElements.(elementType) == 0) = data;
                                        % now the undestroyed elements
                                        elout_data.(elementType){id}(counter+1,destroyedElements.(elementType) == 1) = NaN;
                                    else
                                        % no destroyed elements exist, just copy the data
                                        elout_data.(elementType){id}(counter+1,:) = data;
                                    end
                                    elout_count.(elementType)(id) = counter + 1;
                            end
                        else
                            % unknown data
                            if ~ignoreUnknownDataError
                                error('binoutreader: Unknown data %s.\n', name);
                            else
                                requestDisp(['Unknown data ', name ,' in ', pathnew , '.'], verbose,0);
                            end
                        end
                        
                    elseif strncmp(pathnew,'/eloutdet',9)
                        id = find(strcmp(eloutdet_names(:,1),name));
                        if ~isempty(id)
                            % seperate by data type
                            switch eloutdet_names{id,2}
                                case 1 % only read once
                                    if isempty(eloutdet_data.(elementType){id})
                                        eloutdet_data.(elementType){id} = data;
                                        eloutdet_count.(elementType)(id) = eloutdet_count.(elementType)(id) + 1;
                                    end
                                case 2 % scalar each time step -> array
                                    % memory management (see above for global explanation)
                                    counter = eloutdet_count.(elementType)(id);
                                    if ceil(log2(counter+1)) > ceil(log2(counter))
                                        eloutdet_data.(elementType){id}(2^(ceil(log2(counter+1)))) = 0;
                                    end
                                    
                                    eloutdet_data.(elementType){id}(counter+1) = data;
                                    eloutdet_count.(elementType)(id) = counter + 1;
                                case 3 % vector each time step -> matrix
                                    if (id == 4)
                                        counter = eloutdet_count.(elementType)(id);
                                        
                                        % init destroyedElements (0 = not destroyed, 1 = destroyed)
                                        if (~isfield(destroyedElements, elementType))
                                            destroyedElements.(elementType) = zeros(1,length(data));
                                            % keeping track if any destroyed elements exist (faster this way)
                                            existDestroyed = false;
                                        end
                                        
                                        % search for destroyed elements and log them in destroyedElements
                                        if ~isempty(eloutdet_data.(elementType){id}) && length(data) ~= length(eloutdet_data.(elementType){id}(counter,:))
                                            shift = 0;
                                            for j=1:length(destroyedElements.(elementType))
                                                % j-shift is the pointer to the current position of data
                                                if length(data) >= j-shift
                                                    % compare if the current j-th ID from the current data matches the ID of the last data
                                                    if ~isequal(data(j-shift),eloutdet_data.(elementType){id}(counter,j))
                                                        % the IDs don't match -> the element was destroyed
                                                        shift = shift + 1;
                                                        destroyedElements.(elementType)(j) = 1;
                                                        existDestroyed = true;
                                                    end
                                                else
                                                    % element at the end was destroyed
                                                    destroyedElements.(elementType)(j) = 1;
                                                    existDestroyed = true;
                                                end
                                            end
                                        end
                                    end
                                    
                                    % memory management (see above for global explanation)
                                    counter = eloutdet_count.(elementType)(id);
                                    if ceil(log2(counter+1)) > ceil(log2(counter))
                                        eloutdet_data.(elementType){id}(2^(ceil(log2(counter+1))),:) = zeros(1,length(data));
                                    end
                                    
                                    if existDestroyed
                                        % destroyed data will be written as NaN
                                        eloutdet_data.(elementType){id}(counter+1,destroyedElements.(elementType) == 0) = data;
                                        % now the undestroyed elements
                                        eloutdet_data.(elementType){id}(counter+1,destroyedElements.(elementType) == 1) = NaN;
                                    else
                                        % no destroyed elements exist, just copy the data
%                                         data_ = reshape(data, [8, 40])';
%                                         data_int_points = data_(1:2:end,:);
%                                         data_nodes = data_(2:2:end,:);
                                        eloutdet_data.(elementType){id}(counter+1,:) = data;
                                    end
                                    eloutdet_count.(elementType)(id) = counter + 1;
                            end
                        else
                            % unknown data
                            if ~ignoreUnknownDataError
                                error('binoutreader: Unknown data %s.\n', name);
                            else
                                requestDisp(['Unknown data ', name ,' in ', pathnew , '.'], verbose,0);
                            end
                        end
                        
                    elseif strncmp(pathnew,'/matsum',7)
                        
                        id = find(strcmp(matsum_names(:,1),name));
                        if ~isempty(id)
                            % seperate by data type
                            switch matsum_names{id,2}
                                case 1 % only read once
                                    if isempty(matsum_data{id})
                                        matsum_data{id} = data;
                                    end
                                case 2 % scalar each time step -> array
                                    matsum_data{id}(end+1) = data;
                                case 3 % vector each time step -> matrix
                                    matsum_data{id}(end+1,:) = data;
                            end
                        else
                            % unknown data
                            if ~ignoreUnknownDataError
                                error('binoutreader: Unknown data %s.\n', name);
                            else
                                requestDisp(['Unknown data ', name ,' in ', pathnew , '.'], verbose,0);
                            end
                        end
                        
                    elseif strncmp(pathnew,'/curvout',8)
                        
                        id = find(strcmp(curvout_names(:,1),name));
                        if ~isempty(id)
                            % seperate by data type
                            switch curvout_names{id,2}
                                case 1 % only read once
                                    if isempty(curvout_data{id})
                                        curvout_data{id} = data;
                                    end
                                case 2 % scalar each time step -> array
                                    curvout_data{id}(end+1) = data;
                                case 3 % vector each time step -> matrix
                                    curvout_data{id}(end+1,:) = data;
                            end
                        else
                            % unknown data
                            if ~ignoreUnknownDataError
                                error('binoutreader: Unknown data %s.\n', name);
                            else
                                requestDisp(['Unknown data ', name ,' in ', pathnew , '.'], verbose,0);
                            end
                        end
                    elseif strncmp(pathnew,'/secforc',8)
                        
                        id = find(strcmp(secforc_names(:,1),name));
                        if ~isempty(id)
                            % seperate by data type
                            switch secforc_names{id,2}
                                case 1 % only read once
                                    if isempty(secforc_data{id})
                                        secforc_data{id} = data;
                                    end
                                case 2 % scalar each time step -> array
                                    secforc_data{id}(end+1) = data;
                                case 3 % vector each time step -> matrix
                                    secforc_data{id}(end+1,:) = data;
                            end
                        else
                            %unknown data
                            if ~ignoreUnknownDataError
                                error('binoutreader: Unknown data %s.\n', name);
                            else
                                requestDisp(['Unknown data ', name ,' in ', pathnew , '.'], verbose,0);
                            end
                        end
                    elseif strncmp(pathnew,'/glstat',7)
                        
                        id = find(strcmp(glstat_names(:,1),name));
                        if ~isempty(id)
                            % seperate by data type
                            switch glstat_names{id,2}
                                case 1 % only read once
                                    if isempty(glstat_data{id})
                                        glstat_data{id} = data;
                                    end
                                case 2 % scalar each time step -> array
                                    glstat_data{id}(end+1) = data;
                                case 3 % vector each time step -> matrix
                                    glstat_data{id}(end+1,:) = data;
                            end
                        else
                            % unknown data
                            if ~ignoreUnknownDataError
                                error('binoutreader: Unknown data %s.\n', name);
                            else
                                requestDisp(['Unknown data ', name ,' in ', pathnew , '.'], verbose,0);
                            end
                        end
                        
                    elseif strncmp(pathnew,'/rbdout',7)
                        
                        id = find(strcmp(rbdout_names(:,1),name));
                        if ~isempty(id)
                            % seperate by data type
                            switch rbdout_names{id,2}
                                case 1 % only read once
                                    if isempty(rbdout_data{id})
                                        rbdout_data{id} = data;
                                    end
                                case 2 % scalar each time step -> array
                                    rbdout_data{id}(end+1) = data;
                                case 3 % vector each time step -> matrix
                                    rbdout_data{id}(end+1,:) = data;
                            end
                        end
                        
                    elseif strncmp(pathnew,'/rwforc',7)
                        
                        % rwforce has some strange behavior. time has every element three times
                        % additionally, x/y/z_force is double with size 3 and 45 -> keep only the first
                        id = find(strcmp(rwforc_names(:,1),name));
                        if ~isempty(id)
                            % seperate by data type
                            switch rwforc_names{id,2}
                                case 1 % only read once
                                    if isempty(rwforc_data{id})
                                        rwforc_data{id} = data;
                                    end
                                case 2 % scalar each time step -> array
                                    if id == 7
                                        % special threatment for time, see above
                                        if isempty(rwforc_data{id}) || rwforc_data{id}(end) ~= data
                                            rwforc_data{id}(end+1) = data;
                                        end
                                    else
                                        rwforc_data{id}(end+1) = data;
                                    end
                                case 3 % vector each time step -> matrix
                                    if id == 9 || id == 10 || id == 11
                                        % special threatment for x/y/z_force, see above
                                        if length(data) == 3
                                            rwforc_data{id}(end+1,:) = data;
                                        end
                                    else
                                        rwforc_data{id}(end+1,:) = data;
                                    end
                            end
                        end
                    elseif strncmp(pathnew,'/nodfor',7)
                        
                        id = find(strcmp(nodfor_names(:,1),name));
                        if ~isempty(id)
                            % seperate by data type
                            switch nodfor_names{id,2}
                                case 1 % only read once
                                    if isempty(nodfor_data{id})
                                        nodfor_data{id} = data;
                                    end
                                case 2 % scalar each time step -> array
                                    nodfor_data{id}(end+1) = data;
                                case 3 % vector each time step -> matrix
                                    nodfor_data{id}(end+1,:) = data;
                            end                            
                        else
                            % unknown data
                            if ~ignoreUnknownDataError
                                error('binoutreader: Unknown data %s.\n', name);
                            else
                                requestDisp(['Unknown data ', name ,' in ', pathnew , '.'], verbose,0);
                            end
                        end
                    
                     elseif strncmp(pathnew,'/sbtout',7)
                        
                        id = find(strcmp(sbtout_names(:,1),name));
                        if ~isempty(id)
                            % seperate by data type
                            switch sbtout_names{id,2}
                                case 1 % only read once
                                    if isempty(sbtout_data{id})
                                        sbtout_data{id} = data;
                                    end
                                case 2 % scalar each time step -> array
                                    sbtout_data{id}(end+1) = data;
                                case 3 % vector each time step -> matrix
                                    sbtout_data{id}(end+1,:) = data;
                            end
                        else
                            % unknown data
                            if ~ignoreUnknownDataError
                                error('binoutreader: Unknown data %s.\n', name);
                            else
                                requestDisp(['Unknown data ', name ,' in ', pathnew , '.'], verbose,0);
                            end
                        end    
                        
                    elseif strncmp(pathnew,'/deforc',7)
                                             
                        id = find(strcmp(deforc_names(:,1),name));
                        if ~isempty(id)
                            % seperate by data type
                            switch deforc_names{id,2}
                                case 1 % only read once
                                    if isempty(deforc_data{id})
                                        deforc_data{id} = data;
                                    end
                                case 2 % scalar each time step -> array
                                    deforc_data{id}(end+1) = data;
                                case 3 % vector each time step -> matrix
                                    deforc_data{id}(end+1,:) = data;
                            end
                        else
                            % unknown data
                            if ~ignoreUnknownDataError
                                error('binoutreader: Unknown data %s.\n', name);
                            else
                                requestDisp(['Unknown data ', name ,' in ', pathnew , '.'], verbose,0);
                            end
                        end                            
                        
                       elseif strncmp(pathnew,'/abstat_cpm',10)
                                             
                        id = find(strcmp(abstat_cpm_names(:,1),name));
                        if ~isempty(id)
                            % seperate by data type
                            switch abstat_cpm_names{id,2}
                                case 1 % only read once
                                    if isempty(abstat_cpm_data{id})
                                        abstat_cpm_data{id} = data;
                                    end
                                case 2 % scalar each time step -> array
                                    abstat_cpm_data{id}(end+1) = data;
                                case 3 % vector each time step -> matrix
                                    abstat_cpm_data{id}(end+1,:) = data;
                            end
                        else
                            % unknown data
                            if ~ignoreUnknownDataError
                                error('binoutreader: Unknown data %s.\n', name);
                            else
                                requestDisp(['Unknown data ', name ,' in ', pathnew , '.'], verbose,0);
                            end
                        end                            
                            
                        
                    elseif strncmp(pathnew,'/ncforc',7)
                        [~,contact]=fileparts(fileparts(pathnew));
                        if ~any(strcmp(fieldnames(ncforc_data),contact))                       
                            ncforc_data.(contact) = cell(1,size(ncforc_names,1));
                        end
                        id = find(strcmp(ncforc_names(:,1),name));
                        if ~isempty(id)
                            % seperate by data type
                            switch ncforc_names{id,2}
                                case 1 % only read once
                                    if strcmp(name,'title')
                                        if (data(1) - 0)==0 %% if input is empty (starts with zero)
                                            % jump to right position to
                                            % read the second title
                                            testnum=fread(fileID,1,'int8');
                                            % find right position by jumping backwards in binoutfile
                                            while testnum ~= 96
                                                fseek(fileID,-1,'cof');
                                                testnum=fread(fileID,1,'int8');
                                                fseek(fileID,-1,'cof');
                                            end
                                            continue
                                        end
                                    end
                                    
                                    if isempty(ncforc_data.(contact){id})
                                        ncforc_data.(contact){id} = data;
                                    end
                                case 2 % scalar each time step -> array
                                    if contains(contact,inpt.ncforc)
                                        ncforc_data.(contact){id}(end+1) = data;
                                    end
                                case 3 % vector each time step -> matrix
                                    if contains(contact,inpt.ncforc)
                                        ncforc_data.(contact){id}(end+1,:) = data;
                                    end
                            end
                        else
                            % unknown data
                            if ~ignoreUnknownDataError
                                error('binoutreader: Unknown data %s.\n', name);
                            else
                                requestDisp(['Unknown data ', name ,' in ', pathnew , '.'], verbose,0);
                            end
                        end
                    else %isempty(data)
                        requestDisp(['Empty dataset: ', pathnew, '/', name], verbose,0);
                    end
                else
                    requestDisp(['Unknown output: ', pathnew], verbose,0);
                end
                
                
                
            case 4 %SYMBOLTABLEOFFSET skips the record (not important for data)
                skip(ncommand,nlength,machineformat,fileID,length_field);
            case 5 %BEGINSYMBOLTABLE skips the record (not important for data)
                skip(ncommand,nlength,machineformat,fileID,length_field);
            case 6 %SYMBOLTABLEOFFSET skips the record (not important for data)
                skip(ncommand,nlength,machineformat,fileID,length_field);
            case 7 %SYMBOLTABLEOFFSET skips the record (not important for data)
                skip(ncommand,nlength,machineformat,fileID,length_field);
            otherwise
                requestDisp(['command with No' num2str(ncommand) 'is unknown, please check'],verbose,1)
        end
        
    end
    
    %% Splitted binout
    % if the binout file is not finished within the while loop, we will end
    % up here and scan for subsequent files
    
    % If the binout is splitted into severel files, read in the following file 
    x=x+1;                  % number of file which will be read next
    requestDisp(['...reading splitfile No.' num2str(x)],verbose,0)
    % filename consisting of job_id and extension with the corresponding file number
    input_string = sprintf('%s%s%s%03d', job_id, file_ext, '%', x);
    inputpath_string=fullfile(work_dir,input_string);
    % read in file or if does not exist finish job
    if exist(inputpath_string,'file') ==2
        fileID = fopen(inputpath_string,'r');
    else
        break;
    end

    
end

% write output
output = updateoutput();

status = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% binoutreader
%
% function [output] = updateoutput(elementType, elout_names, elout_data, eloutdet_data, nodout_names, nodout_data, secforc_names, secforc_data, matsum_names, matsum_data, curvout_names, curvout_data, glstat_names, glstat_data, rwforc_names, rwforc_data, nodfor_names, nodfor_data)
% --------------------------------------------------------------------------------------
%
% This function writes all data into the output structure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function output = updateoutput() %#ok<STOUT>
    
% copy elout_data to output.elout.shell/solid/beam

for k = 1:length(fieldnames(elout_data)) %through elementTypes
    tempFieldnames = fieldnames(elout_data);
    for j_ = 1:length(elout_names)
        if ~isempty(elout_data.(tempFieldnames{k}){j_})
            % memory management: cut unused space
            switch elout_names{j_,2}
                case 1
                    range = '';
                case 2
                    range = '(1:elout_count.(tempFieldnames{k})(j_))';
                case 3
                    range = '(1:elout_count.(tempFieldnames{k})(j_),:)';
            end
            prepare_str = ['output.elout.(tempFieldnames{k}).', elout_names{j_,1}, '=', 'elout_data.(tempFieldnames{k}){j_}', range, ';'];
            eval(prepare_str);
        end
    end
end

% write eloutdet to output.eloutdet.shell/solid/beam

% The data for all integration/nodal points is stored in one matrix. 
% In order to increase the files readability, it is stored in a struct, where each point is attached to its element 
% get ids of entries used to refactor eloutdet
ids_id = find(strcmp(eloutdet_names(:,1),'ids'));
nip_id = find(strcmp(eloutdet_names(:,1),'nip'));
nqt_id = find(strcmp(eloutdet_names(:,1),'nqt'));
time_id = find(strcmp(eloutdet_names(:,1),'time'));
% iterate through element types
for k = 1:length(fieldnames(eloutdet_data))
    tempFieldnames = fieldnames(eloutdet_data);
    % extract data which is required to refactor eloutdet_data
    elem_ids = eloutdet_data.(tempFieldnames{k}){ids_id}; % element ids
    nip = eloutdet_data.(tempFieldnames{k}){nip_id}; % integration points per element
    nqt = eloutdet_data.(tempFieldnames{k}){nqt_id}; % nodal points per element
    % new struct containing all elements with their corresponding intergration points and nodal points            
    elems = struct;
    % 
    for j_ = 1:length(eloutdet_names)
        if ~isempty(eloutdet_data.(tempFieldnames{k}){j_})
            % memory management: cut unused space
            switch eloutdet_names{j_,2}
                case 1
                    range = '';
                    prepare_str = ['output.eloutdet.(tempFieldnames{k}).', eloutdet_names{j_,1}, '=', 'eloutdet_data.(tempFieldnames{k}){j_}', range, ';'];
                    eval(prepare_str);
                case 2
                    range = '(1:eloutdet_count.(tempFieldnames{k})(j_))';
                    prepare_str = ['output.eloutdet.(tempFieldnames{k}).', eloutdet_names{j_,1}, '=', 'eloutdet_data.(tempFieldnames{k}){j_}', range, ';'];
                    eval(prepare_str);
                case 3
                    % current propertie name
                    prop = eloutdet_names{j_};
                    % iterate over all elements                    
                    for i_elem = 1:length(elem_ids)
                        elem_name = sprintf('elem%i', elem_ids(i_elem));
                        
                        % the last index of the nodal points is sum of all points reached so long
                        i_nqt_end = sum(nip(1:i_elem)) + sum(nqt(1:i_elem));
                        % the first index of the nodal points is the end index minus the amount of nodal points
                        i_nqt_st = i_nqt_end - nqt(i_elem) + 1;
                        
                        % the last index of the int points is the start index from the nodal points minus one
                        i_nip_end = i_nqt_st - 1;
                        % the first index of the int points is the end index minus the amount of int points
                        i_nip_st = i_nip_end - nip(i_elem) + 1;
                        
                        % write data into struct
                        elems.(elem_name).nqt.(prop) = eloutdet_data.(tempFieldnames{k}){j_}(1:eloutdet_count.(tempFieldnames{k})(j_),i_nqt_st:i_nqt_end);
                        elems.(elem_name).nip.(prop) = eloutdet_data.(tempFieldnames{k}){j_}(1:eloutdet_count.(tempFieldnames{k})(j_),i_nip_st:i_nip_end);
                    end
            end
        end
    end
    % write struct with all elements for current element type into output.eloutdet.shelll/beam/solid
    output.eloutdet.(tempFieldnames{k}).elems = elems;
end

% copy nodout_data to output.nodout
for k = 1:length(nodout_names)
    % memory management: cut unused space
    switch nodout_names{k,2}
        case 1
            range = '';
        case 2
            range = '(1:nodout_count(k))';
        case 3
            range = '(1:nodout_count(k),:)';
    end
    prepare_str = ['output.nodout.', nodout_names{k,1}, '=', 'nodout_data{k}', range, ';'];
    eval(prepare_str);
end

% copy secforc_data to output.secforc
for k = 1:length(secforc_names)
    prepare_str = ['output.secforc.', secforc_names{k,1}, '=', 'secforc_data{k};'];
    eval(prepare_str);
end

% copy matsum_data to output.matsum
for k = 1:length(matsum_names)
    prepare_str = ['output.matsum.', matsum_names{k,1}, '=', 'matsum_data{k};'];
    eval(prepare_str);
end

% copy curvout_data to output.curvout
for k = 1:length(curvout_names)
    prepare_str = ['output.curvout.', curvout_names{k,1}, '=', 'curvout_data{k};'];
    eval(prepare_str);
end

% copy glstat_data to output.glstat
for k = 1:length(glstat_names)
    prepare_str = ['output.glstat.', glstat_names{k,1}, '=', 'glstat_data{k};'];
    eval(prepare_str);
end

% copy rwforc_data to output.rwforc
for k = 1:length(rwforc_names)
    prepare_str = ['output.rwforc.', rwforc_names{k,1}, '=', 'rwforc_data{k};'];
    eval(prepare_str);
end

% copy rwforc_data to output.rwforc
for k = 1:length(rbdout_names)
    prepare_str = ['output.rbdout.', rbdout_names{k,1}, '=', 'rbdout_data{k};'];
    eval(prepare_str);
end

% copy nodfor_data to output.nodfor
for k = 1:length(nodfor_names)
    prepare_str = ['output.nodfor.', nodfor_names{k,1}, '=', 'nodfor_data{k};'];
    eval(prepare_str);
end

for k = 1:length(sbtout_names)
    prepare_str = ['output.sbtout.', sbtout_names{k,1}, '=', 'sbtout_data{k};'];
    eval(prepare_str);
end

for k = 1:length(deforc_names)
    prepare_str = ['output.deforc.', deforc_names{k,1}, '=', 'deforc_data{k};'];
    eval(prepare_str);
end

for k = 1:length(abstat_cpm_names)
    prepare_str = ['output.abstat_cpm.', abstat_cpm_names{k,1}, '=', 'abstat_cpm_data{k};'];
    eval(prepare_str);
end

% copy ncforc_data to output.ncforc
contact = fieldnames(ncforc_data);
for k = 1:length(ncforc_names)
    for con = 1:length(fieldnames(ncforc_data))
        contact = fieldnames(ncforc_data);
        contact = contact{con};
        prepare_str = ['output.ncforc.' contact '.' ncforc_names{k,1},  '=', 'ncforc_data.(contact){k};'];
        eval(prepare_str);
    end
end

end

end






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% binoutreader
%
% function [nbh,nlength,noffset,ncommand,ntypeid,endian,machineformat] = headerreader (machineformat,fileID)
% --------------------------------------------------------------------------------------
%
% This function reads the information in the header
%
% Output arguments
% ----------------
%
% nbh:number of bytes in the header
% nlength: number of bytes used in record LENGTH fields
% noffset: number of bytes used in record OFFSET fields
% ncommand: number of bytes used in record COMMAND fields
% ntypeid: number of bytes used in record TYPEID
% endian: big-endian flag: 0=big-endian, 1=little-endian
%
% created by B. Tezcan, 21.07.2014
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [nbh,nlength,noffset,ncommand,ntypeid,endian,machineformat] = headerreader (machineformat,fileID)
%number of bytes in the header
[nbh]=fread(fileID,1,'int8',0, machineformat);
%
%number of bytes used in record LENGTH fields
[nlength]=fread(fileID,1,'int8',0, machineformat);
%
%number of bytes used in record OFFSET fields
%
[noffset]=fread(fileID,1,'int8',0, machineformat);
%
%number of bytes used in record COMMAND fields
%
[ncommand]=fread(fileID,1,'int8',0, machineformat);
%
%number of bytes used in record TYPEID
%
[ntypeid]=fread(fileID,1,'int8',0, machineformat);
%
%big-endian flag: 0=big-endian, 1=little-endian
[endian]=fread(fileID,1,'int8',0, machineformat);
%
%change machineformate if big-endian
%
if endian == 0
    machineformat = 's';
end
%
%floating point format flag: 0 = IEEE
fread(fileID,1,'int8',0, machineformat);
%
%not used
%
fread(fileID,1,'int8',0, machineformat);
%
%
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% binoutreader
%
% function [path1]=record_LSDA_CD (ncommand,nlength,machineformat,fileID,length_field)
% ------------------------------------------------------------------------------------------
%
% This function reads the path, which is written in the binary file.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [path1]=record_LSDA_CD (ncommand,nlength,machineformat,fileID,length_field)
%
%length of the path to read
%
length_path=(length_field - nlength-ncommand);
%
%read path
%
[path1]=fread(fileID,length_path,'*char',0, machineformat);
%
%
path1=path1';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% binoutreader
%
% function [name,data]=record_LSDA_DATA (ncommand,nlength,machineformat,fileID,length_field)
% ------------------------------------------------------------------------------------------
%
% This function reads the name and the data from the binary file
%
% created by B. Tezcan, 21.07.2014
% fixed by F. Kempter, 03.07.2017 (typid 9: datatyp='single')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



function [name,data]=record_LSDA_DATA (ncommand,nlength,machineformat,fileID,length_field)
%
% read typid to decide datatyp
%
[typid]=fread(fileID,1,'int8',0, machineformat);
%
%read length of name
%
[length_name]=fread(fileID,1,'int8',0, machineformat);
%
%read name
%
[name]=fread(fileID,length_name,'*char',0, machineformat);
name=name';
%
% length of data
%
length_data=(length_field - nlength-ncommand-2-length_name); % -2 wegen typid und lengthname
%
% decide datatyp
%
switch typid
    case 1
        % string
        datatyp = '*char';
        length_type = 1;
    case 2
        datatyp = 'int16';
        length_type = 2;
    case 3
        datatyp = 'int32';
        length_type = 4;
    case 4
        datatyp = 'int64';
        length_type = 8;
    case 5
        datatyp = 'unint8';
        length_type = 1;
    case 6
        datatyp = 'uint16';
        length_type = 2;
    case 7
        datatyp = 'int32';
        length_type = 4;
    case 8
        datatyp = 'uint64';
        length_type = 8;
    case 9
        datatyp = 'single';
        length_type = 4;
        
    case 10
        datatyp = 'double';
        length_type = 8;
    otherwise
        requestDisp(['typid' num2str(typid) 'is unknown, please check if right data is transmitted as typid'],verbose,1)
end
length_data = length_data/length_type;
%
%read data
%
old_pos = ftell(fileID);
[data]=fread(fileID,length_data,datatyp,0, machineformat);
new_pos = ftell(fileID);
if new_pos-old_pos ~= length_data*length_type
    error('binoutreader: fread read %d bytes but it was supposed to read %d bytes. Probably you used the wrong character encoding when opening the file.', new_pos-old_pos, length_data*length_type)
end
data=data';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% binoutreader
%
% function [length_field,command_field]=recordtyp(ncommand,nlength,machineformat,fileID)
% --------------------------------------------------------------------------------------
%
% This function reads the length and the recordtyp of the field.
%
% Output arguments
% ----------------
%
% length_field:  length of the field in bytes
% command_fiel:  recordtyp (1 for LSDA_NULL, 2 for CD record, 3 for data,
% etc.) For more information look at [Livermore Software Data Archival]
% file_format file.
%
% Input arguments
% ----------------
% The input arguments are read by the function 'headerreader'.
% For more information look at the headerreader description.
%
%
% created by B. Tezcan, 21.07.2014
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [length_field,command_field]=recordtyp(ncommand,nlength,machineformat,fileID)
    length_field  = fread(fileID, nlength/8,'int64',0, machineformat);
    command_field = fread(fileID, ncommand, 'int8',0, machineformat);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% binoutreader
%
% function skip(ncommand,nlength,machineformat,fileID,length_field)
% -----------------------------------------------------------------
%
% This function skips sections in the binary file, which is not important for the nodout
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function skip(ncommand,nlength,machineformat,fileID,length_field)
length_skip = length_field - nlength-ncommand;
fread(fileID,length_skip,'int8',0, machineformat);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% binoutreader
%
% function requestDisp(dispString, verbose, importance)
% -----------------------------------------------------------------
%
% This function handels output requests
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function requestDisp(dispString, verbose, importance)
switch importance
    case 0 % not important, only write in verbose mode
        if verbose
            disp(dispString);
        end
    case 1 % important
        disp(dispString);
end
end

