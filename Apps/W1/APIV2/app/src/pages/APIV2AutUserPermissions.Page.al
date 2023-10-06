namespace Microsoft.API.V2;

using System.Environment;
using System.Security.AccessControl;

page 30059 "APIV2 - Aut. User Permissions"
{
    APIGroup = 'automation';
    APIPublisher = 'microsoft';
    APIVersion = 'v2.0';
    EntityCaption = 'User Permission';
    EntitySetCaption = 'User Permissions';
    DelayedInsert = true;
    EntityName = 'userPermission';
    EntitySetName = 'userPermissions';
    Extensible = false;
    PageType = API;
    SourceTable = "Access Control";
    ODataKeyFields = SystemId;

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
                field(roleId; Rec."Role ID")
                {
                    Caption = 'Role Id';
                }
                field(displayName; Rec."Role Name")
                {
                    Caption = 'Display Name';
                    Editable = false;
                }
                field(company; Rec."Company Name")
                {
                    Caption = 'Company';
                }
                field(appId; Rec."App ID")
                {
                    Caption = 'App Id';
                }
                field(extensionName; Rec."App Name")
                {
                    Caption = 'Extension Name';
                    Editable = false;
                }
                field(scope; Rec.Scope)
                {
                    Caption = 'Scope';

                    trigger OnValidate()
                    begin
                        ScopeDefined := true;
                    end;
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

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        AggregatePermissionSet: Record "Aggregate Permission Set";
    begin
        if Rec."Role ID" <> '' then
            AggregatePermissionSet.SetRange("Role ID", Rec."Role ID");
        if not IsNullGuid(Rec."App ID") then
            AggregatePermissionSet.SetRange("App ID", Rec."App ID");
        if ScopeDefined then
            AggregatePermissionSet.SetRange(Scope, Rec.Scope);

        if AggregatePermissionSet.Count() > 1 then
            Error(MultipleRoleIDErr, Rec."Role ID");

        AggregatePermissionSet.FindFirst();
        Rec.Scope := AggregatePermissionSet.Scope;
        Rec."App ID" := AggregatePermissionSet."App ID";
    end;

    var
        AutomationAPIManagement: Codeunit "Automation - API Management";
        MultipleRoleIDErr: Label 'The permission set %1 is defined multiple times in this context.', Comment = '%1 will be replaced with a Role ID code value from the Permission Set table';
        UserIDNotSpecifiedForLinesErr: Label 'You must specify a User Security ID to access user permissions.';
        LinesLoaded: Boolean;
        ScopeDefined: Boolean;
}

