function c = hann (m)
    if (m == 1)
        c = 1;
    else
        m = m - 1;
        c = 0.5 - 0.5 * cos (2 * pi * (0 : m)' / m);
    end
end