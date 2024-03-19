codeunit 4781 "Contoso Purchase"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "Purchase Header" = rim,
        tabledata "Purchase Line" = rim,
        tabledata "Item" = r;

    procedure InsertPurchaseHeader(DocumentType: Enum "Purchase Document Type"; VendorNo: Code[20]; VendorOrderNo: Code[20]; PostingDate: Date; LocationCode: Code[20]): Record "Purchase Header"
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        PurchaseHeader.Validate("Document Type", DocumentType);
        PurchaseHeader.Validate("Buy-from Vendor No.", VendorNo);

        // We need to insert the record to get the default values taken from Document Type and Vendor
        PurchaseHeader.Insert(true);

        PurchaseHeader.Validate("Posting Date", PostingDate);
        PurchaseHeader.Validate("Location Code", LocationCode);
        PurchaseHeader.Validate("Vendor Order No.", VendorOrderNo);

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

}