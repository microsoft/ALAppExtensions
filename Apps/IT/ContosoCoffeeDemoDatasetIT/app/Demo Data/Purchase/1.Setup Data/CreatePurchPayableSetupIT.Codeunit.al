codeunit 12253 "Create Purch. Payable Setup IT"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    trigger OnRun()
    begin
        UpdatePurchasesPayablesSetup()
    end;

    local procedure UpdatePurchasesPayablesSetup()
    var
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        CreateNoSeriesIT: Codeunit "Create No. Series IT";
    begin
        PurchasesPayablesSetup.Get();

        PurchasesPayablesSetup.Validate("Temporary Bill List No.", CreateNoSeriesIT.VendorBillsBRListNo());
        PurchasesPayablesSetup.Validate("Prevent Posted Doc. Deletion", true);
        PurchasesPayablesSetup.Modify(true);
    end;
}