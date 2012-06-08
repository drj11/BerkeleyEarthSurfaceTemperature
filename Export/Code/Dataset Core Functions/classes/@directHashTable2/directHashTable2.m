classdef directHashTable2
    properties
        name = '';
        dir = '';
    end
    properties (Access=private)
        next_index = 0;
        index_list = [];
        file_list = [];
        last_partition = 0;
    end
    methods
        function ht = directHashTable2( name )
            temperatureGlobals;
            
            if ischar( name )
                ht.name = name;
                nm = strrep( ht.name, '\', filesep ) ;
                nm = strrep( nm, '/', filesep );
                
                f = find( nm == filesep );
                if ~isempty(f)
                    f(1) = [];
                    if ~isempty(f)
                        stem = nm(1:f(1));
                    else
                        stem = NaN;
                    end
                else
                    stem = NaN;
                end
                
                nm = strrep( ht.name, '\', filesep ) ;
                nm = strrep( nm, '/', filesep );
                
                if ~ischar( stem ) || ~exist( stem, 'dir')
                    nm = strrep( nm, ' ', '_' )  ;
                    ht.dir = [temperature_data_dir 'Hash Table' filesep nm filesep];
                    checkPath( ht.dir );
                else
                    ht.dir = [nm filesep];
                    checkPath( ht.dir );
                end
            else
                error('Unable to process input')
            end
            
            ht = reload( ht );
        end
    end
end
