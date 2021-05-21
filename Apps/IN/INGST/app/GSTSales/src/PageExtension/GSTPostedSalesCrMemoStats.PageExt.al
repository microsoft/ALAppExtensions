pageextension 18166 "GST Posted Sales Cr Memo Stats" extends "Sales Credit Memo Statistics"
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
        GSTStatistics.GetStatisticsPostedSalesCrMemoAmount(Rec, GSTAmount);
    end;

    var
        GSTAmount: Decimal;
}