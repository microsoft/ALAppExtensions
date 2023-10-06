codeunit 5117 "Contoso Country Or Region"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Country/Region" = rim;

    var
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertCountryOrRegion(CountryOrRegionCode: Code[10]; CountryOrRegionCodeName: Text[50]; ISONumericCode: Code[3])
    var
        CountryOrRegion: Record "Country/Region";
        Exists: Boolean;
    begin
        if CountryOrRegion.Get(CountryOrRegionCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        CountryOrRegion.Validate(Code, CountryOrRegionCode);
        CountryOrRegion.Validate(Name, CountryOrRegionCodeName);
        CountryOrRegion.Validate("ISO Code", CopyStr(CountryOrRegionCode, 1, 2));
        CountryOrRegion.Validate("ISO Numeric Code", ISONumericCode);

        if Exists then
            CountryOrRegion.Modify(true)
        else
            CountryOrRegion.Insert(true);
    end;
}