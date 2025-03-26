namespace Microsoft.eServices.EDocument;

using System.Automation;
using Microsoft.Intercompany;
using Microsoft.RoleCenters;
using System.Threading;

page 6101 "E-Doc. A/P Administrator"
{
    Caption = 'E-Doc. A/P Administrator';
    PageType = RoleCenter;

    layout
    {
        area(RoleCenter)
        {
            part(HeadlineRCAPAdministtrator; "E-Doc. Headline RC A/P Admin")
            {
                ApplicationArea = Basic, Suite;
            }
            part(O365Activities; "O365 Activities")
            {
                // AccessByPermission = TableData "Activities Cue" = I;
                ApplicationArea = Basic, Suite;
            }
            part(ApprovalsActivities; "Approvals Activities")
            {
                ApplicationArea = Suite;
            }
            part("Intercompany Activities"; "Intercompany Activities")
            {
                ApplicationArea = Intercompany;
            }
            part(JobQueueActivities; "Job Queue Activities")
            {
                ApplicationArea = Basic, Suite;
            }
            part(TeamMemberActvities; "Team Member Activities No Msgs")
            {
                ApplicationArea = Suite;
            }
            part("Report Inbox Part"; "Report Inbox Part")
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }
}
