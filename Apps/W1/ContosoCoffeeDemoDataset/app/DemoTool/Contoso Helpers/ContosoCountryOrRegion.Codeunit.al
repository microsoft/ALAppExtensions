codeunit 5117 "Contoso Country Or Region"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Country/Region" = rim,
                tabledata "VAT Registration No. Format" = rim;

    var
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertCountryOrRegion(CountryOrRegionCode: Code[10]; CountryOrRegionCodeName: Text[50]; ISONumericCode: Code[3])
    begin
        InsertCountryOrRegion(CountryOrRegionCode, CountryOrRegionCodeName, ISONumericCode, '', '', Enum::"Country/Region Address Format"::"Blank Line+Post Code+City", 0, '', '');
    end;

    procedure InsertCountryOrRegion(CountryOrRegionCode: Code[10]; CountryOrRegionCodeName: Text[50]; ISONumericCode: Code[3]; EUCountryRegion: Code[10]; IntrastatCode: Code[10]; AddressFormat: Enum "Country/Region Address Format"; ContactAddressFormat: Option First,"After Company Name",Last; VATScheme: Code[10]; CountyName: Text[30])
    begin
        InsertCountryOrRegion(CountryOrRegionCode, CountryOrRegionCodeName, CopyStr(CountryOrRegionCode, 1, 2), ISONumericCode, EUCountryRegion, IntrastatCode, AddressFormat, ContactAddressFormat, VATScheme, CountyName);
    end;

    procedure InsertCountryOrRegion(CountryOrRegionCode: Code[10]; CountryOrRegionCodeName: Text[50]; ISOCode: Code[2]; ISONumericCode: Code[3]; EUCountryRegion: Code[10]; IntrastatCode: Code[10]; AddressFormat: Enum "Country/Region Address Format"; ContactAddressFormat: Option First,"After Company Name",Last; VATScheme: Code[10]; CountyName: Text[30])
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
        CountryOrRegion.Validate("ISO Code", ISOCode);
        CountryOrRegion.Validate("ISO Numeric Code", ISONumericCode);
        CountryOrRegion.Validate("EU Country/Region Code", EUCountryRegion);
        CountryOrRegion.Validate("Intrastat Code", IntrastatCode);
        CountryOrRegion.Validate("Address Format", AddressFormat);
        CountryOrRegion.Validate("Contact Address Format", ContactAddressFormat);
        CountryOrRegion.Validate("VAT Scheme", VATScheme);
        CountryOrRegion.Validate("County Name", CountyName);

        if Exists then
            CountryOrRegion.Modify(true)
        else
            CountryOrRegion.Insert(true);
    end;


    procedure InsertVATRegNoFormat(CountryCode: Code[10]; LineNo: Integer; Format: Text[20])
    var
        VATRegistrationNoFormat: Record "VAT Registration No. Format";
        Exists: Boolean;
    begin
        if VATRegistrationNoFormat.Get(CountryCode, LineNo) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        VATRegistrationNoFormat.Validate("Country/Region Code", CountryCode);
        VATRegistrationNoFormat.Validate("Line No.", LineNo);
        VATRegistrationNoFormat.Validate(Format, Format);

        if Exists then
            VATRegistrationNoFormat.Modify(true)
        else
            VATRegistrationNoFormat.Insert(true);
    end;
}