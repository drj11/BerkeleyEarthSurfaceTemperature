function mn = processHadCRUstring( mn, st )

persistent country_codes_dictionary;
if isempty(country_codes_dictionary)
    country_codes_dictionary = loadCountryCodes();
end

[key, values] = strread( st, '%s%s', 'delimiter', '=' );

id = -1;
nm = '';
country = 0;
lat = NaN;
long = NaN;
elev = NaN;
state = '';

for k = 1:length(values)
    switch lower(key{k})
        case 'number'
            id = values{k};
        case 'name'
            nm = values{k};
            while nm(end) == '-'
                nm(end) = [];
            end
            while nm(1) == '-'
                nm(1) = [];
            end
        case 'country'
            vv = upper( values{k} );
            while vv(end) == '-'
                vv(end) = [];
            end
            while vv(1) == '-'
                vv(1) = [];
            end
            
            append = 0;
            orig = vv;
            
            switch vv
                case 'UNITED KINGDO'
                    vv = 'UNITED KINGDOM';
                case 'ICELA D'
                    vv = 'ICELAND';
                case 'GREEN AND'
                    vv = 'GREENLAND';
                case 'FAEROE IS.'
                    vv = 'FAROE ISLANDS';
                case 'LUXEM OURG'
                    vv = 'LUXEMBOURG';
                case 'FRANC'
                    vv = 'FRANCE';
                case 'ACORES'
                    vv = 'AZORES';
                case 'MADEIRA'
                    vv = 'ME';
                case 'HUNGA Y'
                    vv = 'HUNGARY';
                case 'PORTU AL'
                    vv = 'PORTUGAL';
                case 'CAPE VERDE I'
                    vv = 'CAPE VERDE';
                case {'E.GER ANY', 'W.GER ANY', 'W.GERMANY', 'E.GERMANY'}
                    vv = 'GERMANY';
                case 'CZECH REPUBLI'
                    vv = 'CZECH';
                case 'BOSNIA/HERZE'
                    vv = 'BK';
                case 'YUGOS AVIA'
                    vv = 'YUGOSLAVIA';
                case {'RUMANIA', 'RUMAN A'}
                    vv = 'ROMANIA';
                case 'TURKE'
                    vv = 'TURKEY';
                case {'USSR', 'RUSSIAN FEDER'}
                    vv = 'RUSSIA';
                case 'RUSSIA (ASIA)'
                    vv = 'UA';
                case {'RUSSIA EUROPE', 'RUSSIA (EUROPE)', 'RUSSIA (EUROP'}
                    vv = 'UE';
                case 'KYRGYZ REPUBLI'
                    vv = 'KYRGYZSTAN';
                case {'REPUBLIC OF U', 'REPUBLIC OF UZ'}
                    vv = 'UZBEKISTAN';
                case {'LEBAN', 'LEBAN N'}
                    vv = 'LEBANON';
                case 'JORDON'
                    vv = 'JORDAN';
                case 'AFGHA'
                    vv = 'AFGHANISTAN';
                case 'IZ) A PT' %WTF !!!!!!
                    append = 1;
                    vv = 'SAUDI ARABIA';
                case {'EANDAMAN AND', 'ANDAMAN AND L'}
                    vv = 'INDIA'; %Andamann Islands
                case 'AATAR'
                    vv = 'MONGOLIA';
                    append = 1;
                case 'D.P.R.OF KORE'
                    vv = 'KOREA, NORTH';
                case {'REPUBLIC OF K', 'REPUBLIC-OF'}
                    vv = 'KOREA, SOUTH';
                case 'JAPANESE PACI'
                    vv = 'JAPAN';
                case 'SINGA ORE'
                    vv = 'SINGAPORE';
                case 'VIETNAM'
                    vv = 'VIET NAM';
                case 'LAO P.D.R.'
                    vv = 'LAOS';
                case 'KAMPUCHEA'
                    vv = 'CAMBODIA';
                case {'CANARY IS.', 'CANARY ISLAND'}
                    vv = 'CANARY ISLANDS';
                case 'WESTERN SAHAR'
                    vv = 'WESTERN SAHARA';
                case {'SAO-TOME-AND', 'SAO TOME'}
                    vv = 'TP';
                case 'CHAGOS ARCHIP'
                    vv = 'CHAGOS ARCHIPELAGO';
                case 'CAYMAN IS.'
                    vv = 'CAYMAN ISLANDS';
                case 'MEXIC'
                    vv = 'MEXICO';
                case 'FRENCH SOUTHE'
                    vv = 'FS';
                case 'REUNION'
                    vv = 'RE';
                case 'MAURI IUS'
                    vv = 'MAURITIUS';
                case 'CANAD'
                    vv = 'CANADA';
                case 'SOMAL'
                    vv = 'SOMALIA';
                case 'ASCENSION IS'
                    vv = 'ASCENSION ISLAND';
                case 'D.R. OF CONGO'
                    vv = 'ZAIRE';
                case {'CENTRAL AFRIC', 'C. AFR. REP.'}
                    vv = 'CT';
                case 'MALYASIA'
                    vv = 'MALAYSIA';
                case 'CHRISTMAS IS.'
                    vv = 'CK';
                case 'CAMER ON'
                    vv = 'CAMEROON';
                case 'KOREA'
                    vv = 'KOREA, SOUTH';
                case {'OCEANIA', 'PACIF', 'OCEAN', 'ARCTIC'}
                    vv = 'OW';
                case {'YAN-OLGIY', 'ENTRAL', 'ASTERN', 'OVIALTAY'}
                    append = 1;
                    vv = 'MONGOLIA';
                case 'COTE-D''IVOIR'
                    vv = 'IV';
                case 'ANGOL'
                    vv = 'ANGOLA';
                case 'UK SOUTH ATLAN'
                    vv = 'OW';
                case 'ZAMBI'
                    vv = 'ZAMBIA';
                case 'ZIMBA WE'
                    vv = 'ZIMBABWE';
                case {'S.AFR', 'SOUTH-AFRICA','S.AFRICA', 'SOUTH AFRICAN'}
                    vv = 'SOUTH AFRICA';
                case 'ALASKA'
                    vv = 'UNITED STATES';
                    state = 'AK';
                case {'HAWAII', 'NENE)'}
                    if ~strcmp( 'HAWAII', vv )
                        append = 1;
                    end
                    vv = 'UNITED STATES';
                    state = 'HI';
                case {'USA', 'RUN-BY-USA'}
                    vv = 'UNITED STATES';
                case {'INTL', 'LLY', 'ELLER', 'WASH', ...
                        'PER', 'S', 'POINT', 'S FLD', 'NAL', ...
                        'I', 'ALKER FLD', 'HEM', 'ON RE IONAL', ...
                        'SEPH  O', 'FAN', 'O', 'TCHELL', 'FLD', ...
                        'BELL FLD', 'R TER INAL'}
                    append = 1;
                    nm = [nm, vv];
                    vv = 'UNITED STATES';
                case 'BAHAMAS'
                    vv = 'BF';
                case {'DOMINICAN REP', 'DOMINICAN REPU'}
                    vv = 'DOMINICAN REPUBLIC';
                case 'HONDU AS'
                    vv = 'HONDURAS';
                case {'NETH. ANTILLE', 'ANTIL ES'}
                    vv = 'NETHERLANDS ANTILLES';
                case 'GUADE OUPE'
                    vv = 'GUADELOUPE';
                case 'MARTI IQUE'
                    vv = 'MARTINIQUE';
                case 'TRINIDAD AND'
                    vv = 'TD';
                case 'BRAZI'
                    vv = 'BRAZIL';
                case {'ECUAD R', 'ECUAD'}
                    vv = 'ECUADOR';
                case 'BOLIV A'
                    vv = 'BOLIVIA';
                case 'PARAG AY'
                    vv = 'PARAGUAY';
                case 'ISLA DE PASCU'
                    vv = 'CHILE'; %Easter Island
                case 'URUGU Y'
                    vv = 'URUGUAY';
                case {'ARGEN INA', 'ARGEN'}
                    vv = 'ARGENTINA';
                case {'ANTAR', 'ANTARCTIC'}
                    vv = 'ANTARCTICA';
                case {'MARIANA ISLAN', 'MARIANA ISLAND', 'MARIANA IS.'}
                    vv = 'GUAM';
                case {'CAROLINE ISLA', 'CAROLINE ISLAN', 'CAROLINE IS.'}
                    vv = 'FM';
                case {'MARSHALL IS.'}
                    vv = 'MARSHALL ISLANDS';
                case 'US CENTRAL PA'
                    vv = 'U. S. MINOR ISLANDS';
                case {'SOLOMON ISLAND', 'SOLOMON ISLAN'}
                    vv = 'SOLOMON ISLANDS';
                case 'PALAU IS.'
                    vv = 'PALAU';
                case 'TOKELAU ISLAND'
                    vv = 'TOKELAU';
                case 'NIUE ISLAND'
                    vv = 'NIUE';
                case {'NEW HEBRIDES', 'NEW H'}
                    vv = 'VANUATU';
                case {'WALLIS ISLAND', 'WALLIS IS.'}
                    vv = 'WF';
                case {'FRENCH POLYNE', 'SOCIE Y IS.', 'SOCIETY IS.'}
                    vv = 'FRENCH POLYNESIA';
                case {'AUSTRAL IS.', 'AUSTRALIAN IS'}
                    vv = 'AUSTRALIA'; %Need better code
                case 'PACIFIC OC.'
                    continue;
                case {'PAPUA NEW GUI', 'PAPUA NEW GUIN'}
                    vv = 'PAPUA NEW GUINEA';
                case 'NEW Z ALAND'
                    vv = 'NEW ZEALAND';
                case {'E', 'T OFFICE)'}
                    append = 1;
                    vv = 'AUSTRALIA';
                case {'INDON SIA', 'INDON'}
                    vv = 'INDONESIA';
                case 'GUATE'
                    vv = 'GUATEMALA';
                case 'VENEZUALA'
                    vv = 'VENEZUELA';
                case 'SURINAM'
                    vv = 'SURINAME';
                case 'FR. GUIANA'
                    vv = 'FRENCH GUIANA';
                case {'ST. THOMAS', 'ST. CROIX'}
                    vv = 'VQ';
                case {'PHILI PINES', 'PHILI'}
                    vv = 'PHILIPPINES';
            end
            
            if append == 1
                nm = [nm, orig];
            end
            
            try
                country = country_codes_dictionary( vv );
            catch
                st
                error(lasterr);
            end
            
            if country == country_codes_dictionary( 'UNITED STATES' );
                if nm(3) == ' '
                    state = nm(1:2);
                    nm = nm(4:end);
                end
            end
        case 'lat'
            lat = str2double( values{k} );
            if lat == -99.9
                lat = NaN;
            end
        case 'long'
            long = -str2double( values{k} );
            if long == -199.9
                long = NaN;
            end
        case 'height'
            elev = str2double( values{k} );
            if elev == -99 || elev == -999
                elev = NaN;
            end
    end
end

mn.country = country;
mn.state = state;
mn.name = {nm};

if isnan(lat) || isnan(long)
    mn.location = geoPoint2();
else
    if isnan(elev)
        elev_unc = NaN;
    else
        elev_unc = 0.5;
    end
    mn.location = geoPoint2( lat, long, elev, 0.05, 0.05, elev_unc );
end

mn.ids{end+1} = ['hadcru_' num2str( str2double( id ) )];

mn.archive_key = ['HadCRU_' num2str( str2double( id ) )];

mn.source = stationSourceType( 'HadCRU' );
