namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.Document;

codeunit 30255 "Shpfy Open SalesInvoice" implements "Shpfy IOpenBCDocument"
{

    procedure OpenDocument(DocumentNo: Code[20])
    var
        SalesHeader: Record "Sales Header";
    begin
        if SalesHeader.Get(SalesHeader."Document Type"::Invoice, DocumentNo) then begin
            SalesHeader.SetRecFilter();
            Page.Run(Page::"Sales Invoice", SalesHeader);
        end;
    end;

}