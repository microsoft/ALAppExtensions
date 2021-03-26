pageextension 1152 "COHUB Business Manager RC" extends "Business Manager Role Center"
{
    layout
    {
        addafter(Control55)
        {
            part(COHUBShortSummary; "COHUB Company Short Summary")
            {
                ApplicationArea = Basic, Suite;
                Visible = false;
            }
        }
    }
}