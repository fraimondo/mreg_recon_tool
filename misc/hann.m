function c = hann (m, sflag)
    if nargin < 2
        sflag = 'symmetric';
    end
    sflag = validatestring(sflag, {'symmetric', 'periodic'}, 'hann', 'SFLAG', 2);
    if isempty(m) && isnumeric(m)
        c = zeros(0, 1);
        return
    end
    validateattributes(m, {'numeric'}, {'scalar', 'real', 'finite', 'nonnegative'}, 'hann', 'L', 1);
    m = double(m);
    if (m ~= round(m))
        m = round(m);
        warning('hann:roundingOrder', 'Rounding order to nearest integer.');
    end
    if (m == 0)
        c = zeros(0, 1);
    elseif (m == 1)
        c = 1;
    elseif strcmp(sflag, 'periodic')
        c = 0.5 - 0.5 * cos (2 * pi * (0 : m - 1)' / m);
    else
        m = m - 1;
        c = 0.5 - 0.5 * cos (2 * pi * (0 : m)' / m);
    end
end
