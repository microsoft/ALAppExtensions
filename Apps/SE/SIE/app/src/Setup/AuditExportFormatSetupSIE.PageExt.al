pageextension 5315 "Audit Export Format Setup SIE" extends "Audit File Export Format Setup"
{
    actions
    {
        modify(SelectExportDataTypes)
        {
            Enabled = false;
            Visible = false;
        }
    }
}