namespace Microsoft.Integration.Shopify;

/// <summary>
/// Enum Shpfy Company Mapping (ID 30151) implements Interface Shpfy ICompany Mapping.
/// </summary>
enum 30151 "Shpfy Company Mapping" implements "Shpfy ICompany Mapping", "Shpfy ICustomer/Company Mapping"
{
    Caption = 'Shopify Company Mapping';
    Extensible = true;
    DefaultImplementation = "Shpfy ICompany Mapping" = "Shpfy Comp. By Email/Phone";

    value(0; "By Email/Phone")
    {
        Caption = 'By Email/Phone';
        Implementation = "Shpfy ICustomer/Company Mapping" = "Shpfy Comp. By Email/Phone";
    }
    value(2; DefaultCompany)
    {
        Caption = 'Always take the default Company';
        Implementation = "Shpfy ICustomer/Company Mapping" = "Shpfy Comp. By Default Comp.";
    }
    value(3; "By Tax Id")
    {
        Caption = 'By Tax Id';
        Implementation = "Shpfy ICustomer/Company Mapping" = "Shpfy Comp. By Tax Id";
    }
}
