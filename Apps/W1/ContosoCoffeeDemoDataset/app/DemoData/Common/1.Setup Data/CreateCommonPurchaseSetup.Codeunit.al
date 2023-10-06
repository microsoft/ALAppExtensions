codeunit 5146 "Create Common Purchase Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Purchases & Payables Setup" = rm;

    trigger OnRun()
    var
        PurchasePayablesSetup: Record "Purchases & Payables Setup";
        CommonNoSeries: Codeunit "Create Common No Series";
    begin
        PurchasePayablesSetup.Get();

        if PurchasePayablesSetup."Order Nos." = '' then
            PurchasePayablesSetup.Validate("Order Nos.", CommonNoSeries.PurchaseOrder());

        PurchasePayablesSetup.Modify();
    end;
}