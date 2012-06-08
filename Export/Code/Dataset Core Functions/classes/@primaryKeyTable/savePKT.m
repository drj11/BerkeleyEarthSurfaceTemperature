function savePKT( pt )

temperatureGlobals;

fname = [temperature_data_dir 'Primary Key Tables' filesep() 'PrimaryKeyTable_' pt.name];
save( fname, 'pt' );
