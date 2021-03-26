pageextension 18716 "Posted Purch. Inv Statistics" extends "Purchase Invoice Statistics"
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
        TDSStatistics.GetStatisticsPostedAmount(Rec, TDSAmount);
    end;

    var
        TDSAmount: Decimal;
}