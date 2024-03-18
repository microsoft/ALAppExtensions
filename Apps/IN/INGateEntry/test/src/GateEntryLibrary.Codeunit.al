codeunit 18627 "Gate Entry Library"
{
    var
        LibraryWarehouse: Codeunit "Library - Warehouse";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryInventory: Codeunit "Library - Inventory";
        Assert: Codeunit Assert;
        LibrarySales: Codeunit "Library - Sales";
        LibraryRandom: Codeunit "Library - Random";
        LibraryERM: Codeunit "Library - ERM";
        Storage: Dictionary of [Text, Code[20]];
        LocationCodeLbl: Label 'LocationCode';
        FromLocationLbl: Label 'FromLocation';
        ToLocationLbl: Label 'ToLocation';

    procedure CreateGateEntryDocument(
        var GateEntryHeader: Record "Gate Entry Header";
        EntryType: Enum "Gate Entry Type";
        GateEntrySourceType: Enum "Gate Entry Source Type")
    var
        GateEntryLine: Record "Gate Entry Line";
        Location: Record Location;
        LocationCode: Code[10];
    begin
        LocationCode := LibraryWarehouse.CreateLocationWithInventoryPostingSetup(Location);
        Storage.Set(LocationCodeLbl, LocationCode);

        CreateGateEntryHeader(GateEntryHeader, EntryType, GateEntrySourceType);

        CreateGateEntryLine(GateEntryHeader, GateEntryLine, GateEntrySourceType);
    end;

    procedure PostGateEnty(Var GateEntryHeader: Record "Gate Entry Header"): Code[20]
    var
        PostedGateEntryHeader: Record "Posted Gate Entry Header";
        GateEntryPostYesNo: Codeunit "Gate Entry- Post (Yes/No)";
    begin
        GateEntryPostYesNo.Run(GateEntryHeader);
        PostedGateEntryHeader.SetRange("Gate Entry No.", GateEntryHeader."No.");
        PostedGateEntryHeader.FindFirst();
        exit(PostedGateEntryHeader."No.");
    end;

    procedure CreateGateEntryLine(
        GateEntryHeader: Record "Gate Entry Header";
        var GateEntryLine: Record "Gate Entry Line";
        GateEntrySourceType: Enum "Gate Entry Source Type")
    var
        LibraryUtility: Codeunit "Library - Utility";
        RecordRef: RecordRef;
    begin
        GateEntryLine.SetRange("Entry Type", GateEntryLine."Entry Type");
        GateEntryLine.SetRange("Gate Entry No.", GateEntryHeader."No.");
        if not GateEntryLine.findset() then begin
            GateEntryLine.Init();
            RecordRef.GetTable(GateEntryLine);
            GateEntryLine.Validate("Entry Type", GateEntryHeader."Entry Type");
            GateEntryLine.Validate("Gate Entry No.", GateEntryHeader."No.");
            GateEntryLine.Validate("Line No.", LibraryUtility.GetNewLineNo(RecordRef, GateEntryLine.FieldNo("Line No.")));
            GateEntryLine.Insert(true);
            GateEntryLine.Validate("Challan No.", LibraryRandom.RandText(20));
            GateEntryLine.Validate("Challan Date", WorkDate());
            GateEntryLine.Validate("Source Type", GateEntrySourceType);
            GateEntryLine.Validate("Source No.", GetGateEntryInwardSourceNo(GateEntryHeader, GateEntryLine));
            GateEntryLine.Modify(true);
        end;
    end;

    procedure CreateGateEntryHeader(
        var GateEntryHeader: Record "Gate Entry Header";
        EntryType: Enum "Gate Entry Type";
        GateEntrySourceType: Enum "Gate Entry Source Type")
    var
        Location: Record Location;
        LocationCode: Code[10];
    begin
        LocationCode := LibraryWarehouse.CreateLocationWithInventoryPostingSetup(Location);
        Storage.Set(LocationCodeLbl, LocationCode);

        GateEntryHeader.Init();
        GateEntryHeader.Validate("Entry Type", EntryType);
        GateEntryHeader.Validate("No.", CreateGateEntrySeries(GateEntryHeader));
        GateEntryHeader.Insert(true);
        GateEntryHeader.Validate("Posting No.", CreateNoSeries());
        GateEntryHeader.Validate("Location Code", LocationCode);
        GateEntryHeader.Validate("Station From/To", LocationCode);
        GateEntryHeader.Validate(Description, Location.Name);
        GateEntryHeader.Validate("Item Description", LibraryRandom.RandText(20));
        GateEntryHeader.Validate("Document Date", WorkDate());
        GateEntryHeader.Validate("Document Time", Time);
        GateEntryHeader.Validate("LR/RR No.", LibraryRandom.RandText(20));
        GateEntryHeader.Validate("LR/RR Date", WorkDate());
        GateEntryHeader.Validate("Vehicle No.", LibraryRandom.RandText(20));
        GateEntryHeader.Modify(true);
    end;

    procedure VerifyPostedGateEntries(DocumentNo: Code[20])
    var
        PostedGateEntryHeader: Record "Posted Gate Entry Header";
        PostedGateEntryLine: Record "Posted Gate Entry Line";
    begin
        PostedGateEntryHeader.SetRange("No.", DocumentNo);
        PostedGateEntryHeader.FindFirst();
        Assert.RecordIsNotEmpty(PostedGateEntryHeader);

        PostedGateEntryLine.SetRange(PostedGateEntryLine."Gate Entry No.", PostedGateEntryHeader."No.");
        PostedGateEntryLine.FindFirst();
        Assert.RecordIsNotEmpty(PostedGateEntryLine);
    end;

    procedure VerifyAttachedGateEntries(DocumentNo: Code[20])
    var
        GateEntryAttachment: Record "Gate Entry Attachment";
    begin
        GateEntryAttachment.SetRange(GateEntryAttachment."Source No.", DocumentNo);
        GateEntryAttachment.FindFirst();
        Assert.RecordIsNotEmpty(GateEntryAttachment);
    end;

    procedure DeleteAttachedGateEntries(DocumentNo: Code[20])
    var
        GateEntryAttachment: Record "Gate Entry Attachment";
    begin
        GateEntryAttachment.SetRange(GateEntryAttachment."Source No.", DocumentNo);
        GateEntryAttachment.FindFirst();
        GateEntryAttachment.DeleteAll();
    end;

    procedure VerifyDeletedAttachedGateEntries(DocumentNo: Code[20])
    var
        GateEntryAttachment: Record "Gate Entry Attachment";
    begin
        GateEntryAttachment.SetRange(GateEntryAttachment."Source No.", DocumentNo);
        Assert.RecordIsEmpty(GateEntryAttachment);
    end;

    procedure VerifyPostedAttachedGateEntries(DocumentNo: Code[20])
    var
        PostedGateEntryAttachment: Record "Posted Gate Entry Attachment";
        PostedGateEntryLine: Record "Posted Gate Entry Line";
    begin
        PostedGateEntryAttachment.SetRange(PostedGateEntryAttachment."Source No.", DocumentNo);
        PostedGateEntryAttachment.FindFirst();
        Assert.RecordIsNotEmpty(PostedGateEntryAttachment);

        PostedGateEntryLine.SetRange(PostedGateEntryLine."Source No.", DocumentNo);
        PostedGateEntryLine.FindFirst();
        Assert.AreEqual(PostedGateEntryLine.Status::Close, PostedGateEntryLine.Status, 'hey');
        Assert.RecordIsNotEmpty(PostedGateEntryLine);
    end;

    procedure CreateNoSeries(): Code[20]
    var
        Noseries: Code[20];
    begin
        Noseries := LibraryERM.CreateNoSeriesCode();
        exit(Noseries);
    end;

    procedure GetTransferOrderNo(var TransferHeader: Record "Transfer Header"): Code[20]
    var
        FromLocation: Record Location;
        ToLocation: Record Location;
        InTransitLocation: Record Location;
        TransferLine: Record "Transfer Line";
    begin
        LibraryWarehouse.CreateTransferLocations(FromLocation, ToLocation, InTransitLocation);
        Storage.Set(FromLocationLbl, FromLocation.Code);
        Storage.Set(ToLocationLbl, ToLocation.Code);
        LibraryWarehouse.CreateTransferHeader(TransferHeader, FromLocation.Code, ToLocation.Code, InTransitLocation.Code);
        LibraryWarehouse.CreateTransferLine(TransferHeader, TransferLine, CreateItemWithInventory(), LibraryRandom.RandInt(1));

        TransferLine.Validate("Qty. in Transit", LibraryRandom.RandInt(1));
        TransferLine.Validate("Qty. to Receive", LibraryRandom.RandInt(1));
        TransferLine.Validate("Qty. to Ship", LibraryRandom.RandInt(1));
        TransferLine.Modify(true);
        exit(TransferHeader."No.");
    end;

    procedure GetPurchaseOrderNo(var PurchaseHeader: Record "Purchase Header"): Code[20]
    var
        PurchaseLine: Record "Purchase Line";
        VendorNo: Code[20];
    begin
        VendorNo := LibraryPurchase.CreateVendorNo();
        LibraryPurchase.CreatePurchaseDocumentWithItem(
            PurchaseHeader,
            PurchaseLine,
            PurchaseHeader."Document Type"::Order,
            VendorNo,
            LibraryInventory.
            CreateItemNo(), LibraryRandom.RandInt(1), (Storage.Get(LocationCodeLbl)), WorkDate());
        exit(PurchaseHeader."No.")
    end;

    procedure GetSalesDocNo(var SalesHeader: Record "Sales Header";
        DocType: Enum "Sales Document Type"): Code[20]
    var
        SalesLine: Record "Sales Line";
        CustomerNo: Code[20];
    begin
        CustomerNo := LibrarySales.CreateCustomerNo();
        LibrarySales.CreateSalesDocumentWithItem(
            SalesHeader,
            SalesLine,
            DocType,
            CustomerNo,
            LibraryInventory.
            CreateItemNo(), LibraryRandom.RandInt(1), (Storage.Get(LocationCodeLbl)), WorkDate());
        exit(SalesHeader."No.");
    end;

    procedure GetSalesShipmentNo(
        DocumentNo: Code[20];
        GateEntryHeader: Record "Gate Entry Header"): Code[20]
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
    begin
        SalesShipmentHeader.SetRange("Order No.", DocumentNo);
        SalesShipmentHeader.SetRange("Location Code", GateEntryHeader."Location Code");
        if SalesShipmentHeader.FindFirst() then
            exit(SalesShipmentHeader."No.")
        else
            exit;
    end;

    procedure GetPurchaseReturnShpmntNo(
        DocumentNo: Code[20];
        GateEntryHeader: Record "Gate Entry Header"): Code[20]
    var
        ReturnShipmentHeader: Record "Return Shipment Header";
    begin
        ReturnShipmentHeader.SetRange("Return Order No.", DocumentNo);
        ReturnShipmentHeader.SetRange("Location Code", GateEntryHeader."Location Code");
        if ReturnShipmentHeader.FindFirst() then
            exit(ReturnShipmentHeader."No.")
        else
            exit;
    end;

    procedure GetTransferShipmentNo(
       DocumentNo: Code[20]): Code[20]
    var
        TransferShipmentHeader: Record "Transfer Shipment Header";
    begin
        TransferShipmentHeader.SetRange("Transfer Order No.", DocumentNo);
        if TransferShipmentHeader.FindFirst() then
            exit(TransferShipmentHeader."No.")
        else
            exit;
    end;

    procedure GetTransferReceiptNo(
      DocumentNo: Code[20]): Code[20]
    var
        TransferReceiptHeader: Record "Transfer Receipt Header";
    begin
        TransferReceiptHeader.SetRange("Transfer Order No.", DocumentNo);
        if TransferReceiptHeader.FindFirst() then
            exit(TransferReceiptHeader."No.")
        else
            exit;
    end;

    procedure GetPurchaseInvGateEntryLines(DocumentNo: Code[20])
    var
        PurchaseInvoice: TestPage "Purchase Invoice";
    begin
        PurchaseInvoice.OpenEdit();
        PurchaseInvoice.Filter.SetFilter("No.", DocumentNo);
        PurchaseInvoice."Get Gate Entry Lines".Invoke();
    end;

    procedure GetPurchaseOrdGateEntryLines(DocumentNo: Code[20])
    var
        PurchaseOrder: TestPage "Purchase Order";
    begin
        PurchaseOrder.OpenEdit();
        PurchaseOrder.Filter.SetFilter("No.", DocumentNo);
        PurchaseOrder."Get Gate Entry Lines".Invoke();
    end;

    procedure GetTransferGateEntryLines(DocumentNo: Code[20])
    var
        TransferOrder: TestPage "Transfer Order";
    begin
        TransferOrder.OpenEdit();
        TransferOrder.Filter.SetFilter("No.", DocumentNo);
        TransferOrder."Get Gate Entry Lines".Invoke();
    end;

    procedure VerifyAttachedPurchaseOrdGateEntryLines(DocumentNo: Code[20])
    var
        PurchaseOrder: TestPage "Purchase Order";
    begin
        PurchaseOrder.OpenEdit();
        PurchaseOrder.Filter.SetFilter("No.", DocumentNo);
        PurchaseOrder."Attached Gate Entry".Invoke();
    end;

    procedure VerifyAttachedTransferOrdGateEntryLines(DocumentNo: Code[20])
    var
        TransferOrder: TestPage "Transfer Order";
    begin
        TransferOrder.OpenEdit();
        TransferOrder.Filter.SetFilter("No.", DocumentNo);
        TransferOrder."Attached Gate Entry".Invoke();
    end;

    procedure VerifyAttachedPurchaseInvGateEntryLines(DocumentNo: Code[20])
    var
        PurchaseInvoice: TestPage "Purchase Invoice";
    begin
        PurchaseInvoice.OpenEdit();
        PurchaseInvoice.Filter.SetFilter("No.", DocumentNo);
        PurchaseInvoice."Attached Gate Entry".Invoke();
    end;

    procedure VerifyAttachedSalesShpmtGateEntryLines(DocumentNo: Code[20])
    var
        PostedSalesShipment: TestPage "Posted Sales Shipment";
    begin
        PostedSalesShipment.OpenEdit();
        PostedSalesShipment.Filter.SetFilter("No.", DocumentNo);
        PostedSalesShipment."Attached Gate Entry".Invoke();
    end;

    procedure GetSalesRetrnOrdGateEntryLines(DocumentNo: Code[20])
    var
        SalesReturnOrder: TestPage "Sales Return Order";
    begin
        SalesReturnOrder.OpenEdit();
        SalesReturnOrder.Filter.SetFilter("No.", DocumentNo);
        SalesReturnOrder."Get Gate Entry Lines".Invoke();
    end;

    procedure VerifyAttachedSalesRetrnOrdGateEntryLines(DocumentNo: Code[20])
    var
        SalesReturnOrder: TestPage "Sales Return Order";
    begin
        SalesReturnOrder.OpenEdit();
        SalesReturnOrder.Filter.SetFilter("No.", DocumentNo);
        SalesReturnOrder."Attached Gate Entry".Invoke();
    end;

    procedure VerifyAttachedTransferShpmtGateEntryLines(DocumentNo: Code[20])
    var
        PostedTransferShipment: TestPage "Posted Transfer Shipment";
    begin
        PostedTransferShipment.OpenEdit();
        PostedTransferShipment.Filter.SetFilter("No.", DocumentNo);
        PostedTransferShipment."Attached Gate Entry".Invoke();
    end;

    procedure VerifyAttachedTransferRcptGateEntryLines(DocumentNo: Code[20])
    var
        PostedTransferReceipt: TestPage "Posted Transfer Receipt";
    begin
        PostedTransferReceipt.OpenEdit();
        PostedTransferReceipt.Filter.SetFilter("No.", DocumentNo);
        PostedTransferReceipt."Attached Gate Entry".Invoke();
    end;

    procedure CreateWarehouseReceiptDocument(var WarehouseReceiptHeader: Record "Warehouse Receipt Header")
    var
        WarehouseEmployee: Record "Warehouse Employee";
        Location: Record Location;
    begin
        LibraryWarehouse.CreateWarehouseEmployee(WarehouseEmployee, (Storage.Get(LocationCodeLbl)), false);
        LibraryWarehouse.CreateWarehouseReceiptHeader(WarehouseReceiptHeader);
        Location.Get(Storage.Get(LocationCodeLbl));
        Location.Validate("Require Receive", true);
        Location.Modify(true);
        WarehouseReceiptHeader.Validate("Location Code", Location.Code);
        WarehouseReceiptHeader.Modify();
    end;

    local procedure CreateGateEntrySeries(GateEntryHeader: Record "Gate Entry Header"): Code[20]
    var
        InventorySetup: Record "Inventory Setup";
        NoSeries: Codeunit "No. Series";
    begin
        if GateEntryHeader."No." = '' then begin
            InventorySetup.Get();
            case GateEntryHeader."Entry Type" of
                GateEntryHeader."Entry Type"::Inward:
                    if InventorySetup."Inward Gate Entry Nos." <> '' then
                        exit(NoSeries.GetNextNo(InventorySetup."Inward Gate Entry Nos."))
                    else
                        exit(CreateNoSeries());
                GateEntryHeader."Entry Type"::Outward:
                    if InventorySetup."Outward Gate Entry Nos." <> '' then
                        exit(NoSeries.GetNextNo(InventorySetup."Outward Gate Entry Nos."))
                    else
                        exit(CreateNoSeries());
            end;
        end;
    end;

    local procedure GetGateEntryInwardSourceNo(
            GateEntryHeader: Record "Gate Entry Header";
            GateEntryLine: Record "Gate Entry Line"): Code[20]
    var
        PurchaseHeader: Record "Purchase Header";
        SalesHeader: Record "Sales Header";
        TransferHeader: Record "Transfer Header";
        DocumentNo: Code[20];
    begin
        GateEntryHeader.Get(GateEntryLine."Entry Type", GateEntryLine."Gate Entry No.");
        case GateEntryLine."Source Type" of
            GateEntryLine."Source Type"::"Sales Shipment":
                begin
                    DocumentNo := GetSalesDocNo(SalesHeader, SalesHeader."Document Type"::Order);
                    LibrarySales.PostSalesDocument(SalesHeader, true, false);
                    exit(GetSalesShipmentNo(DocumentNo, GateEntryHeader));
                end;
            GateEntryLine."Source Type"::"Sales Return Order":
                exit(GetSalesDocNo(SalesHeader, SalesHeader."Document Type"::"Return Order"));
            GateEntryLine."Source Type"::"Purchase Order":
                exit(GetPurchaseOrderNo(PurchaseHeader));
            GateEntryLine."Source Type"::"Purchase Return Shipment":
                begin
                    LibraryPurchase.CreatePurchaseReturnOrder(PurchaseHeader);
                    PurchaseHeader.Validate("Location Code", (Storage.Get(LocationCodeLbl)));
                    PurchaseHeader.Modify(true);
                    DocumentNo := PurchaseHeader."No.";
                    LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, false);
                    exit(GetPurchaseReturnShpmntNo(DocumentNo, GateEntryHeader));
                end;
            GateEntryLine."Source Type"::"Transfer Receipt":
                exit(GetTransferOrderNo(TransferHeader));
            GateEntryLine."Source Type"::"Transfer Shipment":
                begin
                    DocumentNo := GetTransferOrderNo(TransferHeader);
                    LibraryWarehouse.PostTransferOrder(TransferHeader, true, false);
                    exit(GetTransferShipmentNo(DocumentNo));
                end;
        end;
    end;

    local procedure CreateItemWithInventory(): Code[20]
    var
        Item: Record Item;
        ItemJournalLine: Record "Item Journal Line";
    begin
        LibraryInventory.CreateItem(Item);
        LibraryInventory.CreateItemJournalLineInItemTemplate(
            ItemJournalLine, Item."No.",
            (Storage.Get(FromLocationLbl)),
            '', LibraryRandom.RandInt(100));
        LibraryInventory.CreateItemJournalLineInItemTemplate(
            ItemJournalLine, Item."No.",
            (Storage.Get(ToLocationLbl)),
            '', LibraryRandom.RandInt(100));
        CODEUNIT.Run(CODEUNIT::"Item Jnl.-Post Batch", ItemJournalLine);
        exit(Item."No.");
    end;
}