namespace Microsoft.Finance.VAT.Reporting;

enum 13604 "Elec. VAT Decl. Request Type" implements "Elec. VAT Decl. Payload Builder"
{
    Extensible = true;

    value(1; "Get VAT Return Periods")
    {
        Implementation = "Elec. VAT Decl. Payload Builder" = "Elec. VAT Decl. Period Builder";
    }
    value(2; "Submit VAT Return")
    {
        Implementation = "Elec. VAT Decl. Payload Builder" = "Elec. VAT Decl. Submit Builder";
    }
    value(3; "Check VAT Return Status")
    {
        Implementation = "Elec. VAT Decl. Payload Builder" = "Elec. VAT Decl. Check Builder";
    }
}