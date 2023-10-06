namespace Microsoft.API.V1;

using System.Environment;
using System.Security.AccessControl;

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
                field(id; Rec."Role ID")
                {
                    ApplicationArea = All;
                    Caption = 'id', Locked = true;
                    ToolTip = 'Specifies the role id.';

                    trigger OnValidate()
                    var
                        AggregatePermissionSet: Record "Aggregate Permission Set";
                    begin
                        AggregatePermissionSet.SetRange("Role ID", Rec."Role ID");
                        AggregatePermissionSet.FindFirst();

                        if AggregatePermissionSet.Count > 1 then
                            Error(MultipleRoleIDErr, Rec."Role ID");

                        Rec.Scope := AggregatePermissionSet.Scope;
                        Rec."App ID" := AggregatePermissionSet."App ID";
                    end;
                }
                field(displayName; Rec."Role Name")
                {
                    ApplicationArea = All;
                    Caption = 'displayName', Locked = true;
                    Editable = false;
                    ToolTip = 'Specifies the name of the security role that has been given to this Windows login in the current database.';
                }
                field(company; Rec."Company Name")
                {
                    ApplicationArea = All;
                    Caption = 'company', Locked = true;
                    ToolTip = 'Specifies the company name.';
                }
                field(appId; Rec."App ID")
                {
                    ApplicationArea = All;
                    Caption = 'appId';
                    ToolTip = 'Specifies the app id.';
                }
                field(extensionName; Rec."App Name")
                {
                    ApplicationArea = All;
                    Caption = 'extensionName', Locked = true;
                    Editable = false;
                    ToolTip = 'Specifies the app name.';
                }
                field(scope; Rec.Scope)
                {
                    ApplicationArea = All;
                    Caption = 'scope';
                    ToolTip = 'Specifies the scope.';
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
        MultipleRoleIDErr: Label 'The permission set %1 is defined multiple times in this context.', Comment = '%1 will be replaced with a Role ID code value from the Permission Set table';
        UserIDNotSpecifiedForLinesErr: Label 'You must specify a User Security ID to access user permissions.';
        LinesLoaded: Boolean;
}


