pageextension 11709 "G/L Balance CZL" extends "G/L Balance"
{
    layout
    {
        addafter("Debit Amount")
        {
            field("Debit Amount (VAT Date) CZL"; Rec."Debit Amount (VAT Date) CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the debit in the account balance during the time period in the Date Filter field posted by VAT date';
            }
        }
        addafter("Credit Amount")
        {
            field("Credit Amount (VAT Date) CZL"; Rec."Credit Amount (VAT Date) CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the credit in the account balance during the time period in the Date Filter field posted by VAT date';
            }
        }
        addafter("Net Change")
        {
            field("Net Change (VAT Date) CZL"; Rec."Net Change (VAT Date) CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the net change in the account balance during the time period in the Date Filter field posted by VAT date.';
                Visible = false;
            }
        }
    }
}
