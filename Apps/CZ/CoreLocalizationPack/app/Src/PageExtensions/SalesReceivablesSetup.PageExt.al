pageextension 11718 "Sales & Receivables Setup CZL" extends "Sales & Receivables Setup"
{
    layout
    {
        addlast(content)
        {
            group(VatCZL)
            {
                Caption = 'VAT';

                field("Default VAT Date CZL"; Rec."Default VAT Date CZL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the default VAT date type for sales document (posting date, document date, blank).';
                }
            }
        }
    }
}
