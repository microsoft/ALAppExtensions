codeunit 19028 "Create IN Inventory Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        UpdateInventorySetup();
    end;

    local procedure UpdateInventorySetup()
    var
        InventorySetup: Record "Inventory Setup";
        CreateINNoSeries: Codeunit "Create IN No. Series";
    begin
        InventorySetup.Get();

        InventorySetup.Validate("Inward Gate Entry Nos.", CreateINNoSeries.GateEntryInwards());
        InventorySetup.Validate("Outward Gate Entry Nos.", CreateINNoSeries.GateEntryOutward());
        InventorySetup.Modify(true);
    end;
}