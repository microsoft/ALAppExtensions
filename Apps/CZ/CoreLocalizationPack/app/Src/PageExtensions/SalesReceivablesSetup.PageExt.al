pageextension 11718 "Sales & Receivables Setup CZL" extends "Sales & Receivables Setup"
{
    layout
    {
#if not CLEAN20
        modify("Allow Multiple Posting Groups")
        {
            Visible = false;
        }
        addlast(General)
        {
            field("Allow Alter Posting Groups CZL"; Rec."Allow Alter Posting Groups CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Allows you to use a different posting group on the document than the one set on the customer.';
                ObsoleteState = Pending;
                ObsoleteTag = '20.1';
                ObsoleteReason = 'It will be replaced by "Allow Multiple Posting Groups" field.';
            }
        }
#endif
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
