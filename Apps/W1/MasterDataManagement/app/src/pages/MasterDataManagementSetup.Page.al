namespace Microsoft.Integration.MDM;

using Microsoft.Integration.SyncEngine;
using System.Threading;
using System.Environment.Configuration;
using System.Telemetry;
using System.Utilities;

page 7230 "Master Data Management Setup"
{
    ApplicationArea = Suite;
    Caption = 'Master Data Management Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ShowFilter = false;
    SourceTable = "Master Data Management Setup";
    UsageCategory = Administration;
    AdditionalSearchTerms = 'mdm,master data';
    Permissions = tabledata "Master Data Management Setup" = imd;

    layout
    {
        area(content)
        {
            group(Connection)
            {
                field("Company Name"; Rec."Company Name")
                {
                    ApplicationArea = Suite;
                    Editable = IsEditable;
                    ToolTip = 'Specifies the name of the source company that you synchronize data from.';
                }
                field("Is Enabled"; Rec."Is Enabled")
                {
                    ApplicationArea = Suite;
                    Caption = 'Enable Data Synchronization';
                    ToolTip = 'Specifies whether data synchronization with the chosen source company.';
                }
                field("Delay Job Scheduling"; Rec."Delay Job Scheduling")
                {
                    ApplicationArea = Suite;
                    Visible = false;
                    ToolTip = 'Specifies if the starting of the synchronization jobs should be delayed until a licensed user starts them explicitly from Job Queue Entries list.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ResetConfiguration)
            {
                ApplicationArea = Suite;
                Caption = 'Use Default Synchronization Setup';
                Image = ResetStatus;
                ToolTip = 'Resets the synchronization tables, fields, and job queue entries to the default values for the connection with the source company. All current synchronization tables are deleted and recreated.';

                trigger OnAction()
                var
                    MasterDataManagementSetupDefaults: Codeunit "Master Data Mgt. Setup Default";
                    MasterDataManagement: Codeunit "Master Data Management";
                begin
                    MasterDataManagement.CheckSetupPermissions();
                    if Confirm(ResetIntegrationTableMappingConfirmQst, false) then begin
                        MasterDataManagementSetupDefaults.ResetConfiguration(Rec);
                        Message(SetupSuccessfulMsg);
                    end;
                end;
            }
            action(ExportSetup)
            {
                ApplicationArea = Suite;
                Caption = 'Export Setup';
                Image = ExportFile;
                ToolTip = 'Export the setup tables.';

                trigger OnAction()
                var
                    DotNetExceptionHandler: Codeunit "DotNet Exception Handler";
                begin
                    if not TryExportSetup() then begin
                        DotNetExceptionHandler.Collect();
                        Error(DotNetExceptionHandler.GetMessage())
                    end;
                end;
            }
            action(ImportSetup)
            {
                ApplicationArea = Suite;
                Caption = 'Import Setup';
                Image = Import;
                ToolTip = 'Import the setup tables.';

                trigger OnAction()
                var
                    DotNetExceptionHandler: Codeunit "DotNet Exception Handler";
                    MasterDataManagement: Codeunit "Master Data Management";
                begin
                    MasterDataManagement.CheckSetupPermissions();
                    if not Confirm(ImportIntegrationTableMappingConfirmQst, false) then
                        exit;

                    if not TryImportSetup() then begin
                        DotNetExceptionHandler.Collect();
                        Error(DotNetExceptionHandler.GetMessage())
                    end;

                    Message(SynchronizationImportedMsg);
                end;
            }
            action(StartInitialSynchAction)
            {
                ApplicationArea = Suite;
                Caption = 'Start Initial Synchronization';
                Enabled = Rec."Is Enabled";
                Image = RefreshLines;
                ToolTip = 'Start all the default synchronization jobs for synchronizing data from the source company. \\Data is synchronized according to the mappings defined on the Synchronization Tables page.';
                RunObject = page "Master Data Full Synch. Review";
            }
            action(SynchronizeNow)
            {
                ApplicationArea = Suite;
                Caption = 'Synchronize Modified Records';
                Enabled = Rec."Is Enabled";
                Image = Refresh;
                ToolTip = 'Synchronize records that have been modified since the last time they were synchronized.';

                trigger OnAction()
                var
                    MasterDataMgtCoupling: Record "Master Data Mgt. Coupling";
                    MasterDataManagement: Codeunit "Master Data Management";
                    IntegrationSynchJobList: Page "Integration Synch. Job List";
                begin
                    MasterDataManagement.CheckUsagePermissions();
                    MasterDataManagement.CheckTaskSchedulePermissions();
                    if MasterDataMgtCoupling.IsEmpty() then begin
                        Message(NoCoupledRecordsMsg);
                        exit;
                    end;

                    if not Confirm(SynchronizeModifiedQst) then
                        exit;

                    Rec.SynchronizeNow(false);
                    Message(SyncNowScheduledMsg, IntegrationSynchJobList.Caption());
                end;
            }
            action("Synch. Job Queue Entries")
            {
                ApplicationArea = Suite;
                Caption = 'Synch. Job Queue Entries';
                Image = JobListSetup;
                ToolTip = 'View the job queue entries that manage the scheduled data synchronization.';

                trigger OnAction()
                var
                    JobQueueEntry: Record "Job Queue Entry";
                begin
                    JobQueueEntry.FilterGroup := 2;
                    JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
                    JobQueueEntry.SetFilter("Object ID to Run", GetJobQueueEntriesObjectIDToRunFilter());
                    JobQueueEntry.FilterGroup := 0;

                    PAGE.Run(PAGE::"Job Queue Entries", JobQueueEntry);
                end;
            }
            action(IntegrationTableMappings)
            {
                ApplicationArea = Suite;
                Caption = 'Synchronization Tables';
                Image = MapAccounts;
                ToolTip = 'View the list of tables to synchronize.';

                trigger OnAction()
                begin
                    Page.Run(Page::"Master Data Synch. Tables");
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Synchronization', Comment = 'Generated from the PromotedActionCategories property index 5.';

                actionref(StartInitialSynchAction_Promoted; StartInitialSynchAction)
                {
                }
                actionref(IntegrationTableMappings_Promoted; IntegrationTableMappings)
                {
                }
                actionref("Synch. Job Queue Entries_Promoted"; "Synch. Job Queue Entries")
                {
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        RefreshData();
    end;

    trigger OnInit()
    var
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        ApplicationAreaMgmtFacade.CheckAppAreaOnlyBasic();
    end;

    trigger OnOpenPage()
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        MasterDataManagement: Codeunit "Master Data Management";
    begin
        FeatureTelemetry.LogUptake('0000JIV', MasterDataManagement.GetFeatureName(), Enum::"Feature Uptake Status"::Discovered);
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if not Rec."Is Enabled" then
            if not Confirm(StrSubstNo(EnableServiceQst, CurrPage.Caption()), true) then
                exit(false);
    end;

    [TryFunction]
    local procedure TryExportSetup()
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        MasterDataManagement: Codeunit "Master Data Management";
    begin
        IntegrationTableMapping.SetRange(Type, IntegrationTableMapping.Type::"Master Data Management");
        IntegrationTableMapping.SetRange("Delete After Synchronization", false);
        Session.LogMessage('0000JIW', CompanyName(), Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::ExtensionPublisher, 'Category', MasterDataManagement.GetTelemetryCategory());
        Xmlport.Run(Xmlport::ExportMDMSetup, false, false, IntegrationTableMapping);
    end;

    [TryFunction]
    local procedure TryImportSetup()
    var
        MasterDataManagement: Codeunit "Master Data Management";
    begin
        Session.LogMessage('0000JIX', CompanyName(), Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::ExtensionPublisher, 'Category', MasterDataManagement.GetTelemetryCategory());
        Xmlport.Run(XmlPort::ImportMDMSetup, false, true);
    end;

    var
        ResetIntegrationTableMappingConfirmQst: Label 'This will restore the default synchronization table setup and synchronization jobs. \\All existing customizations to synchronization table setup and jobs will be overwritten.\\Do you want to continue?';
        ImportIntegrationTableMappingConfirmQst: Label 'This will import the synchronization table setup from a chosen file. \\Existing synchronization tables and fields will be overwritten with the version from the file.\\Existing synchronization job queue entries will not be overwritten. Do you want to continue?';
        EnableServiceQst: Label 'The %1 is not enabled. Are you sure you want to exit?', Comment = '%1 = This Page Caption (Business Central Connection Setup)';
        SynchronizeModifiedQst: Label 'This will synchronize all modified records in all integration table mappings. \\The synchronization will run in the background so you can continue with other tasks. \\Do you want to continue?';
        SyncNowScheduledMsg: Label 'Synchronization of modified records is scheduled. \\You can view details on the %1 page.', Comment = '%1 = The localized caption of page Integration Synch. Job List';
        SetupSuccessfulMsg: Label 'The default setup for Business Central synchronization has completed successfully.';
        IsEditable: Boolean;
        SynchronizationImportedMsg: label 'The synchronization setup is imported. \\To view or edit the synchronization table setup, choose action Synchronization Tables.\\To view or edit the synchronization field setup, select a synchronization table and choose action Synchronization Fields.';
        NoCoupledRecordsMsg: label 'No records are currently coupled to records from the source company. \\Choose the action Start Initial Synchronization.';

    local procedure RefreshData()
    begin
        UpdateEnableFlags();
    end;

    local procedure UpdateEnableFlags()
    begin
        IsEditable := (not Rec."Is Enabled");
    end;

    local procedure GetJobQueueEntriesObjectIDToRunFilter(): Text
    begin
        exit(Format(Codeunit::"Integration Synch. Job Runner") + '|' + Format(Codeunit::"Int. Uncouple Job Runner") + '|' + Format(Codeunit::"Int. Coupling Job Runner"));
    end;
}
