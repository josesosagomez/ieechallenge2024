% function [rangeMap] = rangeNormalizedFiltered(frames)
%     % rangeMap 14x255x20
%     bandwidth = 500e6;
% 
%     [range_profile,range_axis] = complex2Range(frames,bandwidth);
%     range_profile(1,2:255,:) = zeros(1,254,20);
% 
%     filtered_rangeProfile = range_profile(1:14,2:255,:);
%     filtered_rangeAxis = range_axis(1:14,1,:);
% 
%     maxIntensity = max(filtered_rangeProfile,[],"all");
%     maxDistance = max(filtered_rangeAxis,[],"all");
%     range_profile_normalized = filtered_rangeProfile/maxIntensity;
%     range_axis_normalized = filtered_rangeAxis/maxDistance;
% 
%     rangeMap = cat(2,range_axis_normalized,range_profile_normalized);
% end

% function [rangeMap] = rangeNormalizedFiltered(frames)
%     % rangeMap 14x2000 - no range_axis
%     bandwidth = 500e6;
% 
%     [range_profile,~] = complex2Range(frames,bandwidth);
%     range_profile(1,2:255,:) = zeros(1,254,20);
% 
%     filtered_rangeProfile = range_profile(1:14,2:255,:);
% 
%     resultMatrix = [];
% 
%     for frameIndex = 1:size(filtered_rangeProfile, 3)
%         currentFrame = filtered_rangeProfile(:, :, frameIndex);
%         [maxValues, ~] = max(currentFrame, [], 1);
%         [~, sortedIndices] = sort(maxValues, 'descend');
%         top100Indices = sort(sortedIndices(1:100), 'ascend');
%         resultMatrix = [resultMatrix currentFrame(:, top100Indices)];
%     end
% 
%     maxIntensity = max(resultMatrix,[],"all");
%     range_profile_normalized = resultMatrix/maxIntensity;
% 
%     rangeMap = range_profile_normalized;
% end

% function [rangeMap] = rangeNormalizedFiltered(frames)
%     % rangeMap 14x2000x2 - profile and axis
%     bandwidth = 500e6;
% 
%     [range_profile,range_axis] = complex2Range(frames,bandwidth);
%     range_profile(1,2:255,:) = zeros(1,254,20);
% 
%     filtered_rangeProfile = range_profile(1:14,2:255,:);
%     filtered_rangeAxis = range_axis(1:14,1,:);
% 
% 
%     resultMatrix = [];
% 
%     for frameIndex = 1:size(filtered_rangeProfile, 3)
%         currentFrame = filtered_rangeProfile(:, :, frameIndex);
%         [maxValues, ~] = max(currentFrame, [], 1);
%         [~, sortedIndices] = sort(maxValues, 'descend');
%         top100Indices = sort(sortedIndices(1:100), 'ascend');
%         resultMatrix = [resultMatrix currentFrame(:, top100Indices)];
%     end
% 
%     filtered_rangeAxis = repmat(filtered_rangeAxis, 1, 100);
%     axisMatrix = [];
% 
%     for frameIndex = 1:size(filtered_rangeAxis, 3)
%         axisMatrix = [axisMatrix filtered_rangeAxis(:,:,frameIndex)];
%     end
% 
%     maxIntensity = max(resultMatrix,[],"all");
%     maxDistance = max(axisMatrix,[],"all");
%     range_profile_normalized = resultMatrix/maxIntensity;
%     range_axis_normalized = axisMatrix/maxDistance;
% 
%     rangeMap = zeros([size(range_profile_normalized) 2]);
%     rangeMap(:,:,1) = range_profile_normalized;
%     rangeMap(:,:,2) = range_axis_normalized;
% end

% function [rangeMap] = rangeNormalizedFiltered(frames, rd)
% 
%     filtered_radar_data = frames(:,2:255,:);
%     rangeMap = zeros([size(filtered_radar_data) 2]);
% 
%     for k = 1:size(filtered_radar_data,3)
%         frame = filtered_radar_data(:,:,k);
%         [response, rngGrid, ~] = step(rd, frame);
%         rangeMap(:,:,k,1) = abs(response);
%         rangeMap(:,:,k,2) = repmat(rngGrid, 1, 254);
%     end
% 
%     maxIntensity = max(rangeMap(:,:,:,1),[],"all");
%     rangeMap(:,:,:,1) = rangeMap(:,:,:,1)/maxIntensity;
% 
%     maxRange = max(rangeMap(:,:,:,2),[],"all");
%     rangeMap(:,:,:,2) = rangeMap(:,:,:,2)/maxRange;
% end

function [rangeMap] = rangeNormalizedFiltered(frames, rd)
    %260x201x3
    rangeMap = zeros(260,201,3);
    
    for k = 1:size(frames,3)
        frame = frames(:,:,k);
        [response, rngGrid, dopGrid] = step(rd, frame); 
        magnitude = abs(response);
    
        graphMag = magnitude(134:146,31:231);
        graphDop = dopGrid(31:231,1);
        matrixDop = repmat(graphDop, 1, 13)';
    
        graphRng = rngGrid(134:146,1);
        matrixRng = repmat(graphRng, 1, 201);
    
        rangeMap((k-1)*13+1:13*k,:,1) = graphMag;
        rangeMap((k-1)*13+1:13*k,:,2) = matrixDop;
        rangeMap((k-1)*13+1:13*k,:,3) = matrixRng;
    end
end