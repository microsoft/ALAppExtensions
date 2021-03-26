pageextension 18553 "Tax Acc. Period Setup" extends "Tax Acc. Period Setup"
{
    actions
    {
        addfirst(Processing)
        {
            action("Accounting Period")
            {
                ApplicationArea = Basic, Suite;
                Image = AccountingPeriods;
                RunObject = page "Tax Accounting Periods";
                RunPageLink = "Tax Type Code" = field(Code);
                ToolTip = 'Specifies the accounting period for the tax type.';
            }
        }
    }
}