function [function_name, file_name] = parentFunction

st = dbstack(2,'-completenames');
if isempty(st) 
    function_name = '';
    file_name = '';
else
    function_name = st(1).name;
    file_name = st(1).file;
end
