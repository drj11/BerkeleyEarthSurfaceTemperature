function se = processDataString( se, source, strs )

if isa( strs, 'char' )
    strs = cellstr( strs );
end

switch source
    case {1, 2, 31}
        se = processUSSODDataString( se, strs );
    case 3
        se = processGHCNDDataString( se, strs );
    case 4
        se = processGSODDataString( se, strs );
    case 30
        se = processGHCNMDataString( se, strs );
    case 56
        se = processGHCNM3DataString( se, strs );
    case 34
        se = processSCARDataString( se, strs );
    case 35
        se = processHadCRUDataString( se, strs );
    case 36
        se = processUSSOMDataString( se, strs );
    case 37 
        se = processUSHCNMDataString( se, strs );
    case 38
        se = processWMSSCDataString( se, strs );
    case 53
        se = processGSNMONDataString( se, strs );
    case 54
        se = processMCDWDataString( se, strs );
    case 55
        se = processGCOSDataString( se, strs );
    case 76
        se = processWWRDataString( se, strs );
    case 77
        se = processCADataString( se, strs );
    otherwise
        error( 'Source code not recognized.' );
end

se = clean( se );
