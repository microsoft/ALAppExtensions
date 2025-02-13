codeunit 4781 "Contoso Purchase"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "Purchase Header" = rim,
        tabledata "Purchase Line" = rim,
        tabledata "Item" = r,
        tabledata "Purchases & Payables Setup" = rim;

    procedure InsertPurchaseHeader(DocumentType: Enum "Purchase Document Type"; VendorNo: Code[20]; VendorOrderNo: Code[20]; PostingDate: Date; LocationCode: Code[20]): Record "Purchase Header"
    begin
        exit(InsertPurchaseHeader(DocumentType, VendorNo, '', PostingDate, PostingDate, 0D, '', LocationCode, VendorOrderNo, '', PostingDate, ''));
    end;

    procedure InsertPurchaseHeader(DocumentType: Enum "Purchase Document Type"; BuyfromVendorNo: Code[20]; YourReference: Code[35]; OrderDate: Date; PostingDate: Date; ExpectedReceiptDate: Date; PaymentTermsCode: Code[10]; LocationCode: Code[10]; VendorOrderNo: Code[20]; VendorInvoiceNo: Code[35]; DocumentDate: Date; PaymentMethodCode: Code[10]): Record "Purchase Header";
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        PurchaseHeader.Validate("Document Type", DocumentType);
        PurchaseHeader.Validate("Buy-from Vendor No.", BuyfromVendorNo);
        if PurchaseHeader.Insert(true) then;

        PurchaseHeader.Validate("Your Reference", YourReference);
        PurchaseHeader.Validate("Order Date", OrderDate);
        PurchaseHeader.Validate("Posting Date", PostingDate);
        PurchaseHeader.Validate("Expected Receipt Date", ExpectedReceiptDate);
        PurchaseHeader.Validate("Payment Terms Code", PaymentTermsCode);
        PurchaseHeader.Validate("Location Code", LocationCode);
        PurchaseHeader.Validate("Vendor Order No.", VendorOrderNo);

        if VendorInvoiceNo <> '' then
            PurchaseHeader.Validate("Vendor Invoice No.", VendorInvoiceNo)
        else
            PurchaseHeader.Validate("Vendor Invoice No.", PurchaseHeader."No.");

        PurchaseHeader.Validate("Document Date", DocumentDate);
        PurchaseHeader.Validate("Payment Method Code", PaymentMethodCode);
        PurchaseHeader.Modify(true);

        exit(PurchaseHeader);
    end;

    procedure InsertPurchaseLineWithItem(PurchaseHeader: Record "Purchase Header"; ItemNo: Code[20]; Quantity: Decimal)
    begin
        InsertPurchaseLineWithItem(PurchaseHeader, ItemNo, Quantity, '', 0);
    end;

    procedure InsertPurchaseLineWithItem(PurchaseHeader: Record "Purchase Header"; ItemNo: Code[20]; Quantity: Decimal; UnitOfMeasureCode: Code[10]; UnitCost: Decimal)
    begin
        InsertPurchaseLineWithItem(PurchaseHeader, ItemNo, Quantity, UnitOfMeasureCode, UnitCost, 0);
    end;

    procedure InsertPurchaseLineWithItem(PurchaseHeader: Record "Purchase Header"; ItemNo: Code[20]; Quantity: Decimal; UnitOfMeasureCode: Code[10]; UnitCost: Decimal; LineDiscount: Decimal)
    var
        Item: Record Item;
        PurchaseLine: Record "Purchase Line";
    begin
        PurchaseLine.Validate("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.Validate("Document No.", PurchaseHeader."No.");
        PurchaseLine.Validate("Location Code", PurchaseHeader."Location Code");
        PurchaseLine.Validate("Line No.", GetNextPurchaseLineNo(PurchaseHeader));
        PurchaseLine.Validate(Type, PurchaseLine.Type::Item);
        PurchaseLine.Validate("No.", ItemNo);

        if UnitOfMeasureCode <> '' then begin
            PurchaseLine.Validate("Unit of Measure Code", UnitOfMeasureCode);
            PurchaseLine.Validate("Direct Unit Cost", UnitCost);
        end else begin
            Item.SetBaseLoadFields();
            Item.Get(ItemNo);
            PurchaseLine.Validate("Unit of Measure Code", Item."Base Unit of Measure");
            PurchaseLine.Validate("Direct Unit Cost", Item."Unit Cost");
        end;

        PurchaseLine.Validate(Quantity, Quantity);
        PurchaseLine.Validate("Line Discount %", LineDiscount);
        PurchaseLine.Insert(true);
    end;

    procedure InsertPurchaseLineWithResource(PurchaseHeader: Record "Purchase Header"; ResourceNo: Code[20]; Quantity: Decimal)
    var
        Resource: Record Resource;
        PurchaseLine: Record "Purchase Line";
    begin
        PurchaseLine.Validate("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.Validate("Document No.", PurchaseHeader."No.");
        PurchaseLine.Validate("Location Code", PurchaseHeader."Location Code");
        PurchaseLine.Validate("Line No.", GetNextPurchaseLineNo(PurchaseHeader));
        PurchaseLine.Validate(Type, PurchaseLine.Type::Resource);
        PurchaseLine.Validate("No.", ResourceNo);

        Resource.SetBaseLoadFields();
        Resource.Get(ResourceNo);
        PurchaseLine.Validate(Quantity, Quantity);
        PurchaseLine.Validate("Unit of Measure Code", Resource."Base Unit of Measure");
        PurchaseLine.Validate("Direct Unit Cost", Resource."Unit Cost");
        PurchaseLine.Insert(true);
    end;

    local procedure GetNextPurchaseLineNo(PurchaseHeader: Record "Purchase Header"): Integer
    var
        PurchaseLine: Record "Purchase Line";
    begin
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.SetCurrentKey("Line No.");

        if PurchaseLine.FindLast() then
            exit(PurchaseLine."Line No." + 10000)
        else
            exit(10000);
    end;

    procedure InsertPurchasePayableSetup(DiscountPosting: Integer; ReceiptonInvoice: Boolean; InvoiceRounding: Boolean; ExtDocNoMandatory: Boolean; VendorNos: Code[20]; QuoteNos: Code[20]; OrderNos: Code[20]; InvoiceNos: Code[20]; PostedInvoiceNos: Code[20]; CreditMemoNos: Code[20]; PostedCreditMemoNos: Code[20]; PostedReceiptNos: Code[20]; BlanketOrderNos: Code[20]; ApplnbetweenCurrencies: Integer; CopyCommentsBlankettoOrder: Boolean; CopyCommentsOrdertoInvoice: Boolean; CopyCommentsOrdertoReceipt: Boolean; JobQueueCategoryCode: Code[10]; JobQueuePriorityforPost: Integer; JobQPrioforPostPrint: Integer; DocumentDefaultLineType: Enum "Purchase Line Type"; CopyVendorNametoEntries: Boolean; PostedReturnShptNos: Code[20]; CopyCmtsRetOrdtoRetShpt: Boolean; CopyCmtsRetOrdtoCrMemo: Boolean; ReturnOrderNos: Code[20]; PriceCalculationMethod: Enum "Price Calculation Method"; PriceListNos: Code[20])
    var
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
    begin
        if not PurchasesPayablesSetup.Get() then
            PurchasesPayablesSetup.Insert();

        PurchasesPayablesSetup.Validate("Discount Posting", DiscountPosting);
        PurchasesPayablesSetup.Validate("Receipt on Invoice", ReceiptonInvoice);
        PurchasesPayablesSetup.Validate("Invoice Rounding", InvoiceRounding);
        PurchasesPayablesSetup.Validate("Ext. Doc. No. Mandatory", ExtDocNoMandatory);
        PurchasesPayablesSetup.Validate("Vendor Nos.", VendorNos);
        PurchasesPayablesSetup.Validate("Quote Nos.", QuoteNos);
        PurchasesPayablesSetup.Validate("Order Nos.", OrderNos);
        PurchasesPayablesSetup.Validate("Invoice Nos.", InvoiceNos);
        PurchasesPayablesSetup.Validate("Posted Invoice Nos.", PostedInvoiceNos);
        PurchasesPayablesSetup.Validate("Credit Memo Nos.", CreditMemoNos);
        PurchasesPayablesSetup.Validate("Posted Credit Memo Nos.", PostedCreditMemoNos);
        PurchasesPayablesSetup.Validate("Posted Receipt Nos.", PostedReceiptNos);
        PurchasesPayablesSetup.Validate("Blanket Order Nos.", BlanketOrderNos);
        PurchasesPayablesSetup.Validate("Appln. between Currencies", ApplnbetweenCurrencies);
        PurchasesPayablesSetup.Validate("Copy Comments Blanket to Order", CopyCommentsBlankettoOrder);
        PurchasesPayablesSetup.Validate("Copy Comments Order to Invoice", CopyCommentsOrdertoInvoice);
        PurchasesPayablesSetup.Validate("Copy Comments Order to Receipt", CopyCommentsOrdertoReceipt);
        PurchasesPayablesSetup.Validate("Job Queue Category Code", JobQueueCategoryCode);
        PurchasesPayablesSetup.Validate("Job Queue Priority for Post", JobQueuePriorityforPost);
        PurchasesPayablesSetup.Validate("Job Q. Prio. for Post & Print", JobQPrioforPostPrint);
        PurchasesPayablesSetup.Validate("Document Default Line Type", DocumentDefaultLineType);
        PurchasesPayablesSetup.Validate("Copy Vendor Name to Entries", CopyVendorNametoEntries);
        PurchasesPayablesSetup.Validate("Posted Return Shpt. Nos.", PostedReturnShptNos);
        PurchasesPayablesSetup.Validate("Copy Cmts Ret.Ord. to Ret.Shpt", CopyCmtsRetOrdtoRetShpt);
        PurchasesPayablesSetup.Validate("Copy Cmts Ret.Ord. to Cr. Memo", CopyCmtsRetOrdtoCrMemo);
        PurchasesPayablesSetup.Validate("Return Order Nos.", ReturnOrderNos);
        PurchasesPayablesSetup."Price Calculation Method" := PriceCalculationMethod;
        PurchasesPayablesSetup.Validate("Price List Nos.", PriceListNos);
        PurchasesPayablesSetup.Modify(true);
    end;
}