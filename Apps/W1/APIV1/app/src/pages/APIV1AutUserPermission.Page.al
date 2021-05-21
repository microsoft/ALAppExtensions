page 20060 "APIV1 - Aut. User Permission"
{
    Caption = 'userPermission', Locked = true;
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "Access Control";
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; "Role ID")
                {
                    ApplicationArea = All;
                    Caption = 'id', Locked = true;

                    trigger OnValidate()
                    var
                        AggregatePermissionSet: Record "Aggregate Permission Set";
                    begin
                        AggregatePermissionSet.SetRange("Role ID", "Role ID");
                        AggregatePermissionSet.FindFirst();

                        if AggregatePermissionSet.Count > 1 then
                            Error(MultipleRoleIDErr, "Role ID");

                        Scope := AggregatePermissionSet.Scope;
                        "App ID" := AggregatePermissionSet."App ID";
                    end;
                }
                field(displayName; "Role Name")
                {
                    ApplicationArea = All;
                    Caption = 'displayName', Locked = true;
                    Editable = false;
                    ToolTip = 'Specifies the name of the security role that has been given to this Windows login in the current database.';
                }
                field(company; "Company Name")
                {
                    ApplicationArea = All;
                    Caption = 'company', Locked = true;
                }
                field(appId; "App ID")
                {
                    ApplicationArea = All;
                    Caption = 'appId';
                }
                field(extensionName; "App Name")
                {
                    ApplicationArea = All;
                    Caption = 'extensionName', Locked = true;
                    Editable = false;
                }
                field(scope; Scope)
                {
                    ApplicationArea = All;
                    Caption = 'scope';
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
            UserSecurityIDFilter := GetFilter("User Security ID");
            if UserSecurityIDFilter = '' then
                Error(UserIDNotSpecifiedForLinesErr);
            if not FindFirst() then
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
        MultipleRoleIDErr: Label 'The permission set %1 is defined multiple times in this context.', Comment = '%1 will be replaced with a Role ID code value from the Permission Set table';
        UserIDNotSpecifiedForLinesErr: Label 'You must specify a User Security ID to access user permissions.';
        LinesLoaded: Boolean;
}

