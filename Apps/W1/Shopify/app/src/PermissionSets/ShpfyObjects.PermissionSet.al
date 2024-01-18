namespace Microsoft.Integration.Shopify;

/// <summary>
/// Shpfy - Objects Permissions (ID 30104).
/// </summary>
permissionset 30104 "Shpfy - Objects"
{
    Access = Internal;
    Assignable = false;
    Caption = 'Shopify - Objects', MaxLength = 30;

    Permissions =
        table * = X,
        codeunit * = X,
        page * = X,
        query * = X,
        report * = X;
}
