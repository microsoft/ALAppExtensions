#pragma warning disable AA0247
pageextension 6160 "E-Doc. Bus. Manager RC" extends "Business Manager Role Center"
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
