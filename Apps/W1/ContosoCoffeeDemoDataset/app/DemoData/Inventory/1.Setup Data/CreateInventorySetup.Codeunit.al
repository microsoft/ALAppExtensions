codeunit 5273 "Create Inventory Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoItem: Codeunit "Contoso Item";
        CreateNoSeries: Codeunit "Create No. Series";
    begin
        ContosoItem.InsertInventorySetup(true, CreateNoSeries.Item(), Enum::"Automatic Cost Adjustment Type"::Always, CreateNoSeries.TransferOrder(), CreateNoSeries.TransferShipment(), CreateNoSeries.TransferReceipt(), CreateNoSeries.CatalogItems(), CreateNoSeries.InventoryReceipt(), CreateNoSeries.PostedInventoryReceipt(), CreateNoSeries.InventoryShipment(), CreateNoSeries.PostedInventoryShipment(), CreateNoSeries.PostedDirectTransfer(), CreateNoSeries.PhysicalInventoryOrder(), CreateNoSeries.PostedPhysInventOrder());
    end;
}