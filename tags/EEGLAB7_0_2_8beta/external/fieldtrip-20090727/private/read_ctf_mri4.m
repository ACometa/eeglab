function [mri, hdr, cpersist] = read_ctf_mri4(filename);

% READ_CTF_MRI reads header and imnage data from CTF format MRI file
%
% [mri, hdr] = read_ctf_mri(filename)
%
% See also READ_CTF_MEG4, READ_CTF_RES4

% Copyright (C) 2008 Ivar Clemens
%
% $Log: not supported by cvs2svn $
% Revision 1.1  2009/01/14 09:24:45  roboos
% moved even more files from fileio to fileio/privtae, see previous log entry
%
% Revision 1.1  2008/11/28 10:25:05  roboos
% new implementation by Ivar, based on the version 2 reader
%
% Revision 1.1  2008/11/21 13:00:42  ivacle
% Adapted read_ctf_mri to read the 'new' CTF MRI format
%

fid = fopen(filename,'rb', 'ieee-be');

if fid<=0
  error(sprintf('could not open MRI file: %s\n', filename));
end

[cpersist] = read_cpersist(fid);

warning off

% general header information
hdr.identifierString        = get_value(cpersist, '_CTFMRI_VERSION');      % CTF_MRI_FORMAT VER 4.1
hdr.imageSize               = get_value(cpersist, '_CTFMRI_SIZE');         % 256
hdr.dataSize                = get_value(cpersist, '_CTFMRI_DATASIZE');     % 1 or 2(bytes)
hdr.orthogonalFlag          = get_value(cpersist, '_CTFMRI_ORTHOGONALFLAG');   % if set then image is orthogonal
hdr.interpolatedFlag        = get_value(cpersist, '_CTFMRI_INTERPOLATEDFLAG'); % if set than image was interpolated
hdr.comment                 = get_value(cpersist, '_CTFMRI_COMMENT');

hdr.Image.modality          = get_value(cpersist, '_SERIES_MODALITY');
hdr.Image.manufacturerName  = get_value(cpersist, '_EQUIP_MANUFACTURER');
hdr.Image.instituteName     = get_value(cpersist, '_EQUIP_INSTITUTION');
hdr.Image.imagedNucleus     = get_value(cpersist, '_MRIMAGE_IMAGEDNUCLEUS');
hdr.Image.FieldStrength     = get_value(cpersist, '_MRIMAGE_FIELDSTRENGTH');
hdr.Image.EchoTime          = get_value(cpersist, '_MRIMAGE_ECHOTIME');
hdr.Image.RepetitionTime    = get_value(cpersist, '_MRIMAGE_REPETITIONTIME');
hdr.Image.InversionTime     = get_value(cpersist, '_MRIMAGE_INVERSIONTIME');
hdr.Image.FlipAngle         = get_value(cpersist, '_MRIMAGE_FLIPANGLE');

% euler angles to align MR to head coordinate system(angles in degrees !)
rotation = split_nvalue(get_value(cpersist, '_CTFMRI_ROTATE'));
hdr.rotate_coronal  = rotation(1);
hdr.rotate_sagittal = rotation(2);
hdr.rotate_axial    = rotation(3);

transformMatrix = split_nvalue(get_value(cpersist, '_CTFMRI_TRANSFORMMATRIX'));
transformMatrix = reshape(transformMatrix, 4, 4)';

mmPerPixel = split_nvalue(get_value(cpersist, '_CTFMRI_MMPERPIXEL'));
hdr.mmPerPixel_sagittal = mmPerPixel(1);
hdr.mmPerPixel_coronal  = mmPerPixel(2);
hdr.mmPerPixel_axial    = mmPerPixel(3);

% HeadModel_Info specific header items
hmNasion = split_nvalue(get_value(cpersist, '_HDM_NASION'));
hdr.HeadModel.Nasion_Sag = hmNasion(1);
hdr.HeadModel.Nasion_Cor = hmNasion(2);
hdr.HeadModel.Nasion_Axi = hmNasion(3);

hmLeftEar = split_nvalue(get_value(cpersist, '_HDM_LEFTEAR'));
hdr.HeadModel.LeftEar_Sag = hmLeftEar(1);
hdr.HeadModel.LeftEar_Cor = hmLeftEar(2);
hdr.HeadModel.LeftEar_Axi = hmLeftEar(3);

hmRightEar = split_nvalue(get_value(cpersist, '_HDM_RIGHTEAR'));
hdr.HeadModel.RightEar_Sag = hmRightEar(1);
hdr.HeadModel.RightEar_Cor = hmRightEar(2);
hdr.HeadModel.RightEar_Axi = hmRightEar(3);

hmSphere = split_nvalue(get_value(cpersist, '_HDM_DEFAULTSPHERE'));
hdr.HeadModel.defaultSphereX = hmSphere(1);
hdr.HeadModel.defaultSphereY = hmSphere(2);
hdr.HeadModel.defaultSphereZ = hmSphere(3);
hdr.HeadModel.defaultSphereRadius = hmSphere(4);

hmOrigin = split_nvalue(get_value(cpersist, '_HDM_HEADORIGIN'));
hdr.headOrigin_sagittal = hmOrigin(1);
hdr.headOrigin_coronal = hmOrigin(2);
hdr.headOrigin_axial = hmOrigin(3);

%fread(fid,204,'char'); % unused, padding to 1028 bytes
warning on

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% READ THE IMAGE DATA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mri = zeros(256, 256, 256);

