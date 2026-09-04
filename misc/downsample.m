function [resampled_data] = downsample(x,n)
    [y_size, x_size] = size(x);
    if y_size > 1
        resampled_data(1:1:ceil(y_size/n),:) = x(1:n:y_size, :);
    else
        resampled_data(1:1:ceil(x_size/n))   = x(1:n:x_size);
    end
end