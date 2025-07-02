// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Foundation.Company;
using System.Environment;
using System.Privacy;

codeunit 27020 "DIOT - Initialize"
{
    Subtype = Install;

    var
        DIOTDataManagement: Codeunit "DIOT Data Management";

    trigger OnInstallAppPerCompany()
    begin
        if InitializeDone() then
            exit;

        InitializeCompany();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company-Initialize", 'OnCompanyInitialize', '', false, false)]
    local procedure InitializeCompany()
    begin
        ApplyEvaluationClassificationsForPrivacy();
        DIOTDataManagement.InsertDefaultDIOTConcepts();
        InsertDefaultDIOTCountryData();
    end;

    local procedure InitializeDone(): boolean
    var
        AppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        exit(AppInfo.DataVersion() <> Version.Create('0.0.0.0'));
    end;

    local procedure ApplyEvaluationClassificationsForPrivacy()
    var
        Company: Record Company;
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
    begin
        Company.Get(CompanyName());
        if not Company."Evaluation Company" then
            exit;

        DataClassificationMgt.SetTableFieldsToNormal(Database::"DIOT Concept");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"DIOT Concept Link");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"DIOT Country/Region Data");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"DIOT Report Vendor Buffer");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"DIOT Report Buffer");
    end;

    internal procedure InsertDefaultDIOTCountryData()
    begin
        InsertDIOTCountryData('AFG', 'Afganistán', 'AF');
        InsertDIOTCountryData('ALA', 'Islas Aland', 'AX');
        InsertDIOTCountryData('ALB', 'Albania', 'AL');
        InsertDIOTCountryData('DEU', 'Alemania', 'DE');
        InsertDIOTCountryData('AND', 'Andorra', 'AD');
        InsertDIOTCountryData('AGO', 'Angola', 'AO');
        InsertDIOTCountryData('AIA', 'Anguila', 'AI');
        InsertDIOTCountryData('ATA', 'Antártida', 'AQ');
        InsertDIOTCountryData('ATG', 'Antigua y Barbuda', 'AG');
        InsertDIOTCountryData('SAU', 'Arabia Saudita', 'SA');
        InsertDIOTCountryData('DZA', 'Argelia', 'DZ');
        InsertDIOTCountryData('ARG', 'Argentina', 'AR');
        InsertDIOTCountryData('ARM', 'Armenia', 'AM');
        InsertDIOTCountryData('ABW', 'Aruba', 'AW');
        InsertDIOTCountryData('AUS', 'Australia', 'AU');
        InsertDIOTCountryData('AUT', 'Austria', 'AT');
        InsertDIOTCountryData('AZE', 'Azerbaiyán', 'AZ');
        InsertDIOTCountryData('BHS', 'Bahamas (las)', 'BS');
        InsertDIOTCountryData('BGD', 'Bangladés', 'BD');
        InsertDIOTCountryData('BRB', 'Barbados', 'BB');
        InsertDIOTCountryData('BHR', 'Baréin', 'BH');
        InsertDIOTCountryData('BEL', 'Bélgica', 'BE');
        InsertDIOTCountryData('BLZ', 'Belice', 'BZ');
        InsertDIOTCountryData('BEN', 'Benín', 'BJ');
        InsertDIOTCountryData('BMU', 'Bermudas', 'BM');
        InsertDIOTCountryData('BLR', 'Bielorrusia', 'BY');
        InsertDIOTCountryData('MMR', 'Myanmar', 'MM');
        InsertDIOTCountryData('BOL', 'Bolivia, Estado Plurinacional de', 'BO');
        InsertDIOTCountryData('BIH', 'Bosnia y Herzegovina', 'BA');
        InsertDIOTCountryData('BWA', 'Botsuana', 'BW');
        InsertDIOTCountryData('BRA', 'Brasil', 'BR');
        InsertDIOTCountryData('BRN', 'Brunéi Darussalam', 'BN');
        InsertDIOTCountryData('BGR', 'Bulgaria', 'BG');
        InsertDIOTCountryData('BFA', 'Burkina Faso', 'BF');
        InsertDIOTCountryData('BDI', 'Burundi', 'BI');
        InsertDIOTCountryData('BTN', 'Bután', 'BT');
        InsertDIOTCountryData('CPV', 'Cabo Verde', 'CV');
        InsertDIOTCountryData('KHM', 'Camboya', 'KH');
        InsertDIOTCountryData('CMR', 'Camerún', 'CM');
        InsertDIOTCountryData('CAN', 'Canadá', 'CA');
        InsertDIOTCountryData('QAT', 'Catar', 'QA');
        InsertDIOTCountryData('BES', 'Bonaire, San Eustaquio y Saba', 'BQ');
        InsertDIOTCountryData('TCD', 'Chad', 'TD');
        InsertDIOTCountryData('CHL', 'Chile', 'CL');
        InsertDIOTCountryData('CHN', 'China', 'CN');
        InsertDIOTCountryData('CYP', 'Chipre', 'CY');
        InsertDIOTCountryData('COL', 'Colombia', 'CO');
        InsertDIOTCountryData('COM', 'Comoras', 'KM');
        InsertDIOTCountryData('PRK', 'Corea (la República Democrática Popular de)', 'KP');
        InsertDIOTCountryData('KOR', 'Corea (la República de)', 'KR');
        InsertDIOTCountryData('CIV', 'Côte d''Ivoire', 'CI');
        InsertDIOTCountryData('CRI', 'Costa Rica', 'CR');
        InsertDIOTCountryData('HRV', 'Croacia', 'HR');
        InsertDIOTCountryData('CUB', 'Cuba', 'CU');
        InsertDIOTCountryData('CUW', 'Curaçao', 'CW');
        InsertDIOTCountryData('DNK', 'Dinamarca', 'DK');
        InsertDIOTCountryData('DMA', 'Dominica', 'DM');
        InsertDIOTCountryData('ECU', 'Ecuador', 'EC');
        InsertDIOTCountryData('EGY', 'Egipto', 'EG');
        InsertDIOTCountryData('SLV', 'El Salvador', 'SV');
        InsertDIOTCountryData('ARE', 'Emiratos Árabes Unidos (Los)', 'AE');
        InsertDIOTCountryData('ERI', 'Eritrea', 'ER');
        InsertDIOTCountryData('SVK', 'Eslovaquia', 'SK');
        InsertDIOTCountryData('SVN', 'Eslovenia', 'SI');
        InsertDIOTCountryData('ESP', 'España', 'ES');
        InsertDIOTCountryData('USA', 'Estados Unidos (los)', 'US');
        InsertDIOTCountryData('EST', 'Estonia', 'EE');
        InsertDIOTCountryData('ETH', 'Etiopía', 'ET');
        InsertDIOTCountryData('PHL', 'Filipinas (las)', 'PH');
        InsertDIOTCountryData('FIN', 'Finlandia', 'FI');
        InsertDIOTCountryData('FJI', 'Fiyi', 'FJ');
        InsertDIOTCountryData('FRA', 'Francia', 'FR');
        InsertDIOTCountryData('GAB', 'Gabón', 'GA');
        InsertDIOTCountryData('GMB', 'Gambia (La)', 'GM');
        InsertDIOTCountryData('GEO', 'Georgia', 'GE');
        InsertDIOTCountryData('GHA', 'Ghana', 'GH');
        InsertDIOTCountryData('GIB', 'Gibraltar', 'GI');
        InsertDIOTCountryData('GRD', 'Granada', 'GD');
        InsertDIOTCountryData('GRC', 'Grecia', 'GR');
        InsertDIOTCountryData('GRL', 'Groenlandia', 'GL');
        InsertDIOTCountryData('GLP', 'Guadalupe', 'GP');
        InsertDIOTCountryData('GUM', 'Guam', 'GU');
        InsertDIOTCountryData('GTM', 'Guatemala', 'GT');
        InsertDIOTCountryData('GUF', 'Guayana Francesa', 'GF');
        InsertDIOTCountryData('GGY', 'Guernsey', 'GG');
        InsertDIOTCountryData('GIN', 'Guinea', 'GN');
        InsertDIOTCountryData('GNB', 'Guinea-Bisáu', 'GW');
        InsertDIOTCountryData('GNQ', 'Guinea Ecuatorial', 'GQ');
        InsertDIOTCountryData('GUY', 'Guyana', 'GY');
        InsertDIOTCountryData('HTI', 'Haití', 'HT');
        InsertDIOTCountryData('HND', 'Honduras', 'HN');
        InsertDIOTCountryData('HKG', 'Hong Kong', 'HK');
        InsertDIOTCountryData('HUN', 'Hungría', 'HU');
        InsertDIOTCountryData('IND', 'India', 'IN');
        InsertDIOTCountryData('IDN', 'Indonesia', 'ID');
        InsertDIOTCountryData('IRQ', 'Irak', 'IQ');
        InsertDIOTCountryData('IRN', 'Irán (la República Islámica de)', 'IR');
        InsertDIOTCountryData('IRL', 'Irlanda', 'IE');
        InsertDIOTCountryData('BVT', 'Isla Bouvet', 'BV');
        InsertDIOTCountryData('IMN', 'Isla de Man', 'IM');
        InsertDIOTCountryData('CXR', 'Isla de Navidad', 'CX');
        InsertDIOTCountryData('NFK', 'Isla Norfolk', 'NF');
        InsertDIOTCountryData('ISL', 'Islandia', 'IS');
        InsertDIOTCountryData('CYM', 'Islas Caimán (las)', 'KY');
        InsertDIOTCountryData('CCK', 'Islas Cocos (Keeling)', 'CC');
        InsertDIOTCountryData('COK', 'Islas Cook (las)', 'CK');
        InsertDIOTCountryData('FRO', 'Islas Feroe (las)', 'FO');
        InsertDIOTCountryData('SGS', 'Georgia del sur y las islas sandwich del sur', 'GS');
        InsertDIOTCountryData('HMD', 'Isla Heard e Islas McDonald', 'HM');
        InsertDIOTCountryData('FLK', 'Islas Malvinas [Falkland] (las)', 'FK');
        InsertDIOTCountryData('MNP', 'Islas Marianas del Norte (las)', 'MP');
        InsertDIOTCountryData('MHL', 'Islas Marshall (las)', 'MH');
        InsertDIOTCountryData('PCN', 'Pitcairn', 'PN');
        InsertDIOTCountryData('SLB', 'Islas Salomón (las)', 'SB');
        InsertDIOTCountryData('TCA', 'Islas Turcas y Caicos (las)', 'TC');
        InsertDIOTCountryData('UMI', 'Islas de Ultramar Menores de Estados Unidos (las)', 'UM');
        InsertDIOTCountryData('VGB', 'Islas Vírgenes (Británicas)', 'VG');
        InsertDIOTCountryData('VIR', 'Islas Vírgenes (EE.UU.)', 'VI');
        InsertDIOTCountryData('ISR', 'Israel', 'IL');
        InsertDIOTCountryData('ITA', 'Italia', 'IT');
        InsertDIOTCountryData('JAM', 'Jamaica', 'JM');
        InsertDIOTCountryData('JPN', 'Japón', 'JP');
        InsertDIOTCountryData('JEY', 'Jersey', 'JE');
        InsertDIOTCountryData('JOR', 'Jordania', 'JO');
        InsertDIOTCountryData('KAZ', 'Kazajistán', 'KZ');
        InsertDIOTCountryData('KEN', 'Kenia', 'KE');
        InsertDIOTCountryData('KGZ', 'Kirguistán', 'KG');
        InsertDIOTCountryData('KIR', 'Kiribati', 'KI');
        InsertDIOTCountryData('KWT', 'Kuwait', 'KW');
        InsertDIOTCountryData('LAO', 'Lao, (la) República Democrática Popular', 'LA');
        InsertDIOTCountryData('LSO', 'Lesoto', 'LS');
        InsertDIOTCountryData('LVA', 'Letonia', 'LV');
        InsertDIOTCountryData('LBN', 'Líbano', 'LB');
        InsertDIOTCountryData('LBR', 'Liberia', 'LR');
        InsertDIOTCountryData('LBY', 'Libia', 'LY');
        InsertDIOTCountryData('LIE', 'Liechtenstein', 'LI');
        InsertDIOTCountryData('LTU', 'Lituania', 'LT');
        InsertDIOTCountryData('LUX', 'Luxemburgo', 'LU');
        InsertDIOTCountryData('MAC', 'Macao', 'MO');
        InsertDIOTCountryData('MDG', 'Madagascar', 'MG');
        InsertDIOTCountryData('MYS', 'Malasia', 'MY');
        InsertDIOTCountryData('MWI', 'Malaui', 'MW');
        InsertDIOTCountryData('MDV', 'Maldivas', 'MV');
        InsertDIOTCountryData('MLI', 'Malí', 'ML');
        InsertDIOTCountryData('MLT', 'Malta', 'MT');
        InsertDIOTCountryData('MAR', 'Marruecos', 'MA');
        InsertDIOTCountryData('MTQ', 'Martinica', 'MQ');
        InsertDIOTCountryData('MUS', 'Mauricio', 'MU');
        InsertDIOTCountryData('MRT', 'Mauritania', 'MR');
        InsertDIOTCountryData('MYT', 'Mayotte', 'YT');
        InsertDIOTCountryData('FSM', 'Micronesia (los Estados Federados de)', 'FM');
        InsertDIOTCountryData('MDA', 'Moldavia (la República de)', 'MD');
        InsertDIOTCountryData('MCO', 'Mónaco', 'MC');
        InsertDIOTCountryData('MNG', 'Mongolia', 'MN');
        InsertDIOTCountryData('MNE', 'Montenegro', 'ME');
        InsertDIOTCountryData('MSR', 'Montserrat', 'MS');
        InsertDIOTCountryData('MOZ', 'Mozambique', 'MZ');
        InsertDIOTCountryData('NAM', 'Namibia', 'NA');
        InsertDIOTCountryData('NRU', 'Nauru', 'NR');
        InsertDIOTCountryData('NPL', 'Nepal', 'NP');
        InsertDIOTCountryData('NIC', 'Nicaragua', 'NI');
        InsertDIOTCountryData('NER', 'Níger (el)', 'NE');
        InsertDIOTCountryData('NGA', 'Nigeria', 'NG');
        InsertDIOTCountryData('NIU', 'Niue', 'NU');
        InsertDIOTCountryData('NOR', 'Noruega', 'NO');
        InsertDIOTCountryData('NCL', 'Nueva Caledonia', 'NC');
        InsertDIOTCountryData('NZL', 'Nueva Zelanda', 'NZ');
        InsertDIOTCountryData('OMN', 'Omán', 'OM');
        InsertDIOTCountryData('NLD', 'Países Bajos (los)', 'NL');
        InsertDIOTCountryData('PAK', 'Pakistán', 'PK');
        InsertDIOTCountryData('PLW', 'Palaos', 'PW');
        InsertDIOTCountryData('PSE', 'Palestina, Estado de', 'PS');
        InsertDIOTCountryData('PAN', 'Panamá', 'PA');
        InsertDIOTCountryData('PNG', 'Papúa Nueva Guinea', 'PG');
        InsertDIOTCountryData('PRY', 'Paraguay', 'PY');
        InsertDIOTCountryData('PER', 'Perú', 'PE');
        InsertDIOTCountryData('PYF', 'Polinesia Francesa', 'PF');
        InsertDIOTCountryData('POL', 'Polonia', 'PL');
        InsertDIOTCountryData('PRT', 'Portugal', 'PT');
        InsertDIOTCountryData('PRI', 'Puerto Rico', 'PR');
        InsertDIOTCountryData('GBR', 'Reino Unido (el)', 'GB');
        InsertDIOTCountryData('CAF', 'República Centroafricana (la)', 'CF');
        InsertDIOTCountryData('CZE', 'República Checa (la)', 'CZ');
        InsertDIOTCountryData('MKD', 'Macedonia (la antigua República Yugoslava de)', 'MK');
        InsertDIOTCountryData('COG', 'Congo', 'CG');
        InsertDIOTCountryData('COD', 'Congo (la República Democrática del)', 'CD');
        InsertDIOTCountryData('DOM', 'República Dominicana (la)', 'DO');
        InsertDIOTCountryData('REU', 'Reunión', 'RE');
        InsertDIOTCountryData('RWA', 'Ruanda', 'RW');
        InsertDIOTCountryData('ROU', 'Rumania', 'RO');
        InsertDIOTCountryData('RUS', 'Rusia, (la) Federación de', 'RU');
        InsertDIOTCountryData('ESH', 'Sahara Occidental', 'EH');
        InsertDIOTCountryData('WSM', 'Samoa', 'WS');
        InsertDIOTCountryData('ASM', 'Samoa Americana', 'AS');
        InsertDIOTCountryData('BLM', 'San Bartolomé', 'BL');
        InsertDIOTCountryData('KNA', 'San Cristóbal y Nieves', 'KN');
        InsertDIOTCountryData('SMR', 'San Marino', 'SM');
        InsertDIOTCountryData('MAF', 'San Martín (parte francesa)', 'MF');
        InsertDIOTCountryData('SPM', 'San Pedro y Miquelón', 'PM');
        InsertDIOTCountryData('VCT', 'San Vicente y las Granadinas', 'VC');
        InsertDIOTCountryData('SHN', 'Santa Helena, Ascensión y Tristán de Acuña', 'SH');
        InsertDIOTCountryData('LCA', 'Santa Lucía', 'LC');
        InsertDIOTCountryData('STP', 'Santo Tomé y Príncipe', 'ST');
        InsertDIOTCountryData('SEN', 'Senegal', 'SN');
        InsertDIOTCountryData('SRB', 'Serbia', 'RS');
        InsertDIOTCountryData('SYC', 'Seychelles', 'SC');
        InsertDIOTCountryData('SLE', 'Sierra leona', 'SL');
        InsertDIOTCountryData('SGP', 'Singapur', 'SG');
        InsertDIOTCountryData('SXM', 'Sint Maarten (parte holandesa)', 'SX');
        InsertDIOTCountryData('SYR', 'Siria, (la) República Árabe', 'SY');
        InsertDIOTCountryData('SOM', 'Somalia', 'SO');
        InsertDIOTCountryData('LKA', 'Sri Lanka', 'LK');
        InsertDIOTCountryData('SWZ', 'Suazilandia', 'SZ');
        InsertDIOTCountryData('ZAF', 'Sudáfrica', 'ZA');
        InsertDIOTCountryData('SDN', 'Sudán (el)', 'SD');
        InsertDIOTCountryData('SSD', 'Sudán del Sur', 'SS');
        InsertDIOTCountryData('SWE', 'Suecia', 'SE');
        InsertDIOTCountryData('CHE', 'Suiza', 'CH');
        InsertDIOTCountryData('SUR', 'Surinam', 'SR');
        InsertDIOTCountryData('SJM', 'Svalbard y Jan Mayen', 'SJ');
        InsertDIOTCountryData('THA', 'Tailandia', 'TH');
        InsertDIOTCountryData('TWN', 'Taiwán (Provincia de China)', 'TW');
        InsertDIOTCountryData('TZA', 'Tanzania, República Unida de', 'TZ');
        InsertDIOTCountryData('TJK', 'Tayikistán', 'TJ');
        InsertDIOTCountryData('IOT', 'Territorio Británico del Océano Índico (el)', 'IO');
        InsertDIOTCountryData('ATF', 'Territorios Australes Franceses (los)', 'TF');
        InsertDIOTCountryData('TLS', 'Timor-Leste', 'TL');
        InsertDIOTCountryData('TGO', 'Togo', 'TG');
        InsertDIOTCountryData('TKL', 'Tokelau', 'TK');
        InsertDIOTCountryData('TON', 'Tonga', 'TO');
        InsertDIOTCountryData('TTO', 'Trinidad y Tobago', 'TT');
        InsertDIOTCountryData('TUN', 'Túnez', 'TN');
        InsertDIOTCountryData('TKM', 'Turkmenistán', 'TM');
        InsertDIOTCountryData('TUR', 'Turquía', 'TR');
        InsertDIOTCountryData('TUV', 'Tuvalu', 'TV');
        InsertDIOTCountryData('UKR', 'Ucrania', 'UA');
        InsertDIOTCountryData('UGA', 'Uganda', 'UG');
        InsertDIOTCountryData('URY', 'Uruguay', 'UY');
        InsertDIOTCountryData('UZB', 'Uzbekistán', 'UZ');
        InsertDIOTCountryData('VUT', 'Vanuatu', 'VU');
        InsertDIOTCountryData('VAT', 'Santa Sede[Estado de la Ciudad del Vaticano] (la)', 'VA');
        InsertDIOTCountryData('VEN', 'Venezuela, República Bolivariana de', 'VE');
        InsertDIOTCountryData('VNM', 'Viet Nam', 'VN');
        InsertDIOTCountryData('WLF', 'Wallis y Futuna', 'WF');
        InsertDIOTCountryData('YEM', 'Yemen', 'YE');
        InsertDIOTCountryData('DJI', 'Yibuti', 'DJ');
        InsertDIOTCountryData('ZMB', 'Zambia', 'ZM');
        InsertDIOTCountryData('ZWE', 'Zimbabue', 'ZW');
        InsertDIOTCountryData('ZZZ', 'Otro', '--');
    end;

    local procedure InsertDIOTCountryData(DIOTCountryCode: Code[10]; NewNationality: Text; CountryCode: Code[2])
    var
        DIOTCountryData: Record "DIOT Country/Region Data";
        DIOTDataMgt: Codeunit "DIOT Data Management";
    begin
        with DIOTCountryData do begin
            Init();
            "Country/Region Code" := CountryCode;
            Nationality := CopyStr(DIOTDataMgt.RemoveUnwantedCharacters(NewNationality, ' &´.'), 1, MaxStrLen(Nationality));
            "BC Country/Region Code" := CountryCode;
            "ISO A-3 Country/Region Code" := DIOTCountryCode;
            if Insert(true) then;
        end;
    end;
}
