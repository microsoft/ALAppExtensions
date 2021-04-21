pageextension 18848 "Sales Credit Memo Statistics" extends "Sales Credit Memo Statistics"
{
    layout
    {
        addlast(General)
        {
            field("TCS Amount"; TCSAmount)
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                Caption = 'TCS Amount';
                ToolTip = 'Specifies the total TCS amount that has been calculated for all the lines in the sales document.';
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        TCSSalesManagement: Codeunit "TCS Sales Management";
    begin
        TCSSalesManagement.GetStatisticsAmountPostedCreditMemo(Rec, TCSAmount);
    end;

    var
        TCSAmount: Decimal;
}