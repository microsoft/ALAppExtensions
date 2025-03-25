namespace Microsoft.eServices.EDocument;

page 6101 "E-Doc. A/P Administrator"
{
    Caption = 'E-Doc. A/P Administrator';
    PageType = RoleCenter;

    layout
    {
        area(RoleCenter)
        {
            part(Control16; "O365 Activities")
            {
                // AccessByPermission = TableData "Activities Cue" = I;
                ApplicationArea = Basic, Suite;
            }
            part("Report Inbox Part"; "Report Inbox Part")
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }
}
