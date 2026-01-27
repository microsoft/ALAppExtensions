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
        CustomerId1Tok: Label 'TEST-1', Locked = true;
        CustomerId2Tok: Label 'TEST-2', Locked = true;

    local procedure Initialize()
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
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
        IntelligentCloudSetup.DeleteAll();
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
        DetailsText: Text;
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
        DetailsText := HybridReplicationSummary.GetDetails();
        Assert.IsTrue(DetailsText.Contains('Failure 1\Failure 2'), 'Incorrect value parsed for "Details".');
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
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
        RunId: Text;
        Status: Text;
        Errors: Text;
    begin
        // [SCENARIO 291819] User can refresh the status of replication runs
        Initialize();
        RunId := CreateGuid();

        IntelligentCloudSetup.Insert();

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
    end;

    [Test]
    procedure TestUpdateReplicationStatusUpdatesStatusForInProgressRecordsWhenFailed()
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
        RunId: Text;
        Status: Text;
        Errors: Text;
    begin
        // [SCENARIO 291819] User can refresh the status of replication runs
        Initialize();
        RunId := CreateGuid();
        IntelligentCloudSetup.Insert();

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

    [Test]
    procedure TestIncludingTableInReplication()
    var
        IntelligentCloudStatus: Record "Intelligent Cloud Status";
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
        CloudMigSelectTables: TestPage "Cloud Mig - Select Tables";
    begin
        Initialize();

        // [GIVEN] The intelligent cloud is enabled
        LibraryHybridManagement.SetCanModifyDataReplicationRules(true);
        HybridCloudManagement.RefreshIntelligentCloudStatusTable();

        // [WHEN] User opens the cloud migration select tables page and selects a table to be replicated
        OpenCloudMigSelectTablesPage(CloudMigSelectTables);

#pragma warning disable AA0210
        IntelligentCloudStatus.SetRange("Replicate Data", false);
#pragma warning restore AA0210
        IntelligentCloudStatus.FindFirst();
        CloudMigSelectTables.Filter.SetFilter("Table Id", Format(IntelligentCloudStatus."Table Id"));
        CloudMigSelectTables.IncludeTablesInMigration.Invoke();

        // [THEN] The table is marked as included in replication and log is inserted
        VerifyReplicateDataProperty(CloudMigSelectTables, true, IntelligentCloudStatus."Table Id");

        // [WHEN] User invokes reset to default
        CloudMigSelectTables.ResetToDefault.Invoke();

        // [THEN] The table is marked as excluded from replication
        VerifyReplicateDataProperty(CloudMigSelectTables, false, IntelligentCloudStatus."Table Id");
    end;

    [Test]
    procedure TestExcludingTableFromReplication()
    var
        IntelligentCloudStatus: Record "Intelligent Cloud Status";
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
        CloudMigSelectTables: TestPage "Cloud Mig - Select Tables";
    begin
        Initialize();

        // [GIVEN] The intelligent cloud is enabled
        LibraryHybridManagement.SetCanModifyDataReplicationRules(true);
        HybridCloudManagement.RefreshIntelligentCloudStatusTable();

        // [WHEN] User opens the cloud migration select tables page and selects a table to be replicated
        OpenCloudMigSelectTablesPage(CloudMigSelectTables);

#pragma warning disable AA0210
        IntelligentCloudStatus.SetRange("Replicate Data", true);
