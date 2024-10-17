/// <summary>
/// Codeunit Shpfy Sales Channel Helper (ID 139583).
/// </summary>
codeunit 139583 "Shpfy Sales Channel Helper"
{
    internal procedure GetDefaultShopifySalesChannelResponse(OnlineStoreId: BigInteger; POSId: BigInteger): JsonArray
    var
        Any: Codeunit Any;
        JPublications: JsonArray;
        NodesTxt: Text;
        ResponseTok: Label '[ { "id": "gid://shopify/Publication/%2", "name": "Online Store" }, { "id": "gid://shopify/Publication/%1", "name": "Point of Sale" } ]', Locked = true;
    begin
        NodesTxt := StrSubstNo(ResponseTok, OnlineStoreId, POSId);
        JPublications.ReadFrom(NodesTxt);
        exit(JPublications);
    end;
}
