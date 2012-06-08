function v = subsref( pt, S )

if strcmp(S(1).type, '()')
    t = S(1).subs;
    if iscell(t)
        t = t{1};
    end
    v = lookup( pt, t );
else
    error( 'Unsupported access type' );
end