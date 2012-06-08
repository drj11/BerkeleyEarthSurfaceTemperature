function C = codistWrapper( localPart, distributor )
% codist = codistWrapper( localPart, distributor )

% This is a wrapper function for codistributed.build.  It is used to avoid
% transparancy violation errors when some users have parallel computing and
% others do not.

C = codistributed.build( localPart, distributor );