/// <summary>
/// Codeunit Shpfy Sales Channel Helper (ID 139583).
/// </summary>
codeunit 139583 "Shpfy Sales Channel Helper"
{
    internal procedure GetDefaultShopifySalesChannelRespone(): JsonArray
    var
        Any: Codeunit Any;
        JPublications: JsonArray;
        NodesTxt: Text;
        ResponseTok: Label '[ { "id": "gid://shopify/Publication/%2", "name": "Online Store" }, { "id": "gid://shopify/Publication/%1", "name": "Point of Sale" } ]', Locked = true;
    begin
        NodesTxt := StrSubstNo(ResponseTok, Any.IntegerInRange(10000, 99999), Any.IntegerInRange(10000, 99999));
        JPublications.ReadFrom(NodesTxt);
        exit(JPublications);
    end;
}
