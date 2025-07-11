namespace Microsoft.Integration.Shopify;

codeunit 30265 "Shpfy Open Return" implements "Shpfy IOpenShopifyDocument"
{

    procedure OpenDocument(DocumentId: BigInteger)
    var
        ReturnHeader: Record "Shpfy Return Header";
    begin
        if ReturnHeader.Get(DocumentId) then begin
            ReturnHeader.SetRecFilter();
            Page.Run(Page::"Shpfy Return", ReturnHeader);
        end;
    end;

}