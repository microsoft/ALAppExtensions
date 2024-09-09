// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Integration.DynamicsFieldService;

using Microsoft.Integration.Dataverse;
using Microsoft.Integration.SyncEngine;
using System.Environment.Configuration;
using System.Telemetry;
using System.Threading;
using Microsoft.Integration.D365Sales;
using Microsoft.Projects.Project.Journal;

page 6612 "FS Connection Setup"
{
    AccessByPermission = TableData "FS Connection Setup" = IM;
    ApplicationArea = Suite;
    Caption = 'Dynamics 365 Field Service Integration Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ShowFilter = false;
    SourceTable = "FS Connection Setup";
    UsageCategory = Administration;
    AdditionalSearchTerms = 'Dynamics 365 Field Service Connection Setup';

    layout
    {
        area(content)
        {
            group(NAVToFS)
            {
                Caption = 'Connection from Dynamics 365 Business Central to Dynamics 365 Field Service';
                field("Server Address"; Rec."Server Address")
                {
                    ApplicationArea = Suite;
                    Editable = IsEditable;
                    ToolTip = 'Specifies the URL of the environment that hosts the Dynamics 365 Field Service solution that you want to connect to.';

                    trigger OnValidate()
                    begin
                        ConnectionString := Rec.GetConnectionStringAsStoredInSetup();
                    end;
                }
                field("Is Enabled"; Rec."Is Enabled")
                {
                    ApplicationArea = Suite;
                    Caption = 'Enabled', Comment = 'Name of tickbox which shows whether the connection is enabled or disabled';
                    ToolTip = 'Specifies if the connection to Dynamics 365 Field Service is enabled. When you check this checkbox, you will be prompted to sign-in to Dataverse with an administrator user account. The account will be used one time to give consent to, install and configure applications and components that the integration requires.';

                    trigger OnValidate()
                    var
                        FeatureTelemetry: Codeunit "Feature Telemetry";
                        CDSIntegrationImpl: Codeunit "CDS Integration Impl.";
                    begin
                        CurrPage.Update(true);
                        if Rec."Is Enabled" then begin
                            FeatureTelemetry.LogUptake('0000MB9', 'Dynamics 365 Field Service', Enum::"Feature Uptake Status"::"Set up");
                            Session.LogMessage('0000MBC', CRMConnEnabledOnPageTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);

                            if (Rec."Server Address" <> '') and (Rec."Server Address" <> TestServerAddressTok) then
                                if CDSIntegrationImpl.MultipleCompaniesConnected() then
                                    CDSIntegrationImpl.SendMultipleCompaniesNotification();
                        end;
                    end;
                }
                field(ScheduledSynchJobsActive; ScheduledSynchJobsRunning)
                {
                    ApplicationArea = Suite;
                    Caption = 'Active scheduled synchronization jobs';
                    Editable = false;
                    StyleExpr = ScheduledSynchJobsRunningStyleExpr;
                    ToolTip = 'Specifies how many of the default integration synchronization job queue entries ready to automatically synchronize data between Business Central and Dynamics 365 Field Service.';

                    trigger OnDrillDown()
                    var
                        ScheduledSynchJobsRunningMsg: Text;
                    begin
                        if TotalJobs = 0 then
                            ScheduledSynchJobsRunningMsg := JobQueueIsNotRunningMsg
                        else
                            if ActiveJobs = TotalJobs then
                                ScheduledSynchJobsRunningMsg := AllScheduledJobsAreRunningMsg
                            else
                                ScheduledSynchJobsRunningMsg := StrSubstNo(PartialScheduledJobsAreRunningMsg, ActiveJobs, TotalJobs);
                        Message(ScheduledSynchJobsRunningMsg);
                    end;
                }
            }
            group(FSSettings)
            {
                Caption = 'Additional Settings';
                Visible = true;
                field("Is FS Solution Installed"; Rec."Is FS Solution Installed")
                {
                    ApplicationArea = Suite;
                    Caption = 'Dynamics 365 Business Central Integration Solution Imported to Field Service';
                    Editable = false;
                    Visible = false;
                    StyleExpr = CRMSolutionInstalledStyleExpr;
                    ToolTip = 'Specifies if the Integration Solution is installed and configured in Dynamics 365 Field Service. You cannot change this setting.';

                    trigger OnDrillDown()
                    begin
                        if Rec."Is FS Solution Installed" then
                            Message(FavorableCRMSolutionInstalledMsg, PRODUCTNAME.Short(), CRMProductName.FSServiceName())
                        else
                            Message(UnfavorableCRMSolutionInstalledMsg, PRODUCTNAME.Short());
                    end;
                }
                field("Job Journal Template"; Rec."Job Journal Template")
                {
                    ApplicationArea = Suite;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the project journal template in which project journal lines will be created and coupled to work order products and work order services.';
                    Editable = EditableProjectSettings;
                }
                field("Job Journal Batch"; Rec."Job Journal Batch")
                {
                    ApplicationArea = Suite;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the project journal batch in which project journal lines will be created and coupled to work order products and work order services.';
                    Editable = EditableProjectSettings;
                }
                field("Hour Unit of Measure"; Rec."Hour Unit of Measure")
                {
                    ApplicationArea = Suite;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the unit of measure that corresponds to the ''hour'' unit that is used on Dynamics 365 Field Service bookable resources.';
                }
                group(IntegrationTypeService)
                {
                    ShowCaption = false;

                    field("Integration Type"; Rec."Integration Type")
                    {
                        ApplicationArea = Service;
                        Editable = not Rec."Is Enabled";
                        ToolTip = 'Specifies the type of integration between Business Central and Dynamics 365 Field Service.';

                        trigger OnValidate()
                        begin
                            UpdateIntegrationTypeEditable();
                        end;
                    }
                }
            }
            group(SynchSettings)
            {
                Caption = 'Synchronization Settings';
                Visible = Rec."Is Enabled";
                field("Line Synch. Rule"; Rec."Line Synch. Rule")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies when to synchronize work order products and work order services.';
                    Editable = EditableProjectSettings;

                    trigger OnValidate()
                    var
                        IntegrationTableMapping: Record "Integration Table Mapping";
                        JobJouralLine: Record "Job Journal Line";
                        FSSetupDefaults: Codeunit "FS Setup Defaults";
                    begin
                        if not Rec."Is Enabled" then
                            exit;

                        if not Confirm(StrSubstNo(ResetOneIntegrationTableMappingConfirmQst, JobJouralLine.TableCaption())) then
                            Error('');

                        IntegrationTableMapping.SetRange(Type, IntegrationTableMapping.Type::Dataverse);
                        IntegrationTableMapping.SetRange("Delete After Synchronization", false);
                        IntegrationTableMapping.SetRange("Table ID", Database::"Job Journal Line");
                        IntegrationTableMapping.SetFilter("Integration Table ID", Format(Database::"FS Work Order Product") + '|' + Format(Database::"FS Work Order Service"));
                        if IntegrationTableMapping.FindSet() then
                            repeat
                                if IntegrationTableMapping."Integration Table ID" = Database::"FS Work Order Service" then
                                    FSSetupDefaults.ResetProjectJournalLineWOServiceMapping(Rec, IntegrationTableMapping.Name, true);
                                if IntegrationTableMapping."Integration Table ID" = Database::"FS Work Order Product" then
                                    FSSetupDefaults.ResetProjectJournalLineWOProductMapping(Rec, IntegrationTableMapping.Name, true);
                            until IntegrationTableMapping.Next() = 0;
                    end;
                }
                field("Line Post Rule"; Rec."Line Post Rule")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies when to post project journal lines that are coupled to work order products and work order services.';
                    Editable = EditableProjectSettings;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Assisted Setup")
            {
                ApplicationArea = Suite;
                Caption = 'Assisted Setup';
                Image = Setup;
                ToolTip = 'Runs Dynamics 365 Field Service Connection Setup Wizard.';

                trigger OnAction()
                var
                    GuidedExperience: Codeunit "Guided Experience";
                    CRMIntegrationMgt: Codeunit "CRM Integration Management";
                    GuidedExperienceType: Enum "Guided Experience Type";
                begin
                    CRMIntegrationMgt.RegisterAssistedSetup();
                    Commit(); // Make sure all data is committed before we run the wizard
                    GuidedExperience.Run(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"FS Connection Setup Wizard");
                    CurrPage.Update(false);
                end;
            }
            action("Test Connection")
            {
                ApplicationArea = Suite;
                Caption = 'Test Connection', Comment = 'Test is a verb.';
                Image = ValidateEmailLoggingSetup;
                ToolTip = 'Tests the connection to Dynamics 365 Field Service using the specified settings.';

                trigger OnAction()
                begin
                    Rec.PerformTestConnection();
                end;
            }
            action(IntegrationTableMappings)
            {
                ApplicationArea = Suite;
                Caption = 'Integration Table Mappings';
                Enabled = Rec."Is Enabled";
                Image = MapAccounts;
                ToolTip = 'Opens the integration table mapping list.';

                trigger OnAction()
                begin
                    Page.Run(Page::"Integration Table Mapping List");
                end;
            }
            action("Redeploy Solution")
            {
                ApplicationArea = Suite;
                Caption = 'Redeploy Integration Solution';
                Image = Setup;
                Enabled = IsCdsIntegrationEnabled and (not Rec."Is Enabled");
                ToolTip = 'Redeploy and reconfigure the Dynamics 365 Field Service integration solution.';

                trigger OnAction()
                begin
                    Commit();
                    Rec.DeployFSSolution(true);
                end;
            }
            action(ResetConfiguration)
            {
                ApplicationArea = Suite;
                Caption = 'Use Default Synchronization Setup';
                Enabled = Rec."Is Enabled";
                Image = ResetStatus;
                ToolTip = 'Resets the integration table mappings and synchronization jobs to the default values for a connection with Dynamics 365 Field Service. All current mappings are deleted.';

                trigger OnAction()
                var
                    FSSetupDefaults: Codeunit "FS Setup Defaults";
                begin
                    Rec.EnsureCDSConnectionIsEnabled();
                    Rec.EnsureCRMConnectionIsEnabled();
                    if Confirm(ResetIntegrationTableMappingConfirmQst, false, CRMProductName.FSServiceName()) then begin
                        FSSetupDefaults.ResetConfiguration(Rec);
                        Message(SetupSuccessfulMsg, CRMProductName.FSServiceName());
                    end;
                    Rec.RefreshDataFromFS();
                end;
            }
            action(StartInitialSynchAction)
            {
                ApplicationArea = Suite;
                Caption = 'Run Full Synchronization';
                Enabled = Rec."Is Enabled";
                Image = RefreshLines;
                ToolTip = 'Start all the default integration jobs for synchronizing Business Central record types and Dynamics 365 Field Service entities, as defined on the Integration Table Mappings page.';

                trigger OnAction()
                begin
                    Page.Run(Page::"CRM Full Synch. Review");
                end;
            }
        }
        area(navigation)
        {
            action("Synch. Job Queue Entries")
            {
                ApplicationArea = Suite;
                Caption = 'Synch. Job Queue Entries';
                Image = JobListSetup;
                ToolTip = 'View the job queue entries that manage the scheduled synchronization between Dynamics 365 Field Service and Business Central.';

                trigger OnAction()
                var
                    JobQueueEntry: Record "Job Queue Entry";
                begin
                    JobQueueEntry.FilterGroup := 2;
                    JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
                    JobQueueEntry.SetFilter("Object ID to Run", Rec.GetJobQueueEntriesObjectIDToRunFilter());
                    JobQueueEntry.FilterGroup := 0;

                    Page.Run(Page::"Job Queue Entries", JobQueueEntry);
                end;
            }
            action(SkippedSynchRecords)
            {
                ApplicationArea = Suite;
                Caption = 'Skipped Synch. Records';
                Enabled = Rec."Is Enabled";
                Image = NegativeLines;
                RunObject = Page "CRM Skipped Records";
                RunPageMode = View;
                ToolTip = 'View the list of records that will be skipped for synchronization.';
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Connection', Comment = 'Generated from the PromotedActionCategories property index 1.';

                actionref("Assisted Setup_Promoted"; "Assisted Setup")
                {
                }
                actionref("Test Connection_Promoted"; "Test Connection")
                {
                }
            }
            group(Category_Report)
            {
                Caption = 'Mapping', Comment = 'Generated from the PromotedActionCategories property index 2.';

                actionref(IntegrationTableMappings_Promoted; IntegrationTableMappings)
                {
                }
                actionref("Redeploy Solution_Promoted"; "Redeploy Solution")
                {
                }
            }
            group(Category_Category4)
            {
                Caption = 'Synchronization', Comment = 'Generated from the PromotedActionCategories property index 3.';

                actionref(StartInitialSynchAction_Promoted; StartInitialSynchAction)
                {
                }
                actionref("Synch. Job Queue Entries_Promoted"; "Synch. Job Queue Entries")
                {
                }
                actionref(SkippedSynchRecords_Promoted; SkippedSynchRecords)
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
        CRMIntegrationManagement: Codeunit "CRM Integration Management";
    begin
        ApplicationAreaMgmtFacade.CheckAppAreaOnlyBasic();
        CRMIntegrationManagement.RegisterAssistedSetup();
        SetVisibilityFlags();
    end;

    trigger OnOpenPage()
    var
        CRMIntegrationManagement: Codeunit "CRM Integration Management";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        CDSIntegrationImpl: Codeunit "CDS Integration Impl.";
        MultipleCompaniesDetected: Boolean;
    begin
        FeatureTelemetry.LogUptake('0000MBA', 'Dataverse', Enum::"Feature Uptake Status"::Discovered);
        FeatureTelemetry.LogUptake('0000MBB', 'Dynamics 365 Field Service', Enum::"Feature Uptake Status"::Discovered);
        Rec.EnsureCDSConnectionIsEnabled();
        Rec.EnsureCRMConnectionIsEnabled();

        if not Rec.Get() then begin
            Rec.Init();
            InitializeDefaultProxyVersion();
            Rec.Insert();
            Rec.LoadConnectionStringElementsFromCDSConnectionSetup();
        end else begin
            if not Rec."Is Enabled" then
                Rec.LoadConnectionStringElementsFromCDSConnectionSetup();
            ConnectionString := Rec.GetConnectionStringAsStoredInSetup();
            Rec.UnregisterConnection();
            if (not IsValidProxyVersion()) then begin
                if not IsValidProxyVersion() then
                    InitializeDefaultProxyVersion();
                Rec.Modify();
            end;
            if Rec."Is Enabled" then begin
                // just try notifying, because the setup may be broken, and we are in OnOpenPage
                if TryDetectMultipleCompanies(MultipleCompaniesDetected) then
                    if MultipleCompaniesDetected then
                        CDSIntegrationImpl.SendMultipleCompaniesNotification()

            end else
                if Rec."Disable Reason" <> '' then
                    CRMIntegrationManagement.SendConnectionDisabledNotification(Rec."Disable Reason");
        end;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if not Rec."Is Enabled" then
            if not Confirm(StrSubstNo(EnableServiceQst, CurrPage.Caption), true) then
                exit(false);
    end;

    [TryFunction]
    local procedure TryDetectMultipleCompanies(var MultipleCompaniesDetected: Boolean)
    var
        CDSIntegrationImpl: Codeunit "CDS Integration Impl.";
    begin
        Rec.RegisterConnection();
        if (Rec."Server Address" <> '') and (Rec."Server Address" <> TestServerAddressTok) then
            MultipleCompaniesDetected := CDSIntegrationImpl.MultipleCompaniesConnected();
    end;

    var
        CRMProductName: Codeunit "CRM Product Name";
        ResetIntegrationTableMappingConfirmQst: Label 'This will restore the default integration table mappings and synchronization jobs for %1. All custom mappings and jobs will be deleted. The default mappings and jobs will be used the next time data is synchronized. Do you want to continue?', Comment = '%1 = CRM product name';
        ResetOneIntegrationTableMappingConfirmQst: Label 'This will restore the default integration table mappings and synchronization jobs for %1. Do you want to continue?', Comment = '%1 = CRM product name';
        UnfavorableCRMSolutionInstalledMsg: Label 'The %1 Integration Solution was not detected.', Comment = '%1 - product name';
        FavorableCRMSolutionInstalledMsg: Label 'The %1 Integration Solution is installed in %2.', Comment = '%1 - product name, %2 = CRM product name';
        ReadyScheduledSynchJobsTok: Label '%1 of %2', Comment = '%1 = Count of scheduled job queue entries in ready or in process state, %2 count of all scheduled jobs';
        ScheduledSynchJobsRunning: Text;
        EnableServiceQst: Label 'The %1 is not enabled. Are you sure you want to exit?', Comment = '%1 = This Page Caption (Microsoft Dynamics 365 Connection Setup)';
        PartialScheduledJobsAreRunningMsg: Label 'An active job queue is available but only %1 of the %2 scheduled synchronization jobs are ready or in process.', Comment = '%1 = Count of scheduled job queue entries in ready or in process state, %2 count of all scheduled jobs';
        JobQueueIsNotRunningMsg: Label 'There is no job queue started. Scheduled synchronization jobs require an active job queue to process jobs.\\Contact your administrator to get a job queue configured and started.';
        AllScheduledJobsAreRunningMsg: Label 'An job queue is started and all scheduled synchronization jobs are ready or already processing.';
        SetupSuccessfulMsg: Label 'The default setup for %1 synchronization has completed successfully.', Comment = '%1 = CRM product name';
        CategoryTok: Label 'AL Dataverse Integration', Locked = true;
        CRMConnEnabledOnPageTxt: Label 'Field Service Connection has been enabled from FS Connection Setup Page', Locked = true;
        TestServerAddressTok: Label '@@test@@', Locked = true;
        ScheduledSynchJobsRunningStyleExpr: Text;
        CRMSolutionInstalledStyleExpr: Text;
        CRMVersionStyleExpr: Text;
        ConnectionString: Text;
        ActiveJobs: Integer;
        TotalJobs: Integer;
        IsEditable: Boolean;
        IsCdsIntegrationEnabled: Boolean;
        CRMVersionStatus: Boolean;
        EditableProjectSettings: Boolean;

    local procedure RefreshData()
    begin
        Rec.RefreshDataFromFS(false);
        RefreshSynchJobsData();
        UpdateEnableFlags();
        SetStyleExpr();
        UpdateIntegrationTypeEditable();
    end;

    local procedure RefreshSynchJobsData()
    begin
        Rec.CountCRMJobQueueEntries(ActiveJobs, TotalJobs);
        ScheduledSynchJobsRunning := StrSubstNo(ReadyScheduledSynchJobsTok, ActiveJobs, TotalJobs);
        ScheduledSynchJobsRunningStyleExpr := GetRunningJobsStyleExpr();
    end;

    local procedure SetStyleExpr()
    begin
        CRMSolutionInstalledStyleExpr := GetStyleExpr(Rec."Is FS Solution Installed");
        CRMVersionStyleExpr := GetStyleExpr(CRMVersionStatus);
    end;

    local procedure GetRunningJobsStyleExpr() StyleExpr: Text
    begin
        if ActiveJobs < TotalJobs then
            StyleExpr := 'Ambiguous'
        else
            StyleExpr := GetStyleExpr((ActiveJobs = TotalJobs) and (TotalJobs <> 0))
    end;

    local procedure GetStyleExpr(Favorable: Boolean) StyleExpr: Text
    begin
        if Favorable then
            StyleExpr := 'Favorable'
        else
            StyleExpr := 'Unfavorable'
    end;

    local procedure UpdateEnableFlags()
    var
        CDSIntegrationImpl: Codeunit "CDS Integration Impl.";
    begin
        IsEditable := not Rec."Is Enabled" and not CDSIntegrationImpl.IsIntegrationEnabled();
    end;

    local procedure SetVisibilityFlags()
    var
        CDSConnectionSetup: Record "CDS Connection Setup";
    begin
        if CDSConnectionSetup.Get() then
            IsCdsIntegrationEnabled := CDSConnectionSetup."Is Enabled";
    end;

    local procedure IsValidProxyVersion(): Boolean
    begin
        exit(Rec."Proxy Version" <> 0);
    end;

    local procedure InitializeDefaultProxyVersion()
    var
        CRMIntegrationManagement: Codeunit "CRM Integration Management";
    begin
        Rec.Validate("Proxy Version", CRMIntegrationManagement.GetLastProxyVersionItem());
    end;

    local procedure UpdateIntegrationTypeEditable()
    begin
        EditableProjectSettings := Rec."Integration Type" in [Rec."Integration Type"::Project, Rec."Integration Type"::Both];
    end;
}

