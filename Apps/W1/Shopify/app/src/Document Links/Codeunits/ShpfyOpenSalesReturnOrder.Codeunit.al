namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.Document;

codeunit 30256 "Shpfy Open SalesReturnOrder" implements "Shpfy IOpenBCDocument"
{

    procedure OpenDocument(DocumentNo: Code[20])
    var
        SalesHeader: Record "Sales Header";
    begin
        if SalesHeader.Get(SalesHeader."Document Type"::"Return Order", DocumentNo) then begin
            SalesHeader.SetRecFilter();
            Page.Run(Page::"Sales Return Order", SalesHeader);
        end;
    end;

}