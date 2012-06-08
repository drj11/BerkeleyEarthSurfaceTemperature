function sz = matlabPoolSize()
% Determines the size of the Matlab parallel processing pool, or returns 1
% if no parallel processing exists.

if exist( 'matlabpool', 'file' )
    sz = matlabpool('size');
else
    sz = 1;
end

