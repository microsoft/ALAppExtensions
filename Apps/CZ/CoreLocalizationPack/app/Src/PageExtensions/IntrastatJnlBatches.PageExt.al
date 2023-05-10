#if not CLEAN22
#pragma warning disable AL0432
pageextension 31138 "Intrastat Jnl. Batches CZL" extends "Intrastat Jnl. Batches"
#pragma warning restore AL0432
{
    ObsoleteState = Pending;
    ObsoleteTag = '22.0';
    ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';

    layout
    {
        addafter(Reported)
        {
            field("Declaration No. CZL"; Rec."Declaration No. CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the Intrastat declaration number for the Intrastat journal batch.';
                ObsoleteState = Pending;
                ObsoleteTag = '22.0';
                ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';

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
                ObsoleteState = Pending;
                ObsoleteTag = '22.0';
                ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';
            }
        }
    }
}
#endif