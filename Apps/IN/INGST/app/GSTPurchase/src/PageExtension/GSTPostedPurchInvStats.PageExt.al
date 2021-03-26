pageextension 18103 "GST Posted Purch. Inv Stats." extends "Purchase Invoice Statistics"
{
    layout
    {
        addlast(General)
        {
            field("GST Amount"; GSTAmount)
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                Caption = 'GST Amount';
                ToolTip = 'Specifies the amount of GST that is included in the total amount.';
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        GSTStatistics: Codeunit "GST Statistics";
    begin
        GSTStatistics.GetStatisticsPostedPurchInvAmount(Rec, GSTAmount);
    end;

    var
        GSTAmount: Decimal;
}