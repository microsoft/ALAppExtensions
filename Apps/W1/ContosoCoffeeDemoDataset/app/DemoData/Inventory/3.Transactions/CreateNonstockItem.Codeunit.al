codeunit 5577 "Create Nonstock Item"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoInventory: Codeunit "Contoso Inventory";
        CreateUnitOfMeasure: Codeunit "Create Unit of Measure";
        CreateNoSeries: Codeunit "Create No. Series";
        CreateVendor: Codeunit "Create Vendor";
    begin
        ContosoInventory.InsertNonStockItem(CreateVendor.ExportFabrikam(), StraightBackChairVendItemLbl, StraightBackChairLbl, CreateUnitOfMeasure.Piece(), 12, 10, 22, 5, 5, StraightBackChairBarCodeLbl, CreateNoSeries.Item());
        ContosoInventory.InsertNonStockItem(CreateVendor.ExportFabrikam(), RockingChairVendItemLbl, RockingChairLbl, CreateUnitOfMeasure.Piece(), 15, 13, 26, 6, 6, RockingChairBarCodeLbl, CreateNoSeries.Item());
        ContosoInventory.InsertNonStockItem(CreateVendor.EUGraphicDesign(), ComputerDeskVendItemLbl, ComputerDeskLbl, CreateUnitOfMeasure.Piece(), 120, 105, 230, 50, 50, ComputerDeskBarCodeLbl, CreateNoSeries.Item());
        ContosoInventory.InsertNonStockItem(CreateVendor.DomesticWorldImporter(), ConferenceTableVendItemLbl, ConferenceTableLbl, CreateUnitOfMeasure.Piece(), 100, 90, 180, 35, 35, ConferenceTableBarCodeLbl, CreateNoSeries.Item());
    end;

    var
        StraightBackChairVendItemLbl: Label '2100', MaxLength = 20, Locked = true;
        RockingChairVendItemLbl: Label '2200', MaxLength = 20, Locked = true;
        ComputerDeskVendItemLbl: Label '3100', MaxLength = 20, Locked = true;
        ConferenceTableVendItemLbl: Label '4100', MaxLength = 20, Locked = true;
        StraightBackChairLbl: Label 'Straight back chair', MaxLength = 100;
        RockingChairLbl: Label 'Rocking chair', MaxLength = 100;
        ComputerDeskLbl: Label 'Computer desk', MaxLength = 100;
        ConferenceTableLbl: Label 'Conference table', MaxLength = 100;
        StraightBackChairBarCodeLbl: Label '1111X2222', MaxLength = 20, Locked = true;
        RockingChairBarCodeLbl: Label '3333Z4444', MaxLength = 20, Locked = true;
        ComputerDeskBarCodeLbl: Label '31331T5444', MaxLength = 20, Locked = true;
        ConferenceTableBarCodeLbl: Label '999999T8888', MaxLength = 20, Locked = true;
}