pageextension 31022 "General Ledger Setup CZZ" extends "General Ledger Setup"
{
    layout
    {
        addlast(General)
        {
            field("Adv. Deduction Exch. Rate CZZ"; Rec."Adv. Deduction Exch. Rate CZZ")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies advance deduction exchange rate.';
                Importance = Additional;
                Visible = false;
            }
        }
#if not CLEAN19
#pragma warning disable AL0432
        modify(Advances)
        {
            Visible = false;
        }
#pragma warning restore AL0432
#endif
    }
}
