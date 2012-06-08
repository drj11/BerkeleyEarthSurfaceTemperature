function [val, varargout] = subsref( se, S )
% SUBSREF Get properties of the station element
% and return the value

if strcmp(S(1).type, '.')
    if nargout > 1 && length(se) > 1
        error( ['Forbidden syntax: Use "class(:).field" when accessing all' ...
            ' elements of a class array.'] );
    end
    if length(S) > 1
        error( 'Chain subreferences not supported.' );
    end        
    
    switch lower( S(1).subs )
        case { 'dates', 'date' }
            val = cell(length(se),1);
            for k = 1:length(se)
                switch se(k).frequency
                    case 1
                        dates = double( se(k).dates );
                        
                        dv = datevec( dates );

                        dur = ones(length(dv(:,1)),1)*365;
                        f = ( mod(dv(:,1),4) == 0 );
                        dur(f) = 366;

                        dv2 = dv;
                        dv2(:,2:3) = 1;
                        dn = datenum(dv2(:,1:3));
                        if isempty(dv)
                            val{k} = [];
                        else
                            val{k} = dv(:,1) + ( dates' - dn ) ./ dur;
                        end
                    case 2
                        val{k} = double(se(k).dates) / 12 - 1/24 + 1600;
                    otherwise
                        val{k} = expand(se(k).dates);
                end
            end
            if length(se) == 1
                val = val{1};
            end                        
        case { 'years', 'year', 'yr' }
            for k = 1:length(se)
                switch se(k).frequency
                    case 1
                        dv = datevec( double( se(k).dates ) );
                        val{k} = dv(:,1);
                    case 2
                        val{k} = floor(double(se(k).dates) / 12 - 1/24 + 1600);
                    otherwise
                        val{k} = expand(se(k).dates);
                end
            end
            if length(se) == 1
                val = val{1};
            end            
        case { 'months', 'month', 'mon' }
            for k = 1:length(se)
                switch se(k).frequency
                    case 1
                        dv = datevec( double( se(k).dates ) );
                        val{k} = dv(:,2);
                    case 2
                        val{k} = mod( double(se(k).dates) - 1,12) + 1;
                    otherwise
                        val{k} = expand(se(k).dates);
                end
            end
            if length(se) == 1
                val = val{1};
            end            
        case { 'days', 'day' }
            for k = 1:length(se)
                switch se(k).frequency
                    case 1
                        dv = datevec( double( se(k).dates ) );
                        val{k} = dv(:,3);
                    case 2
                        val{k} = double(se(k).dates) .* 0 - 1;
                    otherwise
                        val{k} = expand(se(k).dates);
                end
            end
            if length(se) == 1
                val = val{1};
            end            
        case { 'daynum', 'datenum' }
            val = {se.dates};
            for k = 1:length(val)
                switch se(k).frequency
                    case 1
                        val{k} = expand( val{k} );
                    otherwise
                        val{k} = NaN*(1:length(val{k}));
                end
            end
            if length(se) == 1
                val = val{1};
            end            
        case { 'monthnum' }
            val = {se.dates};
            for k = 1:length(val)
                switch se(k).frequency
                    case 1
                        dv = datevec( double( se(k).dates ) );
                        val{k} = (dv(:,1) - 1600)*12 + dv(:,2);
                    case 2
                        val{k} = expand( val{k} );
                    otherwise
                        val{k} = NaN*(1:length(val{k}));
                end
            end
            if length(se) == 1
                val = val{1};
            end            
        case { 'data' }
            val = {se.data};
            for k = 1:length(val)
                val{k} = expand(val{k});
            end
            if length(se) == 1
                val = val{1};
            end            
        case { 'num', 'num_measurements' }
            val = {se.num_measurements};
            for k = 1:length(val)
                val{k} = double(val{k});
                A = (val{k} == 65535);
                val{k}(A) = NaN;
            end
            if length(se) == 1
                val = val{1};
            end            
        case { 'time_of_observation', 'too', 'time', 'tob' }
            val = {se.time_of_observation};
            for k = 1:length(val)
                val{k} = double(val{k});
                A = (val{k} == 255);
                val{k}(A) = NaN;
            end
            if length(se) == 1
                val = val{1};
            end
        case { 'type', 'record_type' }
            val = stationRecordType([se.record_type]);            
        case { 'flags', 'flag' }
            val = {se.flags};
            for k = 1:length(val)
                val{k} = expand(val{k});
            end
            if length(se) == 1
                val = val{1};
            end            
        case { 'freq', 'frequency' }
            val = stationFrequencyType([se.frequency]);
        case { 'freq_code', 'frequency_code' }
            val = [se.frequency];
            if length(se) == 1
                val = val(1);
            end
        case { 'source', 'sources' }            
            val = {se.source};
            for k = 1:length(val)
                val{k} = expand(val{k});
            end
            if length(se) == 1
                val = val{1};
            end
        case { 'code', 'record_code' }
            val = stationRecordType([se.record_type]);
            val = {val.abbrev};
            if length(se) == 1
                val = val{1};
            end
        otherwise
            error( 'Unknown StationElement property' );
    end
elseif strcmp(S(1).type, '()')
    if length(S) > 1
        val = subsref( se( S(1).subs{:} ), S(2:end) );
    else
        val = se( S(1).subs{:} );
    end
else
    error( 'Cell array of StationElement not supported' );
end

