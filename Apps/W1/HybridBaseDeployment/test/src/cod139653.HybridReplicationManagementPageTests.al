codeunit 139653 "Replication Mgt Page Tests"
{
    // [FEATURE] [Intelligent Edge Hybrid Management Page]
    Subtype = Test;
    TestPermissions = Disabled;

    local procedure Initialize(IsSaas: Boolean)
    var
        HybridDeploymentSetup: Record "Hybrid Deployment Setup";
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
        GuidedExperience: Codeunit "Guided Experience";
        AssistedSetupTestLibrary: Codeunit "Assisted Setup Test Library";
        PermissionManager: Codeunit "Permission Manager";
        EnvironmentInfoTestLibrary: Codeunit "Environment Info Test Library";
    begin
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(IsSaas);
        PermissionManager.SetTestabilityIntelligentCloud(true);
        AssistedSetupTestLibrary.DeleteAll();
        AssistedSetupTestLibrary.CallOnRegister();
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"Hybrid Cloud Setup Wizard");

        IntelligentCloudSetup.DeleteAll();
        IntelligentCloudSetup.Init();
        IntelligentCloudSetup."Product ID" := 'Dynamics BC';
        IntelligentCloudSetup."Company Creation Task Status" := IntelligentCloudSetup."Company Creation Task Status"::Completed;
        IntelligentCloudSetup."Deployed Version" := 'V1.0';
        IntelligentCloudSetup."Latest Version" := 'V2.0';
        IntelligentCloudSetup.Insert();

        if not Initialized then begin
            HybridDeploymentSetup.DeleteAll();
            HybridDeploymentSetup."Handler Codeunit ID" := Codeunit::"Library - Hybrid Management";
            HybridDeploymentSetup.Insert();
            BindSubscription(LibraryHybridManagement);
            HybridDeploymentSetup.Get();
        end else
            exit;

        Initialized := true;
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler,GeneralMessageHandler')]
    procedure TestRunReplicationNow()
    var
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        IntelligentCloudManagement: TestPage "Intelligent Cloud Management";
    begin
        // [SCENARIO] User Opens up the Hybrid Replication Management Page and clicks 'Run Replication Now' button on the ribbon.

        // Remove Inprogress and Failed run records for past 24 hrs
        HybridReplicationSummary.SetFilter("Start Time", '>%1', (CurrentDateTime() - 86400000));
        if not HybridReplicationSummary.IsEmpty() then begin
            HybridReplicationSummary.SetRange("Trigger Type", HybridReplicationSummary."Trigger Type"::Manual);
            HybridReplicationSummary.SetFilter(Status, '<>%1', HybridReplicationSummary.Status::Failed);
            HybridReplicationSummary.DeleteAll();
        end;

        // [GIVEN] User Opens up the Hybrid Replication Management Page.
        Initialize(true);
        IntelligentCloudManagement.Trap();
        Page.Run(Page::"Intelligent Cloud Management");

        with IntelligentCloudManagement do
            // [WHEN] User clicks 'Run Replication Now' action in the ribbon.
            RunReplicationNow.Invoke();
    end;

    [Test]
    [HandlerFunctions('GetRuntimeKeyMessageHandler')]
    procedure TestGetRuntimeKey()
    var
        IntelligentCloudManagement: TestPage "Intelligent Cloud Management";
    begin
        // [SCENARIO] User Opens up the Hybrid Replication Management Page and clicks 'Get Service Key' button on the ribbon.

        // [GIVEN] User Opens up the Hybrid Replication Management Page.
        Initialize(true);
        IntelligentCloudManagement.Trap();
        Page.Run(Page::"Intelligent Cloud Management");

        with IntelligentCloudManagement do
            // [WHEN] User clicks 'Get Service Key' action in the ribbon.
            GetRuntimeKey.Invoke();
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler,GenerateNewKeyMessageHandler')]
    procedure TestGenerateNewKey()
    var
        IntelligentCloudManagement: TestPage "Intelligent Cloud Management";
    begin
        // [SCENARIO] User Opens up the Hybrid Replication Management Page and clicks 'Get Service Key' button on the ribbon.

        // [GIVEN] User Opens up the Hybrid Replication Management Page.
        Initialize(true);
        IntelligentCloudManagement.Trap();
        Page.Run(Page::"Intelligent Cloud Management");

        with IntelligentCloudManagement do
            // [WHEN] User clicks 'Get Service Key' action in the ribbon.
            GenerateNewKey.Invoke();
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler,GeneralMessageHandler')]
    procedure TestRunReplication()
    var
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        IntelligentCloudManagement: TestPage "Intelligent Cloud Management";
        ExpectedRunId: Text;
        ExpectedSource: Text;
    begin
        // [SCENARIO] User Opens up the Hybrid Replication Management Page and clicks 'Get Service Key' button on the ribbon.

        // [GIVEN] User Opens up the Hybrid Replication Management Page.
        Initialize(true);
        IntelligentCloudManagement.Trap();
        Page.Run(Page::"Intelligent Cloud Management");

        // [GIVEN] Intelligent Cloud is set up
        SetupIntelligentCloud(ExpectedRunId, ExpectedSource);

        // [WHEN] User clicks 'Replicate Now' action in the ribbon.
        HybridReplicationSummary.DeleteAll();
        IntelligentCloudManagement.RunReplicationNow.Invoke();

        // [THEN] A Replication Summary record is created that has InProgress status
        with HybridReplicationSummary do begin
            FindFirst();
            Assert.AreEqual(ExpectedRunId, "Run ID", 'Run ID');
            Assert.AreEqual(Status::InProgress, Status, 'Status');
            Assert.AreEqual(ExpectedSource, Source, 'Source');
            Assert.AreEqual("Trigger Type"::Manual, "Trigger Type", 'Trigger Type');
            Assert.AreEqual(ReplicationType::Full, ReplicationType, 'Replication Type');

            // [THEN] The correct replication type is passed to the service
            Assert.AreEqual(ReplicationType::Normal, LibraryHybridManagement.GetActualReplicationType(), 'Replication run type');
        end;
    end;

    [Test]
    procedure TestCreateDiagnosticRun()
    var
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        IntelligentCloudManagement: TestPage "Intelligent Cloud Management";
        ExpectedRunId: Text;
        ExpectedSource: Text;
    begin
        // [SCENARIO] User can create a diagnostic/schema-only replication run

        // [GIVEN] The intelligent cloud is set up
        Initialize(true);
        HybridReplicationSummary.DeleteAll();
        SetupIntelligentCloud(ExpectedRunId, ExpectedSource);
        LibraryHybridManagement.SetDiagnosticRunsEnabled(true);

        // [WHEN] User Opens up the Hybrid Replication Management Page.
        IntelligentCloudManagement.Trap();
        Page.Run(Page::"Intelligent Cloud Management");

        // [WHEN] User chooses to create a diagnostic run
        IntelligentCloudManagement.RunDiagnostic.Invoke();

        // [THEN] A Replication Summary record is created that has InProgress status and Diagnostic Replication Type
        with HybridReplicationSummary do begin
            FindFirst();
            Assert.AreEqual(ExpectedRunId, "Run ID", 'Run ID');
            Assert.AreEqual(Status::InProgress, Status, 'Status');
            Assert.AreEqual(ExpectedSource, Source, 'Source');
            Assert.AreEqual("Trigger Type"::Manual, "Trigger Type", 'Trigger Type');
            Assert.AreEqual(ReplicationType::Diagnostic, ReplicationType, 'Replication Type');

            // [THEN] The correct replication type is passed to the service
            Assert.AreEqual(ReplicationType::Diagnostic, LibraryHybridManagement.GetActualReplicationType(), 'Replication run type');
        end;
    end;

    [Test]
    procedure CreateDiagnosticRunIsNotVisibleIfUnsupported()
    var
        IntelligentCloudManagement: TestPage "Intelligent Cloud Management";
        ExpectedRunId: Text;
        ExpectedSource: Text;
    begin
        // [SCENARIO] User doesn't have ability to create diagnostic runs for unsupported products

        // [GIVEN] The intelligent cloud is set up for a product that doesn't support diagnostic runs
        Initialize(true);
        SetupIntelligentCloud(ExpectedRunId, ExpectedSource);
        LibraryHybridManagement.SetDiagnosticRunsEnabled(false);

        // [WHEN] User Opens up the Hybrid Replication Management Page.
        IntelligentCloudManagement.Trap();
        Page.Run(Page::"Intelligent Cloud Management");

        // [THEN] The diagnostic run button is not visible
        Assert.IsFalse(IntelligentCloudManagement.RunDiagnostic.Visible(), 'Diagnostic run button should not be visible.');
    end;

    [Test]
    procedure TestOpenManageCustomTables()
    var
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        IntelligentCloudManagement: TestPage "Intelligent Cloud Management";
        MigrationTableMapping: TestPage "Migration Table Mapping";
        ExpectedRunId: Text;
        ExpectedSource: Text;
    begin
        // [SCENARIO] User can manage custom table mappings to use in the migration

        // [GIVEN] The intelligent cloud is set up
        Initialize(true);
        HybridReplicationSummary.DeleteAll();
        SetupIntelligentCloud(ExpectedRunId, ExpectedSource);
        LibraryHybridManagement.SetTableMappingEnabled(true);

        // [WHEN] User Opens up the Hybrid Replication Management Page.
        IntelligentCloudManagement.Trap();
        Page.Run(Page::"Intelligent Cloud Management");

        // [WHEN] User chooses to manage custom tables
        MigrationTableMapping.Trap();
        IntelligentCloudManagement.ManageCustomTables.Invoke();

        // [THEN] The migration table mapping page is opened in edit mode
        Assert.IsTrue(MigrationTableMapping.Editable, 'Page should be editable');
    end;

    [Test]
    procedure ManageCustomTablesFailsForInvalidApp()
    var
        MigrationTableMappingRec: Record "Migration Table Mapping";
        MigrationTableMapping: TestPage "Migration Table Mapping";
    begin
        // [SCENARIO] User is not allowed to specify tables from apps that don't exist

        // [GIVEN] The intelligent cloud is set up
        Initialize(true);
        MigrationTableMappingRec.DeleteAll();

        // [WHEN] User chooses to manage custom tables
        MigrationTableMapping.Trap();
        Page.Run(Page::"Migration Table Mapping", MigrationTableMappingRec);

        // [WHEN] User enters bogus app name
        // [THEN] The page gives them an error because the app doesn't exist
        asserterror MigrationTableMapping."Extension Name".SetValue('My Nonexistent App');
    end;

    [Test]
    procedure ManageCustomTablesCanSetValidAppWithAbbreviation()
    var
        PublishedApplication: Record "Published Application";
        MigrationTableMappingRec: Record "Migration Table Mapping";
        MigrationTableMapping: TestPage "Migration Table Mapping";
    begin
        // [SCENARIO] User can enter a substring of the extension name, and the page will fill in the rest
        if not PublishedApplication.WritePermission then
            exit;

        // [GIVEN] The intelligent cloud is set up
        Initialize(true);
        MigrationTableMappingRec.DeleteAll();

        // [GIVEN] At least one custom app exists
        PublishedApplication.Init();
        PublishedApplication."Runtime Package ID" := CreateGuid();
        PublishedApplication.ID := CreateGuid();
        PublishedApplication.Name := 'My Test App';
        PublishedApplication."Package ID" := CreateGuid();
        PublishedApplication.Insert(false);

        // [WHEN] User chooses to manage custom tables
        MigrationTableMapping.Trap();
        Page.Run(Page::"Migration Table Mapping", MigrationTableMappingRec);

        // [WHEN] The user enters the first few characters of their extensions and tabs off
        MigrationTableMapping."Extension Name".SetValue('My T');

        // [THEN] The page finds the correct extension
        MigrationTableMapping."Extension Name".AssertEquals('My Test App');
    end;

    [Test]
    procedure ManageCustomTablesPreventsInvalidAppAndTableNames()
    var
        MigrationTableMappingRec: Record "Migration Table Mapping";
    begin
        // [SCENARIO] UI prevents user from entering non-existent app and table name values

        // [GIVEN] The intelligent cloud is set up
        Initialize(true);
        MigrationTableMappingRec.DeleteAll();

        // [WHEN] User attempts to set invalid extension
        // [THEN] They get a validation error
        asserterror MigrationTableMappingRec.Validate("App ID", CreateGuid());

        // [WHEN] User attempts to set invalid table name
        // [THEN] They get a validation error
        MigrationTableMappingRec."App ID" := CreateGuid();
        asserterror MigrationTableMappingRec.Validate("Table Name", 'Foobar Table');
    end;

    [Test]
    procedure ManageCustomTablesHidesLockedRecords()
    var
        MigrationTableMappingRec: Record "Migration Table Mapping";
        MigrationTableMapping: TestPage "Migration Table Mapping";
    begin
        // [SCENARIO] Page filter hides any locked records

        // [GIVEN] The intelligent cloud is set up
        Initialize(true);
        MigrationTableMappingRec.DeleteAll();

        // [GIVEN] A few mappings already exist but are locked
        MigrationTableMappingRec.Init();
        MigrationTableMappingRec."App ID" := CreateGuid();
        MigrationTableMappingRec."Table ID" := 139653;
        MigrationTableMappingRec.Locked := true;
        MigrationTableMappingRec.Insert(false);

        MigrationTableMappingRec.Init();
        MigrationTableMappingRec."App ID" := CreateGuid();
        MigrationTableMappingRec."Table ID" := 139654;
        MigrationTableMappingRec.Locked := true;
        MigrationTableMappingRec.Insert(false);

        // [WHEN] User chooses to manage custom tables
        MigrationTableMapping.Trap();
        Page.Run(Page::"Migration Table Mapping", MigrationTableMappingRec);

        // [THEN] The list appears empty
        Assert.IsFalse(MigrationTableMapping.First(), 'No records expected in the page view.');
    end;

    [Test]
    procedure ManageCustomTablesDeleteAllForApp()
    var
        MigrationTableMappingRec: Record "Migration Table Mapping";
        MigrationTableMapping: TestPage "Migration Table Mapping";
        AppId: Guid;
    begin
        // [SCENARIO] User can choose to delete all mapping records for a given extension

        // [GIVEN] The intelligent cloud is set up
        Initialize(true);
        MigrationTableMappingRec.DeleteAll();
        AppId := CreateGuid();

        // [GIVEN] A few mappings already exist
        MigrationTableMappingRec.Init();
        MigrationTableMappingRec."App ID" := AppId;
        MigrationTableMappingRec."Table ID" := 139653;
        MigrationTableMappingRec.Insert(false);

        MigrationTableMappingRec.Init();
        MigrationTableMappingRec."App ID" := AppId;
        MigrationTableMappingRec."Table ID" := 139654;
        MigrationTableMappingRec.Insert(false);

        // [WHEN] User chooses to manage custom tables
        MigrationTableMapping.Trap();
        Page.Run(Page::"Migration Table Mapping", MigrationTableMappingRec);

        // [WHEN] User chooses to delete all mappings for an extension
        MigrationTableMapping.First();
        MigrationTableMapping.DeleteAllForExtension.Invoke();

        // [THEN] The records are removed from the table
        Assert.IsTrue(MigrationTableMappingRec.IsEmpty(), 'Mapping table should be empty.');
    end;

    [Test]
    procedure TestIntelligentCloudManagementPagewithUpdateNotification()
    var
        IntelligentCloudManagement: TestPage "Intelligent Cloud Management";
    begin
        // [SCENARIO] User Opens up the Intelligent Cloud Management Page when update notification is available.

        // [GIVEN] User Opens up the Intelligent Cloud Management Page.
        Initialize(true);
        IntelligentCloudManagement.Trap();
        Page.Run(Page::"Intelligent Cloud Management");

        // [THEN] Check for Update action should be enabled
        with IntelligentCloudManagement do
            Assert.IsTrue(CheckForUpdate.Enabled(), 'Check for update action should be enabled');
    end;

    [Test]
    [HandlerFunctions('RunUpdateMessageHandler')]
    procedure TestIntelligentCloudUpdate()
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
        IntelligentCloudUpdatePage: TestPage "Intelligent Cloud Update";
    begin
        // [SCENARIO] User Opens up the Intelligent Cloud Update Page and clicks 'Update' button.

        // [GIVEN] User Opens up the Intelligent Cloud Update Page.
        Initialize(true);
        IntelligentCloudUpdatePage.Trap();
        Page.Run(Page::"Intelligent Cloud Update");

        // [THEN] Intelligent Cloud pipeline upgrade is run
        with IntelligentCloudUpdatePage do begin
            Assert.IsTrue(ActionUpdate.Enabled(), 'Update action should be enabled');
            ActionUpdate.Invoke();
        end;

        // [THEN] The Deployed Version in Intelligent Cloud Setup should be udpated to Latest Version
        if IntelligentCloudSetup.Get() then
            Assert.AreEqual('V2.0', IntelligentCloudSetup."Deployed Version", 'Deployed version is not updated.');
    end;

    [Test]
    [HandlerFunctions('DisableIntelligentCloudPageHandler')]
    procedure TestDisableIntelligentCloud()
    var
        IntelligentCloudManagement: TestPage "Intelligent Cloud Management";
    begin
        // [SCENARIO] User can choose to disable intelligent cloud on the ribbon

        // [GIVEN] User Opens up the Hybrid Replication Management Page.
        Initialize(true);
        IntelligentCloudManagement.Trap();
        Page.Run(Page::"Intelligent Cloud Management");

        // [WHEN] User clicks the 'Disable Replication' action in the ribbon.
        IntelligentCloudManagement.DisableIntelligentCloud.Invoke();
    end;

    [Test]
    procedure TestUpdateStatusForInProgressRuns()
    var
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        IntelligentCloudManagement: TestPage "Intelligent Cloud Management";
        RunId: Text;
        Status: Text;
        Errors: Text;
    begin
        // [SCENARIO 291819] User can refresh replication status for in-progress runs
        // [GIVEN] There is at least one in-progress record in the Replication Summary table
        RunId := CreateGuid();
        HybridReplicationSummary.CreateInProgressRecord(RunId, HybridReplicationSummary.ReplicationType::Normal);

        // [GIVEN] The replication run has finished since the page was last updated
        Status := Format(HybridReplicationSummary.Status::Failed);
        Errors := '"The thing failed"';
        LibraryHybridManagement.SetExpectedRunId(RunId);
        LibraryHybridManagement.SetExpectedStatus(Status, Errors);

        // [WHEN] The user opens the Hybrid Replication Management page in a SaaS environment
        Initialize(true);
        IntelligentCloudManagement.Trap();
        Page.Run(Page::"Intelligent Cloud Management");

        // [WHEN] and chooses the "Refresh Status" action
        IntelligentCloudManagement.RefreshStatus.Invoke();

        // [THEN] The InProgress runs that have finished are updated accordingly
        IntelligentCloudManagement.Last();
        IntelligentCloudManagement.Status.AssertEquals(Format(HybridReplicationSummary.Status::Failed));
        IntelligentCloudManagement.Details.AssertEquals('The thing failed');
    end;

    [Test]
    procedure TestIncompatibleSchemaMessageText()
    var
        HybridMessageManagement: Codeunit "Hybrid Message Management";
        Message: Text;
        Message2: Text;
        InnerMessage: Text;
    begin
        InnerMessage := '[No_]PK,|[Description]T,L,|[Statistics Group]L,';
        Message := HybridMessageManagement.ResolveMessageCode('50011', InnerMessage);
        Assert.AreNotEqual('', Message, 'Message not resolved for 50011');
        Assert.AreNotEqual(InnerMessage, Message, 'Message not resolved for 50011');

        InnerMessage := '[No_]PK,|[Description]T,|[Statistics Group]L,';
        Message2 := HybridMessageManagement.ResolveMessageCode('50011', InnerMessage);
        Assert.AreNotEqual(Message, Message2, 'InnerMessage not parsed correctly');
    end;

    [Test]
    procedure TestOnPremActionVisible()
    var
        IntelligentCloudManagement: TestPage "Intelligent Cloud Management";
    begin
        // [SCENARIO] User opens Hybrid Replication Mananagement page from on-premise.

        // [GIVEN] User opens the Hybrid Replication Management page.
        Initialize(false);
        IntelligentCloudManagement.Trap();
        Page.Run(Page::"Intelligent Cloud Management");

        // [THEN] Verify On-premise actions.
        // TODO: Fix (probably just need to settestabilitysoftwareasaserfice to false)
        // VerifyActionsVisibleState(IntelligentCloudManagement, false);
    end;

    [Test]
    procedure TestSaasActionsVisible()
    var
        IntelligentCloudManagement: TestPage "Intelligent Cloud Management";
    begin
        // [SCENARIO] User opens Hybrid Replication Mananagement page from cloud.

        // [GIVEN] User opens the Hybrid Replication Management page.
        Initialize(true);
        IntelligentCloudManagement.Trap();
        Page.Run(Page::"Intelligent Cloud Management");

        // [THEN] Verify cloud actions.
        VerifyActionsVisibleState(IntelligentCloudManagement, true);
    end;

    [Test]
    [HandlerFunctions('UpdateCompanySelectionMessageHandler')]
    procedure TestCompanySelectionUpdate()
    var
        HybridCompany: Record "Hybrid Company";
        HybridCompaniesManagement: TestPage "Hybrid Companies Management";
        SelectCompany: text[50];
    begin
        // [SCENARIO] User selects a company to replicate from the 'Hybrid Companies Management' page and clicks 'Update'.

        // [GIVEN] Companies have been synchronized from on-premise.
        SelectCompany := 'Not Selected Company';
        SetupTestHybridCompanies();

        // [GIVEN] User Opens up the Hybrid Replication Management Page.
        Initialize(true);
        HybridCompaniesManagement.Trap();
        Page.Run(Page::"Hybrid Companies Management");

        // [WHEN] User selects a company to replicate and clicks 'OK'
        SelectCompanyName(HybridCompaniesManagement, SelectCompany);
        HybridCompaniesManagement.Replicate.SetValue(true);
        HybridCompaniesManagement.OK.Invoke();

        // [THEN] The company is successfully marked to replicate.
        HybridCompany.Get(SelectCompany);
        Assert.AreEqual(true, HybridCompany.Replicate, 'Company should be selected for replication.');
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler')]
    procedure TestCompanySelectionCanceled()
    var
        HybridCompany: Record "Hybrid Company";
        HybridCompaniesManagement: TestPage "Hybrid Companies Management";
        SelectCompany: text[50];
    begin
        // [SCENARIO] User selects a company to replicate from the 'Hybrid Companies Management' page and clicks 'Cancel'.

        // [GIVEN] Companies have been synchronized from on-premise.
        SelectCompany := 'Not Selected Company';
        SetupTestHybridCompanies();

        // [GIVEN] User Opens up the Hybrid Replication Management Page.
        Initialize(true);
        HybridCompaniesManagement.Trap();
        Page.Run(Page::"Hybrid Companies Management");

        // [WHEN] User selects a company to replicate and clicks 'Cancel'
        SelectCompanyName(HybridCompaniesManagement, SelectCompany);
        HybridCompaniesManagement.Replicate.SetValue(true);
        HybridCompaniesManagement.Cancel.Invoke();

        // [THEN] The company is wasn't selected to replicate.
        HybridCompany.Get(SelectCompany);
        Assert.AreEqual(false, HybridCompany.Replicate, 'Company should NOT be selected for replication.');
    end;

    [Test]
    procedure TestNoCompaniesSelectedForReplication()
    var
        HybridCompaniesManagement: TestPage "Hybrid Companies Management";
    begin
        // [SCENARIO] User un-selects all companies to replicate from the 'Hybrid Companies Management' page.

        // [GIVEN] Companies have been synchronized from on-premise.
        SetupTestHybridCompanies();

        // [GIVEN] User Opens up the Hybrid Replication Management Page.
        Initialize(true);
        HybridCompaniesManagement.Trap();
        Page.Run(Page::"Hybrid Companies Management");

        // [WHEN] User selects each company to NOT replicate and clicks 'OK'
        HybridCompaniesManagement.First();
        repeat
            HybridCompaniesManagement.Replicate.SetValue(false);
        until not HybridCompaniesManagement.Next();

        asserterror HybridCompaniesManagement.OK.Invoke();

        // [THEN] The error displayed that at lease one company has to be selected.
        Assert.ExpectedError('You must select at least one company to migrate to continue.');
    end;

    [Test]
    procedure TestGetCopiedRecords()
    var
        HybridReplicationDetail: Record "Hybrid Replication Detail";
        Customer: Record Customer;
        IntelligentCloudStatus: Record "Intelligent Cloud Status";
    begin
        // [SCENARIO] Calling the GetCopiedRecords procedure returns the correct value.
        // [GIVEN] A table is migrating
        IntelligentCloudStatus.SetRange("Company Name", CompanyName());
