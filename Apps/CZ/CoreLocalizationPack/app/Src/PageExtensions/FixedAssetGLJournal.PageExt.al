pageextension 31212 "Fixed Asset G/L Journal CZL" extends "Fixed Asset G/L Journal"
{
    layout
    {
        addafter("Posting Date")
        {
            field("VAT Date CZL"; Rec."VAT Date CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies date by which the accounting transaction will enter VAT statement.';
            }
            field("Original Doc. VAT Date CZL"; Rec."Original Doc. VAT Date CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the VAT date of the original document.';
                Visible = false;
            }
        }
        addafter("Account No.")
        {
            field("Posting Group CZL"; Rec."Posting Group")
            {
                ApplicationArea = Suite;
                ToolTip = 'Specifies the posting group that will be used in posting the journal line.The field is used only if the account type is either customer or vendor.';
                Visible = false;
            }
        }
        addbefore(Amount)
        {
            field("Correction CZL"; Rec.Correction)
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the entry as a corrective entry. You can use the field if you need to post a corrective entry to an account.';
                Visible = false;
            }
        }
        addafter(Amount)
        {
            field("Amount (LCY) CZL"; Rec."Amount (LCY)")
            {
                ApplicationArea = FixedAssets;
                ToolTip = 'Specifies the total amount that the journal line consists of.';
            }
        }
    }
}
