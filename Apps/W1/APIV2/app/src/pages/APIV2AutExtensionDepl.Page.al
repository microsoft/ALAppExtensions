namespace Microsoft.API.V2;

using System.Apps;

page 30007 "APIV2 - Aut. Extension Depl."
{
    APIGroup = 'automation';
    APIPublisher = 'microsoft';
    APIVersion = 'v2.0';
    EntityCaption = 'Extension Deployment Status';
    EntitySetCaption = 'Extension Deployment Status';
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
                    Caption = 'Name';
                }
                field(publisher; ExtensionPublisher)
                {
                    Caption = 'Publisher';
                }
                field(operationType; OperationTypeOption)
                {
                    Caption = 'Operation Type';
                }
                field(status; Rec.Status)
                {
                    Caption = 'Status';
                }
                field(schedule; ExtensionSchedule)
                {
                    Caption = 'Schedule';
                    Width = 12;
                }
                field(appVersion; Version)
                {
                    Caption = 'App Version';
                    Width = 6;
                }
                field(startedOn; Rec."Started On")
                {
                    Caption = 'Started On';
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

