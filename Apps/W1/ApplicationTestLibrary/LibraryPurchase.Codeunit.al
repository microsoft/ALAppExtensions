/// <summary>
/// Provides utility functions for creating and managing purchase documents in test scenarios, including purchase orders, invoices, and credit memos.
/// </summary>
codeunit 130512 "Library - Purchase"
{

    Permissions = TableData "Purchase Header" = rimd,
                  TableData "Purchase Line" = rimd;

    trigger OnRun()
    begin
    end;

    var
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        Assert: Codeunit Assert;
        LibraryUtility: Codeunit "Library - Utility";
        LibraryERM: Codeunit "Library - ERM";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryItemTracking: Codeunit "Library - Item Tracking";
        LibraryJournals: Codeunit "Library - Journals";
        LibraryRandom: Codeunit "Library - Random";
        LibraryResource: Codeunit "Library - Resource";
        LibraryFixedAsset: Codeunit "Library - Fixed Asset";
        WrongDocumentTypeErr: Label 'Document type not supported: %1', Locked = true;

    procedure AssignPurchChargeToPurchRcptLine(PurchaseHeader: Record "Purchase Header"; PurchRcptLine: Record "Purch. Rcpt. Line"; Qty: Decimal; DirectUnitCost: Decimal)
    var
        ItemCharge: Record "Item Charge";
        PurchaseLine: Record "Purchase Line";
        ItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)";
        LibraryPurchase: Codeunit "Library - Purchase";
    begin
        CreateItemChargePurchaseLine(PurchaseLine, ItemCharge, PurchaseHeader, Qty, DirectUnitCost);

        PurchRcptLine.TestField(Type, PurchRcptLine.Type::Item);

        LibraryPurchase.CreateItemChargeAssignment(ItemChargeAssignmentPurch, PurchaseLine, ItemCharge,
          ItemChargeAssignmentPurch."Applies-to Doc. Type"::Receipt,
          PurchRcptLine."Document No.", PurchRcptLine."Line No.",
          PurchRcptLine."No.", Qty, DirectUnitCost);
        ItemChargeAssignmentPurch.Insert();
    end;

    procedure AssignPurchChargeToPurchInvoiceLine(PurchaseHeader: Record "Purchase Header"; PurchInvLine: Record "Purch. Inv. Line"; Qty: Decimal; DirectUnitCost: Decimal)
    var
        ItemCharge: Record "Item Charge";
        PurchaseLine: Record "Purchase Line";
        ItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)";
        LibraryPurchase: Codeunit "Library - Purchase";
    begin
        CreateItemChargePurchaseLine(PurchaseLine, ItemCharge, PurchaseHeader, Qty, DirectUnitCost);

        PurchInvLine.TestField(Type, PurchInvLine.Type::Item);

        LibraryPurchase.CreateItemChargeAssignment(ItemChargeAssignmentPurch, PurchaseLine, ItemCharge,
          ItemChargeAssignmentPurch."Applies-to Doc. Type"::Invoice,
          PurchInvLine."Document No.", PurchInvLine."Line No.",
          PurchInvLine."No.", Qty, DirectUnitCost);
        ItemChargeAssignmentPurch.Insert();
    end;

    procedure AssignPurchChargeToPurchaseLine(PurchaseHeader: Record "Purchase Header"; PurchaseLine: Record "Purchase Line"; Qty: Decimal; DirectUnitCost: Decimal)
    var
        ItemCharge: Record "Item Charge";
        PurchaseLine1: Record "Purchase Line";
        ItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)";
        LibraryPurchase: Codeunit "Library - Purchase";
    begin
        CreateItemChargePurchaseLine(PurchaseLine1, ItemCharge, PurchaseHeader, Qty, DirectUnitCost);

        PurchaseLine.TestField(Type, PurchaseLine.Type::Item);

        LibraryPurchase.CreateItemChargeAssignment(ItemChargeAssignmentPurch, PurchaseLine1, ItemCharge,
          ItemChargeAssignmentPurch."Applies-to Doc. Type"::Order,
          PurchaseLine."Document No.", PurchaseLine."Line No.",
          PurchaseLine."No.", Qty, DirectUnitCost);
        ItemChargeAssignmentPurch.Insert();
    end;

    procedure AssignPurchChargeToPurchReturnLine(PurchaseHeader: Record "Purchase Header"; PurchaseLine: Record "Purchase Line"; Qty: Decimal; DirectUnitCost: Decimal)
    var
        ItemCharge: Record "Item Charge";
        PurchaseLine1: Record "Purchase Line";
        ItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)";
        LibraryPurchase: Codeunit "Library - Purchase";
    begin
        CreateItemChargePurchaseLine(PurchaseLine1, ItemCharge, PurchaseHeader, Qty, DirectUnitCost);

        PurchaseLine.TestField(Type, PurchaseLine.Type::Item);

        LibraryPurchase.CreateItemChargeAssignment(ItemChargeAssignmentPurch, PurchaseLine1, ItemCharge,
          ItemChargeAssignmentPurch."Applies-to Doc. Type"::"Return Order",
          PurchaseLine."Document No.", PurchaseLine."Line No.",
          PurchaseLine."No.", Qty, DirectUnitCost);
        ItemChargeAssignmentPurch.Insert();
    end;

    procedure CreateItemChargePurchaseLine(var PurchaseLine: Record "Purchase Line"; var ItemCharge: Record "Item Charge"; PurchaseHeader: Record "Purchase Header"; Qty: Decimal; DirectUnitCost: Decimal)
    var
        LibraryPurchase: Codeunit "Library - Purchase";
    begin
        LibraryInventory.CreateItemCharge(ItemCharge);
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::"Charge (Item)", ItemCharge."No.", Qty);
        PurchaseLine.Validate("Direct Unit Cost", DirectUnitCost);
        PurchaseLine.Modify(true);
    end;

    procedure BlanketPurchaseOrderMakeOrder(var PurchaseHeader: Record "Purchase Header"): Code[20]
    var
        PurchOrderHeader: Record "Purchase Header";
        BlanketPurchOrderToOrder: Codeunit "Blanket Purch. Order to Order";
    begin
        Clear(BlanketPurchOrderToOrder);
        BlanketPurchOrderToOrder.Run(PurchaseHeader);
        BlanketPurchOrderToOrder.GetPurchOrderHeader(PurchOrderHeader);
        exit(PurchOrderHeader."No.");
    end;

    procedure CopyPurchaseDocument(PurchaseHeader: Record "Purchase Header"; FromDocType: Enum "Purchase Document Type From"; FromDocNo: Code[20]; NewIncludeHeader: Boolean; NewRecalcLines: Boolean)
    var
        CopyPurchaseDocumentReport: Report "Copy Purchase Document";
    begin
        CopyPurchaseDocumentReport.SetPurchHeader(PurchaseHeader);
        CopyPurchaseDocumentReport.SetParameters(FromDocType, FromDocNo, NewIncludeHeader, NewRecalcLines);
        CopyPurchaseDocumentReport.UseRequestPage(false);
        CopyPurchaseDocumentReport.Run();
    end;

    procedure CreateItemChargeAssignment(var ItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)"; PurchaseLine: Record "Purchase Line"; ItemCharge: Record "Item Charge"; DocType: Enum "Purchase Applies-to Document Type"; DocNo: Code[20]; DocLineNo: Integer; ItemNo: Code[20]; Qty: Decimal; UnitCost: Decimal)
    var
        RecRef: RecordRef;
    begin
        Clear(ItemChargeAssignmentPurch);

        ItemChargeAssignmentPurch."Document Type" := PurchaseLine."Document Type";
        ItemChargeAssignmentPurch."Document No." := PurchaseLine."Document No.";
        ItemChargeAssignmentPurch."Document Line No." := PurchaseLine."Line No.";
        ItemChargeAssignmentPurch."Item Charge No." := PurchaseLine."No.";
        ItemChargeAssignmentPurch."Unit Cost" := PurchaseLine."Unit Cost";
        RecRef.GetTable(ItemChargeAssignmentPurch);
        ItemChargeAssignmentPurch."Line No." := LibraryUtility.GetNewLineNo(RecRef, ItemChargeAssignmentPurch.FieldNo("Line No."));
        ItemChargeAssignmentPurch."Item Charge No." := ItemCharge."No.";
        ItemChargeAssignmentPurch."Applies-to Doc. Type" := DocType;
        ItemChargeAssignmentPurch."Applies-to Doc. No." := DocNo;
        ItemChargeAssignmentPurch."Applies-to Doc. Line No." := DocLineNo;
        ItemChargeAssignmentPurch."Item No." := ItemNo;
        ItemChargeAssignmentPurch."Unit Cost" := UnitCost;
        ItemChargeAssignmentPurch.Validate("Qty. to Assign", Qty);
    end;

    procedure CreateOrderAddress(var OrderAddress: Record "Order Address"; VendorNo: Code[20])
    var
        PostCode: Record "Post Code";
    begin
        LibraryERM.CreatePostCode(PostCode);
        OrderAddress.Init();
        OrderAddress.Validate("Vendor No.", VendorNo);
        OrderAddress.Validate(
          Code,
          CopyStr(
            LibraryUtility.GenerateRandomCode(OrderAddress.FieldNo(Code), DATABASE::"Order Address"),
            1,
            LibraryUtility.GetFieldLength(DATABASE::"Order Address", OrderAddress.FieldNo(Code))));
        OrderAddress.Validate(Name, LibraryUtility.GenerateRandomText(MaxStrLen(OrderAddress.Name)));
        OrderAddress.Validate(Address, LibraryUtility.GenerateRandomText(MaxStrLen(OrderAddress.Address)));
        OrderAddress.Validate("Post Code", PostCode.Code);
        OrderAddress.Insert(true);
    end;

    procedure CreateRemitToAddress(var RemitToAddress: Record "Remit Address"; VendorNo: Code[20])
    var
        PostCode: Record "Post Code";
    begin
        LibraryERM.CreatePostCode(PostCode);
        RemitToAddress.Init();
        RemitToAddress.Validate("Vendor No.", VendorNo);
        RemitToAddress.Validate(
          Code,
          CopyStr(
            LibraryUtility.GenerateRandomCode(RemitToAddress.FieldNo(Code), DATABASE::"Remit Address"),
            1,
            LibraryUtility.GetFieldLength(DATABASE::"Remit Address", RemitToAddress.FieldNo(Code))));
        RemitToAddress.Validate(Name, LibraryUtility.GenerateRandomText(MaxStrLen(RemitToAddress.Name)));
        RemitToAddress.Validate(Address, LibraryUtility.GenerateRandomText(MaxStrLen(RemitToAddress.Address)));
        RemitToAddress.Validate("Post Code", PostCode.Code);
        RemitToAddress.Insert(true);
    end;

    procedure CreatePrepaymentVATSetup(var LineGLAccount: Record "G/L Account"; VATCalculationType: Enum "Tax Calculation Type"): Code[20]
    var
        PrepmtGLAccount: Record "G/L Account";
    begin
        LibraryERM.CreatePrepaymentVATSetup(
          LineGLAccount, PrepmtGLAccount, LineGLAccount."Gen. Posting Type"::Purchase, VATCalculationType, VATCalculationType);
        exit(PrepmtGLAccount."No.");
    end;

    procedure CreatePurchasingCode(var Purchasing: Record Purchasing)
    begin
        Purchasing.Init();
        Purchasing.Validate(
          Code,
          CopyStr(
            LibraryUtility.GenerateRandomCode(Purchasing.FieldNo(Code), DATABASE::Purchasing),
            1,
            LibraryUtility.GetFieldLength(DATABASE::Purchasing, Purchasing.FieldNo(Code))));
        Purchasing.Insert(true);
    end;

    procedure CreateDropShipmentPurchasingCode(var Purchasing: Record Purchasing)
    begin
        CreatePurchasingCode(Purchasing);
        Purchasing.Validate("Drop Shipment", true);
        Purchasing.Modify(true);
    end;

    procedure CreateSpecialOrderPurchasingCode(var Purchasing: Record Purchasing)
    begin
        CreatePurchasingCode(Purchasing);
        Purchasing.Validate("Special Order", true);
        Purchasing.Modify(true);
    end;

    procedure CreatePurchHeader(var PurchaseHeader: Record "Purchase Header"; DocumentType: Enum "Purchase Document Type"; BuyfromVendorNo: Code[20])
    begin
        DisableWarningOnCloseUnpostedDoc();
        DisableWarningOnCloseUnreleasedDoc();
        DisableConfirmOnPostingDoc();
        Clear(PurchaseHeader);
        OnBeforeCreatePurchaseHeader(PurchaseHeader, DocumentType, BuyFromVendorNo);
        PurchaseHeader.Validate("Document Type", DocumentType);
        PurchaseHeader.Insert(true);
        if BuyfromVendorNo = '' then
            BuyfromVendorNo := CreateVendorNo();
        PurchaseHeader.Validate("Buy-from Vendor No.", BuyfromVendorNo);
        if PurchaseHeader."Document Type" in [PurchaseHeader."Document Type"::"Credit Memo",
                                              PurchaseHeader."Document Type"::"Return Order"]
        then
            PurchaseHeader.Validate("Vendor Cr. Memo No.", LibraryUtility.GenerateGUID())
        else
            PurchaseHeader.Validate("Vendor Invoice No.", LibraryUtility.GenerateGUID());
        PurchaseHeader.Modify(true);
        OnAfterCreatePurchHeader(PurchaseHeader, DocumentType, BuyfromVendorNo);
    end;

    procedure CreatePurchHeaderWithDocNo(var PurchaseHeader: Record "Purchase Header"; DocumentType: Enum "Purchase Document Type"; BuyfromVendorNo: Code[20]; DocNo: Code[20])
    begin
        Clear(PurchaseHeader);
        PurchaseHeader.Validate("Document Type", DocumentType);
        PurchaseHeader."No." := DocNo;
        PurchaseHeader.Insert(true);
        if BuyfromVendorNo = '' then
            BuyfromVendorNo := CreateVendorNo();
        PurchaseHeader.Validate("Buy-from Vendor No.", BuyfromVendorNo);
        PurchaseHeader.Validate("Vendor Invoice No.", LibraryUtility.GenerateGUID());
        PurchaseHeader.Modify(true);
    end;

    procedure CreatePurchaseLine(var PurchaseLine: Record "Purchase Line"; PurchaseHeader: Record "Purchase Header"; LineType: Enum "Purchase Line Type"; No: Code[20]; Quantity: Decimal)
    begin
        CreatePurchaseLineSimple(PurchaseLine, PurchaseHeader);

        PurchaseLine.Validate(Type, LineType);
        case LineType of
            PurchaseLine.Type::Item:
                if No = '' then
                    No := LibraryInventory.CreateItemNo();
            PurchaseLine.Type::"G/L Account":
                if No = '' then
                    No := LibraryERM.CreateGLAccountWithPurchSetup();
            PurchaseLine.Type::"Charge (Item)":
                if No = '' then
                    No := LibraryInventory.CreateItemChargeNo();
            PurchaseLine.Type::Resource:
                if No = '' then
                    No := LibraryResource.CreateResourceNo();
            PurchaseLine.Type::"Fixed Asset":
                if No = '' then
                    No := LibraryFixedAsset.CreateFixedAssetNo();
        end;
        PurchaseLine.Validate("No.", No);
        if LineType <> PurchaseLine.Type::" " then
            PurchaseLine.Validate(Quantity, Quantity);
        PurchaseLine.Modify(true);

        OnAfterCreatePurchaseLine(PurchaseLine, PurchaseHeader, LineType, No, Quantity);
    end;

    procedure CreatePurchaseLineSimple(var PurchaseLine: Record "Purchase Line"; PurchaseHeader: Record "Purchase Header")
    var
        RecRef: RecordRef;
    begin
        PurchaseLine.Init();
        PurchaseLine.Validate("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.Validate("Document No.", PurchaseHeader."No.");
        RecRef.GetTable(PurchaseLine);
        PurchaseLine.Validate("Line No.", LibraryUtility.GetNewLineNo(RecRef, PurchaseLine.FieldNo("Line No.")));
        PurchaseLine.Insert(true);
    end;

    procedure CreatePurchaseLineWithUnitCost(var PurchaseLine: Record "Purchase Line"; PurchaseHeader: Record "Purchase Header"; ItemNo: Code[20]; UnitCost: Decimal; Quantity: Decimal)
    begin
        CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::Item, ItemNo, Quantity);
        PurchaseLine.Validate("Direct Unit Cost", UnitCost);
        PurchaseLine.Modify();
    end;

    procedure CreatePurchaseQuote(var PurchaseHeader: Record "Purchase Header")
    var
        PurchaseLine: Record "Purchase Line";
    begin
        CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Quote, CreateVendorNo());
        CreatePurchaseLine(
          PurchaseLine, PurchaseHeader, PurchaseLine.Type::Item, LibraryInventory.CreateItemNo(), LibraryRandom.RandInt(100));
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandDecInRange(1, 99, 2));
        PurchaseLine.Modify(true);
    end;

    procedure CreatePurchaseInvoice(var PurchaseHeader: Record "Purchase Header")
    begin
        CreatePurchaseInvoiceForVendorNo(PurchaseHeader, CreateVendorNo());
    end;

    procedure CreatePurchaseInvoiceForVendorNo(var PurchaseHeader: Record "Purchase Header"; VendorNo: Code[20])
    var
        PurchaseLine: Record "Purchase Line";
    begin
        CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Invoice, VendorNo);
        CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::Item, LibraryInventory.CreateItemNo(), LibraryRandom.RandInt(100));
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandDecInRange(1, 100, 2));
        PurchaseLine.Modify(true);
    end;

    procedure CreatePurchaseOrder(var PurchaseHeader: Record "Purchase Header")
    begin
        CreatePurchaseOrderForVendorNo(PurchaseHeader, CreateVendorNo());
    end;

    procedure CreatePurchaseOrderForVendorNo(var PurchaseHeader: Record "Purchase Header"; VendorNo: Code[20])
    var
        PurchaseLine: Record "Purchase Line";
    begin
        CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Order, VendorNo);
        CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::Item, LibraryInventory.CreateItemNo(), LibraryRandom.RandInt(100));
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandDecInRange(1, 100, 2));
        PurchaseLine.Modify(true);
    end;

    procedure CreatePurchaseCreditMemo(var PurchaseHeader: Record "Purchase Header")
    begin
        CreatePurchaseCreditMemoForVendorNo(PurchaseHeader, CreateVendorNo());
    end;

    procedure CreatePurchaseCreditMemoForVendorNo(var PurchaseHeader: Record "Purchase Header"; VendorNo: Code[20])
    var
        PurchaseLine: Record "Purchase Line";
    begin
        CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::"Credit Memo", VendorNo);
        CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::Item, LibraryInventory.CreateItemNo(), LibraryRandom.RandInt(100));
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandDecInRange(1, 100, 2));
        PurchaseLine.Modify(true);
    end;

    procedure CreatePurchaseOrderWithLocation(var PurchaseHeader: Record "Purchase Header"; VendorNo: Code[20]; LocationCode: Code[10])
    begin
        CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Order, VendorNo);
        PurchaseHeader.Validate("Vendor Invoice No.", PurchaseHeader."No.");
        PurchaseHeader.Validate("Location Code", LocationCode);
        PurchaseHeader.Modify();
    end;

    procedure CreatePurchaseReturnOrderWithLocation(var PurchaseHeader: Record "Purchase Header"; VendorNo: Code[20]; LocationCode: Code[10])
    begin
        CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::"Return Order", VendorNo);
        PurchaseHeader.Validate("Vendor Cr. Memo No.", PurchaseHeader."No.");
        PurchaseHeader.Validate("Location Code", LocationCode);
        PurchaseHeader.Modify();
    end;

    procedure CreatePurchaseCreditMemoWithLocation(var PurchaseHeader: Record "Purchase Header"; VendorNo: Code[20]; LocationCode: Code[10])
    begin
        CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::"Credit Memo", VendorNo);
        PurchaseHeader.Validate("Vendor Cr. Memo No.", PurchaseHeader."No.");
        PurchaseHeader.Validate("Location Code", LocationCode);
        PurchaseHeader.Modify();
    end;

    procedure CreatePurchaseReturnOrder(var PurchaseHeader: Record "Purchase Header")
    var
        PurchaseLine: Record "Purchase Line";
    begin
        CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::"Return Order", CreateVendorNo());
        CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::Item, LibraryInventory.CreateItemNo(), LibraryRandom.RandInt(100));
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandDecInRange(1, 100, 2));
        PurchaseLine.Modify(true);
    end;

    procedure CreatePurchaseDocument(var PurchaseHeader: Record "Purchase Header"; var PurchaseLine: Record "Purchase Line"; DocType: Enum "Purchase Document Type"; Item: Record Item; LocationCode: Code[10]; VariantCode: Code[10]; Qty: Decimal; PostingDate: Date; DirectUnitCost: Decimal)
    begin
        CreatePurchHeader(PurchaseHeader, DocType, '');
        PurchaseHeader.Validate("Posting Date", PostingDate);
        PurchaseHeader.Modify(true);
        CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::Item, Item."No.", Qty);
        PurchaseLine."Location Code" := LocationCode;
        PurchaseLine."Variant Code" := VariantCode;
        PurchaseLine.Validate("Direct Unit Cost", DirectUnitCost);
        PurchaseLine.Modify(true);
    end;

    procedure CreatePurchaseOrder(var PurchaseHeader: Record "Purchase Header"; var PurchaseLine: Record "Purchase Line"; Item: Record Item; LocationCode: Code[10]; VariantCode: Code[10]; Qty: Decimal; PostingDate: Date; DirectUnitCost: Decimal)
    begin
        CreatePurchaseDocument(
          PurchaseHeader, PurchaseLine, PurchaseHeader."Document Type"::Order, Item, LocationCode, VariantCode, Qty, PostingDate,
          DirectUnitCost);
    end;

    procedure CreatePurchaseQuote(var PurchaseHeader: Record "Purchase Header"; var PurchaseLine: Record "Purchase Line"; Item: Record Item; LocationCode: Code[10]; VariantCode: Code[10]; Qty: Decimal; PostingDate: Date; DirectUnitCost: Decimal)
    begin
        CreatePurchaseDocument(
          PurchaseHeader, PurchaseLine, PurchaseHeader."Document Type"::Quote,
          Item, LocationCode, VariantCode, Qty, PostingDate, DirectUnitCost);
    end;

    procedure CreatePurchaseBlanketOrder(var PurchaseHeader: Record "Purchase Header"; var PurchaseLine: Record "Purchase Line"; Item: Record Item; LocationCode: Code[10]; VariantCode: Code[10]; Qty: Decimal; PostingDate: Date; DirectUnitCost: Decimal)
    begin
        CreatePurchaseDocument(
          PurchaseHeader, PurchaseLine, PurchaseHeader."Document Type"::"Blanket Order",
          Item, LocationCode, VariantCode, Qty, PostingDate, DirectUnitCost);
    end;

    procedure CreatePurchaseReturnOrder(var PurchaseHeader: Record "Purchase Header"; var PurchaseLine: Record "Purchase Line"; Item: Record Item; LocationCode: Code[10]; VariantCode: Code[10]; Qty: Decimal; PostingDate: Date; DirectUnitCost: Decimal)
    begin
        CreatePurchaseDocument(
          PurchaseHeader, PurchaseLine, PurchaseHeader."Document Type"::"Return Order", Item, LocationCode, VariantCode, Qty, PostingDate,
          DirectUnitCost);
    end;

    procedure CreatePurchaseCreditMemo(var PurchaseHeader: Record "Purchase Header"; var PurchaseLine: Record "Purchase Line"; Item: Record Item; LocationCode: Code[10]; VariantCode: Code[10]; Qty: Decimal; PostingDate: Date; DirectUnitCost: Decimal)
    begin
        CreatePurchaseDocument(
            PurchaseHeader, PurchaseLine, PurchaseHeader."Document Type"::"Credit Memo",
            Item, LocationCode, VariantCode, Qty, PostingDate, DirectUnitCost);
    end;

    procedure CreatePurchaseInvoice(var PurchaseHeader: Record "Purchase Header"; var PurchaseLine: Record "Purchase Line"; Item: Record Item; LocationCode: Code[10]; VariantCode: Code[10]; Qty: Decimal; PostingDate: Date; DirectUnitCost: Decimal)
    begin
        CreatePurchaseDocument(
          PurchaseHeader, PurchaseLine, PurchaseHeader."Document Type"::Invoice, Item, LocationCode, VariantCode, Qty, PostingDate,
          DirectUnitCost);
    end;

    procedure CreatePurchCommentLine(var PurchCommentLine: Record "Purch. Comment Line"; DocumentType: Enum "Purchase Comment Document Type"; No: Code[20]; DocumentLineNo: Integer)
    var
        RecRef: RecordRef;
    begin
        PurchCommentLine.Init();
        PurchCommentLine.Validate("Document Type", DocumentType);
        PurchCommentLine.Validate("No.", No);
        PurchCommentLine.Validate("Document Line No.", DocumentLineNo);
        RecRef.GetTable(PurchCommentLine);
        PurchCommentLine.Validate("Line No.", LibraryUtility.GetNewLineNo(RecRef, PurchCommentLine.FieldNo("Line No.")));
        PurchCommentLine.Insert(true);
        // Validate Comment as primary key to enable user to distinguish between comments because value is not important.
        PurchCommentLine.Validate(
          Comment, Format(PurchCommentLine."Document Type") + PurchCommentLine."No." +
          Format(PurchCommentLine."Document Line No.") + Format(PurchCommentLine."Line No."));
        PurchCommentLine.Modify(true);
    end;

    procedure CreatePurchaseDocumentWithItem(var PurchaseHeader: Record "Purchase Header"; var PurchaseLine: Record "Purchase Line"; DocumentType: Enum "Purchase Document Type"; VendorNo: Code[20]; ItemNo: Code[20]; Quantity: Decimal; LocationCode: Code[10]; ExpectedReceiptDate: Date)
    begin
        CreateFCYPurchaseDocumentWithItem(
          PurchaseHeader, PurchaseLine, DocumentType, VendorNo, ItemNo, Quantity, LocationCode, ExpectedReceiptDate, '');
    end;

    procedure CreateFCYPurchaseDocumentWithItem(var PurchaseHeader: Record "Purchase Header"; var PurchaseLine: Record "Purchase Line"; DocumentType: Enum "Purchase Document Type"; VendorNo: Code[20]; ItemNo: Code[20]; Quantity: Decimal; LocationCode: Code[10]; ExpectedReceiptDate: Date; CurrencyCode: Code[10])
    begin
        CreatePurchHeader(PurchaseHeader, DocumentType, VendorNo);
        if LocationCode <> '' then
            PurchaseHeader.Validate("Location Code", LocationCode);
        PurchaseHeader.Validate("Currency Code", CurrencyCode);
        PurchaseHeader.Modify(true);
        if ItemNo = '' then
            ItemNo := LibraryInventory.CreateItemNo();
        CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::Item, ItemNo, Quantity);
        if LocationCode <> '' then
            PurchaseLine.Validate("Location Code", LocationCode);
        if ExpectedReceiptDate <> 0D then
            PurchaseLine.Validate("Expected Receipt Date", ExpectedReceiptDate);
        PurchaseLine.Modify(true);
    end;

    procedure CreatePurchasePrepaymentPct(var PurchasePrepaymentPct: Record "Purchase Prepayment %"; ItemNo: Code[20]; VendorNo: Code[20]; StartingDate: Date)
    begin
        PurchasePrepaymentPct.Init();
        PurchasePrepaymentPct.Validate("Item No.", ItemNo);
        PurchasePrepaymentPct.Validate("Vendor No.", VendorNo);
        PurchasePrepaymentPct.Validate("Starting Date", StartingDate);
        PurchasePrepaymentPct.Insert(true);
    end;

    procedure CreateStandardPurchaseCode(var StandardPurchaseCode: Record "Standard Purchase Code")
    begin
        StandardPurchaseCode.Init();
        StandardPurchaseCode.Validate(
          Code,
          CopyStr(
            LibraryUtility.GenerateRandomCode(StandardPurchaseCode.FieldNo(Code), DATABASE::"Standard Purchase Code"),
            1,
            LibraryUtility.GetFieldLength(DATABASE::"Standard Purchase Code", StandardPurchaseCode.FieldNo(Code))));
        // Validating Description as Code because value is not important.
        StandardPurchaseCode.Validate(Description, StandardPurchaseCode.Code);
        StandardPurchaseCode.Insert(true);
    end;

    procedure CreateStandardPurchaseLine(var StandardPurchaseLine: Record "Standard Purchase Line"; StandardPurchaseCode: Code[10])
    var
        RecRef: RecordRef;
    begin
        StandardPurchaseLine.Init();
        StandardPurchaseLine.Validate("Standard Purchase Code", StandardPurchaseCode);
        RecRef.GetTable(StandardPurchaseLine);
        StandardPurchaseLine.Validate("Line No.", LibraryUtility.GetNewLineNo(RecRef, StandardPurchaseLine.FieldNo("Line No.")));
        StandardPurchaseLine.Insert(true);
    end;

    procedure CreateVendorDocumentLayout(VendorNo: Code[20]; ReportSelectionUsage: Enum "Report Selection Usage"; ReportID: Integer; CustomReportLayoutCode: Code[20]; EmailAddress: Text)
    var
        CustomReportSelection: Record "Custom Report Selection";
    begin
        CustomReportSelection.Init();
        CustomReportSelection.Validate("Source Type", Database::Vendor);
        CustomReportSelection.Validate("Source No.", VendorNo);
        CustomReportSelection.Validate(Usage, ReportSelectionUsage);
        CustomReportSelection.Validate("Report ID", ReportID);
        CustomReportSelection.Validate("Custom Report Layout Code", CustomReportLayoutCode);
        CustomReportSelection.Validate("Send To Email", CopyStr(EmailAddress, 1, MaxStrLen(CustomReportSelection."Send To Email")));
        CustomReportSelection.Insert(true);
    end;

    procedure CreateSubcontractor(var Vendor: Record Vendor)
    begin
        CreateVendor(Vendor);
    end;

    procedure CreateVendor(var Vendor: Record Vendor): Code[20]
    var
        PaymentMethod: Record "Payment Method";
        GeneralPostingSetup: Record "General Posting Setup";
        VATPostingSetup: Record "VAT Posting Setup";
        VendContUpdate: Codeunit "VendCont-Update";
    begin
        LibraryERM.FindPaymentMethod(PaymentMethod);
        LibraryERM.SetSearchGenPostingTypePurch();
        LibraryERM.FindGeneralPostingSetupInvtFull(GeneralPostingSetup);
        LibraryERM.FindVATPostingSetupInvt(VATPostingSetup);
        LibraryUtility.UpdateSetupNoSeriesCode(
          DATABASE::"Purchases & Payables Setup", PurchasesPayablesSetup.FieldNo("Vendor Nos."));

        Clear(Vendor);
        Vendor.Insert(true);
        Vendor.Validate(Name, Vendor."No."); // Validating Name as No. because value is not important.
        Vendor.Validate("Gen. Bus. Posting Group", GeneralPostingSetup."Gen. Bus. Posting Group");
        Vendor.Validate("VAT Bus. Posting Group", VATPostingSetup."VAT Bus. Posting Group");
        Vendor.Validate("Vendor Posting Group", FindVendorPostingGroup());
        Vendor.Validate("Payment Terms Code", LibraryERM.FindPaymentTermsCode());
        Vendor.Validate("Payment Method Code", PaymentMethod.Code);
        Vendor.Modify(true);
        VendContUpdate.OnModify(Vendor);

        OnAfterCreateVendor(Vendor);
        exit(Vendor."No.");
    end;

    procedure CreateVendorNo(): Code[20]
    var
        Vendor: Record Vendor;
    begin
        CreateVendor(Vendor);
        exit(Vendor."No.");
    end;

    procedure CreateVendorPostingGroup(var VendorPostingGroup: Record "Vendor Posting Group")
    begin
        VendorPostingGroup.Init();
        VendorPostingGroup.Validate(Code,
          LibraryUtility.GenerateRandomCode(VendorPostingGroup.FieldNo(Code), DATABASE::"Vendor Posting Group"));
        VendorPostingGroup.Validate("Payables Account", LibraryERM.CreateGLAccountNo());
        VendorPostingGroup.Validate("Service Charge Acc.", LibraryERM.CreateGLAccountWithPurchSetup());
        VendorPostingGroup.Validate("Invoice Rounding Account", LibraryERM.CreateGLAccountWithPurchSetup());
        VendorPostingGroup.Validate("Debit Rounding Account", LibraryERM.CreateGLAccountNo());
        VendorPostingGroup.Validate("Credit Rounding Account", LibraryERM.CreateGLAccountNo());
        VendorPostingGroup.Validate("Payment Disc. Debit Acc.", LibraryERM.CreateGLAccountNo());
        VendorPostingGroup.Validate("Payment Disc. Credit Acc.", LibraryERM.CreateGLAccountNo());
        VendorPostingGroup.Validate("Payment Tolerance Debit Acc.", LibraryERM.CreateGLAccountNo());
        VendorPostingGroup.Validate("Payment Tolerance Credit Acc.", LibraryERM.CreateGLAccountNo());
        VendorPostingGroup.Validate("Debit Curr. Appln. Rndg. Acc.", LibraryERM.CreateGLAccountNo());
        VendorPostingGroup.Validate("Credit Curr. Appln. Rndg. Acc.", LibraryERM.CreateGLAccountNo());
        VendorPostingGroup.Insert(true);
    end;

    procedure CreateAltVendorPostingGroup(ParentCode: Code[10]; AltCode: Code[10])
    var
        AltVendorPostingGroup: Record "Alt. Vendor Posting Group";
    begin
        AltVendorPostingGroup.Init();
        AltVendorPostingGroup."Vendor Posting Group" := ParentCode;
        AltVendorPostingGroup."Alt. Vendor Posting Group" := AltCode;
        AltVendorPostingGroup.Insert();
    end;

    procedure CreateVendorWithLocationCode(var Vendor: Record Vendor; LocationCode: Code[10]): Code[20]
    begin
        CreateVendor(Vendor);
        Vendor.Validate("Location Code", LocationCode);
        Vendor.Modify(true);
        exit(Vendor."No.");
    end;

    procedure CreateVendorWithBusPostingGroups(GenBusPostGroupCode: Code[20]; VATBusPostGroupCode: Code[20]): Code[20]
    var
        Vendor: Record Vendor;
    begin
        CreateVendor(Vendor);
        Vendor.Validate("Gen. Bus. Posting Group", GenBusPostGroupCode);
        Vendor.Validate("VAT Bus. Posting Group", VATBusPostGroupCode);
        Vendor.Modify(true);
        exit(Vendor."No.");
    end;

    procedure CreateVendorWithVATBusPostingGroup(VATBusPostGroupCode: Code[20]): Code[20]
    var
        Vendor: Record Vendor;
    begin
        CreateVendor(Vendor);
        Vendor.Validate("VAT Bus. Posting Group", VATBusPostGroupCode);
        Vendor.Modify(true);
        exit(Vendor."No.");
    end;

    procedure CreateVendorWithVATRegNo(var Vendor: Record Vendor): Code[20]
    var
        CountryRegion: Record "Country/Region";
    begin
        CreateVendor(Vendor);
        LibraryERM.CreateCountryRegion(CountryRegion);
        Vendor.Validate("Country/Region Code", CountryRegion.Code);
        Vendor."VAT Registration No." := LibraryERM.GenerateVATRegistrationNo(CountryRegion.Code);
        Vendor.Modify(true);
        exit(Vendor."No.");
    end;

    procedure CreateVendorWithAddress(var Vendor: Record Vendor)
    var
        PostCode: Record "Post Code";
    begin
        LibraryERM.CreatePostCode(PostCode);
        CreateVendor(Vendor);
        Vendor.Validate(Name, LibraryUtility.GenerateRandomText(MaxStrLen(Vendor.Name)));
        Vendor.Validate(Address, LibraryUtility.GenerateRandomText(MaxStrLen(Vendor.Address)));
        Vendor.Validate("Address 2", LibraryUtility.GenerateRandomText(MaxStrLen(Vendor."Address 2")));
        Vendor.Validate("Country/Region Code", PostCode."Country/Region Code");
        Vendor.Validate(City, PostCode.City);
        Vendor.Validate(County, LibraryUtility.GenerateRandomText(MaxStrLen(Vendor.County)));
        Vendor.Validate("Post Code", PostCode.Code);
        Vendor.Contact := CopyStr(LibraryUtility.GenerateRandomText(MaxStrLen(Vendor.Contact)), 1, MaxStrLen(Vendor.Contact));
        Vendor.Modify(true);
    end;

    procedure CreateVendorBankAccount(var VendorBankAccount: Record "Vendor Bank Account"; VendorNo: Code[20])
    begin
        VendorBankAccount.Init();
        VendorBankAccount.Validate("Vendor No.", VendorNo);
        VendorBankAccount.Validate(
          Code,
          CopyStr(
            LibraryUtility.GenerateRandomCode(VendorBankAccount.FieldNo(Code), DATABASE::"Vendor Bank Account"),
            1,
            LibraryUtility.GetFieldLength(DATABASE::"Vendor Bank Account", VendorBankAccount.FieldNo(Code))));
        VendorBankAccount.Insert(true);
    end;

    procedure CreateVendorPurchaseCode(var StandardVendorPurchaseCode: Record "Standard Vendor Purchase Code"; VendorNo: Code[20]; "Code": Code[10])
    begin
        StandardVendorPurchaseCode.Init();
        StandardVendorPurchaseCode.Validate("Vendor No.", VendorNo);
        StandardVendorPurchaseCode.Validate(Code, Code);
        StandardVendorPurchaseCode.Insert(true);
    end;

    procedure CreatePurchaseHeaderPostingJobQueueEntry(var JobQueueEntry: Record "Job Queue Entry"; PurchaseHeader: Record "Purchase Header")
    begin
        JobQueueEntry.Init();
        JobQueueEntry.ID := CreateGuid();
        JobQueueEntry."Earliest Start Date/Time" := CreateDateTime(Today, 0T);
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := CODEUNIT::"Purchase Post via Job Queue";
        JobQueueEntry."Record ID to Process" := PurchaseHeader.RecordId;
        JobQueueEntry."Run in User Session" := true;
        JobQueueEntry.Insert(true);
    end;

    procedure CreateIntrastatContact(CountryRegionCode: Code[10]): Code[20]
    var
        Vendor: Record Vendor;
    begin
        CreateVendor(Vendor);
        Vendor.Validate(Name, LibraryUtility.GenerateGUID());
        Vendor.Validate(Address, LibraryUtility.GenerateGUID());
        Vendor.Validate("Country/Region Code", CountryRegionCode);
        Vendor.Validate("Post Code", LibraryUtility.GenerateGUID());
        Vendor.Validate(City, LibraryUtility.GenerateGUID());
        Vendor.Validate("Phone No.", Format(LibraryRandom.RandIntInRange(100000000, 999999999)));
        Vendor.Validate("Fax No.", LibraryUtility.GenerateGUID());
        Vendor.Validate("E-Mail", LibraryUtility.GenerateGUID() + '@' + LibraryUtility.GenerateGUID());
        Vendor.Modify(true);
        exit(Vendor."No.");
    end;

    procedure DeleteInvoicedPurchOrders(var PurchaseHeader: Record "Purchase Header")
    var
        PurchaseHeader2: Record "Purchase Header";
        DeleteInvoicedPurchOrdersReport: Report "Delete Invoiced Purch. Orders";
    begin
        if PurchaseHeader.HasFilter then
            PurchaseHeader2.CopyFilters(PurchaseHeader)
        else begin
            PurchaseHeader.Get(PurchaseHeader."Document Type", PurchaseHeader."No.");
            PurchaseHeader2.SetRange("Document Type", PurchaseHeader."Document Type");
            PurchaseHeader2.SetRange("No.", PurchaseHeader."No.");
        end;
        Clear(DeleteInvoicedPurchOrdersReport);
        DeleteInvoicedPurchOrdersReport.SetTableView(PurchaseHeader2);
        DeleteInvoicedPurchOrdersReport.UseRequestPage(false);
        DeleteInvoicedPurchOrdersReport.RunModal();
    end;

    procedure ExplodeBOM(var PurchaseLine: Record "Purchase Line")
    var
        PurchExplodeBOM: Codeunit "Purch.-Explode BOM";
    begin
        Clear(PurchExplodeBOM);
        PurchExplodeBOM.Run(PurchaseLine);
    end;

    procedure FilterPurchaseHeaderArchive(var PurchaseHeaderArchive: Record "Purchase Header Archive"; DocumentType: Enum "Purchase Document Type"; DocumentNo: Code[20]; DocNoOccurance: Integer; Version: Integer)
    begin
        PurchaseHeaderArchive.SetRange("Document Type", DocumentType);
        PurchaseHeaderArchive.SetRange("No.", DocumentNo);
        PurchaseHeaderArchive.SetRange("Doc. No. Occurrence", DocNoOccurance);
        PurchaseHeaderArchive.SetRange("Version No.", Version);
    end;

    procedure FilterPurchaseLineArchive(var PurchaseLineArchive: Record "Purchase Line Archive"; DocumentType: Enum "Purchase Document Type"; DocumentNo: Code[20]; DocNoOccurance: Integer; Version: Integer)
    begin
        PurchaseLineArchive.SetRange("Document Type", DocumentType);
        PurchaseLineArchive.SetRange("Document No.", DocumentNo);
        PurchaseLineArchive.SetRange("Doc. No. Occurrence", DocNoOccurance);
        PurchaseLineArchive.SetRange("Version No.", Version);
    end;

    procedure FindVendorPostingGroup(): Code[20]
    var
        VendorPostingGroup: Record "Vendor Posting Group";
    begin
        if not VendorPostingGroup.FindFirst() then
            CreateVendorPostingGroup(VendorPostingGroup);
        exit(VendorPostingGroup.Code);
    end;

    procedure FindFirstPurchLine(var PurchaseLine: Record "Purchase Line"; PurchaseHeader: Record "Purchase Header")
    begin
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.FindFirst();
    end;

    procedure FindReturnShipmentHeader(var ReturnShipmentHeader: Record "Return Shipment Header"; ReturnOrderNo: Code[20])
    begin
        ReturnShipmentHeader.SetRange("Return Order No.", ReturnOrderNo);
        ReturnShipmentHeader.FindFirst();
    end;

    procedure GetDropShipment(var PurchaseHeader: Record "Purchase Header")
    var
        PurchGetDropShpt: Codeunit "Purch.-Get Drop Shpt.";
    begin
        Clear(PurchGetDropShpt);
        PurchGetDropShpt.Run(PurchaseHeader);
    end;

    procedure GetInvRoundingAccountOfVendPostGroup(VendorPostingGroupCode: Code[20]): Code[20]
    var
        VendorPostingGroup: Record "Vendor Posting Group";
    begin
        VendorPostingGroup.Get(VendorPostingGroupCode);
        exit(VendorPostingGroup."Invoice Rounding Account");
    end;

    procedure GetPurchaseReturnShipmentLine(var PurchaseLine: Record "Purchase Line")
    var
        PurchGetReturnShipments: Codeunit "Purch.-Get Return Shipments";
    begin
        PurchGetReturnShipments.Run(PurchaseLine);
    end;

    procedure GetPurchaseReceiptLine(var PurchaseLine: Record "Purchase Line")
    var
        PurchGetReceipt: Codeunit "Purch.-Get Receipt";
    begin
        Clear(PurchGetReceipt);
        PurchGetReceipt.Run(PurchaseLine);
    end;

    procedure GetSpecialOrder(var PurchaseHeader: Record "Purchase Header")
    var
        DistIntegration: Codeunit "Dist. Integration";
    begin
        Clear(DistIntegration);
        DistIntegration.GetSpecialOrders(PurchaseHeader);
    end;

    procedure GegVendorLedgerEntryUniqueExternalDocNo(): Code[10]
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        exit(
          LibraryUtility.GenerateRandomCodeWithLength(
            VendorLedgerEntry.FieldNo("External Document No."),
            DATABASE::"Vendor Ledger Entry",
            10));
    end;

    procedure PostPurchaseOrder(var PurchaseHeader: Record "Purchase Header"; Item: Record Item; LocationCode: Code[10]; VariantCode: Code[10]; Qty: Decimal; PostingDate: Date; DirectUnitCost: Decimal; Receive: Boolean; Invoice: Boolean)
    begin
        PostPurchaseOrderPartially(PurchaseHeader, Item, LocationCode, VariantCode, Qty, PostingDate, DirectUnitCost, Receive, Qty, Invoice, Qty);
    end;

    procedure PostPurchaseOrderWithItemTracking(var PurchaseHeader: Record "Purchase Header"; Item: Record Item; LocationCode: Code[10]; VariantCode: Code[10]; Qty: Decimal; PostingDate: Date; DirectUnitCost: Decimal; Receive: Boolean; Invoice: Boolean; SerialNo: Code[50]; LotNo: Code[50])
    var
        PurchaseLine: Record "Purchase Line";
        ReservEntry: Record "Reservation Entry";
    begin
        CreatePurchaseOrder(PurchaseHeader, PurchaseLine, Item, LocationCode, VariantCode, Qty, PostingDate, DirectUnitCost);
        PurchaseLine.Validate("Qty. to Receive", Qty);
        PurchaseLine.Validate("Qty. to Invoice", Qty);
        PurchaseLine.Modify();
        LibraryItemTracking.CreatePurchOrderItemTracking(ReservEntry, PurchaseLine, SerialNo, LotNo, Qty);
        if Invoice then
            SetVendorDocNo(PurchaseHeader);
        PostPurchaseDocument(PurchaseHeader, Receive, Invoice);
    end;

    procedure PostPurchaseOrderPartially(var PurchaseHeader: Record "Purchase Header"; Item: Record Item; LocationCode: Code[10]; VariantCode: Code[10]; Qty: Decimal; PostingDate: Date; DirectUnitCost: Decimal; Receive: Boolean; ReceiveQty: Decimal; Invoice: Boolean; InvoiceQty: Decimal)
    var
        PurchaseLine: Record "Purchase Line";
    begin
        CreatePurchaseOrder(PurchaseHeader, PurchaseLine, Item, LocationCode, VariantCode, Qty, PostingDate, DirectUnitCost);
        PurchaseLine.Validate("Qty. to Receive", ReceiveQty);
        PurchaseLine.Validate("Qty. to Invoice", InvoiceQty);
        PurchaseLine.Modify();
        if Invoice then
            SetVendorDocNo(PurchaseHeader);
        PostPurchaseDocument(PurchaseHeader, Receive, Invoice);
    end;

    procedure PostPurchasePrepaymentCrMemo(var PurchaseHeader: Record "Purchase Header")
    var
        PurchPostPrepayments: Codeunit "Purchase-Post Prepayments";
    begin
        PurchPostPrepayments.CreditMemo(PurchaseHeader);
    end;

    procedure PostPurchasePrepaymentCreditMemo(var PurchaseHeader: Record "Purchase Header") DocumentNo: Code[20]
    var
        PurchPostPrepayments: Codeunit "Purchase-Post Prepayments";
        NoSeries: Codeunit "No. Series";
        NoSeriesCode: Code[20];
    begin
        NoSeriesCode := PurchaseHeader."Prepmt. Cr. Memo No. Series";
        if PurchaseHeader."Prepmt. Cr. Memo No." = '' then
            DocumentNo := NoSeries.PeekNextNo(NoSeriesCode, LibraryUtility.GetNextNoSeriesPurchaseDate(NoSeriesCode))
        else
            DocumentNo := PurchaseHeader."Prepmt. Cr. Memo No.";
        PurchPostPrepayments.CreditMemo(PurchaseHeader);
    end;

    procedure PostPurchasePrepaymentInvoice(var PurchaseHeader: Record "Purchase Header") DocumentNo: Code[20]
    var
        PurchasePostPrepayments: Codeunit "Purchase-Post Prepayments";
        NoSeries: Codeunit "No. Series";
        NoSeriesCode: Code[20];
    begin
        NoSeriesCode := PurchaseHeader."Prepayment No. Series";
        if PurchaseHeader."Prepayment No." = '' then
            DocumentNo := NoSeries.PeekNextNo(NoSeriesCode, LibraryUtility.GetNextNoSeriesPurchaseDate(NoSeriesCode))
        else
            DocumentNo := PurchaseHeader."Prepayment No.";
        PurchasePostPrepayments.Invoice(PurchaseHeader);
    end;

    procedure PostPurchaseDocument(var PurchaseHeader: Record "Purchase Header"; NewShipReceive: Boolean; NewInvoice: Boolean) DocumentNo: Code[20]
    var
        NoSeries: Codeunit "No. Series";
        PurchPost: Codeunit "Purch.-Post";
        RecRef: RecordRef;
        FieldRef: FieldRef;
        DocumentFieldNo: Integer;
    begin
        // Post the purchase document.
        // Depending on the document type and posting type return the number of the:
        // - purchase receipt,
        // - posted purchase invoice,
        // - purchase return shipment, or
        // - posted credit memo
        PurchaseHeader.Validate(Receive, NewShipReceive);
        PurchaseHeader.Validate(Ship, NewShipReceive);
        PurchaseHeader.Validate(Invoice, NewInvoice);
        PurchPost.SetPostingFlags(PurchaseHeader);

        case PurchaseHeader."Document Type" of
            PurchaseHeader."Document Type"::Invoice, PurchaseHeader."Document Type"::"Credit Memo":
                if PurchaseHeader.Invoice and (PurchaseHeader."Posting No. Series" <> '') then begin
                    if (PurchaseHeader."Posting No." = '') then
                        PurchaseHeader."Posting No." := NoSeries.GetNextNo(PurchaseHeader."Posting No. Series", LibraryUtility.GetNextNoSeriesPurchaseDate(PurchaseHeader."Posting No. Series"));
                    DocumentFieldNo := PurchaseHeader.FieldNo("Last Posting No.");
                end;
            PurchaseHeader."Document Type"::Order:
                begin
                    if PurchaseHeader.Receive and (PurchaseHeader."Receiving No. Series" <> '') then begin
                        if (PurchaseHeader."Receiving No." = '') then
                            PurchaseHeader."Receiving No." := NoSeries.GetNextNo(PurchaseHeader."Receiving No. Series", LibraryUtility.GetNextNoSeriesPurchaseDate(PurchaseHeader."Receiving No. Series"));
                        DocumentFieldNo := PurchaseHeader.FieldNo("Last Receiving No.");
                    end;
                    if PurchaseHeader.Invoice and (PurchaseHeader."Posting No. Series" <> '') then begin
                        if (PurchaseHeader."Posting No." = '') then
                            PurchaseHeader."Posting No." := NoSeries.GetNextNo(PurchaseHeader."Posting No. Series", LibraryUtility.GetNextNoSeriesPurchaseDate(PurchaseHeader."Posting No. Series"));
                        DocumentFieldNo := PurchaseHeader.FieldNo("Last Posting No.");
                    end;
                end;
            PurchaseHeader."Document Type"::"Return Order":
                begin
                    if PurchaseHeader.Ship and (PurchaseHeader."Return Shipment No. Series" <> '') then begin
                        if (PurchaseHeader."Return Shipment No." = '') then
                            PurchaseHeader."Return Shipment No." := NoSeries.GetNextNo(PurchaseHeader."Return Shipment No. Series", LibraryUtility.GetNextNoSeriesPurchaseDate(PurchaseHeader."Return Shipment No. Series"));
                        DocumentFieldNo := PurchaseHeader.FieldNo("Last Return Shipment No.");
                    end;
                    if PurchaseHeader.Invoice and (PurchaseHeader."Posting No. Series" <> '') then begin
                        if (PurchaseHeader."Posting No." = '') then
                            PurchaseHeader."Posting No." := NoSeries.GetNextNo(PurchaseHeader."Posting No. Series", LibraryUtility.GetNextNoSeriesPurchaseDate(PurchaseHeader."Posting No. Series"));
                        DocumentFieldNo := PurchaseHeader.FieldNo("Last Posting No.");
                    end;
                end;
            else
                Assert.Fail(StrSubstNo(WrongDocumentTypeErr, PurchaseHeader."Document Type"))
        end;

        CODEUNIT.Run(CODEUNIT::"Purch.-Post", PurchaseHeader);

        RecRef.GetTable(PurchaseHeader);
        FieldRef := RecRef.Field(DocumentFieldNo);
        DocumentNo := FieldRef.Value();
    end;

    procedure QuoteMakeOrder(var PurchaseHeader: Record "Purchase Header"): Code[20]
    var
        PurchaseOrderHeader: Record "Purchase Header";
        PurchQuoteToOrder: Codeunit "Purch.-Quote to Order";
    begin
        Clear(PurchQuoteToOrder);
        PurchQuoteToOrder.Run(PurchaseHeader);
        PurchQuoteToOrder.GetPurchOrderHeader(PurchaseOrderHeader);
        exit(PurchaseOrderHeader."No.");
    end;

    procedure ReleasePurchaseDocument(var PurchaseHeader: Record "Purchase Header")
    var
        ReleasePurchDoc: Codeunit "Release Purchase Document";
    begin
        ReleasePurchDoc.PerformManualRelease(PurchaseHeader);
    end;

    procedure ReopenPurchaseDocument(var PurchaseHeader: Record "Purchase Header")
    var
        ReleasePurchDoc: Codeunit "Release Purchase Document";
    begin
        ReleasePurchDoc.PerformManualReopen(PurchaseHeader);
    end;

    procedure CalcPurchaseDiscount(PurchaseHeader: Record "Purchase Header")
    var
        PurchaseLine: Record "Purchase Line";
    begin
        PurchaseLine."Document Type" := PurchaseHeader."Document Type";
        PurchaseLine."Document No." := PurchaseHeader."No.";
        CODEUNIT.Run(CODEUNIT::"Purch.-Calc.Discount", PurchaseLine);
    end;

    procedure RunBatchPostPurchaseReturnOrdersReport(var PurchaseHeader: Record "Purchase Header")
    var
        BatchPostPurchRetOrders: Report "Batch Post Purch. Ret. Orders";
    begin
        Clear(BatchPostPurchRetOrders);
        BatchPostPurchRetOrders.SetTableView(PurchaseHeader);
        Commit();  // COMMIT is required to run this report.
        BatchPostPurchRetOrders.UseRequestPage(true);
        BatchPostPurchRetOrders.Run();
    end;

    procedure RunDeleteInvoicedPurchaseReturnOrdersReport(var PurchaseHeader: Record "Purchase Header")
    var
        DeleteInvdPurchRetOrders: Report "Delete Invd Purch. Ret. Orders";
    begin
        Clear(DeleteInvdPurchRetOrders);
        DeleteInvdPurchRetOrders.SetTableView(PurchaseHeader);
        DeleteInvdPurchRetOrders.UseRequestPage(false);
        DeleteInvdPurchRetOrders.Run();
    end;

    procedure RunMoveNegativePurchaseLinesReport(var PurchaseHeader: Record "Purchase Header"; FromDocType: Option; ToDocType: Option; ToDocType2: Option)
    var
        MoveNegativePurchaseLines: Report "Move Negative Purchase Lines";
    begin
        Clear(MoveNegativePurchaseLines);
        MoveNegativePurchaseLines.SetPurchHeader(PurchaseHeader);
        MoveNegativePurchaseLines.InitializeRequest(FromDocType, ToDocType, ToDocType2);
        MoveNegativePurchaseLines.UseRequestPage(false);
        MoveNegativePurchaseLines.Run();
    end;

    procedure SetAllowVATDifference(AllowVATDifference: Boolean)
    begin
        PurchasesPayablesSetup.Get();
        PurchasesPayablesSetup.Validate("Allow VAT Difference", AllowVATDifference);
        PurchasesPayablesSetup.Modify(true);
    end;

    procedure SetAllowDocumentDeletionBeforeDate(Date: Date)
    begin
        PurchasesPayablesSetup.Get();
        PurchasesPayablesSetup.Validate("Allow Document Deletion Before", Date);
        PurchasesPayablesSetup.Modify(true);
    end;

    procedure SetApplnBetweenCurrencies(ApplnBetweenCurrencies: Option)
    begin
        PurchasesPayablesSetup.Get();
        PurchasesPayablesSetup.Validate("Appln. between Currencies", ApplnBetweenCurrencies);
        PurchasesPayablesSetup.Modify(true);
    end;

    procedure SetArchiveQuotesAlways()
    begin
        PurchasesPayablesSetup.Get();
        PurchasesPayablesSetup.Validate("Archive Quotes", PurchasesPayablesSetup."Archive Quotes"::Always);
        PurchasesPayablesSetup.Modify(true);
    end;

    procedure SetArchiveOrders(ArchiveOrders: Boolean)
    begin
        PurchasesPayablesSetup.Get();
        PurchasesPayablesSetup.Validate("Archive Orders", ArchiveOrders);
        PurchasesPayablesSetup.Modify(true);
    end;

    procedure SetArchiveBlanketOrders(ArchiveBlanketOrders: Boolean)
    begin
        PurchasesPayablesSetup.Get();
        PurchasesPayablesSetup.Validate("Archive Blanket Orders", ArchiveBlanketOrders);
        PurchasesPayablesSetup.Modify(true);
    end;

    procedure SetArchiveReturnOrders(ArchiveReturnOrders: Boolean)
    begin
        PurchasesPayablesSetup.Get();
        PurchasesPayablesSetup.Validate("Archive Return Orders", ArchiveReturnOrders);
        PurchasesPayablesSetup.Modify(true);
    end;

