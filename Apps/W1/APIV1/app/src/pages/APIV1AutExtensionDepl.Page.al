namespace Microsoft.API.V1;

using System.Apps;
using System.Environment.Configuration;

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
                field(status; Rec.Status)
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
                field(startedOn; Rec."Started On")
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
        if Rec."Operation Type" = 0 then
            OperationTypeOption := OperationTypeOption::Install
        else
            OperationTypeOption := OperationTypeOption::Upload;

        ExtensionManagement.GetDeployOperationInfo(Rec."Operation ID", Version, ExtensionSchedule, ExtensionPublisher, AppName, Rec.Description);
        if Rec.Status = Rec.Status::InProgress then
            ExtensionManagement.RefreshStatus(Rec."Operation ID");
    end;

    trigger OnOpenPage()
    begin
        Rec.SetCurrentKey("Started On");
        Rec.Ascending(false);
    end;

    var
        ExtensionManagement: Codeunit "Extension Management";
        Version: Text;
        ExtensionSchedule: Text;
        ExtensionPublisher: Text;
        AppName: Text;
        OperationTypeOption: Option Upload,Install;
}


