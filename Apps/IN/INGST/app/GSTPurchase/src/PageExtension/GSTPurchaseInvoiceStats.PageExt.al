pageextension 18102 "GST Purchase Invoice Stats." extends "Purchase Statistics"
{
    layout
    {
        addlast(General)
        {
            field("GST Amount"; GSTAmount)
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the amount of GST that is included in the total amount.';
                Caption = 'GST Amount';
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        GSTStatistics: Codeunit "GST Statistics";
    begin
        GSTStatistics.GetPurchaseStatisticsAmount(Rec, GSTAmount);
    end;

    var
        GSTAmount: Decimal;
}