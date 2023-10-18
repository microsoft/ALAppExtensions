#if not CLEAN22
namespace Microsoft.API.V1;

using System.Environment;
using System.Security.AccessControl;

page 20003 "APIV1 - Aut. User Groups"
{
    APIGroup = 'automation';
    APIPublisher = 'microsoft';
    APIVersion = 'v1.0';
    Caption = 'userGroups', Locked = true;
    DelayedInsert = true;
    DeleteAllowed = false;
    EntityName = 'userGroup';
    EntitySetName = 'userGroups';
    InsertAllowed = false;
    PageType = API;
    SourceTable = "User Group";
    Extensible = false;
    ObsoleteState = Pending;
    ObsoleteReason = 'The User Group table is deprecated.';
    ObsoleteTag = '22.0';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("code"; Rec.Code)
                {
                    Caption = 'code', Locked = true;
                    Editable = false;
                }
                field(displayName; Rec.Name)
                {
                    Caption = 'displayName', Locked = true;
                }
                field(defaultProfileID; Rec."Default Profile ID")
                {
                    Caption = 'defaultProfileID', Locked = true;
                }
                field(assignToAllNewUsers; Rec."Assign to All New Users")
                {
                    Caption = 'assignToAllNewUsers', Locked = true;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        BINDSUBSCRIPTION(AutomationAPIManagement);
    end;

    var
        AutomationAPIManagement: Codeunit "Automation - API Management";
}


#endif