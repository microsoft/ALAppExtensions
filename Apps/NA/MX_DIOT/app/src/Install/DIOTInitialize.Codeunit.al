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

    local procedure InsertDefaultDIOTCountryData()
    begin
        InsertDIOTCountryData('AD', 'Principado de Andorra', '--');
        InsertDIOTCountryData('AE', 'Emiratos Arabes Unidos', '--');
        InsertDIOTCountryData('AF', 'Afganistan', '--');
        InsertDIOTCountryData('AG', 'Antigua y Bermuda', '--');
        InsertDIOTCountryData('AI', 'Isla Anguilla', '--');
        InsertDIOTCountryData('AL', 'Republica de Albania', '--');
        InsertDIOTCountryData('AN', 'Antillas Neerlandesas', '--');
        InsertDIOTCountryData('AO', 'Republica de Angola', '--');
        InsertDIOTCountryData('AQ', 'Antartica', '--');
        InsertDIOTCountryData('AR', 'Argentina', '--');
        InsertDIOTCountryData('AS', 'Samoa Americana', '--');
        InsertDIOTCountryData('AT', 'Austria', '--');
        InsertDIOTCountryData('AU', 'Australia', '--');
        InsertDIOTCountryData('AW', 'Aruba', '--');
        InsertDIOTCountryData('AX', 'Ascension', '--');
        InsertDIOTCountryData('AZ', 'Islas Azores', '--');
        InsertDIOTCountryData('BB', 'Barbados', '--');
        InsertDIOTCountryData('BD', 'Bangladesh', '--');
        InsertDIOTCountryData('BE', 'Belgica', '--');
        InsertDIOTCountryData('BF', 'Burkina Faso', '--');
        InsertDIOTCountryData('BG', 'Bulgaria', '--');
        InsertDIOTCountryData('BH', 'Estado de Bahrein', '--');
        InsertDIOTCountryData('BI', 'Burundi', '--');
        InsertDIOTCountryData('BJ', 'Benin', '--');
        InsertDIOTCountryData('BL', 'Belice', '--');
        InsertDIOTCountryData('BM', 'Bermudas', '--');
        InsertDIOTCountryData('BN', 'Brunei Darussalam', '--');
        InsertDIOTCountryData('BO', 'Bolivia', '--');
        InsertDIOTCountryData('BR', 'Brasil', '--');
        InsertDIOTCountryData('BS', 'Commonwealth de las Bahamas', '--');
        InsertDIOTCountryData('BT', 'Buthan', '--');
        InsertDIOTCountryData('BU', 'Burma', '--');
        InsertDIOTCountryData('BV', 'Isla Bouvet', '--');
        InsertDIOTCountryData('BW', 'Botswana', '--');
        InsertDIOTCountryData('BY', 'Bielorrusia', '--');
        InsertDIOTCountryData('CA', 'Canada', '--');
        InsertDIOTCountryData('CC', 'Isla de Cocos o Kelling', '--');
        InsertDIOTCountryData('CD', 'Islas Canarias', '--');
        InsertDIOTCountryData('CE', 'Isla de Christmas', '--');
        InsertDIOTCountryData('CF', 'Republica Centro Africana', '--');
        InsertDIOTCountryData('CG', 'Congo', '--');
        InsertDIOTCountryData('CH', 'Suiza', '--');
        InsertDIOTCountryData('CI', 'Costa de Marfil', '--');
        InsertDIOTCountryData('CK', 'Islas Cook', '--');
        InsertDIOTCountryData('CL', 'Chile', '--');
        InsertDIOTCountryData('CM', 'Camerun', '--');
        InsertDIOTCountryData('CN', 'China', '--');
        InsertDIOTCountryData('CO', 'Colombia', '--');
        InsertDIOTCountryData('CP', 'Campione D''Italia', '--');
        InsertDIOTCountryData('CR', 'Republica de Costa Rica', '--');
        InsertDIOTCountryData('CS', 'Republica Checa y Republica Eslovaca', '--');
        InsertDIOTCountryData('CU', 'Cuba', '--');
        InsertDIOTCountryData('CV', 'Republica de Cabo Verde', '--');
        InsertDIOTCountryData('CX', 'Isla de Navidad', '--');
        InsertDIOTCountryData('CY', 'Republica de Chipre', '--');
        InsertDIOTCountryData('DD', 'Alemania', 'DE');
        InsertDIOTCountryData('DJ', 'Republica de Djibouti', '--');
        InsertDIOTCountryData('DK', 'Dinamarca', '--');
        InsertDIOTCountryData('DM', 'Republica Dominicana', '--');
        InsertDIOTCountryData('DN', 'Commonwealth de Dominica', '--');
        InsertDIOTCountryData('DZ', 'Argelia', '--');
        InsertDIOTCountryData('EC', 'Ecuador', '--');
        InsertDIOTCountryData('EG', 'Egipto', '--');
        InsertDIOTCountryData('EH', 'Sahara del Oeste', '--');
        InsertDIOTCountryData('EO', 'Estado Independiente de Samoa Occidental', '--');
        InsertDIOTCountryData('ES', 'Espana', '--');
        InsertDIOTCountryData('ET', 'Etiopia', '--');
        InsertDIOTCountryData('FI', 'Finlandia', '--');
        InsertDIOTCountryData('FJ', 'Fiji', '--');
        InsertDIOTCountryData('FK', 'Islas Malvinas', '--');
        InsertDIOTCountryData('FM', 'Micronesia', '--');
        InsertDIOTCountryData('FO', 'Islas Faroe', '--');
        InsertDIOTCountryData('FR', 'Francia', '--');
        InsertDIOTCountryData('GA', 'Gabon', '--');
        InsertDIOTCountryData('GB', 'Gran Bretana (Reino Unido)', '--');
        InsertDIOTCountryData('GD', 'Granada', '--');
        InsertDIOTCountryData('GF', 'Guyana Francesa', '--');
        InsertDIOTCountryData('GH', 'Ghana', '--');
        InsertDIOTCountryData('GI', 'Gibraltar', '--');
        InsertDIOTCountryData('GJ', 'Groenlandia', '--');
        InsertDIOTCountryData('GM', 'Gambia', '--');
        InsertDIOTCountryData('GN', 'Guinea', '--');
        InsertDIOTCountryData('GP', 'Guadalupe', '--');
        InsertDIOTCountryData('GQ', 'Guinea Ecuatorial', '--');
        InsertDIOTCountryData('GR', 'Grecia', '--');
        InsertDIOTCountryData('GT', 'Guatemala', '--');
        InsertDIOTCountryData('GU', 'Guam', '--');
        InsertDIOTCountryData('GW', 'Guinea Bissau', '--');
        InsertDIOTCountryData('GY', 'Republica de Guyana', '--');
        InsertDIOTCountryData('GZ', 'Islas de Guernesey, Jersey, Alderney, Isla Great Sark, Herm, Little Sark, Berchou, Jethou, Lihou (Islas del Canal)', '--');
        InsertDIOTCountryData('HK', 'Hong Kong', '--');
        InsertDIOTCountryData('HM', 'Islas Heard and Mc Donald', '--');
        InsertDIOTCountryData('HN', 'Republica de Honduras', '--');
        InsertDIOTCountryData('HT', 'Haiti', '--');
        InsertDIOTCountryData('HU', 'Hungria', '--');
        InsertDIOTCountryData('ID', 'Indonesia', '--');
        InsertDIOTCountryData('IE', 'Irlanda', '--');
        InsertDIOTCountryData('IH', 'Isla del Hombre', '--');
        InsertDIOTCountryData('IL', 'Israel', '--');
        InsertDIOTCountryData('IN', 'India', '--');
        InsertDIOTCountryData('IO', 'Territorio Britanico en el Oceano Indico', '--');
        InsertDIOTCountryData('IP', 'Islas Pacifico', '--');
        InsertDIOTCountryData('IQ', 'Iraq', '--');
        InsertDIOTCountryData('IR', 'Iran', '--');
        InsertDIOTCountryData('IS', 'Islandia', '--');
        InsertDIOTCountryData('IT', 'Italia', '--');
        InsertDIOTCountryData('JM', 'Jamaica', '--');
        InsertDIOTCountryData('JO', 'Reino Hachemita de Jordania', '--');
        InsertDIOTCountryData('JP', 'Japon', '--');
        InsertDIOTCountryData('KE', 'Kenia', '--');
        InsertDIOTCountryData('KH', 'Campuchea Democratica', '--');
        InsertDIOTCountryData('KI', 'Kiribati', '--');
        InsertDIOTCountryData('KM', 'Comoros', '--');
        InsertDIOTCountryData('KN', 'San Kitts', '--');
        InsertDIOTCountryData('KP', 'Republica Democratica de Corea', '--');
        InsertDIOTCountryData('KR', 'Republica de Corea', '--');
        InsertDIOTCountryData('KW', 'Estado de Kuwait', '--');
        InsertDIOTCountryData('KY', 'Islas Caiman', '--');
        InsertDIOTCountryData('LA', 'Republica Democratica de Laos', '--');
        InsertDIOTCountryData('LB', 'Libano', '--');
        InsertDIOTCountryData('LC', 'Santa Lucia', '--');
        InsertDIOTCountryData('LI', 'Principado de Liechtenstein', '--');
        InsertDIOTCountryData('LK', 'Republica Socialista Democratica de Sri Lanka', '--');
        InsertDIOTCountryData('LN', 'Labuan', '--');
        InsertDIOTCountryData('LR', 'Republica de Liberia', '--');
        InsertDIOTCountryData('LS', 'Lesotho', '--');
        InsertDIOTCountryData('LU', 'Gran Ducado de Luxemburgo', '--');
        InsertDIOTCountryData('LY', 'Libia', '--');
        InsertDIOTCountryData('MA', 'Marruecos', '--');
        InsertDIOTCountryData('MC', 'Principado de Monaco', '--');
        InsertDIOTCountryData('MD', 'Madeira', '--');
        InsertDIOTCountryData('MG', 'Madagascar', '--');
        InsertDIOTCountryData('MH', 'Republica de las Islas Marshall', '--');
        InsertDIOTCountryData('ML', 'Mali', '--');
        InsertDIOTCountryData('MN', 'Mongolia', '--');
        InsertDIOTCountryData('MO', 'Macao', '--');
        InsertDIOTCountryData('MP', 'Islas Marianas del Noreste', '--');
        InsertDIOTCountryData('MQ', 'Martinica', '--');
        InsertDIOTCountryData('MR', 'Mauritania', '--');
        InsertDIOTCountryData('MS', 'Monserrat', '--');
        InsertDIOTCountryData('MT', 'Malta', '--');
        InsertDIOTCountryData('MU', 'Republica de Mauricio', '--');
        InsertDIOTCountryData('MV', 'Republica de Maldivas', '--');
        InsertDIOTCountryData('MW', 'Malawi', '--');
        InsertDIOTCountryData('MY', 'Malasia', '--');
        InsertDIOTCountryData('MZ', 'Mozambique', '--');
        InsertDIOTCountryData('NA', 'Republica de Namibia', '--');
        InsertDIOTCountryData('NC', 'Nueva Caledonia', '--');
        InsertDIOTCountryData('NE', 'Niger', '--');
        InsertDIOTCountryData('NF', 'Isla de Norfolk', '--');
        InsertDIOTCountryData('NG', 'Nigeria', '--');
        InsertDIOTCountryData('NI', 'Nicaragua', '--');
        InsertDIOTCountryData('NL', 'Holanda', '--');
        InsertDIOTCountryData('NO', 'Noruega', '--');
        InsertDIOTCountryData('NP', 'Nepal', '--');
        InsertDIOTCountryData('NR', 'Republica de Nauru', '--');
        InsertDIOTCountryData('NT', 'Zona Neutral', '--');
        InsertDIOTCountryData('NU', 'Niue', '--');
        InsertDIOTCountryData('NV', 'Nevis', '--');
        InsertDIOTCountryData('NZ', 'Nueva Zelandia', '--');
        InsertDIOTCountryData('OM', 'Sultania de Oman', '--');
        InsertDIOTCountryData('PA', 'Republica de Panama', '--');
        InsertDIOTCountryData('PE', 'Peru', '--');
        InsertDIOTCountryData('PF', 'Polinesia Francesa', '--');
        InsertDIOTCountryData('PG', 'Papua Nueva Guinea', '--');
        InsertDIOTCountryData('PH', 'Filipinas', '--');
        InsertDIOTCountryData('PK', 'Pakistan', '--');
        InsertDIOTCountryData('PL', 'Polonia', '--');
        InsertDIOTCountryData('PM', 'Isla de San Pedro y Miguelon', '--');
        InsertDIOTCountryData('PN', 'Pitcairn', '--');
        InsertDIOTCountryData('PR', 'Estado Libre Asociado de Puerto Rico', '--');
        InsertDIOTCountryData('PT', 'Portugal', '--');
        InsertDIOTCountryData('PU', 'Patau', '--');
        InsertDIOTCountryData('PW', 'Palau', '--');
        InsertDIOTCountryData('PY', 'Paraguay', '--');
        InsertDIOTCountryData('QA', 'Estado de Quatar', '--');
        InsertDIOTCountryData('QB', 'Isla Qeshm', '--');
        InsertDIOTCountryData('RE', 'Reunion', '--');
        InsertDIOTCountryData('RO', 'Rumania', '--');
        InsertDIOTCountryData('RW', 'Rhuanda', '--');
        InsertDIOTCountryData('SA', 'Arabia Saudita', '--');
        InsertDIOTCountryData('SB', 'Islas Salomon', '--');
        InsertDIOTCountryData('SC', 'Seychelles Islas', '--');
        InsertDIOTCountryData('SD', 'Sudan', '--');
        InsertDIOTCountryData('SE', 'Suecia', '--');
        InsertDIOTCountryData('SG', 'Singapur', '--');
        InsertDIOTCountryData('SH', 'Santa Elena', '--');
        InsertDIOTCountryData('SI', 'Archipielago de Svalbard', '--');
        InsertDIOTCountryData('SJ', 'Islas Svalbard and Jan Mayen', '--');
        InsertDIOTCountryData('SK', 'Sark', '--');
        InsertDIOTCountryData('SL', 'Sierra Leona', '--');
        InsertDIOTCountryData('SM', 'Serenisima Republica de San Marino', '--');
        InsertDIOTCountryData('SN', 'Senegal', '--');
        InsertDIOTCountryData('SO', 'Somalia', '--');
        InsertDIOTCountryData('SR', 'Surinam', '--');
        InsertDIOTCountryData('ST', 'Sao Tome and Principe', '--');
        InsertDIOTCountryData('SU', 'Paises de la Ex-U.R.S.S., excepto Ucrania y Bielorusia', '--');
        InsertDIOTCountryData('SV', 'El Salvador', '--');
        InsertDIOTCountryData('SW', 'Republica de Seychelles', '--');
        InsertDIOTCountryData('SY', 'Siria', '--');
        InsertDIOTCountryData('SZ', 'Reino de Swazilandia', '--');
        InsertDIOTCountryData('TC', 'Islas Turcas y Caicos', '--');
        InsertDIOTCountryData('TD', 'Chad', '--');
        InsertDIOTCountryData('TF', 'Territorios Franceses del Sureste', '--');
        InsertDIOTCountryData('TG', 'Togo', '--');
        InsertDIOTCountryData('TH', 'Thailandia', '--');
        InsertDIOTCountryData('TK', 'Tokelau', '--');
        InsertDIOTCountryData('TN', 'Republica de Tunez', '--');
        InsertDIOTCountryData('TO', 'Reino de Tonga', '--');
        InsertDIOTCountryData('TP', 'Timor Este', '--');
        InsertDIOTCountryData('TR', 'Trieste', '--');
        InsertDIOTCountryData('TS', 'Tristan Da Cunha', '--');
        InsertDIOTCountryData('TT', 'Republica de Trinidad y Tobago', '--');
        InsertDIOTCountryData('TU', 'Turquia', '--');
        InsertDIOTCountryData('TV', 'Tuvalu', '--');
        InsertDIOTCountryData('TW', 'Taiwan', '--');
        InsertDIOTCountryData('TZ', 'Tanzania', '--');
        InsertDIOTCountryData('UA', 'Ucrania', '--');
        InsertDIOTCountryData('UG', 'Uganda', '--');
        InsertDIOTCountryData('UM', 'Islas menores alejadas de los Estados Unidos', '--');
        InsertDIOTCountryData('US', 'Estados Unidos de America', '--');
        InsertDIOTCountryData('UY', 'Republica Oriental del Uruguay', '--');
        InsertDIOTCountryData('VA', 'El Vaticano', '--');
        InsertDIOTCountryData('VC', 'San Vicente y Las Granadinas', '--');
        InsertDIOTCountryData('VE', 'Venezuela', '--');
        InsertDIOTCountryData('VG', 'Islas Virgenes Britanicas', '--');
        InsertDIOTCountryData('VI', 'Islas Virgenes de Estados Unidos de America', '--');
        InsertDIOTCountryData('VN', 'Vietnam', '--');
        InsertDIOTCountryData('VU', 'Republica de Vanuatu', '--');
        InsertDIOTCountryData('WF', 'Islas Wallis y Funtuna', '--');
        InsertDIOTCountryData('XX', 'Otro', '--');
        InsertDIOTCountryData('YD', 'Yemen Democratica', '--');
        InsertDIOTCountryData('YE', 'Republica del Yemen', '--');
        InsertDIOTCountryData('YU', 'Paises de la Ex-Yugoslavia', '--');
        InsertDIOTCountryData('ZA', 'Sudafrica', '--');
        InsertDIOTCountryData('ZC', 'Zona Especial Canaria', '--');
        InsertDIOTCountryData('ZM', 'Zambia', '--');
        InsertDIOTCountryData('ZO', 'Zona Libre Ostrava', '--');
        InsertDIOTCountryData('ZR', 'Zaire', '--');
        InsertDIOTCountryData('ZW', 'Zimbawe', '--');

    end;

    local procedure InsertDIOTCountryData(DIOTCountryCode: Code[2]; NewNationality: Text; CountryCode: Code[10])
    var
        DIOTCountryData: Record "DIOT Country/Region Data";
        DIOTDataMgt: Codeunit "DIOT Data Management";
    begin
        with DIOTCountryData do begin
            Init();
            "Country/Region Code" := DIOTCountryCode;
            Nationality := CopyStr(DIOTDataMgt.RemoveUnwantedCharacters(NewNationality, ' &´.'), 1, MaxStrLen(Nationality));
            "BC Country/Region Code" := CountryCode;
            if Insert(true) then;
        end;
    end;
}
