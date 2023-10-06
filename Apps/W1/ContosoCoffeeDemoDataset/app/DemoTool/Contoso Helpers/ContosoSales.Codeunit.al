codeunit 5124 "Contoso Sales"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "Sales Header" = rim,
        tabledata "Sales Line" = rim,
        tabledata "Item" = rim;

    procedure InsertSalesHeader(DocumentType: Enum "Sales Document Type"; CustomerNo: Code[20]; ExternalDocumentNo: Text[20]; PostingDate: Date; LocationCode: Code[10]): Record "Sales Header"
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.Validate("Document Type", DocumentType);
        SalesHeader.Validate("Sell-to Customer No.", CustomerNo);

        // We need to insert the record to get the default values taken from Document Type and Customer
        SalesHeader.Insert(true);

        SalesHeader.Validate("Posting Date", PostingDate);
        SalesHeader.Validate("External Document No.", ExternalDocumentNo);
        SalesHeader.Validate("Location Code", LocationCode);

        SalesHeader.Modify(true);

        exit(SalesHeader);
    end;

    procedure InsertSalesLineWithItem(SalesHeader: Record "Sales Header"; ItemNo: Code[20]; Quantity: Decimal)
    var
        Item: Record Item;
        SalesLine: Record "Sales Line";
    begin
        Item.SetBaseLoadFields();
        Item.Get(ItemNo);

        SalesLine.Validate("Document Type", SalesHeader."Document Type");
        SalesLine.Validate("Document No.", SalesHeader."No.");
        SalesLine.Validate("Location Code", SalesHeader."Location Code");
        SalesLine.Validate("Line No.", GetNextSalesLineNo(SalesHeader));
        SalesLine.Validate("Type", Enum::"Sales Line Type"::Item);
        SalesLine.Validate("No.", Item."No.");
        SalesLine.Validate("Unit of Measure Code", Item."Base Unit of Measure");
        SalesLine.Validate("Quantity", Quantity);
        SalesLine.Insert(true);
    end;

    local procedure GetNextSalesLineNo(SalesHeader: Record "Sales Header"): Integer
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetCurrentKey("Line No.");

        if SalesLine.FindLast() then
            exit(SalesLine."Line No." + 10000)
        else
            exit(10000);
    end;
}