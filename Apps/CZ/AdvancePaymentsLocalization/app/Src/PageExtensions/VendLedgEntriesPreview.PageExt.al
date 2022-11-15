#if not CLEAN19
#pragma warning disable AL0432
pageextension 31055 "Vend. Ledg. Entries PreviewCZZ" extends "Vend. Ledg. Entries Preview"
{
    layout
    {
        modify(Prepayment)
        {
            Visible = false;
        }
        modify("Prepayment Type")
        {
            Visible = false;
        }
        modify("Open For Advance Letter")
        {
            Visible = false;
        }
    }
}
#pragma warning restore AL0432
#endif
