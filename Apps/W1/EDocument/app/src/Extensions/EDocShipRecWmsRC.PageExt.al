#pragma warning disable AA0247
pageextension 6157 "E-Doc. Ship Rec. WMS RC" extends "Whse. WMS Role Center"
{
    layout
    {
        addafter(ApprovalsActivities)
        {
            part(EDocumentActivities; "E-Doc. Order Map. Activities")
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }
}
