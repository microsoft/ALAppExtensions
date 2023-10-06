#if not CLEAN22
namespace Microsoft.API.V2;

using System.Environment;
using System.Security.AccessControl;

page 30058 "APIV2 - Aut. User Gr. Members"
{
    APIGroup = 'automation';
    APIPublisher = 'microsoft';
    APIVersion = 'v2.0';
    EntityCaption = 'User Group Member';
    EntitySetCaption = 'User Group Members';
    DelayedInsert = true;
    EntityName = 'userGroupMember';
    EntitySetName = 'userGroupMembers';
    Extensible = false;
    PageType = API;
    SourceTable = "User Group Member";
    ODataKeyFields = SystemId;
    ObsoleteState = Pending;
    ObsoleteReason = 'The User Group Member table is deprecated.';
    ObsoleteTag = '22.0';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field(userSecurityId; Rec."User Security ID")
                {
                    Caption = 'User Security Id';
                    Editable = false;
                }
                field("code"; Rec."User Group Code")
                {
                    Caption = 'Code';
                }
                field(displayName; Rec."User Group Name")
                {
                    Caption = 'Display Name';
                }
                field(companyName; Rec."Company Name")
                {
                    Caption = 'Company Name';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnFindRecord(Which: Text): Boolean
    var
        UserSecurityIDFilter: Text;
    begin
        if not LinesLoaded then begin
            UserSecurityIDFilter := Rec.GetFilter("User Security ID");
            if UserSecurityIDFilter = '' then
                Error(UserIDNotSpecifiedForLinesErr);
            if not Rec.FindFirst() then
                exit(false);
            LinesLoaded := true;
        end;

        exit(true);
    end;

    trigger OnOpenPage()
    begin
        BindSubscription(AutomationAPIManagement);
    end;

    var
        AutomationAPIManagement: Codeunit "Automation - API Management";
        UserIDNotSpecifiedForLinesErr: Label 'You must specify a User Security ID to access user groups members.';
        LinesLoaded: Boolean;
}

#endif