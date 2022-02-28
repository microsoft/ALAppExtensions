codeunit 139673 "Hybrid BC Last E2E Test"
{
    // [FEATURE] [GP Forecasting]

    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
    end;

    var
        HybridBCLastWizard: Codeunit "Hybrid BC Last Wizard";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        Initialized: Boolean;

    local procedure Initialize()
    var
        HybridCompany: Record "Hybrid Company";
        HybridCompanyStatus: Record "Hybrid Company Status";
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        HybridReplicationDetail: Record "Hybrid Replication Detail";
        IntelligentCloud: Record "Intelligent Cloud";
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
        WebhookNotification: Record "Webhook Notification";
    begin
        HybridCompany.DeleteAll();
        HybridCompanyStatus.DeleteAll();
        HybridReplicationSummary.DeleteAll();
        HybridReplicationDetail.DeleteAll();
        IntelligentCloud.DeleteAll();
        IntelligentCloudSetup.DeleteAll();
        WebhookNotification.DeleteAll();

        LibraryVariableStorage.AssertEmpty();

        if Initialized then
            exit;

        Initialized := true;
        Commit();
    end;

    [Test]
    [HandlerFunctions('TestConfirmationHandler,TestMessageHandler')]
    procedure TestStatusIsSetToUpgradePending()
    var
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        HybridCompany: Record "Hybrid Company";
        DummyHybridCompanyStatus: Record "Hybrid Company Status";
        CloudMigE2EEventHandler: Codeunit "Cloud Mig E2E Event Handler";
        LibraryHybridBCLast: Codeunit "Library - Hybrid BC Last";
        BCLastE2EEventHandler: Codeunit "BC Last E2E Event Handler";
        IntelligentCloudManagement: TestPage "Intelligent Cloud Management";
    begin
        // [GIVEN] Cloud Migration has been succesfully setup
        Initialize();
        BindSubscription(CloudMigE2EEventHandler);
        BindSubscription(BCLastE2EEventHandler);
        InsertSetupRecords();

        // [GIVEN] User invokes run replication now
        IntelligentCloudManagement.OpenEdit();
        LibraryVariableStorage.Enqueue(true);
        IntelligentCloudManagement.RunReplicationNow.Invoke();
        IntelligentCloudManagement.Close();

        HybridCompany.SetRange(Replicate, true);
        HybridCompany.FindLast();
        HybridReplicationSummary.SetCurrentKey("Start Time");
        HybridReplicationSummary.FindLast();

        // [WHEN] Webhook updates the status
        LibraryHybridBCLast.InsertWebhookCompletedReplication(HybridReplicationSummary."Run ID", HybridCompany.Name);

        // [THEN] Cloud Migraiton is succesfully completed and state is set to pendign
        VerifyHybridReplicationSummaryIsPending();
        VerifyHybridCompanyStatusRecords(DummyHybridCompanyStatus."Upgrade Status"::Pending);

        IntelligentCloudManagement.OpenEdit();
        LibraryVariableStorage.Enqueue(true);
        IntelligentCloudManagement.RunDataUpgrade.Invoke();
        IntelligentCloudManagement.Close();

        VerifyHybridReplicationSummaryIsCompleted();
        VerifyHybridCompanyStatusRecords(DummyHybridCompanyStatus."Upgrade Status"::Completed);
    end;

    [ConfirmHandler]
    procedure TestConfirmationHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := LibraryVariableStorage.DequeueBoolean();
    end;

    [MessageHandler]
    procedure TestMessageHandler(Message: Text[1024])
    begin
    end;

    local procedure VerifyHybridReplicationSummaryIsPending()
    var
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        Assert: Codeunit Assert;
    begin
        HybridReplicationSummary.SetCurrentKey("End Time");
        HybridReplicationSummary.Ascending(false);
        HybridReplicationSummary.FindFirst();

        Assert.AreEqual(HybridReplicationSummary.Status::UpgradePending, HybridReplicationSummary.Status, 'Upgrade status should have been set to pending');
    end;

    local procedure VerifyHybridReplicationSummaryIsCompleted()
    var
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        Assert: Codeunit Assert;
    begin
        HybridReplicationSummary.SetCurrentKey("End Time");
        HybridReplicationSummary.Ascending(false);
        HybridReplicationSummary.FindFirst();

        Assert.AreEqual(HybridReplicationSummary.Status::Completed, HybridReplicationSummary.Status, 'Upgrade status should have been set to pending');
    end;

    local procedure VerifyHybridCompanyStatusRecords(ExpectedUpgradeStatus: Option)
    var
        HybridCompany: Record "Hybrid Company";
        HybridCompanyStatus: Record "Hybrid Company Status";
        Assert: Codeunit Assert;
    begin
        HybridCompany.SetRange(Replicate, true);
        HybridCompany.FindSet();

        repeat
            Assert.IsTrue(HybridCompanyStatus.Get(HybridCompany.Name), 'Hybrid company status was not found for company ' + HybridCompany.Name);
            Assert.AreEqual(ExpectedUpgradeStatus, HybridCompanyStatus."Upgrade Status", 'Wrong status on Hybrid Company Status for company ' + HybridCompany.Name);
        until HybridCompany.Next() = 0;
    end;

    local procedure InsertSetupRecords()
    var
        HybridCompany: Record "Hybrid Company";
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        IntelligentCloud: Record "Intelligent Cloud";
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
    begin
        HybridCompany.Name := CopyStr(CompanyName(), 1, MaxStrLen(HybridCompany.Name));
        HybridCompany."Display Name" := HybridCompany.Name;
        HybridCompany.Replicate := true;
        HybridCompany.Insert();

        if IntelligentCloud.Get() then
            IntelligentCloud.Delete();

        IntelligentCloud.Enabled := true;
        IntelligentCloud.Insert();

        IntelligentCloudSetup."Product ID" := HybridBCLastWizard.ProductId();
        IntelligentCloudSetup."Company Creation Task Status" := IntelligentCloudSetup."Company Creation Task Status"::Completed;
        IntelligentCloudSetup."Replication Enabled" := true;
        IntelligentCloudSetup.Insert();

        HybridReplicationSummary."Run ID" := CreateGuid();
        HybridReplicationSummary."Start Time" := CurrentDateTime() - 10000;
        HybridReplicationSummary."End Time" := CurrentDateTime() - 5000;
        HybridReplicationSummary.ReplicationType := HybridReplicationSummary.ReplicationType::Normal;
        HybridReplicationSummary.Status := HybridReplicationSummary.Status::Completed;
        HybridReplicationSummary.Source := HybridBCLastWizard.ProductName();
        HybridReplicationSummary."Trigger Type" := HybridReplicationSummary."Trigger Type"::Scheduled;
        HybridReplicationSummary.Insert();
    end;
}