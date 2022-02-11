pageextension 11717 "General Ledger Setup CZL" extends "General Ledger Setup"
{
    layout
    {
        addlast(General)
        {
            field("Mark Neg. Qty as Correct. CZL"; Rec."Mark Neg. Qty as Correct. CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies to automatically mark postings with negative quantities as corrections. This will set the Correction field to Yes for any lines with negative quantities.';
            }
            field("Check Posting Debit/Credit CZL"; Rec."Check Posting Debit/Credit CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies checking posting debit/credit.';
            }
            field("Do Not Check Dimension CZL"; Rec."Do Not Check Dimensions CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies whether the system does or does not check the dimension setup by closing operation depending on whether the field is checked.';
            }
            field("Acc. Schedule Results Nos. CZL"; Rec."Acc. Schedule Results Nos. CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the code for the number series that will be used to assign numbers to account schedule results.';
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
#if CLEAN19
        addlast(content)
        {
            group("Other CZL")
            {
                Caption = 'Other';

#else
#pragma warning disable AL0432
        addlast(Other)
#pragma warning restore AL0432
        {
#endif
            field("User Checks Allowed CZL"; Rec."User Checks Allowed CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies whether extended user controls will be activated based on User setup.';
            }
            field("Closed Per. Entry Pos.Date CZL"; Rec."Closed Per. Entry Pos.Date CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the posting date of closed period entries in inventory adjustement';
            }
            field("Rounding Date CZL"; Rec."Rounding Date CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the date for the inventory rounding adjustment by inventory adjustement';
            }
        }
#if CLEAN19
        }
#endif
        addlast(Reporting)
        {
            field("Shared Account Schedule CZL"; Rec."Shared Account Schedule CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies to share the account schedule in general ledger setup.';
            }
        }
#if not CLEAN19
        modify(Other)
        {
            Visible = true;
        }
#endif
    }
}
