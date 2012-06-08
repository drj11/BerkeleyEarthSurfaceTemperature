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
            val = {ss.name};
            if length(ss) == 1
                val = val{1};
            end
        case { 'data', 'element', 'elements' }
            val = {ss.data};
            if length(ss) == 1
                val = val{1};
            end
        case { 'sites', 'site' }
            val = {ss.sites};
            if length(ss) == 1
                val = val{1};
            end
        case { 'frequency', 'freq', 'frequencies' }
            val = {ss.frequencies{1}};
            if length(ss) == 1
                val = val{1};
            end
        case { 'types', 'type' }
            val = {ss.types{1}};
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




function v = findID( ss, kind )

kind = lower(kind);
kind = [kind '_'];
mx = length(kind);

v = {};

for k = 1:length(ss.ids)
    if length(ss.ids{k}) > mx && strcmp(ss.ids{k}(1:mx), kind)
        v{end+1} = ss.ids{k}(mx+1:end);
    end
end