#pragma warning disable AA0247
codeunit 31208 "Create FA Setup CZF"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "FA Setup" = rim;

    trigger OnRun()
    begin
        UpdatePurchasesPayablesSetup()
    end;

    local procedure UpdatePurchasesPayablesSetup()
    var
        CreateDepreciationBookCZ: Codeunit "Create Depreciation Book CZ";
    begin
        ValidateRecordFields(CreateDepreciationBookCZ.FirstAccount(), CreateDepreciationBookCZ.SecondTax(), true);
    end;

    local procedure ValidateRecordFields(DefaultDeprBook: Code[10]; TaxDepreciationBook: Code[10]; FAAcquisitionAsCustom2: Boolean)
    var
        FASetup: Record "FA Setup";
    begin
        FASetup.Get();
        FASetup.Validate("Default Depr. Book", DefaultDeprBook);
        FASetup.Validate("Tax Depreciation Book CZF", TaxDepreciationBook);
        FASetup.Validate("FA Acquisition As Custom 2 CZF", FAAcquisitionAsCustom2);
        FASetup.Modify(true);
    end;
}
