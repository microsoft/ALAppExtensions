pageextension 18845 "Sales Statistics" extends "Sales Statistics"
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
        modify(InvDiscountAmount)
        {
            trigger OnAfterValidate()
            var
                TCSSalesManagement: Codeunit "TCS Sales Management";
            begin
                TCSSalesManagement.UpdateTaxAmount(Rec);
            end;
        }
    }

    trigger OnAfterGetRecord()
    begin
        FormatLine();
    end;

    local procedure GetTCSAmount()
    var
        TCSStatsManagement: Codeunit "TCS Stats Management";
    begin
        TCSAmount := TCSStatsManagement.GetTCSStatsAmount();
        Calculated := true;
        TCSStatsManagement.ClearSessionVariable();
    end;

    local procedure FormatLine()
    begin
        if not Calculated then
            GetTCSAmount();
    end;

    var
        TCSAmount: Decimal;
        Calculated: Boolean;
}