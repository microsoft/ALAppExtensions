pageextension 18933 "Location Card Ext." extends "Location Card"
{
    actions
    {
        addafter("&Bins")
        {
            action("Voucher Setup")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Select this option to define voucher no. series for different types of vouchers.';
                RunObject = page "Journal Voucher Posting Setup";
                RunPageLink = "Location Code" = field(code);
                Promoted = true;
                PromotedCategory = Process;
                Image = Voucher;
            }
        }
    }
}