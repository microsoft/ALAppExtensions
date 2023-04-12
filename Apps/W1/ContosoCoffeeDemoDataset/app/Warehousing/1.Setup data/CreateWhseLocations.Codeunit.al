codeunit 4787 "Create Whse Locations"
{
    Permissions = tabledata "Location" = ri,
        tabledata "Warehouse Employee" = ri;

    var
        WhseDemoDataSetup: Record "Whse Demo Data Setup";
        DoInsertTriggers: Boolean;
        BASICLOCNAMETok: Label 'Silver Warehouse';
        SIMPLELOCNAMETok: Label 'Yellow Warehouse';
        ADVLOCNAMETok: Label 'White Warehouse';
        TRANSITLOCNAMETok: Label 'Own Logistics';
        STDTok: Label 'STD', Locked = true, Comment = 'Should be the same as the Put Away Template code.';


    trigger OnRun()
    var
        IsHandled: Boolean;
    begin
        WhseDemoDataSetup.Get();
        CreateLocations(false);
        OnAfterCreateLocations();

        OnBeforeAddCurrentUserAsWhseEmployee(IsHandled);
        if not IsHandled then
            AddUserAsWarehouseEmployee(CopyStr(UserId, 1, 50));
    end;

    local procedure CreateLocation(
        Code: Code[10];
        Name: Text[100];
        RequirePutaway: Boolean;
        RequirePick: Boolean;
        UseCrossDocking: Boolean;
        RequireReceive: Boolean;
        RequireShipment: Boolean;
        BinMandatory: Boolean;
        DirectedPutawayandPick: Boolean;
        DefaultBinSelection: Enum "Location Default Bin Selection";
        PutawayTemplateCode: Code[10];
        AllowBreakbulk: Boolean;
        BinCapacityPolicy: Option;
        AdjustmentBinCode: Code[20];
        ReceiptBinCode: Code[20];
        ShipmentBinCode: Code[20];
        CrossDockBinCode: Code[20];
        ToAssemblyBinCode: Code[20];
        FromAssemblyBinCode: Code[20];
        AsmtoOrderShptBinCode: Code[20];
        OpenShopFloorBinCode: Code[20];
        ToProductionBinCode: Code[20];
        FromProductionBinCode: Code[20];
        ToJobBinCode: Code[20]
        )
    var
        Location: Record "Location";
    begin
        if Location.Get(Code) then
            exit;
        Location.Init();
        Location."Code" := Code;
        Location."Name" := Name;
        Location."Use As In-Transit" := false;
        Location."Require Put-away" := RequirePutaway;
        Location."Require Pick" := RequirePick;
        Location."Use Cross-Docking" := UseCrossDocking;
        Location."Require Receive" := RequireReceive;
        Location."Require Shipment" := RequireShipment;
        Location."Bin Mandatory" := BinMandatory;
        Location.Validate("Directed Put-away and Pick", DirectedPutawayandPick);
        Location."Default Bin Selection" := DefaultBinSelection;
        Location."Put-away Template Code" := PutawayTemplateCode;
        Location."Always Create Put-away Line" := DirectedPutawayandPick;
        Location."Allow Breakbulk" := AllowBreakbulk;
        Location."Bin Capacity Policy" := BinCapacityPolicy;
        Location."Adjustment Bin Code" := AdjustmentBinCode;
        Location."Receipt Bin Code" := ReceiptBinCode;
        Location."Shipment Bin Code" := ShipmentBinCode;
        Location."Cross-Dock Bin Code" := CrossDockBinCode;
        if CrossDockBinCode <> '' then
            Evaluate(Location."Cross-Dock Due Date Calc.", '<1W>');
        Location."To-Assembly Bin Code" := ToAssemblyBinCode;
        Location."From-Assembly Bin Code" := FromAssemblyBinCode;
        Location."Asm.-to-Order Shpt. Bin Code" := AsmtoOrderShptBinCode;
        Location."Open Shop Floor Bin Code" := OpenShopFloorBinCode;
        Location."To-Production Bin Code" := ToProductionBinCode;
        Location."From-Production Bin Code" := FromProductionBinCode;
        Location."To-Job Bin Code" := ToJobBinCode;
        OnBeforeInsertCreateLocation(Location);
        Location.Insert(DoInsertTriggers);
    end;

    local procedure CreateInTransitLocation(
        Code: Code[10];
        Name: Text[100])
    var
        Location: Record "Location";
    begin
        if Location.Get(Code) then
            exit;
        Location.Init();
        Location."Code" := Code;
        Location."Name" := Name;
        Location."Use As In-Transit" := True;
        OnBeforeInsertCreateLocation(Location);
        Location.Insert(DoInsertTriggers);
    end;

    local procedure CreateLocations(ShouldRunInsertTriggers: Boolean)
    begin
        DoInsertTriggers := ShouldRunInsertTriggers;
        CreateLocation(WhseDemoDataSetup."Location Bin", BASICLOCNAMETok, false, false, false, false, false, true, false, Enum::"Location Default Bin Selection"::"Fixed Bin", '', false, 0,
            '', '', '', '', '', '', '', '', '', '', '');
        CreateLocation(WhseDemoDataSetup."Location Adv Logistics", SIMPLELOCNAMETok, true, true, false, true, true, false, false, Enum::"Location Default Bin Selection"::" ", '', false, 0,
            '', '', '', '', '', '', '', '', '', '', '');
        CreateLocation(WhseDemoDataSetup."Location Directed Pick", ADVLOCNAMETok, true, true, true, true, true, true, true, Enum::"Location Default Bin Selection"::" ", STDTok, true, 2,
            'W-99-0001', 'W-08-0001', 'W-09-0001', 'W-14-0001', 'W-07-0004', 'W-07-0005', '', 'W-07-0001', 'W-07-0002', 'W-07-0003', '');
        CreateInTransitLocation(WhseDemoDataSetup."Location In-Transit", TRANSITLOCNAMETok);
    end;

    local procedure AddUserAsWarehouseEmployee(UserId: Text[50])
    var
        WarehouseEmployee: Record "Warehouse Employee";
    begin
        if not WarehouseEmployee.Get(UserId, WhseDemoDataSetup."Location Bin") then begin
            WarehouseEmployee.Init();
            WarehouseEmployee."User ID" := UserId;
            WarehouseEmployee."Location Code" := WhseDemoDataSetup."Location Bin";
            WarehouseEmployee.Insert(true);
        end;
        if not WarehouseEmployee.Get(UserId, WhseDemoDataSetup."Location Adv Logistics") then begin
            WarehouseEmployee.Init();
            WarehouseEmployee."User ID" := UserId;
            WarehouseEmployee."Location Code" := WhseDemoDataSetup."Location Adv Logistics";
            WarehouseEmployee.Insert(true);
        end;
        if not WarehouseEmployee.Get(UserId, WhseDemoDataSetup."Location Directed Pick") then begin
            WarehouseEmployee.Init();
            WarehouseEmployee."User ID" := UserId;
            WarehouseEmployee."Location Code" := WhseDemoDataSetup."Location Directed Pick";
            WarehouseEmployee.Default := true;
            WarehouseEmployee.Insert(true);
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeAddCurrentUserAsWhseEmployee(var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateLocations()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertCreateLocation(var Location: Record Location)
    begin
    end;
}
