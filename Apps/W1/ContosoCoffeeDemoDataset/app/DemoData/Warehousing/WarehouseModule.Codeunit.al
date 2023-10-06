codeunit 5140 "Warehouse Module" implements "Contoso Demo Data Module"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    procedure RunConfigurationPage()
    begin
        Page.Run(Page::"Warehouse Module Setup");
    end;

    procedure GetDependencies() Dependencies: List of [enum "Contoso Demo Data Module"]
    begin
        Dependencies.Add(Enum::"Contoso Demo Data Module"::"Common Module");
    end;

    procedure CreateSetupData()
    var
        WarehouseModuleSetup: Record "Warehouse Module Setup";
    begin
        WarehouseModuleSetup.InitRecord();
        Codeunit.Run(Codeunit::"Create Whse Put Away Template");
        Codeunit.Run(Codeunit::"Create Whse Location");
        Codeunit.Run(Codeunit::"Create Whse No Series");
        Codeunit.Run(Codeunit::"Create Whse Posting Setup");
        Codeunit.Run(Codeunit::"Create Whse Inventory Setup");
        Codeunit.Run(Codeunit::"Create Whse Item Category");
    end;

    procedure CreateMasterData()
    var
        WarehouseModuleSetup: Record "Warehouse Module Setup";
    begin
        WarehouseModuleSetup.InitWarehousingDemoDataSetup();
        Codeunit.Run(Codeunit::"Create Whse Item");
    end;

    procedure CreateTransactionalData()
    begin
        Codeunit.Run(Codeunit::"Create Whse Orders");
    end;

    procedure CreateHistoricalData()
    begin
        exit;
    end;

    procedure DeleteWarehouseEmployee()
    var
        WarehouseEmployee: Record "Warehouse Employee";
    begin
        WarehouseEmployee.DeleteAll();
        Commit();
    end;
}