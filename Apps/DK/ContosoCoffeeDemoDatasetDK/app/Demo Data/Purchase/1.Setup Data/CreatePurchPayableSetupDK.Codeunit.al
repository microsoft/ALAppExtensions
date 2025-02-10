codeunit 13726 "Create Purch. Payable Setup DK"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    trigger OnRun()
    begin
        UpdatePurchasesPayablesSetup()
    end;

    local procedure UpdatePurchasesPayablesSetup()
    var
        CreateNoSeries: Codeunit "Create No. Series";
    begin
        ValidateRecordFields(true, CreateNoSeries.PostedPurchaseInvoice(), CreateNoSeries.PostedPurchaseCreditMemo());
    end;

    local procedure ValidateRecordFields(AllowVatDifference: Boolean; PostedPrepmtInvNos: Code[20]; PostedPrepmtCrMemoNos: Code[20])
    var
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
    begin
        PurchasesPayablesSetup.Get();
        PurchasesPayablesSetup.Validate("Allow VAT Difference", AllowVatDifference);
        PurchasesPayablesSetup.Validate("Posted Prepmt. Inv. Nos.", PostedPrepmtInvNos);
        PurchasesPayablesSetup.Validate("Posted Prepmt. Cr. Memo Nos.", PostedPrepmtCrMemoNos);
        PurchasesPayablesSetup.Modify(true);
    end;
}