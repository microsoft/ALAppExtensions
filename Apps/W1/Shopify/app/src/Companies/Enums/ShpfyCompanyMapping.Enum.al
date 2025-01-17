namespace Microsoft.Integration.Shopify;

/// <summary>
/// Enum Shpfy Company Mapping (ID 30151) implements Interface Shpfy ICompany Mapping.
/// </summary>
enum 30151 "Shpfy Company Mapping" implements "Shpfy ICompany Mapping"
{
    Caption = 'Shopify Company Mapping';
    Extensible = true;

    value(0; "By Email/Phone")
    {
        Caption = 'By Email/Phone';
        Implementation = "Shpfy ICompany Mapping" = "Shpfy Comp. By Email/Phone";
    }
    value(2; DefaultCompany)
    {
        Caption = 'Always take the default Company';
        Implementation = "Shpfy ICompany Mapping" = "Shpfy Comp. By Default Comp.";
    }

}
