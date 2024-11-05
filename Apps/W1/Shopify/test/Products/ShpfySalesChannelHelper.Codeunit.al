/// <summary>
/// Codeunit Shpfy Sales Channel Helper (ID 139583).
/// </summary>
codeunit 139618 "Shpfy Sales Channel Helper"
{
    internal procedure GetDefaultShopifySalesChannelResponse(OnlineStoreId: BigInteger; POSId: BigInteger): JsonArray
    var
        JPublications: JsonArray;
        NodesTxt: Text;
        ResponseTok: Label '[ { "node": { "id": "gid://shopify/Publication/%1", "catalog": {"apps": { "edges": [ { "node": { "handle": "online_store", "title": "Online Store" } } ] } } } }, { "node": { "id": "gid://shopify/Publication/%2", "catalog": { "apps": { "edges": [ { "node": {"handle": "pos", "title": "Point of Sale" } } ] } } } } ]', Locked = true;
    begin
        NodesTxt := StrSubstNo(ResponseTok, OnlineStoreId, POSId);
        JPublications.ReadFrom(NodesTxt);
        exit(JPublications);
    end;
}