for slice = 1:256
  name = sprintf('_CTFMRI_SLICE_DATA#%.5d', slice);
  offset = get_value(cpersist, name);

  fseek(fid, offset, 'bof');

  if(hdr.dataSize == 1)
    slicedata = uint8(fread(fid, [256 256], 'uint8'));
  elseif(hdr.dataSize == 2)
    slicedata = uint16(fread(fid, [256 256], 'uint16'));
  else
    error('Unknown datasize in CTF MRI file');
  end;

  mri(:, :, slice) = slicedata;
end;

%mri = reshape(mri, [256 256 256]);
fclose(fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DO POST-PROCESSING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% reorient the image data to obtain corresponding image data and transformation matrix
mri = permute(mri, [3 1 2]);	% this was determined by trial and error

% reorient the image data and the transformation matrix along the left-right direction
% remember that the fiducials in voxel coordinates also have to be flipped (see down)
mri = flipdim(mri, 1);
flip = [-1 0 0 256
  0 1 0 0
  0 0 1 0
  0 0 0 1    ];
transformMatrix = flip*transformMatrix;

% re-compute the homogeneous transformation matrices (apply voxel scaling)
scale = eye(4);
scale(1,1) = hdr.mmPerPixel_sagittal;
scale(2,2) = hdr.mmPerPixel_coronal;
scale(3,3) = hdr.mmPerPixel_axial;
hdr.transformHead2MRI = transformMatrix*inv(scale);
hdr.transformMRI2Head = scale*inv(transformMatrix);

% determint location of fiducials in MRI voxel coordinates
% flip the fiducials in voxel coordinates to correspond to the previous flip along left-right
hdr.fiducial.mri.nas = [256 - hdr.HeadModel.Nasion_Sag hdr.HeadModel.Nasion_Cor hdr.HeadModel.Nasion_Axi];
hdr.fiducial.mri.lpa = [256 - hdr.HeadModel.LeftEar_Sag hdr.HeadModel.LeftEar_Cor hdr.HeadModel.LeftEar_Axi];
hdr.fiducial.mri.rpa = [256 - hdr.HeadModel.RightEar_Sag hdr.HeadModel.RightEar_Cor hdr.HeadModel.RightEar_Axi];

% compute location of fiducials in MRI and HEAD coordinates
hdr.fiducial.head.nas = warp_apply(hdr.transformMRI2Head, hdr.fiducial.mri.nas, 'homogenous');
hdr.fiducial.head.lpa = warp_apply(hdr.transformMRI2Head, hdr.fiducial.mri.lpa, 'homogenous');
hdr.fiducial.head.rpa = warp_apply(hdr.transformMRI2Head, hdr.fiducial.mri.rpa, 'homogenous');

%
% Reads a series of delimited numbers from a string
%
% @param input string Delimited string to process
% @param delim string The delimiter (default: \\)
%
% @return values matrix Array containing the numbers found
%
  function [values] = split_nvalue(input, delim)
    if(nargin < 2), delim = '\\'; end;

    remain = input;
    values = [];

    while(numel(remain > 0))
      [value, remain] = strtok(remain, delim);
      values(end + 1) = str2num(value);
    end;
  end

%
% Reads a value from the CPersist structure
%
% @param cpersist struct-array The CPersist structure
% @param key string The name of the parameter
%
% @return value mixed The value of the named parameter
%
  function [value] = get_value(cpersist, key)
    idx = find(strcmp({cpersist.key}, key));

    if(numel(idx) < 1), error('Specified key does not exist.'); end;
    if(numel(idx) > 1), error('Specified key is not unique.'); end;

    value = cpersist(idx).value;
  end

%
% Processes the CTF CPersist structure into a struct-array
%
% @param fid numeric File handle from which to read the CPersist structure
% @return cpersist struct-array
%
  function [cpersist] = read_cpersist(fid)
    magic = char(fread(fid, 4, 'char'))';

    if(~strcmp(magic, 'WS1_')), error('Invalid CPersist header'); end;

    cpersist = struct('key', {}, 'value', {});

    while(~feof(fid))
      % Read label
      lsize = fread(fid, 1, 'int32');
      ltext = char(fread(fid, lsize, 'char'))';

      % Last label in file is always EndOfParameters
      if(strcmp(ltext, 'EndOfParameters')), return; end;

      % Read value
      vtype = fread(fid, 1, 'int32');
      value = read_cpersist_value(fid, vtype);

      cpersist(end + 1).key = ltext;
      cpersist(end).value = value;
    end
  end

%
% Reads a single value of type (vtype) from fid
%
% @param fid numeric  The file to read the value from
% @param vtype numeric The type of value to read
%
% @return value mixed The read value
%
  function [value] = read_cpersist_value(fid, vtype)
    switch vtype
      case 3
        vsize = fread(fid, 1, 'int32');
        value = ftell(fid);
        fseek(fid, vsize, 'cof');
      case 4
        value = fread(fid, 1, 'double');
      case 5
        value = fread(fid, 1, 'int32');
      case 6
        value = fread(fid, 1, 'int16');
      case 10
        vsize = fread(fid, 1, 'int32');
        value = char(fread(fid, vsize, 'char'))';
      otherwise
        error(['Unsupported valuetype (' num2str(vtype) ') found in CPersist object']);
        return
    end
  end

end

