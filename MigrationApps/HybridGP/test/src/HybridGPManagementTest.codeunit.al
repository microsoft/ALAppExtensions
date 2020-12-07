codeunit 139660 "HybridGP Management Test"
{
    // [FEATURE] [Intelligent Edge Hybrid GP Wizard]
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        LibraryHybridManagement: Codeunit "Library - Hybrid Management";
        SubscriptionIdTxt: Label 'DynamicsGP_IntelligentCloud';

    [Test]
    procedure InsertSummaryOnWebhookNotificationInsert()
    var
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        HybridBCWizard: Codeunit "Hybrid GP Wizard";
        RunId: Text;
        StartTime: DateTime;
        TriggerType: Text;
    begin
        // [GIVEN] A Webhook Subscription exists for DynamicsGP
        Initialize();

        // [WHEN] A notification record is inserted
        TriggerType := 'Scheduled';
        InsertNotification(RunId, StartTime, TriggerType);

        // [THEN] A Hybrid Replication Summary record is created
        HybridReplicationSummary.Get(RunId);
        with HybridReplicationSummary do begin
            Assert.AreEqual(Source, HybridBCWizard.ProductName(), 'Unexpected value in summary for source.');
            Assert.AreEqual("Run ID", RunId, 'Unexpected value in summary for Run ID.');
            Assert.AreEqual("Start Time", StartTime, 'Unexpected value in summary for Start Time.');
            Assert.AreEqual("Trigger Type", "Trigger Type"::Scheduled, 'Unexpected value in summary for Trigger Type.');
        end;
    end;

    [Test]
    procedure InsertDetailsOnWebhookNotificationInsert()
    var
        HybridReplicationDetail: Record "Hybrid Replication Detail";
        RunId: Text;
        StartTime: DateTime;
        TriggerType: Text;
    begin
        // [GIVEN] A Webhook Subscription exists for DynamicsGP
        Initialize();

        // [WHEN] A notification record is inserted
        InsertNotification(RunId, StartTime, TriggerType);

        // [THEN] The correct Hybrid Replication Detail records are created.
        with HybridReplicationDetail do begin
            SetRange("Run ID", RunId);
            Assert.AreEqual(3, Count(), 'Unexpected number of detail records.');
            Get(RunId, 'GPDAT$GP Item$feeb3504-556e-4790-b28d-a2b9ce302d81', CompanyName());
            Assert.IsTrue("Error Message" = '', 'Successful table should not report errors.');
            Assert.AreEqual(Status::Successful, Status, 'Successful table should have success status.');

            Get(RunId, 'Bad Table', CompanyName());
            Assert.IsFalse("Error Message" = '', 'Failed table should report errors.');
            Assert.AreEqual('1337', "Error Code", 'Incorrectly parsed error code.');
            Assert.AreEqual(Status::Failed, Status, 'Failed table should have failed status.');

            Get(RunId, 'Bad Table, Errors Array', CompanyName());
            Assert.AreEqual('The table column ''New Column'' does not exist.', "Error Message", 'Incorrectly parsed error message');
            Assert.AreEqual('1000', "Error Code", 'Incorrectly parsed error code');
            Assert.AreEqual(Status::Failed, Status, 'Failed table should have failed status.');
        end;

    end;

    [Test]
    procedure TestGetHybridGPProductName()
    var
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
        HybridGPWizard: Codeunit "Hybrid GP Wizard";
        ProductName: Text;
    begin
        // [GIVEN] Dynamics GP is set up as the intelligent cloud product
        Initialize();

        // [WHEN] The GetChosenProductName method is called
        ProductName := HybridCloudManagement.GetChosenProductName();

        // [THEN] The returned value is set to the GP product name.
        Assert.AreEqual(HybridGPWizard.ProductName(), ProductName, 'Incorrect product name returned.');
    end;

    [Test]
    procedure TableMappingActionIsAvailable()
    var
        IntelligentCloudManagement: TestPage "Intelligent Cloud Management";
    begin
        // [SCENARIO] The "Manage Custom Tables" action is visible and enabled for GP migrations.

        // [GIVEN] Intelligent cloud is set up for GP
        Initialize();

        // [WHEN] The Intelligent Cloud Management page is launched
        IntelligentCloudManagement.Trap();
        Page.Run(Page::"Intelligent Cloud Management");

        // [THEN] The action to manage mapped tables is enabled and visible
        Assert.IsTrue(IntelligentCloudManagement.ManageCustomTables.Visible(), 'Map tables action is not visible');
        Assert.IsTrue(IntelligentcloudManagement.ManageCustomTables.Enabled(), 'Map tables action is not enabled');
    end;

    [Test]
    procedure DiagnosticRunActionIsAvailable()
    var
        IntelligentCloudManagement: TestPage "Intelligent Cloud Management";
    begin
        // [SCENARIO] The "Create Diagnostic Run" action is visible and enabled for GP migrations.

        // [GIVEN] Intelligent cloud is set up for GP
        Initialize();

        // [WHEN] The Intelligent Cloud Management page is launched
        IntelligentCloudManagement.Trap();
        Page.Run(Page::"Intelligent Cloud Management");

        // [THEN] The action to manage mapped tables is enabled and visible
        Assert.IsTrue(IntelligentCloudManagement.RunDiagnostic.Visible(), 'Diagnostic run action is not visible');
        Assert.IsTrue(IntelligentcloudManagement.RunDiagnostic.Enabled(), 'Diagnostic run action is not enabled');
    end;

    local procedure Initialize()
    var
        WebhookSubscription: Record "Webhook Subscription";
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
        HybridGPWizard: Codeunit "Hybrid GP Wizard";
        EnvironmentInfoTestLibrary: Codeunit "Environment Info Test Library";
        PermissionManager: Codeunit "Permission Manager";
    begin
        WebhookSubscription.DeleteAll();
        WebhookSubscription.Init();
        WebhookSubscription."Subscription ID" := COPYSTR(SubscriptionIdTxt, 1, 150);
        WebhookSubscription.Endpoint := 'Hybrid';
        WebhookSubscription.Insert();

        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);
        PermissionManager.SetTestabilityIntelligentCloud(true);

        if not IntelligentCloudSetup.Get() then
            IntelligentCloudSetup.Init();

        IntelligentCloudSetup."Product ID" := HybridGPWizard.ProductId();
        IF not IntelligentCloudSetup.Insert() then
            IntelligentCloudSetup.Modify();
    end;

    local procedure AdditionalNotificationText() Json: Text
    begin
        Json := ', "IncrementalTables": [' +
                            '{' +
                            '"TableName": "GPDAT$GP Item$feeb3504-556e-4790-b28d-a2b9ce302d81",' +
                            '"CompanyName": "' + CompanyName() + '",' +
                            '"$companyid": 0,' +
                            '"NewVersion": 742,' +
                            '"ErrorMessage": ""' +
                            '},' +
                            '{' +
                            '"TableName": "Bad Table",' +
                            '"CompanyName": "' + CompanyName() + '",' +
                            '"$companyid": 0,' +
                            '"NewVersion": 742,' +
                            '"ErrorCode": "1337",' +
                            '"ErrorMessage": "Failure processing data for Table = ''Bad Table''\\\\r\\\\n' +
                                        'Error message: Explicit value must be specified for identity column in table ''' +
                                        'CRONUS International Ltd_$Bad Table''."' +
                            '},' +
                            '{' +
                            '"TableName": "Bad Table, Errors Array",' +
                            '"CompanyName": "' + CompanyName() + '",' +
                            '"$companyid": 0,' +
                            '"NewVersion": 0,' +
                            '"Errors": [{"Code": 1000, "Message": "The table column ''New Column'' does not exist."}]' +
                            '}' +
                        ']';
    end;

    local procedure InsertNotification(var RunId: Text; var StartTime: DateTime; var TriggerType: Text)
    var
        WebhookNotification: Record "Webhook Notification";
        NotificationStream: OutStream;
        NotificationText: Text;
    begin
        NotificationText := LibraryHybridManagement.GetNotificationPayload(SubscriptionIdTxt, RunId, StartTime, TriggerType, AdditionalNotificationText());
        WebhookNotification.Init();
        WebhookNotification.ID := CreateGuid();
        WebhookNotification."Subscription ID" := CopyStr(SubscriptionIdTxt, 1, 150);
        WebhookNotification.Notification.CreateOutStream(NotificationStream, TextEncoding::UTF8);
        NotificationStream.WriteText(NotificationText);
        WebhookNotification.Insert(true);
    end;
}