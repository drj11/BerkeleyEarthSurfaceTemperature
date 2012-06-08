function index = quickSearch( targets, values, control )
% index(loop) = quickSearch( target, values )
%
% Implements a binary search for "target" in pre-sorted list "values".

nearest = 0;
if nargin > 2
    if strcmpi(control, 'nearest')
        nearest = 1;
    end
end

if isempty(values)
    if nearest
        index = 0;
    else
        index = NaN;
    end
    return;
end

if ~ischar( targets )
    index = NaN( length( targets ), 1 );
    
    [ targets, order ] = sort( targets );
else
    targets = { targets };
    index = NaN;
    order = 1;
end

lower_limit = 1;
upper_limit = length(values);

for loop = 1:length(index)

    if loop > 1
        if ~isnan( index(loop-1) )
            lower_limit = floor(index(loop-1));
        else
            lower_limit = start - 1;
        end
        if lower_limit < 1
            lower_limit = 1;
        end
    end
    
    if iscell( targets )
        target = targets{loop};    
    else
        target = targets(loop);
    end
    
    start = lower_limit;
    stop = upper_limit;
    cur = floor(start + 1.5/(length(index)+2)*(stop-start));
    
    if isa( target, 'char' )
        if ~isa( values, 'cell' )
            target = [target, blanks(length(values(1,:)) - length(target))];
            
            done = false;
            while stop > start + 1 && ~done
                or = stringOrder( target, values(cur,:) );
                if or == 0
                    index(loop) = cur;
                    done = true;
                    break;
                elseif or == -1
                    stop = cur;
                else
                    start = cur;
                end
                
                cur = floor((start+stop)/2);
            end
            if done
                continue;
            end
            
            if strcmp( target, values(start,:) )
                index(loop) = start;
            elseif strcmp( target, values(stop,:) )
                index(loop) = stop;
            elseif nearest
                or1 = stringOrder( target, values(start,:) );
                or2 = stringOrder( target, values(stop,:) );
                
                if or1 == -1
                    index(loop) = start - 0.5;
                elseif or2 == 1
                    index(loop) = stop + 0.5;
                else
                    index(loop) = start + 0.5;
                end
            else
                index(loop) = NaN;
            end
        else
            done = false;
            while stop > start + 1 && ~done
                or = stringOrder( target, values{cur} );
                if or == 0
                    index(loop) = cur;
                    done = true;
                    break;
                elseif or == -1
                    stop = cur;
                else
                    start = cur;
                end
                
                cur = floor((start+stop)/2);
            end
            if done
                continue;
            end
            
            if strcmp( target, values{start} )
                index(loop) = start;
            elseif strcmp( target, values{stop} )
                index(loop) = stop;
            elseif nearest
                or1 = stringOrder( target, values{start} );
                or2 = stringOrder( target, values{stop} );
                
                if or1 == -1
                    index(loop) = start - 0.5;
                elseif or2 == 1
                    index(loop) = stop + 0.5;
                else
                    index(loop) = start + 0.5;
                end
            else
                index(loop) = NaN;
            end
        end
    else
        done = false;
        while stop > start + 1 && ~done
            if values(cur) == target
                index(loop) = cur;
                done = true;
                break;
            elseif values(cur) < target
                start = cur;
            else
                stop = cur;
            end
            cur = floor((start+stop)/2);
        end
        
        if done
            continue;
        end
            
        if target == values(start)
            index(loop) = start;
        elseif target == values(stop)
            index(loop) = stop;
        elseif nearest
            if target < values(start)
                index(loop) = start - 0.5;
            elseif target > values(stop)
                index(loop) = stop + 0.5;
            else
                index(loop) = start + 0.5;
            end
        else
            index(loop) = NaN;
        end
    end       
end

index(order) = index;