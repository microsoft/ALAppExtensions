codeunit 11374 "Create Inv. Setup BE"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        InventorySetup: Record "Inventory Setup";
        CreateGenJnlBatch: Codeunit "Create Gen. Journal Batch";
    begin
        InventorySetup.Get();
        InventorySetup.Validate("Invt. Cost Jnl. Template Name", CreateGenJnlBatch.General());
        InventorySetup.Validate("Invt. Cost Jnl. Batch Name", CreateGenJnlBatch.Default());
        InventorySetup.Modify(true);
    end;
}