function checkPath(path, quiet)

psep = filesep();

if nargin < 2
    quiet = false;
end

if strcmp( path(1), psep )
    root = '';
    rem = path(2:end);
else
    [root, rem] = strtok( path, psep );
end

while ~isempty(find(rem, psep ))
    root = [root psep ];
    if ~exist(root,'dir')
        mkdir(root);
        if ~quiet
            disp(['Creating New Directory: ' root]);
        end
    end
    [stem, rem] = strtok(rem, psep);
    root = [root stem];
end