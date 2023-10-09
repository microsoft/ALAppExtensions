codeunit 5148 "Create Whse Inventory Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Inventory Setup" = rim;

    trigger OnRun()
    begin
        CreateInventorySetup();
        CreateInventoryPostingSetup();
    end;

    local procedure CreateInventorySetup()
    var
        InventorySetup: Record "Inventory Setup";
        CreateWhseNoSeries: Codeunit "Create Whse No Series";
    begin
        if not InventorySetup.Get() then begin
            InventorySetup.Init();
            InventorySetup.Insert(true);
        end;

        if InventorySetup."Transfer Order Nos." = '' then
            InventorySetup.Validate("Transfer Order Nos.", CreateWhseNoSeries.TransferOrder());
        if InventorySetup."Posted Transfer Shpt. Nos." = '' then
            InventorySetup.Validate("Posted Transfer Shpt. Nos.", CreateWhseNoSeries.TransferShipment());
        if InventorySetup."Posted Transfer Rcpt. Nos." = '' then
            InventorySetup.Validate("Posted Transfer Rcpt. Nos.", CreateWhseNoSeries.TransferReceipt());
        if InventorySetup."Inventory Pick Nos." = '' then
            InventorySetup.Validate("Inventory Pick Nos.", CreateWhseNoSeries.InventoryPick());
        if InventorySetup."Posted Invt. Pick Nos." = '' then
            InventorySetup.Validate("Posted Invt. Pick Nos.", CreateWhseNoSeries.PostedInventoryPick());
        if InventorySetup."Inventory Put-Away Nos." = '' then
            InventorySetup.Validate("Inventory Put-Away Nos.", CreateWhseNoSeries.InventoryPutAway());
        if InventorySetup."Posted Invt. Put-Away Nos." = '' then
            InventorySetup.Validate("Posted Invt. Put-Away Nos.", CreateWhseNoSeries.PostedInventoryPutAway());
        if InventorySetup."Inventory Movement Nos." = '' then
            InventorySetup.Validate("Inventory Movement Nos.", CreateWhseNoSeries.InventoryMovement());
        if InventorySetup."Registered Invt. Movement Nos." = '' then
            InventorySetup.Validate("Registered Invt. Movement Nos.", CreateWhseNoSeries.RegisteredInventoryMovement());

        InventorySetup.Modify(true);
    end;

    local procedure CreateInventoryPostingSetup()
    var
        WhseDemoDataSetup: Record "Warehouse Module Setup";
        ContosoPostingSetup: Codeunit "Contoso Posting Setup";
        CommonGLAccount: Codeunit "Create Common GL Account";
        CommonPostingGroup: Codeunit "Create Common Posting Group";
    begin
        WhseDemoDataSetup.Get();

        ContosoPostingSetup.InsertInventoryPostingSetup('', CommonPostingGroup.Resale(), CommonGLAccount.Resale(), CommonGLAccount.ResaleInterim());
        ContosoPostingSetup.InsertInventoryPostingSetup(WhseDemoDataSetup."Location Bin", CommonPostingGroup.Resale(), CommonGLAccount.Resale(), CommonGLAccount.ResaleInterim());
        ContosoPostingSetup.InsertInventoryPostingSetup(WhseDemoDataSetup."Location Adv Logistics", CommonPostingGroup.Resale(), CommonGLAccount.Resale(), CommonGLAccount.ResaleInterim());
        ContosoPostingSetup.InsertInventoryPostingSetup(WhseDemoDataSetup."Location Directed Pick", CommonPostingGroup.Resale(), CommonGLAccount.Resale(), CommonGLAccount.ResaleInterim());
        ContosoPostingSetup.InsertInventoryPostingSetup(WhseDemoDataSetup."Location In-Transit", CommonPostingGroup.Resale(), CommonGLAccount.Resale(), CommonGLAccount.ResaleInterim());
    end;
}