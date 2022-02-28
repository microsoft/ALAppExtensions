codeunit 139671 "GP Cloud Migration E2E Test"
{
    // [FEATURE] [GP Forecasting]

    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
    end;

    var
        HybridGPWizard: Codeunit "Hybrid GP Wizard";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        Initialized: Boolean;
        SubscriptionFormatTxt: Label '%1_IntelligentCloud', Comment = '%1 - The source product id', Locked = true;
        DateTimeStringFormatTok: Label '%1-%2-%3', Locked = true;

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
        GPE2ETestEventHandler: Codeunit "GP E2E Test Event Handler";
        IntelligentCloudManagement: TestPage "Intelligent Cloud Management";
    begin
        // [GIVEN] Cloud Migration has been succesfully setup
        Initialize();
        BindSubscription(CloudMigE2EEventHandler);
        BindSubscription(GPE2ETestEventHandler);
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
        InsertWebhookCompletedReplication(HybridReplicationSummary."Run ID", HybridCompany.Name);

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

    local procedure InsertWebhookCompletedReplication(RunID: Text; CompanyName: Text)
    var
        WebhookNotification: Record "Webhook Notification";
        NotificationOutStream: OutStream;
        TodayDate: Date;
        DateTimeString: Text;
    begin
        WebhookNotification.ID := CreateGuid();
        WebhookNotification."Sequence Number" := 1;
        WebhookNotification."Subscription ID" := COPYSTR(STRSUBSTNO(SubscriptionFormatTxt, HybridGPWizard.ProductId()), 1, 150);
        WebhookNotification.Notification.CreateOutStream(NotificationOutStream);
        TodayDate := DT2Date(CurrentDateTime);
        DateTimeString := StrSubstNo(DateTimeStringFormatTok, Date2DMY(TodayDate, 3), Date2DMY(TodayDate, 2), Date2DMY(TodayDate, 1));
        NotificationOutStream.WriteText(GetGPCloudSuccessfullNotification(RunID, CompanyName, DateTimeString));
        WebhookNotification.Insert();
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

        IntelligentCloudSetup."Product ID" := HybridGPWizard.ProductId();
        IntelligentCloudSetup."Company Creation Task Status" := IntelligentCloudSetup."Company Creation Task Status"::Completed;
        IntelligentCloudSetup."Replication Enabled" := true;
        IntelligentCloudSetup.Insert();

        HybridReplicationSummary."Run ID" := CreateGuid();
        HybridReplicationSummary."Start Time" := CurrentDateTime() - 10000;
        HybridReplicationSummary."End Time" := CurrentDateTime() - 5000;
        HybridReplicationSummary.ReplicationType := HybridReplicationSummary.ReplicationType::Normal;
        HybridReplicationSummary.Status := HybridReplicationSummary.Status::Completed;
        HybridReplicationSummary.Source := HybridGPWizard.ProductName();
        HybridReplicationSummary."Trigger Type" := HybridReplicationSummary."Trigger Type"::Scheduled;
        HybridReplicationSummary.Insert();
    end;

    local procedure GetGPCloudSuccessfullNotification(RunId: Text; NameOfCompany: Text; StartDate: Text): Text
    begin
        exit('{ "@odata.type": "#Microsoft.Dynamics.NAV.Hybrid.Notification", "SubscriptionId": "DynamicsGP_IntelligentCloud", "ChangeType": "Changed", "RunId": "' + RunId + '", "StartTime": "' + StartDate + 'T23:59:59.3759312Z", "TriggerType": "Manual", "Status": "Completed", "ServiceType": "ReplicationCompleted", "IncrementalTables": [{ "TableName": "' + NameOfCompany + '$GP Account$feeb3504-556e-4790-b28d-a2b9ce302d81", "CompanyName": "' + NameOfCompany + '","Errors": ""}, { "TableName": "' + NameOfCompany + '$GP Posting Accounts$feeb3504-556e-4790-b28d-a2b9ce302d81", "CompanyName": "' + NameOfCompany + '", "Errors": "" }]}');
    end;
}