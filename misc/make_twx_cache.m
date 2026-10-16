function cache_fname = make_twx_cache(filename)

% function cache_fname = make_twx_cache(filename)
%
% Make sure the twix object cache used by readhdr/loadData exists and can be
% loaded: twx_obj/<name>_twx_obj.mat next to the raw data file. An existing
% cache is reused only if it loads; otherwise mapVBVD parses the raw file
% again. The cache is written to a temporary file and then renamed, so other
% processes never see a partially written cache.
%
% Fede Raimondo
% 16.10.2026

[pathname,filename_no_ext,~] = fileparts(filename);
if isempty(pathname)
    pathname = '.';
end

cache_dir = fullfile(pathname,'twx_obj');
cache_fname = fullfile(cache_dir,[filename_no_ext, '_twx_obj.mat']);

if exist(cache_fname,'file')
    if is_valid_cache(cache_fname)
        fprintf('Using existing twix object cache: %s\n', cache_fname);
        return;
    end
    fprintf('Existing twix object cache cannot be loaded, rebuilding: %s\n', cache_fname);
end

if ~exist(cache_dir,'dir')
    mkdir(cache_dir);
end

fprintf('Parsing %s ...\n', filename);
twx = mapVBVD(filename);

tmp_fname = fullfile(cache_dir,sprintf('%s_twx_obj_tmp_%d.mat', filename_no_ext, feature('getpid')));
save(tmp_fname,'twx');
if ~is_valid_cache(tmp_fname)
    delete(tmp_fname);
    error('make_twx_cache:invalid_cache', 'The newly written twix object cache cannot be loaded: %s', tmp_fname);
end
movefile(tmp_fname, cache_fname, 'f');
fprintf('Twix object cache written: %s\n', cache_fname);

end


function ok = is_valid_cache(fname)
ok = false;
try
    S = load(fname,'twx');
    twx = S.twx;
    if iscell(twx)
        twx = twx{end};
    end
    ok = all(twx.image.dataSize > 0);
catch
end
end
