function [resampled_data] = downsample(x,n,phase)
    if nargin < 3
        phase = 0;
    end
    if isempty(x)
        error('downsample:emptyInput', 'Expected input number 1, X, to be nonempty.');
    end
    validateattributes(n, {'numeric'}, {'scalar', 'positive', 'integer'}, 'downsample', 'N', 2);
    validateattributes(phase, {'numeric'}, {'scalar', 'nonnegative', 'integer', '<=', n - 1}, 'downsample', 'PHASE', 3);
    % Operate along the first non-singleton dimension, keeping the remaining ones
    dim = find(size(x) ~= 1, 1);
    if isempty(dim)
        dim = 2;
    end
    idx = repmat({':'}, 1, ndims(x));
    idx{dim} = phase+1:n:size(x, dim);
    resampled_data = x(idx{:});
end
