codeunit 4787 "Create Whse Location"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Warehouse Employee" = ri;

    var
        WhseDemoDataSetup: Record "Warehouse Module Setup";
        ContosoWarehouse: Codeunit "Contoso Warehouse";
        BasicLocationLbl: Label 'Silver Warehouse', MaxLength = 100;
        SimpleLocationLbl: Label 'Yellow Warehouse', MaxLength = 100;
        AdvancedLocationLbl: Label 'White Warehouse', MaxLength = 100;
        TransitLocationLbl: Label 'Own Logistics', MaxLength = 100;
        BasicLocationTok: Label 'SILVER', MaxLength = 10;
        SimpleLocationTok: Label 'YELLOW', MaxLength = 10;
        AdvancedLocationTok: Label 'WHITE', MaxLength = 10;
        TransitLocationTok: Label 'OWN LOG.', MaxLength = 10;
        ColdTok: Label 'COLD', MaxLength = 10;
        FrozenTok: Label 'FROZEN', MaxLength = 10;
        ForkliftTok: Label 'FORKLIFT', MaxLength = 10;
        ColdLbl: Label '2 degrees Celsius', MaxLength = 100;
        FrozenLbl: Label '-8 degrees Celsius', MaxLength = 100;
        ForkliftLbl: Label 'Forklift', MaxLength = 100;
        AdjustmentTok: Label 'ADJUSTMENT', MaxLength = 10;
        BulkTok: Label 'BULK', MaxLength = 10;
        CrossDuckTok: Label 'CROSS-DOCK', MaxLength = 10;
        PickTok: Label 'PICK', MaxLength = 10;
        PutAwayTok: Label 'PUTAWAY', MaxLength = 10;
        PutPickTok: Label 'PUTPICK', MaxLength = 10;
        QCTok: Label 'QC', MaxLength = 10;
        ReceiveTok: Label 'RECEIVE', MaxLength = 10;
        ShipTok: Label 'SHIP', MaxLength = 10;
        OperationTok: Label 'OPERATION', MaxLength = 10;
        StorageTok: Label 'STORAGE', MaxLength = 10;
        VirtualForAdjustmentLbl: Label 'Virtual for Adjustment', MaxLength = 100;
        BulkStorageLbl: Label 'Bulk Storage', MaxLength = 100;
        CrossDockLbl: Label 'Cross-Dock', MaxLength = 100;
        PickLbl: Label 'Pick', MaxLength = 100;
        PutAwayLbl: Label 'Put Away', MaxLength = 100;
        PutAwayAndPickLbl: Label 'Put Away and Pick', MaxLength = 100;
        QualityControlLbl: Label 'Quality Control', MaxLength = 100;
        ReceivingLbl: Label 'Receiving', MaxLength = 100;
        ShippingLbl: Label 'Shipping', MaxLength = 100;
        OperationsLbl: Label 'Operations', MaxLength = 100;
        NoTypeLbl: Label 'No type', MaxLength = 100;
        StorageLbl: Label 'Storage', MaxLength = 100;

    trigger OnRun()
    begin
        WhseDemoDataSetup.Get();

        CreateLocation();

        AddUserAsWarehouseEmployee(CopyStr(UserId, 1, 50));

        CreateWarehouseClasses();
        CreateSpecialEquipments();

        CreateBinTypes();
        CreateZones();
        CreateBins();

        UpdateAdvancedLocationWithBins();
    end;

    local procedure CreateLocation()
    var
        CreateWhsePutAwayTemplate: Codeunit "Create Whse Put Away Template";
    begin
        if WhseDemoDataSetup."Location Bin" = '' then begin
            ContosoWarehouse.InsertLocation(BasicLocation(), BasicLocationLbl, '', false, false, false, false, false, true, false, "Put-away Bin Policy"::"Put-away Template", "Pick Bin Policy"::"Bin Ranking", Enum::"Location Default Bin Selection"::"Fixed Bin", CreateWhsePutAwayTemplate.StandardTemplate(), Enum::"Prod. Consump. Whse. Handling"::"No Warehouse Handling", Enum::"Prod. Output Whse. Handling"::"No Warehouse Handling", Enum::"Job Consump. Whse. Handling"::"No Warehouse Handling", Enum::"Asm. Consump. Whse. Handling"::"No Warehouse Handling", false, 1, 1, true, false, false);
            WhseDemoDataSetup.Validate("Location Bin", BasicLocation());
        end;

        if WhseDemoDataSetup."Location Adv Logistics" = '' then begin
            ContosoWarehouse.InsertLocation(SimpleLocation(), SimpleLocationLbl, '', true, true, false, true, true, false, false, "Put-away Bin Policy"::"Default Bin", "Pick Bin Policy"::"Default Bin", Enum::"Location Default Bin Selection"::" ", '', Enum::"Prod. Consump. Whse. Handling"::"Warehouse Pick (mandatory)", Enum::"Prod. Output Whse. Handling"::"No Warehouse Handling", Enum::"Job Consump. Whse. Handling"::"Warehouse Pick (mandatory)", Enum::"Asm. Consump. Whse. Handling"::"Warehouse Pick (mandatory)", false, 0, 0, false, false, false);
            WhseDemoDataSetup.Validate("Location Adv Logistics", SimpleLocation());
        end;

        if WhseDemoDataSetup."Location Directed Pick" = '' then begin
            ContosoWarehouse.InsertLocation(AdvancedLocation(), AdvancedLocationLbl, '', true, true, true, true, true, true, true, "Put-away Bin Policy"::"Put-away Template", "Pick Bin Policy"::"Bin Ranking", Enum::"Location Default Bin Selection"::" ", CreateWhsePutAwayTemplate.StandardTemplate(), Enum::"Prod. Consump. Whse. Handling"::"Warehouse Pick (mandatory)", Enum::"Prod. Output Whse. Handling"::"No Warehouse Handling", Enum::"Job Consump. Whse. Handling"::"Warehouse Pick (mandatory)", Enum::"Asm. Consump. Whse. Handling"::"Warehouse Pick (mandatory)", true, 1, 1, false, false, false);
            WhseDemoDataSetup.Validate("Location Directed Pick", AdvancedLocation());
        end;

        if WhseDemoDataSetup."Location In-Transit" = '' then begin
            ContosoWarehouse.InsertLocation(TransitLocation(), TransitLocationLbl, '', true);
            WhseDemoDataSetup.Validate("Location In-Transit", TransitLocation());
        end;

        WhseDemoDataSetup.Modify(true);
    end;

    local procedure AddUserAsWarehouseEmployee(UserId: Text[50])
    begin
        ContosoWarehouse.InsertWarehouseEmployee(UserId, WhseDemoDataSetup."Location Bin", false);
        ContosoWarehouse.InsertWarehouseEmployee(UserId, WhseDemoDataSetup."Location Adv Logistics", false);
        ContosoWarehouse.InsertWarehouseEmployee(UserId, WhseDemoDataSetup."Location Directed Pick", true);
    end;

    local procedure CreateWarehouseClasses()
    begin
        ContosoWarehouse.InsertWarehouseClass(ColdClass(), ColdLbl);
        ContosoWarehouse.InsertWarehouseClass(FrozenClass(), FrozenLbl);
    end;

    local procedure CreateSpecialEquipments()
    begin
        ContosoWarehouse.InsertSpecialEquipment(ForkliftEquipment(), ForkliftLbl);
    end;

    local procedure CreateBinTypes()
    begin
        ContosoWarehouse.InsertBinType(ReceiveBinType(), ReceivingLbl, true, false, false, false);
        ContosoWarehouse.InsertBinType(ShipBinType(), ShippingLbl, false, true, false, false);
        ContosoWarehouse.InsertBinType(PutAwayAndPickBinType(), PutAwayAndPickLbl, false, false, true, true);
        ContosoWarehouse.InsertBinType(PutAwayBinType(), PutAwayLbl, false, false, true, false);
        ContosoWarehouse.InsertBinType(PickBinType(), PickLbl, false, false, false, true);
        ContosoWarehouse.InsertBinType(QualityControlBinType(), NoTypeLbl, false, false, false, false);
    end;

    local procedure CreateZones()
    begin
        ContosoWarehouse.InsertZone(WhseDemoDataSetup."Location Bin", PickZone(), PickLbl, '', '', 0, false, '');
        ContosoWarehouse.InsertZone(WhseDemoDataSetup."Location Bin", ReceiveZone(), ReceivingLbl, '', '', 0, false, '');
        ContosoWarehouse.InsertZone(WhseDemoDataSetup."Location Bin", ShipZone(), ShippingLbl, '', '', 0, false, '');
        ContosoWarehouse.InsertZone(WhseDemoDataSetup."Location Bin", StorageZone(), StorageLbl, '', '', 0, false, ForkliftEquipment());
        ContosoWarehouse.InsertZone(WhseDemoDataSetup."Location Bin", CrossDockZone(), CrossDockLbl, '', '', 0, true, '');
        ContosoWarehouse.InsertZone(WhseDemoDataSetup."Location Bin", OperationZone(), OperationsLbl, '', '', 0, false, '');

        ContosoWarehouse.InsertZone(WhseDemoDataSetup."Location Directed Pick", AdjustmentZone(), VirtualForAdjustmentLbl, QualityControlBinType(), '', 0, false, '');
        ContosoWarehouse.InsertZone(WhseDemoDataSetup."Location Directed Pick", BulkZone(), BulkStorageLbl, PutAwayBinType(), '', 60, false, ForkliftEquipment());
        ContosoWarehouse.InsertZone(WhseDemoDataSetup."Location Directed Pick", CrossDockZone(), CrossDockLbl, PutAwayAndPickBinType(), '', 0, true, '');
        ContosoWarehouse.InsertZone(WhseDemoDataSetup."Location Directed Pick", PickZone(), PickLbl, PutAwayAndPickBinType(), '', 200, false, '');
        ContosoWarehouse.InsertZone(WhseDemoDataSetup."Location Directed Pick", QualityControlZone(), QualityControlLbl, QualityControlBinType(), '', 0, false, '');
        ContosoWarehouse.InsertZone(WhseDemoDataSetup."Location Directed Pick", ReceiveZone(), ReceivingLbl, ReceiveTok, '', 0, false, '');
        ContosoWarehouse.InsertZone(WhseDemoDataSetup."Location Directed Pick", ShipZone(), ShippingLbl, ShipTok, '', 0, false, '');
        ContosoWarehouse.InsertZone(WhseDemoDataSetup."Location Directed Pick", OperationZone(), OperationsLbl, QualityControlBinType(), '', 0, false, '');
    end;

    local procedure CreateBins()
    begin
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Bin", 'S-1-01', '', PickZone(), '', '', 0, 450, 50, 50, false, false, '');
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Bin", 'S-1-02', '', PickZone(), '', '', 0, 400, 50, 50, false, false, '');
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Bin", 'S-1-03', '', PickZone(), '', '', 0, 400, 50, 50, false, false, '');
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Bin", 'S-1-04', '', PickZone(), '', '', 0, 350, 500, 500, false, false, '');
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Bin", 'S-1-05', '', PickZone(), '', '', 0, 350, 500, 500, false, false, '');
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Bin", 'S-2-01', '', PickZone(), '', ColdClass(), 450, 0, 50, 50, false, false, '');
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Bin", 'S-2-02', '', PickZone(), '', ColdClass(), 400, 0, 50, 50, false, false, '');
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Bin", 'S-2-03', '', PickZone(), '', ColdClass(), 400, 0, 50, 50, false, false, '');
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Bin", 'S-2-04', '', PickZone(), '', ColdClass(), 350, 0, 500, 500, false, false, '');
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Bin", 'S-2-05', '', PickZone(), '', ColdClass(), 350, 0, 500, 500, false, false, '');
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Bin", 'S-3-01', '', PickZone(), '', '', 0, 250, 2000, 2000, false, false, '');
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Bin", 'S-3-02', '', PickZone(), '', '', 0, 200, 2000, 2000, false, false, '');
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Bin", 'S-3-03', '', PickZone(), '', '', 0, 200, 2000, 2000, false, false, '');
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Bin", 'S-3-04', '', PickZone(), '', '', 0, 200, 2000, 2000, false, false, '');
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Bin", 'S-3-05', '', PickZone(), '', '', 0, 200, 2000, 2000, false, false, '');
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Bin", 'S-4-01', '', StorageZone(), '', '', 0, 0, 150000, 150000, false, false, ForkliftEquipment());
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Bin", 'S-4-02', '', StorageZone(), '', '', 0, 0, 150000, 150000, false, false, ForkliftEquipment());
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Bin", 'S-4-03', '', StorageZone(), '', '', 0, 0, 150000, 150000, false, false, ForkliftEquipment());
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Bin", 'S-4-04', '', StorageZone(), '', '', 0, 0, 150000, 150000, false, false, ForkliftEquipment());
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Bin", 'S-4-05', '', StorageZone(), '', '', 0, 0, 150000, 150000, false, false, ForkliftEquipment());
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Bin", 'S-4-06', '', StorageZone(), '', '', 0, 0, 150000, 150000, false, false, ForkliftEquipment());
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Bin", 'S-4-07', '', StorageZone(), '', '', 0, 0, 150000, 150000, false, false, ForkliftEquipment());
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Bin", 'S-4-08', '', StorageZone(), '', ColdClass(), 0, 0, 150000, 150000, false, false, ForkliftEquipment());
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Bin", 'S-4-09', '', StorageZone(), '', ColdClass(), 0, 0, 150000, 150000, false, false, ForkliftEquipment());
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Bin", 'S-4-10', '', StorageZone(), '', '', 0, 0, 150000, 150000, false, false, '');
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Bin", 'S-6-01', '', CrossDockZone(), '', '', 0, 500, 0, 0, true, false, '');
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Bin", 'S-6-02', '', CrossDockZone(), '', '', 0, 500, 0, 0, true, false, '');
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Bin", 'S-6-03', '', CrossDockZone(), '', '', 0, 500, 0, 0, true, false, '');
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Bin", 'S-7-01', '', OperationZone(), '', '', 0, 0, 0, 0, false, true, '');
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Bin", 'S-7-02', '', OperationZone(), '', '', 0, 0, 0, 0, false, true, '');
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Bin", 'S-7-03', '', OperationZone(), '', '', 0, 0, 0, 0, false, true, '');
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Bin", 'S-7-04', '', OperationZone(), '', '', 0, 0, 0, 0, false, true, '');
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Bin", 'S-7-05', '', OperationZone(), '', '', 0, 0, 0, 0, false, true, '');
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Bin", 'S-8-01', '', ReceiveZone(), '', '', 0, 0, 5000000, 5000000, false, false, '');
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Bin", 'S-8-02', '', ReceiveZone(), '', '', 0, 0, 5000000, 5000000, false, false, '');
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Bin", 'S-8-03', '', ReceiveZone(), '', ColdClass(), 0, 0, 5000000, 5000000, false, false, '');
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Bin", 'S-9-01', '', ShipZone(), '', '', 0, 0, 5000000, 5000000, false, false, '');
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Bin", 'S-9-02', '', ShipZone(), '', '', 0, 0, 5000000, 5000000, false, false, '');
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Bin", 'S-9-03', '', ShipZone(), '', ColdClass(), 0, 0, 5000000, 5000000, false, false, '');

        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Directed Pick", 'W-01-0001', '', PickZone(), PutAwayAndPickBinType(), '', 0, 450, 50, 50, false, false, '');
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Directed Pick", 'W-01-0002', '', PickZone(), PutAwayAndPickBinType(), '', 0, 400, 50, 50, false, false, '');
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Directed Pick", 'W-01-0003', '', PickZone(), PutAwayAndPickBinType(), '', 0, 400, 50, 50, false, false, '');
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Directed Pick", 'W-02-0001', '', PickZone(), PutAwayAndPickBinType(), '', 0, 350, 500, 500, false, false, '');
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Directed Pick", 'W-02-0002', '', PickZone(), PutAwayAndPickBinType(), '', 0, 300, 500, 500, false, false, '');
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Directed Pick", 'W-02-0003', '', PickZone(), PutAwayAndPickBinType(), '', 0, 300, 500, 500, false, false, '');
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Directed Pick", 'W-03-0001', '', PickZone(), PutAwayAndPickBinType(), ColdClass(), 0, 350, 500, 500, false, false, '');
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Directed Pick", 'W-03-0002', '', PickZone(), PutAwayAndPickBinType(), ColdClass(), 0, 300, 500, 500, false, false, '');
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Directed Pick", 'W-03-0003', '', PickZone(), PutAwayAndPickBinType(), ColdClass(), 0, 300, 500, 500, false, false, '');
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Directed Pick", 'W-04-0001', '', PickZone(), PutAwayAndPickBinType(), '', 0, 250, 2000, 2000, false, false, '');
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Directed Pick", 'W-04-0002', '', PickZone(), PutAwayAndPickBinType(), '', 0, 200, 2000, 2000, false, false, '');
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Directed Pick", 'W-04-0003', '', PickZone(), PutAwayAndPickBinType(), '', 0, 200, 2000, 2000, false, false, '');
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Directed Pick", 'W-04-0004', '', PickZone(), PutAwayAndPickBinType(), '', 0, 200, 2000, 2000, false, false, '');
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Directed Pick", 'W-04-0005', '', PickZone(), PutAwayAndPickBinType(), '', 0, 200, 2000, 2000, false, false, '');
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Directed Pick", 'W-05-0001', '', BulkZone(), PutAwayBinType(), '', 0, 60, 15000, 15000, false, false, ForkliftEquipment());
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Directed Pick", 'W-05-0002', '', BulkZone(), PutAwayBinType(), '', 0, 60, 15000, 15000, false, false, ForkliftEquipment());
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Directed Pick", 'W-05-0003', '', BulkZone(), PutAwayBinType(), '', 0, 60, 15000, 15000, false, false, ForkliftEquipment());
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Directed Pick", 'W-05-0004', '', BulkZone(), PutAwayBinType(), ColdClass(), 0, 60, 15000, 15000, false, false, ForkliftEquipment());
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Directed Pick", 'W-05-0005', '', BulkZone(), PutAwayBinType(), ColdClass(), 0, 60, 15000, 15000, false, false, ForkliftEquipment());
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Directed Pick", BinW070001(), '', OperationZone(), QualityControlBinType(), '', 0, 0, 0, 0, true, true, '');
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Directed Pick", BinW070002(), '', OperationZone(), QualityControlBinType(), '', 0, 0, 0, 0, true, true, '');
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Directed Pick", BinW070003(), '', OperationZone(), QualityControlBinType(), '', 0, 0, 0, 0, true, true, '');
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Directed Pick", BinW070004(), '', OperationZone(), QualityControlBinType(), '', 0, 0, 0, 0, true, true, '');
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Directed Pick", BinW070005(), '', OperationZone(), QualityControlBinType(), '', 0, 0, 0, 0, true, true, '');
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Directed Pick", BinW080001(), '', ReceiveZone(), ReceiveBinType(), '', 0, 0, 5000000, 5000000, false, false, '');
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Directed Pick", 'W-08-0002', '', ReceiveZone(), ReceiveBinType(), '', 0, 0, 5000000, 5000000, false, false, '');
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Directed Pick", 'W-08-0003', '', ReceiveZone(), ReceiveBinType(), ColdClass(), 0, 0, 5000000, 5000000, false, false, '');
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Directed Pick", BinW090001(), '', ShipZone(), ShipBinType(), '', 0, 0, 5000000, 5000000, false, false, '');
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Directed Pick", 'W-09-0002', '', ShipZone(), ShipBinType(), '', 0, 0, 5000000, 5000000, false, false, '');
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Directed Pick", 'W-09-0003', '', ShipZone(), ShipBinType(), ColdClass(), 0, 0, 5000000, 5000000, false, false, '');
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Directed Pick", 'W-10-0001', '', QualityControlZone(), QualityControlBinType(), '', 0, 0, 0, 0, false, false, '');
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Directed Pick", 'W-10-0002', '', QualityControlZone(), QualityControlBinType(), '', 0, 0, 0, 0, false, false, '');
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Directed Pick", BinW990001(), '', AdjustmentZone(), QualityControlBinType(), '', 0, 0, 0, 0, false, false, '');
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Directed Pick", BinW140001(), '', CrossDockZone(), PutAwayAndPickBinType(), '', 0, 500, 0, 0, true, false, '');
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Directed Pick", 'W-14-0002', '', CrossDockZone(), PutAwayAndPickBinType(), '', 0, 500, 0, 0, true, false, '');
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Directed Pick", 'W-14-0003', '', CrossDockZone(), PutAwayAndPickBinType(), ColdClass(), 0, 500, 0, 0, true, false, '');
        ContosoWarehouse.InsertBin(WhseDemoDataSetup."Location Directed Pick", 'W-14-0004', '', CrossDockZone(), PutAwayAndPickBinType(), '', 0, 500, 0, 0, true, false, '');
    end;

    local procedure UpdateAdvancedLocationWithBins()
    var
        Location: Record "Location";
    begin
        Location.Get(WhseDemoDataSetup."Location Directed Pick");

        Location.Validate("Adjustment Bin Code", BinW990001());
        Location.Validate("Receipt Bin Code", BinW080001());
        Location.Validate("Shipment Bin Code", BinW090001());
        Location.Validate("Cross-Dock Bin Code", BinW140001());
        Evaluate(Location."Cross-Dock Due Date Calc.", '<1W>');
        Location.Validate("To-Assembly Bin Code", BinW070004());
        Location.Validate("From-Assembly Bin Code", BinW070005());
        Location.Validate("Open Shop Floor Bin Code", BinW070001());
        Location.Validate("To-Production Bin Code", BinW070002());
        Location.Validate("From-Production Bin Code", BinW070003());
        Location.Modify(true);
    end;

    procedure BasicLocation(): Code[10]
    begin
        exit(BasicLocationTok);
    end;

    procedure SimpleLocation(): Code[10]
    begin
        exit(SimpleLocationTok);
    end;

    procedure AdvancedLocation(): Code[10]
    begin
        exit(AdvancedLocationTok);
    end;

    procedure TransitLocation(): Code[10]
    begin
        exit(TransitLocationTok);
    end;

    procedure ColdClass(): Code[10]
    begin
        exit(ColdTok);
    end;

    procedure FrozenClass(): Code[10]
    begin
        exit(FrozenTok);
    end;

    procedure ForkliftEquipment(): Code[10]
    begin
        exit(FORKLIFTTok);
    end;

    procedure PickBinType(): Code[10]
    begin
        exit(PickTok);
    end;

    procedure PickZone(): Code[10]
    begin
        exit(PickTok);
    end;

    procedure BulkZone(): Code[10]
    begin
        exit(BulkTok);
    end;

    procedure ShipBinType(): Code[10]
    begin
        exit(ShipTok);
    end;

    procedure ShipZone(): Code[10]
    begin
        exit(ShipTok);
    end;

    procedure ReceiveBinType(): Code[10]
    begin
        exit(ReceiveTok);
    end;

    procedure ReceiveZone(): Code[10]
    begin
        exit(ReceiveTok);
    end;

    procedure QualityControlBinType(): Code[10]
    begin
        exit(QCTok);
    end;

    procedure QualityControlZone(): Code[10]
    begin
        exit(QCTok);
    end;

    procedure PutAwayAndPickBinType(): Code[10]
    begin
        exit(PutPickTok);
    end;

    procedure PutAwayBinType(): Code[10]
    begin
        exit(PutAwayTok);
    end;

    procedure OperationZone(): Code[10]
    begin
        exit(OperationTok);
    end;

    procedure CrossDockZone(): Code[10]
    begin
        exit(CrossDuckTok);
    end;

    procedure StorageZone(): Code[10]
    begin
        exit(StorageTok);
    end;


    procedure AdjustmentZone(): Code[10]
    begin
        exit(AdjustmentTok);
    end;

    procedure BinW990001(): Code[20]
    begin
        exit('W-99-0001');
    end;

    procedure BinW080001(): Code[20]
    begin
        exit('W-08-0001');
    end;

    procedure BinW090001(): Code[20]
    begin
        exit('W-09-0001');
    end;

    procedure BinW140001(): Code[20]
    begin
        exit('W-14-0001');
    end;

    procedure BinW070001(): Code[20]
    begin
        exit('W-07-0001');
    end;

    procedure BinW070002(): Code[20]
    begin
        exit('W-07-0002');
    end;

    procedure BinW070003(): Code[20]
    begin
        exit('W-07-0003');
    end;

    procedure BinW070004(): Code[20]
    begin
        exit('W-07-0004');
    end;

    procedure BinW070005(): Code[20]
    begin
        exit('W-07-0005');
    end;
}
