function mid = midByFilename(filename)

[~,f] = fileparts(filename);
idx = strfind(f,'_MID');
f = f(idx+4:end);
all_idx = strfind(f,'_');
if isscalar(all_idx)
    idx = all_idx;
else
    idx = all_idx(1);
end
mid = f(1:idx-1);
mid = str2num(mid);
