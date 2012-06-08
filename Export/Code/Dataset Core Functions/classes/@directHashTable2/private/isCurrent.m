function res = isCurrent( ht )

fname = [ht.dir num2str(ht.next_index) '_data.mat'];

if exist( fname, 'file' )
    res = false;
else
    if ht.next_index > 1
        fname = [ht.dir num2str(ht.next_index-1) '_data.mat'];
        if exist( fname, 'file' )
            res = true;
        else
            res = false;
        end
    else
        res = true;
    end
end