/// <summary>
/// Provides utility functions for creating and managing item tracking (serial numbers, lot numbers) in test scenarios.
/// </summary>
codeunit 130502 "Library - Item Tracking"
{

    Permissions = TableData "Whse. Item Tracking Line" = rimd;

    trigger OnRun()
    begin
    end;

    var
        Assert: Codeunit Assert;
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryUtility: Codeunit "Library - Utility";
        Text001: Label 'Not implemented. Source Type = %1.';
        Text002: Label 'Qty Base for Serial No. %1 is %2.';
        Text031: Label 'You cannot define item tracking on this line because it is linked to production order %1.';
        Text048: Label 'You cannot use item tracking on a %1 created from a %2.';
        LedgerEntryFoundErr: Label '%1  is not found, filters: %2.';
        LedgerEntryQtyErr: Label 'Incorrect quantity for %1, filters: %2.';

    procedure AddSerialNoTrackingInfo(var Item: Record Item)
    var
        ItemTrackingCode: Record "Item Tracking Code";
    begin
        CreateItemTrackingCode(ItemTrackingCode, true, false);
        Item.Validate("Item Tracking Code", ItemTrackingCode.Code);
        Item.Validate("Serial Nos.", LibraryUtility.GetGlobalNoSeriesCode());
        Item.Modify(true);
    end;

    procedure AddLotNoTrackingInfo(var Item: Record Item)
    var
        ItemTrackingCode: Record "Item Tracking Code";
    begin
        CreateItemTrackingCode(ItemTrackingCode, false, true);
        Item.Validate("Item Tracking Code", ItemTrackingCode.Code);
        Item.Validate("Lot Nos.", LibraryUtility.GetGlobalNoSeriesCode());
        Item.Modify(true);
    end;

    procedure CheckLastItemLedgerEntry(var ItemLedgerEntry: Record "Item Ledger Entry"; ItemNo: Code[20]; LocationCode: Code[10]; SerialNo: Code[50]; LotNo: Code[50]; PackageNo: Code[50]; Qty: Decimal): Boolean
    var
        ItemTrackingSetup: Record "Item Tracking Setup";
    begin
        ItemTrackingSetup."Serial No." := SerialNo;
        ItemTrackingSetup."Lot No." := LotNo;
        ItemTrackingSetup."Package No." := PackageNo;
        CheckLastItemLedgerEntry(ItemLedgerEntry, ItemNo, LocationCode, ItemTrackingSetup, Qty);
    end;

    procedure CheckLastItemLedgerEntry(var ItemLedgerEntry: Record "Item Ledger Entry"; ItemNo: Code[20]; LocationCode: Code[10]; ItemTrackingSetup: Record "Item Tracking Setup"; Qty: Decimal): Boolean
    begin
        ItemLedgerEntry.SetCurrentKey("Item No.", Open, "Variant Code", "Location Code", "Item Tracking", "Lot No.", "Serial No.", "Package No.");
        ItemLedgerEntry.SetRange("Item No.", ItemNo);
        ItemLedgerEntry.SetRange("Location Code", LocationCode);
        ItemLedgerEntry.SetTrackingFilterFromItemTrackingSetup(ItemTrackingSetup);
        Assert.IsTrue(
            ItemLedgerEntry.FindLast(),
            StrSubstNo(LedgerEntryFoundErr, ItemLedgerEntry.TableCaption(), ItemLedgerEntry.GetFilters));
        Assert.AreEqual(
            Qty, ItemLedgerEntry.Quantity, StrSubstNo(LedgerEntryQtyErr, ItemLedgerEntry.GetFilters()));
        ItemLedgerEntry.Reset();
    end;

    procedure CheckReservationEntry(SourceType: Integer; SourceSubtype: Integer; SourceID: Code[20]; SourceRefNo: Integer; ItemNo: Code[20]; LocationCode: Code[10]; ItemTrackingSetup: Record "Item Tracking Setup"; Qty: Decimal; ResStatus: Enum "Reservation Status"): Boolean
    var
        ReservationEntry: Record "Reservation Entry";
    begin
        ReservationEntry.SetCurrentKey("Item No.", "Source Type", "Source Subtype");
        ReservationEntry.SetSourceFilter(SourceType, SourceSubtype, SourceID, SourceRefNo, false);
        ReservationEntry.SetRange("Reservation Status", ResStatus);

        ReservationEntry.SetRange("Item No.", ItemNo);
        ReservationEntry.SetRange("Location Code", LocationCode);
        ReservationEntry.SetTrackingFilterFromItemTrackingSetup(ItemTrackingSetup);
        Assert.IsTrue(
            ReservationEntry.FindLast(),
            StrSubstNo(LedgerEntryFoundErr, ReservationEntry.TableCaption(), ReservationEntry.GetFilters()));
        Assert.AreEqual(
            Qty, ReservationEntry.Quantity, StrSubstNo(LedgerEntryQtyErr, ReservationEntry.GetFilters()));
    end;

    procedure CheckSalesReservationEntry(SalesLine: Record "Sales Line"; SerialNo: Code[50]; LotNo: Code[50]; PackageNo: Code[50]; Qty: Decimal; ResStatus: Enum "Reservation Status"): Boolean
    var
        ItemTrackingSetup: Record "Item Tracking Setup";
    begin
        ItemTrackingSetup."Serial No." := SerialNo;
        ItemTrackingSetup."Lot No." := LotNo;
        ItemTrackingSetup."Package No." := PackageNo;
        CheckReservationEntry(
          DATABASE::"Sales Line", SalesLine."Document Type".AsInteger(), SalesLine."Document No.", SalesLine."Line No.",
          SalesLine."No.", SalesLine."Location Code", ItemTrackingSetup, Qty, ResStatus);
    end;

    procedure CheckPurchReservationEntry(PurchLine: Record "Purchase Line"; SerialNo: Code[50]; LotNo: Code[50]; PackageNo: Code[50]; Qty: Decimal; ResStatus: Enum "Reservation Status"): Boolean
    var
        ItemTrackingSetup: Record "Item Tracking Setup";
    begin
        ItemTrackingSetup."Serial No." := SerialNo;
        ItemTrackingSetup."Lot No." := LotNo;
        ItemTrackingSetup."Package No." := PackageNo;
        CheckReservationEntry(
          DATABASE::"Purchase Line", PurchLine."Document Type".AsInteger(), PurchLine."Document No.", PurchLine."Line No.",
          PurchLine."No.", PurchLine."Location Code", ItemTrackingSetup, Qty, ResStatus);
    end;

    procedure CheckInvtDocReservationEntry(InvtDocLine: Record "Invt. Document Line"; SerialNo: Code[50]; LotNo: Code[50]; PackageNo: Code[50]; Qty: Decimal; ResStatus: Enum "Reservation Status"): Boolean
    var
        ItemTrackingSetup: Record "Item Tracking Setup";
    begin
        ItemTrackingSetup."Serial No." := SerialNo;
        ItemTrackingSetup."Lot No." := LotNo;
        ItemTrackingSetup."Package No." := PackageNo;
        CheckReservationEntry(
          DATABASE::"Invt. Document Line", InvtDocLine."Document Type".AsInteger(), InvtDocLine."Document No.", InvtDocLine."Line No.",
          InvtDocLine."Item No.", InvtDocLine."Location Code", ItemTrackingSetup, Qty, ResStatus);
    end;

    procedure CreateAssemblyHeaderItemTracking(var ReservEntry: Record "Reservation Entry"; AssemblyHeader: Record "Assembly Header"; SerialNo: Code[50]; LotNo: Code[50]; QtyBase: Decimal)
    var
        ItemTrackingSetup: Record "Item Tracking Setup";
    begin
        ItemTrackingSetup."Serial No." := SerialNo;
        ItemTrackingSetup."Lot No." := LotNo;
        CreateAssemblyHeaderItemTracking(ReservEntry, AssemblyHeader, ItemTrackingSetup, QtyBase);
    end;

    procedure CreateAssemblyHeaderItemTracking(var ReservEntry: Record "Reservation Entry"; AssemblyHeader: Record "Assembly Header"; ItemTrackingSetup: Record "Item Tracking Setup"; QtyBase: Decimal)
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(AssemblyHeader);
        ItemTracking(ReservEntry, RecRef, ItemTrackingSetup, QtyBase);
    end;

    procedure CreateAssemblyLineItemTracking(var ReservEntry: Record "Reservation Entry"; AssemblyLine: Record "Assembly Line"; SerialNo: Code[50]; LotNo: Code[50]; QtyBase: Decimal)
    var
        ItemTrackingSetup: Record "Item Tracking Setup";
    begin
        ItemTrackingSetup."Serial No." := SerialNo;
        ItemTrackingSetup."Lot No." := LotNo;
        CreateAssemblyLineItemTracking(ReservEntry, AssemblyLine, ItemTrackingSetup, QtyBase);
    end;

    procedure CreateAssemblyLineItemTracking(var ReservEntry: Record "Reservation Entry"; AssemblyLine: Record "Assembly Line"; ItemTrackingSetup: Record "Item Tracking Setup"; QtyBase: Decimal)
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(AssemblyLine);
        ItemTracking(ReservEntry, RecRef, ItemTrackingSetup, QtyBase);
    end;

    procedure CreateItemJournalLineItemTracking(var ReservEntry: Record "Reservation Entry"; ItemJournalLine: Record "Item Journal Line"; SerialNo: Code[50]; LotNo: Code[50]; QtyBase: Decimal)
    var
        ItemTrackingSetup: Record "Item Tracking Setup";
    begin
        ItemTrackingSetup."Serial No." := SerialNo;
        ItemTrackingSetup."Lot No." := LotNo;
        CreateItemJournalLineItemTracking(ReservEntry, ItemJournalLine, ItemTrackingSetup, QtyBase);
    end;

    procedure CreateItemJournalLineItemTracking(var ReservEntry: Record "Reservation Entry"; ItemJournalLine: Record "Item Journal Line"; SerialNo: Code[50]; LotNo: Code[50]; PackageNo: Code[50]; QtyBase: Decimal)
    var
        ItemTrackingSetup: Record "Item Tracking Setup";
    begin
        ItemTrackingSetup."Serial No." := SerialNo;
        ItemTrackingSetup."Lot No." := LotNo;
        ItemTrackingSetup."Package No." := PackageNo;
        CreateItemJournalLineItemTracking(ReservEntry, ItemJournalLine, ItemTrackingSetup, QtyBase);
    end;

    procedure CreateItemJournalLineItemTracking(var ReservEntry: Record "Reservation Entry"; ItemJournalLine: Record "Item Journal Line"; ItemTrackingSetup: Record "Item Tracking Setup"; QtyBase: Decimal)
    var
        RecRef: RecordRef;
    begin
        if ItemJournalLine."Entry Type" = ItemJournalLine."Entry Type"::Transfer then // cannot create this type from UI
            Error(Text001, RecRef.Number);
        RecRef.GetTable(ItemJournalLine);
        ItemTracking(ReservEntry, RecRef, ItemTrackingSetup, QtyBase);
    end;

    procedure CreateItemTrackingLines(var ItemJournalLine: Record "Item Journal Line"; var ItemTrackingLines: Page Microsoft.Inventory.Tracking."Item Tracking Lines")
    var
        TrackingSpecification: Record "Tracking Specification";
        ItemJnlLineReserve: Codeunit "Item Jnl. Line-Reserve";
    begin
        ItemJnlLineReserve.InitFromItemJnlLine(TrackingSpecification, ItemJournalLine);
        ItemTrackingLines.SetSourceSpec(TrackingSpecification, ItemJournalLine."Posting Date");
        ItemTrackingLines.SetInbound(ItemJournalLine.IsInbound());
        ItemTrackingLines.RunModal();
    end;

    procedure CreateItemTrackingCodeWithExpirationDate(var ItemTrackingCode: Record "Item Tracking Code"; SNSpecific: Boolean; LNSpecific: Boolean)
    begin
        CreateItemTrackingCode(ItemTrackingCode, SNSpecific, LNSpecific);
        ItemTrackingCode.Validate("Use Expiration Dates", true);
        ItemTrackingCode.Modify();
    end;

    procedure CreateItemTrackingCode(var ItemTrackingCode: Record "Item Tracking Code"; SNSpecific: Boolean; LNSpecific: Boolean)
    var
        ItemTrackingSetup: Record "Item Tracking Setup";
    begin
        ItemTrackingSetup."Serial No. Required" := SNSpecific;
        ItemTrackingSetup."Lot No. Required" := LNSpecific;
        CreateItemTrackingCode(ItemTrackingCode, ItemTrackingSetup);
    end;

    procedure CreateItemTrackingCode(var ItemTrackingCode: Record "Item Tracking Code"; SNSpecific: Boolean; LNSpecific: Boolean; PNSpecific: Boolean)
    var
        ItemTrackingSetup: Record "Item Tracking Setup";
    begin
        ItemTrackingSetup."Serial No. Required" := SNSpecific;
        ItemTrackingSetup."Lot No. Required" := LNSpecific;
        ItemTrackingSetup."Package No. Required" := PNSpecific;
        CreateItemTrackingCode(ItemTrackingCode, ItemTrackingSetup);
    end;

    procedure CreateItemTrackingCode(var ItemTrackingCode: Record "Item Tracking Code"; ItemTrackingSetup: Record "Item Tracking Setup")
    begin
        Clear(ItemTrackingCode);
        ItemTrackingCode.Validate(Code,
          LibraryUtility.GenerateRandomCode(ItemTrackingCode.FieldNo(Code), DATABASE::"Item Tracking Code"));
        ItemTrackingCode.Validate("SN Specific Tracking", ItemTrackingSetup."Serial No. Required");
        ItemTrackingCode.Validate("Lot Specific Tracking", ItemTrackingSetup."Lot No. Required");
        ItemTrackingCode.Validate("Package Specific Tracking", ItemTrackingSetup."Package No. Required");
        ItemTrackingCode.Insert(true);
    end;

    procedure CreateItemReceiptItemTracking(var ReservEntry: Record "Reservation Entry"; InvtDocumentLine: Record "Invt. Document Line"; SerialNo: Code[50]; LotNo: Code[50]; QtyBase: Decimal)
    var
        ItemTrackingSetup: Record "Item Tracking Setup";
    begin
        ItemTrackingSetup."Serial No." := SerialNo;
        ItemTrackingSetup."Lot No." := LotNo;
        CreateItemReceiptItemTracking(ReservEntry, InvtDocumentLine, ItemTrackingSetup, QtyBase);
    end;

    procedure CreateItemReceiptItemTracking(var ReservEntry: Record "Reservation Entry"; InvtDocumentLine: Record "Invt. Document Line"; SerialNo: Code[50]; LotNo: Code[50]; PackageNo: Code[20]; QtyBase: Decimal)
    var
        ItemTrackingSetup: Record "Item Tracking Setup";
    begin
        ItemTrackingSetup."Serial No." := SerialNo;
        ItemTrackingSetup."Lot No." := LotNo;
        ItemTrackingSetup."Package No." := PackageNo;
        CreateItemReceiptItemTracking(ReservEntry, InvtDocumentLine, ItemTrackingSetup, QtyBase);
    end;

    procedure CreateItemReceiptItemTracking(var ReservEntry: Record "Reservation Entry"; InvtDocumentLine: Record "Invt. Document Line"; ItemTrackingSetup: Record "Item Tracking Setup"; QtyBase: Decimal)
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(InvtDocumentLine);
        ItemTracking(ReservEntry, RecRef, ItemTrackingSetup, QtyBase);
    end;

    procedure CreateItemReclassJnLineItemTracking(var ReservEntry: Record "Reservation Entry"; ItemJournalLine: Record "Item Journal Line"; SerialNo: Code[50]; LotNo: Code[50]; QtyBase: Decimal)
    var
        ItemTrackingSetup: Record "Item Tracking Setup";
    begin
        ItemTrackingSetup."Serial No." := SerialNo;
        ItemTrackingSetup."Lot No." := LotNo;
        CreateItemReclassJnLineItemTracking(ReservEntry, ItemJournalLine, ItemTrackingSetup, QtyBase);
    end;

    procedure CreateItemReclassJnLineItemTracking(var ReservEntry: Record "Reservation Entry"; ItemJournalLine: Record "Item Journal Line"; SerialNo: Code[50]; LotNo: Code[50]; PackageNo: Code[20]; QtyBase: Decimal)
    var
        ItemTrackingSetup: Record "Item Tracking Setup";
    begin
        ItemTrackingSetup."Serial No." := SerialNo;
        ItemTrackingSetup."Lot No." := LotNo;
        ItemTrackingSetup."Package No." := PackageNo;
        CreateItemReclassJnLineItemTracking(ReservEntry, ItemJournalLine, ItemTrackingSetup, QtyBase);
    end;

    procedure CreateItemReclassJnLineItemTracking(var ReservEntry: Record "Reservation Entry"; ItemJournalLine: Record "Item Journal Line"; ItemTrackingSetup: Record "Item Tracking Setup"; QtyBase: Decimal)
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(ItemJournalLine);
        ItemTracking(ReservEntry, RecRef, ItemTrackingSetup, QtyBase);
    end;

    procedure CreateItemWithItemTrackingCode(var Item: Record Item; ItemTrackingCode: Record "Item Tracking Code"): Code[20]
    begin
        LibraryInventory.CreateItem(Item);
        Item.Validate("Item Tracking Code", ItemTrackingCode.Code);
        Item.Modify(true);
        exit(Item."No.");
    end;

    procedure CreateLotItem(var Item: Record Item): Code[20]
    begin
        LibraryInventory.CreateItem(Item);
        AddLotNoTrackingInfo(Item);
        exit(Item."No.");
    end;

    procedure CreateLotNoInformation(var LotNoInformation: Record "Lot No. Information"; ItemNo: Code[20]; VariantCode: Code[10]; LotNo: Code[50])
    begin
        Clear(LotNoInformation);
        LotNoInformation.Init();
        LotNoInformation.Validate("Item No.", ItemNo);
        LotNoInformation.Validate("Variant Code", VariantCode);
        LotNoInformation.Validate("Lot No.", LotNo);
        LotNoInformation.Insert(true);
    end;

    procedure CreatePackageNoInformation(var PackageNoInformation: Record "Package No. Information"; ItemNo: Code[20]; PackageNo: Code[50])
    begin
        Clear(PackageNoInformation);
        PackageNoInformation.Init();
        PackageNoInformation.Validate("Item No.", ItemNo);
        PackageNoInformation.Validate("Package No.", PackageNo);
        PackageNoInformation.Insert(true);
    end;

    procedure CreatePlanningWkshItemTracking(var ReservEntry: Record "Reservation Entry"; ReqLine: Record "Requisition Line"; SerialNo: Code[50]; LotNo: Code[50]; QtyBase: Decimal)
    var
        ItemTrackingSetup: Record "Item Tracking Setup";
    begin
        ItemTrackingSetup."Serial No." := SerialNo;
        ItemTrackingSetup."Lot No." := LotNo;
        CreatePlanningWkshItemTracking(ReservEntry, ReqLine, ItemTrackingSetup, QtyBase);
    end;

    procedure CreatePlanningWkshItemTracking(var ReservEntry: Record "Reservation Entry"; ReqLine: Record "Requisition Line"; ItemTrackingSetup: Record "Item Tracking Setup"; QtyBase: Decimal)
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(ReqLine);
        ItemTracking(ReservEntry, RecRef, ItemTrackingSetup, QtyBase);
    end;

#if not CLEAN27
#pragma warning disable AL0801
    [Obsolete('Moved to codeunit LibraryManufacturing', '27.0')]
    procedure CreateProdOrderItemTracking(var ReservEntry: Record "Reservation Entry"; ProdOrderLine: Record "Prod. Order Line"; SerialNo: Code[50]; LotNo: Code[50]; QtyBase: Decimal)
    var
        ItemTrackingSetup: Record "Item Tracking Setup";
    begin
        ItemTrackingSetup."Serial No." := SerialNo;
        ItemTrackingSetup."Lot No." := LotNo;
#pragma warning disable AL0432
        CreateProdOrderItemTracking(ReservEntry, ProdOrderLine, ItemTrackingSetup, QtyBase);
#pragma warning restore AL0432
    end;
#pragma warning restore AL0801
#endif

#if not CLEAN27
#pragma warning disable AL0801
    [Obsolete('Moved to codeunit LibraryManufacturing', '27.0')]
    procedure CreateProdOrderItemTracking(var ReservEntry: Record "Reservation Entry"; ProdOrderLine: Record "Prod. Order Line"; ItemTrackingSetup: Record "Item Tracking Setup"; QtyBase: Decimal)
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(ProdOrderLine);
        ItemTracking(ReservEntry, RecRef, ItemTrackingSetup, QtyBase);
    end;
#pragma warning restore AL0801
#endif

#if not CLEAN27
#pragma warning disable AL0801
    [Obsolete('Moved to codeunit LibraryManufacturing', '27.0')]
    procedure CreateProdOrderCompItemTracking(var ReservEntry: Record "Reservation Entry"; ProdOrderComp: Record "Prod. Order Component"; SerialNo: Code[50]; LotNo: Code[50]; QtyBase: Decimal)
    var
        ITemTrackingSetup: Record "Item Tracking Setup";
    begin
        ItemTrackingSetup."Serial No." := SerialNo;
        ItemTrackingSetup."Lot No." := LotNo;
#pragma warning disable AL0432
        CreateProdOrderCompItemTracking(ReservEntry, ProdOrderComp, ITemTrackingSetup, QtyBase);
#pragma warning restore AL0432
    end;
#pragma warning restore AL0801
#endif

#if not CLEAN27
#pragma warning disable AL0801
    [Obsolete('Moved to codeunit LibraryManufacturing', '27.0')]
    procedure CreateProdOrderCompItemTracking(var ReservEntry: Record "Reservation Entry"; ProdOrderComp: Record "Prod. Order Component"; ItemTrackingSetup: Record "Item Tracking Setup"; QtyBase: Decimal)
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(ProdOrderComp);
        ItemTracking(ReservEntry, RecRef, ItemTrackingSetup, QtyBase);
    end;
#pragma warning restore AL0801
#endif

    procedure CreatePurchOrderItemTracking(var ReservEntry: Record "Reservation Entry"; PurchLine: Record "Purchase Line"; SerialNo: Code[50]; LotNo: Code[50]; QtyBase: Decimal)
    var
        ItemTrackingSetup: Record "Item Tracking Setup";
    begin
        ItemTrackingSetup."Serial No." := SerialNo;
        ItemTrackingSetup."Lot No." := LotNo;
        CreatePurchOrderItemTracking(ReservEntry, PurchLine, ItemTrackingSetup, QtyBase);
    end;

    procedure CreatePurchOrderItemTracking(var ReservEntry: Record "Reservation Entry"; PurchLine: Record "Purchase Line"; SerialNo: Code[50]; LotNo: Code[50]; PackageNo: Code[50]; QtyBase: Decimal)
    var
        ItemTrackingSetup: Record "Item Tracking Setup";
    begin
        ItemTrackingSetup."Serial No." := SerialNo;
        ItemTrackingSetup."Lot No." := LotNo;
        ItemTrackingSetup."Package No." := PackageNo;
        CreatePurchOrderItemTracking(ReservEntry, PurchLine, ItemTrackingSetup, QtyBase);
    end;

    procedure CreatePurchOrderItemTracking(var ReservEntry: Record "Reservation Entry"; PurchLine: Record "Purchase Line"; ItemTrackingSetup: Record "Item Tracking Setup"; QtyBase: Decimal)
    var
        RecRef: RecordRef;
    begin
        if PurchLine."Document Type" = PurchLine."Document Type"::"Blanket Order" then // cannot create IT for this line from UI
            Error(Text001, RecRef.Number);
        RecRef.GetTable(PurchLine);
        ItemTracking(ReservEntry, RecRef, ItemTrackingSetup, QtyBase);
    end;

    procedure CreateReqWkshItemTracking(var ReservEntry: Record "Reservation Entry"; ReqLine: Record "Requisition Line"; SerialNo: Code[50]; LotNo: Code[50]; QtyBase: Decimal)
    begin
        CreatePlanningWkshItemTracking(ReservEntry, ReqLine, SerialNo, LotNo, QtyBase);
    end;

    procedure CreateSalesOrderItemTracking(var ReservEntry: Record "Reservation Entry"; SalesLine: Record "Sales Line"; SerialNo: Code[50]; LotNo: Code[50]; QtyBase: Decimal)
    var
        ItemTrackingSetup: Record "Item Tracking Setup";
    begin
        ItemTrackingSetup."Serial No." := SerialNo;
        ItemTrackingSetup."Lot No." := LotNo;
        CreateSalesOrderItemTracking(ReservEntry, SalesLine, ItemTrackingSetup, QtyBase);
    end;

    procedure CreateSalesOrderItemTracking(var ReservEntry: Record "Reservation Entry"; SalesLine: Record "Sales Line"; SerialNo: Code[50]; LotNo: Code[50]; PackageNo: Code[50]; QtyBase: Decimal)
    var
        ItemTrackingSetup: Record "Item Tracking Setup";
    begin
        ItemTrackingSetup."Serial No." := SerialNo;
        ItemTrackingSetup."Lot No." := LotNo;
        ItemTrackingSetup."Package No." := PackageNo;
        CreateSalesOrderItemTracking(ReservEntry, SalesLine, ItemTrackingSetup, QtyBase);
    end;

    procedure CreateSalesOrderItemTracking(var ReservEntry: Record "Reservation Entry"; SalesLine: Record "Sales Line"; ItemTrackingSetup: Record "Item Tracking Setup"; QtyBase: Decimal)
    var
        RecRef: RecordRef;
    begin
        if SalesLine."Document Type" = SalesLine."Document Type"::"Blanket Order" then // cannot create IT for this line from UI
            Error(Text001, RecRef.Number);
        RecRef.GetTable(SalesLine);
        ItemTracking(ReservEntry, RecRef, ItemTrackingSetup, QtyBase);
    end;

    procedure CreateSerialItem(var Item: Record Item): Code[20]
    begin
        LibraryInventory.CreateItem(Item);
        AddSerialNoTrackingInfo(Item);
        exit(Item."No.");
    end;

    procedure CreateSerialNoInformation(var SerialNoInformation: Record "Serial No. Information"; ItemNo: Code[20]; VariantCode: Code[10]; SerialNo: Code[50])
    begin
        Clear(SerialNoInformation);
        SerialNoInformation.Init();
        SerialNoInformation.Validate("Item No.", ItemNo);
        SerialNoInformation.Validate("Variant Code", VariantCode);
        SerialNoInformation.Validate("Serial No.", SerialNo);
        SerialNoInformation.Insert(true);
    end;

    procedure CreateTransferOrderItemTracking(var ReservEntry: Record "Reservation Entry"; TransferLine: Record "Transfer Line"; SerialNo: Code[50]; LotNo: Code[50]; QtyBase: Decimal)
    var
        ItemTrackingSetup: Record "Item Tracking Setup";
    begin
        ItemTrackingSetup."Serial No." := SerialNo;
        ItemTrackingSetup."Lot No." := LotNo;
        CreateTransferOrderItemTracking(ReservEntry, TransferLine, ItemTrackingSetup, QtyBase);
    end;

    procedure CreateTransferOrderItemTracking(var ReservEntry: Record "Reservation Entry"; TransferLine: Record "Transfer Line"; SerialNo: Code[50]; LotNo: Code[50]; PackageNo: Code[50]; QtyBase: Decimal)
    var
        ItemTrackingSetup: Record "Item Tracking Setup";
    begin
        ItemTrackingSetup."Serial No." := SerialNo;
        ItemTrackingSetup."Lot No." := LotNo;
        ItemTrackingSetup."Package No." := PackageNo;
        CreateTransferOrderItemTracking(ReservEntry, TransferLine, ItemTrackingSetup, QtyBase);
    end;

    procedure CreateTransferOrderItemTracking(var ReservEntry: Record "Reservation Entry"; TransferLine: Record "Transfer Line"; ItemTrackingSetup: Record "Item Tracking Setup"; QtyBase: Decimal)
    var
        RecRef: RecordRef;
    begin
        // Only creates IT lines for Transfer order shipment! IT lines for receipt cannot be added in form.
        // Note that the ReservEntry returned has two lines - one for TRANSFER-FROM and one for TRANSFER-TO
        RecRef.GetTable(TransferLine);
        ItemTracking(ReservEntry, RecRef, ItemTrackingSetup, QtyBase);
    end;

    procedure CreateWhseInvtPickItemTracking(var WhseItemTrackingLine: Record "Whse. Item Tracking Line"; WhseInternalPickLine: Record "Whse. Internal Pick Line"; SerialNo: Code[50]; LotNo: Code[50]; QtyBase: Decimal)
    var
        WhseItemTrackingSetup: Record "Item Tracking Setup";
    begin
        WhseItemTrackingSetup."Serial No." := SerialNo;
        WhseItemTrackingSetup."Lot No." := LotNo;
        CreateWhseInvtPickItemTracking(WhseItemTrackingLine, WhseInternalPickLine, WhseItemTrackingSetup, QtyBase);
    end;

    procedure CreateWhseInvtPickItemTracking(var WhseItemTrackingLine: Record "Whse. Item Tracking Line"; WhseInternalPickLine: Record "Whse. Internal Pick Line"; WhseItemTrackingSetup: Record "Item Tracking Setup"; QtyBase: Decimal)
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(WhseInternalPickLine);
        WhseItemTracking(WhseItemTrackingLine, RecRef, WhseItemTrackingSetup, QtyBase);
    end;

    procedure CreateWhseInvtPutawayItemTracking(var WhseItemTrackingLine: Record "Whse. Item Tracking Line"; WhseInternalPutAwayLine: Record "Whse. Internal Put-away Line"; SerialNo: Code[50]; LotNo: Code[50]; QtyBase: Decimal)
    var
        WhseItemTrackingSetup: Record "Item Tracking Setup";
    begin
        WhseItemTrackingSetup."Serial No." := SerialNo;
        WhseItemTrackingSetup."Lot No." := LotNo;
        CreateWhseInvtPutawayItemTracking(WhseItemTrackingLine, WhseInternalPutAwayLine, WhseItemTrackingSetup, QtyBase);
    end;

    procedure CreateWhseInvtPutawayItemTracking(var WhseItemTrackingLine: Record "Whse. Item Tracking Line"; WhseInternalPutAwayLine: Record "Whse. Internal Put-away Line"; WhseItemTrackingSetup: Record "Item Tracking Setup"; QtyBase: Decimal)
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(WhseInternalPutAwayLine);
        WhseItemTracking(WhseItemTrackingLine, RecRef, WhseItemTrackingSetup, QtyBase);
    end;

    procedure CreateWhseJournalLineItemTracking(var WhseItemTrackingLine: Record "Whse. Item Tracking Line"; WhseJnlLine: Record "Warehouse Journal Line"; SerialNo: Code[50]; LotNo: Code[50]; QtyBase: Decimal)
    var
        WhseItemTrackingSetup: Record "Item Tracking Setup";
    begin
        WhseItemTrackingSetup."Serial No." := SerialNo;
        WhseItemTrackingSetup."Lot No." := LotNo;
        CreateWhseJournalLineItemTracking(WhseItemTrackingLine, WhseJnlLine, WhseItemTrackingSetup, QtyBase);
    end;

    procedure CreateWhseJournalLineItemTracking(var WhseItemTrackingLine: Record "Whse. Item Tracking Line"; WhseJnlLine: Record "Warehouse Journal Line"; WhseItemTrackingSetup: Record "Item Tracking Setup"; QtyBase: Decimal)
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(WhseJnlLine);
        WhseItemTracking(WhseItemTrackingLine, RecRef, WhseItemTrackingSetup, QtyBase);
    end;

    procedure CreateWhseReceiptItemTracking(var ReservEntry: Record "Reservation Entry"; WhseRcptLine: Record "Warehouse Receipt Line"; SerialNo: Code[50]; LotNo: Code[50]; QtyBase: Decimal)
    var
        WhseItemTrackingSetup: Record "Item Tracking Setup";
    begin
        WhseItemTrackingSetup."Serial No." := SerialNo;
        WhseItemTrackingSetup."Lot No." := LotNo;
        CreateWhseReceiptItemTracking(ReservEntry, WhseRcptLine, WhseItemTrackingSetup, QtyBase);
    end;

    procedure CreateWhseReceiptItemTracking(var ReservEntry: Record "Reservation Entry"; WhseRcptLine: Record "Warehouse Receipt Line"; WhseItemTrackingSetup: Record "Item Tracking Setup"; QtyBase: Decimal)
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(WhseRcptLine);
        ItemTracking(ReservEntry, RecRef, WhseItemTrackingSetup, QtyBase);
    end;

    procedure CreateWhseShipmentItemTracking(var ReservEntry: Record "Reservation Entry"; WhseShptLine: Record "Warehouse Shipment Line"; SerialNo: Code[50]; LotNo: Code[50]; QtyBase: Decimal)
    var
        WhseItemTrackingSetup: Record "Item Tracking Setup";
    begin
        WhseItemTrackingSetup."Serial No." := SerialNo;
        WhseItemTrackingSetup."Lot No." := LotNo;
        CreateWhseShipmentItemTracking(ReservEntry, WhseShptLine, WhseItemTrackingSetup, QtyBase);
    end;

    procedure CreateWhseShipmentItemTracking(var ReservEntry: Record "Reservation Entry"; WhseShptLine: Record "Warehouse Shipment Line"; WhseItemTrackingSetup: Record "Item Tracking Setup"; QtyBase: Decimal)
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(WhseShptLine);
        ItemTracking(ReservEntry, RecRef, WhseItemTrackingSetup, QtyBase);
    end;

    procedure CreateWhseWkshItemTracking(var WhseItemTrackingLine: Record "Whse. Item Tracking Line"; WhseWkshLine: Record "Whse. Worksheet Line"; SerialNo: Code[50]; LotNo: Code[50]; QtyBase: Decimal)
    var
        WhseItemTrackingSetup: Record "Item Tracking Setup";
    begin
        WhseItemTrackingSetup."Serial No." := SerialNo;
        WhseItemTrackingSetup."Lot No." := LotNo;
        CreateWhseWkshItemTracking(WhseItemTrackingLine, WhseWkshLine, WhseItemTrackingSetup, QtyBase);
    end;

    procedure CreateWhseWkshItemTracking(var WhseItemTrackingLine: Record "Whse. Item Tracking Line"; WhseWkshLine: Record "Whse. Worksheet Line"; WhseItemTrackingSetup: Record "Item Tracking Setup"; QtyBase: Decimal)
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(WhseWkshLine);
        WhseItemTracking(WhseItemTrackingLine, RecRef, WhseItemTrackingSetup, QtyBase);
    end;

    procedure ItemJournal_CalcWhseAdjmnt(var Item: Record Item; NewPostingDate: Date; DocumentNo: Text[20])
    var
        ItemJournalLine: Record "Item Journal Line";
        TmpItem: Record Item;
        ItemJournalTemplate: Record "Item Journal Template";
        ItemJournalBatch: Record "Item Journal Batch";
        CalcWhseAdjmnt: Report "Calculate Whse. Adjustment";
        NoSeries: Codeunit "No. Series";
        LibraryAssembly: Codeunit "Library - Assembly";
    begin
        LibraryAssembly.SetupItemJournal(ItemJournalTemplate, ItemJournalBatch);
        ItemJournalLine.Validate("Journal Template Name", ItemJournalBatch."Journal Template Name");
        ItemJournalLine.Validate("Journal Batch Name", ItemJournalBatch.Name);

        Commit();
        CalcWhseAdjmnt.SetItemJnlLine(ItemJournalLine);
        if DocumentNo = '' then
            DocumentNo := NoSeries.PeekNextNo(ItemJournalBatch."No. Series", NewPostingDate);
        CalcWhseAdjmnt.InitializeRequest(NewPostingDate, DocumentNo);
        if Item.HasFilter then
            TmpItem.CopyFilters(Item)
        else begin
            Item.Get(Item."No.");
            TmpItem.SetRange("No.", Item."No.");
        end;

        CalcWhseAdjmnt.SetTableView(TmpItem);
        CalcWhseAdjmnt.UseRequestPage(false);
        CalcWhseAdjmnt.RunModal();
    end;

    procedure ItemTracking(var ReservEntry: Record "Reservation Entry"; RecRef: RecordRef; ItemTrackingSetup: Record "Item Tracking Setup"; QtyBase: Decimal)
    var
        SalesLine: Record "Sales Line";
        PurchLine: Record "Purchase Line";
        AssemblyLine: Record "Assembly Line";
        AssemblyHeader: Record "Assembly Header";
        TransLine: Record "Transfer Line";
        ItemJournalLine: Record "Item Journal Line";
        ReqLine: Record "Requisition Line";
        WhseShptLine: Record "Warehouse Shipment Line";
        WhseRcptLine: Record "Warehouse Receipt Line";
        InvtDocumentLine: Record "Invt. Document Line";
        Job: Record Job;
        Item: Record Item;
        OutgoingEntryNo: Integer;
        IncomingEntryNo: Integer;
        IsHandled: Boolean;
    begin
        // remove leading spaces
        ItemTrackingSetup."Serial No." := DelChr(ItemTrackingSetup."Serial No.", '<', ' ');
        ItemTrackingSetup."Lot No." := DelChr(ItemTrackingSetup."Lot No.", '<', ' ');
        ItemTrackingSetup."Package No." := DelChr(ItemTrackingSetup."Package No.", '<', ' ');
        case RecRef.Number of
            DATABASE::"Sales Line":
                begin
                    RecRef.SetTable(SalesLine);
                    // COPY FROM TAB 37: OpenItemTrackingLines
                    SalesLine.TestField(Type, SalesLine.Type::Item);
                    SalesLine.TestField("No.");
                    SalesLine.TestField("Quantity (Base)");
                    if SalesLine."Job Contract Entry No." <> 0 then
                        Error(Text048, SalesLine.TableCaption(), Job.TableCaption());
                    // COPY END
                    InsertItemTracking(
                        ReservEntry, SalesLine.SignedXX(SalesLine.Quantity) > 0,
                        SalesLine."No.", SalesLine."Location Code", SalesLine."Variant Code",
                        SalesLine.SignedXX(QtyBase), SalesLine."Qty. per Unit of Measure", ItemTrackingSetup,
                        DATABASE::"Sales Line", SalesLine."Document Type".AsInteger(), SalesLine."Document No.",
                        '', 0, SalesLine."Line No.", SalesLine."Shipment Date");
                end;
            DATABASE::"Purchase Line":
                begin
                    RecRef.SetTable(PurchLine);
                    // COPY FROM TAB 39: OpenItemTrackingLines
                    PurchLine.TestField(Type, PurchLine.Type::Item);
                    PurchLine.TestField("No.");
                    if PurchLine."Prod. Order No." <> '' then
                        Error(Text031, PurchLine."Prod. Order No.");
                    PurchLine.TestField("Quantity (Base)");
                    // COPY END
                    InsertItemTracking(
                        ReservEntry, PurchLine.Signed(PurchLine.Quantity) > 0,
                        PurchLine."No.", PurchLine."Location Code", PurchLine."Variant Code",
                        PurchLine.Signed(QtyBase), PurchLine."Qty. per Unit of Measure", ItemTrackingSetup,
                        DATABASE::"Purchase Line", PurchLine."Document Type".AsInteger(), PurchLine."Document No.",
                        '', 0, PurchLine."Line No.", PurchLine."Expected Receipt Date");
                end;
            DATABASE::"Assembly Line":
                begin
                    RecRef.SetTable(AssemblyLine);
                    AssemblyLine.TestField(Type, AssemblyLine.Type::Item);
                    AssemblyLine.TestField("No.");
                    AssemblyLine.TestField("Quantity (Base)");
                    InsertItemTracking(
                        ReservEntry, AssemblyLine.Quantity < 0,
                        AssemblyLine."No.", AssemblyLine."Location Code", AssemblyLine."Variant Code",
                        -QtyBase, AssemblyLine."Qty. per Unit of Measure", ItemTrackingSetup,
                        DATABASE::"Assembly Line", AssemblyLine."Document Type".AsInteger(), AssemblyLine."Document No.",
                        '', 0, AssemblyLine."Line No.", AssemblyLine."Due Date");
                end;
            DATABASE::"Assembly Header":
                begin
                    RecRef.SetTable(AssemblyHeader);
                    AssemblyHeader.TestField("Document Type", AssemblyHeader."Document Type"::Order);
                    AssemblyHeader.TestField("Item No.");
                    AssemblyHeader.TestField("Quantity (Base)");
                    InsertItemTracking(
                        ReservEntry, AssemblyHeader.Quantity > 0,
                        AssemblyHeader."Item No.", AssemblyHeader."Location Code", AssemblyHeader."Variant Code",
                        QtyBase, AssemblyHeader."Qty. per Unit of Measure", ItemTrackingSetup,
                        DATABASE::"Assembly Header", AssemblyHeader."Document Type".AsInteger(), AssemblyHeader."No.",
                        '', 0, 0, AssemblyHeader."Due Date");
                end;
            DATABASE::"Transfer Line":
                begin
                    RecRef.SetTable(TransLine);
                    // COPY FROM TAB 5741: OpenItemTrackingLines
                    TransLine.TestField("Item No.");
                    TransLine.TestField("Quantity (Base)");
                    // COPY END
                    // creates 2 lines- one for Transfer-from and another for Transfer-to
                    // first, outgoing line
                    InsertItemTracking(
                        ReservEntry, false,
                        TransLine."Item No.", TransLine."Transfer-from Code", TransLine."Variant Code",
                        -QtyBase, TransLine."Qty. per Unit of Measure", ItemTrackingSetup,
                        DATABASE::"Transfer Line", 0, TransLine."Document No.",
                        '', 0, TransLine."Line No.", TransLine."Shipment Date");
                    OutgoingEntryNo := ReservEntry."Entry No.";
                    // next, incoming line
                    InsertItemTracking(
                        ReservEntry, true,
                        TransLine."Item No.", TransLine."Transfer-to Code", TransLine."Variant Code",
                        QtyBase, TransLine."Qty. per Unit of Measure", ItemTrackingSetup,
                        DATABASE::"Transfer Line", 1, TransLine."Document No.",
                        '', 0, TransLine."Line No.", TransLine."Receipt Date");
                    IncomingEntryNo := ReservEntry."Entry No.";
                    Clear(ReservEntry);
                    ReservEntry.SetFilter("Entry No.", '%1|%2', OutgoingEntryNo, IncomingEntryNo);
                    ReservEntry.FindSet(); // returns both entries
                end;
            DATABASE::"Item Journal Line":
                begin
                    RecRef.SetTable(ItemJournalLine);
                    InsertItemTracking(
                        ReservEntry, ItemJournalLine.Signed(ItemJournalLine.Quantity) > 0,
                        ItemJournalLine."Item No.", ItemJournalLine."Location Code", ItemJournalLine."Variant Code",
                        ItemJournalLine.Signed(QtyBase), ItemJournalLine."Qty. per Unit of Measure", ItemTrackingSetup,
                        DATABASE::"Item Journal Line", ItemJournalLine."Entry Type".AsInteger(), ItemJournalLine."Journal Template Name",
                        ItemJournalLine."Journal Batch Name", 0, ItemJournalLine."Line No.", ItemJournalLine."Posting Date");
                end;
            DATABASE::"Requisition Line":
                begin
                    RecRef.SetTable(ReqLine);
                    // COPY FROM TAB 246: OpenItemTrackingLines
                    ReqLine.TestField(Type, ReqLine.Type::Item);
                    ReqLine.TestField("No.");
                    ReqLine.TestField("Quantity (Base)");
                    // COPY END
                    InsertItemTracking(
                        ReservEntry, ReqLine.Quantity > 0,
                        ReqLine."No.", ReqLine."Location Code", ReqLine."Variant Code",
                        QtyBase, ReqLine."Qty. per Unit of Measure", ItemTrackingSetup,
                        DATABASE::"Requisition Line", 0, ReqLine."Worksheet Template Name",
                        ReqLine."Journal Batch Name", ReqLine."Prod. Order Line No.", ReqLine."Line No.", ReqLine."Due Date");
                end;
            DATABASE::"Warehouse Shipment Line":
                begin
                    WhseShptLine.Init();
                    RecRef.SetTable(WhseShptLine);
                    // COPY FROM TAB 7321: OpenItemTrackingLines
                    WhseShptLine.TestField("No.");
                    WhseShptLine.TestField("Qty. (Base)");
                    Item.Get(WhseShptLine."Item No.");
                    Item.TestField("Item Tracking Code");
                    // COPY END
                    case WhseShptLine."Source Type" of
                        DATABASE::"Sales Line":
                            if SalesLine.Get(WhseShptLine."Source Subtype", WhseShptLine."Source No.", WhseShptLine."Source Line No.") then
                                CreateSalesOrderItemTracking(ReservEntry, SalesLine, ItemTrackingSetup, QtyBase);
                        DATABASE::"Purchase Line":
                            if PurchLine.Get(WhseShptLine."Source Subtype", WhseShptLine."Source No.", WhseShptLine."Source Line No.") then
                                CreatePurchOrderItemTracking(ReservEntry, PurchLine, ItemTrackingSetup, QtyBase);
                        DATABASE::"Transfer Line":
                            // Outbound only
                            if TransLine.Get(WhseShptLine."Source No.", WhseShptLine."Source Line No.") then
                                CreateTransferOrderItemTracking(ReservEntry, TransLine, ItemTrackingSetup, QtyBase);
                    end;
                end;
            DATABASE::"Warehouse Receipt Line":
                begin
                    WhseRcptLine.Init();
                    RecRef.SetTable(WhseRcptLine);
                    // COPY FROM TAB 7317: OpenItemTrackingLines
                    WhseRcptLine.TestField("No.");
                    WhseRcptLine.TestField("Qty. (Base)");
                    Item.Get(WhseRcptLine."Item No.");
                    Item.TestField("Item Tracking Code");
                    // COPY END
                    case WhseRcptLine."Source Type" of
                        DATABASE::"Purchase Line":
                            if PurchLine.Get(WhseRcptLine."Source Subtype", WhseRcptLine."Source No.", WhseRcptLine."Source Line No.") then
                                CreatePurchOrderItemTracking(ReservEntry, PurchLine, ItemTrackingSetup, QtyBase);
                        DATABASE::"Sales Line":
                            if SalesLine.Get(WhseRcptLine."Source Subtype", WhseRcptLine."Source No.", WhseRcptLine."Source Line No.") then
                                CreateSalesOrderItemTracking(ReservEntry, SalesLine, ItemTrackingSetup, QtyBase);
                        DATABASE::"Transfer Line":
                            // Inbound only - not possible to ADD item tracking lines- so throw error
                            Error(Text001, RecRef.Number);
                    end;
                end;
            DATABASE::"Invt. Document Line":
                begin
                    RecRef.SetTable(InvtDocumentLine);
                    InsertItemTracking(ReservEntry,
                      InvtDocumentLine.Signed(InvtDocumentLine.Quantity) > 0,
                      InvtDocumentLine."Item No.", InvtDocumentLine."Location Code", InvtDocumentLine."Variant Code",
                      InvtDocumentLine.Signed(QtyBase), InvtDocumentLine."Qty. per Unit of Measure", ItemTrackingSetup,
                      DATABASE::"Invt. Document Line", InvtDocumentLine."Document Type".AsInteger(),
                      InvtDocumentLine."Document No.", '', 0, InvtDocumentLine."Line No.", InvtDocumentLine."Posting Date");
                end;
            else begin
                IsHandled := true;
                OnItemTracking(RecRef, ReservEntry, ItemTrackingSetup, QtyBase, IsHandled);
                if not IsHandled then
                    Error(Text001, RecRef.Number);
            end;
        end;
    end;

    procedure InsertItemTracking(var ReservEntry: Record "Reservation Entry"; Positive2: Boolean; Item: Code[20]; Location: Code[10]; Variant: Code[10]; QtyBase: Decimal; QtyperUOM: Decimal; ItemTrackingSetup: Record "Item Tracking Setup"; SourceType: Integer; SourceSubType: Integer; SourceID: Code[20]; SourceBatchName: Code[10]; SourceProdOrderLine: Integer; SourceRefNo: Integer; DueDate: Date)
    var
        SalesLine: Record "Sales Line";
        PurchLine: Record "Purchase Line";
        ItemJnlLine: Record "Item Journal Line";
        LastEntryNo: Integer;
    begin
        if (ItemTrackingSetup."Serial No." <> '') and (Abs(QtyBase) > 1) then
            Error(Text002, ItemTrackingSetup."Serial No.", QtyBase);
        Clear(ReservEntry);
        if ReservEntry.FindLast() then
            LastEntryNo := ReservEntry."Entry No." + 1
        else
            LastEntryNo := 1;
        ReservEntry.Init();
        ReservEntry."Entry No." := LastEntryNo;
        ReservEntry.Positive := Positive2;
        if (SourceType = DATABASE::"Item Journal Line") or
#pragma warning disable AL0801
           ((SourceType = DATABASE::"Prod. Order Line") and (SourceSubType in [0, 1])) or
           // simulated or planned prod line
           ((SourceType = DATABASE::"Prod. Order Component") and (SourceSubType in [0, 1])) or
           // simulated or planned prod comp
#pragma warning restore AL0801
           (SourceType = DATABASE::"Requisition Line")
        then
            ReservEntry.Validate("Reservation Status", ReservEntry."Reservation Status"::Prospect)
        else
            ReservEntry.Validate("Reservation Status", ReservEntry."Reservation Status"::Surplus);

        ReservEntry.Validate("Item No.", Item);
        ReservEntry.Validate("Location Code", Location);
        ReservEntry.Validate("Variant Code", Variant);
        ReservEntry.Validate("Qty. per Unit of Measure", QtyperUOM);
        ReservEntry.Validate("Quantity (Base)", QtyBase);

        case SourceType of
            DATABASE::"Item Journal Line":
                case "Item Ledger Entry Type".FromInteger(SourceSubType) of
                    ItemJnlLine."Entry Type"::Purchase,
                    ItemJnlLine."Entry Type"::"Positive Adjmt.",
                    ItemJnlLine."Entry Type"::Output:
                        ReservEntry.Validate("Expected Receipt Date", DueDate);
                    ItemJnlLine."Entry Type"::Sale,
                    ItemJnlLine."Entry Type"::"Negative Adjmt.",
                    ItemJnlLine."Entry Type"::Consumption:
                        ReservEntry.Validate("Shipment Date", DueDate);
                end;
            5406: // DATABASE::"Prod. Order Line"
                ReservEntry.Validate("Expected Receipt Date", DueDate);
            5407: // DATABASE::"Prod. Order Component"
                ReservEntry.Validate("Shipment Date", DueDate);
            DATABASE::"Requisition Line":
                ReservEntry.Validate("Shipment Date", DueDate);
            DATABASE::"Sales Line":
                case SourceSubType of
                    SalesLine."Document Type"::Order.AsInteger(),
                    SalesLine."Document Type"::Invoice.AsInteger(),
                    SalesLine."Document Type"::Quote.AsInteger():
                        ReservEntry.Validate("Shipment Date", DueDate);
                    SalesLine."Document Type"::"Return Order".AsInteger(),
                    SalesLine."Document Type"::"Credit Memo".AsInteger():
                        ReservEntry.Validate("Expected Receipt Date", DueDate);
                end;
            DATABASE::"Purchase Line":
                case SourceSubType of
                    PurchLine."Document Type"::Order.AsInteger(),
                    PurchLine."Document Type"::Invoice.AsInteger(),
                    PurchLine."Document Type"::Quote.AsInteger():
                        ReservEntry.Validate("Expected Receipt Date", DueDate);
                    PurchLine."Document Type"::"Return Order".AsInteger(),
                    PurchLine."Document Type"::"Credit Memo".AsInteger():
                        ReservEntry.Validate("Shipment Date", DueDate);
                end;
            else
                if Positive2 then
                    ReservEntry.Validate("Expected Receipt Date", DueDate)
                else
                    ReservEntry.Validate("Shipment Date", DueDate);
        end;
        ReservEntry.Validate("Creation Date", WorkDate());
        ReservEntry."Created By" := CopyStr(UserId(), 1, MaxStrLen(ReservEntry."Created By"));

        ReservEntry.Validate("Serial No.", ItemTrackingSetup."Serial No.");
        ReservEntry.Validate("Lot No.", ItemTrackingSetup."Lot No.");
        ReservEntry.Validate("Package No.", ItemTrackingSetup."Package No.");

        ReservEntry.UpdateItemTracking();

        ReservEntry.Validate("Source Type", SourceType);
        ReservEntry.Validate("Source Subtype", SourceSubType);
        ReservEntry.Validate("Source ID", SourceID);
        ReservEntry.Validate("Source Batch Name", SourceBatchName);
        ReservEntry.Validate("Source Prod. Order Line", SourceProdOrderLine);
        ReservEntry.Validate("Source Ref. No.", SourceRefNo);

        ReservEntry.Insert(true);
    end;

    local procedure WhseItemTracking(var WhseItemTrackingLine: Record "Whse. Item Tracking Line"; RecRef: RecordRef; WhseItemTrackingSetup: Record "Item Tracking Setup"; QtyBase: Decimal)
    var
        WhseJnlLine: Record "Warehouse Journal Line";
        WhseWkshLine: Record "Whse. Worksheet Line";
        WhseInternalPutAwayLine: Record "Whse. Internal Put-away Line";
        WhseInternalPickLine: Record "Whse. Internal Pick Line";
        SourceType: Integer;
        SourceID: Code[20];
        SourceBatchName: Code[10];
        SourceRefNo: Integer;
    begin
        // remove leading spaces
        WhseItemTrackingSetup."Serial No." := DelChr(WhseItemTrackingSetup."Serial No.", '<', ' ');
        WhseItemTrackingSetup."Lot No." := DelChr(WhseItemTrackingSetup."Lot No.", '<', ' ');
        WhseItemTrackingSetup."Package No." := DelChr(WhseItemTrackingSetup."Package No.", '<', ' ');
        case RecRef.Number of
            DATABASE::"Warehouse Journal Line":
                begin
                    WhseJnlLine.Init();
                    RecRef.SetTable(WhseJnlLine);
                    // COPY FROM TAB 7311: OpenItemTrackingLines
                    WhseJnlLine.TestField("Item No.");
                    WhseJnlLine.TestField("Qty. (Base)");
                    // COPY END
                    WhseInsertItemTracking(WhseItemTrackingLine,
                      WhseJnlLine."Item No.",
                      WhseJnlLine."Location Code",
                      WhseJnlLine."Variant Code",
                      QtyBase,
                      WhseJnlLine."Qty. per Unit of Measure",
                      WhseItemTrackingSetup,
                      DATABASE::"Warehouse Journal Line",
                      0,
                      WhseJnlLine."Journal Batch Name",
                      WhseJnlLine."Journal Template Name",
                      0,
                      WhseJnlLine."Line No.");
                end;
            DATABASE::"Whse. Worksheet Line":
                begin
                    RecRef.SetTable(WhseWkshLine);
                    // COPY FROM TAB 7326: OpenItemTrackingLines
                    WhseWkshLine.TestField("Item No.");
                    WhseWkshLine.TestField("Qty. (Base)");
                    case WhseWkshLine."Whse. Document Type" of
                        WhseWkshLine."Whse. Document Type"::Receipt:
                            begin
                                SourceType := DATABASE::"Posted Whse. Receipt Line";
                                SourceID := WhseWkshLine."Whse. Document No.";
                                SourceBatchName := '';
                                SourceRefNo := WhseWkshLine."Whse. Document Line No.";
                            end;
                        WhseWkshLine."Whse. Document Type"::Shipment:
                            begin
                                SourceType := DATABASE::"Warehouse Shipment Line";
                                SourceID := WhseWkshLine."Whse. Document No.";
                                SourceBatchName := '';
                                SourceRefNo := WhseWkshLine."Whse. Document Line No.";
                            end;
                        WhseWkshLine."Whse. Document Type"::"Internal Put-away":
                            begin
                                SourceType := DATABASE::"Whse. Internal Put-away Line";
                                SourceID := WhseWkshLine."Whse. Document No.";
                                SourceBatchName := '';
                                SourceRefNo := WhseWkshLine."Whse. Document Line No.";
                            end;
                        WhseWkshLine."Whse. Document Type"::"Internal Pick":
                            begin
                                SourceType := DATABASE::"Whse. Internal Pick Line";
                                SourceID := WhseWkshLine."Whse. Document No.";
                                SourceBatchName := '';
                                SourceRefNo := WhseWkshLine."Whse. Document Line No.";
                            end;
                        WhseWkshLine."Whse. Document Type"::Production:
                            begin
                                SourceType := 5407; // DATABASE::"Prod. Order Component";
                                SourceID := WhseWkshLine."Whse. Document No.";
                                SourceBatchName := '';
                                SourceRefNo := WhseWkshLine."Whse. Document Line No.";
                            end;
                        WhseWkshLine."Whse. Document Type"::Assembly:
                            begin
                                SourceType := DATABASE::"Assembly Line";
                                SourceID := WhseWkshLine."Whse. Document No.";
                                SourceBatchName := '';
                                SourceRefNo := WhseWkshLine."Whse. Document Line No.";
                            end;
                        else begin
                            SourceType := DATABASE::"Whse. Worksheet Line";
                            SourceID := WhseWkshLine.Name;
                            SourceBatchName := WhseWkshLine."Worksheet Template Name";
                            SourceRefNo := WhseWkshLine."Line No.";
                        end;
                    end;
                    // COPY END
                    WhseInsertItemTracking(WhseItemTrackingLine,
                      WhseWkshLine."Item No.",
                      WhseWkshLine."Location Code",
                      WhseWkshLine."Variant Code",
                      QtyBase,
                      WhseWkshLine."Qty. per Unit of Measure",
                      WhseItemTrackingSetup,
                      SourceType,
                      0,
                      SourceID,
                      SourceBatchName,
                      0,
                      SourceRefNo);
                end;
            DATABASE::"Whse. Internal Put-away Line":
                begin
                    WhseInternalPutAwayLine.Init();
                    RecRef.SetTable(WhseInternalPutAwayLine);
                    // COPY FROM TAB 7332: OpenItemTrackingLines
                    WhseInternalPutAwayLine.TestField("Item No.");
                    WhseInternalPutAwayLine.TestField("Qty. (Base)");
                    WhseWkshLine.Init();
                    WhseWkshLine."Whse. Document Type" :=
                      WhseWkshLine."Whse. Document Type"::"Internal Put-away";
                    WhseWkshLine."Whse. Document No." := WhseInternalPutAwayLine."No.";
                    WhseWkshLine."Whse. Document Line No." := WhseInternalPutAwayLine."Line No.";
                    WhseWkshLine."Location Code" := WhseInternalPutAwayLine."Location Code";
                    WhseWkshLine."Item No." := WhseInternalPutAwayLine."Item No.";
                    WhseWkshLine."Qty. (Base)" := WhseInternalPutAwayLine."Qty. (Base)";
                    WhseWkshLine."Qty. to Handle (Base)" :=
                      WhseInternalPutAwayLine."Qty. (Base)" - WhseInternalPutAwayLine."Qty. Put Away (Base)" -
                      WhseInternalPutAwayLine."Put-away Qty. (Base)";
                    WhseWkshLine."Qty. per Unit of Measure" := WhseInternalPutAwayLine."Qty. per Unit of Measure";
                    // COPY END
                    RecRef.GetTable(WhseWkshLine);
                    WhseItemTracking(WhseItemTrackingLine, RecRef, WhseItemTrackingSetup, QtyBase);
                end;
            DATABASE::"Whse. Internal Pick Line":
                begin
                    WhseInternalPickLine.Init();
                    RecRef.SetTable(WhseInternalPickLine);
                    // COPY FROM TAB 7334: OpenItemTrackingLines
                    WhseInternalPickLine.TestField("Item No.");
                    WhseInternalPickLine.TestField("Qty. (Base)");
                    WhseWkshLine.Init();
                    WhseWkshLine."Whse. Document Type" :=
                      WhseWkshLine."Whse. Document Type"::"Internal Pick";
                    WhseWkshLine."Whse. Document No." := WhseInternalPickLine."No.";
                    WhseWkshLine."Whse. Document Line No." := WhseInternalPickLine."Line No.";
                    WhseWkshLine."Location Code" := WhseInternalPickLine."Location Code";
                    WhseWkshLine."Item No." := WhseInternalPickLine."Item No.";
                    WhseWkshLine."Qty. (Base)" := WhseInternalPickLine."Qty. (Base)";
                    WhseWkshLine."Qty. to Handle (Base)" :=
                      WhseInternalPickLine."Qty. (Base)" - WhseInternalPickLine."Qty. Picked (Base)" -
                      WhseInternalPickLine."Pick Qty. (Base)";
                    // WhseWkshLine."Qty. per Unit of Measure" := WhseInternalPickLine."Qty. per Unit of Measure";
                    // COPY END
                    RecRef.GetTable(WhseWkshLine);
                    WhseItemTracking(WhseItemTrackingLine, RecRef, WhseItemTrackingSetup, QtyBase);
                end;
        end;
    end;

    local procedure WhseInsertItemTracking(var WhseItemTrackingLine: Record "Whse. Item Tracking Line"; Item: Code[20]; Location: Code[10]; Variant: Code[10]; QtyBase: Decimal; QtyperUOM: Decimal; WhseItemTrackingSetup: Record "Item Tracking Setup"; SourceType: Integer; SourceSubType: Integer; SourceID: Code[20]; SourceBatchName: Code[10]; SourceProdOrderLine: Integer; SourceRefNo: Integer)
    var
        LastEntryNo: Integer;
    begin
        if (WhseItemTrackingSetup."Serial No." <> '') and (Abs(QtyBase) > 1) then
            Error(Text002, WhseItemTrackingSetup."Serial No.", QtyBase);
        Clear(WhseItemTrackingLine);
        if WhseItemTrackingLine.FindLast() then
            LastEntryNo := WhseItemTrackingLine."Entry No." + 1
        else
            LastEntryNo := 1;
        WhseItemTrackingLine.Init();
        WhseItemTrackingLine."Entry No." := LastEntryNo;

        WhseItemTrackingLine.Validate("Item No.", Item);
        WhseItemTrackingLine.Validate("Location Code", Location);
        WhseItemTrackingLine.Validate("Variant Code", Variant);
        WhseItemTrackingLine.Validate("Qty. per Unit of Measure", QtyperUOM);
        WhseItemTrackingLine.Validate("Quantity (Base)", Abs(QtyBase));

        WhseItemTrackingLine.Validate("Serial No.", WhseItemTrackingSetup."Serial No.");
        WhseItemTrackingLine.Validate("Lot No.", WhseItemTrackingSetup."Lot No.");
        WhseItemTrackingLine.Validate("Package No.", WhseItemTrackingSetup."Package No.");

        WhseItemTrackingLine.Validate("Source Type", SourceType);
        WhseItemTrackingLine.Validate("Source Subtype", SourceSubType);
        WhseItemTrackingLine.Validate("Source ID", SourceID);
        WhseItemTrackingLine.Validate("Source Batch Name", SourceBatchName);
        WhseItemTrackingLine.Validate("Source Prod. Order Line", SourceProdOrderLine);
        WhseItemTrackingLine.Validate("Source Ref. No.", SourceRefNo);

        WhseItemTrackingLine.Insert(true);
    end;

    procedure CreateSalesTrackingFromReservation(SalesHeader: Record "Sales Header"; HideDialog: Boolean)
    var
        ItemTrackingDocMgt: Codeunit "Item Tracking Doc. Management";
    begin
        ItemTrackingDocMgt.CopyDocTrkgFromReservation(DATABASE::"Sales Header", SalesHeader."Document Type".AsInteger(), SalesHeader."No.", HideDialog);
    end;

    procedure PostPositiveAdjustmentWithItemTracking(Item: Record Item; LocationCode: Code[10]; VariantCode: Code[10]; Qty: Decimal; PostingDate: Date; SerialNo: Code[50]; LotNo: Code[50])
    var
        ReservEntry: Record "Reservation Entry";
        ItemJournalTemplate: Record "Item Journal Template";
        ItemJournalLine: Record "Item Journal Line";
        ItemJournalBatch: Record "Item Journal Batch";
    begin
        LibraryInventory.CreateItemJournalBatchByType(ItemJournalBatch, ItemJournalTemplate.Type::Item);
        LibraryInventory.CreateItemJournalLine(ItemJournalLine, ItemJournalBatch, Item, LocationCode, VariantCode, PostingDate,
          ItemJournalLine."Entry Type"::"Positive Adjmt.", Qty, 0);
        CreateItemJournalLineItemTracking(ReservEntry, ItemJournalLine, SerialNo, LotNo, Qty);
        LibraryInventory.PostItemJournalBatch(ItemJournalBatch);
    end;

    [InternalEvent(true)]
    local procedure OnItemTracking(RecRef: RecordRef; var ReservEntry: Record "Reservation Entry"; ItemTrackingSetup: Record "Item Tracking Setup"; QtyBase: Decimal; var IsHandled: Boolean)
    begin
    end;
}

