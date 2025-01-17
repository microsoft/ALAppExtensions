codeunit 11499 "Create GB Purch Payable Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        UpdatePurchasesPayablesSetup();
    end;

    local procedure UpdatePurchasesPayablesSetup()
    var
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        CreateNoSeries: Codeunit "Create No. Series";
    begin
        PurchasesPayablesSetup.Get();

        PurchasesPayablesSetup.Validate("Allow VAT Difference", true);
        PurchasesPayablesSetup.Validate("Posted Prepmt. Inv. Nos.", CreateNoSeries.PostedPurchaseInvoice());
        PurchasesPayablesSetup.Validate("Posted Prepmt. Cr. Memo Nos.", CreateNoSeries.PostedPurchaseCreditMemo());
        PurchasesPayablesSetup.Validate("Posting Date Check on Posting", false);
        PurchasesPayablesSetup.Modify(true);
    end;
}