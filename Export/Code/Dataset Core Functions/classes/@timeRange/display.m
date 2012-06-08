function display( tr );

if length(tr) > 1
    disp( [num2str( length(tr) ) ' TimeRanges' ] );
else
    display( tr.first );
    display( tr.last );
end