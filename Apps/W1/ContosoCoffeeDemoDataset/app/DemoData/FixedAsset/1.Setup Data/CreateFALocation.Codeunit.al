codeunit 5114 "Create FA Location"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoFixedAsset: Codeunit "Contoso Fixed Asset";
    begin
        ContosoFixedAsset.InsertFALocation(WareHouse(), WareHouseLbl);
        ContosoFixedAsset.InsertFALocation(Administration(), AdministrationLbl);
        ContosoFixedAsset.InsertFALocation(Sales(), SalesLbl);
        ContosoFixedAsset.InsertFALocation(Production(), ProductionNameLbl);
    end;

    procedure WareHouse(): Code[10]
    begin
        exit(WareHouseTok);
    end;

    procedure Administration(): Code[10]
    begin
        exit(AdministrationTok);
    end;

    procedure Sales(): Code[10]
    begin
        exit(SalesTok);
    end;

    procedure Production(): Code[10]
    begin
        exit(ProductionTok);
    end;

    var
        WareHouseTok: Label 'WAREHOUSE', MaxLength = 10;
        WareHouseLbl: Label 'WareHouse', MaxLength = 50;
        AdministrationTok: Label 'ADM', MaxLength = 10;
        AdministrationLbl: Label 'Administration, Building_1', MaxLength = 50;
        SalesTok: Label 'SALES', MaxLength = 10;
        SalesLbl: Label 'Sales, Building_1', MaxLength = 50;
        ProductionTok: Label 'PROD', MaxLength = 10;
        ProductionNameLbl: Label 'Production, Building_2', MaxLength = 50;
}