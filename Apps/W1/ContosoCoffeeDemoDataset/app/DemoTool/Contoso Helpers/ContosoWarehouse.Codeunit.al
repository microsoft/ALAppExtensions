codeunit 5147 "Contoso Warehouse"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata Location = rim,
        tabledata "Bin Type" = rim,
        tabledata "Bin" = rim,
        tabledata "Zone" = rim,
        tabledata "Warehouse Class" = rim,
        tabledata "Special Equipment" = rim,
        tabledata "Put-away Template Header" = rim,
        tabledata "Put-away Template Line" = rim,
        tabledata "Warehouse Employee" = rim;

    var
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertLocation(Code: Code[10]; Name: Text[100]; Address: Text[100]; RequirePutAway: Boolean; RequirePick: Boolean; UseCrossDocking: Boolean; RequireReceive: Boolean; RequireShipment: Boolean; BinMandatory: Boolean; DirectedPutAwayAndPick: Boolean; PutAwayBinPolicy: Enum "Put-away Bin Policy"; PickBinPolicy: Enum "Pick Bin Policy"; DefaultBinSelection: Enum "Location Default Bin Selection"; PutAwayTemplateCode: Code[10]; AllowBreakBulk: Boolean; BinCapacityPolicy: Option; SpecialEquipment: Option; AlwaysCreatePutAwayLine: Boolean; AlwaysCreatePickLine: Boolean; UseAsInTransit: Boolean)
    var
        ProdConsumpWhseHandling: Enum "Prod. Consump. Whse. Handling";
        ProdOutputWhseHandling: Enum "Prod. Output Whse. Handling";
        JobConsumpWhseHandling: Enum "Job Consump. Whse. Handling";
        AsmConsumpWhseHandling: Enum "Asm. Consump. Whse. Handling";
    begin

        case true of
            not RequirePick and not RequireShipment:
                begin
                    ProdConsumpWhseHandling := ProdConsumpWhseHandling::"Warehouse Pick (optional)";
                    AsmConsumpWhseHandling := AsmConsumpWhseHandling::"Warehouse Pick (optional)";
                    JobConsumpWhseHandling := JobConsumpWhseHandling::"Warehouse Pick (optional)";
                end;
            not RequirePick and RequireShipment:
                begin
                    ProdConsumpWhseHandling := ProdConsumpWhseHandling::"Warehouse Pick (optional)";
                    AsmConsumpWhseHandling := AsmConsumpWhseHandling::"Warehouse Pick (optional)";
                    JobConsumpWhseHandling := JobConsumpWhseHandling::"Warehouse Pick (optional)";
                end;
            RequirePick and not RequireShipment:
                begin
                    ProdConsumpWhseHandling := ProdConsumpWhseHandling::"Inventory Pick/Movement";
                    AsmConsumpWhseHandling := AsmConsumpWhseHandling::"Inventory Movement";
                    JobConsumpWhseHandling := JobConsumpWhseHandling::"Inventory Pick";
                end;
            RequirePick and RequireShipment:
                begin
                    ProdConsumpWhseHandling := ProdConsumpWhseHandling::"Warehouse Pick (mandatory)";
                    AsmConsumpWhseHandling := AsmConsumpWhseHandling::"Warehouse Pick (mandatory)";
                    JobConsumpWhseHandling := JobConsumpWhseHandling::"Warehouse Pick (mandatory)";
                end;
        end;

        case true of
            not RequirePutaway and not RequireReceive,
            not RequirePutaway and RequireReceive,
            RequirePutaway and RequireReceive:
                ProdOutputWhseHandling := ProdOutputWhseHandling::"No Warehouse Handling";
            RequirePutaway and not RequireReceive:
                ProdOutputWhseHandling := ProdOutputWhseHandling::"Inventory Put-away";

        end;
        InsertLocation(Code, Name, Address, RequirePutAway, RequirePick, UseCrossDocking, RequireReceive, RequireShipment, BinMandatory, DirectedPutAwayAndPick, PutAwayBinPolicy, PickBinPolicy, DefaultBinSelection, PutAwayTemplateCode, ProdConsumpWhseHandling, ProdOutputWhseHandling, JobConsumpWhseHandling, AsmConsumpWhseHandling, AllowBreakBulk, BinCapacityPolicy, SpecialEquipment, AlwaysCreatePutAwayLine, AlwaysCreatePickLine, UseAsInTransit);
    end;

    procedure InsertLocation(Code: Code[10];
            Name:
                Text[100];
            Address:
                Text[100];
            RequirePutAway:
                Boolean;
            RequirePick:
                Boolean;
            UseCrossDocking:
                Boolean;
            RequireReceive:
                Boolean;
            RequireShipment:
                Boolean;
            BinMandatory:
                Boolean;
            DirectedPutAwayAndPick:
                Boolean;
            PutAwayBinPolicy:
                Enum "Put-away Bin Policy";
            PickBinPolicy:
                Enum "Pick Bin Policy";
            DefaultBinSelection:
                Enum "Location Default Bin Selection";
            PutAwayTemplateCode:
                Code[10];
            ProdConumpWhseHandling:
                Enum "Prod. Consump. Whse. Handling";
            ProdOutputWhseHandling:
                Enum "Prod. Output Whse. Handling";
            JobConsumpWhseHandling:
                Enum "Job Consump. Whse. Handling";
            AsmConsumpWhseHandling:
                Enum "Asm. Consump. Whse. Handling";
            AllowBreakBulk:
                Boolean;
            BinCapacityPolicy:
                Option;
            SpecialEquipment:
                Option;
            AlwaysCreatePutAwayLine:
                Boolean;
            AlwaysCreatePickLine:
                Boolean;
            UseAsInTransit:
                Boolean)
    var
        Location:
            Record Location;
        Exists:
                Boolean;
    begin
        if Location.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        Location.Validate("Code", Code);
        Location.Validate("Name", Name);
        Location.Validate(Address, Address);
        Location.Validate("Use As In-Transit", UseAsInTransit);
        Location.Validate("Require Receive", RequireReceive);
        Location.Validate("Require Shipment", RequireShipment);
        Location.Validate("Require Put-away", RequirePutAway);
        Location.Validate("Require Pick", RequirePick);
        Location.Validate("Use Cross-Docking", UseCrossDocking);
        Location.Validate("Bin Mandatory", BinMandatory);
        Location.Validate("Directed Put-away and Pick", DirectedPutAwayAndPick);
        Location.Validate("Default Bin Selection", DefaultBinSelection);
        Location.Validate("Put-away Bin Policy", PutAwayBinPolicy);
        Location.Validate("Pick Bin Policy", PickBinPolicy);
        Location.Validate("Put-away Template Code", PutAwayTemplateCode);
        Location.Validate("Always Create Put-away Line", DirectedPutAwayAndPick);
        Location.Validate("Allow Breakbulk", AllowBreakBulk);
        Location.Validate("Bin Capacity Policy", BinCapacityPolicy);
        Location.Validate("Special Equipment", SpecialEquipment);
        Location.Validate("Always Create Put-away Line", AlwaysCreatePutAwayLine);
        Location.Validate("Always Create Pick Line", AlwaysCreatePickLine);
        Location.Validate("Prod. Consump. Whse. Handling", ProdConumpWhseHandling);
        Location.Validate("Prod. Output Whse. Handling", ProdOutputWhseHandling);
        Location.Validate("Job Consump. Whse. Handling", JobConsumpWhseHandling);
        Location.Validate("Asm. Consump. Whse. Handling", AsmConsumpWhseHandling);

        if Exists then
            Location.Modify(true)
        else
            Location.Insert(true);
    end;

    procedure InsertLocation(Code: Code[10]; Name: Text[100]; Address: Text[100]; UseAsInTransit: Boolean)
    begin
        InsertLocation(Code, Name, Address, false, false, false, false, false, false, false, "Put-away Bin Policy"::"Default Bin", "Pick Bin Policy"::"Default Bin", Enum::"Location Default Bin Selection"::" ", '', Enum::"Prod. Consump. Whse. Handling"::"No Warehouse Handling", Enum::"Prod. Output Whse. Handling"::"No Warehouse Handling", Enum::"Job Consump. Whse. Handling"::"No Warehouse Handling", Enum::"Asm. Consump. Whse. Handling"::"No Warehouse Handling", false, 0, 0, false, false, UseAsInTransit);
    end;

    procedure InsertBinType(Code: Code[10]; Description: Text[100]; Receive: Boolean; Ship: Boolean; PutAway: Boolean; Pick: Boolean)
    var
        BinType: Record "Bin Type";
        Exists: Boolean;
    begin
        if BinType.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        BinType.Validate("Code", Code);
        BinType.Validate("Description", Description);
        BinType.Validate("Receive", Receive);
        BinType.Validate("Ship", Ship);
        BinType.Validate("Put Away", PutAway);
        BinType.Validate("Pick", Pick);

        if Exists then
            BinType.Modify(true)
        else
            BinType.Insert(true);
    end;

    procedure InsertBin(LocationCode: Code[10]; Code: Code[20]; Description: Text[100]; ZoneCode: Code[10]; BinTypeCode: Code[10]; WarehouseClassCode: Code[10]; BlockMovement: Option; BinRanking: Integer; MaximumCubage: Decimal; MaximumWeight: Decimal; CrossDockBin: Boolean; Dedicated: Boolean; SpecialEquipmentCode: Code[10])
    var
        Bin: Record Bin;
        Exists: Boolean;
    begin
        if Bin.Get(LocationCode, Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        Bin.Validate("Location Code", LocationCode);
        Bin.Validate("Code", Code);
        Bin.Validate("Description", Description);
        Bin.Validate("Zone Code", ZoneCode);
        Bin.Validate("Bin Type Code", BinTypeCode);
        Bin.Validate("Warehouse Class Code", WarehouseClassCode);
        Bin.Validate("Block Movement", BlockMovement);
        Bin.Validate("Bin Ranking", BinRanking);
        Bin.Validate("Maximum Cubage", MaximumCubage);
        Bin.Validate("Maximum Weight", MaximumWeight);
        Bin.Validate("Cross-Dock Bin", CrossDockBin);
        Bin.Validate("Dedicated", Dedicated);
        Bin.Validate("Special Equipment Code", SpecialEquipmentCode);

        if Exists then
            Bin.Modify(true)
        else
            Bin.Insert(true);
    end;

    procedure InsertZone(LocationCode: Code[10]; Code: Code[10]; Description: Text[100]; BinTypeCode: Code[10]; WarehouseClassCode: Code[10]; ZoneRanking: Integer; CrossDockBinZone: Boolean; SpecialEquipmentCode: Code[10])
    var
        Zone: Record "Zone";
        Exists: Boolean;
    begin
        if Zone.Get(LocationCode, Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        Zone.Validate("Location Code", LocationCode);
        Zone.Validate("Code", Code);
        Zone.Validate("Description", Description);
        Zone.Validate("Bin Type Code", BinTypeCode);
        Zone.Validate("Warehouse Class Code", WarehouseClassCode);
        Zone.Validate("Zone Ranking", ZoneRanking);
        Zone.Validate("Cross-Dock Bin Zone", CrossDockBinZone);
        Zone.Validate("Special Equipment Code", SpecialEquipmentCode);

        if Exists then
            Zone.Modify(true)
        else
            Zone.Insert(true);
    end;

    procedure InsertWarehouseClass(Code: Code[10]; Description: Text[100])
    var
        WarehouseClass: Record "Warehouse Class";
        Exists: Boolean;
    begin
        if WarehouseClass.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        WarehouseClass.Validate("Code", Code);
        WarehouseClass.Validate("Description", Description);

        if Exists then
            WarehouseClass.Modify(true)
        else
            WarehouseClass.Insert(true);
    end;

    procedure InsertSpecialEquipment(Code: Code[10]; Description: Text[100])
    var
        SpecialEquipment: Record "Special Equipment";
        Exists: Boolean;
    begin
        if SpecialEquipment.Get() then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        SpecialEquipment.Validate("Code", Code);
        SpecialEquipment.Validate("Description", Description);

        if Exists then
            SpecialEquipment.Modify(true)
        else
            SpecialEquipment.Insert(true);
    end;

    procedure InsertPutAwayTemplateHeader(Code: Code[10]; Description: Text[100])
    var
        PutAwayTemplateHeader: Record "Put-away Template Header";
        Exists: Boolean;
    begin
        if PutAwayTemplateHeader.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        PutAwayTemplateHeader.Validate("Code", Code);
        PutAwayTemplateHeader.Validate("Description", Description);

        if Exists then
            PutAwayTemplateHeader.Modify(true)
        else
            PutAwayTemplateHeader.Insert(true);
    end;

    procedure InsertPutAwayTemplateLine(TemplateCode: Code[10]; Description: Text[100]; FindFixedBin: Boolean; FindFloatingBin: Boolean; FindSameItem: Boolean; FindUnitOfMeasureMatch: Boolean; FindBinwLessthanMinQty: Boolean; FindEmptyBin: Boolean)
    var
        PutAwayTemplateLine: Record "Put-away Template Line";
    begin
        PutAwayTemplateLine.Validate("Put-away Template Code", TemplateCode);
        PutAwayTemplateLine.Validate("Line No.", GetNextPutAwayTemplateLineNo(TemplateCode));
        PutAwayTemplateLine.Validate("Description", Description);
        PutAwayTemplateLine.Validate("Find Fixed Bin", FindFixedBin);
        PutAwayTemplateLine.Validate("Find Floating Bin", FindFloatingBin);
        PutAwayTemplateLine.Validate("Find Same Item", FindSameItem);
        PutAwayTemplateLine.Validate("Find Unit of Measure Match", FindUnitOfMeasureMatch);
        PutAwayTemplateLine.Validate("Find Bin w. Less than Min. Qty", FindBinwLessthanMinQty);
        PutAwayTemplateLine.Validate("Find Empty Bin", FindEmptyBin);
        PutAwayTemplateLine.Insert(true);
    end;

    local procedure GetNextPutAwayTemplateLineNo(TemplateCode: Code[10]): Integer
    var
        PutAwayTemplateLine: Record "Put-away Template Line";
    begin
        PutAwayTemplateLine.SetRange("Put-away Template Code", TemplateCode);
        PutAwayTemplateLine.SetCurrentKey("Line No.");

        if PutAwayTemplateLine.FindLast() then
            exit(PutAwayTemplateLine."Line No." + 10000)
        else
            exit(10000);
    end;

    procedure InsertWarehouseEmployee(UserID: Code[50]; LocationCode: Code[10]; Default: Boolean)
    var
        WarehouseEmployee: Record "Warehouse Employee";
        Exists: Boolean;
    begin
        if WarehouseEmployee.Get(UserID, LocationCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        WarehouseEmployee.Validate("User ID", UserID);
        WarehouseEmployee.Validate("Location Code", LocationCode);
        WarehouseEmployee.Validate("Default", Default);

        if Exists then
            WarehouseEmployee.Modify(true)
        else
            WarehouseEmployee.Insert(true);
    end;
}