#pragma warning disable AA0210
        IntelligentCloudStatus.SetRange("Table Id", Database::Customer);
#pragma warning restore
        IntelligentCloudStatus.FindFirst();

        HybridReplicationDetail.Init();
        HybridReplicationDetail."Company Name" := CopyStr(CompanyName(), 1, 30);
        HybridReplicationDetail."Table Name" := IntelligentCloudStatus."Table Name";

        // [WHEN] It is initial sync of table, the status is InProgress, and the stored record count is 0.
        IntelligentCloudStatus."Synced Version" := 0;
        IntelligentCloudStatus.Modify();
        HybridReplicationDetail.Status := HybridReplicationDetail.Status::InProgress;
        HybridReplicationDetail."Records Copied" := 0;
        HybridReplicationDetail."Total Records" := 12000;

        // [THEN] GetCopiedRecords returns the count of the table
        Assert.AreEqual(Customer.Count(), HybridReplicationDetail.GetCopiedRecords(), 'Initial sync, InProgress, 0');

        // [WHEN] It is initial sync of table, the status is InProgress, and the stored record count is >0.
        HybridReplicationDetail."Records Copied" := 50;

        // [THEN] GetCopiedRecords returns the stored value from the field
        Assert.AreEqual(50, HybridReplicationDetail.GetCopiedRecords(), 'Initial sync, InProgress, >0');

        // [WHEN] It is not the initial sync of table, the status is InProgress, and the stored record count is 0.
        IntelligentCloudStatus."Synced Version" := 1;
        IntelligentCloudStatus.Modify();
        HybridReplicationDetail."Records Copied" := 0;

        // [THEN] GetCopiedRecords returns the count of the table
        Assert.AreEqual(0, HybridReplicationDetail.GetCopiedRecords(), 'Delta sync, InProgress, 0');

        // [WHEN] It is initial sync of table, the status is Successful, and the stored record count is 0.
        IntelligentCloudStatus."Synced Version" := 0;
        IntelligentCloudStatus.Modify();
        HybridReplicationDetail.Status := HybridReplicationDetail.Status::Successful;
        HybridReplicationDetail."Records Copied" := 0;

        // [THEN] GetCopiedRecords returns the count of the table
        Assert.AreEqual(0, HybridReplicationDetail.GetCopiedRecords(), 'Initial sync, Successful, 0');

        // [WHEN] It is initial sync of table, the status is Successful, and the stored record count is >0.
        HybridReplicationDetail."Records Copied" := 15;

        // [THEN] GetCopiedRecords returns the count of the table
        Assert.AreEqual(15, HybridReplicationDetail.GetCopiedRecords(), 'Initial sync, Successful, >0');

        // [WHEN] The total records is less than 10k
        HybridReplicationDetail."Total Records" := 8700;
        HybridReplicationDetail."Records Copied" := 0;

        // [THEN] GetCopiedRecords returns the value in the table (0)
        Assert.AreEqual(0, HybridReplicationDetail.GetCopiedRecords(), 'Initial sync, Successful, =0');
    end;

    [Test]
    procedure RecordCountsHiddenIfAllZero()
    var
        HybridReplicationDetail: Record "Hybrid Replication Detail";
        IntelligentCloudDetails: TestPage "Intelligent Cloud Details";
    begin
        // [SCENARIO] Intelligent Cloud Details page only shows record counts if non-zero
        // [GIVEN] A detail record exists with 0 copied records
        HybridReplicationDetail.DeleteAll();
        HybridReplicationDetail.Init();
        HybridReplicationDetail."Run ID" := CreateGuid();
        HybridReplicationDetail."Table Name" := 'FooBar1';
        HybridReplicationDetail."Records Copied" := 0;
        HybridReplicationDetail."Total Records" := 5;
        HybridReplicationDetail.Insert();

        // [WHEN] The Intelligent Cloud Details page is opened
        IntelligentCloudDetails.Trap();
        Page.Run(Page::"Intelligent Cloud Details", HybridReplicationDetail);

        // [THEN] The record count fields are not visible
        Assert.IsFalse(IntelligentCloudDetails."Records Copied".Visible(), 'Record count should not be visible if all zero.');
        Assert.IsFalse(IntelligentCloudDetails."Total Records".Visible(), 'Record count should not be visible if all zero.');
        IntelligentCloudDetails.Close();

        // [WHEN] A detail record exists with non-zero records copied
        HybridReplicationDetail.Init();
        HybridReplicationDetail."Run ID" := CreateGuid();
        HybridReplicationDetail."Table Name" := 'FooBar2';
        HybridReplicationDetail."Records Copied" := 4;
        HybridReplicationDetail."Total Records" := 5;
        HybridReplicationDetail.Insert();

        // [WHEN] The Intillegent Cloud Details page is opened
        IntelligentCloudDetails.Trap();
        Page.Run(Page::"Intelligent Cloud Details", HybridReplicationDetail);

        // [THEN] The record count fields are not visible
        Assert.IsTrue(IntelligentCloudDetails."Records Copied".Visible(), 'Record count should be visible for non-zero values.');
        Assert.IsTrue(IntelligentCloudDetails."Total Records".Visible(), 'Record count should be visible for non-zero values.');
        IntelligentCloudDetails.Close();
    end;

    [ConfirmHandler]
    procedure ConfirmYesHandler(question: Text[1024]; var reply: Boolean)
    begin
        reply := true;
    end;

    [MessageHandler]
    procedure UpdateCompanySelectionMessageHandler(message: Text[1024])
    begin
        // [THEN] The expected message is returned to the user
        Assert.AreEqual('Company selection changes will be reflected on your next migration.', message, 'Company selection update message incorrect.');
    end;

    [MessageHandler]
    procedure RunReplicationNowMessageHandler(message: Text[1024])
    begin
        // [THEN] The expected message is incorrect
        Assert.AreEqual(RunReplicationTxt, message, 'Incorrect message.');
    end;

    [MessageHandler]
    procedure GetRuntimeKeyMessageHandler(message: Text[1024])
    begin
        // [THEN] The runtime integration key is returned to the user
        Assert.AreEqual(StrSubstNo(IntegrationKeyTxt, TestPrimaryKeyTxt), message, 'The incoming integration runtime id is not correct.');
    end;

    [MessageHandler]
    procedure GenerateNewKeyMessageHandler(message: Text[1024])
    begin
        // [THEN] The runtime integration key is returned to the user
        Assert.AreEqual(StrSubstNo(NewIntegrationKeyTxt, TestPrimaryKeyTxt), message, 'The incoming integration runtime id is not correct.');
    end;

    [MessageHandler]
    procedure GeneralMessageHandler(message: Text[1024])
    begin
    end;

    [MessageHandler]
    procedure RunUpdateMessageHandler(message: Text[1024])
    begin
        // [THEN] The expected update run message is returned to the user
        Assert.AreEqual(UpdateReplicationTxt, message, 'The run update message is not correct.');
    end;

    [PageHandler]
    procedure DisableIntelligentCloudPageHandler(var IntelligentCloudReady: TestPage "Intelligent Cloud Ready")
    begin
        Assert.IsTrue(IntelligentCloudReady.Editable(), 'Intelligent Cloud Ready page should be enabled.');
    end;

    local procedure VerifyActionsVisibleState(IntelligentCloudManagement: TestPage "Intelligent Cloud Management"; IsSaas: Boolean)
    begin
        // Cloud only actions.
        Assert.AreEqual(IsSaas, IntelligentCloudManagement.RefreshStatus.Visible(), 'RefreshStatus should be visible.');
        Assert.AreEqual(IsSaas, IntelligentCloudManagement.GetRuntimeKey.Visible(), 'GetRuntimeKey should be visible.');
        Assert.AreEqual(IsSaas, IntelligentCloudManagement.DisableIntelligentCloud.Visible(), 'DisableIntelligentCloud should be visible.');
        Assert.AreEqual(IsSaas, IntelligentCloudManagement.UpdateReplicationCompanies.Visible(), 'UpdateReplicationCompanies should be visible.');
        Assert.AreEqual(IsSaas, IntelligentCloudManagement.RunReplicationNow.Visible(), 'RunReplicationNow should be visible.');
        Assert.AreEqual(IsSaas, IntelligentCloudManagement.ResetAllCloudData.Visible(), 'ResetAllCloudData should be visible.');
        Assert.AreEqual(IsSaas, IntelligentCloudManagement.GenerateNewKey.Visible(), 'GenerateNewKey should be visible.');
        Assert.AreEqual(IsSaas, IntelligentCloudManagement.CheckForUpdate.Visible(), 'CheckForUpdate should be visible.');

        // On-Premise actions.
        Assert.AreEqual(not IsSaas, IntelligentCloudManagement.PrepareTables.Visible(), 'PrepareTables should be visible.');
    end;

    local procedure SetupTestHybridCompanies()
    begin
        CreateOrUpdateHybridCompany('Not Selected Company', 'Company not selected for replication', false);
        CreateOrUpdateHybridCompany('Replicated Company', 'Selected replicated company', true);
        CreateOrUpdateHybridCompany('Another Not Selected Company', 'Another company not selected for replication', false);
    end;

    local procedure CreateOrUpdateHybridCompany(Name: text[50]; DisplayName: text[250]; Replicate: Boolean)
    var
        HybridCompany: Record "Hybrid Company";
    begin
        HybridCompany.Init();
        if HybridCompany.Get(Name) then begin
            HybridCompany."Display Name" := DisplayName;
            HybridCompany.Replicate := Replicate;
            HybridCompany.Modify();
        end else begin
            HybridCompany.Name := Name;
            HybridCompany."Display Name" := DisplayName;
            HybridCompany.Replicate := Replicate;
            HybridCompany.Insert();
        end;
    end;

    local procedure SelectCompanyName(var HybridCompaniesManagement: TestPage "Hybrid Companies Management"; CompanyName: text[50])
    begin
        HybridCompaniesManagement.First();
        if HybridCompaniesManagement.Name.Value() <> CompanyName then
            repeat
                HybridCompaniesManagement.Next();
            until HybridCompaniesManagement.Name.Value() = CompanyName;
    end;

    local procedure SetupIntelligentCloud(var ExpectedRunId: Text; var ExpectedSource: Text)
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
    begin
        LibraryHybridManagement.SetExpectedRunId(ExpectedRunId);
        LibraryHybridManagement.SetExpectedProduct(ExpectedSource);
        IntelligentCloudSetup.Get();
        IntelligentCloudSetup."Product ID" := CopyStr(ExpectedSource, 1, 250);
        IntelligentCloudSetup."Company Creation Task Status" := IntelligentCloudSetup."Company Creation Task Status"::Completed;
        IntelligentCloudSetup.Modify();
    end;

    var
        Assert: Codeunit Assert;
        LibraryHybridManagement: Codeunit "Library - Hybrid Management";
        Initialized: Boolean;
        RunReplicationTxt: Label 'Replication has been successfully triggered; you can track the status on the management page.';
        IntegrationKeyTxt: Label 'Primary key for the integration runtime is: %1', Comment = '%1 = Integration Runtime Key';
        NewIntegrationKeyTxt: Label 'New Primary key for the integration runtime is: %1', Comment = '%1 = Integration Runtime Key';
        TestPrimaryKeyTxt: Label 'TestPrimaryKey';
        UpdateReplicationTxt: Label 'The update has completed successfully.';
}
