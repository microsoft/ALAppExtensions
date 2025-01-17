pageextension 14607 "IS Small Business Owner RC" extends "Small Business Owner RC"
{
    actions
    {
        addafter("G/L - VAT Reconciliation")
        {
            action("IS VAT Balancing A")
            {
                ApplicationArea = VAT;
                Caption = 'VAT Balancing A';
                Image = "Report";
                RunObject = Report "IS VAT Reconciliation A";
                ToolTip = 'View a VAT reconciliation report for sales and purchases for a specified period. The report lists entries by general ledger account and posting group.';
            }
            action("IS VAT Balancing Report")
            {
                ApplicationArea = VAT;
                Caption = 'VAT Balancing Report';
                Image = "Report";
                RunObject = Report "IS VAT Balancing Report";
                ToolTip = 'Get an overview of VAT for sales and purchases and payments due for a specified period.';
            }
        }
    }
}