#if not CLEAN27
    [Obsolete('Discontinued functionality', '27.0')]
    procedure SetCreateItemFromItemNo(NewValue: Boolean)
    begin
        PurchasesPayablesSetup.Get();
        PurchasesPayablesSetup.Validate("Create Item from Item No.", NewValue);
        PurchasesPayablesSetup.Modify(true);
    end;
#endif
    procedure SetDefaultPostingDateWorkDate()
    begin
        PurchasesPayablesSetup.Get();
        PurchasesPayablesSetup.Validate("Default Posting Date", PurchasesPayablesSetup."Default Posting Date"::"Work Date");
        PurchasesPayablesSetup.Modify(true);
    end;

    procedure SetDefaultPostingDateNoDate()
    begin
        PurchasesPayablesSetup.Get();
        PurchasesPayablesSetup.Validate("Default Posting Date", PurchasesPayablesSetup."Default Posting Date"::"No Date");
        PurchasesPayablesSetup.Modify(true);
    end;

    procedure SetDiscountPosting(DiscountPosting: Option)
    begin
        PurchasesPayablesSetup.Get();
        PurchasesPayablesSetup.Validate("Discount Posting", DiscountPosting);
        PurchasesPayablesSetup.Modify(true);
    end;

    procedure SetDiscountPostingSilent(DiscountPosting: Option)
    begin
        PurchasesPayablesSetup.Get();
        PurchasesPayablesSetup."Discount Posting" := DiscountPosting;
        PurchasesPayablesSetup.Modify();
    end;

    procedure SetCalcInvDiscount(CalcInvDiscount: Boolean)
    begin
        PurchasesPayablesSetup.Get();
        PurchasesPayablesSetup.Validate("Calc. Inv. Discount", CalcInvDiscount);
        PurchasesPayablesSetup.Modify(true);
    end;

    procedure SetInvoiceRounding(InvoiceRounding: Boolean)
    begin
        PurchasesPayablesSetup.Get();
        PurchasesPayablesSetup.Validate("Invoice Rounding", InvoiceRounding);
        PurchasesPayablesSetup.Modify(true);
    end;

    procedure SetExactCostReversingMandatory(ExactCostReversingMandatory: Boolean)
    begin
        PurchasesPayablesSetup.Get();
        PurchasesPayablesSetup.Validate("Exact Cost Reversing Mandatory", ExactCostReversingMandatory);
        PurchasesPayablesSetup.Modify(true);
    end;

    procedure SetExtDocNo(ExtDocNoMandatory: Boolean)
    begin
        PurchasesPayablesSetup.Get();
        PurchasesPayablesSetup.Validate("Ext. Doc. No. Mandatory", ExtDocNoMandatory);
        PurchasesPayablesSetup.Modify(true);
    end;

    procedure SetPostWithJobQueue(PostWithJobQueue: Boolean)
    begin
        PurchasesPayablesSetup.Get();
        PurchasesPayablesSetup.Validate("Post with Job Queue", PostWithJobQueue);
        PurchasesPayablesSetup.Modify(true);
    end;

    procedure SetPostAndPrintWithJobQueue(PostAndPrintWithJobQueue: Boolean)
    begin
        PurchasesPayablesSetup.Get();
        PurchasesPayablesSetup.Validate("Post & Print with Job Queue", PostAndPrintWithJobQueue);
        PurchasesPayablesSetup.Modify(true);
    end;

    procedure SetOrderNoSeriesInSetup()
    begin
        PurchasesPayablesSetup.Get();
        PurchasesPayablesSetup.Validate("Order Nos.", LibraryERM.CreateNoSeriesCode());
        PurchasesPayablesSetup.Modify(true);
    end;

    procedure SetPostedNoSeriesInSetup()
    begin
        PurchasesPayablesSetup.Get();
        PurchasesPayablesSetup.Validate("Posted Invoice Nos.", LibraryERM.CreateNoSeriesCode());
        PurchasesPayablesSetup.Validate("Posted Receipt Nos.", LibraryERM.CreateNoSeriesCode());
        PurchasesPayablesSetup.Validate("Posted Credit Memo Nos.", LibraryERM.CreateNoSeriesCode());
        PurchasesPayablesSetup.Modify(true);
    end;

    procedure SetQuoteNoSeriesInSetup()
    begin
        PurchasesPayablesSetup.Get();
        PurchasesPayablesSetup.Validate("Quote Nos.", LibraryERM.CreateNoSeriesCode());
        PurchasesPayablesSetup.Modify(true);
    end;

    procedure SetReturnOrderNoSeriesInSetup()
    begin
        PurchasesPayablesSetup.Get();
        PurchasesPayablesSetup.Validate("Return Order Nos.", LibraryERM.CreateNoSeriesCode());
        PurchasesPayablesSetup.Validate("Posted Return Shpt. Nos.", LibraryERM.CreateNoSeriesCode());
        PurchasesPayablesSetup.Modify(true);
    end;

    procedure SetCopyCommentsOrderToInvoiceInSetup(CopyCommentsOrderToInvoice: Boolean)
    begin
        PurchasesPayablesSetup.Get();
        PurchasesPayablesSetup.Validate("Copy Comments Order to Invoice", CopyCommentsOrderToInvoice);
        PurchasesPayablesSetup.Modify(true);
    end;

    local procedure SetVendorDocNo(var PurchaseHeader: Record "Purchase Header")
    begin
        PurchaseHeader."Vendor Invoice No." := LibraryUtility.GenerateGUID();
        PurchaseHeader."Vendor Cr. Memo No." := LibraryUtility.GenerateGUID();
        PurchaseHeader.Modify();
    end;

    procedure SelectPmtJnlBatch(var GenJournalBatch: Record "Gen. Journal Batch")
    begin
        LibraryJournals.SelectGenJournalBatch(GenJournalBatch, SelectPmtJnlTemplate());
    end;

    procedure SelectPmtJnlTemplate(): Code[10]
    var
        GenJournalTemplate: Record "Gen. Journal Template";
    begin
        exit(LibraryJournals.SelectGenJournalTemplate(GenJournalTemplate.Type::Payments, PAGE::"Payment Journal"));
    end;

    procedure UndoPurchaseReceiptLine(var PurchRcptLine: Record "Purch. Rcpt. Line")
    begin
        CODEUNIT.Run(CODEUNIT::"Undo Purchase Receipt Line", PurchRcptLine);
    end;

    procedure UndoReturnShipmentLine(var ReturnShipmentLine: Record "Return Shipment Line")
    begin
        CODEUNIT.Run(CODEUNIT::"Undo Return Shipment Line", ReturnShipmentLine);
    end;

    procedure DisableConfirmOnPostingDoc()
    var
        InstructionMgt: Codeunit "Instruction Mgt.";
    begin
        InstructionMgt.DisableMessageForCurrentUser(InstructionMgt.ShowPostedConfirmationMessageCode());
    end;

    procedure DisableWarningOnCloseUnreleasedDoc()
    begin
        LibraryERM.DisableClosingUnreleasedOrdersMsg();
    end;

    procedure DisableWarningOnCloseUnpostedDoc()
    var
        InstructionMgt: Codeunit "Instruction Mgt.";
    begin
        InstructionMgt.DisableMessageForCurrentUser(InstructionMgt.QueryPostOnCloseCode());
    end;

    procedure EnablePurchSetupIgnoreUpdatedAddresses()
    var
        PurchSetup: Record "Purchases & Payables Setup";
    begin
        PurchSetup.Get();
        PurchSetup."Ignore Updated Addresses" := true;
        PurchSetup.Modify();
    end;

    procedure DisablePurchSetupIgnoreUpdatedAddresses()
    var
        PurchSetup: Record "Purchases & Payables Setup";
    begin
        PurchSetup.Get();
        PurchSetup."Ignore Updated Addresses" := false;
        PurchSetup.Modify();
    end;

    procedure PreviewPostPurchaseDocument(var PurchaseHeader: Record "Purchase Header")
    var
        PurchPostYesNo: Codeunit "Purch.-Post (Yes/No)";
    begin
        PurchPostYesNo.Preview(PurchaseHeader);
    end;

    procedure CreatePostVendorLedgerEntry(var VendorLedgerEntry: Record "Vendor Ledger Entry")
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        LibraryJournals.CreateGenJournalLineWithBatch(
            GenJournalLine, GenJournalLine."Document Type"::Invoice,
            GenJournalLine."Account Type"::Vendor, CreateVendorNo(), -LibraryRandom.RandDec(100, 2));
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
        LibraryERM.FindVendorLedgerEntry(VendorLedgerEntry, VendorLedgerEntry."Document Type"::Invoice, GenJournalLine."Document No.");
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreatePurchHeader(var PurchaseHeader: Record "Purchase Header"; DocumentType: Enum "Purchase Document Type"; BuyfromVendorNo: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreatePurchaseLine(var PurchaseLine: Record "Purchase Line"; PurchaseHeader: Record "Purchase Header"; Type: Enum "Purchase Line Type"; No: Code[20]; Quantity: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateVendor(var Vendor: Record Vendor)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreatePurchaseHeader(var PurchaseHeader: Record "Purchase Header"; DocumentType: Enum "Purchase Document Type"; BuyfromPurchaseNo: Code[20])
    begin
    end;
}
