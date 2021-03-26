tableextension 11798 "Country/Region CZL" extends "Country/Region"
{
    procedure IsIntrastatCZL(CountryRegionCode: Code[10]; ShipTo: Boolean): Boolean
    var
        CompanyInformation: Record "Company Information";
    begin
        if CountryRegionCode = '' then
            exit(false);

        Get(CountryRegionCode);
        if "Intrastat Code" = '' then
            exit(false);

        CompanyInformation.Get();
        if ShipTo then
            exit(CountryRegionCode <> CompanyInformation."Ship-to Country/Region Code");
        exit(CountryRegionCode <> CompanyInformation."Country/Region Code");
    end;

    procedure IsLocalCountryCZL(CountryRegionCode: Code[10]; ShipTo: Boolean): Boolean
    var
        CompanyInformation: Record "Company Information";
    begin
        if CountryRegionCode = '' then
            exit(true);

        CompanyInformation.Get();
        if ShipTo then
            exit(CountryRegionCode = CompanyInformation."Ship-to Country/Region Code");
        exit(CountryRegionCode = CompanyInformation."Country/Region Code");
    end;
}