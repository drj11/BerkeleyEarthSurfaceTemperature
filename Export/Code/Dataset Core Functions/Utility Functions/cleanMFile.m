function output_str = cleanMFile( input_str )
% Takes an m-file input string and generates a standardized for which
% removes comments and whitespace.  This is generally used before hashing
% the file in order to ensure that the hash doesn't change with trivial
% edits to file content.

A = textscan( input_str, '%s', 'delimiter', '\r\n' );

A = A{1};
bad = zeros( length(A), 1 );
for k = 1:length(A)
    [starts, ends, ~, match] = regexp( A{k}, '''(?:[^'']|'''')*''');
    for j = length(starts):-1:1
        A{k} = [A{k}(1:starts(j)-1), ['$$$$' num2str(j) '####'], A{k}(ends(j)+1:end)];
    end
    f = find(A{k} == '%');
    if ~isempty(f)
        A{k}(f(1):end) = '';
    end
    A{k} = strtrim( A{k} );
    A{k} = regexprep( A{k}, '([,;=-+/\:()<>&|.^{}\[\]]) *', '$1' );
    A{k} = regexprep( A{k}, ' *([,;=-+/\:()<>&|.^{}\]\[])', '$1' );
    
    if isempty(A{k})
        bad(k) = 1;
    end
    
    for j = length(starts):-1:1       
        A{k} = strrep( A{k}, ['$$$$' num2str(j) '####'], match{j} );
    end    
end

A( logical(bad) ) = [];

output_str = sprintf( '%s\n', A{:} );
output_str(end) = [];