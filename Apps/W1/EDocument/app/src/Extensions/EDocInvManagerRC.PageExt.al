#pragma warning disable AA0247
pageextension 6158 "E-Doc. Inv. Manager RC" extends "Whse. Basic Role Center"
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
