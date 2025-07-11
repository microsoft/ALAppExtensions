namespace Microsoft.DataMigration.GP;

codeunit 42002 "GP Vendor 1099 Mapping Helpers"
{
    var
        MinimumSupportedTaxYear: Integer;

    procedure CleanMappings()
    var
        SupportedTaxYear: Record "Supported Tax Year";
        GP1099BoxMapping: Record "GP 1099 Box Mapping";
    begin
        if not GP1099BoxMapping.IsEmpty() then
            GP1099BoxMapping.DeleteAll();

        if not SupportedTaxYear.IsEmpty() then
            SupportedTaxYear.DeleteAll();

        MinimumSupportedTaxYear := 0;
    end;

    procedure InsertSupportedTaxYear(TaxYear: Integer)
    var
        SupportedTaxYear: Record "Supported Tax Year";
    begin
        SupportedTaxYear."Tax Year" := TaxYear;
        SupportedTaxYear.Insert();
    end;

    procedure InsertMapping(TaxYear: Integer; GP1099BoxType: Integer; GP1099BoxNo: Integer; BCIRS1099Code: Code[10])
    var
        GP1099BoxMapping: Record "GP 1099 Box Mapping";
    begin
        GP1099BoxMapping."Tax Year" := TaxYear;
        GP1099BoxMapping."GP 1099 Type" := GP1099BoxType;
        GP1099BoxMapping."GP 1099 Box No." := GP1099BoxNo;
        GP1099BoxMapping."BC IRS 1099 Code" := BCIRS1099Code;
        GP1099BoxMapping.Insert();
    end;

    procedure GetSupportedTaxYear(TaxYear: Integer): Integer
    var
        SupportedTaxYear: Record "Supported Tax Year";
    begin
        if MinimumSupportedTaxYear = 0 then
            MinimumSupportedTaxYear := GetMinimumSupportedTaxYear();

        if (MinimumSupportedTaxYear = 0) or (TaxYear < MinimumSupportedTaxYear) then
            exit(0);

        SupportedTaxYear.SetRange("Tax Year", MinimumSupportedTaxYear, TaxYear);
        SupportedTaxYear.SetCurrentKey("Tax Year");
        SupportedTaxYear.SetAscending("Tax Year", false);
        if SupportedTaxYear.FindFirst() then
            exit(SupportedTaxYear."Tax Year");

        exit(0);
    end;

    procedure GetIRS1099BoxCode(TaxYear: Integer; GP1099BoxType: Integer; GP1099BoxNo: Integer): Code[10]
    var
        GP1099BoxMapping: Record "GP 1099 Box Mapping";
        SupportedTaxYear: Integer;
    begin
        SupportedTaxYear := GetSupportedTaxYear(TaxYear);
        if SupportedTaxYear = 0 then
            exit('');

        if GP1099BoxNo < 1 then
            GP1099BoxNo := 1;

        if GP1099BoxMapping.Get(SupportedTaxYear, GP1099BoxType, GP1099BoxNo) then
            exit(GP1099BoxMapping."BC IRS 1099 Code");

        exit('');
    end;

    procedure GetMinimumSupportedTaxYear(): Integer
    begin
        exit(2022);
    end;
}