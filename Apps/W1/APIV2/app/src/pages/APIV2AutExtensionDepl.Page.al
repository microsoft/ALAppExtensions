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
                field(status; Status)
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
                field(startedOn; "Started On")
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
        if "Operation Type" = 0 then
            OperationTypeOption := OperationTypeOption::Install
        else
            OperationTypeOption := OperationTypeOption::Upload;

        ExtensionManagement.GetDeployOperationInfo("Operation ID", Version, ExtensionSchedule, ExtensionPublisher, AppName, Description);
        if Status = Status::InProgress then
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

