#pragma warning disable AA0247
codeunit 5277 "Create Sust. Responsibility"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoInventory: Codeunit "Contoso Inventory";
        CreateUnitOfMeasure: Codeunit "Create Unit of Measure";
        ContosoSustainability: Codeunit "Contoso Sustainability";
    begin
        ContosoInventory.InsertResponsibilityCenter(Production(), ProductionLbl);
        ContosoSustainability.UpdateSustainabilityResponsibilityCenter(Production(), 50000, CreateUnitOfMeasure.M3());

        ContosoInventory.InsertResponsibilityCenter(Warehouse(), WarehouseLbl);
        ContosoSustainability.UpdateSustainabilityResponsibilityCenter(Warehouse(), 12000, CreateUnitOfMeasure.M3());
    end;

    procedure Production(): Code[10]
    begin
        exit('PRODUCTION');
    end;

    procedure Warehouse(): Code[10]
    begin
        exit('WAREHOUSE');
    end;

    var
        ProductionLbl: Label 'Production Center', MaxLength = 100;
        WarehouseLbl: Label 'Warehouse Center', MaxLength = 100;
}