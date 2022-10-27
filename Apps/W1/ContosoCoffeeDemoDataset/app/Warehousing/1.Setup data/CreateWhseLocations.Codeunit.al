codeunit 4787 "Create Whse Locations"
{
    Permissions = tabledata "Location" = rim;

    var
        DoInsertTriggers: Boolean;

    trigger OnRun()
    begin
        CreateCollection(false);
    end;

    local procedure TextAsGuid(InputText: Text) OutputGuid: Guid
    begin
        Evaluate(OutputGuid, InputText);
    end;

    local procedure TextAsDateFormula(InputText: Text) OutputDateFormula: DateFormula
    begin
        Evaluate(OutputDateFormula, InputText);
    end;

    local procedure CreateLocation(
        Code: Code[10];
        Name: Text[100];
        DefaultBinCode: Code[20];
        NameTwo: Text[50];
        Address: Text[100];
        AddressTwo: Text[50];
        City: Text[30];
        PostCode: Code[20];
        CountryRegionCode: Code[10];
        UseAsInTransit: Boolean;
        RequirePutaway: Boolean;
        RequirePick: Boolean;
        CrossDockDueDateCalc: DateFormula;
        UseCrossDocking: Boolean;
        RequireReceive: Boolean;
        RequireShipment: Boolean;
        BinMandatory: Boolean;
        DirectedPutawayandPick: Boolean;
        DefaultBinSelection: Enum "Location Default Bin Selection";
        OutboundWhseHandlingTime: DateFormula;
        InboundWhseHandlingTime: DateFormula;
        PutawayTemplateCode: Code[10];
        UsePutawayWorksheet: Boolean;
        PickAccordingtoFEFO: Boolean;
        AllowBreakbulk: Boolean;
        BinCapacityPolicy: Option;
        AdjustmentBinCode: Code[20];
        AlwaysCreatePutawayLine: Boolean;
        AlwaysCreatePickLine: Boolean;
        ReceiptBinCode: Code[20];
        ShipmentBinCode: Code[20];
        CrossDockBinCode: Code[20];
        ToAssemblyBinCode: Code[20];
        FromAssemblyBinCode: Code[20];
        AsmtoOrderShptBinCode: Code[20];
        UseADCS: Boolean
    )
    var
        Location: Record "Location";
    begin
        Location.Init();
        Location."Code" := Code;
        Location."Name" := Name;
        Location."Default Bin Code" := DefaultBinCode;
        Location."Name 2" := NameTwo;
        Location."Address" := Address;
        Location."Address 2" := AddressTwo;
        Location."City" := City;
        Location."Post Code" := PostCode;
        Location."Country/Region Code" := CountryRegionCode;
        Location."Use As In-Transit" := UseAsInTransit;
        Location."Require Put-away" := RequirePutaway;
        Location."Require Pick" := RequirePick;
        Location."Cross-Dock Due Date Calc." := CrossDockDueDateCalc;
        Location."Use Cross-Docking" := UseCrossDocking;
        Location."Require Receive" := RequireReceive;
        Location."Require Shipment" := RequireShipment;
        Location."Bin Mandatory" := BinMandatory;
        Location."Directed Put-away and Pick" := DirectedPutawayandPick;
        Location."Default Bin Selection" := DefaultBinSelection;
        Location."Outbound Whse. Handling Time" := OutboundWhseHandlingTime;
        Location."Inbound Whse. Handling Time" := InboundWhseHandlingTime;
        Location."Put-away Template Code" := PutawayTemplateCode;
        Location."Use Put-away Worksheet" := UsePutawayWorksheet;
        Location."Pick According to FEFO" := PickAccordingtoFEFO;
        Location."Allow Breakbulk" := AllowBreakbulk;
        Location."Bin Capacity Policy" := BinCapacityPolicy;
        Location."Adjustment Bin Code" := AdjustmentBinCode;
        Location."Always Create Put-away Line" := AlwaysCreatePutawayLine;
        Location."Always Create Pick Line" := AlwaysCreatePickLine;
        Location."Receipt Bin Code" := ReceiptBinCode;
        Location."Shipment Bin Code" := ShipmentBinCode;
        Location."Cross-Dock Bin Code" := CrossDockBinCode;
        Location."To-Assembly Bin Code" := ToAssemblyBinCode;
        Location."From-Assembly Bin Code" := FromAssemblyBinCode;
        Location."Asm.-to-Order Shpt. Bin Code" := AsmtoOrderShptBinCode;
        Location."Use ADCS" := UseADCS;
        Location.Insert(DoInsertTriggers);
    end;

    local procedure CreateCollection(ShouldRunInsertTriggers: Boolean)
    begin
        DoInsertTriggers := ShouldRunInsertTriggers;
        CreateLocation('SILVER', 'Silver Warehouse', '', '', 'Pier 10, 2', '', 'West End Lane', 'WC1 2GS', 'GB', false, true, true, TextAsDateFormula(''), true, true, true, true, false, Enum::"Location Default Bin Selection"::"Fixed Bin", TextAsDateFormula(''), TextAsDateFormula(''), '', false, false, false, 0, '', false, false, '', '', '', '', '', '', false);
        CreateLocation('WHITE', 'White Warehouse', '', '', 'Merrily Grove Avenue 6, 2', '', 'West End Lane', 'WC1 2GS', 'GB', false, true, true, TextAsDateFormula(''), true, true, true, true, true, Enum::"Location Default Bin Selection"::" ", TextAsDateFormula(''), TextAsDateFormula(''), 'STD', false, false, true, 2, 'W-11-0001', false, false, 'W-08-0001', 'W-09-0001', 'W-14-0001', 'W-07-0002', 'W-07-0003', '', true);
        CreateLocation('YELLOW', 'Yellow Warehouse', '', '', 'Main Bristol Street, 10', '', 'Bristol', 'BS3 6KL', 'GB', false, true, true, TextAsDateFormula(''), false, true, true, false, false, Enum::"Location Default Bin Selection"::" ", TextAsDateFormula('1D'), TextAsDateFormula('1D'), '', false, false, false, 0, '', false, false, '', '', '', '', '', '', false);
    end;
}
