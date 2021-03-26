pageextension 31138 "Intrastat Jnl. Batches CZL" extends "Intrastat Jnl. Batches"
{
    layout
    {
        addafter(Reported)
        {
            field("Declaration No. CZL"; Rec."Declaration No. CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the Intrastat declaration number for the Intrastat journal batch.';

                trigger OnAssistEdit()
                begin
                    if Rec.AssistEditCZL() then
                        CurrPage.Update();
                end;
            }
            field("Statement Type CZL"; Rec."Statement Type CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies a Intrastat Declaration type for the Intrastat journal batch.';
            }
        }
    }
}