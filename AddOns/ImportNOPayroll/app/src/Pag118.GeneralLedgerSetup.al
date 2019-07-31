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
                ToolTip = 'Specifies if data from the two first dimensions in the import file must be copied to the journal line as global dimension codes.';
            }
        }
    }
}