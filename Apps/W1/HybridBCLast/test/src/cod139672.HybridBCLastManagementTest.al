codeunit 139672 "Hybrid BC Last Management Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        LibraryHybridBCLast: Codeunit "Library - Hybrid BC Last";
        IsInitialized: Boolean;

    [Test]
    procedure InsertSummaryOnWebhookNotificationInsert()
    var
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        HybridBCLastWizard: Codeunit "Hybrid BC Last Wizard";
        RunId: Text;
        StartTime: DateTime;
        TriggerType: Text;
        SyncedVersion: BigInteger;
    begin
        // [GIVEN] A Webhook Subscription exists for DynamicsBCLast
        Initialize();

        // [WHEN] A notification record is inserted
        TriggerType := 'Scheduled';
        SyncedVersion := 100;
        LibraryHybridBCLast.InsertNotification(RunId, StartTime, TriggerType, '', SyncedVersion);

        // [THEN] A Hybrid Replication Summary record is created
        HybridReplicationSummary.Get(RunId);
        with HybridReplicationSummary do begin
            Assert.AreEqual(Source, HybridBCLastWizard.ProductName(), 'Unexpected value in summary for source.');
            Assert.AreEqual("Run ID", RunId, 'Unexpected value in summary for Run ID.');
            Assert.AreEqual("Start Time", StartTime, 'Unexpected value in summary for Start Time.');
            Assert.AreEqual("Synced Version", SyncedVersion, 'Synced Version did not get set.');
            Assert.AreEqual("Trigger Type", "Trigger Type"::Scheduled, 'Unexpected value in summary for Replication Type.');
        end;
    end;

    [Test]
    procedure InsertSummaryWithDetailsOnWebhookNotificationInsert()
    var
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        HybridBCLastWizard: Codeunit "Hybrid BC Last Wizard";
        RunId: Text;
        StartTime: DateTime;
        TriggerType: Text;
        SyncedVersion: BigInteger;
    begin
        // [GIVEN] A Webhook Subscription exists for DynamicsBCLast
        Initialize();

        // [WHEN] A notification record is inserted
        TriggerType := 'Scheduled';
        SyncedVersion := 100;
        LibraryHybridBCLast.InsertNotification(RunId, StartTime, TriggerType, 'INIT', SyncedVersion);

        // [THEN] A Hybrid Replication Summary record is created
        HybridReplicationSummary.Get(RunId);
        with HybridReplicationSummary do begin
            Assert.AreEqual(Source, HybridBCLastWizard.ProductName(), 'Unexpected value in summary for source.');
            Assert.AreEqual("Run ID", RunId, 'Unexpected value in summary for Run ID.');
            Assert.AreEqual("Start Time", StartTime, 'Unexpected value in summary for Start Time.');
            Assert.AreEqual("Trigger Type", "Trigger Type"::Scheduled, 'Unexpected value in summary for Replication Type.');
            Assert.AreEqual("Synced Version", SyncedVersion, 'Synced Version did not get set.');
            Assert.IsTrue(Details.HasValue(), 'Details should contain text.');
        end;
    end;

    [Test]
    procedure TestGetHybridBCLastProductName()
    var
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
        HybridBCLastWizard: Codeunit "Hybrid BC Last Wizard";
        ProductName: Text;
    begin
        // [GIVEN] DynamicsBCLast is set up as the intelligent cloud product
        Initialize();

        // [WHEN] The GetChosenProductName method is called
        ProductName := HybridCloudManagement.GetChosenProductName();

        // [THEN] The returned value is set to the BC Last product name.
        Assert.AreEqual(HybridBCLastWizard.ProductName(), ProductName, 'Incorrect product name returned.');
    end;

    [Test]
    procedure VerifyGetMessageText()
    var
        HybridMessageManagement: Codeunit "Hybrid Message Management";
        Message: Text;
        InnerMessage: Text;
        i: Integer;
    begin
        Initialize();

        for i := 50001 to 50007 do begin
            Message := HybridMessageManagement.ResolveMessageCode(CopyStr(Format(i), 1, 10), '');
            Assert.AreNotEqual('', Message, 'No message provided for code ' + Format(i));

            if i in [50001, 50002, 50004, 50005, 50006, 50007] then begin
                InnerMessage := 'blah blah SqlErrorNumber=' + Format(i) + '; blah blah';
                Message := HybridMessageManagement.ResolveMessageCode('', InnerMessage);
                Assert.AreNotEqual('', Message, 'Unable to resolve sql error for code ' + Format(i));
                Assert.AreNotEqual(InnerMessage, Message, 'Unable to resolve sql error for code ' + Format(i));
            end;
        end;
    end;


    [Test]
    procedure GetSupportedUpgradeVersions()
    var
        W1Management: Codeunit "W1 Management";
        TargetVersions: List of [Decimal];
    begin
        // [SCENARIO] BCLast extension can handle upgrade paths independently
        // [GIVEN] Migration is set up with BC 14.0 as source
        Initialize(14.0);

        // [WHEN] A call to get upgrade versions is called
        W1Management.GetSupportedUpgradeVersions(TargetVersions);

        // [THEN] The 15.0, 16.0, 17.0, 18.0 , 19.0 and 20.0 target upgrade versions are returned
        Assert.IsTrue(TargetVersions.Contains(15.0), '15.0 not returned as target version');
        Assert.IsTrue(TargetVersions.Contains(16.0), '16.0 not returned as target version');
        Assert.IsTrue(TargetVersions.Contains(17.0), '17.0 not returned as target version');
        Assert.IsTrue(TargetVersions.Contains(18.0), '18.0 not returned as target version');
        Assert.IsTrue(TargetVersions.Contains(19.0), '19.0 not returned as target version');
        Assert.IsTrue(TargetVersions.Contains(20.0), '20.0 not returned as target version');
        Assert.AreEqual(6, TargetVersions.Count(), 'Incorrect number of target versions returned.');

        // [GIVEN] Migration is set up with BC 14.9 as source
        TargetVersions.RemoveRange(1, 6);
        Initialize(14.0);

        // [WHEN] A call to get upgrade versions is called
        W1Management.GetSupportedUpgradeVersions(TargetVersions);

        // [THEN] The 15.0, 16.0, 17.0, 18.0 , 19.0 and 20.0 target upgrade versions are returned
        Assert.IsTrue(TargetVersions.Contains(15.0), '15.0 not returned as target version');
        Assert.IsTrue(TargetVersions.Contains(16.0), '16.0 not returned as target version');
        Assert.IsTrue(TargetVersions.Contains(17.0), '17.0 not returned as target version');
        Assert.IsTrue(TargetVersions.Contains(18.0), '18.0 not returned as target version');
        Assert.IsTrue(TargetVersions.Contains(19.0), '19.0 not returned as target version');
        Assert.IsTrue(TargetVersions.Contains(20.0), '20.0 not returned as target version');
        Assert.AreEqual(6, TargetVersions.Count(), 'Incorrect number of target versions returned.');

        // [GIVEN] Migration is set up with BC 15.0 as source
        TargetVersions.RemoveRange(1, 6);
        Initialize(15.0);

        // [WHEN] A call to get upgrade versions is called
        W1Management.GetSupportedUpgradeVersions(TargetVersions);

        // [THEN] The 16.0, 17.0, 18.0 , 19.0 and 20.0 target upgrade versions are returned
        Assert.IsTrue(TargetVersions.Contains(16.0), '16.0 not returned as target version');
        Assert.IsTrue(TargetVersions.Contains(17.0), '17.0 not returned as target version');
        Assert.IsTrue(TargetVersions.Contains(18.0), '18.0 not returned as target version');
        Assert.IsTrue(TargetVersions.Contains(19.0), '19.0 not returned as target version');
        Assert.IsTrue(TargetVersions.Contains(20.0), '20.0 not returned as target version');
        Assert.AreEqual(5, TargetVersions.Count(), 'Incorrect number of target versions returned.');

        // [GIVEN] Migration is set up with BC 15.6 as source
        TargetVersions.RemoveRange(1, 5);
        Initialize(15.6);

        // [WHEN] A call to get upgrade versions is called
        W1Management.GetSupportedUpgradeVersions(TargetVersions);

        // [THEN] The 16.0, 17.0, 18.0 , 19.0 and 20.0 target upgrade versions are returned
        Assert.IsTrue(TargetVersions.Contains(16.0), '16.0 not returned as target version');
        Assert.IsTrue(TargetVersions.Contains(17.0), '17.0 not returned as target version');
        Assert.IsTrue(TargetVersions.Contains(18.0), '18.0 not returned as target version');
        Assert.IsTrue(TargetVersions.Contains(19.0), '19.0 not returned as target version');
        Assert.IsTrue(TargetVersions.Contains(20.0), '20.0 not returned as target version');
        Assert.AreEqual(5, TargetVersions.Count(), 'Incorrect number of target versions returned.');

        // [GIVEN] Migration is set up with BC 16.0 as source
        TargetVersions.RemoveRange(1, 5);
        Initialize(16.0);

        // [WHEN] A call to get upgrade versions is called
        W1Management.GetSupportedUpgradeVersions(TargetVersions);

        // [THEN] The 17.0, 18.0 , 19.0 and 20.0 target upgrade versions are returned
        Assert.IsTrue(TargetVersions.Contains(17.0), '17.0 not returned as target version');
        Assert.IsTrue(TargetVersions.Contains(18.0), '18.0 not returned as target version');
        Assert.IsTrue(TargetVersions.Contains(19.0), '19.0 not returned as target version');
        Assert.IsTrue(TargetVersions.Contains(20.0), '20.0 not returned as target version');
        Assert.AreEqual(4, TargetVersions.Count(), 'Incorrect number of target versions returned.');
        TargetVersions.RemoveRange(1, 4);

        // [GIVEN] Migration is set up with BC 17.0 as source
        Initialize(17.0);

        // [WHEN] A call to get upgrade versions is called
        W1Management.GetSupportedUpgradeVersions(TargetVersions);

        // [THEN] The 18.0 , 19.0 and 20.0 target upgrade versions are returned
        Assert.IsTrue(TargetVersions.Contains(18.0), '18.0 not returned as target version');
        Assert.IsTrue(TargetVersions.Contains(19.0), '19.0 not returned as target version');
        Assert.IsTrue(TargetVersions.Contains(20.0), '20.0 not returned as target version');
        Assert.AreEqual(3, TargetVersions.Count(), 'Incorrect number of target versions returned.');
        TargetVersions.RemoveRange(1, 3);

        // [GIVEN] Migration is set up with BC 18.0 as source
        Initialize(18.0);

        // [WHEN] A call to get upgrade versions is called
        W1Management.GetSupportedUpgradeVersions(TargetVersions);

        // [THEN] Only 19.0 and 20.0 target upgrade version is returned
        Assert.IsTrue(TargetVersions.Contains(19.0), '19.0 not returned as target version');
        Assert.IsTrue(TargetVersions.Contains(20.0), '20.0 not returned as target version');
        Assert.AreEqual(2, TargetVersions.Count(), 'Incorrect number of target versions returned.');
        TargetVersions.RemoveRange(1, 2);

        // [GIVEN] Migration is set up with BC 19.0 as source
        Initialize(19.0);

        // [WHEN] A call to get upgrade versions is called
        W1Management.GetSupportedUpgradeVersions(TargetVersions);

        // [THEN] Only 20.0 target upgrade version is returned
        Assert.IsTrue(TargetVersions.Contains(20.0), '20.0 not returned as target version');
        Assert.AreEqual(1, TargetVersions.Count(), 'Incorrect number of target versions returned.');
        TargetVersions.RemoveRange(1, 1);

        // [GIVEN] Migration is set up with BC 19.0 as source
        Initialize(20.0);

        // [WHEN] A call to get upgrade versions is called
        W1Management.GetSupportedUpgradeVersions(TargetVersions);

        // [THEN] No upgrade versions are returned
        Assert.AreEqual(0, TargetVersions.Count(), 'No upgrade versions should be returned');
    end;

    [Test]
    procedure VerifyPublishersCalledWith14xSource()
    var
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        W1CompanyHandler: Codeunit "W1 Company Handler";
    begin
        // [SCENARIO] Upgrade paths are completed in the correct order: Upgrade in place, Transform, then Load Data from staging
        Initialize(14.3);
        HybridReplicationSummary.Init();
        HybridReplicationSummary.Insert();

        // [WHEN] The company upgrade is triggered
        W1CompanyHandler.Run(HybridReplicationSummary);

        // [THEN] The upgrade events are called in the correct order.
        LibraryHybridBCLast.VerifyEventOrder(15.0, false); // 15x upgrade
        LibraryHybridBCLast.VerifyEventOrder(16.0, false); // 16x upgrade
        LibraryHybridBCLast.VerifyEventOrder(17.0, false); // 17x upgrade
        LibraryHybridBCLast.VerifyEventOrder(18.0, false); // 18x upgrade
        LibraryHybridBCLast.VerifyEventOrder(19.0, false); // 19x upgrade
        LibraryHybridBCLast.VerifyEventOrder(20.0, true); // 20x upgrade
    end;

    [Test]
    procedure VerifyPublishersCalledWith15xSource()
    var
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        W1CompanyHandler: Codeunit "W1 Company Handler";
    begin
        // [SCENARIO] Upgrade paths are completed in the correct order: Upgrade in place, Transform, then Load Data from staging
        Initialize(15.4);
        HybridReplicationSummary.Init();
        HybridReplicationSummary.Insert();

        // [WHEN] The company upgrade is triggered
        W1CompanyHandler.Run(HybridReplicationSummary);

        // [THEN] The upgrade events are called in the correct order.
        LibraryHybridBCLast.VerifyEventOrder(16.0, false); // 16x upgrade
        LibraryHybridBCLast.VerifyEventOrder(17.0, false); // 17x upgrade
        LibraryHybridBCLast.VerifyEventOrder(18.0, false); // 18x upgrade
        LibraryHybridBCLast.VerifyEventOrder(19.0, false); // 19x upgrade
        LibraryHybridBCLast.VerifyEventOrder(20.0, true); // 20x upgrade
    end;

    [Test]
    procedure VerifyPublishersCalledWith16xSource()
    var
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        W1CompanyHandler: Codeunit "W1 Company Handler";
    begin
        // [SCENARIO] Upgrade paths are completed in the correct order: Upgrade in place, Transform, then Load Data from staging
        Initialize(16.5);
        HybridReplicationSummary.Init();
        HybridReplicationSummary.Insert();

        // [WHEN] The company upgrade is triggered
        W1CompanyHandler.Run(HybridReplicationSummary);

        // [THEN] The upgrade events are called in the correct order.
        LibraryHybridBCLast.VerifyEventOrder(17.0, false); // 17x upgrade
        LibraryHybridBCLast.VerifyEventOrder(18.0, false); // 18x upgrade
        LibraryHybridBCLast.VerifyEventOrder(19.0, false); // 19x upgrade
        LibraryHybridBCLast.VerifyEventOrder(20.0, true); // 20x upgrade
    end;

    local procedure Initialize(BCVersion: Decimal)
    var
        HybridBCLastSetup: Record "Hybrid BC Last Setup";
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
        HybridCompanyStatus: Record "Hybrid Company Status";
        HybridReplicationSummary: Record "Hybrid Replication Summary";
    begin
        LibraryHybridBCLast.ClearGlobalVariables();

        if not IntelligentCloudSetup.Get() then begin
            IntelligentCloudSetup.Init();
            IntelligentCloudSetup.Insert();
        end;

        HybridReplicationSummary.DeleteAll();
        HybridCompanyStatus.DeleteAll();
        HybridCompanyStatus.Name := CompanyName();
        HybridCompanyStatus.Replicated := true;
        HybridCompanyStatus."Upgrade Status" := HybridCompanyStatus."Upgrade Status"::Pending;
        HybridCompanyStatus.Insert();
        IntelligentCloudSetup."Source BC Version" := BCVersion;
        IntelligentCloudSetup.Modify();

        if IsInitialized then
            exit;

        LibraryHybridBCLast.InitializeWebhookSubscription();
        HybridBCLastSetup.SetHandlerCodeunit(Codeunit::"Library - Hybrid BC Last");
        BindSubscription(LibraryHybridBCLast);

        IsInitialized := true;
    end;

    local procedure Initialize()
    begin
        Initialize(14.0);
    end;
}