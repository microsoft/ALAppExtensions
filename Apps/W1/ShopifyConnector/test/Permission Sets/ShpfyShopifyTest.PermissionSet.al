/// <summary>
/// Unknown ShpfyShpfyShpfyShopify Test (ID 30500).
/// </summary>
permissionset 30500 "Shopify Test"
{
    Assignable = true;
    Caption = 'Shopify Test', MaxLength = 30;
    Permissions =
        codeunit "Shpfy Filter Mgt. Test" = X,
        codeunit "Shpfy GraphQL Rate Limit Test" = X,
        codeunit "Shpfy Initialize Test" = X,
        codeunit "Shpfy Test Shopify" = X;
}
