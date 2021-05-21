page 20007 "APIV1 - Aut. Extension Depl."
{
    APIGroup = 'automation';
    APIPublisher = 'microsoft';
    APIVersion = 'v1.0';
    Caption = 'extensionDeploymentStatus', Locked = true;
    DelayedInsert = true;
    DeleteAllowed = false;
    Editable = false;
    EntityName = 'extensionDeploymentStatus';
    EntitySetName = 'extensionDeploymentStatus';
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = API;
    RefreshOnActivate = true;
    SourceTable = "NAV App Tenant Operation";
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(name; AppName)
                {
                    Caption = 'name', Locked = true;
                    ToolTip = 'Specifies the name of the App.';
                }
                field(publisher; ExtensionPublisher)
                {
                    Caption = 'publisher', Locked = true;
                    ToolTip = 'Specifies the name of the App Publisher.';
                }
                field(operationType; OperationTypeOption)
                {
                    Caption = 'operationType', Locked = true;
                    ToolTip = 'Specifies the deployment type.';
                }
                field(status; Status)
                {
                    Caption = 'status', Locked = true;
                    ToolTip = 'Specifies the deployment status.';
                }
                field(schedule; ExtensionSchedule)
                {
                    Caption = 'schedule', Locked = true;
                    ToolTip = 'Specifies the deployment Schedule.';
                    Width = 12;
                }
                field(appVersion; Version)
                {
                    Caption = 'appVersion', Locked = true;
                    ToolTip = 'Specifies the version of the App.';
                    Width = 6;
                }
                field(startedOn; "Started On")
                {
                    Caption = 'startedOn', Locked = true;
                    ToolTip = 'Specifies the deployment start date.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
        }
    }

    trigger OnAfterGetRecord()
    begin
        IF "Operation Type" = 0 THEN
            OperationTypeOption := OperationTypeOption::Install
        ELSE
            OperationTypeOption := OperationTypeOption::Upload;

        ExtensionManagement.GetDeployOperationInfo("Operation ID", Version, ExtensionSchedule, ExtensionPublisher, AppName, Description);
        IF Status = Status::InProgress THEN
            ExtensionManagement.RefreshStatus("Operation ID");
    end;

    trigger OnOpenPage()
    begin
        SetCurrentKey("Started On");
        Ascending(false);
    end;

    var
        ExtensionManagement: Codeunit "Extension Management";
        Version: Text;
        ExtensionSchedule: Text;
        ExtensionPublisher: Text;
        AppName: Text;
        OperationTypeOption: Option Upload,Install;
}

