function saveBlock( pth, md5, key2, cell_mode, val, sup )

num = length(val);

if nargin > 5 && ~isempty( sup )
    v_req = cell( 2*num, 1);
else
    v_req = cell( num, 1 );
end
for m = 1:num
    if ~cell_mode
        eval( ['v_' key2(m,:) ' = val( m );'] );
        v_req{m} = ['v_' key2(m,:)];
        if nargin > 5 && ~isempty( sup )
            eval( ['s_' key2(m,:) ' = sup( m );'] );
            v_req{m+num} = ['s_' key2(m,:)];
        end
    else
        eval( ['v_' key2(m,:) ' = val{ m };'] );
        v_req{m} = ['v_' key2(m,:)];
        if  nargin > 5 && ~isempty( sup )
            eval( ['s_' key2(m,:) ' = sup{ m };'] );
            v_req{m+num} = ['s_' key2(m,:)];
        end
    end
end

pth2 = [pth(1:end-9) '_contents.mat'];
checkPath(pth2, true);

contents = md5(:);     

attempts = 0;
done = 0;

% If system is very busy, too many disk requests can result in temporary
% failure.  This is especially likely if the system is using the disk for
% paging.  Temporarily delay the commit and hope the condition clears.
while ~done
    try
        save(pth, v_req{:}, '-v6');
        done = 1;
        save(pth2, 'contents', '-v6');        
    catch ME
        attempts = attempts + 1;
        if attempts > 20
            error( 'Save failed despite many attempts.' );            
        end
        pause( 10 ); % Wait 10 seconds for conflicts to clear
    end
end