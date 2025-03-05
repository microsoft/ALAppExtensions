codeunit 19031 "Create IN Purch. Pay. Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        UpdatePurchasePayablesSetup();
    end;

    local procedure UpdatePurchasePayablesSetup()
    var
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        CreateINNoSeries: Codeunit "Create IN No. Series";
    begin
        PurchasesPayablesSetup.Get();

        PurchasesPayablesSetup.Validate("GST Liability Adj. Jnl Nos.", CreateINNoSeries.GSTLiablilityAdjustmentJournal());
        PurchasesPayablesSetup.Validate("RCM Exempt Start Date (Unreg)", DMY2Date(01, 04, 2020));
        PurchasesPayablesSetup.Validate("RCM Exempt End Date (Unreg)", DMY2Date(02, 04, 2020));
        PurchasesPayablesSetup.Modify(true);
    end;
}