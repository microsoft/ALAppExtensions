codeunit 4790 "Create Common Location"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoWarehouse: Codeunit "Contoso Warehouse";
    begin
        ContosoWarehouse.InsertLocation(MainLocation(), MainWarehouseLbl, UKCampusBldg5Lbl, false);
    end;

    var
        UKCampusBldg5Lbl: Label 'UK Campus Bldg 5', MaxLength = 100;
        MainWarehouseLbl: Label 'Main Warehouse', MaxLength = 100;

    procedure MainLocation(): Code[10]
    var
        CreateLocation: Codeunit "Create Location";
    begin
        exit(CreateLocation.MainLocation());
    end;
}