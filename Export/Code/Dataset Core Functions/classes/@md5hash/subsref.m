function [val, varargout] = subsref( md, S )
% SUBSREF Get properties of the md5hash
% and return the value

if strcmp(S(1).type, '.')
    if nargout > 1 && length(md) > 1
        error( ['Forbidden syntax: Use "class(:).field" when accessing all' ...
            ' elements of a class array.'] );
    end
    if length(S) > 1
        error( 'Chain subreferences not supported.' );
    end        
    
    switch lower( S(1).subs )
        case { 'num', 'val' }
            val = [md.val]';
        case { 'key', 'hash' }
            V = [md.val];
            V = reshape( V, numel(V), 1 );
            V = typecast( V, 'uint8' );
            
            %Swap bytes
            V = reshape( V, 8, length(md)*2 );
            V = flipud(V);
            
            V = reshape( V, 1, numel(V) );
            if all( V == 0 )
                %dec2hex mangles values of all zeros
                V = repmat( '0', 2, numel(V) );
            else
                V = dec2hex( V )';
            end
            V = reshape( V, numel(V), 1 );
            V = reshape( V, 32, length(md) )';
            val = lower(V);
        otherwise
            error( 'Unknown MD5Hash property' );
    end
elseif strcmp(S(1).type, '()')
    if length(S) > 1
        val = subsref( md( S(1).subs{:} ), S(2:end) );
    else
        val = md( S(1).subs{:} );
    end
else
    error( 'Cell array of MD5Hash not supported' );
end

