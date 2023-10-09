namespace Microsoft.DataMigration.GP;

table 40140 "GP Known Countries"
{
    Caption = 'GP Known Countries';
    DataClassification = SystemMetadata;
    DataPerCompany = false;

    fields
    {
        field(1; ISO3; Code[3])
        {
            Caption = 'ISO3';
        }
        field(2; ISO2; Code[2])
        {
            Caption = 'ISO2';
        }
        field(3; Name; Text[50])
        {
            Caption = 'Name';
        }
    }
    keys
    {
        key(PK; ISO3)
        {
            Clustered = true;
        }
        key(K2; ISO2)
        {
        }
        key(K3; Name)
        {
        }
    }

    local procedure EnsureData()
    begin
        Clear(Rec);
        if Rec.IsEmpty() then begin
            AddKnownCountry('ABW', 'AW', 'Aruba');
            AddKnownCountry('AFG', 'AF', 'Afghanistan');
            AddKnownCountry('AGO', 'AO', 'Angola');
            AddKnownCountry('AIA', 'AI', 'Anguilla');
            AddKnownCountry('ALA', 'AX', 'Aland Islands');
            AddKnownCountry('ALB', 'AL', 'Albania');
            AddKnownCountry('AND', 'AD', 'Andorra');
            AddKnownCountry('ARE', 'AE', 'United Arab Emirates');
            AddKnownCountry('ARG', 'AR', 'Argentina');
            AddKnownCountry('ARM', 'AM', 'Armenia');
            AddKnownCountry('ASM', 'AS', 'American Samoa');
            AddKnownCountry('ATA', 'AQ', 'Antarctica');
            AddKnownCountry('ATF', 'TF', 'French Southern Territories');
            AddKnownCountry('ATG', 'AG', 'Antigua And Barbuda');
            AddKnownCountry('AUS', 'AU', 'Australia');
            AddKnownCountry('AUT', 'AT', 'Austria');
            AddKnownCountry('AZE', 'AZ', 'Azerbaijan');
            AddKnownCountry('BDI', 'BI', 'Burundi');
            AddKnownCountry('BEL', 'BE', 'Belgium');
            AddKnownCountry('BEN', 'BJ', 'Benin');
            AddKnownCountry('BES', 'BQ', 'Bonaire, Sint Eustatius and Saba');
            AddKnownCountry('BFA', 'BF', 'Burkina Faso');
            AddKnownCountry('BGD', 'BD', 'Bangladesh');
            AddKnownCountry('BGR', 'BG', 'Bulgaria');
            AddKnownCountry('BHR', 'BH', 'Bahrain');
            AddKnownCountry('BHS', 'BS', 'The Bahamas');
            AddKnownCountry('BIH', 'BA', 'Bosnia and Herzegovina');
            AddKnownCountry('BLM', 'BL', 'Saint-Barthelemy');
            AddKnownCountry('BLR', 'BY', 'Belarus');
            AddKnownCountry('BLZ', 'BZ', 'Belize');
            AddKnownCountry('BMU', 'BM', 'Bermuda');
            AddKnownCountry('BOL', 'BO', 'Bolivia');
            AddKnownCountry('BRA', 'BR', 'Brazil');
            AddKnownCountry('BRB', 'BB', 'Barbados');
            AddKnownCountry('BRN', 'BN', 'Brunei');
            AddKnownCountry('BTN', 'BT', 'Bhutan');
            AddKnownCountry('BVT', 'BV', 'Bouvet Island');
            AddKnownCountry('BWA', 'BW', 'Botswana');
            AddKnownCountry('CAF', 'CF', 'Central African Republic');
            AddKnownCountry('CAN', 'CA', 'Canada');
            AddKnownCountry('CCK', 'CC', 'Cocos (Keeling) Islands');
            AddKnownCountry('CHE', 'CH', 'Switzerland');
            AddKnownCountry('CHL', 'CL', 'Chile');
            AddKnownCountry('CHN', 'CN', 'China');
            AddKnownCountry('CIV', 'CI', 'Cote d''Ivoire');
            AddKnownCountry('CMR', 'CM', 'Cameroon');
            AddKnownCountry('COD', 'CD', 'Democratic Republic of the Congo');
            AddKnownCountry('COG', 'CG', 'Congo');
            AddKnownCountry('COK', 'CK', 'Cook Islands');
            AddKnownCountry('COL', 'CO', 'Colombia');
            AddKnownCountry('COM', 'KM', 'Comoros');
            AddKnownCountry('CPV', 'CV', 'Cape Verde');
            AddKnownCountry('CRI', 'CR', 'Costa Rica');
            AddKnownCountry('CUB', 'CU', 'Cuba');
            AddKnownCountry('CUW', 'CW', 'Curacao');
            AddKnownCountry('CXR', 'CX', 'Christmas Island');
            AddKnownCountry('CYM', 'KY', 'Cayman Islands');
            AddKnownCountry('CYP', 'CY', 'Cyprus');
            AddKnownCountry('CZE', 'CZ', 'Czech Republic');
            AddKnownCountry('DEU', 'DE', 'Germany');
            AddKnownCountry('DJI', 'DJ', 'Djibouti');
            AddKnownCountry('DMA', 'DM', 'Dominica');
            AddKnownCountry('DNK', 'DK', 'Denmark');
            AddKnownCountry('DOM', 'DO', 'Dominican Republic');
            AddKnownCountry('DZA', 'DZ', 'Algeria');
            AddKnownCountry('ECU', 'EC', 'Ecuador');
            AddKnownCountry('EGY', 'EG', 'Egypt');
            AddKnownCountry('ERI', 'ER', 'Eritrea');
            AddKnownCountry('ESH', 'EH', 'Western Sahara');
            AddKnownCountry('ESP', 'ES', 'Spain');
            AddKnownCountry('EST', 'EE', 'Estonia');
            AddKnownCountry('ETH', 'ET', 'Ethiopia');
            AddKnownCountry('FIN', 'FI', 'Finland');
            AddKnownCountry('FJI', 'FJ', 'Fiji Islands');
            AddKnownCountry('FLK', 'FK', 'Falkland Islands');
            AddKnownCountry('FRA', 'FR', 'France');
            AddKnownCountry('FRO', 'FO', 'Faroe Islands');
            AddKnownCountry('FSM', 'FM', 'Micronesia');
            AddKnownCountry('GAB', 'GA', 'Gabon');
            AddKnownCountry('GBR', 'GB', 'United Kingdom');
            AddKnownCountry('GEO', 'GE', 'Georgia');
            AddKnownCountry('GGY', 'GG', 'Guernsey and Alderney');
            AddKnownCountry('GHA', 'GH', 'Ghana');
            AddKnownCountry('GIB', 'GI', 'Gibraltar');
            AddKnownCountry('GIN', 'GN', 'Guinea');
            AddKnownCountry('GLP', 'GP', 'Guadeloupe');
            AddKnownCountry('GMB', 'GM', 'Gambia The');
            AddKnownCountry('GNB', 'GW', 'Guinea-Bissau');
            AddKnownCountry('GNQ', 'GQ', 'Equatorial Guinea');
            AddKnownCountry('GRC', 'GR', 'Greece');
            AddKnownCountry('GRD', 'GD', 'Grenada');
            AddKnownCountry('GRL', 'GL', 'Greenland');
            AddKnownCountry('GTM', 'GT', 'Guatemala');
            AddKnownCountry('GUF', 'GF', 'French Guiana');
            AddKnownCountry('GUM', 'GU', 'Guam');
            AddKnownCountry('GUY', 'GY', 'Guyana');
            AddKnownCountry('HKG', 'HK', 'Hong Kong (SAR)');
            AddKnownCountry('HMD', 'HM', 'Heard Island and McDonald Islands');
            AddKnownCountry('HND', 'HN', 'Honduras');
            AddKnownCountry('HRV', 'HR', 'Croatia');
            AddKnownCountry('HTI', 'HT', 'Haiti');
            AddKnownCountry('HUN', 'HU', 'Hungary');
            AddKnownCountry('IDN', 'ID', 'Indonesia');
            AddKnownCountry('IMN', 'IM', 'Isle of Man');
            AddKnownCountry('IND', 'IN', 'India');
            AddKnownCountry('IOT', 'IO', 'British Indian Ocean Territory');
            AddKnownCountry('IRL', 'IE', 'Ireland');
            AddKnownCountry('IRN', 'IR', 'Iran');
            AddKnownCountry('IRQ', 'IQ', 'Iraq');
            AddKnownCountry('ISL', 'IS', 'Iceland');
            AddKnownCountry('ISR', 'IL', 'Israel');
            AddKnownCountry('ITA', 'IT', 'Italy');
            AddKnownCountry('JAM', 'JM', 'Jamaica');
            AddKnownCountry('JEY', 'JE', 'Jersey');
            AddKnownCountry('JOR', 'JO', 'Jordan');
            AddKnownCountry('JPN', 'JP', 'Japan');
            AddKnownCountry('KAZ', 'KZ', 'Kazakhstan');
            AddKnownCountry('KEN', 'KE', 'Kenya');
            AddKnownCountry('KGZ', 'KG', 'Kyrgyzstan');
            AddKnownCountry('KHM', 'KH', 'Cambodia');
            AddKnownCountry('KIR', 'KI', 'Kiribati');
            AddKnownCountry('KNA', 'KN', 'Saint Kitts And Nevis');
            AddKnownCountry('KOR', 'KR', 'South Korea');
            AddKnownCountry('KWT', 'KW', 'Kuwait');
            AddKnownCountry('LAO', 'LA', 'Laos');
            AddKnownCountry('LBN', 'LB', 'Lebanon');
            AddKnownCountry('LBR', 'LR', 'Liberia');
            AddKnownCountry('LBY', 'LY', 'Libya');
            AddKnownCountry('LCA', 'LC', 'Saint Lucia');
            AddKnownCountry('LIE', 'LI', 'Liechtenstein');
            AddKnownCountry('LKA', 'LK', 'Sri Lanka');
            AddKnownCountry('LSO', 'LS', 'Lesotho');
            AddKnownCountry('LTU', 'LT', 'Lithuania');
            AddKnownCountry('LUX', 'LU', 'Luxembourg');
            AddKnownCountry('LVA', 'LV', 'Latvia');
            AddKnownCountry('MAC', 'MO', 'Macau (SAR)');
            AddKnownCountry('MAF', 'MF', 'Saint-Martin (French part)');
            AddKnownCountry('MAR', 'MA', 'Morocco');
            AddKnownCountry('MCO', 'MC', 'Monaco');
            AddKnownCountry('MDA', 'MD', 'Moldova');
            AddKnownCountry('MDG', 'MG', 'Madagascar');
            AddKnownCountry('MDV', 'MV', 'Maldives');
            AddKnownCountry('MEX', 'MX', 'Mexico');
            AddKnownCountry('MHL', 'MH', 'Marshall Islands');
            AddKnownCountry('MKD', 'MK', 'North Macedonia');
            AddKnownCountry('MLI', 'ML', 'Mali');
            AddKnownCountry('MLT', 'MT', 'Malta');
            AddKnownCountry('MMR', 'MM', 'Myanmar');
            AddKnownCountry('MNE', 'ME', 'Montenegro');
            AddKnownCountry('MNG', 'MN', 'Mongolia');
            AddKnownCountry('MNP', 'MP', 'Northern Mariana Islands');
            AddKnownCountry('MOZ', 'MZ', 'Mozambique');
            AddKnownCountry('MRT', 'MR', 'Mauritania');
            AddKnownCountry('MSR', 'MS', 'Montserrat');
            AddKnownCountry('MTQ', 'MQ', 'Martinique');
            AddKnownCountry('MUS', 'MU', 'Mauritius');
            AddKnownCountry('MWI', 'MW', 'Malawi');
            AddKnownCountry('MYS', 'MY', 'Malaysia');
            AddKnownCountry('MYT', 'YT', 'Mayotte');
            AddKnownCountry('NAM', 'NA', 'Namibia');
            AddKnownCountry('NCL', 'NC', 'New Caledonia');
            AddKnownCountry('NER', 'NE', 'Niger');
            AddKnownCountry('NFK', 'NF', 'Norfolk Island');
            AddKnownCountry('NGA', 'NG', 'Nigeria');
            AddKnownCountry('NIC', 'NI', 'Nicaragua');
            AddKnownCountry('NIU', 'NU', 'Niue');
            AddKnownCountry('NLD', 'NL', 'Netherlands');
            AddKnownCountry('NOR', 'NO', 'Norway');
            AddKnownCountry('NPL', 'NP', 'Nepal');
            AddKnownCountry('NRU', 'NR', 'Nauru');
            AddKnownCountry('NZL', 'NZ', 'New Zealand');
            AddKnownCountry('OMN', 'OM', 'Oman');
            AddKnownCountry('PAK', 'PK', 'Pakistan');
            AddKnownCountry('PAN', 'PA', 'Panama');
            AddKnownCountry('PCN', 'PN', 'Pitcairn Island');
            AddKnownCountry('PER', 'PE', 'Peru');
            AddKnownCountry('PHL', 'PH', 'Philippines');
            AddKnownCountry('PLW', 'PW', 'Palau');
            AddKnownCountry('PNG', 'PG', 'Papua new Guinea');
            AddKnownCountry('POL', 'PL', 'Poland');
            AddKnownCountry('PRI', 'PR', 'Puerto Rico');
            AddKnownCountry('PRK', 'KP', 'North Korea');
            AddKnownCountry('PRT', 'PT', 'Portugal');
            AddKnownCountry('PRY', 'PY', 'Paraguay');
            AddKnownCountry('PSE', 'PS', 'Palestinian Territory Occupied');
            AddKnownCountry('PYF', 'PF', 'French Polynesia');
            AddKnownCountry('QAT', 'QA', 'Qatar');
            AddKnownCountry('REU', 'RE', 'Reunion');
            AddKnownCountry('ROU', 'RO', 'Romania');
            AddKnownCountry('RUS', 'RU', 'Russia');
            AddKnownCountry('RWA', 'RW', 'Rwanda');
            AddKnownCountry('SAU', 'SA', 'Saudi Arabia');
            AddKnownCountry('SDN', 'SD', 'Sudan');
            AddKnownCountry('SEN', 'SN', 'Senegal');
            AddKnownCountry('SGP', 'SG', 'Singapore');
            AddKnownCountry('SGS', 'GS', 'South Georgia');
            AddKnownCountry('SHN', 'SH', 'Saint Helena');
            AddKnownCountry('SJM', 'SJ', 'Svalbard and Jan Mayen');
            AddKnownCountry('SLB', 'SB', 'Solomon Islands');
            AddKnownCountry('SLE', 'SL', 'Sierra Leone');
            AddKnownCountry('SLV', 'SV', 'El Salvador');
            AddKnownCountry('SMR', 'SM', 'San Marino');
            AddKnownCountry('SOM', 'SO', 'Somalia');
            AddKnownCountry('SPM', 'PM', 'Saint Pierre and Miquelon');
            AddKnownCountry('SRB', 'RS', 'Serbia');
            AddKnownCountry('STP', 'ST', 'Sao Tome and Principe');
            AddKnownCountry('SUR', 'SR', 'Suriname');
            AddKnownCountry('SVK', 'SK', 'Slovakia');
            AddKnownCountry('SVN', 'SI', 'Slovenia');
            AddKnownCountry('SWE', 'SE', 'Sweden');
            AddKnownCountry('SWZ', 'SZ', 'Swaziland');
            AddKnownCountry('SXM', 'SX', 'Sint Maarten');
            AddKnownCountry('SYC', 'SC', 'Seychelles');
            AddKnownCountry('SYR', 'SY', 'Syria');
            AddKnownCountry('TCA', 'TC', 'Turks And Caicos Islands');
            AddKnownCountry('TCD', 'TD', 'Chad');
            AddKnownCountry('TGO', 'TG', 'Togo');
            AddKnownCountry('THA', 'TH', 'Thailand');
            AddKnownCountry('TJK', 'TJ', 'Tajikistan');
            AddKnownCountry('TKL', 'TK', 'Tokelau');
            AddKnownCountry('TKM', 'TM', 'Turkmenistan');
            AddKnownCountry('TLS', 'TL', 'East Timor');
            AddKnownCountry('TON', 'TO', 'Tonga');
            AddKnownCountry('TTO', 'TT', 'Trinidad And Tobago');
            AddKnownCountry('TUN', 'TN', 'Tunisia');
            AddKnownCountry('TUR', 'TR', 'Turkey');
            AddKnownCountry('TUV', 'TV', 'Tuvalu');
            AddKnownCountry('TWN', 'TW', 'Taiwan');
            AddKnownCountry('TZA', 'TZ', 'Tanzania');
            AddKnownCountry('UGA', 'UG', 'Uganda');
            AddKnownCountry('UKR', 'UA', 'Ukraine');
            AddKnownCountry('UMI', 'UM', 'U.S. Minor Outlying Islands');
            AddKnownCountry('URY', 'UY', 'Uruguay');
            AddKnownCountry('USA', 'US', 'United States');
            AddKnownCountry('UZB', 'UZ', 'Uzbekistan');
            AddKnownCountry('VAT', 'VA', 'Holy See (Vatican City)');
            AddKnownCountry('VCT', 'VC', 'Saint Vincent And The Grenadines');
            AddKnownCountry('VEN', 'VE', 'Venezuela');
            AddKnownCountry('VGB', 'VG', 'British Virgin Islands');
            AddKnownCountry('VIR', 'VI', 'U.S. Virgin Islands');
            AddKnownCountry('VNM', 'VN', 'Vietnam');
            AddKnownCountry('VUT', 'VU', 'Vanuatu');
            AddKnownCountry('WLF', 'WF', 'Wallis and Futuna');
            AddKnownCountry('WSM', 'WS', 'Samoa');
            AddKnownCountry('YEM', 'YE', 'Yemen');
            AddKnownCountry('ZAF', 'ZA', 'South Africa');
            AddKnownCountry('ZMB', 'ZM', 'Zambia');
            AddKnownCountry('ZWE', 'ZW', 'Zimbabwe');
        end;
    end;

    local procedure AddKnownCountry(ISO3Code: Code[3]; ISO2Code: Code[2]; CountryName: Text[50])
    begin
        Clear(Rec);
        Rec.ISO3 := ISO3Code;
        Rec.ISO2 := ISO2Code;
        Rec.Name := CountryName;
        Rec.Insert();
    end;

    procedure SearchKnownCountry(SearchString: Text[75]; var Found: Boolean; var ResultISO2: Code[2]; var ResultCountryName: Text[50])
    var
        TrimmedSearchString: Text[75];
    begin
        EnsureData();
        Clear(Found);
        Clear(ResultISO2);
        Clear(ResultCountryName);

        TrimmedSearchString := CopyStr(SearchString.Trim(), 1, MaxStrLen(TrimmedSearchString));
        if TrimmedSearchString = '' then
            exit;

        Rec.Reset();
        if StrLen(TrimmedSearchString) = 2 then begin
            Rec.SetRange(ISO2, TrimmedSearchString);
            Found := Rec.FindFirst();
            if Found then begin
                ResultISO2 := Rec.ISO2;
                ResultCountryName := Rec.Name;
                exit;
            end;
        end;

        Rec.Reset();
        if StrLen(TrimmedSearchString) = 3 then begin
            Rec.SetRange(ISO3, TrimmedSearchString);
            Found := Rec.FindFirst();
            if Found then begin
                ResultISO2 := Rec.ISO2;
                ResultCountryName := Rec.Name;
                exit;
            end;
        end;

        Rec.Reset();
        Rec.SetFilter(Name, '@' + TrimmedSearchString + '*');
        Found := Rec.FindFirst();
        if Found then begin
            ResultISO2 := Rec.ISO2;
            ResultCountryName := Rec.Name;
            exit;
        end;
    end;
}