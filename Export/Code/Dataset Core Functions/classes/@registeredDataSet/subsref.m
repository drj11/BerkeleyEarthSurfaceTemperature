function [val, varargout] = subsref( ss, S )
% SUBSREF Get properties of the dataset
% and return the value

if strcmp(S(1).type, '.')
    if nargout > 1 && length(ss) > 1
        error( ['Forbidden syntax: Use "class(:).field" when accessing all' ...
            ' elements of a class array.'] );
    end
    if length(S) > 1
        error( 'Chain subreferences not supported.' );
    end        
    switch lower( S(1).subs )
        case { 'name' }            
            for k = 1:length(ss)
                val{K} = { [ss(k).collection ' : ' ss(k).type ' : ' ss(k).version] };
            end
            if length(ss) == 1
                val = val{1};
            end
        case { 'data', 'element', 'elements' }
            val = {ss.dataSet.data};
            if length(ss) == 1
                val = val{1};
            end
        case { 'sites', 'site' }
            val = {ss.dataSet.sites};
            if length(ss) == 1
                val = val{1};
            end
        case { 'path' }
            val = {ss.path};
            if length(ss) == 1
                val = val{1};
            end
        case { 'date' }
            val = {ss.date};
            if length(ss) == 1
                val = val{1};
            end
        case { 'size' }
            val = {ss.size};
            if length(ss) == 1
                val = val{1};
            end
        case { 'collection' }
            val = {ss.collection};
            if length(ss) == 1
                val = val{1};
            end
        case { 'type' }
            val = {ss.type};
            if length(ss) == 1
                val = val{1};
            end
        case { 'version' }
            val = {ss.version};
            if length(ss) == 1
                val = val{1};
            end
        case { 'frequency', 'freq', 'frequencies' }
            val = {ss.dataSet.frequencies{1}};
            if length(ss) == 1
                val = val{1};
            end
        case { 'types' }
            val = {ss.dataSet.types{1}};
            if length(ss) == 1
                val = val{1};
            end
        otherwise
            error( 'Unknown DataSet property' );
    end
elseif strcmp(S(1).type, '()')
    if length(S) > 1
        val = subsref( ss( S(1).subs{:} ), S(2:end) );
    else
        val = ss( S(1).subs{:} );
    end
else
    error( 'Cell array of DataSet not supported' );
end
