function [list, vals] = functionDependencies( name, pre_compute )

temperatureGlobals;

A = depfun( name, '-toponly', '-quiet' );
B = dictionary();
B( A{1} ) = saveMFile( A{1} );
A(1) = [];

root = temperature_software_dir;

while ~isempty(A)    
    if length(A{1}) < length(root)
        A(1) = [];
        continue;
    end
    if ~strcmp( A{1}(1:length(root)), root )
        A(1) = [];
        continue;
    end
    if ismember( A{1}, B )
        A(1) = [];
        continue;
    end
    
    if nargin >= 2
        try
            H = pre_compute( A{1} );
        catch
            H = saveMFile( A{1} );
        end
        B( A{1} ) = H;
    else
        B( A{1} ) = saveMFile( A{1} );
    end
    C = depfun( A{1}, '-toponly', '-quiet' );
    A(end + 1:end + length(C)) = C;
end

list = keys(B);
vals = values(B);
vals = [vals{:}];