pageextension 10827 "Audit Export Format Setup FEC" extends "Audit File Export Format Setup"
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