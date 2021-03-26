pageextension 18932 "Company Information Ext" extends "Company Information"
{
    actions
    {
        addafter(Codes)
        {
            action("Journal Voucher Posting Setup")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Voucher Setup';
                ToolTip = 'Select this option to define voucher no. series for different types of vouchers.';
                RunObject = page "Journal Voucher Posting Setup";
                RunPageLink = "Location Code" = filter('');
                Promoted = true;
                PromotedCategory = Process;
                Image = Voucher;
            }
        }
    }
}