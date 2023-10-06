namespace Microsoft.API.V1;

using System.Security.AccessControl;
using System.Environment;

page 20004 "APIV1 - Aut. Users"
{
    APIGroup = 'automation';
    APIPublisher = 'microsoft';
    APIVersion = 'v1.0';
    Caption = 'user', Locked = true;
    DelayedInsert = true;
    DeleteAllowed = false;
    EntityName = 'user';
    EntitySetName = 'users';
    InsertAllowed = false;
    PageType = API;
    SourceTable = User;
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(userSecurityId; Rec."User Security ID")
                {
                    Caption = 'userSecurityId', Locked = true;
                    Editable = false;
                }
                field(userName; Rec."User Name")
                {
                    Caption = 'userName', Locked = true;
                    Editable = false;
                }
                field(displayName; Rec."Full Name")
                {
                    Caption = 'displayName', Locked = true;
                    Editable = false;
                }
                field(state; Rec.State)
                {
                    Caption = 'state', Locked = true;
                }
                field(expiryDate; Rec."Expiry Date")
                {
                    Caption = 'expiryDate', Locked = true;
                }
#if not CLEAN22
                part(userGroupMember; "APIV1 - Aut. User Group Member")
                {
                    Caption = 'userGroupMember', Locked = true;
                    EntityName = 'userGroupMember';
                    EntitySetName = 'userGroupMembers';
                    SubPageLink = "User Security ID" = field("User Security ID");
                    Visible = LegacyUserGroupsVisible;
                    ObsoleteState = Pending;
                    ObsoleteReason = 'The user groups functionality is deprecated.';
                    ObsoleteTag = '22.0';
                }
#endif
                part(userPermission; "APIV1 - Aut. User Permission")
                {
                    Caption = 'userPermission', Locked = true;
                    EntityName = 'userPermission';
                    EntitySetName = 'userPermissions';
                    SubPageLink = "User Security ID" = field("User Security ID");
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    var
#if not CLEAN22
#pragma warning disable AL0432
        LegacyUserGroups: Codeunit "Legacy User Groups";
#pragma warning restore AL0432
#endif
        EnvironmentInformation: Codeunit "Environment Information";
    begin
#if not CLEAN22
        LegacyUserGroupsVisible := LegacyUserGroups.UiElementsVisible();
#endif
        BindSubscription(AutomationAPIManagement);
        if EnvironmentInformation.IsSaaS() then
            Rec.SetFilter("License Type", '<>%1', Rec."License Type"::"External User");
    end;

    var
        AutomationAPIManagement: Codeunit "Automation - API Management";
#if not CLEAN22
        LegacyUserGroupsVisible: Boolean;
#endif
}


