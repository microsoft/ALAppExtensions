#if not CLEANSCHEMA29
namespace Microsoft.Integration.Shopify;

/// <summary>
/// Enum Shpfy Metafield Value Type (ID 30102).
/// </summary>
enum 30102 "Shpfy Metafield Value Type"
{
    Access = Internal;
    Caption = 'Shopify  Metafield Value Type';
    Extensible = false;
    ObsoleteState = Pending;
    ObsoleteReason = 'Value Type is obsolete in Shopify API. Use Metafield Type instead.';
#pragma warning disable AS0074
    ObsoleteTag = '26.0';
#pragma warning restore AS0074

    value(0; String)
    {
        Caption = 'String';
    }

    value(1; Integer)
    {
        Caption = 'Integer';
    }

    value(2; Json)
    {
        Caption = 'Json';
    }
}
#endif