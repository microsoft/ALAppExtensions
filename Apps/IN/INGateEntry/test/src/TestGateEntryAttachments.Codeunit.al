codeunit 18630 "Test Gate Entry Attachments"
{
    Subtype = Test;

    var
        GateEntryLib: Codeunit "Gate Entry Library";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibrarySales: Codeunit "Library - Sales";
        LibraryWarehouse: Codeunit "Library - Warehouse";

    [Test]
    [HandlerFunctions('GateEntryPostConfirmHandler,GateEntryPostMsgHandler,PostedGateEntryLineListHndlr')]
    procedure VerifyPostedGateEntryAttachmentInPurchaseOrder()
    var
        GateEntryHeader: Record "Gate Entry Header";
        PurchaseHeader: Record "Purchase Header";
        GateEntryType: Enum "Gate Entry Type";
        GateEntrySourceType: Enum "Gate Entry Source Type";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] [Check if the program is displaying Posted Gate entry Attachment – Inward record in the Purchase Order]
        // [GIVEN] Created and Validated Gate Entry Inward and Outward Nos in Inventory Setup
        CreateInventorySetupWithGateEntyNos();

        // [WHEN] Create and Post Gate Entry Inward with Source Type Purchase Order
        GateEntryLib.CreateGateEntryDocument(
            GateEntryHeader,
            GateEntryType::Inward,
            GateEntrySourceType::"Purchase Order");
        PostedDocumentNo := GateEntryLib.PostGateEnty(GateEntryHeader);
        PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, GetSourceNo(PostedDocumentNo));
        GateEntryLib.GetPurchaseOrdGateEntryLines(PurchaseHeader."No.");
        GateEntryLib.VerifyAttachedPurchaseOrdGateEntryLines(PurchaseHeader."No.");
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, false);

        // [THEN] Posted Attached Purchase Gate Entry Lines Verified
        GateEntryLib.VerifyPostedAttachedGateEntries(PurchaseHeader."No.");
    end;

    [Test]
    [HandlerFunctions('GateEntryPostConfirmHandler,GateEntryPostMsgHandler,PostedGateEntryLineListHndlr')]
    procedure VerifyPostedGateEntryAttachmentInSalesReturnOrder()
    var
        GateEntryHeader: Record "Gate Entry Header";
        SalesHeader: Record "Sales Header";
        GateEntryType: Enum "Gate Entry Type";
        GateEntrySourceType: Enum "Gate Entry Source Type";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] [Check if the program is displaying Posted Gate entry Attachment – Outward record in the Sales Return Order]
        // [GIVEN] Created and Validated Gate Entry Inward and Outward Nos in Inventory Setup
        CreateInventorySetupWithGateEntyNos();

        // [WHEN] Create and Post Gate Entry Inward with Source Type Sales Return Order
        GateEntryLib.CreateGateEntryDocument(
            GateEntryHeader,
            GateEntryType::Inward,
            GateEntrySourceType::"Sales Return Order");
        PostedDocumentNo := GateEntryLib.PostGateEnty(GateEntryHeader);
        SalesHeader.Get(SalesHeader."Document Type"::"Return Order", GetSourceNo(PostedDocumentNo));
        GateEntryLib.GetSalesRetrnOrdGateEntryLines(SalesHeader."No.");
        GateEntryLib.VerifyAttachedSalesRetrnOrdGateEntryLines(SalesHeader."No.");
        LibrarySales.PostSalesDocument(SalesHeader, true, false);

        // [THEN] Posted Attached Sales Gate Entry Lines Verified
        GateEntryLib.VerifyPostedAttachedGateEntries(SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('GateEntryPostConfirmHandler,WhseReceiptHandler,GateEntryPostMsgHandler,PostedGateEntryLineListHndlr')]
    procedure PostFromGateEntryInWhseRcptWithAttachedEntries()
    var
        GateEntryHeader: Record "Gate Entry Header";
        PurchaseHeader: Record "Purchase Header";
        WarehouseReceiptLine: Record "Warehouse Receipt Line";
        GateEntryHandler: Codeunit "Gate Entry Handler";
        GateEntryType: Enum "Gate Entry Type";
        GateEntrySourceType: Enum "Gate Entry Source Type";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] [385156] Check if the program is allowing you to attach posted Gate Entry – Inward record in the Warehouse Receipts form.
        // [GIVEN] Created and Validated Gate Entry Inward and Outward Nos in Inventory Setup
        CreateInventorySetupWithGateEntyNos();

        // [WHEN] Create and Post Gate Entry Inward with Source Type Purchase Order
        GateEntryLib.CreateGateEntryDocument(
            GateEntryHeader,
            GateEntryType::Inward,
            GateEntrySourceType::"Purchase Order");
        PostedDocumentNo := GateEntryLib.PostGateEnty(GateEntryHeader);
        PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, GetSourceNo(PostedDocumentNo));
        CreateWarehouseReceiptDoc(PurchaseHeader);
        WarehouseReceiptLine.SetRange("No.", GetWarehouseReceiptDoc(PurchaseHeader."No."));
        WarehouseReceiptLine.FindFirst();
        GateEntryHandler.GetWarehouseGateEntryLines(WarehouseReceiptLine);
        LibraryWarehouse.PostWhseRcptWithConfirmMsg(WarehouseReceiptLine."No.");

        // [THEN] Posted Gate Entry Lines Verified
        GateEntryLib.VerifyPostedGateEntries(PostedDocumentNo);
    end;

    [Test]
    [HandlerFunctions('GateEntryPostConfirmHandler,GateEntryPostMsgHandler,PostedGateEntryLineListHndlr')]
    procedure VerifyPostedGateEntryAttachmentInTransferReceipt()
    var
        GateEntryHeader: Record "Gate Entry Header";
        TransferHeader: Record "Transfer Header";
        GateEntryType: Enum "Gate Entry Type";
        GateEntrySourceType: Enum "Gate Entry Source Type";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] [Check if the program is displaying Posted Gate entry Attachment – Inward record in the Transfer Receipt]
        // [GIVEN] Created and Validated Gate Entry Inward and Outward Nos in Inventory Setup
        CreateInventorySetupWithGateEntyNos();

        // [WHEN] Create and Post Gate Entry Inward with Source Type Transfer Receipt
        GateEntryLib.CreateGateEntryDocument(
            GateEntryHeader,
            GateEntryType::Inward,
            GateEntrySourceType::"Transfer Receipt");
        PostedDocumentNo := GateEntryLib.PostGateEnty(GateEntryHeader);
        TransferHeader.Get(GetSourceNo(PostedDocumentNo));
        GateEntryLib.GetTransferGateEntryLines(TransferHeader."No.");
        GateEntryLib.VerifyAttachedTransferOrdGateEntryLines(TransferHeader."No.");
        LibraryWarehouse.PostTransferOrder(TransferHeader, true, true);

        // [THEN] Posted Attached Transfer Gate Entry Lines Verified
        GateEntryLib.VerifyPostedAttachedGateEntries(TransferHeader."No.");
    end;

    [Test]
    [HandlerFunctions('GateEntryPostConfirmHandler,GateEntryPostMsgHandler,PostedGateEntryLineListHndlr')]
    procedure VerifyDeletedGateEntryAttachmentInTransferReceipt()
    var
        GateEntryHeader: Record "Gate Entry Header";
        TransferHeader: Record "Transfer Header";
        GateEntryType: Enum "Gate Entry Type";
        GateEntrySourceType: Enum "Gate Entry Source Type";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] [Check if the program is not displaying Posted Gate entry Attachment after deletion – Inward record in the Transfer Receipt]
        // [GIVEN] Created and Validated Gate Entry Inward and Outward Nos in Inventory Setup
        CreateInventorySetupWithGateEntyNos();

        // [WHEN] Create and Post Gate Entry Inward with Source Type Transfer Receipt
        GateEntryLib.CreateGateEntryDocument(
            GateEntryHeader,
            GateEntryType::Inward,
            GateEntrySourceType::"Transfer Receipt");
        PostedDocumentNo := GateEntryLib.PostGateEnty(GateEntryHeader);
        TransferHeader.Get(GetSourceNo(PostedDocumentNo));
        GateEntryLib.GetTransferGateEntryLines(TransferHeader."No.");
        GateEntryLib.VerifyAttachedTransferRcptGateEntryLines(TransferHeader."No.");
        GateEntryLib.DeleteAttachedGateEntries(TransferHeader."No.");

        // [THEN] Deleted Attached Transfer Gate Entry Lines Verified
        GateEntryLib.VerifyDeletedAttachedGateEntries(TransferHeader."No.");
    end;

    [Test]
    [HandlerFunctions('GateEntryPostConfirmHandler,GateEntryPostMsgHandler,PostedGateEntryLineListHndlr')]
    procedure VerifyDeletedGateEntryAttachmentInPurchaseOrder()
    var
        GateEntryHeader: Record "Gate Entry Header";
        PurchaseHeader: Record "Purchase Header";
        GateEntryType: Enum "Gate Entry Type";
        GateEntrySourceType: Enum "Gate Entry Source Type";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] [Check if the program is not displaying Posted Gate entry Attachment after deletion – Inward record in the Purchase Order]
        // [GIVEN] Created and Validated Gate Entry Inward and Outward Nos in Inventory Setup
        CreateInventorySetupWithGateEntyNos();

        // [WHEN] Create and Post Gate Entry Inward with Source Type Purchase Order
        GateEntryLib.CreateGateEntryDocument(
            GateEntryHeader,
            GateEntryType::Inward,
            GateEntrySourceType::"Purchase Order");
        PostedDocumentNo := GateEntryLib.PostGateEnty(GateEntryHeader);
        PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, GetSourceNo(PostedDocumentNo));
        GateEntryLib.GetPurchaseOrdGateEntryLines(PurchaseHeader."No.");
        GateEntryLib.VerifyAttachedPurchaseOrdGateEntryLines(PurchaseHeader."No.");
        GateEntryLib.DeleteAttachedGateEntries(PurchaseHeader."No.");

        // [THEN] Deleted Attached Purchase Gate Entry Lines Verified
        GateEntryLib.VerifyDeletedAttachedGateEntries(PurchaseHeader."No.");
    end;

    [Test]
    [HandlerFunctions('GateEntryPostConfirmHandler,GateEntryPostMsgHandler,PostedGateEntryLineListHndlr')]
    procedure VerifyDeletedGateEntryAttachmentInSalesReturnOrd()
    var
        GateEntryHeader: Record "Gate Entry Header";
        SalesHeader: Record "Sales Header";
        GateEntryType: Enum "Gate Entry Type";
        GateEntrySourceType: Enum "Gate Entry Source Type";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] [Check if the program is not displaying Posted Gate entry Attachment after deletion – Inward record in the Sales Return Order]
        // [GIVEN] Created and Validated Gate Entry Inward and Outward Nos in Inventory Setup
        CreateInventorySetupWithGateEntyNos();

        // [WHEN] Create and Post Gate Entry Inward with Source Type Sales Return Order
        GateEntryLib.CreateGateEntryDocument(
            GateEntryHeader,
            GateEntryType::Inward,
            GateEntrySourceType::"Sales Return Order");
        PostedDocumentNo := GateEntryLib.PostGateEnty(GateEntryHeader);
        SalesHeader.Get(SalesHeader."Document Type"::"Return Order", GetSourceNo(PostedDocumentNo));
        GateEntryLib.GetSalesRetrnOrdGateEntryLines(SalesHeader."No.");
        GateEntryLib.VerifyAttachedSalesRetrnOrdGateEntryLines(SalesHeader."No.");
        GateEntryLib.DeleteAttachedGateEntries(SalesHeader."No.");

        // [THEN] Deleted Attached Sales Gate Entry Lines Verified
        GateEntryLib.VerifyDeletedAttachedGateEntries(SalesHeader."No.");
    end;

    local procedure GetSourceNo(PostedDocumentNo: Code[20]): Code[20]
    var
        PostedGateEntryLine: Record "Posted Gate Entry Line";
    begin
        PostedGateEntryLine.SetRange("Gate Entry No.", PostedDocumentNo);
        PostedGateEntryLine.FindFirst();
        exit(PostedGateEntryLine."Source No.");
    end;

    local procedure CreateWarehouseReceiptDoc(PurchaseHeader: Record "Purchase Header")
    var
        Location: Record Location;
        WarehouseEmployee: Record "Warehouse Employee";
    begin
        Location.Get(PurchaseHeader."Location Code");
        Location.Validate("Require Receive", true);
        Location.Modify(true);
        LibraryPurchase.ReleasePurchaseDocument(PurchaseHeader);
        LibraryWarehouse.CreateWarehouseEmployee(WarehouseEmployee, PurchaseHeader."Location Code", false);
        CreateWarehouseReceiptDoc(PurchaseHeader."No.");
    end;

    local procedure CreateWarehouseReceiptDoc(No: Code[20])
    var
        PurchaseOrder: TestPage "Purchase Order";
    begin
        PurchaseOrder.OpenEdit();
        PurchaseOrder.Filter.SetFilter("No.", No);
        PurchaseOrder."Create &Whse. Receipt".Invoke();
    end;

    local procedure GetWarehouseReceiptDoc(No: Code[20]): Code[20]
    var
        WarehouseReceiptLine: Record "Warehouse Receipt Line";
    begin
        WarehouseReceiptLine.SetRange("Source No.", No);
        WarehouseReceiptLine.FindFirst();
        exit(WarehouseReceiptLine."No.");
    end;

    local procedure CreateInventorySetupWithGateEntyNos()
    var
        InventorySetup: Record "Inventory Setup";
    begin
        InventorySetup.Get();
        if InventorySetup."Inward Gate Entry Nos." <> '' then
            InventorySetup.Validate("Inward Gate Entry Nos.", InventorySetup."Inward Gate Entry Nos.")
        else
            InventorySetup.Validate("Inward Gate Entry Nos.", GateEntryLib.CreateNoSeries());
        if InventorySetup."Outward Gate Entry Nos." <> '' then
            InventorySetup.Validate("Outward Gate Entry Nos.", InventorySetup."Outward Gate Entry Nos.")
        else
            InventorySetup.Validate("Outward Gate Entry Nos.", GateEntryLib.CreateNoSeries());
        InventorySetup.Modify(true);
    end;

    [ModalPageHandler]
    procedure PostedGateEntryLineListHndlr(var PostedGateEntryLineList: TestPage "Posted Gate Entry Line List")
    begin
        PostedGateEntryLineList.OK().Invoke();
    end;

    [ConfirmHandler]
    procedure GateEntryPostConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [MessageHandler]
    procedure GateEntryPostMsgHandler(SuccessMessage: Text[1024])
    begin
    end;

    [PageHandler]
    procedure WhseReceiptHandler(var WarehouseReceipt: TestPage "Warehouse Receipt")
    begin
        WarehouseReceipt.Close();
    end;
}