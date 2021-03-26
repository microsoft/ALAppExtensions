pageextension 18724 "Posted Purch. Cr Memo Stats." extends "Purch. Credit Memo Statistics"
{
    layout
    {
        addlast(General)
        {
            field("TDS Amount"; TDSAmount)
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                Caption = 'TDS Amount';
                ToolTip = 'Specifies the amount of TDS that is included in the total amount.';
            }
        }
    }
    trigger OnAfterGetRecord()
    var
        TDSStatistics: Codeunit "TDS Statistics";
    begin
        TDSStatistics.GetStatisticsPostedPurchCrMemoAmount(Rec, TDSAmount);
    end;

    var
        TDSAmount: Decimal;
}