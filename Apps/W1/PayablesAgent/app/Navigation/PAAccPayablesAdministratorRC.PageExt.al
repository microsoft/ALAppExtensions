#pragma warning disable AA0247
pageextension 3311 PAAccPayablesAdministratorRC extends "Acc. Payable Administrator RC"
{
    layout
    {
        addafter(ApprovalsActivities)
        {
            part(PayablesAgentActivities; "Payables Agent Activities")
            {
                ApplicationArea = Basic, Suite;
                AccessByPermission = tabledata "Payables Agent Setup" = R;
            }
        }
    }
}
