pageextension 18104 "GST Posted Purch Cr Memo Stats" extends "Purch. Credit Memo Statistics"
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
        GSTStatistics.GetStatisticsPostedPurchCrMemoAmount(Rec, GSTAmount);
    end;

    var
        GSTAmount: Decimal;
}