page 30075 "APIV2 - Aut. User Group Perm."
{
    APIGroup = 'automation';
    APIPublisher = 'microsoft';
    APIVersion = 'v2.0';
    EntityCaption = 'User Group Permission';
    EntitySetCaption = 'User Group Permissions';
    DelayedInsert = true;
    EntityName = 'userGroupPermission';
    EntitySetName = 'userGroupPermissions';
    Extensible = false;
    PageType = API;
    SourceTable = "User Group Permission Set";
    ODataKeyFields = SystemId;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field(userGroupCode; "User Group Code")
                {
                    Caption = 'User Group Code';
                    Editable = false;
                }
                field(roleId; "Role ID")
                {
                    Caption = 'Role Id';
                }
                field(displayName; "Role Name")
                {
                    Caption = 'Display Name';
                    Editable = false;
                }
                field(appId; "App ID")
                {
                    Caption = 'App Id';
                }
                field(extensionName; "Extension Name")
                {
                    Caption = 'Extension Name';
                    Editable = false;
                }
                field(scope; Scope)
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

    trigger OnAfterGetCurrRecord()
    begin
        if not FilterChecked then begin
            CheckFilter();
            FilterChecked := true;
        end;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        CheckFilter();
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
        UserGroupCodeNotSpecifiedForLinesErr: Label 'You must specify a User Group Code to access user group permissions.';
        FilterChecked: Boolean;
        ScopeDefined: Boolean;

    local procedure CheckFilter()
    begin
        if Rec.GetFilter("User Group Code") = '' then
            Error(UserGroupCodeNotSpecifiedForLinesErr);
    end;
}

