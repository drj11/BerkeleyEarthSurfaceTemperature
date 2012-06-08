function display( ss )

if length(ss) > 1
    disp( ['  ' num2str(length(ss)) ' DataSet'] );
    return;
end

try
    disp( ss.name )
    disp( [ num2str(length(ss.data)) ' Records'] )
catch
    disp( 'Empty Dataset.' );
end