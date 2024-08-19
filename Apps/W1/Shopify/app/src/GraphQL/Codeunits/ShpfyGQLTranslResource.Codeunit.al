namespace Microsoft.Integration.Shopify;

codeunit 30340 "Shpfy GQL TranslResource" implements "Shpfy IGraphQL"
{

    internal procedure GetGraphQL(): Text
    begin
        exit('{"query":"{ translatableResource(resourceId: \"gid://shopify/{{ResourceType}}/{{ResourceId}}\") { resourceId translatableContent {key value digest locale} }}"}');
    end;

    internal procedure GetExpectedCost(): Integer
    begin
        exit(3);
    end;
}