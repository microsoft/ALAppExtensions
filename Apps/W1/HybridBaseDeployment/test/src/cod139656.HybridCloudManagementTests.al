codeunit 139656 "Hybrid Cloud Management Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        LibraryHybridManagement: Codeunit "Library - Hybrid Management";
        Initialized: Boolean;
        ExtensionRefreshFailureErr: Label 'Some extensions could not be updated and may need to be reinstalled to refresh their data.';
        ExtensionRefreshUnexpectedFailureErr: Label 'Failed to update extensions. You may need to verify and reinstall any missing extensions if needed.';

    local procedure Initialize()
    var
        HybridDeploymentSetup: Record "Hybrid Deployment Setup";
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        HybridReplicationDetail: Record "Hybrid Replication Detail";
    begin
        if not Initialized then begin
            HybridDeploymentSetup.DeleteAll();
            HybridDeploymentSetup."Handler Codeunit ID" := Codeunit::"Library - Hybrid Management";
            HybridDeploymentSetup.Insert();
            BindSubscription(LibraryHybridManagement);
            HybridDeploymentSetup.Get();
        end;

        HybridReplicationDetail.DeleteAll();
        HybridReplicationSummary.DeleteAll();
        Initialized := true;
    end;

    [Test]
    procedure TestRedirectToSaaSWizardUrl()
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
        RedirectUrl: Text;
    begin
        // [SCENARIO] Verifies the redirect to SAAS wizard url is correct.

        // [GIVEN] The request to navigate to SAAS wizard is executed.

        // [THEN] The url to the SAAS wizard and filter are correct.
        RedirectUrl := HybridCloudManagement.GetSaasWizardRedirectUrl(IntelligentCloudSetup);
        Assert.IsTrue(RedirectUrl.Contains('?page=4000'), 'Redirect Url is incorrect: ' + RedirectUrl);
    end;

    [Test]
    procedure TestParseWebhookNotification()
    var
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        NotificationHandler: Codeunit "Notification Handler";
        NotificationText: Text;
        RunId: Text;
        StartTime: DateTime;
        TriggerType: Text;
        ProductName: Text;
    begin
        Initialize();
        LibraryHybridManagement.ResetSourceProduct(ProductName);

        // [GIVEN] A valid notification payload
        NotificationText := LibraryHybridManagement.GetNotificationPayload(ProductName, RunId, StartTime, TriggerType, HybridReplicationSummary.ReplicationType::Full, ', "Status": "' + Format(HybridReplicationSummary.Status::Completed) + '"');

        // [WHEN] The function to parse that payload is called
        NotificationHandler.ParseReplicationSummary(HybridReplicationSummary, NotificationText);

        // [THEN] The expected values from the payload are set in a HybridReplicationSummary record
        Assert.AreEqual(RunId, HybridReplicationSummary."Run ID", 'Incorrect value parsed for "Run ID".');
        Assert.AreEqual(StartTime, HybridReplicationSummary."Start Time", 'Incorrect value parsed for "Start Time".');
        Assert.AreEqual(HybridReplicationSummary."Trigger Type"::Manual, HybridReplicationSummary."Trigger Type", 'Incorrect value parsed for "Trigger Type".');
        Assert.AreEqual(HybridReplicationSummary.ReplicationType::Full, HybridReplicationSummary.ReplicationType, 'Incorrect value parsed for "Replication Type".');
        Assert.AreEqual(HybridReplicationSummary.Status::Completed, HybridReplicationSummary.Status, 'Incorrect value parsed for "Status".');
        Assert.AreEqual(ProductName, HybridReplicationSummary.Source, 'Incorrect value parsed for "Source".');
    end;

    [Test]
    procedure TestParseWebhookNotificationForFailedRun()
    var
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        NotificationHandler: Codeunit "Notification Handler";
        NotificationText: Text;
        RunId: Text;
        StartTime: DateTime;
        TriggerType: Text;
        ProductName: Text;
        PipelineErrors: Text;
        Status: Text;
    begin
        Initialize();
        PipelineErrors := '[]';
        Status := Format(HybridReplicationSummary.Status::Failed);
        LibraryHybridManagement.SetExpectedStatus(Status, PipelineErrors);
        LibraryHybridManagement.ResetSourceProduct(ProductName);

        // [GIVEN] A valid notification payload
        TriggerType := 'Scheduled';
        NotificationText := LibraryHybridManagement.GetNotificationPayload(ProductName, RunId, StartTime, TriggerType, HybridReplicationSummary.ReplicationType::Normal, ', "Status": "Failed", "Details": "Bad stuff"');

        // [WHEN] The function to parse that payload is called
        NotificationHandler.ParseReplicationSummary(HybridReplicationSummary, NotificationText);

        // [THEN] The expected values from the payload are set in a HybridReplicationSummary record
        Assert.AreEqual(RunId, HybridReplicationSummary."Run ID", 'Incorrect value parsed for "Run ID".');
        Assert.AreEqual(StartTime, HybridReplicationSummary."Start Time", 'Incorrect value parsed for "Start Time".');
        Assert.AreEqual(HybridReplicationSummary."Trigger Type"::Scheduled, HybridReplicationSummary."Trigger Type", 'Incorrect value parsed for "Trigger Type".');
        Assert.AreEqual(HybridReplicationSummary.ReplicationType::Normal, HybridReplicationSummary.ReplicationType, 'Incorrect value parsed for "Replication Type".');
        Assert.AreEqual(HybridReplicationSummary.Status::Failed, HybridReplicationSummary.Status, 'Incorrect value parsed for "Status".');
        Assert.AreEqual(ProductName, HybridReplicationSummary.Source, 'Incorrect value parsed for "Source".');
        Assert.AreEqual('Bad stuff', HybridReplicationSummary.GetDetails(), 'Incorrect value parsed for "Details".');
    end;

    [Test]
    procedure TestParseWebhookNotificationForFailedRunWithPipelineErrors()
    var
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        NotificationHandler: Codeunit "Notification Handler";
        NotificationText: Text;
        RunId: Text;
        StartTime: DateTime;
        TriggerType: Text;
        ProductName: Text;
        Errors: Text;
        Status: Text;
    begin
        Initialize();
        Status := Format(HybridReplicationSummary.Status::Failed);
        Errors := '"Failure 1", "Failure 2"';
        LibraryHybridManagement.SetExpectedStatus(Status, Errors);
        LibraryHybridManagement.ResetSourceProduct(ProductName);

        // [GIVEN] A valid notification payload
        TriggerType := 'Scheduled';
        NotificationText := LibraryHybridManagement.GetNotificationPayload(ProductName, RunId, StartTime, TriggerType, HybridReplicationSummary.ReplicationType::Diagnostic, ', "Status": "Failed", "Details": "bad things"');

        // [WHEN] The function to parse that payload is called
        NotificationHandler.ParseReplicationSummary(HybridReplicationSummary, NotificationText);

        // [THEN] The expected values from the payload are set in a HybridReplicationSummary record
        Assert.AreEqual(RunId, HybridReplicationSummary."Run ID", 'Incorrect value parsed for "Run ID".');
        Assert.AreEqual(StartTime, HybridReplicationSummary."Start Time", 'Incorrect value parsed for "Start Time".');
        Assert.AreEqual(HybridReplicationSummary."Trigger Type"::Scheduled, HybridReplicationSummary."Trigger Type", 'Incorrect value parsed for "Trigger Type".');
        Assert.AreEqual(HybridReplicationSummary.Status::Failed, HybridReplicationSummary.Status, 'Incorrect value parsed for "Status".');
        Assert.AreEqual(HybridReplicationSummary.ReplicationType::Diagnostic, HybridReplicationSummary.ReplicationType, 'Incorrect value parsed for "Replication Type".');
        Assert.AreEqual(ProductName, HybridReplicationSummary.Source, 'Incorrect value parsed for "Source".');
        Assert.AreEqual('Failure 1\Failure 2', HybridReplicationSummary.GetDetails(), 'Incorrect value parsed for "Details".');
    end;

    [Test]
    procedure TestParseWebhookNotificationForCompletedRunWithExtensionRefreshErrors()
    var
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        NotificationHandler: Codeunit "Notification Handler";
        NotificationText: Text;
        RunId: Text;
        StartTime: DateTime;
        TriggerType: Text;
        ProductName: Text;
    begin
        Initialize();
        LibraryHybridManagement.ResetSourceProduct(ProductName);

        // [GIVEN] A valid notification payload
        TriggerType := 'Scheduled';
        NotificationText := LibraryHybridManagement.GetNotificationPayload(ProductName, RunId, StartTime, TriggerType, HybridReplicationSummary.ReplicationType::Normal, ', "Status": "Completed", "ExtensionRefreshFailed": { "ErrorCode": "50008", "FailedExtensions": "Late Payment Prediction, Essential Business Headlines"}');

        // [WHEN] The function to parse that payload is called
        NotificationHandler.ParseReplicationSummary(HybridReplicationSummary, NotificationText);

        // [THEN] The expected values from the payload are set in a HybridReplicationSummary record
        Assert.AreEqual(RunId, HybridReplicationSummary."Run ID", 'Incorrect value parsed for "Run ID".');
        Assert.AreEqual(StartTime, HybridReplicationSummary."Start Time", 'Incorrect value parsed for "Start Time".');
        Assert.AreEqual(HybridReplicationSummary."Trigger Type"::Scheduled, HybridReplicationSummary."Trigger Type", 'Incorrect value parsed for "Trigger Type".');
        Assert.AreEqual(HybridReplicationSummary.Status::Completed, HybridReplicationSummary.Status, 'Incorrect value parsed for "Status".');
        Assert.AreEqual(ProductName, HybridReplicationSummary.Source, 'Incorrect value parsed for "Source".');
        Assert.AreEqual(ExtensionRefreshFailureErr + ' Late Payment Prediction, Essential Business Headlines', HybridReplicationSummary.GetDetails(), 'Incorrect value parsed for "Details".');
    end;

    [Test]
    procedure TestParseWebhookNotificationForCompletedRunWithExtensionRefreshUnexpectedErrors()
    var
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        NotificationHandler: Codeunit "Notification Handler";
        NotificationText: Text;
        RunId: Text;
        StartTime: DateTime;
        TriggerType: Text;
        ProductName: Text;
    begin
        Initialize();
        LibraryHybridManagement.ResetSourceProduct(ProductName);

        // [GIVEN] A valid notification payload
        TriggerType := 'Scheduled';
        NotificationText := LibraryHybridManagement.GetNotificationPayload(ProductName, RunId, StartTime, TriggerType, HybridReplicationSummary.ReplicationType::Normal, ', "Status": "Completed", "ExtensionRefreshUnexpectedError": { "ErrorCode": "50009" }');

        // [WHEN] The function to parse that payload is called
        NotificationHandler.ParseReplicationSummary(HybridReplicationSummary, NotificationText);

        // [THEN] The expected values from the payload are set in a HybridReplicationSummary record
        Assert.AreEqual(RunId, HybridReplicationSummary."Run ID", 'Incorrect value parsed for "Run ID".');
        Assert.AreEqual(StartTime, HybridReplicationSummary."Start Time", 'Incorrect value parsed for "Start Time".');
        Assert.AreEqual(HybridReplicationSummary."Trigger Type"::Scheduled, HybridReplicationSummary."Trigger Type", 'Incorrect value parsed for "Trigger Type".');
        Assert.AreEqual(HybridReplicationSummary.Status::Completed, HybridReplicationSummary.Status, 'Incorrect value parsed for "Status".');
        Assert.AreEqual(ProductName, HybridReplicationSummary.Source, 'Incorrect value parsed for "Source".');
        Assert.AreEqual(ExtensionRefreshUnexpectedFailureErr, HybridReplicationSummary.GetDetails(), 'Incorrect value parsed for "Details".');
    end;

    [Test]
    procedure TestGetNextScheduledReplicationLaterToday()
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
        TodayDateTime: DateTime;
        TodayTime: Time;
        NextScheduled: DateTime;
    begin
        // [GIVEN] The intelligent cloud is scheduled for Thursday at 13:01
        Evaluate(TodayTime, '13:00');
        TodayDateTime := CreateDateTime(DMY2Date(09, 08, 2018), TodayTime);
        IntelligentCloudSetup.DeleteAll();
        IntelligentCloudSetup.Init();
        IntelligentCloudSetup.Thursday := true;
        IntelligentCloudSetup."Time to Run" := DT2Time(TodayDateTime) + 60000; // One minute in the future
        IntelligentCloudSetup.Insert();

        // [WHEN] The call to get the next scheduled run is made on Thursday at 13:00
        NextScheduled := IntelligentCloudSetup.GetNextScheduledRunDateTime(TodayDateTime);

        // [THEN] The next scheduled date time is returned as Thursday at 13:01
        Assert.AreEqual(TodayDateTime + 60000, NextScheduled, 'Unexpected next scheduled datetime');
    end;

    [Test]
    procedure TestGetNextScheduledReplicationTomorrow()
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
        TodayDateTime: DateTime;
        TodayTime: Time;
        NextScheduled: DateTime;
    begin
        // [GIVEN] The intelligent cloud is scheduled for Friday at 13:00
        Evaluate(TodayTime, '13:00');
        TodayDateTime := CreateDateTime(DMY2Date(09, 08, 2018), TodayTime);
        IntelligentCloudSetup.DeleteAll();
        IntelligentCloudSetup.Init();
        IntelligentCloudSetup.Recurrence := IntelligentCloudSetup.Recurrence::Weekly;
        IntelligentCloudSetup.Friday := true;
        IntelligentCloudSetup."Time to Run" := DT2Time(TodayDateTime);
        IntelligentCloudSetup.Insert();

        // [WHEN] The call to get the next scheduled run is made on Thursday at 13:00
        NextScheduled := IntelligentCloudSetup.GetNextScheduledRunDateTime(TodayDateTime);

        // [THEN] The next scheduled date time is returned as Friday at 13:00
        Assert.AreEqual(CreateDateTime(DMY2Date(10, 08, 2018), TodayTime), NextScheduled, 'Unexpected next scheduled datetime');
    end;

    [Test]
    procedure TestGetNextScheduledReplicationNextWeek()
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
        TodayDateTime: DateTime;
        TodayTime: Time;
        NextScheduled: DateTime;
    begin
        // [GIVEN] The intelligent cloud is scheduled for Sundays and Tuesdays at 13:00
        Evaluate(TodayTime, '13:00');
        TodayDateTime := CreateDateTime(DMY2Date(12, 08, 2018), TodayTime);
        IntelligentCloudSetup.DeleteAll();
        IntelligentCloudSetup.Init();
        IntelligentCloudSetup.Recurrence := IntelligentCloudSetup.Recurrence::Weekly;
        IntelligentCloudSetup.Tuesday := true;
        IntelligentCloudSetup.Sunday := true;
        IntelligentCloudSetup."Time to Run" := DT2Time(TodayDateTime);
        IntelligentCloudSetup.Insert();

        // [WHEN] The call to get the next scheduled run is made on Sunday at 13:01
        NextScheduled := IntelligentCloudSetup.GetNextScheduledRunDateTime(TodayDateTime + 60000);

        // [THEN] The next scheduled date time is returned as Tuesday at 13:00
        Assert.AreEqual(CreateDateTime(DMY2Date(14, 08, 2018), TodayTime), NextScheduled, 'Unexpected next scheduled datetime');
    end;

    [Test]
    procedure TestGetNextScheduledReplicationBeforeMidnight()
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
        TodayDateTime: DateTime;
        TodayTime: Time;
        NextScheduled: DateTime;
    begin
        // [GIVEN] The intelligent cloud is scheduled for Wednesdays at 23:59
        Evaluate(TodayTime, '23:50');
        TodayDateTime := CreateDateTime(DMY2Date(15, 08, 2018), TodayTime);
        IntelligentCloudSetup.DeleteAll();
        IntelligentCloudSetup.Init();
        IntelligentCloudSetup.Recurrence := IntelligentCloudSetup.Recurrence::Weekly;
        IntelligentCloudSetup.Wednesday := true;
        IntelligentCloudSetup."Time to Run" := DT2Time(TodayDateTime) + (9 * 60 * 1000); // 23:59
        IntelligentCloudSetup.Insert();

        // [WHEN] The call to get the next scheduled run is made on Wednesday at 23:50
        NextScheduled := IntelligentCloudSetup.GetNextScheduledRunDateTime(TodayDateTime);

        // [THEN] The next scheduled date time is returned as Wednesday (today) at 23:59
        Assert.AreEqual(CreateDateTime(DMY2Date(15, 08, 2018), IntelligentCloudSetup."Time to Run"), NextScheduled, 'Unexpected next scheduled datetime');
    end;

    [Test]
    procedure TestGetNextScheduledReplicationAfterMidnight()
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
        TodayDateTime: DateTime;
        TodayTime: Time;
        NextScheduled: DateTime;
    begin
        // [GIVEN] The intelligent cloud is scheduled for Wednesdays at 23:59
        Evaluate(TodayTime, '00:00');
        TodayDateTime := CreateDateTime(DMY2Date(16, 08, 2018), TodayTime);
        IntelligentCloudSetup.DeleteAll();
        IntelligentCloudSetup.Init();
        IntelligentCloudSetup.Recurrence := IntelligentCloudSetup.Recurrence::Weekly;
        IntelligentCloudSetup.Wednesday := true;
        IntelligentCloudSetup."Time to Run" := DT2Time(TodayDateTime - 60000); // 23:59
        IntelligentCloudSetup.Insert();

        // [WHEN] The call to get the next scheduled run is made on Thursday at 00:00
        NextScheduled := IntelligentCloudSetup.GetNextScheduledRunDateTime(TodayDateTime);

        // [THEN] The next scheduled date time is returned as next Wednesday at 23:59
        Assert.AreEqual(CreateDateTime(DMY2Date(22, 08, 2018), IntelligentCloudSetup."Time to Run"), NextScheduled, 'Unexpected next scheduled datetime');
    end;

    [Test]
    procedure TestGetMessageText()
    var
        HybridMessageManagement: Codeunit "Hybrid Message Management";
        Message: Text;
        InnerMessage: Text;
    begin
        InnerMessage := 'Sample inner message';
        Message := HybridMessageManagement.ResolveMessageCode('INIT', InnerMessage);
        Assert.AreNotEqual('', Message, 'Message not resolved for INIT');
        Assert.AreNotEqual(InnerMessage, Message, 'Message not resolved for INIT');

        Message := HybridMessageManagement.ResolveMessageCode('Unknown', InnerMessage);
        Assert.AreEqual(InnerMessage, Message, 'Unresolved code should default to inner message.');
    end;

    [Test]
    procedure TestUpdateReplicationStatusUpdatesStatusForInProgressRecordsWhenSucceeded()
    var
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
        RunId: Text;
        Status: Text;
        Errors: Text;
    begin
        // [SCENARIO 291819] User can refresh the status of replication runs
        Initialize();
        RunId := CreateGuid();

        // [GIVEN] An in-progress record exists in the system
        HybridReplicationSummary.CreateInProgressRecord(RunId, HybridReplicationSummary.ReplicationType::Normal);

        // [GIVEN] The replication run has succeeded meanwhile
        Status := 'Succeeded';
        Errors := '[]';
        LibraryHybridManagement.SetExpectedStatus(Status, Errors);

        // [WHEN] The call to RefreshReplicationStatus is made
        HybridCloudManagement.RefreshReplicationStatus();

        // [THEN] The summary record gets updated with the new status
        HybridReplicationSummary.Get(RunId);
        Assert.AreEqual(HybridReplicationSummary.Status::Completed, HybridReplicationSummary.Status, 'Status not updated.');
        Assert.AreEqual('', HybridReplicationSummary.GetDetails(), 'Details should be empty.');
    end;

    [Test]
    procedure TestUpdateReplicationStatusUpdatesStatusForInProgressRecordsWhenFailed()
    var
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
        RunId: Text;
        Status: Text;
        Errors: Text;
    begin
        // [SCENARIO 291819] User can refresh the status of replication runs
        Initialize();
        RunId := CreateGuid();

        // [GIVEN] An in-progress record exists in the system
        HybridReplicationSummary.CreateInProgressRecord(RunId, HybridReplicationSummary.ReplicationType::Normal);

        // [GIVEN] The replication run has failed meanwhile
        Status := 'Failed';
        Errors := '"Small failure 1", "Big failure 2"';
        LibraryHybridManagement.SetExpectedStatus(Status, Errors);

        // [WHEN] The call to RefreshReplicationStatus is made
        HybridCloudManagement.RefreshReplicationStatus();

        // [THEN] The summary record gets updated with the new failed status
        HybridReplicationSummary.Get(RunId);
        Assert.AreEqual(HybridReplicationSummary.Status::Failed, HybridReplicationSummary.Status, 'Status not updated.');
        Assert.AreEqual('Small failure 1\Big failure 2', HybridReplicationSummary.GetDetails(), 'Details should be empty.');
    end;

    [Test]
    procedure CleanupNotificationDisablesMigrationAndInsertsSummary()
    var
        IntelligentCloud: Record "Intelligent Cloud";
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        Product: Text;
        IntelligentCloudExists: Boolean;
    begin
        // [GIVEN] Migration is enabled
        Initialize();
        Product := CopyStr(CreateGuid(), 1, 10);
        LibraryHybridManagement.ResetSourceProduct(Product);

        IntelligentCloudExists := IntelligentCloud.Get();
        IntelligentCloud.Enabled := true;
        if IntelligentCloudExists then
            IntelligentCloud.Modify()
        else
            IntelligentCloud.Insert();

        HybridReplicationSummary.DeleteAll();

        // [WHEN] A cleanup webhook notification arrives
        InsertNotification('IntelligentCloudService_' + Product, '{ "ServiceType": "TenantCleanedUp" }');

        // [THEN] Migration is disabled
        IntelligentCloud.Get();
        Assert.IsFalse(IntelligentCloud.Enabled, 'Intelligent cloud should have been disabled.');

        // [THEN] Replication summary record is inserted to indicate disablement
        HybridReplicationSummary.FindFirst();
        Assert.AreEqual(Product, HybridReplicationSummary.Source, 'Unexpected source');
    end;

    local procedure InsertNotification(SubscriptionID: Text[50]; Body: Text)
    var
        WebhookNotification: Record "Webhook Notification";
        NotificationOutStream: OutStream;
    begin
        WebhookNotification.Init();
        WebhookNotification."Subscription ID" := SubscriptionID;
        WebhookNotification.Notification.CreateOutStream(NotificationOutStream);
        NotificationOutStream.WriteText(Body);
        WebhookNotification.Insert();
    end;
}