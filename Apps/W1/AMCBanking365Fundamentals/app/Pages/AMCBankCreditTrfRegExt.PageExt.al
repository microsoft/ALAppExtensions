pageextension 20108 "AMC Bank Credit Trf. Reg. Ext" extends "Credit Transfer Registers"
{
    layout
    {
        addlast(Group)
        {
            field("XTL Journal"; "AMC Bank XTL Journal")
            {
                ApplicationArea = Basic, Suite;
                Importance = Additional;
                ToolTip = 'XTL Journal associated with the Credit Transfer Register';
                Visible = IsAMCFundamentalsEnabled;
            }
        }
    }
    var
        AMCBankingMgt: Codeunit "AMC Banking Mgt.";
        IsAMCFundamentalsEnabled: Boolean;

    trigger OnOpenPage()
    var
    begin
        IsAMCFundamentalsEnabled := AMCBankingMgt.IsAMCFundamentalsEnabled();
    end;
}