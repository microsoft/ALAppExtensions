namespace Microsoft.Sales.Document.Test;

using Microsoft.Inventory.Item;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;

codeunit 149827 "SLS Test Demo Data"
{

    var
        LibrarySales: Codeunit "Library - Sales";
        LibraryInventory: Codeunit "Library - Inventory";

    procedure Items()
    var
        Item, SetupItem : Record Item;
        DemoItems: List of [Text];
        ItemNo: Code[20];
    begin
        LibraryInventory.CreateItem(SetupItem);

        DemoItems := '1896-S, 1900-S, 1936-S, 1996-S, 1965-W, 1969-W'.Split(', ');
        foreach ItemNo in DemoItems do begin
            Item.Get(ItemNo);
            Item."Inventory Posting Group" := SetupItem."Inventory Posting Group";
            Item."Gen. Prod. Posting Group" := SetupItem."Gen. Prod. Posting Group";
            Item."VAT Prod. Posting Group" := SetupItem."VAT Prod. Posting Group";
            Item.Modify();
        end;
    end;

    procedure SalesQuotes()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
    begin
        GetCustomer(Customer);

        CreateSalesDocument(SalesHeader, Customer."No.", "Sales Document Type"::Quote, '**SQ-0001**', '1896-S'.Split(', '));
        CreateSalesDocument(SalesHeader, Customer."No.", "Sales Document Type"::Quote, '**SQ-0002**', '1896-S, 1900-S'.Split(', '));
        CreateSalesDocument(SalesHeader, Customer."No.", "Sales Document Type"::Quote, '**SQ-0003**', '1896-S, 1900-S, 1936-S'.Split(', '));
        CreateSalesDocument(SalesHeader, Customer."No.", "Sales Document Type"::Quote, '**SQ-0004**', '1896-S, 1900-S, 1936-S, 1996-S'.Split(', '));
        CreateSalesDocument(SalesHeader, Customer."No.", "Sales Document Type"::Quote, '**SQ-0005**', '1896-S, 1900-S, 1936-S, 1996-S, 1965-W'.Split(', '));
        CreateSalesDocument(SalesHeader, Customer."No.", "Sales Document Type"::Quote, '**SQ-0006**', '1896-S, 1900-S, 1936-S, 1996-S, 1965-W, 1969-W'.Split(', '));
        CreateSalesDocument(SalesHeader, Customer."No.", "Sales Document Type"::Quote, '**SQ-BLANK**', ''.Split(', '));
        CreateSalesDocument(SalesHeader, Customer."No.", "Sales Document Type"::Quote, '**SQ-SAME**', '1896-S, 1896-S, 1896-S, 1896-S, 1896-S, 1896-S'.Split(', '));
        CreateSalesDocumentWithAlternateUoM(SalesHeader, Customer."No.", "Sales Document Type"::Quote, '**SQ-UOM**', '1900-S, 1936-S'.Split(', '));
    end;

    procedure SalesOrders()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
    begin
        GetCustomer(Customer);

        CreateSalesDocument(SalesHeader, Customer."No.", "Sales Document Type"::Order, '**SO-0001**', '1896-S'.Split(', '));
        CreateSalesDocument(SalesHeader, Customer."No.", "Sales Document Type"::Order, '**SO-0002**', '1896-S, 1900-S'.Split(', '));
        CreateSalesDocument(SalesHeader, Customer."No.", "Sales Document Type"::Order, '**SO-0003**', '1896-S, 1900-S, 1936-S'.Split(', '));
        CreateSalesDocument(SalesHeader, Customer."No.", "Sales Document Type"::Order, '**SO-0004**', '1896-S, 1900-S, 1936-S, 1996-S'.Split(', '));
        CreateSalesDocument(SalesHeader, Customer."No.", "Sales Document Type"::Order, '**SO-0005**', '1896-S, 1900-S, 1936-S, 1996-S, 1965-W'.Split(', '));
        CreateSalesDocument(SalesHeader, Customer."No.", "Sales Document Type"::Order, '**SO-0006**', '1896-S, 1900-S, 1936-S, 1996-S, 1965-W, 1969-W'.Split(', '));
        CreateSalesDocument(SalesHeader, Customer."No.", "Sales Document Type"::Order, '**SO-BLANK**', ''.Split(', '));
        CreateSalesDocument(SalesHeader, Customer."No.", "Sales Document Type"::Order, '**SO-SAME**', '1896-S, 1896-S, 1896-S, 1896-S, 1896-S, 1896-S'.Split(', '));
        CreateSalesDocumentWithAlternateUoM(SalesHeader, Customer."No.", "Sales Document Type"::Order, '**SO-UOM**', '1900-S, 1936-S'.Split(', '));
    end;

    procedure SalesBlanketOrders()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
    begin
        GetCustomer(Customer);

        CreateSalesDocument(SalesHeader, Customer."No.", "Sales Document Type"::"Blanket Order", '**SBO-0001**', '1896-S'.Split(', '));
        CreateSalesDocument(SalesHeader, Customer."No.", "Sales Document Type"::"Blanket Order", '**SBO-0002**', '1896-S, 1900-S'.Split(', '));
        CreateSalesDocument(SalesHeader, Customer."No.", "Sales Document Type"::"Blanket Order", '**SBO-0003**', '1896-S, 1900-S, 1936-S'.Split(', '));
        CreateSalesDocument(SalesHeader, Customer."No.", "Sales Document Type"::"Blanket Order", '**SBO-0004**', '1896-S, 1900-S, 1936-S, 1996-S'.Split(', '));
        CreateSalesDocument(SalesHeader, Customer."No.", "Sales Document Type"::"Blanket Order", '**SBO-0005**', '1896-S, 1900-S, 1936-S, 1996-S, 1965-W'.Split(', '));
        CreateSalesDocument(SalesHeader, Customer."No.", "Sales Document Type"::"Blanket Order", '**SBO-0006**', '1896-S, 1900-S, 1936-S, 1996-S, 1965-W, 1969-W'.Split(', '));
        CreateSalesDocument(SalesHeader, Customer."No.", "Sales Document Type"::"Blanket Order", '**SBO-BLANK**', ''.Split(', '));
        CreateSalesDocument(SalesHeader, Customer."No.", "Sales Document Type"::"Blanket Order", '**SBO-SAME**', '1896-S, 1896-S, 1896-S, 1896-S, 1896-S, 1896-S'.Split(', '));
        CreateSalesDocumentWithAlternateUoM(SalesHeader, Customer."No.", "Sales Document Type"::"Blanket Order", '**SBO-UOM**', '1900-S, 1936-S'.Split(', '));
    end;

    procedure PostedSalesOrders()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
    begin
        GetCustomer(Customer);

        CreateAndPostSalesDocument(SalesHeader, Customer."No.", "Sales Document Type"::Order, '**PSO-0001**', '1896-S'.Split(', '));
        CreateAndPostSalesDocument(SalesHeader, Customer."No.", "Sales Document Type"::Order, '**PSO-0002**', '1896-S, 1900-S'.Split(', '));
        CreateAndPostSalesDocument(SalesHeader, Customer."No.", "Sales Document Type"::Order, '**PSO-0003**', '1896-S, 1900-S, 1936-S'.Split(', '));
        CreateAndPostSalesDocument(SalesHeader, Customer."No.", "Sales Document Type"::Order, '**PSO-0004**', '1896-S, 1900-S, 1936-S, 1996-S'.Split(', '));
        CreateAndPostSalesDocument(SalesHeader, Customer."No.", "Sales Document Type"::Order, '**PSO-0005**', '1896-S, 1900-S, 1936-S, 1996-S, 1965-W'.Split(', '));
        CreateAndPostSalesDocument(SalesHeader, Customer."No.", "Sales Document Type"::Order, '**PSO-0006**', '1896-S, 1900-S, 1936-S, 1996-S, 1965-W, 1969-W'.Split(', '));
        CreateAndPostSalesDocument(SalesHeader, Customer."No.", "Sales Document Type"::Order, '**PSO-SAME**', '1896-S, 1896-S, 1896-S, 1896-S, 1896-S, 1896-S'.Split(', '));
        CreateAndPostSalesDocumentWithAlternateUoM(SalesHeader, Customer."No.", "Sales Document Type"::Order, '**PSO-UOM**', '1900-S, 1936-S'.Split(', '));
    end;

    procedure GetCustomer(var Customer: Record Customer)
    var
        CustomerTok: Label '**CUSTOMER**';
    begin
        Customer.SetRange(Name, CustomerTok);
        if not Customer.FindFirst() then begin
            LibrarySales.CreateCustomer(Customer);
            Customer.Validate(Name, CustomerTok);
            Customer.Modify(true);
        end;
    end;

    local procedure CreateSalesDocument(var SalesHeader: Record "Sales Header"; CustomerNo: Code[20]; DocumentType: Enum "Sales Document Type"; ExternalDocumentNo: Code[35]; ItemList: List of [Text])
    var
        SalesLine: Record "Sales Line";
        ItemNo: Code[20];
        Index: Integer;
    begin
        Clear(SalesHeader);
        LibrarySales.CreateSalesHeader(SalesHeader, DocumentType, CustomerNo);
        SalesHeader.Validate("External Document No.", ExternalDocumentNo);
        SalesHeader.Modify(true);

        foreach ItemNo in ItemList do begin
            Index += 1;
            if ItemNo <> '' then
                LibrarySales.CreateSalesLineWithUnitPrice(SalesLine, SalesHeader, ItemNo, 1.0, Index);
        end;
    end;

    local procedure CreateAndPostSalesDocument(var SalesHeader: Record "Sales Header"; CustomerNo: Code[20]; DocumentType: Enum "Sales Document Type"; ExternalDocumentNo: Code[35]; ItemList: List of [Text])
    begin
        CreateSalesDocument(SalesHeader, CustomerNo, DocumentType, ExternalDocumentNo, ItemList);
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
    end;

    local procedure CreateSalesDocumentWithAlternateUoM(var SalesHeader: Record "Sales Header"; CustomerNo: Code[20]; DocumentType: Enum "Sales Document Type"; ExternalDocumentNo: Code[35]; ItemList: List of [Text])
    var
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        SalesLine: Record "Sales Line";
        ItemNo: Code[20];
        Index: Integer;
    begin
        Clear(SalesHeader);
        LibrarySales.CreateSalesHeader(SalesHeader, DocumentType, CustomerNo);
        SalesHeader.Validate("External Document No.", ExternalDocumentNo);
        SalesHeader.Modify(true);

        foreach ItemNo in ItemList do begin
            Index += 1;
            ItemUnitOfMeasure.SetRange("Item No.", ItemNo);
            ItemUnitOfMeasure.SetFilter("Qty. per Unit of Measure", '<>1');
            ItemUnitOfMeasure.FindFirst();

            LibrarySales.CreateSalesLineWithUnitPrice(SalesLine, SalesHeader, ItemNo, 1.0, Index);
            SalesLine.Validate("Unit of Measure Code", ItemUnitOfMeasure.Code);
            SalesLine.Modify(true);
        end;
    end;

    local procedure CreateAndPostSalesDocumentWithAlternateUoM(var SalesHeader: Record "Sales Header"; CustomerNo: Code[20]; DocumentType: Enum "Sales Document Type"; ExternalDocumentNo: Code[35]; ItemList: List of [Text])
    begin
        CreateSalesDocumentWithAlternateUoM(SalesHeader, CustomerNo, DocumentType, ExternalDocumentNo, ItemList);
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
    end;
}