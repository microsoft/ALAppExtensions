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
    begin
        FormatLine();
    end;

    local procedure GetTDSAmount()
    var
        TDSStatsManagement: Codeunit "TDS Stats Management";
    begin
        TDSAmount := TDSStatsManagement.GetTDSStatsAmount();
        Calculated := true;
        TDSStatsManagement.ClearSessionVariable();
    end;

    local procedure FormatLine()
    begin
        if not Calculated then
            GetTDSAmount();
    end;

    var

        TDSAmount: Decimal;
        Calculated: Boolean;
}