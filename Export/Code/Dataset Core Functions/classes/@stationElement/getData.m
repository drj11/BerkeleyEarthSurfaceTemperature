function [dates, data] = getData( se, bad_flags )

if length(se) > 1
    error( 'More than one record requested' );
end

if nargin > 1
    exc = findFlags( se, bad_flags );
else
    exc = [];
end

S.type = '.';
S.subs = 'dates';

dates = subsref( se, S );
data = expand( se.data );

if ~isempty(exc)
    dates(exc) = [];
    data(exc) = [];
end
    