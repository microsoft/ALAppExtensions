// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Test.Integration.DynamicsFieldService;

using Microsoft.Integration.D365Sales;
using Microsoft.Integration.DynamicsFieldService;
using System.TestLibraries.Utilities;
using Microsoft.Projects.Project.Journal;
using Microsoft.Foundation.UOM;
using Microsoft.Integration.SyncEngine;
using System.Threading;
using Microsoft.Integration.Dataverse;
using Microsoft.Inventory.Setup;
using Microsoft.Finance.Currency;
using System.TestLibraries.Environment.Configuration;
using System.Security.Encryption;
using Microsoft.CRM.Contact;
using Microsoft.Sales.Customer;
using Microsoft.CRM.Team;
using Microsoft.Purchases.Vendor;
using System.Security.AccessControl;
using Microsoft.TestLibraries.DynamicsFieldService;

codeunit 139204 "FS Integration Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [FS Integration] [Connection Setup]
    end;

    var
        CRMProductName: Codeunit "CRM Product Name";
        CRMSetupTest: Codeunit "CRM Setup Test";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        FSIntegrationTestLibrary: Codeunit "FS Integration Test Library";
        Assert: Codeunit Assert;
        LibraryCRMIntegration: Codeunit "Library - CRM Integration";
        ConnectionErr: Label 'The connection setup cannot be validated. Verify the settings and try again.';
        ConnectionSuccessMsg: Label 'The connection test was successful';
        JobQueueEntryStatusReadyErr: Label 'Job Queue Entry status should be Ready.';
        JobQueueEntryStatusOnHoldErr: Label 'Job Queue Entry status should be On Hold.';
        SetupSuccessfulMsg: Label 'The default setup for %1 synchronization has completed successfully.', Comment = '%1 - Dynamics 365 Field Service';
        HourUnitOfMeasureMustBePickedErr: label 'Field Service uses a fixed unit of measure for bookable resources - hour. You must pick a corresponding resource unit of measure.';
        IsInitialized: Boolean;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure RegisterConnection()
    var
        FSConnectionSetup: Record "FS Connection Setup";
        ConnectionName: Code[10];
    begin
        Initialize();

        ConnectionName := 'No. 1';
        UnregisterTableConnection(TableConnectionType::CRM, ConnectionName);

        // Get a disabled and unregistered connection
        CreateFSConnectionSetup(ConnectionName, 'invalid.dns.int', false);
        AssertConnectionNotRegistered(ConnectionName);

        // Enable it without registering it
        FSConnectionSetup.Get(ConnectionName);
        FSConnectionSetup."Is Enabled" := true;
        FSConnectionSetup.Modify(false);

        AssertConnectionNotRegistered(ConnectionName);

        // Register
        FSIntegrationTestLibrary.RegisterConnection(FSConnectionSetup);
        // Second attempt of registration skips registration if it exists
        FSIntegrationTestLibrary.RegisterConnection(FSConnectionSetup);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure UnregisterConnection()
    var
        FSConnectionSetup: Record "FS Connection Setup";
        ConnectionName: Code[10];
    begin
        Initialize();

        ConnectionName := 'No. 1';
        UnregisterTableConnection(TableConnectionType::CRM, ConnectionName);

        // Get an enabled and registered connection
        CreateFSConnectionSetup(ConnectionName, 'invalid.dns.int', true);
        FSConnectionSetup.Get(ConnectionName);
        FSIntegrationTestLibrary.RegisterConnection(FSConnectionSetup);

        // Unregister and check
        FSIntegrationTestLibrary.UnregisterConnection(FSConnectionSetup);
        AssertConnectionNotRegistered(ConnectionName);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure JournalTemplateNameRequiredToEnable()
    var
        FSConnectionSetup: Record "FS Connection Setup";
        DummyPassword: Text;
    begin
        // [FEATURE] [UT]
        Initialize();

        DummyPassword := 'T3sting!';
        FSConnectionSetup.Init();
        FSConnectionSetup."User Name" := 'tester@domain.net';
        FSIntegrationTestLibrary.SetPassword(FSConnectionSetup, DummyPassword);
        FSConnectionSetup.Insert();

        asserterror FSConnectionSetup.Validate("Is Enabled", true);
        Assert.ExpectedError(FSConnectionSetup.FieldCaption("Job Journal Template"));
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure JournalBatchRequiredToEnable()
    var
        FSConnectionSetup: Record "FS Connection Setup";
        JobJournalTemplate: Record "Job Journal Template";
        LibraryJob: Codeunit "Library - Job";
        DummyPassword: Text;
    begin
        // [FEATURE] [UT]
        Initialize();
        LibraryJob.CreateJobJournalTemplate(JobJournalTemplate);
        JobJournalTemplate.Insert();
        DummyPassword := 'T3sting!';
        FSConnectionSetup.Init();
        FSConnectionSetup."Server Address" := '@@test@@';
        FSIntegrationTestLibrary.SetPassword(FSConnectionSetup, DummyPassword);
        FSConnectionSetup."Job Journal Template" := JobJournalTemplate.Name;
        FSConnectionSetup.Insert();

        asserterror FSConnectionSetup.Validate("Is Enabled", true);
        Assert.ExpectedError(FSConnectionSetup.FieldCaption("Job Journal Batch"));
        if JobJournalTemplate.Find() then
            JobJournalTemplate.Delete();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure HourUOMRequiredToEnable()
    var
        FSConnectionSetup: Record "FS Connection Setup";
        JobJournalTemplate: Record "Job Journal Template";
        JobJournalBatch: Record "Job Journal Batch";
        LibraryJob: Codeunit "Library - Job";
        DummyPassword: Text;
    begin
        // [FEATURE] [UT]
        Initialize();
        LibraryCRMIntegration.RegisterTestTableConnection();
        LibraryJob.CreateJobJournalTemplate(JobJournalTemplate);
        LibraryJob.CreateJobJournalBatch(JobJournalTemplate.Name, JobJournalBatch);
        DummyPassword := 'T3sting!';

        FSConnectionSetup.Init();
        FSConnectionSetup."Server Address" := '@@test@@';
        FSIntegrationTestLibrary.SetPassword(FSConnectionSetup, DummyPassword);
        FSConnectionSetup."Job Journal Template" := JobJournalTemplate.Name;
        FSConnectionSetup."Job Journal Batch" := JobJournalBatch.Name;
        FSConnectionSetup.Insert();

        asserterror FSConnectionSetup.Validate("Is Enabled", true);
        Assert.ExpectedError(HourUnitOfMeasureMustBePickedErr);
        if JobJournalBatch.Find() then
            JobJournalBatch.Delete();
        if JobJournalTemplate.Find() then
            JobJournalTemplate.Delete();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure WorkingConnectionRequiredToEnable()
    var
        FSConnectionSetup: Record "FS Connection Setup";
        JobJournalTemplate: Record "Job Journal Template";
        JobJournalBatch: Record "Job Journal Batch";
        UnitOfMeasure: Record "Unit of Measure";
        LibraryJob: Codeunit "Library - Job";
        LibraryInventory: Codeunit "Library - Inventory";
        DummyPassword: Text;
    begin
        // [FEATURE] [UT]
        Initialize();
        LibraryCRMIntegration.RegisterTestTableConnection();
        LibraryJob.CreateJobJournalTemplate(JobJournalTemplate);
        LibraryJob.CreateJobJournalBatch(JobJournalTemplate.Name, JobJournalBatch);
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);
        LibraryCRMIntegration.UnbindMockConnection();
        DummyPassword := 'T3sting!';

        // Enter details in the page and enable the connection
        FSConnectionSetup.Init();
        FSConnectionSetup."Server Address" := 'https://nocrmhere.gov';
        FSConnectionSetup.Validate("User Name", 'tester@domain.net');
        FSIntegrationTestLibrary.SetPassword(FSConnectionSetup, DummyPassword);
        FSConnectionSetup."Job Journal Template" := JobJournalTemplate.Name;
        FSConnectionSetup."Job Journal Batch" := JobJournalBatch.Name;
        FSConnectionSetup."Hour Unit of Measure" := UnitOfMeasure.Code;
        FSConnectionSetup.Insert();

        asserterror FSConnectionSetup.Validate("Is Enabled", true);
        Assert.ExpectedError(ConnectionErr);
    end;

    [Test]
    procedure EnableConnectionCanResetIntegrationTableMappingsIfEmpty()
    var
        FSConnectionSetup: Record "FS Connection Setup";
        JobJournalTemplate: Record "Job Journal Template";
        JobJournalBatch: Record "Job Journal Batch";
        UnitOfMeasure: Record "Unit of Measure";
        LibraryJob: Codeunit "Library - Job";
        LibraryInventory: Codeunit "Library - Inventory";
    begin
        // [FEATURE] [Table Mapping] [UI]
        Initialize();
        LibraryCRMIntegration.RegisterTestTableConnection();
        LibraryCRMIntegration.EnsureCRMSystemUser();
        LibraryCRMIntegration.CreateCRMOrganization();
        LibraryJob.CreateJobJournalTemplate(JobJournalTemplate);
        LibraryJob.CreateJobJournalBatch(JobJournalTemplate.Name, JobJournalBatch);
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);
        // [GIVEN] Table Mapping is empty
        Assert.TableIsEmpty(Database::"Integration Table Mapping");

        // [GIVEN] Connection is disabled
        FSConnectionSetup.DeleteAll();
        InitSetup(false, '');

        // [WHEN] Enable the connection
        FSConnectionSetup.Get();
        FSConnectionSetup."Job Journal Template" := JobJournalTemplate.Name;
        FSConnectionSetup."Job Journal Batch" := JobJournalBatch.Name;
        FSConnectionSetup."Hour Unit of Measure" := UnitOfMeasure.Code;
        FSConnectionSetup.Validate("Is Enabled", true);

        // [THEN] Table Mapping is filled
        Assert.TableIsNotEmpty(Database::"Integration Table Mapping");
    end;

    [Test]
    [HandlerFunctions('MessageOk')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure CanTestConnectionWhenNotIsEnabled()
    var
        FSConnectionSetup: Record "FS Connection Setup";
        DummyPassword: Text;
    begin
        Initialize();
        LibraryCRMIntegration.RegisterTestTableConnection();
        LibraryCRMIntegration.EnsureCRMSystemUser();
        FSConnectionSetup.DeleteAll();
        FSConnectionSetup.Init();
        FSConnectionSetup."Server Address" := '@@test@@';
        FSConnectionSetup.Validate("User Name", 'tester@domain.net');
        DummyPassword := 'value';
        FSIntegrationTestLibrary.SetPassword(FSConnectionSetup, DummyPassword);
        FSConnectionSetup.Insert();

        FSIntegrationTestLibrary.PerformTestConnection(FSConnectionSetup);
    end;

    [Test]
    [HandlerFunctions('ConfirmYes,MessageOk')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure InvokeResetConfigurationCreatesNewMappings()
    var
        JobQueueEntry: Record "Job Queue Entry";
        IntegrationTableMapping: Record "Integration Table Mapping";
        FSConnectionSetup: TestPage "FS Connection Setup";
    begin
        // [FEATURE] [Table Mapping] [UI]
        Initialize();

        // [GIVEN] Connection to CRM established
        LibraryCRMIntegration.DisableTaskOnBeforeJobQueueScheduleTask();
        LibraryCRMIntegration.ConfigureCRM();

        // [GIVEN] No Integration Table Mapping records
        // [GIVEN] No Job Queue Entry records
        IntegrationTableMapping.DeleteAll(true);
        JobQueueEntry.DeleteAll();

        CreateFSConnectionSetup('', '@@test@@', true);

        // [GIVEN] FS Connection Setup page
        FSConnectionSetup.OpenEdit();

        // [WHEN] "Use Default Synchronization Setup" action is invoked
        FSConnectionSetup.ResetConfiguration.Invoke();

        // [THEN] Integration Table Mapping and Job Queue Entry tables are not empty
        Assert.AreNotEqual(0, IntegrationTableMapping.Count(), 'Expected the reset mappings to create new mappings');
        Assert.AreNotEqual(0, JobQueueEntry.Count(), 'Expected the reset mappings to create new job queue entries');

        // [THEN] Message "The default setup for Dynamics 365 Sales synchronization has completed successfully." appears
        Assert.ExpectedMessage(StrSubstNo(SetupSuccessfulMsg, CRMProductName.FSServiceName()), LibraryVariableStorage.DequeueText());
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure EnableLocationMandatoryCreatesLocationMappingForEnabledFieldServiceSetup()
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
    begin
        // [FEATURE] [Table Mapping] [UI]
        Initialize();

        // [GIVEN] Connection to CRM established
        LibraryCRMIntegration.DisableTaskOnBeforeJobQueueScheduleTask();
        LibraryCRMIntegration.ConfigureCRM();

        // [GIVEN] No Integration Table Mapping records
        IntegrationTableMapping.DeleteAll(true);

        // [GIVEN] Enable FS Connection Setup
        CreateFSConnectionSetup('', '@@test@@', true);

        // [WHEN] Enable Location Mandatory
        EnableLocationMandatoryOnInventorySetup();

        // [THEN] Integration Table Mapping for Location is created        
        Assert.AreEqual(1, IntegrationTableMapping.Count(), 'Expects Location mappings to be created.');
    end;

    local procedure CreateFSConnectionSetup(PrimaryKey: Code[10]; HostName: Text; IsEnabledVar: Boolean)
    var
        FSConnectionSetup: Record "FS Connection Setup";
    begin
        if FSConnectionSetup.Get(PrimaryKey) then
            FSConnectionSetup.Delete();
        FSConnectionSetup.Init();
        FSConnectionSetup."Primary Key" := PrimaryKey;
        FSConnectionSetup."Server Address" := CopyStr(HostName, 1, MaxStrLen(FSConnectionSetup."Server Address"));
        FSConnectionSetup."Is Enabled" := IsEnabledVar;
        FSConnectionSetup."Authentication Type" := FSConnectionSetup."Authentication Type"::Office365;
        FSConnectionSetup.Validate("User Name", 'UserName@asEmail.net');
        // Empty username triggers username/password dialog
        FSConnectionSetup.Insert(true);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure ActionSyncJobs()
    var
        FSConnectionSetup: TestPage "FS Connection Setup";
        JobQueueEntries: TestPage "Job Queue Entries";
    begin
        // [FEATURE] [UI]
        // [SCENARIO] Action "Synch. Job Queue Entries" opens page with CRM synch. jobs.
        Initialize();
        // [GIVEN] FS Connection Setup, where "Is Enabled" = Yes
        InitSetup(true, '');
        // [GIVEN] 4 Job Queue Entries: 3 are for CRM Integration, 3 of them active
        InsertJobQueueEntries();
        // [WHEN] Run action "Synch. Job Queue Entries" on FS Connection Setup page
        FSConnectionSetup.OpenView();
        JobQueueEntries.Trap();
        FSConnectionSetup."Synch. Job Queue Entries".Invoke();
        // [THEN] Page "Job Queue Entries" is open, where are 3 jobs
        Assert.IsTrue(JobQueueEntries.First(), 'First');
        Assert.IsTrue(JobQueueEntries.Next(), 'Second');
        Assert.IsTrue(JobQueueEntries.Next(), 'Third');
        Assert.IsFalse(JobQueueEntries.Next(), 'Fourth should fail');
    end;

    [Test]
    [HandlerFunctions('MessageDequeue')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure AllJobsActive()
    var
        FSConnectionSetupPage: TestPage "FS Connection Setup";
    begin
        // [FEATURE] [UI]
        // [SCENARIO] FS Connection Setup page shows '3 of 3' when all jobs are active
        Initialize();
        // [GIVEN] FS Connection Setup, where "Is Enabled" = Yes
        InitSetup(true, '');
        // [GIVEN] 4 Job Queue Entries: 3 are for CRM Integration, 3 of them active
        InsertJobQueueEntries();

        // [WHEN] Open FS Connection Setup page
        FSConnectionSetupPage.OpenView();

        // [THEN] Control "Active scheduled synchronization jobs" is '3 of 3'
        FSConnectionSetupPage.ScheduledSynchJobsActive.AssertEquals('3 of 3');

        // [WHEN] DrillDown on '3 of 3'
        LibraryVariableStorage.Enqueue('all scheduled synchronization jobs are ready or already processing.');
        FSConnectionSetupPage.ScheduledSynchJobsActive.DrillDown();
        // [THEN] Message : "all scheduled synchronization jobs are ready or already processing."
        // handled by MessageDequeue
    end;

    [Test]
    [HandlerFunctions('MessageDequeue')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestConnectionAction()
    var
        FSConnectionSetup: Record "FS Connection Setup";
        FSConnectionSetupPage: TestPage "FS Connection Setup";
    begin
        // [FEATURE] [UI]
        Initialize();
        LibraryCRMIntegration.RegisterTestTableConnection();
        LibraryCRMIntegration.EnsureCRMSystemUser();

        FSConnectionSetup.DeleteAll();
        InitSetup(true, '');
        // [GIVEN] Open FS Connection Setup page
        FSConnectionSetupPage.OpenEdit();
        // [WHEN] Run "Test Connection" action
        LibraryVariableStorage.Enqueue(ConnectionSuccessMsg);
        FSConnectionSetupPage."Test Connection".Invoke();
        // [THEN] Message: "The connection test was successful"
        // handled by MessageDequeue
    end;

    [Test]
    procedure StartInitialSynchAction()
    var
        FSConnectionSetupPage: TestPage "FS Connection Setup";
        CRMFullSynchReviewPage: TestPage "CRM Full Synch. Review";
    begin
        // [FEATURE] [UI]
        Initialize();
        LibraryCRMIntegration.ConfigureCRM();
        CreateTableMapping();
        LibraryCRMIntegration.DisableTaskOnBeforeJobQueueScheduleTask();
        InitSetup(true, '');
        // [GIVEN] Open FS Connection Setup page
        FSConnectionSetupPage.OpenEdit();
        // [WHEN] run action StartInitialSynch
        CRMFullSynchReviewPage.Trap();
        FSConnectionSetupPage.StartInitialSynchAction.Invoke();
        // [THEN] CRMFullSynchReview page is open
        CRMFullSynchReviewPage.Close();
    end;

    [Test]
    procedure EnableJobQueueEntriesOnEnableFSConnection()
    var
        FSConnectionSetup: Record "FS Connection Setup";
        JobJournalTemplate: Record "Job Journal Template";
        JobJournalBatch: Record "Job Journal Batch";
        UnitOfMeasure: Record "Unit of Measure";
        LibraryJob: Codeunit "Library - Job";
        LibraryInventory: Codeunit "Library - Inventory";
    begin
        // [SCENARIO] Enabling CRM Connection move all CRM Job Queue Entries in "Ready" status
        Initialize();
        LibraryCRMIntegration.DisableTaskOnBeforeJobQueueScheduleTask();
        LibraryJob.CreateJobJournalTemplate(JobJournalTemplate);
        LibraryJob.CreateJobJournalBatch(JobJournalTemplate.Name, JobJournalBatch);
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);

        // [GIVEN] Connection Setup with Integration Table Mapping and Job Queue Entries
        CreateFSConnectionSetup();
        FSConnectionSetup.DeleteAll();
        InitSetup(false, '');

        // [WHEN] Enable the connection
        FSConnectionSetup.Get();
        FSConnectionSetup."Job Journal Template" := JobJournalTemplate.Name;
        FSConnectionSetup."Job Journal Batch" := JobJournalBatch.Name;
        FSConnectionSetup."Hour Unit of Measure" := UnitOfMeasure.Code;
        FSConnectionSetup.Validate("Is Enabled", true);
        FSConnectionSetup.Modify(true);

        // [THEN] All Job Queue Entries has Status = Ready
        VerifyJobQueueEntriesStatusIsReady();
        FSConnectionSetup.Validate("Is Enabled", false);
        FSConnectionSetup.Modify(true);
        FSConnectionSetup.Delete();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure DisableJobQueueEntriesOnDisableFSConnection()
    var
        FSConnectionSetup: Record "FS Connection Setup";
    begin
        // [SCENARIO] Disabling CRM Connection move all CRM Job Queue Entries in "On Hold" status
        Initialize();

        // [GIVEN] FS Connection Setup with Integration Table Mapping and CRM Job Queue Entries
        CreateFSConnectionSetup();
        FSConnectionSetup.DeleteAll();
        InitSetup(true, '');

        // [WHEN] Disable the connection
        FSConnectionSetup.Get();
        FSConnectionSetup.Validate("Is Enabled", false);
        FSConnectionSetup.Modify(true);

        // [THEN] All CRM Job Queue Entries has Status = On Hold
        VerifyJobQueueEntriesStatusIsOnHold();
    end;

    [Test]
    [HandlerFunctions('FSAssistedSetupModalHandler,ConfirmYes')]
    procedure RunAssistedSetupFromFSConnectionSetup()
    var
        CRMConnectionSetup: Record "CRM Connection Setup";
        FSConnectionSetupPage: TestPage "FS Connection Setup";
    begin
        // [SCENARIO 266927] FS Connection Assisted Setup can be opened from FS Connection Setup page
        Initialize();
        CRMConnectionSetup.Init();
        CRMConnectionSetup."Unit Group Mapping Enabled" := true;
        CRMConnectionSetup.Insert();

        InitSetup(true, '');
        // [GIVEN] FS Connection Setup page is opened, Server Address "SA"
        FSConnectionSetupPage.OpenEdit();
        FSConnectionSetupPage."Server Address".SetValue('TEST');

        // [WHEN] Assisted Setup is invoked
        FSConnectionSetupPage."Assisted Setup".Invoke();

        // [THEN] FS Connection Setup wizard is opened and Server Address = "SA"
        // Wizard page is opened in FSAssistedSetupModalHandler
        Assert.ExpectedMessage(FSConnectionSetupPage."Server Address".Value, LibraryVariableStorage.DequeueText());
        if CRMConnectionSetup.Get() then
            CRMConnectionSetup.Delete();
    end;

    local procedure Initialize()
    var
        AssistedSetupTestLibrary: Codeunit "Assisted Setup Test Library";
        CryptographyManagement: Codeunit "Cryptography Management";
    begin
        ResetFSEnvironment();
        LibraryCRMIntegration.ResetEnvironment();
        LibraryVariableStorage.Clear();
        if CryptographyManagement.IsEncryptionEnabled() then
            CryptographyManagement.DisableEncryption(true);
        Assert.IsFalse(EncryptionEnabled(), 'Encryption should be disabled');

        Clear(CRMSetupTest);
        UnregisterTableConnection(TableConnectionType::CRM, '');
        UnregisterTableConnection(TableConnectionType::CRM, GetDefaultTableConnection(TableConnectionType::CRM));
        Assert.AreEqual(
          '', GetDefaultTableConnection(TableConnectionType::CRM),
          'DEFAULTTABLECONNECTION should not be registered');

        AssistedSetupTestLibrary.DeleteAll();
        AssistedSetupTestLibrary.CallOnRegister();
        InitializeCDSConnectionSetup();

        if IsInitialized then
            exit;

        IsInitialized := true;
        SetTenantLicenseStateToTrial();
    end;

    procedure ResetFSEnvironment()
    var
        FSConnectionSetup: Record "FS Connection Setup";
    begin
        FSConnectionSetup.DeleteAll();
    end;

    local procedure InitializeCDSConnectionSetup()
    var
        CDSConnectionSetup: Record "CDS Connection Setup";
        ClearClientSecret: Text;
        ClientSecret: SecretText;
    begin
        CDSConnectionSetup.DeleteAll();
        CDSConnectionSetup."Is Enabled" := true;
        CDSConnectionSetup."Server Address" := '@@test@@';
        CDSConnectionSetup."User Name" := 'user@test.net';
        CDSConnectionSetup."Authentication Type" := CDSConnectionSetup."Authentication Type"::Office365;
        CDSConnectionSetup."Proxy Version" := LibraryCRMIntegration.GetLastestSDKVersion();
        CDSConnectionSetup.Validate("Client Id", 'ClientId');
        CDSConnectionSetup.Validate("Redirect URL", 'RedirectURL');
        ClearClientSecret := 'ClientSecret';
        ClientSecret := ClearClientSecret;
        CDSConnectionSetup.SetClientSecret(ClientSecret);
    end;

    local procedure AssertConnectionNotRegistered(ConnectionName: Code[10])
    var
        FSConnectionSetup: Record "FS Connection Setup";
    begin
        FSConnectionSetup.Get(ConnectionName);
        FSIntegrationTestLibrary.RegisterConnection(FSConnectionSetup);
        FSIntegrationTestLibrary.UnregisterConnection(FSConnectionSetup);
    end;

    local procedure CreateTableMapping()
    var
        CRMTransactioncurrency: Record "CRM Transactioncurrency";
        IntegrationTableMapping: Record "Integration Table Mapping";
    begin
        IntegrationTableMapping.Init();
        IntegrationTableMapping."Table ID" := Database::Currency;
        IntegrationTableMapping."Integration Table ID" := Database::"CRM Transactioncurrency";
        IntegrationTableMapping.Validate("Integration Table UID Fld. No.", CRMTransactioncurrency.FieldNo(TransactionCurrencyId));
        IntegrationTableMapping."Synch. Codeunit ID" := Codeunit::"CRM Integration Table Synch.";

        IntegrationTableMapping.Name := 'FIRST';
        IntegrationTableMapping.Direction := IntegrationTableMapping.Direction::FromIntegrationTable;
        IntegrationTableMapping.Insert();

        IntegrationTableMapping.Name := 'SECOND';
        IntegrationTableMapping.Direction := IntegrationTableMapping.Direction::Bidirectional;
        IntegrationTableMapping.Insert();
    end;

    local procedure CreateIntTableMappingWithJobQueueEntries()
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        JobQueueEntry: Record "Job Queue Entry";
    begin
        IntegrationTableMapping.DeleteAll();
        CreateTableMapping();
        JobQueueEntry.DeleteAll();
        InsertJobQueueEntries();
        InsertJobQueueEntriesWithError();
        IntegrationTableMapping.FindFirst();
        JobQueueEntry.ModifyAll("Record ID to Process", IntegrationTableMapping.RecordId);
    end;

    local procedure CreateFSConnectionSetup()
    begin
        LibraryCRMIntegration.RegisterTestTableConnection();
        LibraryCRMIntegration.EnsureCRMSystemUser();
        LibraryCRMIntegration.CreateCRMOrganization();
        CreateIntTableMappingWithJobQueueEntries();
    end;

    local procedure InitSetup(Enable: Boolean; Version: Text[30])
    var
        FSConnectionSetup: Record "FS Connection Setup";
        JobJournalTemplate: Record "Job Journal Template";
        JobJournalBatch: Record "Job Journal Batch";
        UnitOfMeasure: Record "Unit of Measure";
        LibraryJob: Codeunit "Library - Job";
        LibraryInventory: Codeunit "Library - Inventory";
        DummyPassword: Text;
    begin
        FSConnectionSetup.Init();
        FSConnectionSetup."Is Enabled" := Enable;
        FSConnectionSetup."Is FS Solution Installed" := Enable;
        FSConnectionSetup."Server Address" := '@@test@@';
        FSConnectionSetup.Validate("User Name", 'tester@domain.net');
        DummyPassword := 'Password';
        FSIntegrationTestLibrary.SetPassword(FSConnectionSetup, DummyPassword);
        FSConnectionSetup."FS Version" := Version;
        if Enable then begin
            LibraryJob.CreateJobJournalTemplate(JobJournalTemplate);
            LibraryJob.CreateJobJournalBatch(JobJournalTemplate.Name, JobJournalBatch);
            LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);
            FSConnectionSetup."Job Journal Template" := JobJournalTemplate.Name;
            FSConnectionSetup."Job Journal Batch" := JobJournalBatch.Name;
            FSConnectionSetup."Hour Unit of Measure" := UnitOfMeasure.Code;
        end;
        FSConnectionSetup.Insert();

        if FSConnectionSetup."Is Enabled" then
            FSIntegrationTestLibrary.RegisterConnection(FSConnectionSetup);
    end;

    local procedure InsertJobQueueEntries()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.DeleteAll();
        InsertJobQueueEntry(Codeunit::"Integration Synch. Job Runner", JobQueueEntry.Status::Ready);
        InsertJobQueueEntry(Codeunit::"Integration Synch. Job Runner", JobQueueEntry.Status::"In Process");
        InsertJobQueueEntry(Codeunit::"CRM Statistics Job", JobQueueEntry.Status::Ready);
    end;

    local procedure InsertJobQueueEntriesWithError()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        InsertJobQueueEntry(Codeunit::"CRM Statistics Job", JobQueueEntry.Status::Error);
    end;

    local procedure InsertJobQueueEntry(ID: Integer; Status: Option)
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.Init();
        JobQueueEntry.ID := CreateGuid();
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := ID;
        JobQueueEntry.Status := Status;
        JobQueueEntry.Insert();
    end;

    local procedure VerifyJobQueueEntriesStatusIsReady()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"Integration Synch. Job Runner");
        JobQueueEntry.FindSet();
        repeat
            if JobQueueEntry.Description.Contains(CRMProductName.FSServiceName()) then
                Assert.IsTrue(JobQueueEntry.Status = JobQueueEntry.Status::Ready, JobQueueEntryStatusReadyErr);
        until JobQueueEntry.Next() = 0;
    end;

    local procedure VerifyJobQueueEntriesStatusIsOnHold()
    var
        JobQueueEntry: Record "Job Queue Entry";
        IntegrationTableMapping: Record "Integration Table Mapping";
        CheckSetOnHold: Boolean;
    begin
        JobQueueEntry.FindSet();
        repeat
            CheckSetOnHold := true;
            if IntegrationTableMapping.Get(JobQueueEntry."Record ID to Process") then
                if IntegrationTableMapping."Table ID" in [Database::Contact, Database::Customer, Database::"Salesperson/Purchaser", Database::Vendor, Database::Currency] then
                    CheckSetOnHold := false;
            if CheckSetOnHold then
                Assert.IsTrue(JobQueueEntry.Status = JobQueueEntry.Status::"On Hold", JobQueueEntryStatusOnHoldErr);
        until JobQueueEntry.Next() = 0;
    end;

    [ConfirmHandler]
    procedure ConfirmNo(Question: Text; var Reply: Boolean)
    begin
        Reply := false;
    end;

    [ConfirmHandler]
    procedure ConfirmYes(Question: Text; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [MessageHandler]
    procedure MessageOk(Message: Text)
    begin
        LibraryVariableStorage.Enqueue(Message);
    end;

    [MessageHandler]
    procedure MessageDequeue(Message: Text)
    begin
        Assert.ExpectedMessage(LibraryVariableStorage.DequeueText(), Message);
    end;

    [ModalPageHandler]
    procedure CRMOptionMappingModalHandler(var CRMOptionMappingPage: TestPage "CRM Option Mapping")
    begin
        Assert.IsFalse(CRMOptionMappingPage.Editable, 'The page should be NOT editable');
        CRMOptionMappingPage.First();
        CRMOptionMappingPage.Record.AssertEquals(LibraryVariableStorage.DequeueText());
        CRMOptionMappingPage."Option Value".AssertEquals(LibraryVariableStorage.DequeueInteger());
        CRMOptionMappingPage."Option Value Caption".AssertEquals(LibraryVariableStorage.DequeueText());
    end;

    [PageHandler]
    procedure CRMSystemUserListHandler(var CRMSystemuserList: TestPage "CRM Systemuser List")
    begin
        LibraryVariableStorage.Enqueue(CRMSystemuserList.SalespersonPurchaserCode.Editable());
        LibraryVariableStorage.Enqueue(CRMSystemuserList.Couple.Visible());
    end;

    [ModalPageHandler]
    procedure SDKVersionListModalHandler(var SDKVersionList: TestPage "SDK Version List")
    begin
        SDKVersionList.GotoKey(LibraryVariableStorage.DequeueInteger());
        SDKVersionList.OK().Invoke();
    end;

    [SendNotificationHandler]
    procedure ConnectionBrokenNotificationHandler(var ConnectionBrokenNotification: Notification): Boolean
    begin
        LibraryVariableStorage.Enqueue(ConnectionBrokenNotification.Message);
    end;

    [ModalPageHandler]
    procedure FSAssistedSetupModalHandler(var FSConnectionSetupWizard: TestPage "FS Connection Setup Wizard")
    begin
        LibraryVariableStorage.Enqueue(FSConnectionSetupWizard.ServerAddress.Value);
    end;

    local procedure SetTenantLicenseStateToTrial()
    var
        TenantLicenseState: Record "Tenant License State";
    begin
        TenantLicenseState."Start Date" := CurrentDateTime;
        TenantLicenseState.State := TenantLicenseState.State::Trial;
        TenantLicenseState.Insert();
    end;

    local procedure EnableLocationMandatoryOnInventorySetup()
    var
        InventorySetup: Record "Inventory Setup";
    begin
        InventorySetup.Get();
        InventorySetup.Validate("Location Mandatory", true);
        InventorySetup.Modify(true);
    end;
}

