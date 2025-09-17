#pragma warning disable AA0247
pageextension 6125 EDocAccountantRC extends "Accountant Role Center"
{
    layout
    {
        addafter(ApprovalsActivities)
        {
            part(EDocumentActivities; "E-Document Activities")
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }
}
