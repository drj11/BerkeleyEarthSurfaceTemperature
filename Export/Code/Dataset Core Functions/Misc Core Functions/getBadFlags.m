function bf = getBadFlags( reload )
% Standard list of quality control flags indicating that the data is bad
% and/or questionable.

persistent global_bad_flags;

if nargin < 1
    reload = 1;
end

if isempty( global_bad_flags ) || reload
    
    bad_flags = {'NEW_1', 'NEW_2', 'NEW_3', ...
        'NEW_4', 'NEW_5', 'NEW_6', 'NEW_7', 'NEW_8', 'NEW_9', ...
        'NEW_11', 'MONTHLY_HIGHLY_INCOMPLETE', ...
        'ISOLATED_VALUE' };

    bf = [];

    for k = 1:length(bad_flags)
        bf(k) = dataFlags( bad_flags{k} );
    end

    global_bad_flags = bf;
else 
    bf = global_bad_flags;
end