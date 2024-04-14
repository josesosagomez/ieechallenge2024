classdef RadarDatastore < matlab.io.Datastore
    properties
        Data
        Labels
        CurrentIndex
    end
    
    methods
        function ds = RadarDatastore(data, labels)
            ds.Data = data;
            ds.Labels = labels;
            ds.CurrentIndex = 1;
        end
        
        function [data, info] = read(ds)
            if hasdata(ds)
                data = ds.Data(:, :, ds.CurrentIndex);
                labels = ds.Labels(ds.CurrentIndex);
                ds.CurrentIndex = ds.CurrentIndex + 1;
                info.Label = labels;
            else
                error('No more data to read.');
            end
        end
        
        function reset(ds)
            ds.CurrentIndex = 1;
        end
        
        function tf = hasdata(ds)
            tf = ds.CurrentIndex <= size(ds.Data, 3);
        end
        
        function frac = progress(ds)
            frac = ds.CurrentIndex / size(ds.Data, 3);
        end
    end
end
