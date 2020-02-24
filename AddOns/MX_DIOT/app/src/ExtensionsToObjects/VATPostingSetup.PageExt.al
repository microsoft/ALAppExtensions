pageextension 27038 "DIOT VAT Posting Setup" extends "VAT Posting Setup"
{
    layout
    {
        addafter("VAT Calculation Type")
        {
            field("DIOT WHT %"; "DIOT WHT %")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the withholding tax percentage to be used with this VAT posting setup when exporting the DIOT report. Important: This field only affects the DIOT report.';
            }
        }
    }
}