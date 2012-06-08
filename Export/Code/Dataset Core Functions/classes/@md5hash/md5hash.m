function md = md5hash( varargin )
% hash = md5hash( data )
% 
% Creates an MD5 hash of data

md.val = zeros(2,1,'uint64');

if nargin == 0    
    md = class( md, 'md5hash' );
    return;
elseif nargin == 1
    v = varargin{1};
    if isa( v , 'md5hash' )
        md = v;
        return;
    elseif ischar( v )
        if all( size( v ) == [1,32] )
            if ~isempty(regexp(v, '[0-9a-f]{32}', 'once'))
                 md.val = swapbytes( typecast( ...
                     uint8(hex2dec([v(1:2:end)', v(2:2:end)']))', 'uint64' )' );
                 md = class( md, 'md5hash' );
                 return;
            end
        end        
    elseif isa( v, 'uint64' ) && length( v(1,:) ) == 2 && length( v(:,1) ) == 1
        md.val = v;
        md = class( md, 'md5hash' );
        return;
    end
end

persistent jv
if isempty( jv )
    jv=java.security.MessageDigest.getInstance('MD5');
else
    jv.reset();
end

vals = {};
count = 0;
for k = 1:nargin
    [jv, vals, count] = bufferedProcess( jv, vals, count, varargin{k} );
end
if ~isempty(vals)
    nums = cellfun( @length, vals );
    if sum(nums) < 5e6
        jv.update( [vals{:}] );
    else
        for k = 1:length(vals)
            if nums(k) < 5e6
                jv.update( vals{k} );
            else
                for m = 1:5e6:nums(k)
                    max_len = min( m+5e6-1, nums(k) );
                    jv.update( vals{k}(m:max_len) );
                end
            end
        end
    end
end
md.val = typecast(jv.digest,'uint64');
md = class( md, 'md5hash' );


function [jv, vals, count] = bufferedProcess( jv, vals, count, A )

if isempty( A )
    vals{end+1} = uint8(0);
    count = count + 1;
elseif isnumeric( A ) || islogical( A )
    if issparse( A )
        [i,j,s] = find(A);
        vals{end+1} = typecast([1 i(:)', j(:)', s(:)'], 'uint8');
        count = count + length(vals{end});        
    elseif ~islogical( A )
        vals{end+1} = [typecast([1 size(A)], 'uint8'), ...
            typecast(A(:)', 'uint8')];
        count = count + length(vals{end});
    else
        vals{end+1} = [typecast([1 size(A)], 'uint8'), ...
            uint8(A(:)')];
        count = count + length(vals{end});        
    end
elseif ischar( A )
    vals{end+1} = [typecast([2 size(A)], 'uint8') uint8(A(:)')];
    count = count + length(vals{end});
elseif isstruct( A )
    flds = fieldnames(A);
    vals{end+1} = uint8([3 flds{:}]);
    count = count + length(vals{end});
    for k = 1:length(flds)
        if length(A) <= 1
            [jv, vals, count] = bufferedProcess( jv, vals, count, A.(flds{k}) );
        else
            [jv, vals, count] = bufferedProcess( jv, vals, count, {A.(flds{k})} );
        end
    end
elseif iscell( A )
    vals{end+1} = uint8(4);
    count = count + 1;
    for k = 1:length(A)
        [jv, vals, count] = bufferedProcess( jv, vals, count, A{k} );
    end
elseif isobject( A )
    MM = methods(A);
    if any(strcmp(MM, 'md5hash'))
        B = md5hash(A);
        if length(B) > 1
            B = collapse( B );
        end
        vals{end+1} = [uint8([5,6]), typecast(B.val, 'uint8')'];       
        count = count + length(vals{end});
    else
        vals{end+1} = uint8([5 7]);
        count = count + 2;
        [jv, vals, count] = bufferedProcess( jv, vals, count, struct(A) );
    end
else
    error( 'Unable to Process');
end
    
if count > 10e6
    nums = cellfun( @length, vals );
    if sum(nums) < 5e6
        jv.update( [vals{:}] );
    else
        for k = 1:length(vals)
            if nums(k) < 5e6
                jv.update( vals{k} );
            else
                for m = 1:5e6:nums(k)
                    max_len = min( m+5e6-1, nums(k) );
                    jv.update( vals{k}(m:max_len) );
                end
            end
        end
    end
    vals = {};
    count = 0;
end
    
