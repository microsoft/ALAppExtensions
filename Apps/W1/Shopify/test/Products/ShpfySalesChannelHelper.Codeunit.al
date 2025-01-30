codeunit 139699 "Shpfy Sales Channel Helper"
{
    internal procedure GetDefaultShopifySalesChannelResponse(OnlineStoreId: BigInteger; POSId: BigInteger): JsonArray
    var
        JPublications: JsonArray;
        NodesTxt: Text;
        ResInStream: InStream;
    begin
        NavApp.GetResource('Products/DefaultSalesChannelResponse.txt', ResInStream, TextEncoding::UTF8);
        ResInStream.ReadText(NodesTxt);
        JPublications.ReadFrom(StrSubstNo(NodesTxt, OnlineStoreId, POSId));
        exit(JPublications);
    end;
}