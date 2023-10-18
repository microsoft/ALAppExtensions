pageextension 31034 "Det.Cust.Ledg.Entr.Preview CZL" extends "Det. Cust. Ledg. Entr. Preview"
{
    layout
    {
        addlast(Control1)
        {
#if not CLEAN22
#pragma warning disable AL0432
            field("Customer Posting Group CZL"; Rec."Customer Posting Group CZL")
#pragma warning restore AL0432
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the customer''s market type to link business transactions to.';
                Visible = false;
                ObsoleteState = Pending;
                ObsoleteTag = '22.0';
                ObsoleteReason = 'Replaced by "Posting Group" field.';
            }
#endif
            field("Posting Group CZL"; Rec."Posting Group")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the customer''s market type to link business transactions to.';
            }
        }
    }
}