pageextension 11719 "Purchases & Payables Setup CZL" extends "Purchases & Payables Setup"
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
                ToolTip = 'Allows you to use a different posting group on the document than the one set on the vendor.';
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
                    ToolTip = 'Specifies the default VAT date type for purchase document (posting date, document date, blank).';
                }
                field("Def. Orig. Doc. VAT Date CZL"; Rec."Def. Orig. Doc. VAT Date CZL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the default original document VAT date type for purchase document (posting date, document date, VAT date or blank).';
                }
            }
        }
    }
}
