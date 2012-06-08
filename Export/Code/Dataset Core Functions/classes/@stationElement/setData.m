function se = setData( se, new_data );

se.data = [new_data(:)]';

if se.auto_compress == 1;
    rd = zipMatrix( se.data );
    if memSize( rd ) < 8*length(se.data)
        se.data = rd;
    end
end