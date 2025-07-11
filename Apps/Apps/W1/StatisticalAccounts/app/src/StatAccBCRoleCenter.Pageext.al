namespace Microsoft.Finance.Analysis.StatisticalAccount;

using Microsoft.Finance.RoleCenters;

pageextension 2620 "Stat. Acc. BC Role Center" extends "Business Manager Role Center"
{
    actions
    {
        addafter(Dimensions)
        {
            action(StatisticalAccounts)
            {
                ApplicationArea = All;
                Caption = 'Statistical Accounts';
                Image = Ledger;
                RunObject = page "Statistical Account List";
                ToolTip = 'Define statistical accounts for tracking non-transactional data.';
            }
        }
    }
}