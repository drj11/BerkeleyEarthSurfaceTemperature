function recompress( input_dir, output_dir )

global temperature_data_dir

dd = dir( [temperature_data_dir input_dir '*.mat'] );

psep = filesep();

warning off
for k = 1:length(dd)
    if dd(k).isdir
        continue;
    end
    
    if exist( [temperature_data_dir output_dir psep dd(k).name], 'file' )
        continue;
    end
    
    se = [];
    global_id_dict = [];
    global_id_dictionary = [];
    
    if strcmp( dd(k).name, 'manifests.mat' )
        continue;
    end
    
    load( [temperature_data_dir input_dir psep dd(k).name] );
    if isempty( se )
        continue;
    end
    
    for m = 1:length(se)
        if mod( m, 20 ) == 0
            timePlot( 'Recompress', m/length(se) );
        end
        sx = compress( se(m) );
        
%         dates1 = se(m).dates;
%         data1 = se(m).data;
%         num1 = se(m).num;
%         tob1 = se(m).tob;
%         flags1 = se(m).flags;
%         source1 = se(m).source;
%         
%         dates2 = sx.dates;
%         data2 = sx.data;
%         num2 = sx.num;
%         tob2 = sx.tob;
%         flags2 = sx.flags;
%         source2 = sx.source;        
%         
%         if ~all( abs( double(dates2) - double(dates1) ) < 1e-4 )
%             m
%             figure
%             plot(double(dates1) - double(dates2))
%             sx2 = struct(sx)
%             error( 'Bad dates' )
%         end
%         if ~all( (abs( data2 - data1 ) < 1e-4) | (abs( (data2 + data1) / 2 ) > 1000) )
%             m
%             figure
%             plot(data1-data2)
%             sx2 = struct(sx)
%             struct(sx2.data)
%             error( 'Bad data' )
%         end
%         if ~all( all( abs( double(flags1) - double(flags2) ) < 1e-4 | ( isnan( flags1 ) & ~flags2 ) ) )
%             m
%             flags1
%             flags2
%             error( 'Bad flags' )
%         end
%         if ~all( all( abs( double( source1 ) - double( source2 ) ) < 1e-4 ) )
%             m
%             error( 'Bad source' )
%         end
%         if ~all( ( abs( num1 - num2 ) < 1e-4 ) | (isnan(num1) & isnan(num2)) )
%             m
%             error( 'Bad num' )
%         end
%         if ~all( ( abs( tob1 - tob2) < 1e-4 ) | (isnan(tob1) & isnan(tob2)) )
%             m
%             error( 'Bad tob' )
%         end
        
        se(m) = sx;
    end
    timePlot( 'Recompress', 1 );
    
    if isempty( global_id_dictionary )
        global_id_dictionary = global_id_dict;
    end
    
    save( [temperature_data_dir output_dir psep dd(k).name], 'se', 'global_id_table', 'global_id_dictionary' );
end
warning on

for k = 1:length(dd)
    if dd(k).isdir
        continue;
    end
    
    if exist( [temperature_data_dir output_dir psep dd(k).name '.digest'], 'file' )
        continue;
    end
    
    if ~exist( [temperature_data_dir input_dir psep dd(k).name '.digest'], 'file' )
        continue;
    end
    A = readDigestFile( [input_dir psep dd(k).name] );
    
    dependencies = {};
    
    if isfield( A, 'dependency' )
        for j = 1:length(A.dependency) 
            dependencies{end+1} = A.dependency{j}{2};
        end
    end
    
    dependencies
    try
        generateDigestFile( [output_dir psep dd(k).name], A.generator, dependencies );
    catch
    end
end