#pragma warning restore AA0210
        IntelligentCloudStatus.FindFirst();
        CloudMigSelectTables.Filter.SetFilter("Table Id", Format(IntelligentCloudStatus."Table Id"));
        CloudMigSelectTables.ExcludeTablesFromMigration.Invoke();

        // [THEN] The table is marked as included in replication and log is inserted
        VerifyReplicateDataProperty(CloudMigSelectTables, false, IntelligentCloudStatus."Table Id");

        // [WHEN] User invokes reset to default
        CloudMigSelectTables.ResetToDefault.Invoke();

        // [THEN] The table is marked as excluded from replication
        VerifyReplicateDataProperty(CloudMigSelectTables, true, IntelligentCloudStatus."Table Id");
    end;

    [Test]
    procedure TestSettingTableToDeltaSync()
    var
        IntelligentCloudStatus: Record "Intelligent Cloud Status";
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
        CloudMigSelectTables: TestPage "Cloud Mig - Select Tables";
    begin
        Initialize();

        // [GIVEN] The intelligent cloud is enabled
        LibraryHybridManagement.SetCanModifyDataReplicationRules(true);
        HybridCloudManagement.RefreshIntelligentCloudStatusTable();

        // [WHEN] User opens the cloud migration select tables page and selects a table to be delta synced
#pragma warning disable AA0210
        IntelligentCloudStatus.SetRange("Company Name", '');
        IntelligentCloudStatus.SetRange("Preserve Cloud Data", false);
#pragma warning restore AA0210
        if not IntelligentCloudStatus.FindFirst() then begin
            IntelligentCloudStatus.SetRange("Preserve Cloud Data");
            IntelligentCloudStatus.FindFirst();
            IntelligentCloudStatus."Preserve Cloud Data" := false;
            IntelligentCloudStatus.Modify();
        end;

        OpenCloudMigSelectTablesPage(CloudMigSelectTables);
        CloudMigSelectTables.Filter.SetFilter("Table Id", Format(IntelligentCloudStatus."Table Id"));
        CloudMigSelectTables.DeltaSyncTables.Invoke();

        // [THEN] The table is marked as delta sync data in replication and log is inserted
        VerifyDeltaSyncProperty(CloudMigSelectTables, true, IntelligentCloudStatus."Table Id");
    end;

    [Test]
    procedure TestSettingToReplaceTableData()
    var
        IntelligentCloudStatus: Record "Intelligent Cloud Status";
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
        CloudMigSelectTables: TestPage "Cloud Mig - Select Tables";
    begin
        Initialize();

        // [GIVEN] The intelligent cloud is enabled
        LibraryHybridManagement.SetCanModifyDataReplicationRules(true);
        HybridCloudManagement.RefreshIntelligentCloudStatusTable();

        // [WHEN] User opens the cloud migration select tables page and selects a table to be replicated
        OpenCloudMigSelectTablesPage(CloudMigSelectTables);
#pragma warning disable AA0210
        IntelligentCloudStatus.SetRange("Preserve Cloud Data", true);
