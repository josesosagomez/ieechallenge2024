function [range_profile,range_axis] = complex2Range(frames,bandwidth)

    c = physconst("LightSpeed");
    range_resolution = c / (2 * bandwidth); 
    num_samples = size(frames, 1);
    range_profile = zeros(size(frames));
    
    for i = 1:size(frames,3)
        range_fft = fft(frames(:,:,i), [], 1);
        range_profile(:,:,i) = abs(range_fft);
        range_axis(:,1,i) = (0:num_samples-1) * range_resolution;
    end

end