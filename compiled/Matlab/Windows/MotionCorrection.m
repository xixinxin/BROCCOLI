function [motion_corrected_volumes, motion_parameters] = MotionCorrection(volumes,broccoli_location,varargin)

% The function performs motion correction of an fMRI dataset.
%
% [motion_corrected_volumes, motion_parameters] = MotionCorrection(volumes,broccoli_location,iterations,opencl_platform,opencl_device)
%
% Required input parameters
%
% volumes - The fMRI data to be motion corrected (filename or Matlab variable)
% broccoli_location - Where BROCCOLI is installed, a string
%
% Optional input parameters
%
% iterations - The number of iterations to use for the algorithm (default 5)
% opencl_platform - The OpenCL platform to use (default 0)
% opencl_device - The OpenCL device to use (default 0)

if length(varargin) > 0
    iterations = varargin{1};
else
    iterations = 5;
end

if length(varargin) > 1
    opencl_platform = varargin{2};
else
    opencl_platform = 0;
end

if length(varargin) > 2
    opencl_device = varargin{3};
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
    voxel_size_x = 3;
    voxel_size_y = 3;
    voxel_size_z = 3;
end

% Load quadrature filters
try
    load([broccoli_location 'filters\filters_for_linear_registration.mat'])
catch
    error = 1;
    disp('Unable to load quadrature filters!')
end

% Do motion correction on OpenCL device
if error == 0
    try
        start = clock;
        [motion_corrected_volumes,motion_parameters] = MotionCorrectionMex(volumes,voxel_size_x,voxel_size_y,voxel_size_z,f1_parametric_registration,f2_parametric_registration,f3_parametric_registration,iterations,opencl_platform,opencl_device,broccoli_location);
        runtime = etime(clock,start);
        disp(sprintf('It took %f seconds to run the motion correction \n',runtime'));
    catch
        disp('Failed to run motion correction!')
    end
end