#pragma warning restore AA0210
        IntelligentCloudStatus.FindFirst();
        CloudMigSelectTables.Filter.SetFilter("Table Id", Format(IntelligentCloudStatus."Table Id"));
        CloudMigSelectTables.ReplaceSyncTables.Invoke();

        // [THEN] The table is marked as included in replication and log is inserted
        VerifyDeltaSyncProperty(CloudMigSelectTables, false, IntelligentCloudStatus."Table Id");

        // [WHEN] User invokes reset to default
        CloudMigSelectTables.ResetToDefault.Invoke();

        // [THEN] The table is marked as excluded from replication
        VerifyDeltaSyncProperty(CloudMigSelectTables, true, IntelligentCloudStatus."Table Id");
    end;

    [Test]
    procedure TestMigrateRecordLinksNoMappings()
    var
        ReplicationRecordLinkBuffer: Record "Replication Record Link Buffer";
        RecordLink: Record "Record Link";
        RecordLinkMapping: Record "Record Link Mapping";
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
        RecordLinkCount: Integer;
        ReplicationRecordLinkBufferCount: Integer;
    begin
        // [GIVEN] Setup buffer with sample data
        ReplicationRecordLinkBuffer.DeleteAll();
        RecordLink.DeleteAll();
        RecordLinkMapping.DeleteAll();
        CreateReplicationRecordLinkBuffers();
        CreateRecordLinks();
        RecordLinkCount := RecordLink.Count();
        ReplicationRecordLinkBufferCount := ReplicationRecordLinkBuffer.Count();

        // [WHEN] Call migration
        HybridCloudManagement.MigrateRecordLinks();

        // [THEN] Record link and Record link mapping should be created
        Assert.AreEqual(RecordLinkCount + ReplicationRecordLinkBufferCount, RecordLink.Count(), 'Record links not created');
        Assert.AreEqual(ReplicationRecordLinkBufferCount, RecordLinkMapping.Count(), 'Record link mappings not created');
        RecordLinkMapping.FindSet();
        repeat
            ReplicationRecordLinkBuffer.Get(RecordLinkMapping."Source ID", RecordLinkMapping.Company);
            RecordLink.Get(RecordLinkMapping."Target ID");
            VerifyRecordLink(ReplicationRecordLinkBuffer, RecordLink);
        until RecordLinkMapping.Next() = 0;
    end;

    [Test]
    procedure TestMigrateRecordLinksExistingMappings()
    var
        ReplicationRecordLinkBuffer: Record "Replication Record Link Buffer";
        RecordLink: Record "Record Link";
        RecordLinkMapping: Record "Record Link Mapping";
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
        RecordLinkCount: Integer;
        ReplicationRecordLinkBufferCount: Integer;
        RecordLinkMappingCount: Integer;
    begin
        // [GIVEN] Setup buffer with sample data
        ReplicationRecordLinkBuffer.DeleteAll();
        RecordLink.DeleteAll();
        RecordLinkMapping.DeleteAll();
        CreateReplicationRecordLinkBuffers();
        CreateRecordLinks();
        ReplicationRecordLinkBuffer.FindLast();
        RecordLink.FindLast();
        CreateRecordLinkMapping(ReplicationRecordLinkBuffer, RecordLink);
        RecordLinkCount := RecordLink.Count();
        ReplicationRecordLinkBufferCount := ReplicationRecordLinkBuffer.Count();
        RecordLinkMappingCount := RecordLinkMapping.Count();

        // [WHEN] Call migration
        HybridCloudManagement.MigrateRecordLinks();

        // [THEN] Record link and Record link mapping should be created
        Assert.AreEqual(RecordLinkCount + ReplicationRecordLinkBufferCount - RecordLinkMappingCount, RecordLink.Count(), 'Record links not created');
        Assert.AreEqual(ReplicationRecordLinkBufferCount, RecordLinkMapping.Count(), 'Record link mappings not created');
        RecordLinkMapping.FindSet();
        repeat
            ReplicationRecordLinkBuffer.Get(RecordLinkMapping."Source ID", RecordLinkMapping.Company);
            RecordLink.Get(RecordLinkMapping."Target ID");
            VerifyRecordLink(ReplicationRecordLinkBuffer, RecordLink);
        until RecordLinkMapping.Next() = 0;
    end;

    [Test]
    procedure TestMigrateRecordLinksDataTransfer()
    var
        ReplicationRecordLinkBuffer: Record "Replication Record Link Buffer";
        RecordLink: Record "Record Link";
        RecordLinkMapping: Record "Record Link Mapping";
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
        ReplicationRecordLinkBufferCount: Integer;
    begin
        // [GIVEN] Setup buffer with sample data
        LibraryHybridManagement.SetAdlMigrationEnabled(true);
        ReplicationRecordLinkBuffer.DeleteAll();
        RecordLink.DeleteAll();
        RecordLinkMapping.DeleteAll();
        CreateReplicationRecordLinkBuffers();
        ReplicationRecordLinkBufferCount := ReplicationRecordLinkBuffer.Count();

        // [WHEN] Call migration
        HybridCloudManagement.MigrateRecordLinks();

        // [THEN] Record link and Record link mapping should be created
        Assert.AreEqual(ReplicationRecordLinkBufferCount, RecordLink.Count(), 'Record links not created');
        Assert.AreEqual(ReplicationRecordLinkBufferCount, RecordLinkMapping.Count(), 'Record link mappings not created');
        RecordLinkMapping.FindSet();
        repeat
            ReplicationRecordLinkBuffer.Get(RecordLinkMapping."Source ID", RecordLinkMapping.Company);
            RecordLink.Get(RecordLinkMapping."Target ID");
            VerifyRecordLink(ReplicationRecordLinkBuffer, RecordLink);
        until RecordLinkMapping.Next() = 0;
    end;

    [Test]
    procedure TestMigrateRecordLinksCompanyStatus()
    var
        ReplicationRecordLinkBuffer: Record "Replication Record Link Buffer";
        RecordLink: Record "Record Link";
        RecordLinkMapping: Record "Record Link Mapping";
        HybridCompanyStatus: Record "Hybrid Company Status";
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
    begin
        // [GIVEN] Setup buffer with sample data
        ReplicationRecordLinkBuffer.DeleteAll();
        RecordLink.DeleteAll();
        RecordLinkMapping.DeleteAll();
        CreateReplicationRecordLinkBuffers();
        CreateRecordLinks();

        // [WHEN] Call migration
        HybridCloudManagement.MigrateRecordLinks();

        // [THEN] Company status is updated
        HybridCompanyStatus.Get();
        Assert.IsTrue(HybridCompanyStatus."Record Link Move Completed", 'Record links migration status not updated');
    end;

    [Test]
    procedure TestMigrationValidation()
    var
        MigrationValidationError: Record "Migration Validation Error";
        Customer: Record Customer;
        HybridCompanyStatus: Record "Hybrid Company Status";
        MigrationValidation: Codeunit "Migration Validation";
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
        DataCreationFailed: Boolean;
    begin
        // [GIVEN] A company migration is being validated
        InitMigrationValidationTests();

        DataCreationFailed := false;

        // [WHEN] No customers were migrated, but were expected
        MigrationValidation.StartMigrationValidationImp(DataCreationFailed);

        // [THEN] The migration will fail, and there will be corresponding validation error entries
        HybridCompanyStatus.Get(CompanyName());
        Assert.IsTrue(HybridCompanyStatus.Validated, 'The company should have been validated.');
        Assert.RecordCount(MigrationValidationError, 1);
        MigrationValidationError.FindFirst();
        Assert.AreEqual('Missing TEST-1', MigrationValidationError."Test Description", 'Incorrect test description');
        Assert.AreEqual(false, MigrationValidationError."Is Warning", 'Incorrect value for Is Warning');
        Assert.IsTrue(DataCreationFailed, 'The migration should be in a failed state.');

        // Reset
        DataCreationFailed := false;
        MigrationValidation.DeleteMigrationValidationEntriesForCompany();

        // [WHEN] Some of the customers were created
        // Create Customer TEST-1
        InitMigrationValidationTest_CustomerTest1();
        MigrationValidation.StartMigrationValidationImp(DataCreationFailed);

        // [THEN] The migration will fail, and there will be corresponding validation error entries
        Assert.IsTrue(DataCreationFailed, 'The migration should be in a failed state.');
        Assert.RecordCount(MigrationValidationError, 1);
        MigrationValidationError.FindFirst();
        Assert.AreEqual('Missing TEST-2', MigrationValidationError."Test Description", 'Incorrect test description');
        Assert.AreEqual(false, MigrationValidationError."Is Warning", 'Incorrect value for Is Warning');

        // Reset
        DataCreationFailed := false;
        MigrationValidation.DeleteMigrationValidationEntriesForCompany();

        // [WHEN] All the customers were created and correct
        InitMigrationValidationTest_CustomerTest1();
        InitMigrationValidationTest_CustomerTest2();

        // [THEN] No validation progress should be recorded for either Customers.
        // Note: The source table will normally be the staging table, but for testing the Customer table is sufficient
        Assert.IsFalse(CustomerHasNotBeenValidated(CustomerId1Tok), 'Customer 1 should not have validation progress recorded.');
        Assert.IsFalse(CustomerHasNotBeenValidated(CustomerId2Tok), 'Customer 2 should not have validation progress recorded.');

        MigrationValidation.StartMigrationValidationImp(DataCreationFailed);

        // [THEN] The migration will be successful, and there won't be any validation error entries
        Assert.IsFalse(DataCreationFailed, 'The migration should be in a failed state.');
        Assert.RecordCount(MigrationValidationError, 0);

        // [THEN] Validation progress will be recorded for both Customers.
        // Note: The source table will normally be the staging table, but for testing the Customer table is sufficient
        Assert.IsTrue(CustomerHasNotBeenValidated(CustomerId1Tok), 'Customer 1 should have validation progress recorded.');
        Assert.IsTrue(CustomerHasNotBeenValidated(CustomerId2Tok), 'Customer 2 should have validation progress recorded.');

        // Reset
        DataCreationFailed := false;
        MigrationValidation.DeleteMigrationValidationEntriesForCompany();

        // [WHEN] Some values are unexpected
        Customer.GET(CustomerId1Tok);
        Customer.Name := 'Wrong name';
        Customer."Name 2" := 'Wrong name 2';
        Customer.Modify();

        MigrationValidation.StartMigrationValidationImp(DataCreationFailed);

        // [TEST] The correct validation error records will be added
        // The migration will be in a failed state because there is an entry that isn't a warning
        Assert.RecordCount(MigrationValidationError, 2);
        Assert.IsTrue(DataCreationFailed, 'The migration should be in a failed state.');

        MigrationValidationError.FindSet();
        Assert.AreEqual('Name', MigrationValidationError."Test Description", 'Incorrect test description');
        Assert.AreEqual('Test 1', MigrationValidationError.Expected, 'Incorrect Expected value');
        Assert.AreEqual('Wrong name', MigrationValidationError.Actual, 'Incorrect Actual value');
        Assert.AreEqual(false, MigrationValidationError."Is Warning", 'Incorrect value for Is Warning');

        MigrationValidationError.Next();
        Assert.AreEqual('Name 2', MigrationValidationError."Test Description", 'Incorrect test description');
        Assert.AreEqual('Test name 2', MigrationValidationError.Expected, 'Incorrect Expected value');
        Assert.AreEqual('Wrong name 2', MigrationValidationError.Actual, 'Incorrect Actual value');
        Assert.AreEqual(true, MigrationValidationError."Is Warning", 'Incorrect value for Is Warning');

        // Reset
        DataCreationFailed := false;
        MigrationValidation.DeleteMigrationValidationEntriesForCompany();

        // [WHEN] Some values are unexpected, but nothing considered major
        Customer.GET(CustomerId1Tok);
        Customer.Name := 'Test 1'; // Back to expected value
        Customer."Name 2" := 'Wrong name 2';
        Customer.Modify();

        // [THEN] The migration should NOT be in a failed state
        MigrationValidation.StartMigrationValidationImp(DataCreationFailed);
        Assert.RecordCount(MigrationValidationError, 1);
        Assert.IsFalse(DataCreationFailed, 'The migration should NOT be in a failed state.');
    end;

    local procedure CustomerHasNotBeenValidated(CustomerNo: Code[20]): Boolean
    var
        Customer: Record Customer;
        MigrationValidationAssert: Codeunit "Migration Validation Assert";
        MockMigrationValidator: Codeunit "Mock Migration Validator";
    begin
        // The source table will normally be the staging table, but for testing the Customer table is sufficient
        if Customer.Get(CustomerNo) then
            exit(MigrationValidationAssert.IsSourceRowValidated(MockMigrationValidator.GetValidatorCode(), Customer));
    end;

    local procedure InitMigrationValidationTests()
    var
        MigrationValidatorRegistry: Record "Migration Validator Registry";
        MigrationValidationError: Record "Migration Validation Error";
        DataMigrationStatus: Record "Data Migration Status";
        HybridCompany: Record "Hybrid Company";
        HybridCompanyStatus: Record "Hybrid Company Status";
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
        MockMigrationValidator: Codeunit "Mock Migration Validator";
        ValidatorCode: Code[20];
        MigrationType: Text[250];
        ValidatorCodeunitId: Integer;
    begin
        ValidatorCode := MockMigrationValidator.GetValidatorCode();
        ValidatorCodeunitId := Codeunit::"Mock Migration Validator";

        if not IntelligentCloudSetup.Get() then begin
            IntelligentCloudSetup."Product ID" := GetDefaultTestMigrationType();
            IntelligentCloudSetup.Insert();
        end;

        MigrationType := IntelligentCloudSetup."Product ID";

        if not DataMigrationStatus.IsEmpty() then
            DataMigrationStatus.DeleteAll();

        if not MigrationValidationError.IsEmpty() then
            MigrationValidationError.DeleteAll();

        if not MigrationValidatorRegistry.IsEmpty() then
            MigrationValidatorRegistry.DeleteAll();

        if not MigrationValidatorRegistry.Get(ValidatorCode) then begin
            MigrationValidatorRegistry.Validate("Validator Code", ValidatorCode);
            MigrationValidatorRegistry.Validate("Migration Type", MigrationType);
            MigrationValidatorRegistry.Validate("Codeunit Id", ValidatorCodeunitId);
            MigrationValidatorRegistry.Insert();
        end;

        if not HybridCompany.Get(CompanyName()) then begin
            HybridCompany.Name := CopyStr(CompanyName(), 1, MaxStrLen(HybridCompany.Name));
            HybridCompany.Insert();
        end;

        if not HybridCompanyStatus.Get(CompanyName()) then begin
            HybridCompanyStatus.Name := CopyStr(CompanyName(), 1, MaxStrLen(HybridCompanyStatus.Name));
            HybridCompanyStatus.Insert();
        end;

        HybridCompanyStatus.Validated := false;
        HybridCompany.Modify();

        Clear(DataMigrationStatus);
        DataMigrationStatus."Migration Type" := IntelligentCloudSetup."Product ID";
        DataMigrationStatus.Status := DataMigrationStatus.Status::"In Progress";
        DataMigrationStatus.Insert(true);

        MockMigrationValidator.OnPrepareMigrationValidation(MigrationType);
    end;

    local procedure InitMigrationValidationTest_CustomerTest1()
    var
        Customer: Record Customer;
    begin
        if not Customer.Get(CustomerId1Tok) then begin
            Customer."No." := CustomerId1Tok;
            Customer.Name := 'Test 1';
            Customer."Name 2" := 'Test name 2';
            Customer.Insert();
        end;
    end;

    local procedure InitMigrationValidationTest_CustomerTest2()
    var
        Customer: Record Customer;
    begin
        if not Customer.Get(CustomerId2Tok) then begin
            Customer."No." := CustomerId2Tok;
            Customer.Name := 'Test 2';
            Customer."Name 2" := 'Test name 2';
            Customer.Insert();
        end;
    end;

    local procedure GetDefaultTestMigrationType(): Code[20]
    begin
        exit('TEST');
    end;

    local procedure OpenCloudMigSelectTablesPage(var CloudMigSelectTables: TestPage "Cloud Mig - Select Tables")
    var
        IntelligentCloudStatus: Record "Intelligent Cloud Status";
        CloudMigReplicateDataManagement: Codeunit "Cloud Mig. Replicate Data Mgt.";
    begin
        CloudMigSelectTables.Trap();
        CloudMigReplicateDataManagement.LoadRecords(IntelligentCloudStatus);
        Page.Run(Page::"Cloud Mig - Select Tables", IntelligentCloudStatus);
    end;

    local procedure VerifyReplicateDataProperty(var CloudMigSelectTables: TestPage "Cloud Mig - Select Tables"; ExpectedReplicateProperty: Boolean; SelectedTableId: Integer)
    var
        CloudMigOverrideLog: Record "Cloud Migration Override Log";
        IntelligentCloudStatus: Record "Intelligent Cloud Status";
    begin
        // [THEN] The table is marked as included in replication
        Assert.AreEqual(ExpectedReplicateProperty, CloudMigSelectTables."Replicate Data".AsBoolean(), 'Table was not correctly marked for replication');

        // [THEN] The log table is created and main intelligent cloud status table is updated
        Assert.IsTrue(IntelligentCloudStatus.Get(CloudMigSelectTables."Table Name".Value, CloudMigSelectTables."Company Name".Value), 'Intelligent cloud status record not found');
        Assert.AreEqual(ExpectedReplicateProperty, IntelligentCloudStatus."Replicate Data", 'Intelligent cloud status record not updated correctly');
        Assert.IsTrue(CloudMigOverrideLog.FindLast(), 'Cloud migration override log record not found');
        Assert.AreEqual(CloudMigOverrideLog."Table Id", SelectedTableId, 'Cloud migration override log record not updated correctly');
        Assert.AreEqual(ExpectedReplicateProperty, CloudMigOverrideLog."Replicate Data", 'Cloud migration override log record not updated correctly');
    end;

    local procedure VerifyDeltaSyncProperty(var CloudMigSelectTables: TestPage "Cloud Mig - Select Tables"; ExpectedDeltaSyncProperty: Boolean; SelectedTableId: Integer)
    var
        CloudMigOverrideLog: Record "Cloud Migration Override Log";
        IntelligentCloudStatus: Record "Intelligent Cloud Status";
    begin
        // [THEN] The table is marked as included in replication
        Assert.AreEqual(ExpectedDeltaSyncProperty, CloudMigSelectTables."Preserve Cloud Data".AsBoolean(), 'Table was not correctly marked for delta sync');

        // [THEN] The log table is created and main intelligent cloud status table is updated
        Assert.IsTrue(IntelligentCloudStatus.Get(CloudMigSelectTables."Table Name".Value, CloudMigSelectTables."Company Name".Value), 'Intelligent cloud status record not found');
        Assert.AreEqual(ExpectedDeltaSyncProperty, IntelligentCloudStatus."Preserve Cloud Data", 'Intelligent cloud status record not updated correctly');
        Assert.IsTrue(CloudMigOverrideLog.FindLast(), 'Cloud migration override log record not found');
        Assert.AreEqual(SelectedTableId, CloudMigOverrideLog."Table Id", 'Cloud migration override log record not updated correctly');
        Assert.AreEqual(ExpectedDeltaSyncProperty, CloudMigOverrideLog."Preserve Cloud Data", 'Cloud migration override log record not updated correctly');
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

    local procedure CreateReplicationRecordLinkBuffers()
    var
        ReplicationRecordLinkBuffer: Record "Replication Record Link Buffer";
        i: Integer;
        OutStream: OutStream;
    begin
        for i := 1 to 10 do begin
            ReplicationRecordLinkBuffer."Link ID" := i;
            ReplicationRecordLinkBuffer.Company := CopyStr(CompanyName(), 1, MaxStrLen(ReplicationRecordLinkBuffer.Company));
            ReplicationRecordLinkBuffer.Description := 'record link buffer description' + Format(i);
            if i mod 2 = 0 then begin
                ReplicationRecordLinkBuffer.Type := ReplicationRecordLinkBuffer.Type::Link;
                ReplicationRecordLinkBuffer.URL1 := 'buffertest' + Format(i) + '.com';
            end else begin
                ReplicationRecordLinkBuffer.Type := ReplicationRecordLinkBuffer.Type::Note;
                ReplicationRecordLinkBuffer.Note.CreateOutStream(OutStream);
                OutStream.Write('buffer note' + Format(i));
            end;
            ReplicationRecordLinkBuffer.Insert();
        end;
    end;

    local procedure CreateRecordLinks()
    var
        RecordLink: Record "Record Link";
        RecordLinkManagement: Codeunit "Record Link Management";
        i: Integer;
    begin
        for i := 1 to 2 do begin
            RecordLink."Link ID" := i;
            RecordLink.Company := CopyStr(CompanyName(), 1, MaxStrLen(RecordLink.Company));
            RecordLink.Description := 'record link description' + Format(i);
            if i mod 2 = 0 then begin
                RecordLink.Type := RecordLink.Type::Link;
                RecordLink.URL1 := 'recordlinktest' + Format(i) + '.com';
            end else begin
                RecordLink.Type := RecordLink.Type::Note;
                RecordLinkManagement.WriteNote(RecordLink, 'recordlinknote' + Format(i));
            end;
            RecordLink.Insert();
        end;
    end;

    local procedure CreateRecordLinkMapping(ReplicationRecordLinkBuffer: Record "Replication Record Link Buffer"; RecordLink: Record "Record Link")
    var
        RecordLinkMapping: Record "Record Link Mapping";
    begin
        RecordLinkMapping."Source ID" := ReplicationRecordLinkBuffer."Link ID";
        RecordLinkMapping."Target ID" := RecordLink."Link ID";
        RecordLinkMapping.Company := ReplicationRecordLinkBuffer.Company;
        RecordLinkMapping.Insert();
    end;

    local procedure VerifyRecordLink(ReplicationRecordLinkBuffer: Record "Replication Record Link Buffer"; RecordLink: Record "Record Link")
    begin
        Assert.AreEqual(ReplicationRecordLinkBuffer."Record ID", RecordLink."Record ID", 'Record ID mismatch');
        Assert.AreEqual(ReplicationRecordLinkBuffer.URL1, RecordLink.URL1, 'URL1 mismatch');
        Assert.AreEqual(ReplicationRecordLinkBuffer.Description, RecordLink.Description, 'Description mismatch');
        Assert.AreEqual(ReplicationRecordLinkBuffer.Type, RecordLink.Type, 'Type mismatch');
        Assert.AreEqual(ReplicationRecordLinkBuffer.Created, RecordLink.Created, 'Created mismatch');
        Assert.AreEqual(ReplicationRecordLinkBuffer."User ID", RecordLink."User ID", 'User ID mismatch');
        Assert.AreEqual(ReplicationRecordLinkBuffer.Company, RecordLink.Company, 'Company mismatch');
        Assert.AreEqual(ReplicationRecordLinkBuffer.Notify, RecordLink.Notify, 'Notify mismatch');
        Assert.AreEqual(ReplicationRecordLinkBuffer."To User ID", RecordLink."To User ID", 'To User ID mismatch');
        Assert.AreEqual(ReadReplicationRecordLinkBufferNote(ReplicationRecordLinkBuffer), ReadRecordLinkNote(RecordLink), 'Note mismatch');
    end;

    local procedure ReadReplicationRecordLinkBufferNote(ReplicationRecordLinkBuffer: Record "Replication Record Link Buffer") Result: Text
    var
        InStream: InStream;
    begin
        ReplicationRecordLinkBuffer.CalcFields(Note);
        ReplicationRecordLinkBuffer.Note.CreateInStream(InStream);
        InStream.Read(Result);
    end;

    local procedure ReadRecordLinkNote(RecordLink: Record "Record Link") Result: Text
    var
        InStream: InStream;
    begin
        RecordLink.CalcFields(Note);
        RecordLink.Note.CreateInStream(InStream);
        InStream.Read(Result);
    end;
}