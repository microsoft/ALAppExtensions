codeunit 139657 "ADL Migration Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;
    EventSubscriberInstance = Manual;

    var
        Assert: Codeunit Assert;
        LibraryHybridManagement: Codeunit "Library - Hybrid Management";

    local procedure Initialize()
    var
        HybridDeploymentSetup: Record "Hybrid Deployment Setup";
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        HybridReplicationDetail: Record "Hybrid Replication Detail";
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
        Product: Text;
    begin
        IntelligentCloudSetup.DeleteAll();
        HybridDeploymentSetup.DeleteAll();
        HybridDeploymentSetup."Handler Codeunit ID" := Codeunit::"Library - Hybrid Management";
        HybridDeploymentSetup.Insert();
        HybridDeploymentSetup.Get();

        HybridReplicationDetail.DeleteAll();
        HybridReplicationSummary.DeleteAll();

        if UnbindSubscription(LibraryHybridManagement) then;
        BindSubscription(LibraryHybridManagement);
        LibraryHybridManagement.ResetSourceProduct(Product);
    end;


    // [Test]
    procedure AdlMigrationActionNotVisibleIfNotSupported()
    begin
        // [SCENARIO 345772] ADL Migration action is not available for unsupported products
        VerifyAdlMigrationActionVisibility(false);
    end;

    [Test]
    procedure AdlMigrationActionVisibleIfSupported()
    begin
        // [SCENARIO 345772] ADL Migration action is available if product supports it
        VerifyAdlMigrationActionVisibility(true);
    end;

    [Test]
    [HandlerFunctions('HandleAdlSetup')]
    procedure AdlActionOpensSetupPage()
    var
        IntelligentCloudManagement: TestPage "Intelligent Cloud Management";
    begin
        // [SCENARIO 345772] ADL action opens the ADL setup page
        Initialize();

        // [GIVEN] Migration is set up with a product that supports ADL
        LibraryHybridManagement.SetAdlMigrationEnabled(true);

        // [WHEN] User launches the cloud migration management page
        IntelligentCloudManagement.Trap();
        Page.Run(Page::"Intelligent Cloud Management");

        // [WHEN] And chooses the ADL action
        IntelligentCloudManagement.AdlSetup.Invoke();

        // [THEN] The ADL Setup page opens
        // Verified by HandleAdlSetup
    end;

    [Test]
    [HandlerFunctions('HandleAdlSetup')]
    procedure AdlActionViaCloudReadyOpensSetupPage()
    var
        IntelligentCloudReady: TestPage "Intelligent Cloud Ready";
    begin
        // [SCENARIO 345772] ADL action opens the ADL setup page
        Initialize();

        // [GIVEN] Migration is set up with a product that supports ADL
        LibraryHybridManagement.SetAdlMigrationEnabled(true);

        // [WHEN] User launches the intelligent cloud ready page
        IntelligentCloudReady.Trap();
        Page.Run(Page::"Intelligent Cloud Ready");

        // [WHEN] And chooses the ADL action
        IntelligentCloudReady.AdlSetup.Invoke();

        // [THEN] The ADL Setup page opens
        // Verified by HandleAdlSetup
    end;

    [Test]
    procedure AdlMigrationPageOpensIfSupported()
    var
        CloudMigrationAdlSetup: TestPage "Cloud Migration ADL Setup";
    begin
        // [SCENARIO 345772] ADL Migration page opens without error if supported
        Initialize();

        // [GIVEN] Migration is set up with an ADL-supported product
        LibraryHybridManagement.SetAdlMigrationEnabled(true);

        // [WHEN] User launches the ADL setup page
        CloudMigrationAdlSetup.OpenEdit();

        // [THEN] The page opens without error
        CloudMigrationAdlSetup.Close();
    end;

    [Test]
    procedure AdlMigrationPageFailsIfNotSupported()
    begin
        // [SCENARIO 345772] ADL Migration page fails to oppen if not supported
        Initialize();

        // [GIVEN] Migration is set up with a product that does not support ADL
        LibraryHybridManagement.SetAdlMigrationEnabled(false);

        // [WHEN] User launches the ADL setup page
        Commit();
        asserterror Page.Run(Page::"Cloud Migration ADL Setup");

        // [THEN] The page fails to open
    end;

    [Test]
    [HandlerFunctions('CaptureMessageDialog')]
    procedure AdlWizardWorks()
    var
        CloudMigrationAdlSetupRec: Record "Cloud Migration ADL Setup";
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        CloudMigrationAdlSetup: TestPage "Cloud Migration ADL Setup";
        RunId: Text;
    begin
        // [SCENARIO 345772] ADL Migration page functions correctly
        Initialize();
        LibraryHybridManagement.SetAdlMigrationEnabled(true);

        // [GIVEN] User opens the ADL setup page
        CloudMigrationAdlSetup.OpenEdit();

        // [THEN] Next is initially disabled
        Assert.IsFalse(CloudMigrationAdlSetup.ActionNext.Enabled(), 'Next should be initially disabled');

        // [THEN] Back is also disabled
        Assert.IsFalse(CloudMigrationAdlSetup.ActionBack.Enabled(), 'Back should be initially disabled');

        // [WHEN] User accepts privacy notice
        CloudMigrationAdlSetup.AcceptLegal.SetValue(true);

        // [THEN] Next is enabled
        Assert.IsTrue(CloudMigrationAdlSetup.ActionNext.Enabled(), 'Next should be enabled after privacy acceptance');

        // [WHEN] User clicks Next
        CloudMigrationAdlSetup.ActionNext.Invoke();

        // [THEN] UI moves to next page
        Assert.IsTrue(CloudMigrationAdlSetup."Storage Account Name".Visible(), 'Storage account name not visible');
        Assert.IsTrue(CloudMigrationAdlSetup."Storage Account Key".Visible(), 'Storage account key not visible');
        Assert.IsFalse(CloudMigrationAdlSetup.AcceptLegal.Visible(), 'Privacy notice is still visible');

        // [THEN] Next is disabled
        Assert.IsFalse(CloudMigrationAdlSetup.ActionNext.Enabled(), 'Next should be disabled before entering info');

        // [WHEN] User clicks back
        CloudMigrationAdlSetup.ActionBack.Invoke();

        // [THEN] UI returns to first page
        Assert.IsFalse(CloudMigrationAdlSetup."Storage Account Name".Visible(), 'Storage account name visible');
        Assert.IsFalse(CloudMigrationAdlSetup."Storage Account Key".Visible(), 'Storage account key visible');
        Assert.IsTrue(CloudMigrationAdlSetup.AcceptLegal.Visible(), 'Privacy notice is not visible');
        Assert.IsTrue(CloudMigrationAdlSetup.ActionNext.Enabled(), 'Next should be enabled after navigating back');
        Assert.IsFalse(CloudMigrationAdlSetup.ActionBack.Enabled(), 'Back should be disabled on first page');

        // [WHEN] User clicks next again and enters storage account name
        CloudMigrationAdlSetup.ActionNext.Invoke();
        CloudMigrationAdlSetup."Storage Account Name".SetValue('fooadl');

        // [THEN] Next is still disabled
        Assert.IsFalse(CloudMigrationAdlSetup.ActionNext.Enabled(), 'Next should be disabled before entering account and key');

        // [WHEN] User provides storage account key
        CloudMigrationAdlSetup."Storage Account Key".SetValue('fooadlkey');

        // [THEN] Next action becomes enabled
        Assert.IsTrue(CloudMigrationAdlSetup.ActionNext.Enabled(), 'Next should be enabled after entering account and key');

        // [WHEN] User clears account name
        CloudMigrationAdlSetup."Storage Account Name".SetValue('');

        // [THEN] Next action becomes disabled
        Assert.IsFalse(CloudMigrationAdlSetup.ActionNext.Enabled(), 'Next should be disabled if account or key are empty');

        // [WHEN] User enters account name again and clicks next
        CloudMigrationAdlSetup."Storage Account Name".SetValue('foobaradl');
        CloudMigrationAdlSetup.ActionNext.Invoke();

        // [THEN] UI moves to last page
        Assert.IsFalse(CloudMigrationAdlSetup."Storage Account Name".Visible(), 'Storage account name visible');
        Assert.IsFalse(CloudMigrationAdlSetup."Storage Account Key".Visible(), 'Storage account key visible');
        Assert.IsFalse(CloudMigrationAdlSetup.AcceptLegal.Visible(), 'Privacy notice is not visible');
        Assert.IsTrue(CloudMigrationAdlSetup.ActionBack.Enabled(), 'Back should be enabled on last page');
        Assert.IsFalse(CloudMigrationAdlSetup.ActionNext.Enabled(), 'Next should be disabled on last page');
        Assert.IsTrue(CloudMigrationAdlSetup.ActionFinish.Enabled(), 'Finish should be enabled on last page');

        // [WHEN] User clicks finish
        LibraryHybridManagement.SetExpectedRunId(RunId);
        CloudMigrationAdlSetup.ActionFinish.Invoke();

        // [THEN] Message appears
        // Verified by message handler

        // [THEN] A call is made to initiate the data lake migration
        HybridReplicationSummary.Get(RunId);
        Assert.AreEqual(HybridReplicationSummary.Status::InProgress, HybridReplicationSummary.Status, 'Status not in progress');
        Assert.AreEqual(HybridReplicationSummary.ReplicationType::"Azure Data Lake", HybridReplicationSummary.ReplicationType, 'Type not ADL');

        // [THEN] No actual record was inserted into ADL setup table
        Assert.IsTrue(CloudMigrationAdlSetupRec.IsEmpty(), 'Adl Setup table must be empty');

        // [THEN] Page closes
        // The asserterror will fail if the page is still open
        asserterror CloudMigrationAdlSetup.Close();
    end;

    [Test]
    procedure RunAdlMigrationInitiatesMigration()
    var
        CloudMigrationAdlSetup: Record "Cloud Migration ADL Setup";
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
        Product: Text;
    begin
        // [SCENARIO 345772] Run ADL Migration api initiates the migration
        Initialize();

        // [GIVEN] Cloud migration is set up
        Product := 'AdlSupported';
        LibraryHybridManagement.SetExpectedProduct(Product);

        // [WHEN] RunAdlMigration function is called
        CloudMigrationAdlSetup."Storage Account Name" := 'testadl';
        CloudMigrationAdlSetup."Storage Account Key" := 'testadlkey';
        HybridCloudManagement.RunAdlMigration(CloudMigrationAdlSetup);

        // [THEN] Call to service was made with correct account name and key
        Assert.AreEqual('testadl', LibraryHybridManagement.GetAdlAccountName(), 'Unexpected account name');
        Assert.AreEqual('testadlkey', LibraryHybridManagement.GetAdlAccountKey(), 'Unexpected account key');
    end;

    [Test]
    procedure RunAdlMigrationCreatesInProgressRecord()
    var
        CloudMigrationAdlSetup: Record "Cloud Migration ADL Setup";
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
        Product: Text;
        RunId: Text;
    begin
        // [SCENARIO 345772] Run ADL Migration api creates in-progress summary record
        Initialize();

        // [GIVEN] Cloud migration is set up
        LibraryHybridManagement.SetExpectedProduct(Product);
        LibraryHybridManagement.ResetSourceProduct(Product);

        // [WHEN] Call to initiate ADL migration is made
        CloudMigrationAdlSetup."Storage Account Name" := 'testadl';
        CloudMigrationAdlSetup."Storage Account Key" := 'testadlkey';
        LibraryHybridManagement.SetExpectedRunId(RunId);
        HybridCloudManagement.RunAdlMigration(CloudMigrationAdlSetup);

        // [THEN] Summary record is inserted with correct values
        HybridReplicationSummary.Get(RunId);
        Assert.AreEqual(HybridReplicationSummary.ReplicationType::"Azure Data Lake", HybridReplicationSummary.ReplicationType, 'Incorrect replication type');
        Assert.AreEqual(Product, HybridReplicationSummary.Source, 'Source not specified');
    end;

    [Test]
    procedure ParseMigrationSummaryCallsFinishAdlMigration()
    var
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        NotificationHandler: Codeunit "Notification Handler";
        NotificationText: Text;
        RunId: Text;
        TriggerType: Text;
        Product: Text;
        StartTime: DateTime;
    begin
        // [SCENARIO 345772] Correct events are called after finishing ADL migration
        Initialize();
        LibraryHybridManagement.SetExpectedProduct(Product);
        LibraryHybridManagement.SetExpectedRunId(RunId);
        LibraryHybridManagement.SetAdlCleanedUp(false);

        // [GIVEN] A valid notification payload
        NotificationText := LibraryHybridManagement.GetNotificationPayload(Product, RunId, StartTime, TriggerType, HybridReplicationSummary.ReplicationType::"Azure Data Lake", ', "Status": "' + Format(HybridReplicationSummary.Status::Completed) + '"');

        // [WHEN] The function to parse that payload is called
        NotificationHandler.ParseReplicationSummary(HybridReplicationSummary, NotificationText);

        // [THEN] The FinishAdlMigration event publisher is called
        Assert.IsTrue(LibraryHybridManagement.GetAdlCleanedUp(), 'Finish ADL subscriber not called');
    end;

    [Test]
    procedure AdlCleanupDisablesAdlMigration()
    var
    begin
        // [SCENARIO 345772] ADL Cleanup codeunit properly disables ADL migration
        Initialize();
        LibraryHybridManagement.SetAdlCleanedUp(false);

        // [WHEN] Cleanup codeunit is run
        Codeunit.Run(Codeunit::"Data Lake Migration Cleanup");

        // [THEN] The call to disable data lake migration is made
        Assert.IsTrue(LibraryHybridManagement.GetAdlCleanedUp(), 'Adl migration not cleaned up');
    end;

    [ModalPageHandler]
    procedure HandleAdlSetup(var CloudMigrationAdlSetup: TestPage "Cloud Migration ADL Setup")
    begin
        CloudMigrationAdlSetup.Close();
    end;

    [MessageHandler]
    procedure CaptureMessageDialog(Message: Text[1024])
    begin
    end;

    local procedure VerifyAdlMigrationActionVisibility(ExpectedVisibility: Boolean)
    var
        IntelligentCloudManagement: TestPage "Intelligent Cloud Management";
        IntelligentCloudReady: TestPage "Intelligent Cloud Ready";
    begin
        Initialize();

        // [GIVEN] ADL Migration is enabled or disabled for the source product
        LibraryHybridManagement.SetAdlMigrationEnabled(ExpectedVisibility);

        // [WHEN] User opens the cloud migration management page
        IntelligentCloudManagement.OpenEdit();

        // [THEN] The Azure Data Lake action is properly visible
        Assert.AreEqual(ExpectedVisibility, IntelligentCloudManagement.AdlSetup.Visible(), 'Management page');

        // [WHEN] User opens the disable migration flow
        IntelligentCloudReady.Trap();
        IntelligentCloudManagement.DisableIntelligentCloud.Invoke();

        // [THEN] The Azure Data Lake action is properly enabled
        Assert.AreEqual(ExpectedVisibility, IntelligentCloudReady.AdlSetup.Enabled(), 'Cloud Ready page');
    end;
}