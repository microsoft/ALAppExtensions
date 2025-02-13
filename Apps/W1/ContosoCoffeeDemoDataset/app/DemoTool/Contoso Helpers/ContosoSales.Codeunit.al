codeunit 5124 "Contoso Sales"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "Sales Header" = rim,
        tabledata "Sales Line" = rim,
        tabledata "Item" = rim;


    procedure InsertSalesHeader(DocumentType: Enum "Sales Document Type"; CustomerNo: Code[20]; ExternalDocumentNo: Text[20]; PostingDate: Date; LocationCode: Code[10]): Record "Sales Header"
    begin
        exit(InsertSalesHeader(DocumentType, CustomerNo, '', 0D, PostingDate, '', 0D, '', '', 0D, '', ExternalDocumentNo));
    end;

    procedure InsertSalesHeader(DocumentType: Enum "Sales Document Type"; SelltoCustomerNo: Code[20]; YourReference: Code[35]; OrderDate: Date; PostingDate: Date; PaymentTermsCode: Code[10]; DocumentDate: Date; PaymentMethodCode: Code[10]; ShippingAgentCode: Code[10]; RequestedDeliveryDate: Date; ShippingAgentServiceCode: Code[10]; ExternalDocumentNo: Code[35]): Record "Sales Header"
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.Validate("Document Type", DocumentType);
        SalesHeader.Validate("Sell-to Customer No.", SelltoCustomerNo);
        SalesHeader.Insert(true);

        SalesHeader.Validate("Your Reference", YourReference);
        SalesHeader.Validate("Order Date", OrderDate);
        SalesHeader.Validate("Posting Date", PostingDate);
        SalesHeader.Validate("Payment Terms Code", PaymentTermsCode);
        SalesHeader.Validate("Document Date", DocumentDate);
        SalesHeader.Validate("Payment Method Code", PaymentMethodCode);
        SalesHeader.Validate("Shipping Agent Code", ShippingAgentCode);
        SalesHeader.Validate("Requested Delivery Date", RequestedDeliveryDate);
        SalesHeader.Validate("Shipping Agent Service Code", ShippingAgentServiceCode);
        SalesHeader.Validate("External Document No.", ExternalDocumentNo);
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

    procedure InsertSalesLineWithComments(SalesHeader: Record "Sales Header"; Description: Text[100])
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.Validate("Document Type", SalesHeader."Document Type");
        SalesLine.Validate("Document No.", SalesHeader."No.");
        SalesLine.Validate("Line No.", GetNextSalesLineNo(SalesHeader));
        SalesLine.Validate("Type", Enum::"Sales Line Type"::" ");
        SalesLine.Validate(Description, Description);
        SalesLine.Insert(true);
    end;

    procedure InsertSalesLineWithGLAccount(SalesHeader: Record "Sales Header"; GLAccountNo: Code[20]; Quantity: Decimal; UnitPrice: Decimal)
    var
        GLAccount: Record "G/L Account";
        SalesLine: Record "Sales Line";
    begin
        GLAccount.SetBaseLoadFields();
        GLAccount.Get(GLAccountNo);

        SalesLine.Validate("Document Type", SalesHeader."Document Type");
        SalesLine.Validate("Document No.", SalesHeader."No.");
        SalesLine.Validate("Location Code", SalesHeader."Location Code");
        SalesLine.Validate("Line No.", GetNextSalesLineNo(SalesHeader));
        SalesLine.Validate("Type", Enum::"Sales Line Type"::"G/L Account");
        SalesLine.Validate("No.", GLAccount."No.");
        SalesLine.Validate("Quantity", Quantity);
        SalesLine.Validate("Unit Price", UnitPrice);
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