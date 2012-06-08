function dt = setUpdateOnly( dt, val )
% dt = setUpdateOnly( dt, value )
%
% If value == 1, then all cache reads will fail.  Writing results into the
% cache is still allowed.  Use this setting if results are expected to have
% changed in ways not detectable with the hash check.
%

if nargin < 2
    val = 1;
end

dt.disable_read = logical(val);

