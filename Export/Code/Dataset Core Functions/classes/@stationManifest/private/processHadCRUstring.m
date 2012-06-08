function mn = processHadCRUstring( mn, st )

global country_codes_dictionary;
if isempty(country_codes_dictionary)
    loadCountryCodes();
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
                 case {'RUSSIA (EUROPE)', 'RUSSIA (EUROP'}
                    vv = 'UE';
                 case 'KYRGYZ REPUBLI'
                    vv = 'KYRGYZSTAN';
                 case {'REPUBLIC OF U', 'REPUBLIC OF UZ'}
                    vv = 'UZBEKISTAN';
                 case 'LEBAN N'
                    vv = 'LEBANON';
                 case 'AFGHA'
                    vv = 'AFGHANISTAN';
                 case 'IZ) A PT' %WTF !!!!!!
                    vv = 'SAUDI ARABIA';
                 case {'EANDAMAN AND', 'ANDAMAN AND L'}
                    vv = 'INDIA'; %Andamann Islands
                 case 'AATAR' 
                    vv = 'MONGOLIA';
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
                case 'FRENCH SOUTHE'
                    vv = 'FS';
                case 'REUNION'
                    vv = 'RE';
                case 'MAURI IUS'
                    vv = 'MAURITIUS';
                case 'SOMAL'
                    vv = 'SOMALIA';
                case 'D.R. OF CONGO'
                    vv = 'ZAIRE';
                case 'CENTRAL AFRIC'
                    vv = 'CT';
                case 'CAMER ON'
                    vv = 'CAMEROON';
                case 'COTE-D''IVOIR'
                    vv = 'IV';
                case 'ANGOL'
                    vv = 'ANGOLA';
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
                    vv = 'UNITED STATES';
                    state = 'HI';
                case 'USA'
                    vv = 'UNITED STATES';                    
                case {'INTL', 'LLY', 'ELLER', 'WASH', ...
                        'PER', 'S', 'POINT', 'S FLD', 'NAL', ...
                        'I', 'ALKER FLD', 'HEM', 'ON RE IONAL', ...
                        'SEPH  O', 'FAN', 'O', 'TCHELL', 'FLD', ...
                        'BELL FLD', 'R TER INAL'}
                    nm = [nm, vv];
                    vv = 'UNITED STATES';
                case 'BAHAMAS'
                    vv = 'BF';                    
                case 'DOMINICAN REP'
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
                case 'ARGEN INA'
                    vv = 'ARGENTINA';                    
                case 'ANTAR'
                    vv = 'ANTARCTICA';                    
                case 'MARIANA ISLAN'
                    vv = 'GUAM';                    
                case 'CAROLINE ISLA'
                    vv = 'FM';                    
                case 'US CENTRAL PA'
                    vv = 'U. S. MINOR ISLANDS';                    
                case {'SOLOMON ISLAND', 'SOLOMON ISLAN'}
                    vv = 'SOLOMON ISLANDS';    
                case 'WALLIS ISLAND'
                    vv = 'WF';                    
                case 'FRENCH POLYNE'
                    vv = 'FRENCH POLYNESIA';                    
                case {'AUSTRAL IS.', 'AUSTRALIAN IS'}
                    vv = 'AUSTRALIA'; %Need better code                    
                case 'PACIFIC OC.'
                    continue;                 
                case 'PAPUA NEW GUI'
                    vv = 'PAPUA NEW GUINEA';                    
                case 'NEW Z ALAND'
                    vv = 'NEW ZEALAND';                    
                case {'E', 'T OFFICE)'}
                    vv = 'AUSTRALIA';                    
                case 'INDON SIA'
                    vv = 'INDONESIA';                    
                case {'PHILI PINES', 'PHILI'}
                    vv = 'PHILIPPINES';                    
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
    mn.location = geoPoint();
else
    mn.location = geoPoint( lat, long, elev );
end
    
mn.ids{end+1} = ['hadcru_' id];

v = stationID( stationSourceType('HadCRU'), id );
mn.ids{end+1} = ['uid_' num2str(v)];

mn.source = stationSourceType( 'HadCRU' );
