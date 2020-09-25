pageextension 10610 "NO General Journal Setup" extends "General Ledger Setup"
{
    layout
    {
        modify("Payroll Transaction Import")
        {
            Visible = true;
        }
        modify("Payroll Trans. Import Format")
        {
            Visible = true;
        }
        addafter("Payroll Trans. Import Format")
        {
            field("Import Dimension Codes"; "Import Dimension Codes")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies if data from the two first dimensions in the import file must be copied to the journal line as global dimension codes.';
            }
            field("Ignore Zeros-Only Values"; "Ignore Zeros-Only Values")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies that field values that consist of zeros only will be treated as blank values. Such field values can occur when importing payroll files, for example.';
            }
        }
    }
}