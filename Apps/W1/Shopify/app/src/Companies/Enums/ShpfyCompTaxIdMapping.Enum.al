namespace Microsoft.Integration.Shopify;
//JZA: Task 3 Tax ID
/// <summary>
/// Enum Shopify Company Tax Id Mapping (ID 30165).
/// </summary>
enum 30165 "Shpfy Comp. Tax Id Mapping" implements "Shpfy Tax Registration Id Mapping"
{
    Caption = 'Shopify Company Tax Id Mapping';
    Extensible = true;

    value(0; "Registration No.")
    {
        Caption = 'Registration No.';
        Implementation = "Shpfy Tax Registration Id Mapping" = "Shpfy Tax Registration No.";
    }
    value(1; "VAT Registration No.")
    {
        Caption = 'VAT Registration No.';
        Implementation = "Shpfy Tax Registration Id Mapping" = "Shpfy VAT Tax Registration No.";
    }
}
