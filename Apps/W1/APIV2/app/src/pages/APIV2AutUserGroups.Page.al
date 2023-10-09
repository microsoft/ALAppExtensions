#if not CLEAN22
namespace Microsoft.API.V2;

using System.Environment;
using System.Security.AccessControl;

page 30003 "APIV2 - Aut. User Groups"
{
    APIGroup = 'automation';
    APIPublisher = 'microsoft';
    APIVersion = 'v2.0';
    EntityCaption = 'User Group';
    EntitySetCaption = 'User Groups';
    DelayedInsert = true;
    EntityName = 'userGroup';
    EntitySetName = 'userGroups';
    PageType = API;
    SourceTable = "User Group";
    Extensible = false;
    ODataKeyFields = SystemId;
    ObsoleteState = Pending;
    ObsoleteReason = 'The User Group table is deprecated.';
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
                field("code"; Rec.Code)
                {
                    Caption = 'Code';
                }
                field(displayName; Rec.Name)
                {
                    Caption = 'Display Name';
                }
                field(defaultProfileID; Rec."Default Profile ID")
                {
                    Caption = 'Default Profile Id';
                }
                field(assignToAllNewUsers; Rec."Assign to All New Users")
                {
                    Caption = 'Assign To All New Users';
                }
                part(defaultProfile; "APIV2 - Aut. Profiles")
                {
                    Caption = 'Default Profile';
                    EntityName = 'profile';
                    EntitySetName = 'profiles';
                    Multiplicity = ZeroOrOne;
                    SubPageLink = "Profile ID" = field("Default Profile ID"), "App ID" = field("Default Profile App ID"), Scope = field("Default Profile Scope");
                }
                part(userGroupPermissions; "APIV2 - Aut. User Group Perm.")
                {
                    Caption = 'User Group Permissions';
                    EntityName = 'userGroupPermission';
                    EntitySetName = 'userGroupPermissions';
                    SubPageLink = "User Group Code" = field(Code);
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        BindSubscription(AutomationAPIManagement);
    end;

    var
        AutomationAPIManagement: Codeunit "Automation - API Management";
}

#endif