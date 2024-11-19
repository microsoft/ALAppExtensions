codeunit 5563 "Contoso Language"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata Language = rim;

    var
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertLanguage(Code: Code[10]; Name: Text[50])
    var
        Language: Record Language;
        WindowsLang: Record "Windows Language";
        Exists: Boolean;
    begin
        if Language.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        Language.Validate(Code, Code);
        Language.Validate(Name, Name);

        WindowsLang.Reset();
        WindowsLang.SetCurrentKey("Abbreviated Name");
        WindowsLang.SetFilter("Abbreviated Name", Code);
        WindowsLang.FindFirst();

        Language.Validate("Windows Language ID", WindowsLang."Language ID");

        if Exists then
            Language.Modify(true)
        else
            Language.Insert(true);

        WindowsLang.Reset();
    end;

    procedure GetLanguageCode(CountryCode: Code[10]): Code[10]
    var
        LanguageCountryPair: Dictionary of [Text[10], Text[10]];
    begin
        LanguageCountryPair := GetLanguageCountryPair();

        if LanguageCountryPair.ContainsKey(UpperCase(CountryCode)) then
            exit(LanguageCountryPair.Get(CountryCode))
        else
            exit('ENU');
    end;

    local procedure GetLanguageCountryPair() LanguageCountryPair: Dictionary of [Text[10], Text[10]]
    begin
        LanguageCountryPair.Add('AT', 'DEA');
        LanguageCountryPair.Add('AU', 'ENA');
        LanguageCountryPair.Add('BE', 'NLB');
        LanguageCountryPair.Add('BG', 'BGR');
        LanguageCountryPair.Add('BR', 'PTB');
        LanguageCountryPair.Add('CA', 'ENC');
        LanguageCountryPair.Add('CH', 'DES');
        LanguageCountryPair.Add('CO', 'ESO');
        LanguageCountryPair.Add('CZ', 'CSY');
        LanguageCountryPair.Add('DE', 'DEU');
        LanguageCountryPair.Add('DK', 'DAN');
        LanguageCountryPair.Add('ES', 'ESP');
        LanguageCountryPair.Add('ET', 'ETI');
        LanguageCountryPair.Add('FI', 'FIN');
        LanguageCountryPair.Add('FR', 'FRA');
        LanguageCountryPair.Add('GB', 'ENG');
        LanguageCountryPair.Add('GR', 'ELL');
        LanguageCountryPair.Add('HR', 'HRV');
        LanguageCountryPair.Add('HU', 'HUN');
        LanguageCountryPair.Add('ID', 'IND');
        LanguageCountryPair.Add('IE', 'ENI');
        LanguageCountryPair.Add('IN', 'ENG');
        LanguageCountryPair.Add('IS', 'ISL');
        LanguageCountryPair.Add('IT', 'ITA');
        LanguageCountryPair.Add('LT', 'LTH');
        LanguageCountryPair.Add('LV', 'LVI');
        LanguageCountryPair.Add('MX', 'ESM');
        LanguageCountryPair.Add('MY', 'ENU');
        LanguageCountryPair.Add('NL', 'NLD');
        LanguageCountryPair.Add('NO', 'NOR');
        LanguageCountryPair.Add('NZ', 'ENZ');
        LanguageCountryPair.Add('PE', 'ESR');
        LanguageCountryPair.Add('PL', 'PLK');
        LanguageCountryPair.Add('PT', 'PTG');
        LanguageCountryPair.Add('RO', 'ROM');
        LanguageCountryPair.Add('RS', 'SRP');
        LanguageCountryPair.Add('RU', 'RUS');
        LanguageCountryPair.Add('SE', 'SVE');
        LanguageCountryPair.Add('SI', 'SLV');
        LanguageCountryPair.Add('SG', 'ENU');
        LanguageCountryPair.Add('SK', 'SKY');
        LanguageCountryPair.Add('TH', 'THA');
        LanguageCountryPair.Add('TR', 'TRK');
        LanguageCountryPair.Add('UA', 'UKR');
        LanguageCountryPair.Add('US', 'ENU');
        LanguageCountryPair.Add('ZA', 'ENU');
        LanguageCountryPair.Add('ZH', 'CHS');
    end;
}