namespace Microsoft.Integration.Shopify;
//JZA: Task 3 Tax ID
/// <summary>
/// Enum Shopify Company Tax Id Mapping (ID 30165).
/// </summary>
enum 30165 "Shpfy Comp. Tax Id Mapping"
{
    Caption = 'Shopify Company Tax Id Mapping';
    Extensible = true;

    value(0; RegistrationNo)
    {
        Caption = 'Registration No.';
    }
    value(1; VATRegistrationNo)
    {
        Caption = 'VAT Registration No.';
    }
}
