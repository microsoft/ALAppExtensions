pageextension 41022 "Hist. Vendor Factbox Ext." extends "Vendor Hist. Buy-from FactBox"
{
    layout
    {
        addlast(Control1)
        {
            field(NoOfHistPayablesTrxTile; Rec."No. of Hist. Payables Trx.")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'GP Payables transactions';
                DrillDownPageID = "Hist. Payables Documents";
                ToolTip = 'Specifies the number of historical payables transactions that have been posted by the vendor.';
            }
            field(NoOfHistReceivingsTrxTile; Rec."No. of Hist. Receivings Trx.")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'GP Receivings transactions';
                DrillDownPageID = "Hist. Purchase Recv. Headers";
                ToolTip = 'Specifies the number of historical purchase receivings transactions that have been posted by the vendor.';
            }
        }
    }
}