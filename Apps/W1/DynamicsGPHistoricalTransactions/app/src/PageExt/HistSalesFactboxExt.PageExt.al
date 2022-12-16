pageextension 41021 "Hist. Sales Factbox Ext." extends "Sales Hist. Sell-to FactBox"
{
    layout
    {
        addlast(Control2)
        {
            field(NoOfHistSalesTrxTile; Rec."No. of Hist. Sales Trx.")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'GP Sales transactions';
                DrillDownPageID = "Hist. Sales Trx. Headers";
                ToolTip = 'Specifies the number of historical sales transactions that have been posted by the customer.';
            }
            field(NoOfHistRecvTrxTile; Rec."No. of Hist. Recv. Trx.")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'GP Receivables transactions';
                DrillDownPageID = "Hist. Receivables Documents";
                ToolTip = 'Specifies the number of historical receivables transactions that have been posted by the customer.';
            }
        }
    }
}