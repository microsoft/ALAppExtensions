namespace Microsoft.Integration.Shopify;

codeunit 30225 "Shpfy GQL ReturnHeader" implements "Shpfy IGraphQL"
{

    internal procedure GetGraphQL(): Text
    begin
        exit('{"query":"{ return(id: \"gid://shopify/Return/{{ReturnId}}\") { order { legacyResourceId } id name status totalQuantity decline { reason note }}}"}');
    end;

    internal procedure GetExpectedCost(): Integer
    begin
        exit(3);
    end;
}
