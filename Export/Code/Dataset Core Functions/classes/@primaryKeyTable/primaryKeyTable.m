function pt = primaryKeyTable( varargin )

temperatureGlobals;

psep = filesep();

if nargin == 0
    pt.name = '';
    pt.accessor_list = {};
    pt.lookup_table_names = {};
    pt.lookup_table_numbers = [];
    pt.auto_save = 1;
    
    pt = class(pt, 'primaryKeyTable');
elseif nargin == 1
    if isa( varargin{1}, 'primaryKeyTable' )
        pt = varargin{1};
    elseif isa( varargin{1}, 'char' )

        fname = [temperature_data_dir 'Primary Key Tables' psep 'PrimaryKeyTable_' varargin{1}];
        if exist([fname '.mat'], 'file')
            A = load(fname, 'pt');
            pt = A.pt;
        else
            pt.name = varargin{1};
            pt.accessor_list = {};
            pt.lookup_table_names = {};
            pt.lookup_table_numbers = [];
            pt.auto_save = 1;
            
            pt = class( pt, 'primaryKeyTable' );
            savePKT(pt);
        end
    else
        error( 'Input has wrong type' );
    end
else
    error( 'Too many inputs' );
end