namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.History;

codeunit 30263 "Shpfy Open PostedSalesCrMemo" implements "Shpfy IOpenBCDocument"
{

    procedure OpenDocument(DocumentNo: Code[20])
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        if SalesCrMemoHeader.Get(DocumentNo) then begin
            SalesCrMemoHeader.SetRecFilter();
            Page.Run(Page::"Posted Sales Credit Memo", SalesCrMemoHeader);
        end;
    end;

}