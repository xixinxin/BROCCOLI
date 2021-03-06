function smoothed_volumes = Smoothing(volumes,broccoli_location,varargin)

% The function performs smoothing of an fMRI dataset.
%
% smoothed_volumes = Smoothing(volumes,broccoli_location,voxel_size,FWHM,opencl_platform,opencl_device)
%
% Required input parameters
%
% volumes - The fMRI data to be smoothed (filename or Matlab variable)
% broccoli_location - Where BROCCOLI is installed, a string
%
% Optional input parameters
%
% voxel_size - vector with 3 elements (for Matlab variables, use [] for filename)
% FWHM - The amount of smoothing in FWHM (default 6 mm)
% opencl_platform - The OpenCL platform to use (default 0)
% opencl_device - The OpenCL device to use (default 0)

if length(varargin) > 0
    voxel_size = varargin{1};
else
    voxel_size = 0;
end

if length(varargin) > 1
    FWHM = varargin{2};
else
    FWHM = 6;
end

if length(varargin) > 2
    opencl_platform = varargin{3};
else
    opencl_platform = 0;
end

if length(varargin) > 3
    opencl_device = varargin{4};
else
    opencl_device = 0;
end


%---------------------------------------------------------------------------------------------------------------------
% README
% If you run this code in Windows, your graphics driver might stop working
% for large volumes / large filter sizes. This is not a bug in my code but is due to the
% fact that the Nvidia driver thinks that something is wrong if the GPU
% takes more than 2 seconds to complete a task. This link solved my problem
% https://forums.geforce.com/default/topic/503962/tdr-fix-here-for-nvidia-driver-crashing-randomly-in-firefox/
%---------------------------------------------------------------------------------------------------------------------

error = 0;

if ischar(volumes)
    % Load fMRI data
    try
        EPI_nii = load_nii(volumes);
        volumes = double(EPI_nii.img);
        voxel_size_x = EPI_nii.hdr.dime.pixdim(2);
        voxel_size_y = EPI_nii.hdr.dime.pixdim(3);
        voxel_size_z = EPI_nii.hdr.dime.pixdim(4);
    catch
        error = 1;
        disp('Unable to load fMRI data!')
    end
else    
    if voxel_size == 0
        error = 1;
        disp('Voxel size of source fMRI data is not defined!')
    else
        voxel_size_x = voxel_size(1);
        voxel_size_y = voxel_size(2);
        voxel_size_z = voxel_size(3);
    end
end

% Do smoothing on OpenCL device
if error == 0
    try
        start = clock;
        smoothed_volumes = SmoothingMex(volumes,voxel_size_x,voxel_size_y,voxel_size_z,FWHM,opencl_platform,opencl_device,broccoli_location);
        runtime = etime(clock,start);
        disp(sprintf('It took %f seconds to run the smoothing \n',runtime'));
    catch
        disp('Failed to run smoothing!')
    end
end


