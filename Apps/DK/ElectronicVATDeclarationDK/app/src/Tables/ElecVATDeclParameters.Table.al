namespace Microsoft.Finance.VAT.Reporting;

table 13604 "Elec. VAT Decl. Parameters"
{
    TableType = Temporary;

    fields
    {
        field(1; "VAT Report Header No."; Code[20])
        {

        }
        field(2; "VAT Report Config. Code"; Enum "VAT Report Configuration")
        {

        }
        field(3; "From Date"; Date)
        {

        }
        field(4; "To Date"; Date)
        {

        }
        field(5; "Transaction ID"; Text[250])
        {

        }
    }
}