namespace Microsoft.Integration.Shopify;

codeunit 30264 "Shpfy Open Order" implements "Shpfy IOpenShopifyDocument"
{

    procedure OpenDocument(DocumentId: BigInteger)
    var
        OrderHeader: Record "Shpfy Order Header";
    begin
        if OrderHeader.Get(DocumentId) then begin
            OrderHeader.SetRecFilter();
            Page.Run(Page::"Shpfy Order", OrderHeader);
        end;
    end;
}