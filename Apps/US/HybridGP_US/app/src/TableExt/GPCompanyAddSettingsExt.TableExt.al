namespace Microsoft.DataMigration.GP;

tableextension 41103 "GP Company Add. Settings Ext." extends "GP Company Additional Settings"
{
    fields
    {
        field(100; "Migrate Vendor 1099"; Boolean)
        {
            Caption = 'Migrate Vendor 1099';
            InitValue = true;
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                if Rec."Migrate Vendor 1099" then
                    if not Rec."Migrate Payables Module" then
                        Rec.Validate("Migrate Payables Module", true);
            end;
        }
        field(101; "1099 Tax Year"; Integer)
        {
            Caption = '1099 Tax Year';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            var
                GPVendor1099MappingHelpers: Codeunit "GP Vendor 1099 Mapping Helpers";
                CurrentYear: Integer;
                MinimumSupportedTaxYear: Integer;
            begin
                if Rec."Migrate Vendor 1099" then begin
                    CurrentYear := Date2DMY(Today(), 3);
                    MinimumSupportedTaxYear := GPVendor1099MappingHelpers.GetMinimumSupportedTaxYear();

                    if Rec."1099 Tax Year" > CurrentYear then
                        Error(TaxYearCannotBeInFutureErr);

                    if (Rec."1099 Tax Year" < MinimumSupportedTaxYear) then
                        Error(TaxYearCannotBeLessThanSupportYearErr, MinimumSupportedTaxYear);
                end;
            end;
        }

        modify("Migrate Payables Module")
        {
            trigger OnAfterValidate()
            begin
                if not Rec."Migrate Payables Module" then
                    Rec.Validate("Migrate Vendor 1099", false);
            end;
        }
    }

    trigger OnBeforeInsert()
    var
        GPVendor1099MappingHelpers: Codeunit "GP Vendor 1099 Mapping Helpers";
    begin
        if Rec."1099 Tax Year" < GPVendor1099MappingHelpers.GetMinimumSupportedTaxYear() then
            Rec."1099 Tax Year" := Date2DMY(Today(), 3);
    end;

    procedure GetMigrateVendor1099Enabled(): Boolean
    begin
        GetSingleInstance();
        exit(Rec."Migrate Vendor 1099");
    end;

    procedure Get1099TaxYear(): Integer
    begin
        GetSingleInstance();
        exit(Rec."1099 Tax Year");
    end;

    var
        TaxYearCannotBeInFutureErr: Label 'The 1099 tax year cannot be in the future.';

        TaxYearCannotBeLessThanSupportYearErr: Label 'The 1099 tax year cannot be less than %1', Comment = '%1 = Minimum supported tax year.';
}