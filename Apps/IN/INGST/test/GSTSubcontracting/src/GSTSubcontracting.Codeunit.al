codeunit 18479 "GST Subcontracting"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    var
        SourceCode: Record "Source Code";
        SourceCodeSetup: Record "Source Code Setup";
        LibraryERM: Codeunit "Library - ERM";
        LibraryMfg: Codeunit "Library - Manufacturing";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryPlanning: Codeunit "Library - Planning";
        LibraryRandom: Codeunit "Library - Random";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryItemTracking: Codeunit "Library - Item Tracking";
        LibraryAssert: Codeunit "Library Assert";
        LibraryGST: Codeunit "Library GST";
        LibraryWarehouse: Codeunit "Library - Warehouse";
        Assert: Codeunit Assert;
        UpdateSubcontractDetails: Codeunit "Update Subcontract Details";
        ComponentPerArray: array[20] of Decimal;
        Storage: Dictionary of [Text, Text];
        StorageBoolean: Dictionary of [Text, Boolean];
        WithDimensionLbl: Label 'WithDimensionLbl', Locked = true;
        XLocPANNoTok: Label 'LocPANNo', Locked = true;
        XCompanyLocationStateCodeTok: Label 'CompanyLocationStateCode', Locked = true;
        XCompanyLocationCodeTok: Label 'CompanyLocationCode', Locked = true;
        XGSTGroupCodeTok: Label 'GSTGroupCode', Locked = true;
        XHSNSACCodeTok: Label 'HSNSACCode', Locked = true;
        XVendorStateCodeTok: Label 'VendorStateCode', Locked = true;
        XVendorNoTok: Label 'VendorNo', Locked = true;
        WorkCenterNoTok: Label 'WorkCenterNo', Locked = true;
        XBinCodeTok: Label 'BinCode', Locked = true;
        XMainItemNoTok: Label 'MainItemNo', Locked = true;
        XComponentItemNoTok: Label 'ComponentItemNo', Locked = true;
        XFromStateCodeTok: Label 'FromStateCode', Locked = true;
        XToStateCodeTok: Label 'ToStateCode', Locked = true;
        DeliveryChallanNoLbl: Label 'DeliveryChallanNo', Locked = true;
        FieldVerifyErr: Label '%1 is incorrect in %2.', Comment = '%1 and %2 = Field Caption and Table Caption';
        SuccessMsg: Label 'Items sent against Delivery Challan No. = %1.', Comment = '%1 = Delivery Challan No.';
        NotPostedErr: Label 'Items not sent.', locked = true;
        ValueMismatchErr: Label '%1 in the Production Order does not match the Item Ledger Entry applied to.', Comment = '%1 = Field Caption';

    [Test]
    [HandlerFunctions('TaxRatePageHandler,DeliveryChallanSentMsgHandler')]
    procedure SubconOrderToUnregVendIntraStateSendItem()
    var
        ProductionOrder: Record "Production Order";
        PurchaseLine: Record "Purchase Line";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [SCENARIO] [382747] Check if the system create Subcontracting Order for Unregistered Vendor and send Raw Material to Subcon Vendor Location for Jobwork.
        // [GIVEN] Setups created
        CreateGSTSubconSetups(GSTVendorType::Unregistered, GSTGroupType::Goods, true);

        // [WHEN] Create Subcontracting Order from Released Purchase Order, Send Subcon Components
        CreateSubcontractingOrderFromReleasedProdOrder(ProductionOrder, PurchaseLine);
        DeliverSubconComponents(PurchaseLine, 0);

        // [THEN] Delivery Challan and Item ledger entries are Verified
        VerifyDeliveryChallanLine(PurchaseLine);
        VerifyItemLedgerEntryComponentTransfer(PurchaseLine);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,DeliveryChallanSentMsgHandler,PostConfirmation')]
    procedure SubconOrderToUnregVendIntraStateReceiveItem()
    var
        ProductionOrder: Record "Production Order";
        PurchaseLine: Record "Purchase Line";
        PurchaseHeader: Record "Purchase Header";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        OutputQty: Decimal;
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [382878] Check if the system create Subcontracting Order for Unregistered Vendor and send Raw Material to Subcon Vendor Location for Jobwork.
        // [SCENARIO] [382885] Check if the system on subcontracting order for Unregistered Vendor Send and Receipt from Vendor and Change Status of Released Production order and Post Subcon order.
        // [GIVEN] Setups created
        CreateGSTSubconSetups(GSTVendorType::Unregistered, GSTGroupType::Goods, true);

        // [WHEN] Create Subcontracting Order from Released Purchase Order, Send Subcon Components, Receive Item, Post Purchase Order
        CreateSubcontractingOrderFromReleasedProdOrder(ProductionOrder, PurchaseLine);
        DeliverSubconComponents(PurchaseLine, 0);
        OutputQty := ReceiptSubconItem(PurchaseLine, false, false, false, WorkDate());
        ChangeStatusReleasedProdOrder(ProductionOrder);
        PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.");
        PurchaseHeader.Validate("Vendor Invoice No.", PurchaseHeader."No.");
        PurchaseHeader.Modify(true);
        DocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, false, true);

        // [THEN] Delivery Challan, Item ledger entries, G/L Entries are Verified
        VerifyDeliveryChallanLine(PurchaseLine);
        VerifyItemLedgerEntryComponentTransfer(PurchaseLine);
        VerifyItemLedgerEntryComponentConsumption(PurchaseLine);
        VerifyItemLedgerEntryItemOutput(PurchaseLine, OutputQty);
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 6);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,DeliveryChallanSentMsgHandler,PostConfirmation')]
    procedure SubconOrderToUnregVendIntraStateReceiveItemPartial()
    var
        ProductionOrder: Record "Production Order";
        PurchaseLine: Record "Purchase Line";
        PurchaseHeader: Record "Purchase Header";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        OutputQty: Decimal;
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [382905] Check if the system Create subcontracting order for Unregistered Vendor and Finish Goods Received Partially from Subcon vendor Location in before 180 days.
        // [GIVEN] Setups created
        CreateGSTSubconSetups(GSTVendorType::Unregistered, GSTGroupType::Goods, true);

        // [WHEN] Create Subcontracting Order from Released Purchase Order, Send Subcon Components, Receive Item, Post Purchase Order
        CreateSubcontractingOrderFromReleasedProdOrder(ProductionOrder, PurchaseLine);
        DeliverSubconComponents(PurchaseLine, 0);
        OutputQty := ReceiptSubconItem(PurchaseLine, true, false, false, WorkDate());
        PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.");
        PurchaseHeader.Validate("Vendor Invoice No.", PurchaseHeader."No.");
        PurchaseHeader.Modify(true);
        DocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, false, true);

        // [THEN] Delivery Challan, Item ledger entries, G/L Entries are Verified
        VerifyDeliveryChallanLine(PurchaseLine);
        VerifyItemLedgerEntryComponentTransfer(PurchaseLine);
        VerifyItemLedgerEntryComponentConsumption(PurchaseLine);
        VerifyItemLedgerEntryItemOutput(PurchaseLine, OutputQty);
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 6);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,DeliveryChallanSentMsgHandler,PostConfirmation')]
    procedure SubconOrderToUnregVendIntraStateReceiveItemPartialRejectVE()
    var
        ProductionOrder: Record "Production Order";
        PurchaseLine: Record "Purchase Line";
        PurchaseHeader: Record "Purchase Header";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        OutputQty: Decimal;
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [382927] Check if the system Create subcontracting order for Unregistered Vendor and Finish Goods Received Partially and Balance Quantity Reject on V.E.
        // [GIVEN] Setups created
        CreateGSTSubconSetups(GSTVendorType::Unregistered, GSTGroupType::Goods, true);

        // [WHEN] Create Subcontracting Order from Released Purchase Order, Send Subcon Components, Receive Item, Post Purchase Order
        CreateSubcontractingOrderFromReleasedProdOrder(ProductionOrder, PurchaseLine);
        DeliverSubconComponents(PurchaseLine, 0);
        OutputQty := ReceiptSubconItem(PurchaseLine, true, true, false, WorkDate());
        PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.");
        PurchaseHeader.Validate("Vendor Invoice No.", PurchaseHeader."No.");
        PurchaseHeader.Modify(true);
        DocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, false, true);

        // [THEN] Delivery Challan, Item ledger entries, G/L Entries are Verified
        VerifyDeliveryChallanLine(PurchaseLine);
        VerifyItemLedgerEntryComponentTransfer(PurchaseLine);
        VerifyItemLedgerEntryComponentConsumption(PurchaseLine);
        VerifyItemLedgerEntryItemOutput(PurchaseLine, OutputQty);
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 6);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,PostConfirmation,CreditMemoCreateMsgHandler')]
    procedure SubconOrderToUnregVendIntraStateReceiveItemPartialRejectVEDrNote()
    var
        ProductionOrder: Record "Production Order";
        PurchaseLine: Record "Purchase Line";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        OutputQty: Decimal;
    begin
        // [SCENARIO] [382951] Check if the system create subcontracting order for Unregistered Vendor for Finish Goods Received Partially and Create Debit Note for Quantity Reject on V.E.
        // [GIVEN] Setups created
        CreateGSTSubconSetups(GSTVendorType::Unregistered, GSTGroupType::Goods, true);

        // [WHEN] Create Subcontracting Order from Released Purchase Order, Send Subcon Components, Receive Item, Create Debit Note
        CreateSubcontractingOrderFromReleasedProdOrder(ProductionOrder, PurchaseLine);
        DeliverSubconComponents(PurchaseLine, 0);
        OutputQty := ReceiptSubconItem(PurchaseLine, true, true, false, WorkDate());
        CreateDebitNoteRejectVE(PurchaseLine);

        // [THEN] Delivery Challan, Item ledger entries, Debit Note are Verified
        VerifyDeliveryChallanLine(PurchaseLine);
        VerifyItemLedgerEntryComponentTransfer(PurchaseLine);
        VerifyItemLedgerEntryComponentConsumption(PurchaseLine);
        VerifyItemLedgerEntryItemOutput(PurchaseLine, OutputQty);
        VerifyDebitNote(PurchaseLine);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,DeliveryChallanSentMsgHandler')]
    procedure SubconOrderToRegVendIntraStateSendItem()
    var
        ProductionOrder: Record "Production Order";
        PurchaseLine: Record "Purchase Line";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [SCENARIO] [382958] Check if the system create subcontracting order for Registered Vendor and send Raw Material to Subcon Vendor Location for Jobwork - Intrastate.
        // [SCENARIO] [383240] Check if the system create subcontracting order for Registered Vendor and send Raw Material to Subcon Vendor Location for Jobwork - Intrastate.
        // [GIVEN] Setups created
        CreateGSTSubconSetups(GSTVendorType::Registered, GSTGroupType::Goods, true);

        // [WHEN] Create Subcontracting Order from Released Purchase Order, Send Subcon Components
        CreateSubcontractingOrderFromReleasedProdOrder(ProductionOrder, PurchaseLine);
        DeliverSubconComponents(PurchaseLine, 0);

        // [THEN] Delivery Challan and Item ledger entries are Verified
        VerifyDeliveryChallanLine(PurchaseLine);
        VerifyItemLedgerEntryComponentTransfer(PurchaseLine);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,DeliveryChallanSentMsgHandler,PostConfirmation')]
    procedure SubconOrderToRegVendIntraStateReceiveItem()
    var
        ProductionOrder: Record "Production Order";
        PurchaseLine: Record "Purchase Line";
        PurchaseHeader: Record "Purchase Header";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        OutputQty: Decimal;
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [383122] Check if the system on subcontracting order for Registered Vendor and after Send and Receipt from Vendor and Change Status of Released Production order and Post Subcon order.
        // [GIVEN] Setups created
        CreateGSTSubconSetups(GSTVendorType::Registered, GSTGroupType::Goods, true);

        // [WHEN] Create Subcontracting Order from Released Purchase Order, Send Subcon Components, Receive Item, Post Purchase Order
        CreateSubcontractingOrderFromReleasedProdOrder(ProductionOrder, PurchaseLine);
        DeliverSubconComponents(PurchaseLine, 0);
        OutputQty := ReceiptSubconItem(PurchaseLine, false, false, false, WorkDate());
        PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.");
        PurchaseHeader.Validate("Vendor Invoice No.", PurchaseHeader."No.");
        PurchaseHeader.Modify(true);
        DocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, false, true);
        ChangeStatusReleasedProdOrder(ProductionOrder);

        // [THEN] Delivery Challan, Item ledger entries and G/L Entries are Verified
        VerifyDeliveryChallanLine(PurchaseLine);
        VerifyItemLedgerEntryComponentTransfer(PurchaseLine);
        VerifyItemLedgerEntryComponentConsumption(PurchaseLine);
        VerifyItemLedgerEntryItemOutput(PurchaseLine, OutputQty);
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 4);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,DeliveryChallanSentMessageHandler,PostConfirmation')]
    procedure SubconOrderToRegVendIntraStateReceiveItemWithDimension()
    var
        ProductionOrder: Record "Production Order";
        PurchaseLine: Record "Purchase Line";
        PurchaseHeader: Record "Purchase Header";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        OutputQty: Decimal;
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [383122] Check if the system on subcontracting order for Registered Vendor with Dimensions and after Send and Receipt from Vendor and Change Status of Released Production order and Post Subcon order.
        // [GIVEN] Setups created
        CreateGSTSubconSetups(GSTVendorType::Registered, GSTGroupType::Goods, true);
        Initialize();

        // [WHEN] Create Subcontracting Order with Dimension from Released Purchase Order, Send Subcon Components, Receive Item, Post Purchase Order
        CreateSubcontractingOrderFromReleasedProdOrderWithDimension(ProductionOrder, PurchaseLine);
        DeliverSubconComponents(PurchaseLine, 0);
        OutputQty := ReceiptSubconItem(PurchaseLine, false, false, false, WorkDate());
        PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.");
        PurchaseHeader.Validate("Vendor Invoice No.", PurchaseHeader."No.");
        PurchaseHeader.Modify(true);
        DocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, false, true);
        ChangeStatusReleasedProdOrder(ProductionOrder);

        // [THEN] Verify Delivery Challan Lines, Item ledger entries for transfer, consumption and output and G/L Entries and finally dispose variables
        VerifyDeliveryChallanLine(PurchaseLine);
        VerifyItemLedgerEntryComponentTransfer(PurchaseLine);
        VerifyItemLedgerEntryComponentConsumption(PurchaseLine);
        VerifyItemLedgerEntryItemOutput(PurchaseLine, OutputQty);
        VerifyDimensionsOnItemLedgerEntry(ProductionOrder);
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 4);
        Dispose();
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,DeliveryChallanSentMsgHandler')]
    procedure SubconOrderToRegVendInterStateSendItem()
    var
        ProductionOrder: Record "Production Order";
        PurchaseLine: Record "Purchase Line";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [SCENARIO] [383149] Check if the system create subcontracting order for Registered Vendor and send Raw Material to Subcon Vendor Location for Jobwork - Interstate.
        // [GIVEN] Setups created
        CreateGSTSubconSetups(GSTVendorType::Registered, GSTGroupType::Goods, false);

        // [WHEN] Create Subcontracting Order from Released Purchase Order, Send Subcon Components
        CreateSubcontractingOrderFromReleasedProdOrder(ProductionOrder, PurchaseLine);
        DeliverSubconComponents(PurchaseLine, 0);

        // [THEN] Delivery Challan and Item ledger entries are Verified
        VerifyDeliveryChallanLine(PurchaseLine);
        VerifyItemLedgerEntryComponentTransfer(PurchaseLine);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,DeliveryChallanSentMsgHandler,PostConfirmation')]
    procedure SubconOrderToRegVendInterStateReceiveItem()
    var
        ProductionOrder: Record "Production Order";
        PurchaseLine: Record "Purchase Line";
        PurchaseHeader: Record "Purchase Header";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        OutputQty: Decimal;
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [383122] Check if the system on subcontracting order for Registered Vendor and after Send and Receipt from Vendor and Change Status of Released Production order and Post Subcon order.
        // [GIVEN] Setups created
        CreateGSTSubconSetups(GSTVendorType::Registered, GSTGroupType::Goods, false);

        // [WHEN] Create Subcontracting Order from Released Purchase Order, Send Subcon Components, Receive Item, Post Purchase Order
        CreateSubcontractingOrderFromReleasedProdOrder(ProductionOrder, PurchaseLine);
        DeliverSubconComponents(PurchaseLine, 0);
        OutputQty := ReceiptSubconItem(PurchaseLine, false, false, false, WorkDate());
        PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.");
        PurchaseHeader.Validate("Vendor Invoice No.", PurchaseHeader."No.");
        PurchaseHeader.Modify(true);
        DocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, false, true);
        ChangeStatusReleasedProdOrder(ProductionOrder);

        // [THEN] Delivery Challan, Item ledger entries and G/L Entries are Verified
        VerifyDeliveryChallanLine(PurchaseLine);
        VerifyItemLedgerEntryComponentTransfer(PurchaseLine);
        VerifyItemLedgerEntryComponentConsumption(PurchaseLine);
        VerifyItemLedgerEntryItemOutput(PurchaseLine, OutputQty);
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 3);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,DeliveryChallanSentMsgHandler,PostConfirmation')]
    procedure SubconOrderToRegVendInterStateReceiveItemPartial()
    var
        ProductionOrder: Record "Production Order";
        PurchaseLine: Record "Purchase Line";
        PurchaseHeader: Record "Purchase Header";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        OutputQty: Decimal;
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [383155] Check if the system Create subconracting order for Registered Vendor and Received Finish Goods from Subcon vendor Location in Before 180 days Partially.
        // [GIVEN] Setups created
        CreateGSTSubconSetups(GSTVendorType::Registered, GSTGroupType::Goods, false);

        // [WHEN] Create Subcontracting Order from Released Purchase Order, Send Subcon Components, Receive Item, Post Purchase Order
        CreateSubcontractingOrderFromReleasedProdOrder(ProductionOrder, PurchaseLine);
        DeliverSubconComponents(PurchaseLine, 0);
        OutputQty := ReceiptSubconItem(PurchaseLine, true, false, false, WorkDate());
        PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.");
        PurchaseHeader.Validate("Vendor Invoice No.", PurchaseHeader."No.");
        PurchaseHeader.Modify(true);
        DocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, false, true);

        // [THEN] Delivery Challan, Item ledger entries, G/L Entries are Verified
        VerifyDeliveryChallanLine(PurchaseLine);
        VerifyItemLedgerEntryComponentTransfer(PurchaseLine);
        VerifyItemLedgerEntryComponentConsumption(PurchaseLine);
        VerifyItemLedgerEntryItemOutput(PurchaseLine, OutputQty);
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 3);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,DeliveryChallanSentMsgHandler,PostConfirmation')]
    procedure SubconOrderToRegVendInterStateReceiveItemPartialRejectCE()
    var
        ProductionOrder: Record "Production Order";
        PurchaseLine: Record "Purchase Line";
        PurchaseHeader: Record "Purchase Header";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        OutputQty: Decimal;
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [383156] Check if the system on subcontracting order for Registered Vendor and Received Finish Goods Partially from Subcon Vendor Location and Qty Reject on C.E.
        // [GIVEN] Setups created
        CreateGSTSubconSetups(GSTVendorType::Registered, GSTGroupType::Goods, false);

        // [WHEN] Create Subcontracting Order from Released Purchase Order, Send Subcon Components, Receive Item, Post Purchase Order
        CreateSubcontractingOrderFromReleasedProdOrder(ProductionOrder, PurchaseLine);
        DeliverSubconComponents(PurchaseLine, 0);
        OutputQty := ReceiptSubconItem(PurchaseLine, true, false, true, WorkDate());
        PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.");
        PurchaseHeader.Validate("Vendor Invoice No.", PurchaseHeader."No.");
        PurchaseHeader.Modify(true);
        DocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, false, true);

        // [THEN] Delivery Challan, Item ledger entries, G/L Entries are Verified
        VerifyDeliveryChallanLine(PurchaseLine);
        VerifyItemLedgerEntryComponentTransfer(PurchaseLine);
        VerifyItemLedgerEntryComponentConsumption(PurchaseLine);
        VerifyItemLedgerEntryItemOutput(PurchaseLine, OutputQty);
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 3);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,DeliveryChallanSentMsgHandler,PostConfirmation')]
    procedure SubconOrderToRegVendInterStateReturnItem()
    var
        ProductionOrder: Record "Production Order";
        PurchaseLine: Record "Purchase Line";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [SCENARIO] [383170] Check if the system on subcontracting order for Registered Vendor and Send and Return 100% from Subcon Vendor Location.
        // [GIVEN] Setups created
        CreateGSTSubconSetups(GSTVendorType::Registered, GSTGroupType::Goods, false);

        // [WHEN] Create Subcontracting Order from Released Purchase Order, Send Subcon Components, Return Components
        CreateSubcontractingOrderFromReleasedProdOrder(ProductionOrder, PurchaseLine);
        DeliverSubconComponents(PurchaseLine, 0);
        ReturnSubconItem(PurchaseLine);

        // [THEN] Delivery Challan and Item ledger entries are Verified
        VerifyDeliveryChallanLine(PurchaseLine);
        VerifyItemLedgerEntryComponentTransfer(PurchaseLine);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,DeliveryChallanSentMsgHandler,GSTLiabilityLinePageHandler')]
    procedure SubconOrderToRegVendIntraStateCreateGSTLiability()
    var
        ProductionOrder: Record "Production Order";
        PurchaseLine: Record "Purchase Line";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        DeliveryChallanNo: Code[20];
        GSTLastDate: Date;
    begin
        // [SCENARIO] [382983] Check if the system GST Amount on subconracting order for Registered Vendor and Received Finish Goods from Subcon vendor Location in After 180 days and create GST Liability Intrastate.
        // [GIVEN] Setups created
        CreateGSTSubconSetups(GSTVendorType::Registered, GSTGroupType::Goods, true);

        // [WHEN] Create Subcontracting Order from Released Purchase Order, Send Subcon Components, Receive Item, Post Purchase Order
        CreateSubcontractingOrderFromReleasedProdOrder(ProductionOrder, PurchaseLine);
        DeliverSubconComponents(PurchaseLine, 0);

        GetGSTLastDateDeliveryChallan(PurchaseLine, DeliveryChallanNo, GSTLastDate);
        GSTLastDate := CalcDate('<1D>', GSTLastDate);
        CreateGSTLiability(PurchaseLine."Buy-from Vendor No.", PurchaseLine."Document No.", DeliveryChallanNo, GSTLastDate);

        // [THEN] Delivery Challan and Item ledger entries are Verified
        VerifyDeliveryChallanLine(PurchaseLine);
        VerifyItemLedgerEntryComponentTransfer(PurchaseLine);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,DeliveryChallanSentMsgHandler,GSTLiabilityLinePageHandler,PostConfirmation')]
    procedure SubconOrderToRegVendIntraStatePostGSTLiability()
    var
        ProductionOrder: Record "Production Order";
        PurchaseLine: Record "Purchase Line";
        PurchaseHeader: Record "Purchase Header";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        OutputQty: Decimal;
        DocumentNo: Code[20];
        DeliveryChallanNo: Code[20];
        GSTLastDate: Date;
    begin
        // [SCENARIO] [383100] Check if the system GST Amount on subcontracting order for Registered Vendor and Received Finish Goods from Subcon vendor Location in After 180 days and Posted GST Liability.
        // [GIVEN] Setups created
        CreateGSTSubconSetups(GSTVendorType::Registered, GSTGroupType::Goods, true);

        // [WHEN] Create Subcontracting Order from Released Purchase Order, Send Subcon Components, Receive Item, Post Purchase Order
        CreateSubcontractingOrderFromReleasedProdOrder(ProductionOrder, PurchaseLine);
        DeliverSubconComponents(PurchaseLine, 0);

        GetGSTLastDateDeliveryChallan(PurchaseLine, DeliveryChallanNo, GSTLastDate);
        GSTLastDate := CalcDate('<1D>', GSTLastDate);
        CreateGSTLiability(PurchaseLine."Buy-from Vendor No.", PurchaseLine."Document No.", DeliveryChallanNo, GSTLastDate);
        PostGSTLiability();

        OutputQty := ReceiptSubconItem(PurchaseLine, false, false, false, GSTLastDate);
        PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.");
        PurchaseHeader.Validate("Vendor Invoice No.", PurchaseHeader."No.");
        PurchaseHeader.Modify(true);
        DocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, false, true);
        ChangeStatusReleasedProdOrder(ProductionOrder);

        // [THEN] Delivery Challan, Item ledger entries and G/L Entries are Verified
        VerifyDeliveryChallanLine(PurchaseLine);
        VerifyItemLedgerEntryComponentTransfer(PurchaseLine);
        VerifyItemLedgerEntryComponentConsumption(PurchaseLine);
        VerifyItemLedgerEntryItemOutput(PurchaseLine, OutputQty);
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 4);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,DeliveryChallanSentMsgHandler,GSTLiabilityLinePageHandler')]
    procedure SubconOrderToRegVendInterStateCreateGSTLiability()
    var
        ProductionOrder: Record "Production Order";
        PurchaseLine: Record "Purchase Line";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        DeliveryChallanNo: Code[20];
        GSTLastDate: Date;
    begin
        // [SCENARIO] [383187] Check if the system GST Amount on subconracting order for Registered Vendor and Received Finish Goods from Subcon vendor Location in After 180 days and create GST Liability Interstate.
        // [GIVEN] Setups created
        CreateGSTSubconSetups(GSTVendorType::Registered, GSTGroupType::Goods, false);

        // [WHEN] Create Subcontracting Order from Released Purchase Order, Send Subcon Components, Receive Item, Post Purchase Order
        CreateSubcontractingOrderFromReleasedProdOrder(ProductionOrder, PurchaseLine);
        DeliverSubconComponents(PurchaseLine, 0);

        GetGSTLastDateDeliveryChallan(PurchaseLine, DeliveryChallanNo, GSTLastDate);
        GSTLastDate := CalcDate('<1D>', GSTLastDate);
        CreateGSTLiability(PurchaseLine."Buy-from Vendor No.", PurchaseLine."Document No.", DeliveryChallanNo, GSTLastDate);

        // [THEN] Delivery Challan and Item ledger entries are Verified
        VerifyDeliveryChallanLine(PurchaseLine);
        VerifyItemLedgerEntryComponentTransfer(PurchaseLine);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,DeliveryChallanSentMsgHandler,GSTLiabilityLinePageHandler')]
    procedure SubconOrderToRegVendInterStatePostGSTLiability()
    var
        ProductionOrder: Record "Production Order";
        PurchaseLine: Record "Purchase Line";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        DeliveryChallanNo: Code[20];
        GSTLastDate: Date;
    begin
        // [SCENARIO] [383245] Check if the system GST Amount on subcontracting order for Registered Vendor and Received Finish Goods from Subcon vendor Location in After 180 days and Posted GST Liability.
        // [GIVEN] Setups created
        CreateGSTSubconSetups(GSTVendorType::Registered, GSTGroupType::Goods, false);

        // [WHEN] Create Subcontracting Order from Released Purchase Order, Send Subcon Components, Receive Item, Post Purchase Order
        CreateSubcontractingOrderFromReleasedProdOrder(ProductionOrder, PurchaseLine);
        DeliverSubconComponents(PurchaseLine, 0);

        GetGSTLastDateDeliveryChallan(PurchaseLine, DeliveryChallanNo, GSTLastDate);
        GSTLastDate := CalcDate('<1D>', GSTLastDate);
        CreateGSTLiability(PurchaseLine."Buy-from Vendor No.", PurchaseLine."Document No.", DeliveryChallanNo, GSTLastDate);
        PostGSTLiability();

        // [THEN] Delivery Challan and Item ledger entries are Verified
        VerifyDeliveryChallanLine(PurchaseLine);
        VerifyItemLedgerEntryComponentTransfer(PurchaseLine);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,DeliveryChallanSentMsgHandler,GSTLiabilityLinePageHandler,PostConfirmation')]
    procedure SubconOrderToRegVendInterStatePostGSTLiabilityReceiveItem()
    var
        ProductionOrder: Record "Production Order";
        PurchaseLine: Record "Purchase Line";
        PurchaseHeader: Record "Purchase Header";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        OutputQty: Decimal;
        DocumentNo: Code[20];
        DeliveryChallanNo: Code[20];
        GSTLastDate: Date;
    begin
        // [SCENARIO] [383247] Check if the system on subcontracting order for Registered Vendor and after Send and Receipt from Vendor and Change Status of Released Production order and Post Subcon order.
        // [GIVEN] Setups created
        CreateGSTSubconSetups(GSTVendorType::Registered, GSTGroupType::Goods, false);

        // [WHEN] Create Subcontracting Order from Released Purchase Order, Send Subcon Components, Receive Item, Post Purchase Order
        CreateSubcontractingOrderFromReleasedProdOrder(ProductionOrder, PurchaseLine);
        DeliverSubconComponents(PurchaseLine, 0);

        GetGSTLastDateDeliveryChallan(PurchaseLine, DeliveryChallanNo, GSTLastDate);
        GSTLastDate := CalcDate('<1D>', GSTLastDate);
        CreateGSTLiability(PurchaseLine."Buy-from Vendor No.", PurchaseLine."Document No.", DeliveryChallanNo, GSTLastDate);
        PostGSTLiability();

        OutputQty := ReceiptSubconItem(PurchaseLine, false, false, false, GSTLastDate);
        PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.");
        PurchaseHeader.Validate("Vendor Invoice No.", PurchaseHeader."No.");
        PurchaseHeader.Modify(true);
        DocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, false, true);
        ChangeStatusReleasedProdOrder(ProductionOrder);

        // [THEN] Delivery Challan, Item ledger entries and G/L Entries are Verified
        VerifyDeliveryChallanLine(PurchaseLine);
        VerifyItemLedgerEntryComponentTransfer(PurchaseLine);
        VerifyItemLedgerEntryComponentConsumption(PurchaseLine);
        VerifyItemLedgerEntryItemOutput(PurchaseLine, OutputQty);
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 3);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,DeliveryChallanSentMsgHandler,PostConfirmation')]
    procedure SubconOrderToRegVendIntraStateReceiveItemWithTracking()
    var
        ProductionOrder: Record "Production Order";
        PurchaseLine: Record "Purchase Line";
        PurchaseHeader: Record "Purchase Header";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        OutputQty: Decimal;
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [383420] Check if the system Receipt on subcontracting order for Registered  Vendor and FG Received from Subcon Vendor Location with Item Tracking.
        // [GIVEN] Setups created
        CreateGSTSubconSetups(GSTVendorType::Registered, GSTGroupType::Goods, true);
        UpdateItemTrackingCode();

        // [WHEN] Create Subcontracting Order from Released Purchase Order, Send Subcon Components, Receive Item, Post Purchase Order
        CreateSubcontractingOrderFromReleasedProdOrder(ProductionOrder, PurchaseLine);
        DeliverSubconComponents(PurchaseLine, 0);
        UpdateProdOrderLineItemTracking(PurchaseLine);
        OutputQty := ReceiptSubconItem(PurchaseLine, false, false, false, WorkDate());
        PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.");
        PurchaseHeader.Validate("Vendor Invoice No.", PurchaseHeader."No.");
        PurchaseHeader.Modify(true);
        DocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, false, true);
        ChangeStatusReleasedProdOrder(ProductionOrder);

        // [THEN] Delivery Challan, Item ledger entries and G/L Entries are Verified
        VerifyDeliveryChallanLine(PurchaseLine);
        VerifyItemLedgerEntryComponentTransfer(PurchaseLine);
        VerifyItemLedgerEntryComponentConsumption(PurchaseLine);
        VerifyItemLedgerEntryItemOutput(PurchaseLine, OutputQty);
        LibraryGST.VerifyGLEntries(PurchaseHeader."Document Type"::Invoice, DocumentNo, 4);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,DeliveryChallanSentMsgHandler')]
    procedure SubconOrderToUnregVendIntraStateSendItemRework()
    var
        ProductionOrder: Record "Production Order";
        PurchaseLine: Record "Purchase Line";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [SCENARIO] [383467] Check if the system Rework Qty on subcontracting order for Registered Vendor for Finish Goods send to  Subcon Vendor Location
        // [GIVEN] Setups created
        CreateGSTSubconSetups(GSTVendorType::Unregistered, GSTGroupType::Goods, true);

        // [WHEN] Create Subcontracting Order from Released Purchase Order, Send Subcon Components
        CreateSubcontractingOrderFromReleasedProdOrder(ProductionOrder, PurchaseLine);
        DeliverSubconComponents(PurchaseLine, 1);

        // [THEN] Delivery Challan and Item ledger entries are Verified
        VerifyDeliveryChallanLine(PurchaseLine);
        VerifyItemLedgerEntryComponentTransfer(PurchaseLine);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,DeliveryChallanSentMsgHandler')]
    procedure SubconOrderMultipleToUnregVendIntraStateSendItem()
    var
        ProductionOrderFirst: Record "Production Order";
        ProductionOrderSecond: Record "Production Order";
        PurchaseLineFirst: Record "Purchase Line";
        PurchaseLineSecond: Record "Purchase Line";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        MultipleSubconOrderDetailsNo: Code[20];
    begin
        // [SCENARIO] [383317] Check if the system create Delivery Challan against Multiple Sub contracting Orders for Jobwork Vendor.
        // [GIVEN] Setups created
        CreateGSTSubconSetups(GSTVendorType::Unregistered, GSTGroupType::Goods, true);

        // [WHEN] Create Multiple Subcontracting Order from Released Purchase Order, Send Subcon Components
        CreateSubcontractingOrderFromReleasedProdOrder(ProductionOrderFirst, PurchaseLineFirst);
        CreateSubcontractingOrderFromReleasedProdOrder(ProductionOrderSecond, PurchaseLineSecond);
        DeliverSubconComponentsMultiple(PurchaseLineFirst, PurchaseLineSecond, MultipleSubconOrderDetailsNo);

        // [THEN] Delivery Challan and Item ledger entries are Verified
        VerifyDeliveryChallanLine(PurchaseLineFirst);
        VerifyItemLedgerEntryComponentTransfer(PurchaseLineFirst);
        VerifyDeliveryChallanLine(PurchaseLineSecond);
        VerifyItemLedgerEntryComponentTransfer(PurchaseLineSecond);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,PostConfirmation,DeliveryChallanSentMsgHandler')]
    procedure SubconOrderMultipleToUnregVendIntraStateReceiveItem()
    var
        ProductionOrderFirst: Record "Production Order";
        ProductionOrderSecond: Record "Production Order";
        PurchaseLineFirst: Record "Purchase Line";
        PurchaseLineSecond: Record "Purchase Line";
        PurchaseHeaderFirst: Record "Purchase Header";
        PurchaseHeaderSecond: Record "Purchase Header";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        MultipleSubconOrderDetailsNo: Code[20];
        OutputQtyFirst: Decimal;
        OutputQtySecond: Decimal;
        DocumentNoFirst: Code[20];
        DocumentNoSecond: Code[20];
    begin
        // [SCENARIO] [383325] Check if the system create Single Receipt against Multiple Delivery Challans for Sub contracting Orders from Jobwork Vendor.
        // [GIVEN] Setups created
        CreateGSTSubconSetups(GSTVendorType::Unregistered, GSTGroupType::Goods, true);

        // [WHEN] Create Multiple Subcontracting Order from Released Purchase Order, Send Subcon Components
        CreateSubcontractingOrderFromReleasedProdOrder(ProductionOrderFirst, PurchaseLineFirst);
        CreateSubcontractingOrderFromReleasedProdOrder(ProductionOrderSecond, PurchaseLineSecond);
        DeliverSubconComponentsMultiple(PurchaseLineFirst, PurchaseLineSecond, MultipleSubconOrderDetailsNo);
        ReceiptSubconItemMultiple(PurchaseLineFirst, PurchaseLineSecond, MultipleSubconOrderDetailsNo, WorkDate(), OutputQtyFirst, OutputQtySecond);

        PurchaseHeaderFirst.Get(PurchaseLineFirst."Document Type", PurchaseLineFirst."Document No.");
        PurchaseHeaderFirst.Validate("Vendor Invoice No.", PurchaseHeaderFirst."No.");
        PurchaseHeaderFirst.Modify(true);
        DocumentNoFirst := LibraryPurchase.PostPurchaseDocument(PurchaseHeaderFirst, false, true);

        PurchaseHeaderSecond.Get(PurchaseLineSecond."Document Type", PurchaseLineSecond."Document No.");
        PurchaseHeaderSecond.Validate("Vendor Invoice No.", PurchaseHeaderSecond."No.");
        PurchaseHeaderSecond.Modify(true);
        DocumentNoSecond := LibraryPurchase.PostPurchaseDocument(PurchaseHeaderSecond, false, true);

        // [THEN] Delivery Challan, Item ledger entries and G/L Entries are Verified
        VerifyDeliveryChallanLine(PurchaseLineFirst);
        VerifyItemLedgerEntryComponentTransfer(PurchaseLineFirst);
        VerifyDeliveryChallanLine(PurchaseLineSecond);
        VerifyItemLedgerEntryComponentTransfer(PurchaseLineSecond);
        VerifyItemLedgerEntryComponentConsumption(PurchaseLineFirst);
        VerifyItemLedgerEntryItemOutput(PurchaseLineFirst, OutputQtyFirst);
        VerifyItemLedgerEntryComponentConsumption(PurchaseLineSecond);
        VerifyItemLedgerEntryItemOutput(PurchaseLineSecond, OutputQtySecond);
        LibraryGST.VerifyGLEntries(PurchaseHeaderFirst."Document Type"::Invoice, DocumentNoFirst, 6);
        LibraryGST.VerifyGLEntries(PurchaseHeaderSecond."Document Type"::Invoice, DocumentNoSecond, 6);
    end;

    [Test]
    procedure CheckPurchRcptHeader()
    var
        PurchRcptHeader: Record "Purch. Rcpt. Header";
    begin
        if PurchRcptHeader.Get('107061') then
            if PurchRcptHeader.Subcontracting then
                exit
            else
                Error('Notfound');
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure SubconOrderToRegVendIntraStateItemAndDelete()
    var
        ProductionOrder: Record "Production Order";
        PurchaseLine: Record "Purchase Line";
        PurchaseLine2: Record "Purchase Line";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [SCENARIO] [456861] Subcontracting order no. and subcontractor Code are not being deleted in the released production order if users delete the subcontracting order without doing any process of send and receive
        // [GIVEN] Setups created
        CreateGSTSubconSetups(GSTVendorType::Registered, GSTGroupType::Goods, true);

        // [GIVEN] Create Subcontracting Order from Released Purchase Order
        CreateSubcontractingOrderFromReleasedProdOrder(ProductionOrder, PurchaseLine);

        // [WHEN] Validate Subcontracting Order Line befor delete
        UpdateSubcontractDetails.ValidateOrUpdateBeforeSubConOrderLineDelete(PurchaseLine);

        // [THEN] Delete Subcontracting Order Line
        PurchaseLine.Delete(true);

        // [VERIFY] Verify it no longer exists
        Assert.IsFalse(PurchaseLine2.Get(PurchaseLine."Document Type", PurchaseLine."Document No.", PurchaseLine."Line No."), 'Subcontracting Order Line still exists after deletion');
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,CreditMemoCreateMsgHandler')]
    procedure SubconOrderLineDeleteNotAllowedAfterDeliverSubConItem()
    var
        ProductionOrder: Record "Production Order";
        PurchaseLine: Record "Purchase Line";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        DeliveryChallanLineExistsErr: Label 'Line cannot be deleted. Delivery Challan exist for Subcontracting Order no. %1, Line No. %2', Comment = '%1 = Subcontracting Order No., %2 = and Line No.';
    begin
        // [SCENARIO] [456858] System is allowing to delete Subcontracting orders or Lines if a delivery challan is already created against the subcontracting order but didn’t receive finished goods from the subcontractor location
        // [GIVEN] Setups created
        CreateGSTSubconSetups(GSTVendorType::Registered, GSTGroupType::Goods, true);

        // [WHEN] Create Subcontracting Order from Released Purchase Order
        CreateSubcontractingOrderFromReleasedProdOrder(ProductionOrder, PurchaseLine);

        // [THEN] Deliver Subcontracting Component
        DeliverSubconComponents(PurchaseLine, 0);

        // [VERIFY] Assert Error Verified to Validate Purchase Order Delete Subcontracting Order Line
        asserterror UpdateSubcontractDetails.ValidateOrUpdateBeforeSubConOrderLineDelete(PurchaseLine);
        Assert.ExpectedError(StrSubstNo(DeliveryChallanLineExistsErr, PurchaseLine."Document No.", PurchaseLine."Line No."));
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,PostConfirmation,DeliveryChallanSentMsgHandler')]
    procedure SubconOrderToCheckOutputDateInItemLedgerEntry()
    var
        ProductionOrderFirst: Record "Production Order";
        ProductionOrderSecond: Record "Production Order";
        PurchaseLineFirst: Record "Purchase Line";
        PurchaseLineSecond: Record "Purchase Line";
        PurchaseHeaderFirst: Record "Purchase Header";
        PurchaseHeaderSecond: Record "Purchase Header";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
        MultipleSubconOrderDetailsNo: Code[20];
        OutputQtyFirst: Decimal;
        OutputDateFirst: Date;
        OutputDateSecond: Date;
        OutputQtySecond: Decimal;
        DocumentNoFirst: Code[20];
        DocumentNoSecond: Code[20];
    begin
        // [SCENARIO] [469048] Posting date of Purchase receipt and Order subcon receipt dfifers when Order subcon receipt has a different posting date
        // [GIVEN] Setups created
        CreateGSTSubconSetups(GSTVendorType::Registered, GSTGroupType::Goods, true);

        // [WHEN] Create Multiple Subcontracting Order from Released Purchase Order, Send Subcon Components
        CreateSubcontractingOrderFromReleasedProdOrder(ProductionOrderFirst, PurchaseLineFirst);
        CreateSubcontractingOrderFromReleasedProdOrder(ProductionOrderSecond, PurchaseLineSecond);
        DeliverSubconComponentsMultiple(PurchaseLineFirst, PurchaseLineSecond, MultipleSubconOrderDetailsNo);
        ReceiptSubconItemMultipleWithOutputDate(PurchaseLineFirst, PurchaseLineSecond, MultipleSubconOrderDetailsNo, WorkDate(), OutputQtyFirst, OutputQtySecond, OutputDateFirst, OutputDateSecond);

        PurchaseHeaderFirst.Get(PurchaseLineFirst."Document Type", PurchaseLineFirst."Document No.");
        PurchaseHeaderFirst.Validate("Vendor Invoice No.", PurchaseHeaderFirst."No.");
        PurchaseHeaderFirst.Modify(true);
        DocumentNoFirst := LibraryPurchase.PostPurchaseDocument(PurchaseHeaderFirst, false, true);

        PurchaseHeaderSecond.Get(PurchaseLineSecond."Document Type", PurchaseLineSecond."Document No.");
        PurchaseHeaderSecond.Validate("Vendor Invoice No.", PurchaseHeaderSecond."No.");
        PurchaseHeaderSecond.Modify(true);
        DocumentNoSecond := LibraryPurchase.PostPurchaseDocument(PurchaseHeaderSecond, false, true);

        // [THEN] Delivery Challan, Item ledger entries and G/L Entries are Verified
        VerifyDeliveryChallanLine(PurchaseLineFirst);
        VerifyItemLedgerEntryComponentTransfer(PurchaseLineFirst);
        VerifyDeliveryChallanLine(PurchaseLineSecond);
        VerifyItemLedgerEntryComponentTransfer(PurchaseLineSecond);
        VerifyItemLedgerEntryComponentConsumption(PurchaseLineFirst);
        VerifyItemLedgerEntryItemOutput(PurchaseLineFirst, OutputQtyFirst);
        VerifyItemLedgerEntryOutputDate(PurchaseLineFirst, OutputDateFirst);
        VerifyItemLedgerEntryComponentConsumption(PurchaseLineSecond);
        VerifyItemLedgerEntryItemOutput(PurchaseLineSecond, OutputQtySecond);
        VerifyItemLedgerEntryOutputDate(PurchaseLineSecond, OutputDateSecond);
        LibraryGST.VerifyGLEntries(PurchaseHeaderFirst."Document Type"::Invoice, DocumentNoFirst, 4);
        LibraryGST.VerifyGLEntries(PurchaseHeaderSecond."Document Type"::Invoice, DocumentNoSecond, 4);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,DeliveryChallanSentMsgHandler')]
    procedure SubconOrderWithBinCodeVendIntraStateSendItem()
    var
        ProductionOrder: Record "Production Order";
        PurchaseLine: Record "Purchase Line";
        GSTGroupType: Enum "GST Group Type";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [SCENARIO] [487490] Check if the system create Subcontracting Order for Unregistered Vendor and send Raw Material to Subcon Vendor Location for Jobwork.
        // [GIVEN] Setups created
        CreateGSTSubconSetupsWithBinMandatory(GSTVendorType::Unregistered, GSTGroupType::Goods, true);

        // [WHEN] Create Subcontracting Order from Released Purchase Order, Send Subcon Components
        CreateSubcontractingOrderWithBinCodeFromReleasedProdOrder(ProductionOrder, PurchaseLine);
        DeliverSubconComponents(PurchaseLine, 0);

        // [THEN] Delivery Challan and Item ledger entries are Verified
        VerifyDeliveryChallanLine(PurchaseLine);
        VerifyItemLedgerEntryComponentTransfer(PurchaseLine);
    end;

    local procedure CreateGSTSubconSetups(
        GSTVendorType: Enum "GST Vendor Type";
                           GSTGroupType: Enum "GST Group Type";
                           IntraState: Boolean)
    begin
        // Source Codes
        UpdateSourceCodes();

        // General Ledger Setup
        UpdateGLSetup();

        // Purchases and Payables Setup
        UpdatePurchSetup();

        // Company Information
        UpdateCompanyInformation();

        // Inventory Setup
        UpdateInventorySetup();

        // GST Group and HSN Code
        CreateGSTGroupHSNCode(GSTGroupType);

        // Subcontracting Vendor
        CreateSubconVendor(GSTVendorType, IntraState);

        // Work Center
        CreateWorkCenter();

        // Main Item with Production BOM and Routing
        CreateMainItemWithProdBOMAndRouting();

        // Create Inventory for Components
        CreateComponentInventory();

        // Create Inventory for Main Item for Rework
        CreateMainItemInventory();

        // Tax Rate and Posting Setup
        CreateTaxRateAndPostingSetup(IntraState);
    end;

    local procedure UpdateSourceCodes()
    begin
        LibraryERM.CreateSourceCode(SourceCode);
        SourceCodeSetup.Get();
        SourceCodeSetup."GST Liability - Job Work" := SourceCode.Code;
        SourceCodeSetup."GST Receipt - Job Work" := SourceCode.Code;
        SourceCodeSetup.Modify();
    end;

    local procedure UpdateGLSetup()
    var
        GLSetup: Record "General Ledger Setup";
        GLAccount: Record "G/L Account";
    begin
        GLSetup.Get();
        if GLSetup."Sub-Con Interim Account" = '' then begin
            LibraryERM.CreateGLAccount(GLAccount);
            GLSetup."Sub-Con Interim Account" := GLAccount."No.";
            GLSetup.Modify();
        end;
    end;

    local procedure UpdatePurchSetup()
    var
        PurchSetup: Record "Purchases & Payables Setup";
    begin
        PurchSetup.Get();
        if PurchSetup."Subcontracting Order Nos." = '' then
            PurchSetup."Subcontracting Order Nos." := (LibraryERM.CreateNoSeriesCode());
        if PurchSetup."Delivery Challan Nos." = '' then
            PurchSetup."Delivery Challan Nos." := (LibraryERM.CreateNoSeriesCode());
        if PurchSetup."Posted Delivery Challan Nos." = '' then
            PurchSetup."Posted Delivery Challan Nos." := (LibraryERM.CreateNoSeriesCode());
        if PurchSetup."Posted SC Comp. Rcpt. Nos." = '' then
            PurchSetup."Posted SC Comp. Rcpt. Nos." := (LibraryERM.CreateNoSeriesCode());
        if PurchSetup."Multiple Subcon. Order Det Nos" = '' then
            PurchSetup."Multiple Subcon. Order Det Nos" := (LibraryERM.CreateNoSeriesCode());
        PurchSetup.Modify();
    end;

    local procedure UpdateCompanyInformation()
    var
        Location: Record Location;
        CompanyInformation: Record "Company information";
        CompanyLocationCode: Code[10];
        CompanyLocationStateCode: Code[10];
        LocPANNo: Code[20];
        LocationGSTRegNo: Code[15];
    begin
        CompanyInformation.Get();
        if CompanyInformation."P.A.N. No." = '' then begin
            CompanyInformation."P.A.N. No." := LibraryGST.CreatePANNos();
            CompanyInformation.Modify();
        end else
            LocPANNo := CompanyInformation."P.A.N. No.";

        LocPANNo := CompanyInformation."P.A.N. No.";
        CompanyLocationStateCode := LibraryGST.CreateInitialSetup();
        Storage.Set(XLocPANNoTok, LocPANNo);
        Storage.Set(XCompanyLocationStateCodeTok, CompanyLocationStateCode);

        LocationGSTRegNo := LibraryGST.CreateGSTRegistrationNos(CompanyLocationStateCode, LocPANNo);
        if CompanyInformation."GST Registration No." = '' then begin
            CompanyInformation."GST Registration No." := LocationGSTRegNo;
            CompanyInformation.Modify(true);
        end;

        // Company Location
        CompanyLocationCode := LibraryGST.CreateLocationSetup(CompanyLocationStateCode, LocationGSTRegNo, false);
        Location.Get(CompanyLocationCode);
        Location."GST Liability Invoice" := (LibraryERM.CreateNoSeriesCode());
        Location.Modify();
        Storage.Set(XCompanyLocationCodeTok, CompanyLocationCode);
    end;

    local procedure UpdateInventorySetup()
    var
        InventorySetup: Record "Inventory Setup";
    begin
        InventorySetup.Get();
        InventorySetup."Sub. Component Location" := (Storage.Get(XCompanyLocationCodeTok));
        InventorySetup."Job Work Return Period" := 180;
        InventorySetup.Modify();
    end;

    local procedure CreateGSTGroupHSNCode(GSTGroupType: Enum "GST Group Type")
    var
        GSTGroup: Record "GST Group";
        HSNSAC: Record "HSN/SAC";
        GSTGroupCode: Code[20];
        HSNSACCode: Code[10];
        HsnSacType: Enum "GST Goods And Services Type";
    begin
        GSTGroupCode := LibraryGST.CreateGSTGroup(GSTGroup, GSTGroupType, GSTGroup."GST Place Of Supply"::"Bill-to Address", false);
        Storage.Set(XGSTGroupCodeTok, GSTGroupCode);

        HSNSACCode := LibraryGST.CreateHSNSACCode(HSNSAC, GSTGroupCode, HsnSacType::HSN);
        Storage.Set(XHSNSACCodeTok, HSNSACCode);
    end;

    local procedure CreateSubconVendor(GSTVendorType: Enum "GST Vendor Type"; IntraState: Boolean)
    var
        TaxComponent: Record "Tax Component";
        GSTComponentCode: Text[30];
        VendorNo: Code[20];
        VendorStateCode: Code[10];
        LocPANNo: Code[20];
        CompanyLocationStateCode: Code[10];
    begin
        LocPANNo := (Storage.Get(XLocPANNoTok));
        CompanyLocationStateCode := (Storage.Get(XCompanyLocationStateCodeTok));

        if IntraState then begin
            VendorNo := LibraryGST.CreateVendorSetup();
            UpdateSubconVendorSetupWithGST(VendorNo, GSTVendorType, false, CompanyLocationStateCode, LocPANNo);
            InitializeTaxRateParameters(IntraState, CompanyLocationStateCode, CompanyLocationStateCode);
            CreateGSTComponentAndPostingSetup(IntraState, CompanyLocationStateCode, TaxComponent, GSTComponentCode);
        end else begin
            VendorStateCode := LibraryGST.CreateGSTStateCode();
            VendorNo := LibraryGST.CreateVendorSetup();
            UpdateSubconVendorSetupWithGST(VendorNo, GSTVendorType, false, VendorStateCode, LocPANNo);
            Storage.Set(XVendorStateCodeTok, VendorStateCode);
            if GSTVendorType in [GSTVendorType::Import, GSTVendorType::SEZ] then
                InitializeTaxRateParameters(IntraState, '', CompanyLocationStateCode)
            else begin
                InitializeTaxRateParameters(IntraState, VendorStateCode, CompanyLocationStateCode);
                CreateGSTComponentAndPostingSetup(IntraState, VendorStateCode, TaxComponent, GSTComponentCode);
            end;
        end;

        Storage.Set(XVendorNoTok, VendorNo);
    end;

    local procedure UpdateSubconVendorSetupWithGST(
        VendorNo: Code[20];
        GSTVendorType: Enum "GST Vendor Type";
                           AssociateEnterprise: Boolean;
                           StateCode: Code[10];
                           PANNo: Code[20])
    var
        Vendor: Record Vendor;
        State: Record State;
        SubconLocationCode: Code[10];
    begin
        Vendor.Get(VendorNo);

        if (GSTVendorType <> GSTVendorType::Import) then begin
            State.Get(StateCode);
            Vendor.Validate("State Code", StateCode);
            Vendor.Validate("P.A.N. No.", PANNo);
            if not ((GSTVendorType = GSTVendorType::" ") or (GSTVendorType = GSTVendorType::Unregistered)) then
                Vendor.Validate("GST Registration No.", LibraryGST.GenerateGSTRegistrationNo(State."State Code (GST Reg. No.)", PANNo));
        end else
            vendor.Validate("Associated Enterprises", AssociateEnterprise);

        Vendor.Validate("GST Vendor Type", GSTVendorType);
        Vendor.Subcontractor := true;
        SubconLocationCode := CreateSubconLocation(Vendor);
        vendor."Vendor Location" := SubconLocationCode;
        Vendor.Modify(true);
    end;

    local procedure CreateSubconLocation(Vendor: Record Vendor): Code[10]
    var
        Location: Record Location;
        SubconLocationCode: Code[10];
        LocationGSTRegNo: Code[15];
        LocPANNo: Code[10];
    begin
        LocPANNo := (Storage.Get(XLocPANNoTok));
        LocationGSTRegNo := LibraryGST.CreateGSTRegistrationNos(Vendor."State Code", LocPANNo);
        SubconLocationCode := LibraryGST.CreateLocationSetup(Vendor."State Code", LocationGSTRegNo, false);

        Location.Get(SubconLocationCode);
        Location."Subcontracting Location" := true;
        Location."Subcontractor No." := Vendor."No.";
        Location.Modify();

        exit(SubconLocationCode);
    end;

    local procedure CreateWorkCenter()
    var
        WorkCenter: Record "Work Center";
        VendorNo: Code[20];
    begin
        VendorNo := (Storage.Get(XVendorNoTok));

        LibraryMfg.CreateWorkCenter(WorkCenter);
        WorkCenter.Validate("Direct Unit Cost", LibraryRandom.RandInt(5));
        WorkCenter.Validate("Unit Cost Calculation", WorkCenter."Unit Cost Calculation"::Units);
        WorkCenter.Validate("Subcontractor No.", VendorNo);
        WorkCenter.Modify();

        Storage.Set(WorkCenterNoTok, WorkCenter."No.");
    end;

    local procedure CreateMainItemWithProdBOMAndRouting()
    var
        Item: Record Item;
        VATPostingSetup: Record "VAT Posting Setup";
        GenProdPostingGroup: Record "Gen. Product Posting Group";
        MainItemNo: Code[20];
        ComponentItemNo: Code[20];
        ProductionBOMNo: Code[20];
        RoutingNo: Code[20];
    begin
        MainItemNo := LibraryGST.CreateItemWithGSTDetails(VATPostingSetup, (Storage.Get(XGSTGroupCodeTok)), (Storage.Get(XHSNSACCodeTok)), true, false);
        ComponentItemNo := LibraryGST.CreateItemWithGSTDetails(VATPostingSetup, (Storage.Get(XGSTGroupCodeTok)), (Storage.Get(XHSNSACCodeTok)), true, false);
        ProductionBOMNo := CreateProdBOM(ComponentItemNo);
        RoutingNo := CreateRouting(Storage.Get(WorkCenterNoTok));

        Item.Get(MainItemNo);
        Item."Replenishment System" := Item."Replenishment System"::"Prod. Order";
        Item."Production BOM No." := ProductionBOMNo;
        Item."Routing No." := RoutingNo;
        Item.Modify();

        Item.Get(ComponentItemNo);
        LibraryGST.CreateGeneralPostingSetup('', Item."Gen. Prod. Posting Group");
        GenProdPostingGroup.Get(Item."Gen. Prod. Posting Group");
        GenProdPostingGroup."Auto Insert Default" := false;
        GenProdPostingGroup.Modify();

        Storage.Set(XMainItemNoTok, MainItemNo);
        Storage.Set(XComponentItemNoTok, ComponentItemNo);
    end;

    local procedure CreateProdBOM(ComponentItemNo: Code[20]): Code[20]
    var
        ProductionBOMHeader: Record "Production BOM Header";
        ProductionBOMNo: Code[20];
    begin
        ProductionBOMNo := LibraryMfg.CreateCertifiedProductionBOM(ProductionBOMHeader, ComponentItemNo, 1);
        exit(ProductionBOMNo);
    end;

    local procedure CreateRouting(WorkCenterNo: Code[20]): Code[20]
    var
        RoutingHeader: Record "Routing Header";
        RoutingLine: Record "Routing Line";
        CapacityTypeRouting: Enum "Capacity Type Routing";
        OperationNo: Code[10];
    begin
        OperationNo := Format(10 + LibraryRandom.RandInt(10));
        LibraryMfg.CreateRoutingHeader(RoutingHeader, RoutingHeader.Type::Serial);
        LibraryMfg.CreateRoutingLine(RoutingHeader, RoutingLine, '', OperationNo, CapacityTypeRouting::"Work Center", WorkCenterNo);
        RoutingHeader.Validate(Status, RoutingHeader.Status::Certified);
        RoutingHeader.Modify();
        exit(RoutingHeader."No.");
    end;

    local procedure CreateComponentInventory()
    var
        ComponentItemNo: Code[20];
        CompanyLocationCode: Code[10];
    begin
        ComponentItemNo := (Storage.Get(XComponentItemNoTok));
        CompanyLocationCode := (Storage.Get(XCompanyLocationCodeTok));
        CreateInventory(ComponentItemNo, CompanyLocationCode, 100, LibraryRandom.RandInt(100));
    end;

    local procedure CreateMainItemInventory()
    var
        MainItemNo: Code[20];
        CompanyLocationCode: Code[10];
    begin
        MainItemNo := (Storage.Get(XComponentItemNoTok));
        CompanyLocationCode := (Storage.Get(XCompanyLocationCodeTok));
        CreateInventory(MainItemNo, CompanyLocationCode, 10, 0);
    end;

    local procedure CreateInventory(ItemNo: Code[20]; LocationCode: Code[10]; Quantity: Decimal; UnitCost: Decimal)
    var
        ItemJournalLine: Record "Item Journal Line";
    begin
        LibraryInventory.CreateItemJournalLineInItemTemplate(ItemJournalLine, ItemNo, LocationCode, '', Quantity);
        if UnitCost > 0 then begin
            ItemJournalLine.Validate("Unit Amount", UnitCost);
            ItemJournalLine.Modify();
        end;

        Codeunit.Run(Codeunit::"Item Jnl.-Post Line", ItemJournalLine);
    end;

    local procedure CreateTaxRateAndPostingSetup(IntraState: Boolean)
    var
        TaxComponent: Record "Tax Component";
        GSTComponentCode: Text[30];
        CompanyLocationStateCode: Code[10];
    begin
        CompanyLocationStateCode := (Storage.Get(XCompanyLocationStateCodeTok));
        CreateTaxRate();
        CreateGSTComponentAndPostingSetup(IntraState, CompanyLocationStateCode, TaxComponent, GSTComponentCode);
    end;

    local procedure CreateGSTComponentAndPostingSetup(
        IntraState: Boolean;
        LocationStateCode: Code[10];
        TaxComponent: Record "Tax Component";
        GSTComponentCode: Text[30])
    begin
        if IntraState then begin
            GSTComponentCode := 'CGST';
            LibraryGST.CreateGSTComponent(TaxComponent, GSTComponentCode);
            LibraryGST.CreateGSTPostingSetup(TaxComponent, LocationStateCode);

            GSTComponentCode := 'SGST';
            LibraryGST.CreateGSTComponent(TaxComponent, GSTComponentCode);
            LibraryGST.CreateGSTPostingSetup(TaxComponent, LocationStateCode);
        end else begin
            GSTComponentCode := 'IGST';
            LibraryGST.CreateGSTComponent(TaxComponent, GSTComponentCode);
            LibraryGST.CreateGSTPostingSetup(TaxComponent, LocationStateCode);
        end;
    end;

    local procedure InitializeTaxRateParameters(IntraState: Boolean; FromState: Code[10]; ToState: Code[10])
    var
        GSTTaxPercent: Decimal;
    begin
        Storage.Set(XFromStateCodeTok, FromState);
        Storage.Set(XToStateCodeTok, ToState);
        GSTTaxPercent := LibraryRandom.RandDecInRange(10, 18, 0);
        if IntraState then begin
            ComponentPerArray[1] := (GSTTaxPercent / 2);
            ComponentPerArray[2] := (GSTTaxPercent / 2);
        end else
            ComponentPerArray[3] := GSTTaxPercent;
    end;

    local procedure CreateTaxRate()
    var
        GSTSetup: Record "GST Setup";
        TaxTypes: TestPage "Tax Types";
    begin
        if not GSTSetup.Get() then
            exit;

        TaxTypes.OpenEdit();
        TaxTypes.Filter.SetFilter(Code, GSTSetup."GST Tax Type");
        TaxTypes.TaxRates.Invoke();
    end;

    local procedure UpdateItemTrackingCode()
    var
        MainItem: Record Item;
        MainItemNo: Code[20];
    begin
        MainItemNo := (Storage.Get(XMainItemNoTok));
        MainItem.Get(MainItemNo);
        LibraryItemTracking.AddSerialNoTrackingInfo(MainItem);
    end;

    local procedure CreateSubcontractingOrderFromReleasedProdOrder(var ProductionOrder: Record "Production Order"; var PurchaseLine: Record "Purchase Line")
    var
        ProdOrderLine: Record "Prod. Order Line";
        ProdOrderRoutingLine: Record "Prod. Order Routing Line";
        ProdOrderComponent: Record "Prod. Order Component";
        RequisitionLine: Record "Requisition Line";
        Item: Record Item;
        SubOrderComponentList: Record "Sub Order Component List";
        ProdOrderStatus: Enum "Production order Status";
        ProdOrderSourceType: Enum "Prod. Order Source Type";
        MainItemNo: Code[20];
        CompanyLocationCode: Code[10];
    begin
        MainItemNo := (Storage.Get(XMainItemNoTok));
        CompanyLocationCode := (Storage.Get(XCompanyLocationCodeTok));
        CreateAndRefreshProductionOrder(ProductionOrder, ProdOrderStatus::Released, ProdOrderSourceType::Item, MainItemNo, 10, CompanyLocationCode);

        ProdOrderLine.Reset();
        ProdOrderLine.SetRange(Status, ProdOrderStatus::Released);
        ProdOrderLine.SetRange("Prod. Order No.", ProductionOrder."No.");
        if ProdOrderLine.FindFirst() then begin
            ProdOrderComponent.SetRange(Status, ProdOrderLine.Status);
            ProdOrderComponent.SetRange("Prod. Order No.", ProdOrderLine."Prod. Order No.");
            ProdOrderComponent.SetRange("Prod. Order Line No.", ProdOrderLine."Line No.");
            if ProdOrderComponent.FindSet() then
                repeat
                    ProdOrderComponent.Validate("Unit Cost", LibraryRandom.RandInt(100));
                    ProdOrderComponent.Modify();
                until ProdOrderComponent.Next() = 0;

            ProdOrderRoutingLine.SetRange(Status, ProdOrderLine.Status);
            ProdOrderRoutingLine.SetRange("Prod. Order No.", ProdOrderLine."Prod. Order No.");
            ProdOrderRoutingLine.SetRange("Routing Reference No.", ProdOrderLine."Routing Reference No.");
            ProdOrderRoutingLine.SetRange("Routing No.", ProdOrderLine."Routing No.");
            if ProdOrderRoutingLine.FindSet() then
                LibraryMfg.CalculateSubcontractOrderWithProdOrderRoutingLine(ProdOrderRoutingLine);
        end;

        FindRequisitionLineForProductionOrder(RequisitionLine, ProductionOrder);
        LibraryPlanning.CarryOutAMSubcontractWksh(RequisitionLine);

        Item.Get(MainItemNo);
        PurchaseLine.SetRange("No.", MainItemNo);
        PurchaseLine.SetRange("Prod. Order No.", ProductionOrder."No.");
        PurchaseLine.FindFirst();
        PurchaseLine.Validate("Gen. Prod. Posting Group", Item."Gen. Prod. Posting Group");
        PurchaseLine.Validate("VAT Prod. Posting Group", Item."VAT Prod. Posting Group");
        PurchaseLine.Validate("Qty. per Unit of Measure", 1);
        PurchaseLine.Validate(Quantity, PurchaseLine.Quantity);
        PurchaseLine.Validate(PurchaseLine."Qty. to Receive", PurchaseLine.Quantity);
        PurchaseLine.Validate(PurchaseLine."Qty. to Invoice", PurchaseLine.Quantity);
        PurchaseLine.Modify();
        Storage.Set(DeliveryChallanNoLbl, PurchaseLine."Document No.");

        SubOrderComponentList.Reset();
        SubOrderComponentList.SetRange("Document No.", PurchaseLine."Document No.");
        SubOrderComponentList.SetRange("Document Line No.", PurchaseLine."Line No.");
        SubOrderComponentList.ModifyAll("Company Location", CompanyLocationCode);
    end;

    procedure CreateAndRefreshProductionOrder(
        var ProductionOrder: Record "Production Order";
        ProdOrderStatus: Enum "Production Order Status";
                             SourceType: Enum "Prod. Order Source Type";
                             SourceNo: Code[20];
                             Quantity: Decimal;
                             CompanyLocationCode: Code[10])
    begin
        LibraryMfg.CreateProductionOrder(ProductionOrder, ProdOrderStatus, SourceType, SourceNo, Quantity);
        ProductionOrder.Validate("Location Code", CompanyLocationCode);
        ProductionOrder.Modify();
        LibraryMfg.RefreshProdOrder(ProductionOrder, false, true, true, true, false);
    end;

    local procedure CreateSubcontractingOrderFromReleasedProdOrderWithDimension(var ProductionOrder: Record "Production Order"; var PurchaseLine: Record "Purchase Line")
    var
        RequisitionLine: Record "Requisition Line";

        SubOrderComponentList: Record "Sub Order Component List";
        ProdOrderStatus: Enum "Production order Status";
        ProdOrderSourceType: Enum "Prod. Order Source Type";
        MainItemNo: Code[20];
        CompanyLocationCode: Code[10];
    begin
        MainItemNo := (Storage.Get(XMainItemNoTok));
        CompanyLocationCode := (Storage.Get(XCompanyLocationCodeTok));
        CreateAndRefreshProductionOrderWithDimension(ProductionOrder, ProdOrderStatus::Released, ProdOrderSourceType::Item, MainItemNo, 10, CompanyLocationCode);
        CreateAndValidateProdOrderComponent(ProductionOrder);

        FindRequisitionLineForProductionOrder(RequisitionLine, ProductionOrder);
        LibraryPlanning.CarryOutAMSubcontractWksh(RequisitionLine);
        CreateAndInsertPurchaseLineForSubContractingOrder(ProductionOrder, PurchaseLine, MainItemNo);

        SubOrderComponentList.Reset();
        SubOrderComponentList.SetRange("Document No.", PurchaseLine."Document No.");
        SubOrderComponentList.SetRange("Document Line No.", PurchaseLine."Line No.");
        SubOrderComponentList.ModifyAll("Company Location", CompanyLocationCode);
    end;

    procedure CreateAndRefreshProductionOrderWithDimension(
        var ProductionOrder: Record "Production Order";
        ProdOrderStatus: Enum "Production Order Status";
                             SourceType: Enum "Prod. Order Source Type";
                             SourceNo: Code[20];
                             Quantity: Decimal;
                             CompanyLocationCode: Code[10])
    var
        DimensionValue: Record "Dimension Value";
    begin
        LibraryMfg.CreateProductionOrder(ProductionOrder, ProdOrderStatus, SourceType, SourceNo, Quantity);
        ProductionOrder.Validate("Location Code", CompanyLocationCode);
        DimensionValue.SetRange("Global Dimension No.", 1);
        if DimensionValue.FindFirst() then
            ProductionOrder.Validate("Shortcut Dimension 1 Code", DimensionValue.Code);

        DimensionValue.SetRange("Global Dimension No.", 2);
        if DimensionValue.FindFirst() then
            ProductionOrder.Validate("Shortcut Dimension 2 Code", DimensionValue.Code);
        ProductionOrder.Modify();
        LibraryMfg.RefreshProdOrder(ProductionOrder, false, true, true, true, false);
    end;

    local procedure FindRequisitionLineForProductionOrder(var RequisitionLine: Record "Requisition Line"; ProductionOrder: Record "Production Order")
    begin
        RequisitionLine.SetCurrentKey("Ref. Order Type", "Ref. Order Status", "Ref. Order No.", "Ref. Line No.");
        RequisitionLine.SetRange("No.", ProductionOrder."Source No.");
        RequisitionLine.SetRange("Ref. Order Status", ProductionOrder.Status);
        RequisitionLine.SetRange("Ref. Order No.", ProductionOrder."No.");
        RequisitionLine.FindFirst();
    end;

    local procedure DeliverSubconComponents(var PurchaseLine: Record "Purchase Line"; ReworkQty: Decimal)
    begin
        PurchaseLine.FindFirst();

        PurchaseLine.Validate("Deliver Comp. For", PurchaseLine.Quantity);
        PurchaseLine.Validate("Qty. to Receive", (PurchaseLine.Quantity - ReworkQty));
        if ReworkQty > 0 then
            PurchaseLine.Validate("Qty. to Reject (Rework)", ReworkQty);
        PurchaseLine.Validate("Posting Date", WorkDate());
        PurchaseLine.Validate("Delivery Challan Date", WorkDate());
        PurchaseLine.SubConSend := true;
        PurchaseLine.Modify();

        Codeunit.Run(Codeunit::"Subcontracting Post", PurchaseLine);
    end;

    local procedure DeliverSubconComponentsMultiple(var PurchaseLineFirst: Record "Purchase Line"; var PurchaseLineSecond: Record "Purchase Line"; var MultipleSubconOrderDetailsNo: Code[20])
    var
        MultipleSubconOrderDetails: Record "Multiple Subcon. Order Details";
        VendorNo: Code[20];
    begin
        VendorNo := (Storage.Get(XVendorNoTok));

        MultipleSubconOrderDetails.Init();
        MultipleSubconOrderDetails."No." := '';
        MultipleSubconOrderDetails."Subcontractor No." := VendorNo;
        MultipleSubconOrderDetails.Insert(true);
        MultipleSubconOrderDetailsNo := MultipleSubconOrderDetails."No.";

        PurchaseLineFirst.FindFirst();
        PurchaseLineFirst.Validate("Deliver Comp. For", PurchaseLineFirst.Quantity);
        PurchaseLineFirst.Validate("Applies-to ID (Delivery)", MultipleSubconOrderDetails."No.");
        PurchaseLineFirst.Modify();
        Storage.Set(DeliveryChallanNoLbl, PurchaseLineFirst."Document No.");

        PurchaseLineSecond.FindFirst();
        PurchaseLineSecond.Validate("Deliver Comp. For", PurchaseLineSecond.Quantity);
        PurchaseLineSecond.Validate("Applies-to ID (Delivery)", MultipleSubconOrderDetails."No.");
        PurchaseLineSecond.Modify();

        Codeunit.Run(Codeunit::"Subcontracting Post Batch", MultipleSubconOrderDetails);
    end;

    local procedure UpdateProdOrderLineItemTracking(PurchaseLine: Record "Purchase Line")
    var
        ProdOrderLine: Record "Prod. Order Line";
        ReservationEntry: Record "Reservation Entry";
        MainItem: Record Item;
        NoSeriesMgt: Codeunit NoSeriesManagement;
        SlNo: Code[20];
        i: Integer;
    begin
        MainItem.Get(PurchaseLine."No.");
        ProdOrderLine.SetRange(Status, ProdOrderLine.Status::Released);
        ProdOrderLine.SetRange(ProdOrderLine."Prod. Order No.", Purchaseline."Prod. Order No.");
        ProdOrderLine.SetRange(ProdOrderLine."Line No.", PurchaseLine."Prod. Order Line No.");
        ProdOrderLine.FindFirst();
        for i := 1 to ProdOrderLine.Quantity do begin
            SlNo := NoSeriesMgt.GetNextNo(MainItem."Serial Nos.", 0D, true);
            LibraryItemTracking.CreateProdOrderItemTracking(ReservationEntry, ProdOrderLine, SlNo, '', 1);
        end;
    end;

    local procedure ReceiptSubconItem(var PurchaseLine: Record "Purchase Line"; PartialReceipt: Boolean; RejectVE: Boolean; RejectCE: Boolean; PostingDate: Date): Decimal
    var
        SubConPost: Codeunit "Subcontracting Post";
        QtyToReceive: Decimal;
        QtyRejectVE: Decimal;
        QtyRejectCE: Decimal;
    begin
        PurchaseLine.FindFirst();
        PurchaseLine."Vendor Shipment No." := LibraryUtility.GenerateRandomCode(PurchaseLine.FieldNo("Vendor Shipment No."), Database::"Purchase Line");
        PurchaseLine.Validate("Posting Date", PostingDate);

        QtyToReceive := PurchaseLine.Quantity;
        if PartialReceipt then
            QtyToReceive := QtyToReceive div 2;

        if PartialReceipt and RejectVE then
            QtyRejectVE := PurchaseLine.Quantity - QtyToReceive;

        if PartialReceipt and RejectCE then
            QtyRejectCE := PurchaseLine.Quantity - QtyToReceive;

        PurchaseLine.Validate("Qty. to Receive", QtyToReceive);
        if QtyRejectVE > 0 then
            PurchaseLine.Validate("Qty. to Reject (V.E.)", QtyRejectVE);

        if QtyRejectCE > 0 then
            PurchaseLine.Validate("Qty. to Reject (C.E.)", QtyRejectCE);

        PurchaseLine.Modify();

        // Apply Delivery Challan
        ApplyDeliveryChallan(PurchaseLine);

        // Post Receipt        
        PurchaseLine.SubConReceive := true;
        SubConPost.PostPurchOrder(PurchaseLine);

        exit(QtyToReceive);
    end;

    local procedure ReceiptSubconItemMultiple(var PurchaseLineFirst: Record "Purchase Line";
        var PurchaseLineSecond: Record "Purchase Line";
        MultipleSubconOrderDetailsNo: Code[20];
        PostingDate: Date;
        var OutputQtyFirst: Decimal;
        var OutputQtySecond: Decimal)
    var
        MultipleSubconOrderDetails: Record "Multiple Subcon. Order Details";
        SubconPostBatch: Codeunit "Subcontracting Post Batch";
        VendorNo: Code[20];
    begin
        VendorNo := (Storage.Get(XVendorNoTok));

        MultipleSubconOrderDetails.SetRange("No.", MultipleSubconOrderDetailsNo);
        MultipleSubconOrderDetails.SetRange("Subcontractor No.", VendorNo);
        MultipleSubconOrderDetails.FindFirst();
        MultipleSubconOrderDetails.Validate("Posting Date", PostingDate);
        MultipleSubconOrderDetails."Vendor Shipment No." :=
            LibraryUtility.GenerateRandomCode(MultipleSubconOrderDetails.FieldNo("Vendor Shipment No."), Database::"Multiple Subcon. Order Details");
        MultipleSubconOrderDetails.Modify();

        PurchaseLineFirst.FindFirst();
        PurchaseLineFirst.Validate("Posting Date", PostingDate);
        PurchaseLineFirst.Validate("Qty. to Receive", PurchaseLineFirst.Quantity);
        PurchaseLineFirst.Validate("Applies-to ID (Receipt)", MultipleSubconOrderDetails."No.");
        PurchaseLineFirst.Modify();
        OutputQtyFirst := PurchaseLineFirst."Qty. to Receive";

        PurchaseLineSecond.FindFirst();
        PurchaseLineSecond.Validate("Posting Date", PostingDate);
        PurchaseLineSecond.Validate("Qty. to Receive", PurchaseLineSecond.Quantity);
        PurchaseLineSecond.Validate("Applies-to ID (Receipt)", MultipleSubconOrderDetails."No.");
        PurchaseLineSecond.Modify();
        OutputQtySecond := PurchaseLineSecond."Qty. to Receive";

        ApplyDeliveryChallan(PurchaseLineFirst);
        ApplyDeliveryChallan(PurchaseLineSecond);

        SubconPostBatch.PostPurchorder(MultipleSubconOrderDetails);
    end;

    local procedure ReceiptSubconItemMultipleWithOutputDate(var PurchaseLineFirst: Record "Purchase Line";
        var PurchaseLineSecond: Record "Purchase Line";
        MultipleSubconOrderDetailsNo: Code[20];
        PostingDate: Date;
        var OutputQtyFirst: Decimal;
        var OutputQtySecond: Decimal;
        var OutputDateFirst: Date;
        var OutputDateSecond: Date)
    var
        MultipleSubconOrderDetails: Record "Multiple Subcon. Order Details";
        SubconPostBatch: Codeunit "Subcontracting Post Batch";
        VendorNo: Code[20];
    begin
        VendorNo := (Storage.Get(XVendorNoTok));

        MultipleSubconOrderDetails.SetRange("No.", MultipleSubconOrderDetailsNo);
        MultipleSubconOrderDetails.SetRange("Subcontractor No.", VendorNo);
        MultipleSubconOrderDetails.FindFirst();
        MultipleSubconOrderDetails.Validate("Posting Date", PostingDate);
        MultipleSubconOrderDetails."Vendor Shipment No." :=
            LibraryUtility.GenerateRandomCode(MultipleSubconOrderDetails.FieldNo("Vendor Shipment No."), Database::"Multiple Subcon. Order Details");
        MultipleSubconOrderDetails.Modify();

        PurchaseLineFirst.FindFirst();
        PurchaseLineFirst.Validate("Posting Date", PostingDate);
        PurchaseLineFirst.Validate("Qty. to Receive", PurchaseLineFirst.Quantity);
        PurchaseLineFirst.Validate("Applies-to ID (Receipt)", MultipleSubconOrderDetails."No.");
        PurchaseLineFirst.Modify();
        OutputQtyFirst := PurchaseLineFirst."Qty. to Receive";
        OutputDateFirst := PurchaseLineFirst."Posting Date";

        PurchaseLineSecond.FindFirst();
        PurchaseLineSecond.Validate("Posting Date", PostingDate);
        PurchaseLineSecond.Validate("Qty. to Receive", PurchaseLineSecond.Quantity);
        PurchaseLineSecond.Validate("Applies-to ID (Receipt)", MultipleSubconOrderDetails."No.");
        PurchaseLineSecond.Modify();
        OutputQtySecond := PurchaseLineSecond."Qty. to Receive";
        OutputDateSecond := PurchaseLineSecond."Posting Date";

        ApplyDeliveryChallan(PurchaseLineFirst);
        ApplyDeliveryChallan(PurchaseLineSecond);

        SubconPostBatch.PostPurchorder(MultipleSubconOrderDetails);
    end;

    local procedure ApplyDeliveryChallan(PurchaseLine: Record "Purchase Line")
    var
        DeliveryChallanLine: Record "Delivery Challan Line";
        AppliedDeliveryChallan: Record "Applied Delivery Challan";
        SubOrderCompListVend: Record "Sub Order Comp. List Vend";
        BaseQtyToConsume: Decimal;
    begin
        SubOrderCompListVend.SetRange("Document No.", PurchaseLine."Document No.");
        SubOrderCompListVend.SetRange("Document Line No.", PurchaseLine."Line No.");
        SubOrderCompListVend.SetRange("Parent Item No.", PurchaseLine."No.");
        if SubOrderCompListVend.FindSet() then
            repeat
                BaseQtyToConsume := SubOrderCompListVend."Qty. to Consume" + SubOrderCompListVend."Qty. to Receive" +
                    SubOrderCompListVend."Qty. to Return (C.E.)" + SubOrderCompListVend."Qty. To Return (V.E.)";
                SubOrderCompListVend."Qty. to Consume" := BaseQtyToConsume * PurchaseLine."Qty. to Receive" / PurchaseLine.Quantity;
                SubOrderCompListVend."Qty. To Return (V.E.)" := BaseQtyToConsume * PurchaseLine."Qty. to Reject (V.E.)" / PurchaseLine.Quantity;
                SubOrderCompListVend."Qty. to Return (C.E.)" := BaseQtyToConsume * PurchaseLine."Qty. to Reject (C.E.)" / PurchaseLine.Quantity;
                SubOrderCompListVend.Modify();

                DeliveryChallanLine.SetRange("Document No.", PurchaseLine."Document No.");
                DeliveryChallanLine.SetRange("Document Line No.", PurchaseLine."Line No.");
                DeliveryChallanLine.SetRange("Parent Item No.", PurchaseLine."No.");
                DeliveryChallanLine.SetRange("Item No.", SubOrderCompListVend."Item No.");
                if DeliveryChallanLine.FindFirst() then begin
                    AppliedDeliveryChallan.Init();
                    AppliedDeliveryChallan."Document No." := PurchaseLine."Document No.";
                    AppliedDeliveryChallan."Document Line No." := PurchaseLine."Line No.";
                    AppliedDeliveryChallan."Parent Item No." := PurchaseLine."No.";
                    AppliedDeliveryChallan."Line No." := SubOrderCompListVend."Line No.";
                    AppliedDeliveryChallan."Item No." := DeliveryChallanLine."Item No.";
                    AppliedDeliveryChallan."Applied Delivery Challan No." := DeliveryChallanLine."Delivery Challan No.";
                    AppliedDeliveryChallan."App. Delivery Challan Line No." := DeliveryChallanLine."Line No.";
                    AppliedDeliveryChallan."Job Work Return Period" := DeliveryChallanLine."Job Work Return Period";
                    AppliedDeliveryChallan.Insert(true);
                    AppliedDeliveryChallan."Qty. to Consume" := DeliveryChallanLine.Quantity * PurchaseLine."Qty. to Receive" / PurchaseLine.Quantity;
                    AppliedDeliveryChallan."Qty. To Return (V.E.)" := DeliveryChallanLine.Quantity * PurchaseLine."Qty. to Reject (V.E.)" / PurchaseLine.Quantity;
                    AppliedDeliveryChallan."Qty. To Return (C.E.)" := DeliveryChallanLine.Quantity * PurchaseLine."Qty. to Reject (C.E.)" / PurchaseLine.Quantity;
                    AppliedDeliveryChallan.Modify(true);
                end;
            until SubOrderCompListVend.Next() = 0;
    end;

    local procedure ReturnSubconItem(var PurchaseLine: Record "Purchase Line")
    var
        DeliveryChallanLine: Record "Delivery Challan Line";
        AppliedDeliveryChallan: Record "Applied Delivery Challan";
        SubOrderCompListVend: Record "Sub Order Comp. List Vend";
        SubConPost: Codeunit "Subcontracting Post";
    begin
        PurchaseLine.FindFirst();
        PurchaseLine."Vendor Shipment No." := LibraryUtility.GenerateRandomCode(PurchaseLine.FieldNo("Vendor Shipment No."), Database::"Purchase Line");
        PurchaseLine.Validate("Posting Date", WorkDate());
        PurchaseLine.Validate("Qty. to Receive", 0);
        PurchaseLine.Modify();

        // Apply Delivery Challan
        SubOrderCompListVend.SetRange("Document No.", PurchaseLine."Document No.");
        SubOrderCompListVend.SetRange("Document Line No.", PurchaseLine."Line No.");
        SubOrderCompListVend.SetRange("Parent Item No.", PurchaseLine."No.");
        if SubOrderCompListVend.FindSet() then
            repeat
                SubOrderCompListVend.CalcFields("Expected Quantity");
                SubOrderCompListVend."Qty. to Consume" := 0;
                SubOrderCompListVend."Qty. to Receive" := SubOrderCompListVend."Expected Quantity";
                SubOrderCompListVend.Modify();

                DeliveryChallanLine.SetRange("Document No.", PurchaseLine."Document No.");
                DeliveryChallanLine.SetRange("Document Line No.", PurchaseLine."Line No.");
                DeliveryChallanLine.SetRange("Parent Item No.", PurchaseLine."No.");
                DeliveryChallanLine.SetRange("Item No.", SubOrderCompListVend."Item No.");
                if DeliveryChallanLine.FindFirst() then begin
                    AppliedDeliveryChallan.Init();
                    AppliedDeliveryChallan."Document No." := PurchaseLine."Document No.";
                    AppliedDeliveryChallan."Document Line No." := PurchaseLine."Line No.";
                    AppliedDeliveryChallan."Parent Item No." := PurchaseLine."No.";
                    AppliedDeliveryChallan."Line No." := SubOrderCompListVend."Line No.";
                    AppliedDeliveryChallan."Item No." := DeliveryChallanLine."Item No.";
                    AppliedDeliveryChallan."Applied Delivery Challan No." := DeliveryChallanLine."Delivery Challan No.";
                    AppliedDeliveryChallan."App. Delivery Challan Line No." := DeliveryChallanLine."Line No.";
                    AppliedDeliveryChallan."Job Work Return Period" := DeliveryChallanLine."Job Work Return Period";
                    AppliedDeliveryChallan.Insert(true);
                    AppliedDeliveryChallan."Qty. to Consume" := 0;
                    AppliedDeliveryChallan."Qty. to Receive" := SubOrderCompListVend."Qty. to Receive";
                    AppliedDeliveryChallan.Modify(true);
                end;
            until SubOrderCompListVend.Next() = 0;

        // Post Receipt        
        PurchaseLine.SubConReceive := true;
        SubConPost.PostPurchOrder(PurchaseLine);
    end;

    local procedure GetGSTLastDateDeliveryChallan(PurchaseLine: Record "Purchase Line"; var DeliveryChallanNo: Code[20]; var GSTLastDate: Date)
    var
        SubOrderComponentList: Record "Sub Order Component List";
        DeliveryChallanLine: Record "Delivery Challan Line";
    begin
        SubOrderComponentList.Reset();
        SubOrderComponentList.SetRange("Document No.", PurchaseLine."Document No.");
        SubOrderComponentList.SetRange("Document Line No.", PurchaseLine."Line No.");
        SubOrderComponentList.SetRange("Parent Item No.", PurchaseLine."No.");
        if SubOrderComponentList.FindFirst() then begin
            DeliveryChallanLine.SetRange("Document No.", PurchaseLine."Document No.");
            DeliveryChallanLine.SetRange("Document Line No.", PurchaseLine."Line No.");
            DeliveryChallanLine.SetRange("Parent Item No.", PurchaseLine."No.");
            DeliveryChallanLine.SetRange("Prod. Order Comp. Line No.", SubOrderComponentList."Line No.");
            DeliveryChallanLine.FindFirst();
            DeliveryChallanNo := DeliveryChallanLine."Delivery Challan No.";
            GSTLastDate := DeliveryChallanLine."Last Date";
        end;
    end;

    local procedure CreateGSTLiability(VendorNo: Code[20]; SubconOrderNo: Code[20]; DeliveryChallanNo: Code[20]; GSTLastDate: Date);
    var
        CreateGSTLiabilityPage: TestPage "Create GST Liability";
    begin
        CreateGSTLiabilityPage.OpenEdit();
        CreateGSTLiabilityPage."Vendor No. Filter".SetValue(VendorNo);
        CreateGSTLiabilityPage."Subcontracting Order No. Filter".SetValue(SubconOrderNo);
        CreateGSTLiabilityPage."Delivery Challan No. Filter".SetValue(DeliveryChallanNo);
        CreateGSTLiabilityPage."Liability Date Filter".SetValue(GSTLastDate);
        CreateGSTLiabilityPage."Liability Document No.".SetValue(DeliveryChallanNo);
        CreateGSTLiabilityPage."Create GST Liability".Invoke();
    end;

    local procedure PostGSTLiability()
    var
        GSTLiabilityLine: Record "GST Liability Line";
        SubcontractingPostGSTLiab: Codeunit "Subcontracting Post GST Liab.";
    begin
        GSTLiabilityLine.FindSet();
        SubcontractingPostGSTLiab.PostGSTLiability(GSTLiabilityLine);
    end;

    local procedure ChangeStatusReleasedProdOrder(ProductionOrder: Record "Production Order")
    begin
        LibraryMfg.ChangeStatusReleasedToFinished(ProductionOrder."No.");
    end;

    local procedure CreateDebitNoteRejectVE(var PurchaseLine: Record "Purchase Line")
    begin
        Report.Run(Report::"Create Vendor Exp. Debit Note", false, true, PurchaseLine);
    end;

    local procedure VerifyDeliveryChallanLine(PurchaseLine: Record "Purchase Line")
    var
        SubOrderComponentList: Record "Sub Order Component List";
        DeliveryChallanLine: Record "Delivery Challan Line";
    begin
        SubOrderComponentList.Reset();
        SubOrderComponentList.SetRange("Document No.", PurchaseLine."Document No.");
        SubOrderComponentList.SetRange("Document Line No.", PurchaseLine."Line No.");
        SubOrderComponentList.SetRange("Parent Item No.", PurchaseLine."No.");
        if SubOrderComponentList.FindSet() then
            repeat
                DeliveryChallanLine.SetRange("Document No.", PurchaseLine."Document No.");
                DeliveryChallanLine.SetRange("Document Line No.", PurchaseLine."Line No.");
                DeliveryChallanLine.SetRange("Parent Item No.", PurchaseLine."No.");
                DeliveryChallanLine.SetRange("Prod. Order Comp. Line No.", SubOrderComponentList."Line No.");
                DeliveryChallanLine.FindFirst();
                DeliveryChallanLine.TestField("Item No.", SubOrderComponentList."Item No.");
                DeliveryChallanLine.TestField(Quantity, SubOrderComponentList."Quantity (Base)");
            until SubOrderComponentList.Next() = 0;
    end;

    local procedure VerifyItemLedgerEntryComponentTransfer(PurchaseLine: Record "Purchase Line")
    var
        SubOrderComponentList: Record "Sub Order Component List";
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        SubOrderComponentList.Reset();
        SubOrderComponentList.SetRange("Document No.", PurchaseLine."Document No.");
        SubOrderComponentList.SetRange("Document Line No.", PurchaseLine."Line No.");
        SubOrderComponentList.SetRange("Parent Item No.", PurchaseLine."No.");
        if SubOrderComponentList.FindSet() then
            repeat
                ItemLedgerEntry.SetRange("Document No.", PurchaseLine."Prod. Order No.");
                ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Transfer);
                ItemLedgerEntry.SetRange("Item No.", SubOrderComponentList."Item No.");
                ItemLedgerEntry.SetRange("Location Code", SubOrderComponentList."Company Location");
                ItemLedgerEntry.FindFirst();
                ItemLedgerEntry.TestField(Quantity, -SubOrderComponentList."Quantity (Base)");
                ItemLedgerEntry.SetRange("Location Code", SubOrderComponentList."Vendor Location");
                ItemLedgerEntry.FindFirst();
                ItemLedgerEntry.TestField(Quantity, SubOrderComponentList."Quantity (Base)");
            until SubOrderComponentList.Next() = 0;
    end;

    local procedure VerifyItemLedgerEntryComponentConsumption(PurchaseLine: Record "Purchase Line")
    var
        SubOrderCompListVend: Record "Sub Order Comp. List Vend";
        ItemLedgerEntry: Record "Item Ledger Entry";
        ConsumptionQty: Decimal;
    begin
        SubOrderCompListVend.SetRange("Document No.", PurchaseLine."Document No.");
        SubOrderCompListVend.SetRange("Document Line No.", PurchaseLine."Line No.");
        SubOrderCompListVend.SetRange("Parent Item No.", PurchaseLine."No.");
        if SubOrderCompListVend.FindSet() then
            repeat
                SubOrderCompListVend.CalcFields("Qty. Consumed");
                ItemLedgerEntry.SetRange("Document No.", PurchaseLine."Prod. Order No.");
                ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Consumption);
                ItemLedgerEntry.SetRange("Item No.", SubOrderCompListVend."Item No.");
                ItemLedgerEntry.SetRange("Location Code", SubOrderCompListVend."Vendor Location");
                ItemLedgerEntry.FindSet();
                ItemLedgerEntry.CalcSums(Quantity);
                ConsumptionQty := ItemLedgerEntry.Quantity;
                LibraryAssert.AreEqual(
                    -SubOrderCompListVend."Qty. Consumed",
                    ConsumptionQty,
                    StrSubstNo(FieldVerifyErr, SubOrderCompListVend.FieldCaption("Qty. Consumed"), SubOrderCompListVend.TableCaption));
            until SubOrderCompListVend.Next() = 0;
    end;

    local procedure VerifyItemLedgerEntryItemOutput(PurchaseLine: Record "Purchase Line"; ExpectedOutputQty: Decimal)
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        OutputQty: Decimal;
    begin
        ItemLedgerEntry.SetRange("Document No.", PurchaseLine."Prod. Order No.");
        ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Output);
        ItemLedgerEntry.SetRange("Item No.", PurchaseLine."No.");
        ItemLedgerEntry.SetRange("Location Code", PurchaseLine."Location Code");
        ItemLedgerEntry.FindSet();
        ItemLedgerEntry.CalcSums(Quantity);
        OutputQty := ItemLedgerEntry.Quantity;
        LibraryAssert.AreEqual(OutputQty, ExpectedOutputQty, StrSubstNo(FieldVerifyErr, ItemLedgerEntry.FieldCaption(Quantity), ItemLedgerEntry.TableCaption));
    end;

    local procedure VerifyItemLedgerEntryOutputDate(PurchaseLine: Record "Purchase Line"; ExpectedOutputPostingDate: Date)
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        OutputDate: Date;
    begin
        ItemLedgerEntry.SetRange("Document No.", PurchaseLine."Prod. Order No.");
        ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Output);
        ItemLedgerEntry.SetRange("Item No.", PurchaseLine."No.");
        ItemLedgerEntry.SetRange("Location Code", PurchaseLine."Location Code");
        ItemLedgerEntry.FindSet();
        ItemLedgerEntry.CalcSums(Quantity);
        OutputDate := ItemLedgerEntry."Posting Date";
        LibraryAssert.AreEqual(OutputDate, ExpectedOutputPostingDate, StrSubstNo(FieldVerifyErr, ItemLedgerEntry.FieldCaption("Posting Date"), ItemLedgerEntry.TableCaption));
    end;

    local procedure VerifyDimensionsOnItemLedgerEntry(var ProductionOrder: Record "Production Order")
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        FindItemLedgerEntry(ItemLedgerEntry, ProductionOrder."No.");
        ItemLedgerEntry.FindSet();
        repeat
            Assert.AreEqual(
                ItemLedgerEntry."Dimension Set ID",
                ProductionOrder."Dimension Set ID",
                StrSubstNo(
                    ValueMismatchErr,
                    ProductionOrder.FieldCaption("Dimension Set ID")));

            Assert.AreEqual(
                ItemLedgerEntry."Global Dimension 1 Code",
                ProductionOrder."Shortcut Dimension 1 Code",
                StrSubstNo(
                    ValueMismatchErr,
                    ProductionOrder.FieldCaption("Shortcut Dimension 1 Code")));

            Assert.AreEqual(
                ItemLedgerEntry."Global Dimension 2 Code",
                ProductionOrder."Shortcut Dimension 2 Code",
                StrSubstNo(
                    ValueMismatchErr,
                    ProductionOrder.FieldCaption("Shortcut Dimension 2 Code")));
        until ItemLedgerEntry.Next() = 0;
    end;

    local procedure FindItemLedgerEntry(var ItemLedgerEntry: Record "Item Ledger Entry"; OrderNo: Code[20])
    begin
        ItemLedgerEntry.SetRange("Order No.", OrderNo);
        ItemLedgerEntry.FindFirst();
    end;

    local procedure VerifyDebitNote(PurchaseLine: Record "Purchase Line")
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        PurchaseHeader.SetRange("Document Type", PurchaseHeader."Document Type"::"Credit Memo");
        PurchaseHeader.SetRange("Subcon. Order No.", PurchaseLine."Document No.");
        PurchaseHeader.SetRange("Subcon. Order Line No.", PurchaseLine."Line No.");
        PurchaseHeader.FindFirst();
        PurchaseHeader.TestField("Buy-from Vendor No.", PurchaseLine."Buy-from Vendor No.");
    end;

    local procedure CreateAndInsertPurchaseLineForSubContractingOrder(ProductionOrder: Record "Production Order"; var PurchaseLine: Record "Purchase Line"; MainItemNo: Code[20])
    var
        Item: Record Item;
    begin
        Item.Get(MainItemNo);
        PurchaseLine.SetRange("No.", MainItemNo);
        PurchaseLine.SetRange("Prod. Order No.", ProductionOrder."No.");
        PurchaseLine.FindFirst();
        PurchaseLine.Validate("Gen. Prod. Posting Group", Item."Gen. Prod. Posting Group");
        PurchaseLine.Validate("VAT Prod. Posting Group", Item."VAT Prod. Posting Group");
        PurchaseLine.Validate("Qty. per Unit of Measure", 1);
        PurchaseLine.Validate(Quantity, PurchaseLine.Quantity);
        PurchaseLine.Validate(PurchaseLine."Qty. to Receive", PurchaseLine.Quantity);
        PurchaseLine.Validate(PurchaseLine."Qty. to Invoice", PurchaseLine.Quantity);
        PurchaseLine.Modify();
        Storage.Set(DeliveryChallanNoLbl, PurchaseLine."Document No.");
    end;

    local procedure CreateAndValidateProdOrderComponent(ProductionOrder: Record "Production Order")
    var
        ProdOrderLine: Record "Prod. Order Line";
        ProdOrderRoutingLine: Record "Prod. Order Routing Line";
        ProdOrderComponent: Record "Prod. Order Component";
        ProdOrderStatus: Enum "Production order Status";
    begin
        ProdOrderLine.Reset();
        ProdOrderLine.SetRange(Status, ProdOrderStatus::Released);
        ProdOrderLine.SetRange("Prod. Order No.", ProductionOrder."No.");
        if ProdOrderLine.FindFirst() then begin
            ProdOrderComponent.SetRange(Status, ProdOrderLine.Status);
            ProdOrderComponent.SetRange("Prod. Order No.", ProdOrderLine."Prod. Order No.");
            ProdOrderComponent.SetRange("Prod. Order Line No.", ProdOrderLine."Line No.");
            if ProdOrderComponent.FindSet() then
                repeat
                    ProdOrderComponent.Validate("Unit Cost", LibraryRandom.RandInt(100));
                    ProdOrderComponent.Modify();
                until ProdOrderComponent.Next() = 0;

            ProdOrderRoutingLine.SetRange(Status, ProdOrderLine.Status);
            ProdOrderRoutingLine.SetRange("Prod. Order No.", ProdOrderLine."Prod. Order No.");
            ProdOrderRoutingLine.SetRange("Routing Reference No.", ProdOrderLine."Routing Reference No.");
            ProdOrderRoutingLine.SetRange("Routing No.", ProdOrderLine."Routing No.");
            if ProdOrderRoutingLine.FindSet() then
                LibraryMfg.CalculateSubcontractOrderWithProdOrderRoutingLine(ProdOrderRoutingLine);
        end;
    end;

    local procedure CreateGSTSubconSetupsWithBinMandatory(
        GSTVendorType: Enum "GST Vendor Type";
                           GSTGroupType: Enum "GST Group Type";
                           IntraState: Boolean)
    begin
        // Source Codes
        UpdateSourceCodes();

        // General Ledger Setup
        UpdateGLSetup();

        // Purchases and Payables Setup
        UpdatePurchSetup();

        // Company Information
        UpdateCompanyInformation();

        //Update Company Location with Bin Mandatory
        UpdateLocationWithBinMandatory();

        // Inventory Setup
        UpdateInventorySetup();

        // GST Group and HSN Code
        CreateGSTGroupHSNCode(GSTGroupType);

        // Subcontracting Vendor
        CreateSubconVendor(GSTVendorType, IntraState);

        // Work Center
        CreateWorkCenter();

        // Main Item with Production BOM and Routing
        CreateItemWithProdBOMAndRouting();

        // Create Inventory for Components
        CreateComponentItemInventory();

        // Tax Rate and Posting Setup
        CreateTaxRateAndPostingSetup(IntraState);
    end;

    local procedure UpdateLocationWithBinMandatory()
    var
        Location: Record Location;
    begin
        Location.Get((Storage.Get(XCompanyLocationCodeTok)));
        Location."Bin Mandatory" := true;
        Location.Modify();
    end;

    local procedure CreateItemWithProdBOMAndRouting()
    var
        Item: Record Item;
        Bin: Record Bin;
        CompItemBinContent: Record "Bin Content";
        MainItemBinContent: Record "Bin Content";
        VATPostingSetup: Record "VAT Posting Setup";
        GenProdPostingGroup: Record "Gen. Product Posting Group";
        CompLocationCode: Code[10];
        MainItemNo: Code[20];
        ComponentItemNo: Code[20];
        ProductionBOMNo: Code[20];
        RoutingNo: Code[20];
    begin
        MainItemNo := LibraryGST.CreateItemWithGSTDetails(VATPostingSetup, (Storage.Get(XGSTGroupCodeTok)), (Storage.Get(XHSNSACCodeTok)), true, false);
        ComponentItemNo := LibraryGST.CreateItemWithGSTDetails(VATPostingSetup, (Storage.Get(XGSTGroupCodeTok)), (Storage.Get(XHSNSACCodeTok)), true, false);
        CompLocationCode := (Storage.Get(XCompanyLocationCodeTok));
        ProductionBOMNo := CreateProdBOM(ComponentItemNo);
        RoutingNo := CreateRouting(Storage.Get(WorkCenterNoTok));

        Item.Get(MainItemNo);
        Item."Replenishment System" := Item."Replenishment System"::"Prod. Order";
        Item."Production BOM No." := ProductionBOMNo;
        Item."Routing No." := RoutingNo;
        Item.Modify();

        LibraryWarehouse.CreateBin(Bin, CompLocationCode, '', '', '');
        LibraryWarehouse.CreateBinContent(MainItemBinContent, CompLocationCode, '', Bin.Code, Item."No.", '', Item."Base Unit of Measure");

        Item.Get(ComponentItemNo);
        LibraryGST.CreateGeneralPostingSetup('', Item."Gen. Prod. Posting Group");
        GenProdPostingGroup.Get(Item."Gen. Prod. Posting Group");
        GenProdPostingGroup."Auto Insert Default" := false;
        GenProdPostingGroup.Modify();

        LibraryWarehouse.CreateBinContent(CompItemBinContent, CompLocationCode, '', Bin.Code, Item."No.", '', Item."Base Unit of Measure");

        Storage.Set(XMainItemNoTok, MainItemNo);
        Storage.Set(XComponentItemNoTok, ComponentItemNo);
        Storage.Set(XBinCodeTok, Bin.Code);
    end;

    local procedure CreateComponentItemInventory()
    var
        ItemJournalLine: Record "Item Journal Line";
        BinCode: Code[20];
        ComponentItemNo: Code[20];
        CompanyLocationCode: Code[10];
    begin
        ComponentItemNo := (Storage.Get(XComponentItemNoTok));
        CompanyLocationCode := (Storage.Get(XCompanyLocationCodeTok));
        BinCode := (Storage.Get(XBinCodeTok));
        LibraryInventory.CreateItemJournalLineInItemTemplate(ItemJournalLine, ComponentItemNo, CompanyLocationCode, BinCode, 100);
        LibraryInventory.PostItemJournalLine(ItemJournalLine."Journal Template Name", ItemJournalLine."Journal Batch Name");
    end;

    local procedure CreateSubcontractingOrderWithBinCodeFromReleasedProdOrder(var ProductionOrder: Record "Production Order"; var PurchaseLine: Record "Purchase Line")
    var
        ProdOrderLine: Record "Prod. Order Line";
        ProdOrderRoutingLine: Record "Prod. Order Routing Line";
        ProdOrderComponent: Record "Prod. Order Component";
        RequisitionLine: Record "Requisition Line";
        Item: Record Item;
        SubOrderComponentList: Record "Sub Order Component List";
        ProdOrderStatus: Enum "Production order Status";
        ProdOrderSourceType: Enum "Prod. Order Source Type";
        MainItemNo: Code[20];
        CompanyLocationCode: Code[10];
        BinCode: Code[20];
    begin
        MainItemNo := (Storage.Get(XMainItemNoTok));
        CompanyLocationCode := (Storage.Get(XCompanyLocationCodeTok));
        BinCode := (Storage.Get(XBinCodeTok));

        LibraryMfg.CreateProductionOrder(ProductionOrder, ProdOrderStatus::Released, ProdOrderSourceType::Item, MainItemNo, 10);
        ProductionOrder.Validate("Location Code", CompanyLocationCode);
        ProductionOrder.Validate("Bin Code", BinCode);
        ProductionOrder.Modify();
        LibraryMfg.RefreshProdOrder(ProductionOrder, false, true, true, true, false);

        ProdOrderLine.Reset();
        ProdOrderLine.SetRange(Status, ProdOrderStatus::Released);
        ProdOrderLine.SetRange("Prod. Order No.", ProductionOrder."No.");
        if ProdOrderLine.FindFirst() then begin
            ProdOrderComponent.SetRange(Status, ProdOrderLine.Status);
            ProdOrderComponent.SetRange("Prod. Order No.", ProdOrderLine."Prod. Order No.");
            ProdOrderComponent.SetRange("Prod. Order Line No.", ProdOrderLine."Line No.");
            if ProdOrderComponent.FindSet() then
                repeat
                    ProdOrderComponent.Validate("Unit Cost", LibraryRandom.RandInt(100));
                    ProdOrderComponent.Modify();
                until ProdOrderComponent.Next() = 0;

            ProdOrderRoutingLine.SetRange(Status, ProdOrderLine.Status);
            ProdOrderRoutingLine.SetRange("Prod. Order No.", ProdOrderLine."Prod. Order No.");
            ProdOrderRoutingLine.SetRange("Routing Reference No.", ProdOrderLine."Routing Reference No.");
            ProdOrderRoutingLine.SetRange("Routing No.", ProdOrderLine."Routing No.");
            if ProdOrderRoutingLine.FindSet() then
                LibraryMfg.CalculateSubcontractOrderWithProdOrderRoutingLine(ProdOrderRoutingLine);
        end;

        FindRequisitionLineForProductionOrder(RequisitionLine, ProductionOrder);
        LibraryPlanning.CarryOutAMSubcontractWksh(RequisitionLine);

        Item.Get(MainItemNo);
        PurchaseLine.SetRange("No.", MainItemNo);
        PurchaseLine.SetRange("Prod. Order No.", ProductionOrder."No.");
        PurchaseLine.FindFirst();
        PurchaseLine.Validate("Gen. Prod. Posting Group", Item."Gen. Prod. Posting Group");
        PurchaseLine.Validate("VAT Prod. Posting Group", Item."VAT Prod. Posting Group");
        PurchaseLine.Validate("Qty. per Unit of Measure", 1);
        PurchaseLine.Validate(Quantity, PurchaseLine.Quantity);
        PurchaseLine.Validate(PurchaseLine."Qty. to Receive", PurchaseLine.Quantity);
        PurchaseLine.Validate(PurchaseLine."Qty. to Invoice", PurchaseLine.Quantity);
        PurchaseLine.Modify();
        Storage.Set(DeliveryChallanNoLbl, PurchaseLine."Document No.");

        SubOrderComponentList.Reset();
        SubOrderComponentList.SetRange("Document No.", PurchaseLine."Document No.");
        SubOrderComponentList.SetRange("Document Line No.", PurchaseLine."Line No.");
        SubOrderComponentList.ModifyAll("Company Location", CompanyLocationCode);
        SubOrderComponentList.ModifyAll("Bin Code", BinCode);
    end;

    local procedure Initialize()
    begin
        StorageBoolean.Set(WithDimensionLbl, true);
    end;

    local procedure Dispose()
    begin
        StorageBoolean.Set(WithDimensionLbl, false);
    end;

    [PageHandler]
    procedure TaxRatePageHandler(var TaxRates: TestPage "Tax Rates")
    begin
        TaxRates.New();
        TaxRates.AttributeValue1.SetValue(Storage.Get(XGSTGroupCodeTok));
        TaxRates.AttributeValue2.SetValue(Storage.Get(XHSNSACCodeTok));
        TaxRates.AttributeValue3.SetValue(Storage.Get(XFromStateCodeTok));
        TaxRates.AttributeValue4.SetValue(Storage.Get(XToStateCodeTok));
        TaxRates.AttributeValue5.SetValue(WorkDate());
        TaxRates.AttributeValue6.SetValue(CalcDate('<10Y>', WorkDate()));
        TaxRates.AttributeValue7.SetValue(ComponentPerArray[1]);
        TaxRates.AttributeValue8.SetValue(ComponentPerArray[2]);
        TaxRates.AttributeValue9.SetValue(ComponentPerArray[3]);
        TaxRates.AttributeValue10.SetValue(ComponentPerArray[4]);
        TaxRates.AttributeValue11.SetValue(false);
        TaxRates.AttributeValue12.SetValue(false);
        TaxRates.OK().Invoke();
    end;

    [PageHandler]
    procedure GSTLiabilityLinePageHandler(var GSTLiabilityLinePage: TestPage "GST Liability Line")
    begin
        GSTLiabilityLinePage.Close();
    end;

    [MessageHandler]
    procedure DeliveryChallanSentMsgHandler(MsgTxt: Text[1024])
    begin
        if MsgTxt <> StrSubstNo(SuccessMsg, Storage.Get(DeliveryChallanNoLbl)) then
            Error(NotPostedErr);
    end;

    [MessageHandler]
    procedure DeliveryChallanSentMessageHandler(MsgTxt: Text[1024])
    begin
        if not StorageBoolean.Get(WithDimensionLbl) then
            Error(NotPostedErr);
    end;

    [MessageHandler]
    procedure CreditMemoCreateMsgHandler(MsgTxt: Text[1024])
    begin

    end;

    [ConfirmHandler]
    procedure PostConfirmation(Question: Text; var Reply: Boolean)
    begin
        Reply := true;
    end;
}