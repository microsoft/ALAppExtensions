/// <summary>
/// Provides utility functions for creating and managing warehouse-related entities in test scenarios, including locations, bins, warehouse documents, and warehouse activities.
/// </summary>
codeunit 132204 "Library - Warehouse"
{

    trigger OnRun()
    begin
    end;

    var
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryAssembly: Codeunit "Library - Assembly";
        LibraryUtility: Codeunit "Library - Utility";
        Assert: Codeunit Assert;

    procedure AutoFillQtyHandleWhseActivity(WarehouseActivityHeaderRec: Record "Warehouse Activity Header")
    var
        WarehouseActivityLine: Record "Warehouse Activity Line";
    begin
        Clear(WarehouseActivityLine);
        WarehouseActivityLine.SetRange("Activity Type", WarehouseActivityHeaderRec.Type);
        WarehouseActivityLine.SetRange("No.", WarehouseActivityHeaderRec."No.");
        WarehouseActivityLine.AutofillQtyToHandle(WarehouseActivityLine);
    end;

    procedure AutoFillQtyInventoryActivity(WarehouseActivityHeader: Record "Warehouse Activity Header")
    begin
        AutoFillQtyHandleWhseActivity(WarehouseActivityHeader);
    end;

    procedure AutofillQtyToShipWhseShipment(var WarehouseShipmentHeader: Record "Warehouse Shipment Header")
    var
        WarehouseShipmentLine: Record "Warehouse Shipment Line";
        WarehouseShipmentLine2: Record "Warehouse Shipment Line";
    begin
        Clear(WarehouseShipmentLine);
        WarehouseShipmentLine.SetRange("No.", WarehouseShipmentHeader."No.");
        WarehouseShipmentLine.FindLast();
        WarehouseShipmentLine2.Copy(WarehouseShipmentLine);
        WarehouseShipmentLine.AutofillQtyToHandle(WarehouseShipmentLine2);
    end;

    procedure AutofillQtyToRecvWhseReceipt(var WarehouseReceiptHeader: Record "Warehouse Receipt Header")
    var
        WarehouseReceiptLine: Record "Warehouse Receipt Line";
        WarehouseReceiptLine2: Record "Warehouse Receipt Line";
    begin
        Clear(WarehouseReceiptLine);
        WarehouseReceiptLine.SetRange("No.", WarehouseReceiptHeader."No.");
        WarehouseReceiptLine.FindLast();
        WarehouseReceiptLine2.Copy(WarehouseReceiptLine);
        WarehouseReceiptLine.AutofillQtyToReceive(WarehouseReceiptLine2);
    end;

    procedure CalculateCountingPeriodOnWarehousePhysicalInventoryJournal(var WarehouseJournalLine: Record "Warehouse Journal Line")
    var
        PhysInvtCountManagement: Codeunit "Phys. Invt. Count.-Management";
    begin
        Commit();  // Commit is required.
        Clear(PhysInvtCountManagement);
        PhysInvtCountManagement.InitFromWhseJnl(WarehouseJournalLine);
        PhysInvtCountManagement.Run();
    end;

    procedure CalculatePlannedDate(OrgDateExpression: Text[30]; OrgDate: Date; CustomCalendarChange: array[2] of Record "Customized Calendar Change"; CheckBothCalendars: Boolean) PlannedDate: Date
    var
        CalendarManagement: Codeunit "Calendar Management";
    begin
        PlannedDate := CalendarManagement.CalcDateBOC(OrgDateExpression, OrgDate, CustomCalendarChange, CheckBothCalendars);
    end;

    procedure CalculateWhseAdjustment(var Item: Record Item; ItemJournalBatch: Record "Item Journal Batch")
    var
        ItemJournalLine: Record "Item Journal Line";
        TmpItem: Record Item;
        CalcWhseAdjmt: Report "Calculate Whse. Adjustment";
        NoSeries: Codeunit "No. Series";
        DocumentNo: Text[20];
    begin
        Clear(ItemJournalLine);
        ItemJournalLine.Init();
        ItemJournalLine.Validate("Journal Template Name", ItemJournalBatch."Journal Template Name");
        ItemJournalLine.Validate("Journal Batch Name", ItemJournalBatch.Name);

        Commit();
        CalcWhseAdjmt.SetItemJnlLine(ItemJournalLine);
        if (DocumentNo = '') and (ItemJournalBatch."No. Series" <> '') then
            DocumentNo := NoSeries.PeekNextNo(ItemJournalBatch."No. Series");
        CalcWhseAdjmt.InitializeRequest(WorkDate(), DocumentNo);
        if Item.HasFilter then
            TmpItem.CopyFilters(Item)
        else begin
            Item.Get(Item."No.");
            TmpItem.SetRange("No.", Item."No.");
        end;

        CalcWhseAdjmt.SetTableView(TmpItem);
        CalcWhseAdjmt.UseRequestPage(false);
        CalcWhseAdjmt.RunModal();
    end;

    procedure CalculateWhseAdjustmentItemJournal(var Item: Record Item; NewPostingDate: Date; DocumentNo: Text[20])
    var
        ItemJournalLine: Record "Item Journal Line";
        TmpItem: Record Item;
        ItemJournalTemplate: Record "Item Journal Template";
        ItemJournalBatch: Record "Item Journal Batch";
        CalculateWhseAdjustmentReport: Report "Calculate Whse. Adjustment";
        NoSeries: Codeunit "No. Series";
    begin
        LibraryAssembly.SetupItemJournal(ItemJournalTemplate, ItemJournalBatch);
        ItemJournalLine.Validate("Journal Template Name", ItemJournalBatch."Journal Template Name");
        ItemJournalLine.Validate("Journal Batch Name", ItemJournalBatch.Name);

        Commit();
        CalculateWhseAdjustmentReport.SetItemJnlLine(ItemJournalLine);
        if DocumentNo = '' then
            DocumentNo := NoSeries.PeekNextNo(ItemJournalBatch."No. Series", NewPostingDate);
        CalculateWhseAdjustmentReport.InitializeRequest(NewPostingDate, DocumentNo);
        if Item.HasFilter then
            TmpItem.CopyFilters(Item)
        else begin
            Item.Get(Item."No.");
            TmpItem.SetRange("No.", Item."No.");
        end;

        CalculateWhseAdjustmentReport.SetTableView(TmpItem);
        CalculateWhseAdjustmentReport.UseRequestPage(false);
        CalculateWhseAdjustmentReport.RunModal();
    end;

    procedure CalculateBinReplenishment(BinContent: Record "Bin Content"; WhseWorksheetName: Record "Whse. Worksheet Name"; LocationCode: Code[10]; AllowBreakBulk: Boolean; HideDialog: Boolean; DoNotFillQtyToHandle: Boolean)
    var
        CalculateBinReplenishmentReport: Report "Calculate Bin Replenishment";
    begin
        CalculateBinReplenishmentReport.InitializeRequest(
          WhseWorksheetName."Worksheet Template Name", WhseWorksheetName.Name, LocationCode, AllowBreakBulk, HideDialog,
          DoNotFillQtyToHandle);
        CalculateBinReplenishmentReport.SetTableView(BinContent);
        CalculateBinReplenishmentReport.UseRequestPage(false);
        CalculateBinReplenishmentReport.Run();
    end;

    procedure CalculateCrossDockLines(var WhseCrossDockOpportunity: Record "Whse. Cross-Dock Opportunity"; NewTemplateName: Code[10]; NewNameNo: Code[20]; NewLocationCode: Code[10])
    var
        WhseCrossDockManagement: Codeunit "Whse. Cross-Dock Management";
    begin
        WhseCrossDockManagement.CalculateCrossDockLines(WhseCrossDockOpportunity, NewTemplateName, NewNameNo, NewLocationCode);
    end;

    procedure ChangeUnitOfMeasure(var WarehouseActivityLine: Record "Warehouse Activity Line")
    var
        WarehouseActivityLine2: Record "Warehouse Activity Line";
        WhseChangeUnitOfMeasure: Report "Whse. Change Unit of Measure";
    begin
        Commit();
        Clear(WhseChangeUnitOfMeasure);
        WhseChangeUnitOfMeasure.DefWhseActLine(WarehouseActivityLine);
        WhseChangeUnitOfMeasure.RunModal();
        if WhseChangeUnitOfMeasure.ChangeUOMCode(WarehouseActivityLine2) then
            WarehouseActivityLine.ChangeUOMCode(WarehouseActivityLine, WarehouseActivityLine2);
    end;

    procedure CreateFullWMSLocation(var Location: Record Location; BinsPerZone: Integer)
    var
        PutAwayTemplateHeader: Record "Put-away Template Header";
        PutAwayTemplateLine: Record "Put-away Template Line";
        Zone: Record Zone;
        Bin: Record Bin;
    begin
        Clear(Location);
        Location.Init();

        CreateLocationWithInventoryPostingSetup(Location);
        // Skip validate trigger for bin mandatory to improve performance.
        Location."Bin Mandatory" := true;
        Location.Validate("Directed Put-away and Pick", true);
        Location.Validate("Use Cross-Docking", true);
        if Location."Require Pick" then
            if Location."Require Shipment" then begin
                Location."Prod. Consump. Whse. Handling" := Location."Prod. Consump. Whse. Handling"::"Warehouse Pick (mandatory)";
                Location."Asm. Consump. Whse. Handling" := Location."Asm. Consump. Whse. Handling"::"Warehouse Pick (mandatory)";
                Location."Job Consump. Whse. Handling" := Location."Job Consump. Whse. Handling"::"Warehouse Pick (mandatory)";
            end else begin
                Location."Prod. Consump. Whse. Handling" := Location."Prod. Consump. Whse. Handling"::"Inventory Pick/Movement";
                Location."Asm. Consump. Whse. Handling" := Location."Asm. Consump. Whse. Handling"::"Inventory Movement";
                Location."Job Consump. Whse. Handling" := Location."Job Consump. Whse. Handling"::"Inventory Pick";
            end
        else begin
            Location."Prod. Consump. Whse. Handling" := Location."Prod. Consump. Whse. Handling"::"Warehouse Pick (optional)";
            Location."Asm. Consump. Whse. Handling" := Location."Asm. Consump. Whse. Handling"::"Warehouse Pick (optional)";
            Location."Job Consump. Whse. Handling" := Location."Job Consump. Whse. Handling"::"Warehouse Pick (optional)";
        end;

        if Location."Require Put-away" and not Location."Require Receive" then
            Location."Prod. Output Whse. Handling" := Location."Prod. Output Whse. Handling"::"Inventory Put-away";
        Location.Modify(true);

        // Create Zones and bins
        // Fill in Bins fast tab
        // 1. Adjustment
        CreateZone(Zone, 'ADJUSTMENT', Location.Code, SelectBinType(false, false, false, false), '', '', 0, false);
        CreateNumberOfBins(Location.Code, Zone.Code, SelectBinType(false, false, false, false), BinsPerZone, false);
        FindBin(Bin, Location.Code, Zone.Code, 1);
        Location.Validate("Adjustment Bin Code", Bin.Code);

        // 2. Bulk zone
        CreateZone(Zone, 'BULK', Location.Code, SelectBinType(false, false, true, false), '', '', 50, false);
        CreateNumberOfBins(Location.Code, Zone.Code, SelectBinType(false, false, true, false), BinsPerZone, false);

        // 3. Cross-dock zone
        CreateZone(Zone, 'CROSS-DOCK', Location.Code, SelectBinType(false, false, true, true), '', '', 0, true);
        CreateNumberOfBins(Location.Code, Zone.Code, SelectBinType(false, false, true, true), BinsPerZone, true);
        FindBin(Bin, Location.Code, Zone.Code, 1);
        Location.Validate("Cross-Dock Bin Code", Bin.Code);

        // 4. Pick zone
        CreateZone(Zone, 'PICK', Location.Code, SelectBinType(false, false, true, true), '', '', 100, false);
        CreateNumberOfBins(Location.Code, Zone.Code, SelectBinType(false, false, true, true), BinsPerZone, false);

        // 5. Production zone
        CreateZone(Zone, 'PRODUCTION', Location.Code, SelectBinType(false, false, false, false), '', '', 5, false);
        CreateNumberOfBins(Location.Code, Zone.Code, SelectBinType(false, false, false, false), BinsPerZone, false);
        FindBin(Bin, Location.Code, Zone.Code, 1);
        Location.Validate("Open Shop Floor Bin Code", Bin.Code);
        FindBin(Bin, Location.Code, Zone.Code, 2);
        Location.Validate("To-Production Bin Code", Bin.Code);
        FindBin(Bin, Location.Code, Zone.Code, 3);
        Location.Validate("From-Production Bin Code", Bin.Code);

        // 6. QC zone
        CreateZone(Zone, 'QC', Location.Code, SelectBinType(false, false, false, false), '', '', 0, false);
        CreateNumberOfBins(Location.Code, Zone.Code, SelectBinType(false, false, false, false), BinsPerZone, false);
        FindBin(Bin, Location.Code, Zone.Code, 1);
        Location.Validate("To-Assembly Bin Code", Bin.Code);
        FindBin(Bin, Location.Code, Zone.Code, 2);
        Location.Validate("From-Assembly Bin Code", Bin.Code);

        // 7. Receive Zone
        CreateZone(Zone, 'RECEIVE', Location.Code, SelectBinType(true, false, false, false), '', '', 10, false);
        CreateNumberOfBins(Location.Code, Zone.Code, SelectBinType(true, false, false, false), BinsPerZone, false);
        FindBin(Bin, Location.Code, Zone.Code, 1);
        Location.Validate("Receipt Bin Code", Bin.Code);

        // 8. Ship Zone
        CreateZone(Zone, 'SHIP', Location.Code, SelectBinType(false, true, false, false), '', '', 200, false);
        CreateNumberOfBins(Location.Code, Zone.Code, SelectBinType(false, true, false, false), BinsPerZone, false);
        FindBin(Bin, Location.Code, Zone.Code, 1);
        Location.Validate("Shipment Bin Code", Bin.Code);

        // 9. Stage zone
        CreateZone(Zone, 'STAGE', Location.Code, SelectBinType(false, true, false, false), '', '', 5, false);
        CreateNumberOfBins(Location.Code, Zone.Code, SelectBinType(false, true, false, false), BinsPerZone, false);

        // Bin policies fast tab
        // Created the STD put-away template - same as the one in the demo data
        CreatePutAwayTemplateHeader(PutAwayTemplateHeader);
        CreatePutAwayTemplateLine(PutAwayTemplateHeader, PutAwayTemplateLine, true, false, true, true, true, false);
        CreatePutAwayTemplateLine(PutAwayTemplateHeader, PutAwayTemplateLine, true, false, true, true, false, false);
        CreatePutAwayTemplateLine(PutAwayTemplateHeader, PutAwayTemplateLine, false, true, true, true, false, false);
        CreatePutAwayTemplateLine(PutAwayTemplateHeader, PutAwayTemplateLine, false, true, true, false, false, false);
        CreatePutAwayTemplateLine(PutAwayTemplateHeader, PutAwayTemplateLine, false, true, false, false, false, true);
        CreatePutAwayTemplateLine(PutAwayTemplateHeader, PutAwayTemplateLine, false, true, false, false, false, false);
        Location.Validate("Put-away Template Code", PutAwayTemplateHeader.Code);

        Location.Validate("Allow Breakbulk", true);

        Location.Modify(true);

        OnAfterCreateFullWMSLocation(Location, BinsPerZone);
    end;

    procedure CreateBin(var Bin: Record Bin; LocationCode: Code[10]; BinCode: Code[20]; ZoneCode: Code[10]; BinTypeCode: Code[10])
    begin
        Clear(Bin);
        Bin.Init();
        Bin.Validate("Location Code", LocationCode);
        if BinCode = '' then
            BinCode := LibraryUtility.GenerateRandomCode(Bin.FieldNo(Code), DATABASE::Bin);
        Bin.Validate(Code, BinCode);
        Bin.Validate("Bin Type Code", BinTypeCode);
        Bin.Validate("Zone Code", ZoneCode);
        Bin.Insert(true);

        OnAfterCreateBin(Bin, LocationCode, BinCode, ZoneCode, BinTypeCode);
    end;

    procedure CreateBinContent(var BinContent: Record "Bin Content"; LocationCode: Code[10]; ZoneCode: Code[10]; BinCode: Code[20]; ItemNo: Code[20]; VariantCode: Code[10]; UnitOfMeasureCode: Code[10])
    var
        Bin: Record Bin;
    begin
        BinContent.Init();
        BinContent.Validate("Location Code", LocationCode);
        BinContent.Validate("Bin Code", BinCode);
        BinContent.Validate("Item No.", ItemNo);
        BinContent.Validate("Variant Code", VariantCode);
        BinContent.Validate("Unit of Measure Code", UnitOfMeasureCode);
        if ZoneCode = '' then begin
            Bin.Get(LocationCode, BinCode);
            ZoneCode := Bin."Zone Code";
        end;
        BinContent.Validate("Zone Code", ZoneCode);
        BinContent.Insert(true);
    end;

    procedure CreateBinCreationWorksheetLine(var BinCreationWorksheetLine: Record "Bin Creation Worksheet Line"; WorksheetTemplateName: Code[10]; Name: Code[10]; LocationCode: Code[10]; BinCode: Code[20])
    var
        RecRef: RecordRef;
    begin
        BinCreationWorksheetLine.Init();
        BinCreationWorksheetLine.Validate("Worksheet Template Name", WorksheetTemplateName);
        BinCreationWorksheetLine.Validate(Name, Name);
        BinCreationWorksheetLine.Validate("Location Code", LocationCode);
        BinCreationWorksheetLine.Validate("Bin Code", BinCode);
        RecRef.GetTable(BinCreationWorksheetLine);
        BinCreationWorksheetLine.Validate("Line No.", LibraryUtility.GetNewLineNo(RecRef, BinCreationWorksheetLine.FieldNo("Line No.")));
        BinCreationWorksheetLine.Insert(true);
    end;

    procedure CreateBinTemplate(var BinTemplate: Record "Bin Template"; LocationCode: Code[10])
    begin
        BinTemplate.Init();
        BinTemplate.Validate(Code, LibraryUtility.GenerateRandomCode(BinTemplate.FieldNo(Code), DATABASE::Location));
        BinTemplate.Insert(true);
        BinTemplate.Validate("Location Code", LocationCode);
        BinTemplate.Modify(true);
    end;

    procedure CreateBinType(var BinType: Record "Bin Type"; Receive: Boolean; Ship: Boolean; PutAway: Boolean; Pick: Boolean)
    begin
        Clear(BinType);
        BinType.Init();

        BinType.Code := LibraryUtility.GenerateRandomCode(BinType.FieldNo(Code), DATABASE::"Bin Type");
        BinType.Description := BinType.Code;
        BinType.Receive := Receive;
        BinType.Ship := Ship;
        BinType."Put Away" := PutAway;
        BinType.Pick := Pick;
        BinType.Insert(true);
    end;

#if not CLEAN27
#pragma warning disable AL0801
    [Obsolete('Moved to codeunit LibraryManufacturing', '27.0')]
    procedure CreateInboundWhseReqFromProdO(ProductionOrder: Record "Production Order")
    var
        LibraryManufacturing: Codeunit "Library - Manufacturing";
    begin
        LibraryManufacturing.CreateInboundWhseReqFromProdOrder(ProductionOrder);
    end;
#pragma warning restore AL0801
#endif

    procedure CreateInternalMovementHeader(var InternalMovementHeader: Record "Internal Movement Header"; LocationCode: Code[10]; ToBinCode: Code[20])
    begin
        Clear(InternalMovementHeader);
        InternalMovementHeader.Validate("Location Code", LocationCode);
        InternalMovementHeader.Validate("To Bin Code", ToBinCode);
        InternalMovementHeader.Insert(true);
    end;

    procedure CreateInternalMovementLine(InternalMovementHeader: Record "Internal Movement Header"; var InternalMovementLine: Record "Internal Movement Line"; ItemNo: Code[20]; FromBinCode: Code[20]; ToBinCode: Code[20]; Qty: Decimal)
    var
        RecRef: RecordRef;
    begin
        Clear(InternalMovementLine);
        InternalMovementLine.Validate("No.", InternalMovementHeader."No.");
        RecRef.GetTable(InternalMovementLine);
        InternalMovementLine.Validate("Line No.", LibraryUtility.GetNewLineNo(RecRef, InternalMovementLine.FieldNo("Line No.")));
        InternalMovementLine.Validate("Item No.", ItemNo);
        InternalMovementLine.Validate("From Bin Code", FromBinCode);
        InternalMovementLine.Validate("To Bin Code", ToBinCode);
        InternalMovementLine.Validate(Quantity, Qty);
        InternalMovementLine.Insert(true);
    end;

    procedure CreateInTransitLocation(var Location: Record Location)
    begin
        CreateLocationWithInventoryPostingSetup(Location);
        Location.Validate("Use As In-Transit", true);
        Location.Modify(true);
    end;

    procedure CreateInventoryMovementHeader(var WarehouseActivityHeader: Record "Warehouse Activity Header"; LocationCode: Code[10])
    begin
        Clear(WarehouseActivityHeader);
        WarehouseActivityHeader.Validate("Location Code", LocationCode);
        WarehouseActivityHeader.Validate(Type, WarehouseActivityHeader.Type::"Invt. Movement");
        WarehouseActivityHeader.Insert(true);
    end;

    procedure CreateInvtMvmtFromInternalMvmt(var InternalMovementHeader: Record "Internal Movement Header")
    var
        CreateInvtPickMovement: Codeunit "Create Inventory Pick/Movement";
    begin
        CreateInvtPickMovement.CreateInvtMvntWithoutSource(InternalMovementHeader);
    end;

    procedure CreateInvtPutPickMovement(SourceDocument: Enum "Warehouse Request Source Document"; SourceNo: Code[20]; PutAway: Boolean; Pick: Boolean; Movement: Boolean)
    var
        WhseRequest: Record "Warehouse Request";
        CreateInvtPutAwayPickMvmt: Report "Create Invt Put-away/Pick/Mvmt";
    begin
        WhseRequest.Reset();
        WhseRequest.Init();
        WhseRequest.SetCurrentKey("Source Document", "Source No.");
        WhseRequest.SetRange("Source Document", SourceDocument);
        WhseRequest.SetRange("Source No.", SourceNo);
        CreateInvtPutAwayPickMvmt.SetTableView(WhseRequest);
        CreateInvtPutAwayPickMvmt.InitializeRequest(PutAway, Pick, Movement, false, false);
        CreateInvtPutAwayPickMvmt.UseRequestPage(false);
        CreateInvtPutAwayPickMvmt.RunModal();
    end;

    procedure CreateInvtPutPickPurchaseOrder(var PurchaseHeader: Record "Purchase Header")
    var
        WhseRequest: Record "Warehouse Request";
        CreateInvtPutPick: Report "Create Invt Put-away/Pick/Mvmt";
    begin
        PurchaseHeader.TestField(Status, PurchaseHeader.Status::Released);

        WhseRequest.Reset();
        WhseRequest.SetCurrentKey("Source Document", "Source No.");
        case PurchaseHeader."Document Type" of
            PurchaseHeader."Document Type"::Order:
                WhseRequest.SetRange("Source Document", WhseRequest."Source Document"::"Purchase Order");
            PurchaseHeader."Document Type"::"Return Order":
                WhseRequest.SetRange("Source Document", WhseRequest."Source Document"::"Purchase Return Order");
        end;
        WhseRequest.SetRange("Source No.", PurchaseHeader."No.");
        CreateInvtPutPick.SetTableView(WhseRequest);
        CreateInvtPutPick.InitializeRequest(true, true, false, false, false);
        CreateInvtPutPick.UseRequestPage(false);
        CreateInvtPutPick.RunModal();
    end;

    procedure CreateInvtPutPickSalesOrder(var SalesHeader: Record "Sales Header")
    var
        WhseRequest: Record "Warehouse Request";
        CreateInvtPutPick: Report "Create Invt Put-away/Pick/Mvmt";
    begin
        SalesHeader.TestField(Status, SalesHeader.Status::Released);

        WhseRequest.Reset();
        WhseRequest.SetCurrentKey("Source Document", "Source No.");
        case SalesHeader."Document Type" of
            SalesHeader."Document Type"::Order:
                WhseRequest.SetRange("Source Document", WhseRequest."Source Document"::"Sales Order");
            SalesHeader."Document Type"::"Return Order":
                WhseRequest.SetRange("Source Document", WhseRequest."Source Document"::"Sales Return Order");
        end;
        WhseRequest.SetRange("Source No.", SalesHeader."No.");
        CreateInvtPutPick.SetTableView(WhseRequest);
        CreateInvtPutPick.InitializeRequest(true, true, false, false, false);
        CreateInvtPutPick.UseRequestPage(false);
        CreateInvtPutPick.RunModal();
    end;

    procedure CreateInvtPutAwayPick(var WarehouseRequest: Record "Warehouse Request"; PutAway: Boolean; Pick: Boolean; Movement: Boolean)
    var
        TmpWarehouseRequest: Record "Warehouse Request";
        CreateInvtPutAwayPickMvmt: Report "Create Invt Put-away/Pick/Mvmt";
    begin
        Commit();
        CreateInvtPutAwayPickMvmt.InitializeRequest(PutAway, Pick, Movement, false, false);
        if WarehouseRequest.HasFilter then
            TmpWarehouseRequest.CopyFilters(WarehouseRequest)
        else begin
            WarehouseRequest.Get(WarehouseRequest.Type,
              WarehouseRequest."Location Code",
              WarehouseRequest."Source Type",
              WarehouseRequest."Source Subtype",
              WarehouseRequest."Source No.");
            TmpWarehouseRequest.SetRange(Type, WarehouseRequest.Type);
            TmpWarehouseRequest.SetRange("Location Code", WarehouseRequest."Location Code");
            TmpWarehouseRequest.SetRange("Source Type", WarehouseRequest."Source Type");
            TmpWarehouseRequest.SetRange("Source Subtype", WarehouseRequest."Source Subtype");
            TmpWarehouseRequest.SetRange("Source No.", WarehouseRequest."Source No.");
        end;
        CreateInvtPutAwayPickMvmt.SetTableView(TmpWarehouseRequest);
        CreateInvtPutAwayPickMvmt.UseRequestPage(false);
        CreateInvtPutAwayPickMvmt.RunModal();
    end;

    procedure CreateLocation(var Location: Record Location): Code[10]
    begin
        CreateLocationCodeAndName(Location);
        exit(Location.Code);
    end;

    procedure CreateLocationWMS(var Location: Record Location; BinMandatory: Boolean; RequirePutAway: Boolean; RequirePick: Boolean; RequireReceive: Boolean; RequireShipment: Boolean)
    begin
        CreateLocationWithInventoryPostingSetup(Location);
        if RequirePutAway then begin
            Location.Validate("Require Put-away", true);
            Location.Validate("Always Create Put-away Line", true);
        end;
        if RequirePick then
            Location.Validate("Require Pick", true);
        if RequireReceive then
            Location.Validate("Require Receive", true);
        if RequireShipment then
            Location.Validate("Require Shipment", true);
        Location."Bin Mandatory" := BinMandatory;

        if RequirePick then
            if RequireShipment then begin
                Location."Prod. Consump. Whse. Handling" := Location."Prod. Consump. Whse. Handling"::"Warehouse Pick (mandatory)";
                Location."Asm. Consump. Whse. Handling" := Location."Asm. Consump. Whse. Handling"::"Warehouse Pick (mandatory)";
                Location."Job Consump. Whse. Handling" := Location."Job Consump. Whse. Handling"::"Warehouse Pick (mandatory)";
            end else begin
                Location."Prod. Consump. Whse. Handling" := Location."Prod. Consump. Whse. Handling"::"Inventory Pick/Movement";
                Location."Asm. Consump. Whse. Handling" := Location."Asm. Consump. Whse. Handling"::"Inventory Movement";
                Location."Job Consump. Whse. Handling" := Location."Job Consump. Whse. Handling"::"Inventory Pick";
            end
        else begin
            Location."Prod. Consump. Whse. Handling" := Location."Prod. Consump. Whse. Handling"::"Warehouse Pick (optional)";
            Location."Asm. Consump. Whse. Handling" := Location."Asm. Consump. Whse. Handling"::"Warehouse Pick (optional)";
            Location."Job Consump. Whse. Handling" := Location."Job Consump. Whse. Handling"::"Warehouse Pick (optional)";
        end;

        if RequirePutAway and not RequireReceive then
            Location."Prod. Output Whse. Handling" := Location."Prod. Output Whse. Handling"::"Inventory Put-away";

        Location.Modify();

        OnAfterCreateLocationWMS(Location, BinMandatory, RequirePutAway, RequirePick, RequireReceive, RequireShipment);
    end;

    local procedure CreateLocationCodeAndName(var Location: Record Location): Code[10]
    begin
        Location.Init();
        Location.Validate(Code, LibraryUtility.GenerateRandomCode(Location.FieldNo(Code), DATABASE::Location));
        Location.Validate(Name, Location.Code);
        Location.Insert(true);
        OnAfterCreateLocationCodeAndName(Location);
        exit(Location.Code);
    end;

    procedure CreateLocationWithInventoryPostingSetup(var Location: Record Location): Code[10]
    begin
        CreateLocationCodeAndName(Location);
        LibraryInventory.UpdateInventoryPostingSetup(Location);
        exit(Location.Code);
    end;

    procedure CreateLocationWithAddress(var Location: Record Location): Code[10]
    begin
        CreateLocation(Location);
        Location.Validate("Name 2", LibraryUtility.GenerateRandomText(MaxStrLen(Location."Name 2")));
        Location.Validate(Address, LibraryUtility.GenerateRandomText(MaxStrLen(Location.Address)));
        Location.Validate("Address 2", LibraryUtility.GenerateRandomText(MaxStrLen(Location."Address 2")));
        Location.Modify(true);

        exit(Location.Code);
    end;

    procedure CreateMovementWorksheetLine(var WhseWorksheetLine: Record "Whse. Worksheet Line"; FromBin: Record Bin; ToBin: Record Bin; ItemNo: Code[20]; VariantCode: Code[10]; Quantity: Decimal)
    var
        WhseWorksheetTemplate: Record "Whse. Worksheet Template";
        WhseWorksheetName: Record "Whse. Worksheet Name";
    begin
        SelectWhseWorksheetTemplate(WhseWorksheetTemplate, "Warehouse Worksheet Template Type"::Movement);
        SelectWhseWorksheetName(WhseWorksheetName, WhseWorksheetTemplate.Name, FromBin."Location Code");
        CreateWhseWorksheetLine(
          WhseWorksheetLine, WhseWorksheetName."Worksheet Template Name", WhseWorksheetName.Name, WhseWorksheetName."Location Code",
          "Warehouse Worksheet Document Type"::" ");
        WhseWorksheetLine.Validate("Item No.", ItemNo);
        WhseWorksheetLine.Validate("Variant Code", VariantCode);
        WhseWorksheetLine.Validate("From Zone Code", FromBin."Zone Code");
        WhseWorksheetLine.Validate("From Bin Code", FromBin.Code);
        WhseWorksheetLine.Validate("To Zone Code", ToBin."Zone Code");
        WhseWorksheetLine.Validate("To Bin Code", ToBin.Code);
        WhseWorksheetLine.Validate(Quantity, Quantity);
        WhseWorksheetLine.Modify(true);
    end;

    procedure CreateNumberOfBins(LocationCode: Code[10]; ZoneCode: Code[10]; BinTypeCode: Code[10]; NoOfBins: Integer; IsCrossDock: Boolean)
    var
        Bin: Record Bin;
        i: Integer;
        ExistingBinCount: Integer;
    begin
        Clear(Bin);
        Bin.Init();
        Bin.SetRange("Location Code", LocationCode);
        ExistingBinCount := Bin.Count + 1;

        for i := 1 to NoOfBins do begin
            CreateBin(Bin, LocationCode, 'Bin' + Format(ExistingBinCount), ZoneCode, BinTypeCode);
            ExistingBinCount := ExistingBinCount + 1;
            if IsCrossDock then begin
                Bin.Validate("Cross-Dock Bin", true);
                Bin.Modify(true);
            end;
        end;
    end;

    procedure CreatePick(var WarehouseShipmentHeader: Record "Warehouse Shipment Header")
    var
        WarehouseShipmentLine: Record "Warehouse Shipment Line";
        WhseShptHeader: Record "Warehouse Shipment Header";
        WhseShptLine: Record "Warehouse Shipment Line";
        WhseShipmentRelease: Codeunit "Whse.-Shipment Release";
    begin
        WarehouseShipmentLine.SetRange("No.", WarehouseShipmentHeader."No.");
        WarehouseShipmentLine.FindFirst();
        WhseShptLine.Copy(WarehouseShipmentLine);
        WhseShptHeader.Get(WhseShptLine."No.");
        if WhseShptHeader.Status = WhseShptHeader.Status::Open then
            WhseShipmentRelease.Release(WhseShptHeader);
        WarehouseShipmentLine.SetHideValidationDialog(true);
        WarehouseShipmentLine.CreatePickDoc(WhseShptLine, WhseShptHeader);
    end;

    procedure CreatePickFromPickWorksheet(var WhseWorksheetLine: Record "Whse. Worksheet Line"; LineNo: Integer; WkshTemplateName: Code[10]; Name: Code[10]; LocationCode: Code[10]; AssignedID: Code[10]; MaxNoOfLines: Integer; MaxNoOfSourceDoc: Integer; SortPick: Enum "Whse. Activity Sorting Method"; PerShipTo: Boolean; PerItem: Boolean; PerZone: Boolean; PerBin: Boolean; PerWhseDoc: Boolean; PerDate: Boolean; PrintPick: Boolean)
    var
        WhseWorksheetLine2: Record "Whse. Worksheet Line";
        CreatePickReport: Report "Create Pick";
    begin
        WhseWorksheetLine2 := WhseWorksheetLine;
        WhseWorksheetLine2.SetRange("Worksheet Template Name", WkshTemplateName);
        WhseWorksheetLine2.SetRange(Name, Name);
        WhseWorksheetLine2.SetRange("Location Code", LocationCode);
        if LineNo <> 0 then
            WhseWorksheetLine2.SetRange("Line No.", LineNo);

        CreatePickReport.InitializeReport(
          AssignedID, MaxNoOfLines, MaxNoOfSourceDoc, SortPick, PerShipTo, PerItem,
          PerZone, PerBin, PerWhseDoc, PerDate, PrintPick, false, false);
        CreatePickReport.UseRequestPage(false);
        CreatePickReport.SetWkshPickLine(WhseWorksheetLine2);
        CreatePickReport.RunModal();
        Clear(CreatePickReport);

        WhseWorksheetLine := WhseWorksheetLine2;
    end;

    procedure CreatePutAwayTemplateHeader(var PutAwayTemplateHeader: Record "Put-away Template Header")
    begin
        Clear(PutAwayTemplateHeader);
        PutAwayTemplateHeader.Init();

        PutAwayTemplateHeader.Validate(Code,
          LibraryUtility.GenerateRandomCode(PutAwayTemplateHeader.FieldNo(Code), DATABASE::"Put-away Template Header"));
        PutAwayTemplateHeader.Validate(Description, PutAwayTemplateHeader.Code);
        PutAwayTemplateHeader.Insert(true);
    end;

    procedure CreatePutAwayTemplateLine(PutAwayTemplateHeader: Record "Put-away Template Header"; var PutAwayTemplateLine: Record "Put-away Template Line"; FindFixedBin: Boolean; FindFloatingBin: Boolean; FindSameItem: Boolean; FindUnitofMeasureMatch: Boolean; FindBinLessthanMinQty: Boolean; FindEmptyBin: Boolean)
    var
        RecRef: RecordRef;
    begin
        Clear(PutAwayTemplateLine);
        PutAwayTemplateLine.Init();

        PutAwayTemplateLine.Validate("Put-away Template Code", PutAwayTemplateHeader.Code);
        RecRef.GetTable(PutAwayTemplateLine);
        PutAwayTemplateLine.Validate("Line No.", LibraryUtility.GetNewLineNo(RecRef, PutAwayTemplateLine.FieldNo("Line No.")));
        PutAwayTemplateLine.Validate("Find Fixed Bin", FindFixedBin);
        PutAwayTemplateLine.Validate("Find Floating Bin", FindFloatingBin);
        PutAwayTemplateLine.Validate("Find Same Item", FindSameItem);
        PutAwayTemplateLine.Validate("Find Unit of Measure Match", FindUnitofMeasureMatch);
        PutAwayTemplateLine.Validate("Find Bin w. Less than Min. Qty", FindBinLessthanMinQty);
        PutAwayTemplateLine.Validate("Find Empty Bin", FindEmptyBin);
        PutAwayTemplateLine.Insert(true);
    end;

    procedure CreateStockkeepingUnit(var StockkeepingUnit: Record "Stockkeeping Unit"; Item: Record Item)
    var
        Location: Record Location;
        ItemVariant: Record "Item Variant";
    begin
        Clear(StockkeepingUnit);
        CreateLocationWithInventoryPostingSetup(Location);
        LibraryInventory.CreateItemVariant(ItemVariant, Item."No.");
        LibraryInventory.CreateStockkeepingUnitForLocationAndVariant(StockkeepingUnit, Location.Code, Item."No.", ItemVariant.Code);
        StockkeepingUnit."Unit Cost" := Item."Unit Cost";
        StockkeepingUnit."Standard Cost" := Item."Standard Cost";
        StockkeepingUnit.Modify();
    end;

    procedure CreateTransferHeader(var TransferHeader: Record "Transfer Header"; FromLocation: Text[10]; ToLocation: Text[10]; InTransitCode: Text[10])
    var
        Handled: Boolean;
    begin
        Clear(TransferHeader);
        TransferHeader.Init();
        TransferHeader.Insert(true);
        OnAfterCreateTransferHeaderInsertTransferHeader(TransferHeader, FromLocation, ToLocation, InTransitCode, Handled);
        if Handled then
            exit;

        TransferHeader.Validate("Transfer-from Code", FromLocation);
        TransferHeader.Validate("Transfer-to Code", ToLocation);
        TransferHeader.Validate("In-Transit Code", InTransitCode);
        TransferHeader.Modify(true);
        OnAfterCreateTransferHeader(TransferHeader, FromLocation, ToLocation, InTransitCode, Handled);
    end;

    procedure CreateTransferLine(var TransferHeader: Record "Transfer Header"; var TransferLine: Record "Transfer Line"; ItemNo: Text[20]; Quantity: Decimal)
    var
        RecRef: RecordRef;
    begin
        Clear(TransferLine);
        TransferLine.Init();
        TransferLine.Validate("Document No.", TransferHeader."No.");
        RecRef.GetTable(TransferLine);
        TransferLine.Validate("Line No.", LibraryUtility.GetNewLineNo(RecRef, TransferLine.FieldNo("Line No.")));
        TransferLine.Insert(true);
        TransferLine.Validate("Item No.", ItemNo);
        OnAfterValidateItemNo(TransferHeader, TransferLine, ItemNo, Quantity);

        TransferLine.Validate(Quantity, Quantity);
        TransferLine.Modify(true);
    end;

    procedure CreateTransferLocations(var FromLocation: Record Location; var ToLocation: Record Location; var InTransitLocation: Record Location)
    begin
        CreateLocationWithInventoryPostingSetup(FromLocation);
        CreateLocationWithInventoryPostingSetup(ToLocation);
        CreateInTransitLocation(InTransitLocation);
    end;

    procedure CreateTransferRoute(var TransferRoute: Record "Transfer Route"; TransferFrom: Code[10]; TransferTo: Code[10])
    begin
        Clear(TransferRoute);
        TransferRoute.Init();
        TransferRoute.Validate("Transfer-from Code", TransferFrom);
        TransferRoute.Validate("Transfer-to Code", TransferTo);
        TransferRoute.Insert(true);
    end;

    procedure CreateAndUpdateTransferRoute(var TransferRoute: Record "Transfer Route"; TransferFrom: Code[10]; TransferTo: Code[10]; InTransitCode: Code[10]; ShippingAgentCode: Code[10]; ShippingAgentServiceCode: Code[10])
    begin
        CreateTransferRoute(TransferRoute, TransferFrom, TransferTo);
        TransferRoute.Validate("In-Transit Code", InTransitCode);
        TransferRoute.Validate("Shipping Agent Code", ShippingAgentCode);
        TransferRoute.Validate("Shipping Agent Service Code", ShippingAgentServiceCode);
        TransferRoute.Modify(true);
    end;

    procedure CreateZone(var Zone: Record Zone; ZoneCode: Code[10]; LocationCode: Code[10]; BinTypeCode: Code[10]; WhseClassCode: Code[10]; SpecialEquip: Code[10]; ZoneRank: Integer; IsCrossDockZone: Boolean)
    begin
        Clear(Zone);
        Zone.Init();

        if ZoneCode = '' then
            Zone.Validate(Code, LibraryUtility.GenerateRandomCode(Zone.FieldNo(Code), DATABASE::Zone))
        else
            Zone.Validate(Code, ZoneCode);

        Zone.Validate("Location Code", LocationCode);
        Zone.Validate(Description, Zone.Code);
        Zone.Validate("Bin Type Code", BinTypeCode);
        Zone.Validate("Warehouse Class Code", WhseClassCode);
        Zone.Validate("Special Equipment Code", SpecialEquip);
        Zone.Validate("Zone Ranking", ZoneRank);
        Zone.Validate("Cross-Dock Bin Zone", IsCrossDockZone);

        Zone.Insert(true);
    end;

    procedure CreateWarehouseEmployee(var WarehouseEmployee: Record "Warehouse Employee"; LocationCode: Code[10]; IsDefault: Boolean)
    begin
        Clear(WarehouseEmployee);
        if UserId = '' then
            exit; // for native database
        if WarehouseEmployee.Get(UserId, LocationCode) then
            exit;

        if IsDefault then begin
            WarehouseEmployee.SetRange("User ID", UserId);
            WarehouseEmployee.SetRange(Default, true);
            if WarehouseEmployee.FindFirst() then
                exit;
        end;

        WarehouseEmployee.Reset();
        WarehouseEmployee.Init();
        WarehouseEmployee.Validate("User ID", UserId);
        WarehouseEmployee.Validate("Location Code", LocationCode);
        WarehouseEmployee.Validate(Default, IsDefault);
        WarehouseEmployee.Insert(true);
    end;

    procedure CreateWarehouseClass(var WarehouseClass: Record "Warehouse Class")
    begin
        Clear(WarehouseClass);
        WarehouseClass.Init();
        WarehouseClass.Validate(Code, LibraryUtility.GenerateRandomCode(WarehouseClass.FieldNo(Code), DATABASE::"Warehouse Class"));
        WarehouseClass.Insert(true);
    end;

    procedure CreateWarehouseReceiptHeader(var WarehouseReceiptHeader: Record "Warehouse Receipt Header")
    begin
        WarehouseReceiptHeader.Init();
        WarehouseReceiptHeader.Insert(true);
    end;

    procedure CreateWarehouseShipmentHeader(var WarehouseShipmentHeader: Record "Warehouse Shipment Header")
    begin
        WarehouseShipmentHeader.Init();
        WarehouseShipmentHeader.Insert(true);
    end;

    procedure CreateWarehouseShipmentLine(var WhseShptLine: Record "Warehouse Shipment Line"; WhseShptHeader: Record "Warehouse Shipment Header")
    var
        RecRef: RecordRef;
    begin
        Clear(WhseShptLine);
        WhseShptLine."No." := WhseShptHeader."No.";
        RecRef.GetTable(WhseShptLine);
        WhseShptLine."Line No." := LibraryUtility.GetNewLineNo(RecRef, WhseShptLine.FieldNo("Line No."));
        WhseShptLine.Insert(true);
    end;

    procedure CreateWarehouseSourceFilter(var WarehouseSourceFilter: Record "Warehouse Source Filter"; Type: Option)
    begin
        // Create Warehouse source filter to get Source Document.
        WarehouseSourceFilter.Init();
        WarehouseSourceFilter.Validate(Type, Type);
        WarehouseSourceFilter.Validate(
          Code, LibraryUtility.GenerateRandomCode(WarehouseSourceFilter.FieldNo(Code), DATABASE::"Warehouse Source Filter"));
        WarehouseSourceFilter.Insert(true);
    end;

    procedure CreateWhseInternalPickHeader(var WhseInternalPickHeader: Record "Whse. Internal Pick Header"; LocationCode: Code[10])
    begin
        Clear(WhseInternalPickHeader);
        WhseInternalPickHeader.Validate("Location Code", LocationCode);
        WhseInternalPickHeader.Insert(true);
    end;

    procedure CreateWhseInternalPickLine(WhseInternalPickHeader: Record "Whse. Internal Pick Header"; var WhseInternalPickLine: Record "Whse. Internal Pick Line"; ItemNo: Code[20]; Qty: Decimal)
    var
        RecRef: RecordRef;
    begin
        Clear(WhseInternalPickLine);
        WhseInternalPickLine.Validate("No.", WhseInternalPickHeader."No.");
        RecRef.GetTable(WhseInternalPickLine);
        WhseInternalPickLine.Validate("Line No.", LibraryUtility.GetNewLineNo(RecRef, WhseInternalPickLine.FieldNo("Line No.")));
        WhseInternalPickLine.Validate("Item No.", ItemNo);
        WhseInternalPickLine.Validate(Quantity, Qty);
        WhseInternalPickLine.Insert(true);
    end;

    procedure CreateWhseInternalPutawayHdr(var WhseInternalPutAwayHeader: Record "Whse. Internal Put-away Header"; LocationCode: Code[10])
    begin
        Clear(WhseInternalPutAwayHeader);
        WhseInternalPutAwayHeader.Validate("Location Code", LocationCode);
        WhseInternalPutAwayHeader.Insert(true);
    end;

    procedure CreateWhseInternalPutawayLine(WhseInternalPutAwayHeader: Record "Whse. Internal Put-away Header"; var WhseInternalPutAwayLine: Record "Whse. Internal Put-away Line"; ItemNo: Code[20]; Qty: Decimal)
    var
        RecRef: RecordRef;
    begin
        Clear(WhseInternalPutAwayLine);
        WhseInternalPutAwayLine.Validate("No.", WhseInternalPutAwayHeader."No.");
        RecRef.GetTable(WhseInternalPutAwayLine);
        WhseInternalPutAwayLine.Validate("Line No.", LibraryUtility.GetNewLineNo(RecRef, WhseInternalPutAwayLine.FieldNo("Line No.")));
        WhseInternalPutAwayLine.Validate("Item No.", ItemNo);
        WhseInternalPutAwayLine.Validate(Quantity, Qty);
        WhseInternalPutAwayLine.Insert(true);
    end;

    procedure CreateWhseJournalTemplate(var WarehouseJournalTemplate: Record "Warehouse Journal Template"; WarehouseJournalTemplateType: Enum "Warehouse Journal Template Type")
    begin
        WarehouseJournalTemplate.Init();
        WarehouseJournalTemplate.Validate(Name, LibraryUtility.GenerateGUID());
        WarehouseJournalTemplate.Validate(Type, WarehouseJournalTemplateType);
        WarehouseJournalTemplate.Insert(true);
    end;

    procedure CreateWarehouseJournalBatch(var WarehouseJournalBatch: Record "Warehouse Journal Batch"; WarehouseJournalTemplateType: Enum "Warehouse Journal Template Type"; LocationCode: Code[10])
    var
        WarehouseJournalTemplate: Record "Warehouse Journal Template";
    begin
        SelectWhseJournalTemplateName(WarehouseJournalTemplate, WarehouseJournalTemplateType);
        WarehouseJournalTemplate."Increment Batch Name" := true; // for compatibility with batch name auto increment
        WarehouseJournalTemplate.Modify();
        CreateWhseJournalBatch(WarehouseJournalBatch, WarehouseJournalTemplate.Name, LocationCode);
    end;

    procedure CreateWhseJournalBatch(var WarehouseJournalBatch: Record "Warehouse Journal Batch"; WarehouseJournalTemplateName: Code[10]; LocationCode: Code[10])
    begin
        // Create Item Journal Batch with a random Name of String length less than 10.
        WarehouseJournalBatch.Init();
        WarehouseJournalBatch.Validate("Journal Template Name", WarehouseJournalTemplateName);
        WarehouseJournalBatch.Validate(
          Name, CopyStr(LibraryUtility.GenerateRandomCode(WarehouseJournalBatch.FieldNo(Name), DATABASE::"Warehouse Journal Batch"), 1,
            MaxStrLen(WarehouseJournalBatch.Name)));
        WarehouseJournalBatch.Validate("Location Code", LocationCode);
        WarehouseJournalBatch.Insert(true);
    end;

    procedure CreateWhseJournalLine(var WarehouseJournalLine: Record "Warehouse Journal Line"; JournalTemplateName: Code[10]; JournalBatchName: Code[10]; LocationCode: Code[10]; ZoneCode: Code[10]; BinCode: Code[20]; EntryType: Option; ItemNo: Text[20]; NewQuantity: Decimal)
    var
        NoSeries: Record "No. Series";
        WarehouseJournalBatch: Record "Warehouse Journal Batch";
        NoSeriesCodeunit: Codeunit "No. Series";
        RecRef: RecordRef;
        DocumentNo: Code[20];
        JnlSelected: Boolean;
    begin
        if not WarehouseJournalBatch.Get(JournalTemplateName, JournalBatchName, LocationCode) then begin
            WarehouseJournalBatch.Init();
            WarehouseJournalBatch.Validate("Journal Template Name", JournalTemplateName);
            WarehouseJournalBatch.SetupNewBatch();
            WarehouseJournalBatch.Validate(Name, JournalBatchName);
            WarehouseJournalBatch.Validate(Description, JournalBatchName + ' journal');
            WarehouseJournalBatch.Validate("Location Code", LocationCode);
            WarehouseJournalBatch.Insert(true);
        end;

        Clear(WarehouseJournalLine);
        WarehouseJournalLine.Init();
        WarehouseJournalLine.Validate("Journal Template Name", JournalTemplateName);
        WarehouseJournalLine.Validate("Journal Batch Name", JournalBatchName);
        WarehouseJournalLine.Validate("Location Code", LocationCode);
        WarehouseJournalLine.Validate("Zone Code", ZoneCode);
        WarehouseJournalLine.Validate("Bin Code", BinCode);

        JnlSelected :=
            WarehouseJournalLine.TemplateSelection(
                PAGE::"Whse. Item Journal", "Warehouse Journal Template Type"::Item, WarehouseJournalLine);
        Assert.IsTrue(JnlSelected, 'Journal was not selected');
        WarehouseJournalLine.OpenJnl(JournalBatchName, LocationCode, WarehouseJournalLine);
        Commit();
        WarehouseJournalLine.SetUpNewLine(WarehouseJournalLine);

        RecRef.GetTable(WarehouseJournalLine);
        WarehouseJournalLine.Validate("Line No.", LibraryUtility.GetNewLineNo(RecRef, WarehouseJournalLine.FieldNo("Line No.")));
        WarehouseJournalLine.Insert(true);
        WarehouseJournalLine.Validate("Registering Date", WorkDate());
        WarehouseJournalLine.Validate("Entry Type", EntryType);
        if NoSeries.Get(WarehouseJournalBatch."No. Series") then
            DocumentNo := NoSeriesCodeunit.PeekNextNo(WarehouseJournalBatch."No. Series", WarehouseJournalLine."Registering Date")
        else
            DocumentNo := 'Default Document No.';
        WarehouseJournalLine.Validate("Whse. Document No.", DocumentNo);
        WarehouseJournalLine.Validate("Item No.", ItemNo);
        WarehouseJournalLine.Validate(Quantity, NewQuantity);
        WarehouseJournalLine.Modify(true);
    end;

    procedure CreateWhseMovement(BatchName: Text[30]; LocationCode: Text[30]; SortActivity: Enum "Whse. Activity Sorting Method"; BreakBulkFilter: Boolean; DoNotFillQtyToHandle: Boolean)
    var
        WhseWorksheetLine: Record "Whse. Worksheet Line";
        WarehouseActivityHeader: Record "Warehouse Activity Header";
        WhseWorksheetTemplate: Record "Whse. Worksheet Template";
        WhseSrcCreateDocument: Report "Whse.-Source - Create Document";
    begin
        WhseWorksheetLine.SetFilter(Quantity, '>0');
        WhseWorksheetTemplate.SetRange(Type, WhseWorksheetTemplate.Type::Movement);
        WhseWorksheetTemplate.FindFirst();
        WhseWorksheetLine.SetRange("Worksheet Template Name", WhseWorksheetTemplate.Name);
        WhseWorksheetLine.SetRange(Name, BatchName);
        WhseWorksheetLine.SetRange("Location Code", LocationCode);
        WhseWorksheetLine.FindFirst();

        WhseSrcCreateDocument.SetWhseWkshLine(WhseWorksheetLine);
        WhseSrcCreateDocument.Initialize(CopyStr(UserId(), 1, 50), SortActivity, false, DoNotFillQtyToHandle, BreakBulkFilter);
        WhseSrcCreateDocument.UseRequestPage(false);
        WhseSrcCreateDocument.RunModal();
        WhseSrcCreateDocument.GetResultMessage(WarehouseActivityHeader.Type::Movement.AsInteger());
    end;

    procedure CreateWhsePick(var WarehouseShipmentHeader: Record "Warehouse Shipment Header")
    var
        WarehouseShipmentLineRec: Record "Warehouse Shipment Line";
        WhseShptHeader: Record "Warehouse Shipment Header";
        WhseShptLine: Record "Warehouse Shipment Line";
        WhseShipmentRelease: Codeunit "Whse.-Shipment Release";
    begin
        WarehouseShipmentLineRec.SetRange("No.", WarehouseShipmentHeader."No.");
        WarehouseShipmentLineRec.FindFirst();
        WhseShptLine.Copy(WarehouseShipmentLineRec);
        WhseShptHeader.Get(WhseShptLine."No.");
        if WhseShptHeader.Status = WhseShptHeader.Status::Open then
            WhseShipmentRelease.Release(WhseShptHeader);
        WarehouseShipmentLineRec.SetHideValidationDialog(true);
        WarehouseShipmentLineRec.CreatePickDoc(WhseShptLine, WhseShptHeader);
    end;

#if not CLEAN27
#pragma warning disable AL0801
    [Obsolete('Moved to codeunit LibraryManufacturing', '27.0')]
    procedure CreateWhsePickFromProduction(ProductionOrder: Record "Production Order")
    var
        LibraryManufacturing: Codeunit "Library - Manufacturing";
    begin
        LibraryManufacturing.CreateWhsePickFromProduction(ProductionOrder);
    end;
#pragma warning restore AL0801
#endif

    procedure CreateWhseReceiptFromPO(var PurchaseHeader: Record "Purchase Header")
    var
        GetSourceDocInbound: Codeunit "Get Source Doc. Inbound";
    begin
        GetSourceDocInbound.CreateFromPurchOrderHideDialog(PurchaseHeader);
        OnAfterCreateWhseReceiptFromPO(PurchaseHeader);
    end;

    procedure CreateWhseReceiptFromSalesReturnOrder(var SalesHeader: Record "Sales Header")
    var
        GetSourceDocInbound: Codeunit "Get Source Doc. Inbound";
    begin
        GetSourceDocInbound.CreateFromSalesReturnOrderHideDialog(SalesHeader);
    end;

    procedure CreateWhseShipmentFromPurchaseReturnOrder(var PurchaseHeader: Record "Purchase Header")
    var
        GetSourceDocOutbound: Codeunit "Get Source Doc. Outbound";
    begin
        GetSourceDocOutbound.CreateFromPurchReturnOrderHideDialog(PurchaseHeader);
    end;

    procedure CreateWhseShipmentFromServiceOrder(ServiceHeader: Record "Service Header")
    var
        ServGetSourceDocOutbound: Codeunit "Serv. Get Source Doc. Outbound";
    begin
        ServGetSourceDocOutbound.CreateFromServiceOrderHideDialog(ServiceHeader);
    end;

    procedure CreateWhseShipmentFromSO(var SalesHeader: Record "Sales Header")
    var
        GetSourceDocOutbound: Codeunit "Get Source Doc. Outbound";
    begin
        GetSourceDocOutbound.CreateFromSalesOrderHideDialog(SalesHeader);
    end;

    procedure CreateWhseReceiptFromTO(var TransferHeader: Record "Transfer Header")
    var
        GetSourceDocInbound: Codeunit "Get Source Doc. Inbound";
    begin
        GetSourceDocInbound.CreateFromInbndTransferOrderHideDialog(TransferHeader);
    end;

    procedure CreateWhseShipmentFromTO(var TransferHeader: Record "Transfer Header")
    var
        GetSourceDocOutbound: Codeunit "Get Source Doc. Outbound";
    begin
        GetSourceDocOutbound.CreateFromOutbndTransferOrderHideDialog(TransferHeader);
    end;

    procedure CreateWhseWorksheetName(var WhseWorksheetName: Record "Whse. Worksheet Name"; WhseWorkSheetTemplateName: Code[10]; LocationCode: Code[10])
    begin
        // Create Item Journal Batch with a random Name of String length less than 10.
        WhseWorksheetName.Init();
        WhseWorksheetName.Validate("Worksheet Template Name", WhseWorkSheetTemplateName);
        WhseWorksheetName.Validate(
          Name, CopyStr(LibraryUtility.GenerateRandomCode(WhseWorksheetName.FieldNo(Name), DATABASE::"Whse. Worksheet Name"), 1,
            MaxStrLen(WhseWorksheetName.Name)));
        WhseWorksheetName.Validate("Location Code", LocationCode);
        WhseWorksheetName.Insert(true);
    end;

    procedure CreateWhseWorksheetLine(var WhseWorksheetLine: Record "Whse. Worksheet Line"; WorksheetTemplateName: Code[10]; Name: Code[10]; LocationCode: Code[10]; WhseDocumentType: Enum "Warehouse Worksheet Document Type")
    var
        RecRef: RecordRef;
    begin
        Clear(WhseWorksheetLine);
        WhseWorksheetLine.Init();
        WhseWorksheetLine.Validate("Worksheet Template Name", WorksheetTemplateName);
        WhseWorksheetLine.Validate(Name, Name);
        WhseWorksheetLine.Validate("Location Code", LocationCode);
        RecRef.GetTable(WhseWorksheetLine);
        WhseWorksheetLine.Validate("Line No.", LibraryUtility.GetNewLineNo(RecRef, WhseWorksheetLine.FieldNo("Line No.")));
        WhseWorksheetLine.Insert(true);
        WhseWorksheetLine.Validate("Whse. Document Type", WhseDocumentType);
        WhseWorksheetLine.Modify(true);
    end;

    procedure DeleteEmptyWhseRegisters()
    var
        DeleteEmptyWhseRegistersReport: Report "Delete Empty Whse. Registers";
    begin
        Commit();  // Commit required for batch job report.
        Clear(DeleteEmptyWhseRegistersReport);
        DeleteEmptyWhseRegistersReport.UseRequestPage(false);
        DeleteEmptyWhseRegistersReport.Run();
    end;

    procedure FindBin(var Bin: Record Bin; LocationCode: Code[10]; ZoneCode: Code[10]; BinIndex: Integer)
    begin
        Bin.Init();
        Bin.Reset();
        Bin.SetCurrentKey("Location Code", "Zone Code", Code);
        Bin.SetRange("Location Code", LocationCode);
        Bin.SetRange("Zone Code", ZoneCode);
        Bin.FindSet(true);

        if BinIndex > 1 then
            Bin.Next(BinIndex - 1);
    end;

    procedure FindWhseReceiptNoBySourceDoc(SourceType: Option; SourceSubtype: Option; SourceNo: Code[20]): Code[20]
    var
        WhseRcptLine: Record "Warehouse Receipt Line";
    begin
        WhseRcptLine.SetRange("Source Type", SourceType);
        WhseRcptLine.SetRange("Source Subtype", SourceSubtype);
        WhseRcptLine.SetRange("Source No.", SourceNo);
        if WhseRcptLine.FindFirst() then
            exit(WhseRcptLine."No.");

        exit('');
    end;

    procedure FindWhseActivityNoBySourceDoc(SourceType: Option; SourceSubtype: Option; SourceNo: Code[20]): Code[20]
    var
        WhseActivityLine: Record "Warehouse Activity Line";
    begin
        WhseActivityLine.SetRange("Source Type", SourceType);
        WhseActivityLine.SetRange("Source Subtype", SourceSubtype);
        WhseActivityLine.SetRange("Source No.", SourceNo);
        if WhseActivityLine.FindFirst() then
            exit(WhseActivityLine."No.");

        exit('');
    end;

    procedure FindWhseShipmentNoBySourceDoc(SourceType: Option; SourceSubtype: Option; SourceNo: Code[20]): Code[20]
    var
        WhseShptLine: Record "Warehouse Shipment Line";
    begin
        WhseShptLine.SetRange("Source Type", SourceType);
        WhseShptLine.SetRange("Source Subtype", SourceSubtype);
        WhseShptLine.SetRange("Source No.", SourceNo);
        if WhseShptLine.FindFirst() then
            exit(WhseShptLine."No.");

        exit('');
    end;

    procedure FindWhseActivityBySourceDoc(var WarehouseActivityHeader: Record "Warehouse Activity Header"; SourceType: Option; SourceSubtype: Option; SourceNo: Code[20]; SourceLineNo: Integer): Boolean
    var
        WarehouseActivityLine: Record "Warehouse Activity Line";
    begin
        if not FindWhseActivityLineBySourceDoc(WarehouseActivityLine, SourceType, SourceSubtype, SourceNo, SourceLineNo) then
            exit(false);

        WarehouseActivityHeader.Get(WarehouseActivityLine."Activity Type", WarehouseActivityLine."No.");
        exit(true);
    end;

    procedure FindWhseActivityLineBySourceDoc(var WarehouseActivityLine: Record "Warehouse Activity Line"; SourceType: Option; SourceSubtype: Option; SourceNo: Code[20]; SourceLineNo: Integer): Boolean
    begin
        WarehouseActivityLine.SetRange("Source Type", SourceType);
        WarehouseActivityLine.SetRange("Source Subtype", SourceSubtype);
        WarehouseActivityLine.SetRange("Source No.", SourceNo);
        WarehouseActivityLine.SetRange("Source Line No.", SourceLineNo);
        exit(WarehouseActivityLine.FindFirst())
    end;

    procedure FindZone(var Zone: Record Zone; LocationCode: Code[10]; BinTypeCode: Code[10]; CrossDockBinZone: Boolean)
    begin
        Zone.SetRange("Location Code", LocationCode);
        Zone.SetRange("Bin Type Code", BinTypeCode);
        Zone.SetRange("Cross-Dock Bin Zone", CrossDockBinZone);
        Zone.FindFirst();
    end;

    procedure GetBinContentInternalMovement(InternalMovementHeader: Record "Internal Movement Header"; LocationCodeFilter: Text[30]; ItemFilter: Text[30]; BinCodeFilter: Text[100])
    var
        BinContent: Record "Bin Content";
        WhseGetBinContentReport: Report "Whse. Get Bin Content";
    begin
        BinContent.Init();
        BinContent.Reset();
        if LocationCodeFilter <> '' then
            BinContent.SetRange("Location Code", LocationCodeFilter);
        if ItemFilter <> '' then
            BinContent.SetFilter("Item No.", ItemFilter);
        if BinCodeFilter <> '' then
            BinContent.SetFilter("Bin Code", BinCodeFilter);
        WhseGetBinContentReport.SetTableView(BinContent);
        WhseGetBinContentReport.InitializeInternalMovement(InternalMovementHeader);
        WhseGetBinContentReport.UseRequestPage(false);
        WhseGetBinContentReport.RunModal();
    end;

    procedure GetBinContentTransferOrder(var TransferHeader: Record "Transfer Header"; LocationCodeFilter: Text[30]; ItemFilter: Text[30]; BinCodeFilter: Text[100])
    var
        BinContent: Record "Bin Content";
        WhseGetBinContentReport: Report "Whse. Get Bin Content";
    begin
        BinContent.Init();
        BinContent.Reset();
        if LocationCodeFilter <> '' then
            BinContent.SetRange("Location Code", LocationCodeFilter);
        if ItemFilter <> '' then
            BinContent.SetFilter("Item No.", ItemFilter);
        if BinCodeFilter <> '' then
            BinContent.SetFilter("Bin Code", BinCodeFilter);
        WhseGetBinContentReport.SetTableView(BinContent);
        WhseGetBinContentReport.InitializeTransferHeader(TransferHeader);
        WhseGetBinContentReport.UseRequestPage(false);
        WhseGetBinContentReport.Run();
    end;

    procedure GetInboundSourceDocuments(var WhsePutAwayRqst: Record "Whse. Put-away Request"; WhseWorksheetName: Record "Whse. Worksheet Name"; LocationCode: Code[10])
    var
        GetInboundSourceDocumentsReport: Report "Get Inbound Source Documents";
    begin
        Clear(GetInboundSourceDocumentsReport);
        GetInboundSourceDocumentsReport.SetWhseWkshName(WhseWorksheetName."Worksheet Template Name", WhseWorksheetName.Name, LocationCode);
        GetInboundSourceDocumentsReport.UseRequestPage(false);
        GetInboundSourceDocumentsReport.SetTableView(WhsePutAwayRqst);
        GetInboundSourceDocumentsReport.Run();
    end;

    procedure GetOutboundSourceDocuments(var WhsePickRequest: Record "Whse. Pick Request"; WhseWorksheetName: Record "Whse. Worksheet Name"; LocationCode: Code[10])
    var
        GetOutboundSourceDocumentsReport: Report "Get Outbound Source Documents";
    begin
        Clear(GetOutboundSourceDocumentsReport);
        GetOutboundSourceDocumentsReport.SetPickWkshName(WhseWorksheetName."Worksheet Template Name", WhseWorksheetName.Name, LocationCode);
        GetOutboundSourceDocumentsReport.UseRequestPage(false);
        GetOutboundSourceDocumentsReport.SetTableView(WhsePickRequest);
        GetOutboundSourceDocumentsReport.Run();
    end;

    procedure GetSourceDocumentsShipment(var WarehouseShipmentHeader: Record "Warehouse Shipment Header"; var WarehouseSourceFilter: Record "Warehouse Source Filter"; LocationCode: Code[10])
    var
        GetSourceDocuments: Report "Get Source Documents";
    begin
        // Get Shipment Lines for the required Order in matching criteria.
        GetSourceDocuments.SetOneCreatedShptHeader(WarehouseShipmentHeader);
        WarehouseSourceFilter.SetFilters(GetSourceDocuments, LocationCode);
        GetSourceDocuments.SetSkipBlockedItem(true);
        GetSourceDocuments.UseRequestPage(false);
        GetSourceDocuments.RunModal();
    end;

    procedure GetSourceDocumentsReceipt(var WarehouseReceiptHeader: Record "Warehouse Receipt Header"; var WarehouseSourceFilter: Record "Warehouse Source Filter"; LocationCode: Code[10])
    var
        GetSourceDocuments: Report "Get Source Documents";
    begin
        // Get Receipt Lines for the required Order in matching criteria.
        GetSourceDocuments.SetOneCreatedReceiptHeader(WarehouseReceiptHeader);
        WarehouseSourceFilter.SetFilters(GetSourceDocuments, LocationCode);
        GetSourceDocuments.SetSkipBlockedItem(true);
        GetSourceDocuments.UseRequestPage(false);
        GetSourceDocuments.RunModal();
    end;

    procedure GetSourceDocInventoryMovement(var WarehouseActivityHeader: Record "Warehouse Activity Header")
    var
        CreateInvtPickMovement: Codeunit "Create Inventory Pick/Movement";
    begin
        Clear(CreateInvtPickMovement);
        CreateInvtPickMovement.SetInvtMovement(true);
        CreateInvtPickMovement.Run(WarehouseActivityHeader);
    end;

    procedure GetSourceDocInventoryPick(WarehouseActivityHeader: Record "Warehouse Activity Header")
    var
        CreateInventoryPickMovement: Codeunit "Create Inventory Pick/Movement";
    begin
        Assert.AreEqual(WarehouseActivityHeader.Type::"Invt. Pick", WarehouseActivityHeader.Type, 'Only processes Inventory Pick');
        Clear(CreateInventoryPickMovement);
        CreateInventoryPickMovement.Run(WarehouseActivityHeader);
    end;

    procedure GetSourceDocInventoryPutAway(WarehouseActivityHeader: Record "Warehouse Activity Header")
    var
        CreateInventoryPickMovement: Codeunit "Create Inventory Pick/Movement";
    begin
        Assert.AreEqual(WarehouseActivityHeader.Type::"Invt. Put-away", WarehouseActivityHeader.Type, 'Only processes Inventory Put-away');
        Clear(CreateInventoryPickMovement);
        CreateInventoryPickMovement.Run(WarehouseActivityHeader);
    end;

    procedure GetWhseDocsPickWorksheet(var WhseWkshLine: Record "Whse. Worksheet Line"; WhsePickRequest: Record "Whse. Pick Request"; Name: Code[10]): Integer
    var
        WhsePickRqst2: Record "Whse. Pick Request";
        WhseWkshTemplate: Record "Whse. Worksheet Template";
        WhseWkshName: Record "Whse. Worksheet Name";
        GetOutboundSourceDocumentsReport: Report "Get Outbound Source Documents";
    begin
        WhsePickRequest.TestField("Location Code");
        WhsePickRequest.TestField("Completely Picked", false);

        WhseWkshTemplate.SetRange(Type, WhseWkshTemplate.Type::Pick);
        WhseWkshTemplate.FindFirst(); // expected to be present as Distribution demo data has been called.
        if not WhseWkshName.Get(WhseWkshTemplate.Name, Name, WhsePickRequest."Location Code") then begin
            WhseWkshName.Init();
            WhseWkshName.Validate("Worksheet Template Name", WhseWkshTemplate.Name);
            WhseWkshName.Validate(Name, Name);
            WhseWkshName.Validate("Location Code", WhsePickRequest."Location Code");
            WhseWkshName.Insert(true);
        end;

        WhsePickRqst2 := WhsePickRequest;
        GetOutboundSourceDocumentsReport.SetPickWkshName(WhseWkshTemplate.Name, WhseWkshName.Name, WhsePickRequest."Location Code");
        WhsePickRqst2.MarkedOnly(true);
        if not WhsePickRqst2.FindFirst() then begin
            WhsePickRqst2.MarkedOnly(false);
            WhsePickRqst2.SetRecFilter();
        end;

        GetOutboundSourceDocumentsReport.UseRequestPage(false);
        GetOutboundSourceDocumentsReport.SetTableView(WhsePickRqst2);
        GetOutboundSourceDocumentsReport.RunModal();

        Clear(WhseWkshLine);
        WhseWkshLine.SetRange("Worksheet Template Name", WhseWkshTemplate.Name);
        WhseWkshLine.SetRange(Name, WhseWkshName.Name);
        WhseWkshLine.SetRange("Location Code", WhsePickRequest."Location Code");
        WhseWkshLine.SetRange("Whse. Document No.", WhsePickRequest."Document No.");
        exit(WhseWkshLine.Count);
    end;

    procedure GetZoneForBin(LocationCode: Code[10]; BinCode: Code[20]): Code[10]
    var
        Bin: Record Bin;
    begin
        if Bin.Get(LocationCode, BinCode) then
            exit(Bin."Zone Code");

        exit('');
    end;

    procedure NoSeriesSetup(var WarehouseSetup: Record "Warehouse Setup")
    begin
        WarehouseSetup.Get();
        WarehouseSetup.Validate("Posted Whse. Receipt Nos.", LibraryUtility.GetGlobalNoSeriesCode());
        WarehouseSetup.Validate("Posted Whse. Shipment Nos.", LibraryUtility.GetGlobalNoSeriesCode());
        WarehouseSetup.Validate("Registered Whse. Movement Nos.", LibraryUtility.GetGlobalNoSeriesCode());
        WarehouseSetup.Validate("Registered Whse. Pick Nos.", LibraryUtility.GetGlobalNoSeriesCode());
        WarehouseSetup.Validate("Registered Whse. Put-away Nos.", LibraryUtility.GetGlobalNoSeriesCode());
        WarehouseSetup.Validate("Whse. Movement Nos.", LibraryUtility.GetGlobalNoSeriesCode());
        WarehouseSetup.Validate("Whse. Pick Nos.", LibraryUtility.GetGlobalNoSeriesCode());
        WarehouseSetup.Validate("Whse. Put-away Nos.", LibraryUtility.GetGlobalNoSeriesCode());
        WarehouseSetup.Validate("Whse. Receipt Nos.", LibraryUtility.GetGlobalNoSeriesCode());
        WarehouseSetup.Validate("Whse. Ship Nos.", LibraryUtility.GetGlobalNoSeriesCode());
        WarehouseSetup.Validate("Whse. Internal Pick Nos.", LibraryUtility.GetGlobalNoSeriesCode());
        WarehouseSetup.Validate("Whse. Internal Put-away Nos.", LibraryUtility.GetGlobalNoSeriesCode());
        WarehouseSetup.Modify(true);
    end;

    procedure PostInventoryActivity(var WarehouseActivityHeader: Record "Warehouse Activity Header"; Invoice: Boolean)
    begin
        PostAndPrintInventoryActivity(WarehouseActivityHeader, Invoice, false);
    end;

    procedure PostAndPrintInventoryActivity(var WarehouseActivityHeader: Record "Warehouse Activity Header"; Invoice: Boolean; Print: Boolean)
    var
        WarehouseActivityLine: Record "Warehouse Activity Line";
        WhseActivityPost: Codeunit "Whse.-Activity-Post";
    begin
        WarehouseActivityLine.SetRange("Activity Type", WarehouseActivityHeader.Type);
        WarehouseActivityLine.SetRange("No.", WarehouseActivityHeader."No.");
        WarehouseActivityLine.FindFirst();

        WhseActivityPost.SetInvoiceSourceDoc(Invoice);
        WhseActivityPost.PrintDocument(Print);
        WhseActivityPost.Run(WarehouseActivityLine);
        Clear(WhseActivityPost);
    end;

    procedure PostTransferOrder(var TransferHeader: Record "Transfer Header"; Ship: Boolean; Receive: Boolean)
    var
        TransferOrderPostShipment: Codeunit "TransferOrder-Post Shipment";
        TransferOrderPostReceipt: Codeunit "TransferOrder-Post Receipt";
    begin
        Clear(TransferOrderPostShipment);
        if Ship then
            TransferOrderPostShipment.Run(TransferHeader);
        if Receive then begin
            TransferOrderPostReceipt.SetHideValidationDialog(true);
            TransferOrderPostReceipt.Run(TransferHeader);
        end;
    end;

    procedure PostWhseAdjustment(var Item: Record Item)
    var
        ItemJournalTemplate: Record "Item Journal Template";
        ItemJournalBatch: Record "Item Journal Batch";
    begin
        LibraryAssembly.SetupItemJournal(ItemJournalTemplate, ItemJournalBatch);
        CalculateWhseAdjustment(Item, ItemJournalBatch);
        LibraryInventory.PostItemJournalLine(ItemJournalBatch."Journal Template Name", ItemJournalBatch.Name);
    end;

    procedure PostWhseJournalLine(JournalTemplateName: Text[30]; JournalBatchName: Text[30]; Location: Text[30])
    var
        WarehouseJournalLine: Record "Warehouse Journal Line";
        WhseJnlRegisterBatch: Codeunit "Whse. Jnl.-Register Batch";
    begin
        Clear(WhseJnlRegisterBatch);
        WarehouseJournalLine.SetRange("Journal Template Name", JournalTemplateName);
        WarehouseJournalLine.SetRange("Journal Batch Name", JournalBatchName);
        WarehouseJournalLine.SetRange("Location Code", Location);
        if WarehouseJournalLine.FindFirst() then
            WhseJnlRegisterBatch.Run(WarehouseJournalLine);
    end;

    procedure PostWhseReceipt(var WarehouseReceiptHeader: Record "Warehouse Receipt Header")
    var
        WarehouseReceiptLine: Record "Warehouse Receipt Line";
        WhsePostReceipt: Codeunit "Whse.-Post Receipt";
    begin
        WarehouseReceiptLine.SetRange("No.", WarehouseReceiptHeader."No.");
        if WarehouseReceiptLine.FindFirst() then
            WhsePostReceipt.Run(WarehouseReceiptLine);
    end;

    procedure PostWhseRcptWithConfirmMsg(No: Code[20])
    var
        WarehouseReceiptLine: Record "Warehouse Receipt Line";
        WhsePostReceiptYesNo: Codeunit "Whse.-Post Receipt (Yes/No)";
    begin
        Clear(WhsePostReceiptYesNo);
        WarehouseReceiptLine.SetRange("No.", No);
        if WarehouseReceiptLine.FindFirst() then
            WhsePostReceiptYesNo.Run(WarehouseReceiptLine);
    end;

    procedure PostWhseShipment(WarehouseShipmentHeader: Record "Warehouse Shipment Header"; Invoice: Boolean)
    var
        WarehouseShipmentLine: Record "Warehouse Shipment Line";
        WhsePostShipment: Codeunit "Whse.-Post Shipment";
    begin
        WhsePostShipment.SetPostingSettings(Invoice);
        WarehouseShipmentLine.SetRange("No.", WarehouseShipmentHeader."No.");
        if WarehouseShipmentLine.FindFirst() then
            WhsePostShipment.Run(WarehouseShipmentLine);
    end;

    procedure PostWhseShptWithShipInvoiceMsg(No: Code[20])
    var
        WarehouseShipmentLine: Record "Warehouse Shipment Line";
        WhsePostShipmentYesNo: Codeunit "Whse.-Post Shipment (Yes/No)";
    begin
        Clear(WhsePostShipmentYesNo);
        WarehouseShipmentLine.SetRange("No.", No);
        if WarehouseShipmentLine.FindFirst() then
            WhsePostShipmentYesNo.Run(WarehouseShipmentLine);
    end;

    procedure RegisterWhseActivity(var WarehouseActivityHeader: Record "Warehouse Activity Header")
    var
        WarehouseActivityLine: Record "Warehouse Activity Line";
        WhseActivityRegister: Codeunit "Whse.-Activity-Register";
        WMSMgt: Codeunit "WMS Management";
    begin
        WarehouseActivityLine.SetRange("Activity Type", WarehouseActivityHeader.Type);
        WarehouseActivityLine.SetRange("No.", WarehouseActivityHeader."No.");
        WarehouseActivityLine.FindFirst();
        WMSMgt.CheckBalanceQtyToHandle(WarehouseActivityLine);
        WhseActivityRegister.Run(WarehouseActivityLine);
    end;

    procedure RegisterWhseJournalLine(JournalTemplateName: Text[10]; JournalBatchName: Text[10]; LocationCode: Code[10]; UseBatchJob: Boolean)
    var
        WarehouseJournalLine: Record "Warehouse Journal Line";
    begin
        WarehouseJournalLine.Init();
        WarehouseJournalLine.Validate("Journal Template Name", JournalTemplateName);
        WarehouseJournalLine.Validate("Journal Batch Name", JournalBatchName);
        WarehouseJournalLine.Validate("Location Code", LocationCode);
        // Batch job doesn't show confirmation dialog about registering journal lines and message dialog that they have been registered.
        if UseBatchJob then
            CODEUNIT.Run(CODEUNIT::"Whse. Jnl.-Register Batch", WarehouseJournalLine)
        else
            CODEUNIT.Run(CODEUNIT::"Whse. Jnl.-Register", WarehouseJournalLine);
    end;

    procedure ReleaseTransferOrder(var TransferHeader: Record "Transfer Header")
    var
        ReleaseTransferDocument: Codeunit "Release Transfer Document";
    begin
        Clear(ReleaseTransferDocument);
        ReleaseTransferDocument.Run(TransferHeader);
    end;

    procedure ReleaseWarehouseShipment(var WarehouseShipmentHeader: Record "Warehouse Shipment Header")
    var
        WhseShipmentRelease: Codeunit "Whse.-Shipment Release";
    begin
        WhseShipmentRelease.Release(WarehouseShipmentHeader);
    end;

    procedure ReleaseWarehouseInternalPick(var WhseInternalPickHeader: Record "Whse. Internal Pick Header")
    var
        WhseInternalPickRelease: Codeunit "Whse. Internal Pick Release";
    begin
        WhseInternalPickRelease.Release(WhseInternalPickHeader);
    end;

    procedure ReleaseWarehouseInternalPutAway(var WhseInternalPutAwayHeader: Record "Whse. Internal Put-away Header")
    var
        WhseIntPutAwayRelease: Codeunit "Whse. Int. Put-away Release";
    begin
        WhseIntPutAwayRelease.Release(WhseInternalPutAwayHeader);
    end;

    procedure ReopenTransferOrder(var TransferHeader: Record "Transfer Header")
    var
        ReleaseTransferDocument: Codeunit "Release Transfer Document";
    begin
        ReleaseTransferDocument.Reopen(TransferHeader);
    end;

    procedure ReopenWhseShipment(var WhseShipmentHeader: Record "Warehouse Shipment Header")
    var
        WhseShipmentRelease: Codeunit "Whse.-Shipment Release";
    begin
        WhseShipmentRelease.Reopen(WhseShipmentHeader);
    end;

    procedure RunDateCompressWhseEntries(ItemNo: Code[20])
    var
        WarehouseEntry: Record "Warehouse Entry";
        DateCompressWhseEntries: Report "Date Compress Whse. Entries";
    begin
        Commit();  // Commit required for batch job report.
        Clear(DateCompressWhseEntries);
        WarehouseEntry.SetRange("Item No.", ItemNo);
        DateCompressWhseEntries.SetTableView(WarehouseEntry);
        DateCompressWhseEntries.Run();
    end;

    procedure SelectBinType(Receive: Boolean; Ship: Boolean; PutAway: Boolean; Pick: Boolean): Code[10]
    var
        BinType: Record "Bin Type";
    begin
        Clear(BinType);
        BinType.Init();

        BinType.SetRange(Receive, Receive);
        BinType.SetRange(Ship, Ship);
        BinType.SetRange("Put Away", PutAway);
        BinType.SetRange(Pick, Pick);
        if not BinType.FindFirst() then
            CreateBinType(BinType, Receive, Ship, PutAway, Pick);

        exit(BinType.Code);
    end;

    procedure SelectWhseJournalTemplateName(var WarehouseJournalTemplate: Record "Warehouse Journal Template"; WarehouseJournalTemplateType: Enum "Warehouse Journal Template Type")
    begin
        // Find Item Journal Template for the given Template Type.
        WarehouseJournalTemplate.SetRange(Type, WarehouseJournalTemplateType);
        if not WarehouseJournalTemplate.FindFirst() then
            CreateWhseJournalTemplate(WarehouseJournalTemplate, WarehouseJournalTemplateType);
    end;

    procedure SelectWhseJournalBatchName(var WarehouseJournalBatch: Record "Warehouse Journal Batch"; WhseJournalBatchTemplateType: Enum "Warehouse Journal Template Type"; WarehouseJournalTemplateName: Code[10]; LocationCode: Code[10])
    begin
        // Find Name for Batch Name.
        WarehouseJournalBatch.SetRange("Template Type", WhseJournalBatchTemplateType);
        WarehouseJournalBatch.SetRange("Journal Template Name", WarehouseJournalTemplateName);
        WarehouseJournalBatch.SetRange("Location Code", LocationCode);

        // If Warehouse Journal Batch not found then create it.
        if not WarehouseJournalBatch.FindFirst() then
            CreateWhseJournalBatch(WarehouseJournalBatch, WarehouseJournalTemplateName, LocationCode);
    end;

    procedure SelectWhseWorksheetTemplate(var WhseWorksheetTemplate: Record "Whse. Worksheet Template"; TemplateType: Enum "Warehouse Worksheet Template Type")
    begin
        // Find Item Journal Template for the given Template Type.
        WhseWorksheetTemplate.SetRange(Type, TemplateType);
        WhseWorksheetTemplate.FindFirst();
    end;

    procedure SelectWhseWorksheetName(var WhseWorksheetName: Record "Whse. Worksheet Name"; WhseWorkSheetTemplateName: Code[10]; LocationCode: Code[10])
    begin
        // Find Name for Warehouse Worksheet Name.
        WhseWorksheetName.SetRange("Worksheet Template Name", WhseWorkSheetTemplateName);
        WhseWorksheetName.SetRange("Location Code", LocationCode);

        // If Warehouse Worksheet Name not found then create it.
        if not WhseWorksheetName.FindFirst() then
            CreateWhseWorksheetName(WhseWorksheetName, WhseWorkSheetTemplateName, LocationCode);
    end;

    procedure SetQtyToHandleInternalMovement(InternalMovementHeader: Record "Internal Movement Header"; Qty: Decimal)
    var
        InternalMovementLine: Record "Internal Movement Line";
    begin
        Clear(InternalMovementLine);
        InternalMovementLine.SetRange("No.", InternalMovementHeader."No.");
        InternalMovementLine.FindSet();
        repeat
            InternalMovementLine.Validate(Quantity, Qty);
            InternalMovementLine.Modify(true);
        until InternalMovementLine.Next() = 0;
    end;

    procedure SetQtyHandleInventoryMovement(WarehouseActivityHeader: Record "Warehouse Activity Header"; Qty: Decimal)
    begin
        SetQtyToHandleWhseActivity(WarehouseActivityHeader, Qty);
    end;

    procedure SetQtyToHandleWhseActivity(WhseActivityHdr: Record "Warehouse Activity Header"; Qty: Decimal)
    var
        WhseActivityLine: Record "Warehouse Activity Line";
    begin
        Clear(WhseActivityLine);
        WhseActivityLine.SetRange("Activity Type", WhseActivityHdr.Type);
        WhseActivityLine.SetRange("No.", WhseActivityHdr."No.");
        WhseActivityLine.FindSet();
        repeat
            WhseActivityLine.Validate(Quantity, Qty);
            WhseActivityLine.Modify(true);
        until WhseActivityLine.Next() = 0;
    end;

    procedure SetRequireShipmentOnWarehouseSetup(RequireShipment: Boolean)
    var
        WarehouseSetup: Record "Warehouse Setup";
    begin
        WarehouseSetup.Get();
        WarehouseSetup.Validate("Require Shipment", RequireShipment);
        WarehouseSetup.Modify(true);
    end;

    procedure SetRequireReceiveOnWarehouseSetup(RequireReceive: Boolean)
    var
        WarehouseSetup: Record "Warehouse Setup";
    begin
        WarehouseSetup.Get();
        WarehouseSetup.Validate("Require Receive", RequireReceive);
        WarehouseSetup.Modify(true);
    end;

    procedure UpdateInventoryOnLocationWithDirectedPutAwayAndPick(ItemNo: Code[20]; LocationCode: Code[10]; Quantity: Decimal; WithItemTracking: Boolean)
    var
        Zone: Record Zone;
        Bin: Record Bin;
    begin
        FindZone(Zone, LocationCode, SelectBinType(false, false, true, true), false);
        FindBin(Bin, LocationCode, Zone.Code, 1);
        UpdateInventoryInBinUsingWhseJournal(Bin, ItemNo, Quantity, WithItemTracking);
    end;

    procedure UpdateInventoryInBinUsingWhseJournal(Bin: Record Bin; ItemNo: Code[20]; Quantity: Decimal; WithItemTracking: Boolean)
    var
        Item: Record Item;
    begin
        UpdateWarehouseStockOnBin(Bin, ItemNo, Quantity, WithItemTracking);

        Item.Get(ItemNo);
        PostWhseAdjustment(Item);
    end;

    procedure UpdateWarehouseStockOnBin(Bin: Record Bin; ItemNo: Code[20]; Quantity: Decimal; WithItemTracking: Boolean)
    var
        WarehouseJournalTemplate: Record "Warehouse Journal Template";
        WarehouseJournalBatch: Record "Warehouse Journal Batch";
        WarehouseJournalLine: Record "Warehouse Journal Line";
    begin
        SelectWhseJournalTemplateName(WarehouseJournalTemplate, WarehouseJournalTemplate.Type::Item);
        WarehouseJournalTemplate.Validate("No. Series", LibraryUtility.GetGlobalNoSeriesCode());
        WarehouseJournalTemplate.Modify(true);
        SelectWhseJournalBatchName(
          WarehouseJournalBatch, WarehouseJournalTemplate.Type, WarehouseJournalTemplate.Name, Bin."Location Code");
        WarehouseJournalBatch.Validate("No. Series", LibraryUtility.GetGlobalNoSeriesCode());
        WarehouseJournalBatch.Modify(true);

        CreateWhseJournalLine(
          WarehouseJournalLine, WarehouseJournalBatch."Journal Template Name", WarehouseJournalBatch.Name,
          Bin."Location Code", Bin."Zone Code", Bin.Code,
          WarehouseJournalLine."Entry Type"::"Positive Adjmt.", ItemNo, Quantity);
        if WithItemTracking then
            WarehouseJournalLine.OpenItemTrackingLines();

        RegisterWhseJournalLine(
          WarehouseJournalBatch."Journal Template Name", WarehouseJournalBatch.Name, Bin."Location Code", true);
    end;

    procedure WhseCalculateInventory(WarehouseJournalLine: Record "Warehouse Journal Line"; var BinContent: Record "Bin Content"; NewRegisteringDate: Date; WhseDocNo: Code[20]; ItemsNotOnInvt: Boolean)
    var
        WhseCalculateInventoryReport: Report "Whse. Calculate Inventory";
    begin
        Commit();  // Commit is required to run the report.
        WhseCalculateInventoryReport.SetWhseJnlLine(WarehouseJournalLine);
        WhseCalculateInventoryReport.InitializeRequest(NewRegisteringDate, WhseDocNo, ItemsNotOnInvt);
        WhseCalculateInventoryReport.SetTableView(BinContent);
        WhseCalculateInventoryReport.UseRequestPage(false);
        WhseCalculateInventoryReport.Run();
    end;

    procedure WhseSourceCreateDocument(var WhseWorksheetLine: Record "Whse. Worksheet Line"; SortActivity: Enum "Whse. Activity Sorting Method"; PrintDoc: Boolean;
                                                                                                               DoNotFillQtytoHandle: Boolean;
                                                                                                               BreakbulkFilter: Boolean)
    var
        WhseSourceCreateDocumentReport: Report "Whse.-Source - Create Document";
    begin
        WhseSourceCreateDocumentReport.Initialize(CopyStr(UserId(), 1, 50), SortActivity, PrintDoc, DoNotFillQtytoHandle, BreakbulkFilter);
        WhseSourceCreateDocumentReport.UseRequestPage(false);
        WhseSourceCreateDocumentReport.SetWhseWkshLine(WhseWorksheetLine);
        WhseSourceCreateDocumentReport.Run();
    end;

    procedure WhseGetBinContent(var BinContent: Record "Bin Content"; WhseWorksheetLine: Record "Whse. Worksheet Line"; WhseInternalPutAwayHeader: Record "Whse. Internal Put-away Header"; DestinationType: Enum "Warehouse Destination Type 2")
    var
        WhseGetBinContentReport: Report "Whse. Get Bin Content";
    begin
        WhseGetBinContentReport.SetParameters(WhseWorksheetLine, WhseInternalPutAwayHeader, DestinationType);
        WhseGetBinContentReport.SetTableView(BinContent);
        WhseGetBinContentReport.UseRequestPage(false);
        WhseGetBinContentReport.Run();
    end;

    procedure WhseGetBinContentFromItemJournalLine(var BinContent: Record "Bin Content"; ItemJournalLine: Record "Item Journal Line")
    var
        WhseGetBinContentReport: Report "Whse. Get Bin Content";
    begin
        Clear(WhseGetBinContentReport);
        WhseGetBinContentReport.SetTableView(BinContent);
        WhseGetBinContentReport.InitializeItemJournalLine(ItemJournalLine);
        WhseGetBinContentReport.UseRequestPage(false);
        WhseGetBinContentReport.Run();
    end;

    procedure WarehouseJournalSetup(LocationCode: Code[10]; var WarehouseJournalTemplate: Record "Warehouse Journal Template"; var WarehouseJournalBatch: Record "Warehouse Journal Batch")
    begin
        Clear(WarehouseJournalTemplate);
        WarehouseJournalTemplate.Init();
        SelectWhseJournalTemplateName(WarehouseJournalTemplate, WarehouseJournalTemplate.Type::Item);
        WarehouseJournalTemplate.Validate("No. Series", LibraryUtility.GetGlobalNoSeriesCode());
        WarehouseJournalTemplate.Modify(true);

        Clear(WarehouseJournalBatch);
        WarehouseJournalBatch.Init();
        SelectWhseJournalBatchName(
          WarehouseJournalBatch, WarehouseJournalTemplate.Type, WarehouseJournalTemplate.Name, LocationCode);
        WarehouseJournalBatch.Validate("No. Series", LibraryUtility.GetGlobalNoSeriesCode());
        WarehouseJournalBatch.Modify(true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateBin(var Bin: Record Bin; LocationCode: Code[10]; BinCode: Code[20]; ZoneCode: Code[10]; BinTypeCode: Code[10])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateFullWMSLocation(var Location: Record Location; BinsPerZone: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateLocationCodeAndName(var Location: Record Location)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateLocationWMS(var Location: Record Location; BinMandatory: Boolean; RequirePutAway: Boolean; RequirePick: Boolean; RequireReceive: Boolean; RequireShipment: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateTransferHeaderInsertTransferHeader(var TransferHeader: Record "Transfer Header"; FromLocation: Text[10]; ToLocation: Text[10]; InTransitCode: Text[10]; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateTransferHeader(var TransferHeader: Record "Transfer Header"; FromLocation: Text[10]; ToLocation: Text[10]; InTransitCode: Text[10]; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterValidateItemNo(var TransferHeader: Record "Transfer Header"; var TransferLine: Record "Transfer Line"; ItemNo: Text[20]; Quantity: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateWhseReceiptFromPO(var PurchaseHeader: Record "Purchase Header")
    begin
    end;
}

