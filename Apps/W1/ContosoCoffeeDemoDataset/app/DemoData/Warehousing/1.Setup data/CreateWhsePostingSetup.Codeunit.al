codeunit 4788 "Create Whse Posting Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Warehouse Setup" = rim;

    trigger OnRun()
    begin
        CreateWarehouseSetup();
    end;

    local procedure CreateWarehouseSetup()
    var
        WarehouseSetup: Record "Warehouse Setup";
        CreateWhseNoSeries: Codeunit "Create Whse No Series";
    begin
        if not WarehouseSetup.Get() then begin
            WarehouseSetup.Init();
            WarehouseSetup.Insert(true);
        end;

        if WarehouseSetup."Whse. Receipt Nos." = '' then
            WarehouseSetup.Validate("Whse. Receipt Nos.", CreateWhseNoSeries.WarehouseReceipt());
        if WarehouseSetup."Posted Whse. Receipt Nos." = '' then
            WarehouseSetup.Validate("Posted Whse. Receipt Nos.", CreateWhseNoSeries.PostedWarehouseReceipt());
        if WarehouseSetup."Whse. Ship Nos." = '' then
            WarehouseSetup.Validate("Whse. Ship Nos.", CreateWhseNoSeries.WarehouseShipment());
        if WarehouseSetup."Posted Whse. Shipment Nos." = '' then
            WarehouseSetup.Validate("Posted Whse. Shipment Nos.", CreateWhseNoSeries.PostedWarehouseShipment());
        if WarehouseSetup."Whse. Put-away Nos." = '' then
            WarehouseSetup.Validate("Whse. Put-away Nos.", CreateWhseNoSeries.WarehousePutAway());
        if WarehouseSetup."Registered Whse. Put-away Nos." = '' then
            WarehouseSetup.Validate("Registered Whse. Put-away Nos.", CreateWhseNoSeries.RegisteredWarehousePutAway());
        if WarehouseSetup."Whse. Pick Nos." = '' then
            WarehouseSetup.Validate("Whse. Pick Nos.", CreateWhseNoSeries.WarehousePick());
        if WarehouseSetup."Registered Whse. Pick Nos." = '' then
            WarehouseSetup.Validate("Registered Whse. Pick Nos.", CreateWhseNoSeries.RegisteredWarehousePick());
        if WarehouseSetup."Whse. Movement Nos." = '' then
            WarehouseSetup.Validate("Whse. Movement Nos.", CreateWhseNoSeries.WarehouseMovement());
        if WarehouseSetup."Registered Whse. Movement Nos." = '' then
            WarehouseSetup.Validate("Registered Whse. Movement Nos.", CreateWhseNoSeries.RegisteredWarehouseMovement());
        WarehouseSetup.Modify(true);
    end;
}
