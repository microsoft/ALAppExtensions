pageextension 18165 "GST Posted Sales Inv Stats." extends "Sales Invoice Statistics"
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
        GSTStatistics.GetStatisticsPostedSalesInvAmount(Rec, GSTAmount);
    end;

    var
        GSTAmount: Decimal;
}