codeunit 139671 "Test Data Load W1"
{
    Subtype = Test;
    TestPermissions = Disabled;
    Description = 'Test the data loading logic for the staged tables.';

    var
        Assert: Codeunit Assert;
        LibraryHybridBCLast: Codeunit "Library - Hybrid BC Last";
        IsInitialized: Boolean;

    // [Test]
    // procedure LoadDataDoesNotUpdateSyncedVersionIfNoChanges()
    // var
    //     IntelligentCloudStatus: Record "Intelligent Cloud Status";
    //     RunId: Text;
    //     TriggerType: Text;
    //     StartTime: DateTime;
    // begin
    //     // [SCENARIO] When a successful data load occurs, only tables with changes get updated in Intelligent Cloud Status.
    //     Initialize();

    //     // [GIVEN] No staged changes are present
    //     // [WHEN] The data load mechanism is invoked
    //     LibraryHybridBCLast.InsertNotification(RunId, StartTime, TriggerType, '', 1338);

    //     // [THEN] The Intelligent Cloud Synced version is not updated for any tables.
    //     IntelligentCloudStatus.SetRange("Synced Version", 1338);
    //     Assert.AreEqual(IntelligentCloudStatus.Count(), 0, 'No records should have been updated.');
    // end;

    [Test]
    procedure LoadDataFailureUpdatesSetsErrorAndSyncedVersionForAllStagedTables()
    var
        IntelligentCloudStatus: Record "Intelligent Cloud Status";
        HybridReplicationDetail: Record "Hybrid Replication Detail";
        SourceTableMapping: Record "Source Table Mapping";
        TableCount: Integer;
        CurrentTable: Text;
        FailureMessage: Text;
        RunId: Text;
        TriggerType: Text;
        StartTime: DateTime;
    begin
        // [SCENARIO] When a failure occurs while loading data, all staged tables get updated and blocked
        Initialize();
        HybridReplicationDetail.DeleteAll();

        // [GIVEN] Previous successful replication runs have occurred.
        FailureMessage := 'it failed...';
        LibraryHybridBCLast.SetDataLoadFailure(FailureMessage);
        IntelligentCloudStatus.ModifyAll("Synced Version", 250);

        // [WHEN] The data load mechanism is invoked and fails
        LibraryHybridBCLast.InsertNotification(RunId, StartTime, TriggerType, '', 500);

        // [THEN] All staged tables get updated to be blocked and have 0 as synced version
        IntelligentCloudStatus.SetRange("Synced Version", 0);
        IntelligentCloudStatus.SetRange(Blocked, true);
        SourceTableMapping.SetCurrentKey("Source Table Name");
        SourceTableMapping.SetRange(Staged, true);
        if SourceTableMapping.FindSet() then
            repeat
                if SourceTableMapping."Source Table Name" <> CurrentTable then begin
                    CurrentTable := SourceTableMapping."Source Table Name";
                    TableCount += 1;
                end;
            until SourceTableMapping.Next() = 0;

        // This will change as we add more staged tables.
        Assert.AreEqual(TableCount, IntelligentCloudStatus.Count(), 'The expected number of staged tables did not get blocked.');

        // [THEN] The Hybrid Replication Detail records get updated to have failed status
        HybridReplicationDetail.SetRange("Run ID", RunId);
        HybridReplicationDetail.SetRange(Status, HybridReplicationDetail.Status::Failed);
        Assert.AreEqual(TableCount, HybridReplicationDetail.Count(), 'The expected Hybrid Replication Detail records did not get updated.');

        HybridReplicationDetail.FindFirst();
        Assert.AreEqual(FailureMessage, HybridReplicationDetail."Error Message", 'The error message did not get updated on the detail record.');
    end;

    local procedure Initialize()
    var
        HybridCompany: Record "Hybrid Company";
        HybridBCLastSetup: Record "Hybrid BC Last Setup";
        IntelligentCloudStatus: Record "Intelligent Cloud Status";
    begin
        if IsInitialized then
            exit;

        HybridCompany.Init();
        HybridCompany.Name := CopyStr(CompanyName(), 1, 30);
        HybridCompany.Replicate := true;
        if HybridCompany.Insert() then;

        BindSubscription(LibraryHybridBCLast);
        HybridBCLastSetup.SetHandlerCodeunit(Codeunit::"Library - Hybrid BC Last");
        IntelligentCloudStatus.ModifyAll("Synced Version", 0);
        LibraryHybridBCLast.InitializeMapping(14.5);
        IsInitialized := true;
    end;
}