% setup.m
% set up MREG Reconstruction Toolbox path

if ~exist('mreg_recon_dir', 'var')

    % default is to look for directory where this setup.m is installed!
    mreg_recon_dir = which('setup'); % find setup.m
    [mreg_recon_dir, ~] = fileparts(mreg_recon_dir);

    disp(['Using MREG Recon Tool from directory "' mreg_recon_dir '".'])

end

if mreg_recon_dir(end) ~= filesep % make sure there is a '/' at end of directory
    mreg_recon_dir = [mreg_recon_dir filesep];
end

list = {...
    'grad_files', ...
    'mapVBVD', ...
    'misc', ...
    'mreg_batch', ...
    'mreg_recon_tool', ...
    'nitfti', ...
    'penalties', ...
    'penalties/wavelet', ...
    'psf', ...
    'trajectories', ...
    'trajectories/common', ...
    'trajectories/Shells', ...
    'trajectories/Stack_of_Spirals', ...
    'trajectories/Stack_of_Spirals/pns', ...
    };


for ii=1:numel(list)
    tmp = [mreg_recon_dir list{ii}];
    if exist(tmp, 'dir'), addpath(tmp), end
end


% Set up path to mex files, possibly depending on matlab version.
% Fortunately it seems that the v6 files also run on v7.
% Unfortunately, it seems that sometimes compiling on one version
% e.g., 7.3 and running on earlier 7.0 won't work.
% If you have mex problems, comment out the following line.
% Much of the toolbox will work without mex, just slower.
addpath([mreg_recon_dir 'mex/v7']);


% do not add the paths below if you are using Matlab!
if ir_is_octave
    addpath([mreg_recon_dir 'octave']); % extra stuff for octave only!
elseif isempty(which('dbstack')) % for freemat only!
    addpath([mreg_recon_dir 'freemat']); % extra stuff for freemat only!
end

run([mreg_recon_dir  'external' filesep 'mirt' filesep 'setup.m']); % add mirt to path

% check to see if path setup worked by looking for im() routine.
if strcmp([mreg_recon_dir 'mreg_recon_tool' filesep 'mreg_recon_tool.m'], which('mreg_recon_tool'))
    disp('Path setup for MREG Recon Tool appears to have succeeded.')
    clear list ii mreg_recon_dir tmp
else
    disp('Path setup for MREG Recon Tool may have failed.')
end
