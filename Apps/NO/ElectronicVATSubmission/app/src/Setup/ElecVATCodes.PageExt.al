pageextension 10699 "Elec. VAT Codes" extends "VAT Codes"
{
    layout
    {
        addlast(Control1080000)
        {
            field("VAT Rate For Reporting"; "VAT Rate For Reporting")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the VAT rate to report.';
            }
            field("Report VAT Rate"; "Report VAT Rate")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies whether the VAT rate value must be reported.';
            }
        }
    }
}