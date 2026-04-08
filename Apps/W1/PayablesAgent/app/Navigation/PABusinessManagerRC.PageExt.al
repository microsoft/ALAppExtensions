#pragma warning disable AA0247
pageextension 3312 PABusinessManagerRC extends "Business Manager Role Center"
{
    layout
    {
        addafter(ApprovalsActivities)
        {
            part(PayablesAgentActivities; "Payables Agent Activities")
            {
                ApplicationArea = Basic, Suite;
                AccessByPermission = tabledata "Payables Agent Setup" = R;
                Visible = false;
            }
        }
    }
}
