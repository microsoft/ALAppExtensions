pageextension 11720 "Service Mgt. Setup CZL" extends "Service Mgt. Setup"
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
                    ToolTip = 'Specifies the default VAT date type for service document (posting date, document date, blank).';
                }
            }
        }
    }
}
