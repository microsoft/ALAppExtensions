pageextension 11717 "General Ledger Setup CZL" extends "General Ledger Setup"
{
    layout
    {
        addlast(General)
        {
            field("Do Not Check Dimension CZL"; Rec."Do Not Check Dimensions CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies whether the system does or does not check the dimension setup by closing operation depending on whether the field is checked.';
            }
        }
        addlast(content)
        {
            group(VatCZL)
            {
                Caption = 'VAT';

                field("Use VAT Date CZL"; Rec."Use VAT Date CZL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if you want to be able to record different accounting and VAT dates in accounting cases.';
                }
                field("Allow VAT Posting From CZL"; Rec."Allow VAT Posting From CZL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the earliest VAT date on which posting to the company is allowed.';
                }
                field("Allow VAT Posting To CZL"; Rec."Allow VAT Posting To CZL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the latest VAT date on which posting to the company is allowed.';
                }
            }
        }
    }
}
