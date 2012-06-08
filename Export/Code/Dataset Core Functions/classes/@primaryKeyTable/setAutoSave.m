function pt = setAutoSave( pt, val );

if nargin <= 1
    val = 1;
end

pt.auto_save = val;