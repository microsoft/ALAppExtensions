codeunit 139655 "Hybrid Cue Setup Mgt Tests"
{
    // [FEATURE] [Intelligent Cloud Role Center Cue]
    Subtype = Test;
    TestPermissions = Disabled;

    local procedure Initialize()
    var
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        HybridReplicationDetail: Record "Hybrid Replication Detail";
        HybridCompany: Record "Hybrid Company";
    begin
        HybridReplicationSummary.DeleteAll();
        HybridReplicationDetail.DeleteAll();
        HybridCompany.DeleteAll();
    end;

    local procedure AddNormalTestRunToHybridReplicationDetail(RunId: Text[50]; TableName: Text[250]; CompanyName: Text[250]; StartTime: DateTime; EndTime: DateTime; Status: Option)
    var
        DummyHybridReplicationSummary: Record "Hybrid Replication Summary";
    begin
        AddTestRunToHybridReplicationDetail(RunId, TableName, CompanyName, StartTime, EndTime, Status, DummyHybridReplicationSummary.ReplicationType::Normal);
    end;

    local procedure AddDiagnosticTestRunToHybridReplicationDetail(RunId: Text[50]; TableName: Text[250]; CompanyName: Text[250]; StartTime: DateTime; EndTime: DateTime; Status: Option)
    var
        DummyHybridReplicationSummary: Record "Hybrid Replication Summary";
    begin
        AddTestRunToHybridReplicationDetail(RunId, TableName, CompanyName, StartTime, EndTime, Status, DummyHybridReplicationSummary.ReplicationType::Diagnostic);
    end;

    local procedure AddTestRunToHybridReplicationDetail(RunId: Text[50]; TableName: Text[250]; CompanyName: Text[250]; StartTime: DateTime; EndTime: DateTime; Status: Option; ReplicationType: Option)
    var
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        HybridReplicationDetail: Record "Hybrid Replication Detail";
    begin
        if not HybridReplicationSummary.Get(RunId) then begin
            HybridReplicationSummary.Init();
            HybridReplicationSummary."Trigger Type" := HybridReplicationSummary."Trigger Type"::Manual;
            HybridReplicationSummary.ReplicationType := ReplicationType;
            HybridReplicationSummary."Run ID" := RunId;
            HybridReplicationSummary."Start Time" := StartTime;
            HybridReplicationSummary.Status := HybridReplicationSummary.Status::Completed;
            HybridReplicationSummary.Insert();
        end;

        HybridReplicationDetail.Init();
        HybridReplicationDetail."Run ID" := RunId;
        HybridReplicationDetail."Table Name" := TableName;
        HybridReplicationDetail."Company Name" := CompanyName;
        HybridReplicationDetail."Start Time" := StartTime;
        HybridReplicationDetail."End Time" := EndTime;
        HybridReplicationDetail.Status := Status;
        HybridReplicationDetail.Insert();
    end;

    local procedure EnableReplicationForCompany(CompanyName: Text[50]; Replicate: Boolean)
    var
        HybridCompany: Record "Hybrid Company";
    begin
        if HybridCompany.Get(CompanyName) then begin
            HybridCompany.Replicate := Replicate;
            HybridCompany.Modify();
        end else begin
            HybridCompany.Init();
            HybridCompany.Name := CompanyName;
            HybridCompany.Replicate := Replicate;
            HybridCompany.Insert();
        end;
    end;

    [Test]
    procedure TestNumberOfReplicatedTablesIsZeroWhenNoTablesHaveBeenReplicated()
    var
        HybridReplicationDetail: Record "Hybrid Replication Detail";
        HybridCueSetupManagement: Codeunit "Hybrid Cue Setup Management";
    begin
        // [Scenario] Total number of distinct replicated tables is zero when no tables have been replicated.

        // [Given] No replication runs
        Initialize();
        Assert.AreEqual(0, HybridReplicationDetail.Count(), 'Hybrid Replication Detail table is not empty');

        // [When] Calculate total number of tables
        // [Then] total number of tables is 0
        Assert.AreEqual(0, HybridCueSetupManagement.GetTotalNumberOfDistinctReplicatedTables(), 'Number of distinct tables must be 0');
    end;

    [Test]
    procedure TestNumberOfReplicatedTablesIsZeroWithDisabledCompanyPreviouslyReplicated()
    var
        HybridReplicationDetail: Record "Hybrid Replication Detail";
        HybridCueSetupManagement: Codeunit "Hybrid Cue Setup Management";
        DummyRunId: Guid;
        DummyDateTime: DateTime;
        DummyCompanyName: Text[50];
    begin
        // [Scenario] Total number of distinct replicated tables is zero when company with tables that were previously replicated is now disabled.

        // [GIVEN] 1 replication run with 2 tables for enabled company
        Initialize();
        DummyCompanyName := 'Company 1';
        DummyRunId := CreateGuid();
        DummyDateTime := CurrentDateTime();
        EnableReplicationForCompany(DummyCompanyName, true);
        AddNormalTestRunToHybridReplicationDetail(DummyRunId, 'Table 1', DummyCompanyName, DummyDateTime, DummyDateTime, HybridReplicationDetail.Status::Successful);
        AddNormalTestRunToHybridReplicationDetail(DummyRunId, 'Table 2', DummyCompanyName, DummyDateTime, DummyDateTime, HybridReplicationDetail.Status::Successful);
        Assert.AreEqual(2, HybridReplicationDetail.Count(), 'There must be 2 entries.');

        // [WHEN] company replication is disabled
        EnableReplicationForCompany(DummyCompanyName, false);

        // [THEN] total number of tables is 0
        Assert.AreEqual(0, HybridCueSetupManagement.GetTotalNumberOfDistinctReplicatedTables(), 'Number of distinct tables must be 0');
    end;

    [Test]
    procedure TestNumberOfReplicatedTablesIsCorrectWithReplicationEnabledCompany()
    var
        HybridReplicationDetail: Record "Hybrid Replication Detail";
        HybridCueSetupManagement: Codeunit "Hybrid Cue Setup Management";
        DummyRunId: Guid;
        DummyDateTime: DateTime;
        DummyCompanyName: Text[50];
    begin
        // [Scenario] Total number of distinct replicated tables is correct when there is company with replication enabled.

        // [GIVEN] 1 replication run with 1 table for enabled company
        Initialize();
        DummyCompanyName := 'Company 1';
        DummyRunId := CreateGuid();
        DummyDateTime := CurrentDateTime();
        EnableReplicationForCompany(DummyCompanyName, true);
        AddNormalTestRunToHybridReplicationDetail(DummyRunId, 'Table 1', DummyCompanyName, DummyDateTime, DummyDateTime, HybridReplicationDetail.Status::Successful);
        Assert.AreEqual(1, HybridReplicationDetail.Count(), 'There must be 1 entries.');

        // [WHEN] Calculate total number of tables
        // [THEN] total number of tables is 1
        Assert.AreEqual(1, HybridCueSetupManagement.GetTotalNumberOfDistinctReplicatedTables(), 'Number of distinct tables must be 1');
    end;

    [Test]
    procedure TestNumberOfReplicatedTablesIsCorrectWithReplicationEnabledAndDisabledCompanies()
    var
        HybridReplicationDetail: Record "Hybrid Replication Detail";
        HybridCueSetupManagement: Codeunit "Hybrid Cue Setup Management";
        DummyRunId: Guid;
        DummyDateTime: DateTime;
        DummyCompanyName: Text[50];
    begin
        // [Scenario] Total number of distinct replicated tables is correct when there is a mix of companies with replication enabled and disabled.

        // [GIVEN] 1 replication run with 2 tables for enabled company
        Initialize();
        DummyCompanyName := 'Company 1';
        DummyRunId := CreateGuid();
        DummyDateTime := CurrentDateTime();
        EnableReplicationForCompany(DummyCompanyName, true);
        AddNormalTestRunToHybridReplicationDetail(DummyRunId, 'Table 1', DummyCompanyName, DummyDateTime, DummyDateTime, HybridReplicationDetail.Status::Successful);
        AddNormalTestRunToHybridReplicationDetail(DummyRunId, 'Table 2', DummyCompanyName, DummyDateTime, DummyDateTime, HybridReplicationDetail.Status::Successful);

        // [GIVEN] same replication run with 2 tables for disabled company
        DummyCompanyName := 'Company 2';
        EnableReplicationForCompany(DummyCompanyName, true);
        AddNormalTestRunToHybridReplicationDetail(DummyRunId, 'Table 1', DummyCompanyName, DummyDateTime, DummyDateTime, HybridReplicationDetail.Status::Successful);
        AddNormalTestRunToHybridReplicationDetail(DummyRunId, 'Table 2', DummyCompanyName, DummyDateTime, DummyDateTime, HybridReplicationDetail.Status::Successful);
        EnableReplicationForCompany(DummyCompanyName, false);

        Assert.AreEqual(4, HybridReplicationDetail.Count(), 'There must be 4 entries.');

        // [WHEN] Calculate total number of tables
        // [THEN] total number of tables is 2 since company 2 is disabled
        Assert.AreEqual(2, HybridCueSetupManagement.GetTotalNumberOfDistinctReplicatedTables(), 'Number of distinct tables must be 2');
    end;

    [Test]
    procedure TestNumberOfFailedTablesIsZeroWhenThereAreNoRuns()
    var
        HybridReplicationDetail: Record "Hybrid Replication Detail";
        HybridCueSetupManagement: Codeunit "Hybrid Cue Setup Management";
    begin
        // [Scenario] Number of failed tables is 0 when there are no runs.

        // [Given] No runs
        Initialize();
        Assert.AreEqual(0, HybridReplicationDetail.Count(), 'There must be 0 entries.');

        // [WHEN] find number of failed tables
        // [THEN] number of failed tables is 0
        Assert.AreEqual(0, HybridCueSetupManagement.GetTotalNumberOfFailedReplicatedTables(), 'Number of failed tables must be 0.');
    end;

    [Test]
    procedure TestNumberOfTablesIsZeroWhenOnlyDiagnosticRuns()
    var
        HybridReplicationDetail: Record "Hybrid Replication Detail";
        HybridCueSetupManagement: Codeunit "Hybrid Cue Setup Management";
        DummyRunId: Guid;
        DummyDateTime: DateTime;
        DummyCompanyName: Text[50];
    begin
        // [SCENARIO] Number of failed tables is 0 when there are only diagnostic runs.

        // [GIVEN] There have only been diagnostic runs
        Initialize();
        DummyCompanyName := 'Company 1';
        DummyRunId := CreateGuid();
        DummyDateTime := CurrentDateTime();
        EnableReplicationForCompany(DummyCompanyName, true);
        AddDiagnosticTestRunToHybridReplicationDetail(DummyRunId, 'Table 1', DummyCompanyName, DummyDateTime, DummyDateTime, HybridReplicationDetail.Status::Successful);
        AddDiagnosticTestRunToHybridReplicationDetail(DummyRunId, 'Table 2', DummyCompanyName, DummyDateTime, DummyDateTime, HybridReplicationDetail.Status::Failed);
        AddDiagnosticTestRunToHybridReplicationDetail(DummyRunId, 'Table 3', DummyCompanyName, DummyDateTime, DummyDateTime, HybridReplicationDetail.Status::Successful);

        DummyRunId := CreateGuid();
        AddDiagnosticTestRunToHybridReplicationDetail(DummyRunId, 'Table 1', DummyCompanyName, DummyDateTime, DummyDateTime, HybridReplicationDetail.Status::Failed);
        AddDiagnosticTestRunToHybridReplicationDetail(DummyRunId, 'Table 2', DummyCompanyName, DummyDateTime, DummyDateTime, HybridReplicationDetail.Status::Failed);

        // [THEN] The number of reported failed tables is zero
        Assert.AreEqual(0, HybridCueSetupManagement.GetTotalNumberOfFailedReplicatedTables(), 'Number of failed tables must be 0.');

        // [THEN] The number of reported successful tables is zero
        Assert.AreEqual(0, HybridCueSetupManagement.GetTotalNumberOfSuccessfulReplicatedTables(), 'Number of successful tables must be 0.');
    end;

    [Test]
    procedure TestNumberOfFailedTablesIsCorrectForASingleRun()
    var
        HybridReplicationDetail: Record "Hybrid Replication Detail";
        HybridCueSetupManagement: Codeunit "Hybrid Cue Setup Management";
        DummyRunId: Guid;
        DummyDateTime: DateTime;
        DummyCompanyName: Text[50];
    begin
        // [Scenario] Number of failed tables for single run.

        // [GIVEN] 1 successful table and 1 failed table in a run
        Initialize();
        DummyRunId := CreateGuid();
        DummyDateTime := CurrentDateTime();
        DummyCompanyName := 'Company 1';
        EnableReplicationForCompany(DummyCompanyName, true);
        AddNormalTestRunToHybridReplicationDetail(DummyRunId, 'Table 1', DummyCompanyName, DummyDateTime, DummyDateTime, HybridReplicationDetail.Status::Successful);
        AddNormalTestRunToHybridReplicationDetail(DummyRunId, 'Table 2', DummyCompanyName, DummyDateTime, DummyDateTime, HybridReplicationDetail.Status::Successful);

        // [GIVEN] And 1 failed and 1 warning tables in same run
        DummyCompanyName := 'Company 2';
        EnableReplicationForCompany(DummyCompanyName, true);
        AddNormalTestRunToHybridReplicationDetail(DummyRunId, 'Table 1', DummyCompanyName, DummyDateTime, DummyDateTime, HybridReplicationDetail.Status::Failed);
        AddNormalTestRunToHybridReplicationDetail(DummyRunId, 'Table 2', DummyCompanyName, DummyDateTime, DummyDateTime, HybridReplicationDetail.Status::Warning);

        // Verify number of entries
        Assert.AreEqual(4, HybridReplicationDetail.Count(), 'There must be 4 entries.');

        // [WHEN] find number of failed tables
        // [THEN] number of failed tables is 3
        Assert.AreEqual(2, HybridCueSetupManagement.GetTotalNumberOfFailedReplicatedTables(), 'number of failed tables must be 2');
    end;

    [Test]
    procedure TestNumberOfFailedTablesIsCorrectForMultipleRuns()
    var
        HybridReplicationDetail: Record "Hybrid Replication Detail";
        HybridCueSetupManagement: Codeunit "Hybrid Cue Setup Management";
        DummyRunId: Guid;
        DummyDateTime: DateTime;
        DummyCompanyName: Text[50];
    begin
        // [Scenario] Number of failed tables for multiple run.

        // [GIVEN] First run: 2 failed tables
        Initialize();
        DummyRunId := CreateGuid();
        DummyDateTime := CurrentDateTime();
        DummyCompanyName := 'Company 1';
        EnableReplicationForCompany(DummyCompanyName, true);
        AddNormalTestRunToHybridReplicationDetail(DummyRunId, 'Table 1', DummyCompanyName, DummyDateTime, DummyDateTime, HybridReplicationDetail.Status::Failed);
        AddNormalTestRunToHybridReplicationDetail(DummyRunId, 'Table 2', DummyCompanyName, DummyDateTime, DummyDateTime, HybridReplicationDetail.Status::Failed);

        // [GIVEN] second run: 2 successful tables
        DummyRunId := CreateGuid();
        DummyDateTime := CreateDateTime(Today() + 1, 0T);
        AddNormalTestRunToHybridReplicationDetail(DummyRunId, 'Table 1', DummyCompanyName, DummyDateTime, DummyDateTime, HybridReplicationDetail.Status::Successful);
        AddNormalTestRunToHybridReplicationDetail(DummyRunId, 'Table 2', DummyCompanyName, DummyDateTime, DummyDateTime, HybridReplicationDetail.Status::Successful);

        // [GIVEN] Third run: 3 failed tables for diagnostic run
        DummyRunId := CreateGuid();
        DummyDateTime := CreateDateTime(Today() + 2, 0T);
        AddDiagnosticTestRunToHybridReplicationDetail(DummyRunId, 'Table 1', DummyCompanyName, DummyDateTime, DummyDateTime, HybridReplicationDetail.Status::Failed);
        AddDiagnosticTestRunToHybridReplicationDetail(DummyRunId, 'Table 2', DummyCompanyName, DummyDateTime, DummyDateTime, HybridReplicationDetail.Status::Failed);
        AddDiagnosticTestRunToHybridReplicationDetail(DummyRunId, 'Table 3', DummyCompanyName, DummyDateTime, DummyDateTime, HybridReplicationDetail.Status::Failed);

        Assert.AreEqual(7, HybridReplicationDetail.Count(), 'Unexpected number of detail records.');

        // [THEN] The reported number of failed tables is zero
        Assert.AreEqual(0, HybridCueSetupManagement.GetTotalNumberOfFailedReplicatedTables(), 'number of failed tables must be 0');
    end;

    [Test]
    procedure TestNumberOfFailedTablesIsCorrectWithReplicationEnabledAndDisabledCompanies()
    var
        HybridReplicationDetail: Record "Hybrid Replication Detail";
        HybridCueSetupManagement: Codeunit "Hybrid Cue Setup Management";
        DummyRunId: Guid;
        DummyDateTime: DateTime;
        DummyCompanyName: Text[50];
    begin
        // [Scenario] Number of failed tables is correct when there are enabled and disabled companies.

        // [GIVEN] 2 successful tables for company 1
        Initialize();
        DummyRunId := CreateGuid();
        DummyDateTime := CurrentDateTime();
        DummyCompanyName := 'Company 1';
        EnableReplicationForCompany(DummyCompanyName, true);
        AddNormalTestRunToHybridReplicationDetail(DummyRunId, 'Table 1', DummyCompanyName, DummyDateTime, DummyDateTime, HybridReplicationDetail.Status::Successful);
        AddNormalTestRunToHybridReplicationDetail(DummyRunId, 'Table 2', DummyCompanyName, DummyDateTime, DummyDateTime, HybridReplicationDetail.Status::Successful);

        // [GIVEN] 2 failed tables for company 2
        DummyCompanyName := 'Company 2';
        EnableReplicationForCompany(DummyCompanyName, true);
        AddNormalTestRunToHybridReplicationDetail(DummyRunId, 'Table 1', DummyCompanyName, DummyDateTime, DummyDateTime, HybridReplicationDetail.Status::Failed);
        AddNormalTestRunToHybridReplicationDetail(DummyRunId, 'Table 2', DummyCompanyName, DummyDateTime, DummyDateTime, HybridReplicationDetail.Status::Failed);

        // Verify number of entries
        Assert.AreEqual(4, HybridReplicationDetail.Count(), 'There must be 4 entries.');

        // [WHEN] Company 2 is disable from replication
        EnableReplicationForCompany(DummyCompanyName, false);

        // [Then] number of failed tables is 0, because of Comapny 1 since Company 2 is diabled.
        Assert.AreEqual(0, HybridCueSetupManagement.GetTotalNumberOfFailedReplicatedTables(), 'Number of failed tables is 0');
    end;

    [Test]
    procedure TestNumberOfSuccessfulTablesIsZeroWhenThereAreNoRuns()
    var
        HybridReplicationDetail: Record "Hybrid Replication Detail";
        HybridCueSetupManagement: Codeunit "Hybrid Cue Setup Management";
    begin
        // [Scenario] Number of successful tables is 0 when there are no runs.

        // [Given] No runs
        Initialize();
        Assert.AreEqual(0, HybridReplicationDetail.Count(), 'There must be 0 entries.');

        // [When] find number of successful tables
        // [Then] number of successful tables is 0
        Assert.AreEqual(0, HybridCueSetupManagement.GetTotalNumberOfSuccessfulReplicatedTables(), 'Number of successful tables must be 0.');
    end;

    [Test]
    procedure TestNumberOfSuccessfulTablesIsCorrectForASingleRun()
    var
        HybridReplicationDetail: Record "Hybrid Replication Detail";
        HybridCueSetupManagement: Codeunit "Hybrid Cue Setup Management";
        DummyRunId: Guid;
        DummyDateTime: DateTime;
        DummyCompanyName: Text[50];
    begin
        // [Scenario] Number of successful tables for single run.

        // [GIVEN] 1 successful table and 1 failed table in a run
        Initialize();
        DummyRunId := CreateGuid();
        DummyDateTime := CurrentDateTime();
        DummyCompanyName := 'Company 1';
        EnableReplicationForCompany(DummyCompanyName, true);
        AddNormalTestRunToHybridReplicationDetail(DummyRunId, 'Table 1', DummyCompanyName, DummyDateTime, DummyDateTime, HybridReplicationDetail.Status::Successful);
        AddNormalTestRunToHybridReplicationDetail(DummyRunId, 'Table 2', DummyCompanyName, DummyDateTime, DummyDateTime, HybridReplicationDetail.Status::Failed);

        // Verify number of entries
        Assert.AreEqual(2, HybridReplicationDetail.Count(), 'There must be 2 entries.');

        // [WHEN] find number of successful tables
        // [THEN] number of successful tables is 1
        Assert.AreEqual(1, HybridCueSetupManagement.GetTotalNumberOfSuccessfulReplicatedTables(), 'number of successful tables must be 1');
    end;

    [Test]
    procedure TestNumberOfSuccessfulTablesIsCorrectForMultipleRuns()
    var
        HybridReplicationDetail: Record "Hybrid Replication Detail";
        HybridCueSetupManagement: Codeunit "Hybrid Cue Setup Management";
        DummyRunId: Guid;
        DummyDateTime: DateTime;
        DummyCompanyName: Text[50];
    begin
        // [Scenario] Number of successful tables for multiple run.

        // [GIVEN] First run: 2 successful tables
        Initialize();
        DummyRunId := CreateGuid();
        DummyDateTime := CurrentDateTime();
        DummyCompanyName := 'Company 1';
        EnableReplicationForCompany(DummyCompanyName, true);
        AddNormalTestRunToHybridReplicationDetail(DummyRunId, 'Table 1', DummyCompanyName, DummyDateTime, DummyDateTime, HybridReplicationDetail.Status::Failed);
        AddNormalTestRunToHybridReplicationDetail(DummyRunId, 'Table 2', DummyCompanyName, DummyDateTime, DummyDateTime, HybridReplicationDetail.Status::Failed);

        // [GIVEN] Second run: 2 successful tables
        DummyRunId := CreateGuid();
        DummyDateTime := CreateDateTime(Today() + 1, 0T);
        AddNormalTestRunToHybridReplicationDetail(DummyRunId, 'Table 1', DummyCompanyName, DummyDateTime, DummyDateTime, HybridReplicationDetail.Status::Successful);
        AddNormalTestRunToHybridReplicationDetail(DummyRunId, 'Table 2', DummyCompanyName, DummyDateTime, DummyDateTime, HybridReplicationDetail.Status::Successful);

        // [GIVEN] Third run: 4 failed tables (diagnostic)
        DummyRunId := CreateGuid();
        DummyDateTime := CreateDateTime(Today() + 1, 0T);
        AddDiagnosticTestRunToHybridReplicationDetail(DummyRunId, 'Table 1', DummyCompanyName, DummyDateTime, DummyDateTime, HybridReplicationDetail.Status::Failed);
        AddDiagnosticTestRunToHybridReplicationDetail(DummyRunId, 'Table 2', DummyCompanyName, DummyDateTime, DummyDateTime, HybridReplicationDetail.Status::Failed);
        AddDiagnosticTestRunToHybridReplicationDetail(DummyRunId, 'Table 3', DummyCompanyName, DummyDateTime, DummyDateTime, HybridReplicationDetail.Status::Failed);
        AddDiagnosticTestRunToHybridReplicationDetail(DummyRunId, 'Table 4', DummyCompanyName, DummyDateTime, DummyDateTime, HybridReplicationDetail.Status::Failed);

        Assert.AreEqual(8, HybridReplicationDetail.Count(), 'Incorrect number of detail records.');

        // [THEN] The number of reported successful tables is two.
        Assert.AreEqual(2, HybridCueSetupManagement.GetTotalNumberOfSuccessfulReplicatedTables(), 'Unexpected number of successful tables');
    end;

    [Test]
    procedure TestNumberOfSuccessfulTablesIsCorrectWithReplicationEnabledAndDisabledCompanies()
    var
        HybridReplicationDetail: Record "Hybrid Replication Detail";
        HybridCueSetupManagement: Codeunit "Hybrid Cue Setup Management";
        DummyRunId: Guid;
        DummyDateTime: DateTime;
        DummyCompanyName: Text[50];
    begin
        // [Scenario] Number of successful tables is correct when there are enabled and disabled companies.

        // [GIVEN] 2 successful tables for company 1
        Initialize();
        DummyRunId := CreateGuid();
        DummyDateTime := CurrentDateTime();
        DummyCompanyName := 'Company 1';
        EnableReplicationForCompany(DummyCompanyName, true);
        AddNormalTestRunToHybridReplicationDetail(DummyRunId, 'Table 1', DummyCompanyName, DummyDateTime, DummyDateTime, HybridReplicationDetail.Status::Successful);
        AddNormalTestRunToHybridReplicationDetail(DummyRunId, 'Table 2', DummyCompanyName, DummyDateTime, DummyDateTime, HybridReplicationDetail.Status::Successful);

        // [GIVEN] 2 failed tables for company 2
        DummyCompanyName := 'Company 2';
        EnableReplicationForCompany(DummyCompanyName, true);
        AddNormalTestRunToHybridReplicationDetail(DummyRunId, 'Table 1', DummyCompanyName, DummyDateTime, DummyDateTime, HybridReplicationDetail.Status::Failed);
        AddNormalTestRunToHybridReplicationDetail(DummyRunId, 'Table 2', DummyCompanyName, DummyDateTime, DummyDateTime, HybridReplicationDetail.Status::Failed);

        // Verify number of entries
        Assert.AreEqual(4, HybridReplicationDetail.Count(), 'There must be 4 entries.');

        // [WHEN] Company 2 is disable from replication
        EnableReplicationForCompany(DummyCompanyName, false);

        // [Then] number of successful tables is 2, because of Comapny 1 since Company 2 is diabled.
        Assert.AreEqual(2, HybridCueSetupManagement.GetTotalNumberOfSuccessfulReplicatedTables(), 'Number of successful tables is 2');
    end;

    [Test]
    procedure TestReplicationSuccessRateIsZeroWhenNoTablesHaveBeenReplicated()
    var
        HybridReplicationDetail: Record "Hybrid Replication Detail";
        HybridCueSetupManagement: Codeunit "Hybrid Cue Setup Management";
    begin
        // [Scenario] Replication Success Rate cue value is zero when no table have been replicated.

        // [Given] No replication runs
        Initialize();
        Assert.AreEqual(0, HybridReplicationDetail.Count(), 'Hybrid Replication Detail table is not empty');

        // [When] Calculate Replication success rate
        // [Then] Replication success rate is 0
        Assert.AreEqual(0, HybridCueSetupManagement.GetReplicationSuccessRateCueValue(), 'Replication Success Rate must be 0');
    end;

    [Test]
    procedure TestReplicationSuccessRateCalculationIsBasedOnCompanyWithReplicationEnabledOnly()
    var
        HybridReplicationDetail: Record "Hybrid Replication Detail";
        HybridCueSetupManagement: Codeunit "Hybrid Cue Setup Management";
        DummyRunId: Guid;
        DummyDateTime: DateTime;
        DummyCompanyName: Text[50];
    begin
        // [Scenario] Replication Success Rate cue value is calculated using only companies with replication enabled.

        // [GIVEN] 2 successful for company 1, 1 failed and 1 warning tables for company 2. Both companies enabled.
        Initialize();
        DummyRunId := CreateGuid();
        DummyDateTime := CurrentDateTime();
        DummyCompanyName := 'Company 1';
        EnableReplicationForCompany(DummyCompanyName, true);
        AddNormalTestRunToHybridReplicationDetail(DummyRunId, 'Table 1', DummyCompanyName, DummyDateTime, DummyDateTime, HybridReplicationDetail.Status::Successful);
        AddNormalTestRunToHybridReplicationDetail(DummyRunId, 'Table 2', DummyCompanyName, DummyDateTime, DummyDateTime, HybridReplicationDetail.Status::Successful);

        DummyCompanyName := 'Company 2';
        EnableReplicationForCompany(DummyCompanyName, true);
        AddNormalTestRunToHybridReplicationDetail(DummyRunId, 'Table 1', DummyCompanyName, DummyDateTime, DummyDateTime, HybridReplicationDetail.Status::Failed);
        AddNormalTestRunToHybridReplicationDetail(DummyRunId, 'Table 2', DummyCompanyName, DummyDateTime, DummyDateTime, HybridReplicationDetail.Status::Warning);

        // Verify that there are 4 entries
        Assert.AreEqual(4, HybridReplicationDetail.Count(), 'Hybrid Replication Detail should contain 4 entries');

        // [WHEN] Calculate Replication success rate
        // [THEN] Replication success rate is 2 successful / 4 total.
        Assert.AreEqual(0.50, HybridCueSetupManagement.GetReplicationSuccessRateCueValue(), 'Replication Success Rate must be 0.50');

        // Disable Company 2 replication
        EnableReplicationForCompany(DummyCompanyName, false);

        // [When] Calculate Replication success rate
        // [Then] Replication success rate is 2 successful / 4 total.
        // TODO: This is failing for now. Find a way to get most recent run id that excludes disabled companing.
        Assert.AreEqual(1, HybridCueSetupManagement.GetReplicationSuccessRateCueValue(), 'Replication Success Rate must be 1');
    end;

    [Test]
    procedure TestReplicationSuccessRateCalculationIsCorrectForSingleRun()
    var
        HybridReplicationDetail: Record "Hybrid Replication Detail";
        HybridCueSetupManagement: Codeunit "Hybrid Cue Setup Management";
        DummyRunId: Guid;
        DummyDateTime: DateTime;
        DummyCompanyName: Text[50];
    begin
        // [Scenario] Replication Success Rate cue value is calculated correctly when we have only 1 run.

        // [GIVEN] 2 successful, 1 failed and 1 warning tables on first replication run for company 1.
        Initialize();
        DummyCompanyName := 'Company 1';
        EnableReplicationForCompany(DummyCompanyName, true);
        DummyRunId := CreateGuid();
        DummyDateTime := CurrentDateTime();
        AddNormalTestRunToHybridReplicationDetail(DummyRunId, 'Table 1', DummyCompanyName, DummyDateTime, DummyDateTime, HybridReplicationDetail.Status::Successful);
        AddNormalTestRunToHybridReplicationDetail(DummyRunId, 'Table 2', DummyCompanyName, DummyDateTime, DummyDateTime, HybridReplicationDetail.Status::Successful);
        AddNormalTestRunToHybridReplicationDetail(DummyRunId, 'Table 3', DummyCompanyName, DummyDateTime, DummyDateTime, HybridReplicationDetail.Status::Failed);
        AddNormalTestRunToHybridReplicationDetail(DummyRunId, 'Table 4', DummyCompanyName, DummyDateTime, DummyDateTime, HybridReplicationDetail.Status::Warning);

        // Verify that there are 4 entries
        Assert.AreEqual(4, HybridReplicationDetail.Count(), 'Hybrid Replication Detail should contain 4 entries');

        // [WHEN] Calculate Replication success rate
        // [THEN] Replication success rate is 2 successful / 4 total.
        Assert.AreEqual(0.50, HybridCueSetupManagement.GetReplicationSuccessRateCueValue(), 'Replication Success Rate must be 0.50');
    end;

    [Test]
    procedure TestReplicationSuccessRateCalculationIsCorrectForMultipleRuns()
    var
        HybridReplicationDetail: Record "Hybrid Replication Detail";
        HybridCueSetupManagement: Codeunit "Hybrid Cue Setup Management";
        DummyRunId: Guid;
        DummyDateTime: DateTime;
        DummyCompanyName: Text[50];
    begin
        // [Scenario] Replication Success Rate cue value is calculated correctly when we have multiple runs.

        // [GIVEN] 2 successful, 1 failed and 1 warning tables on first replication run for company 1.
        Initialize();
        DummyRunId := CreateGuid();
        DummyDateTime := CurrentDateTime();
        DummyCompanyName := 'Company 1';
        EnableReplicationForCompany(DummyCompanyName, true);
        AddNormalTestRunToHybridReplicationDetail(DummyRunId, 'Table 1', DummyCompanyName, DummyDateTime, DummyDateTime, HybridReplicationDetail.Status::Successful);
        AddNormalTestRunToHybridReplicationDetail(DummyRunId, 'Table 2', DummyCompanyName, DummyDateTime, DummyDateTime, HybridReplicationDetail.Status::Successful);
        AddNormalTestRunToHybridReplicationDetail(DummyRunId, 'Table 3', DummyCompanyName, DummyDateTime, DummyDateTime, HybridReplicationDetail.Status::Failed);
        AddNormalTestRunToHybridReplicationDetail(DummyRunId, 'Table 4', DummyCompanyName, DummyDateTime, DummyDateTime, HybridReplicationDetail.Status::Warning);

        // [GIVEN] 1 successful table and 1 failed on second replication run.
        DummyRunId := CreateGuid();
        DummyDateTime := CreateDateTime(Today() + 1, 0T);
        AddNormalTestRunToHybridReplicationDetail(DummyRunId, 'Table 3', DummyCompanyName, DummyDateTime, DummyDateTime, HybridReplicationDetail.Status::Successful);
        AddNormalTestRunToHybridReplicationDetail(DummyRunId, 'Table 4', DummyCompanyName, DummyDateTime, DummyDateTime, HybridReplicationDetail.Status::Failed);

        // [GIVEN] 1 successful table third replication run.
        DummyRunId := CreateGuid();
        DummyDateTime := CreateDateTime(Today() + 2, 0T);
        AddNormalTestRunToHybridReplicationDetail(DummyRunId, 'Table 4', DummyCompanyName, DummyDateTime, DummyDateTime, HybridReplicationDetail.Status::Successful);

        // Verify that there are 6 entries
        Assert.AreEqual(7, HybridReplicationDetail.Count(), 'Hybrid Replication Detail should contain 7 entries');

        // [WHEN] Calculate Replication success rate
        // [THEN] Replication success rate is 4 successful / 4 total.
        Assert.AreEqual(1, HybridCueSetupManagement.GetReplicationSuccessRateCueValue(), 'Replication Success Rate must be 1');
    end;

    [Test]
    procedure RemainingTablesIsCorrectForASingleRun()
    var
        HybridReplicationDetail: Record "Hybrid Replication Detail";
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        IntelligentCloudManagement: TestPage "Intelligent Cloud Management";
        DummyRunId: Guid;
        DummyDateTime: DateTime;
        DummyCompanyName: Text[50];
        i: Integer;
    begin
        // [SCENARIO] The [Remaining Tables] cue accurately reflects the number of remaining tables

        // [GIVEN] 4 not started and 1 in progress tables
        Initialize();
        DummyRunId := CreateGuid();
        DummyDateTime := CurrentDateTime();
        DummyCompanyName := 'Company 1';
        EnableReplicationForCompany(DummyCompanyName, true);
        for i := 1 to 4 do
            AddNormalTestRunToHybridReplicationDetail(DummyRunId, 'Table ' + Format(i), DummyCompanyName, DummyDateTime, DummyDateTime, HybridReplicationDetail.Status::NotStarted);
        AddNormalTestRunToHybridReplicationDetail(DummyRunId, 'Table 5', DummyCompanyName, DummyDateTime, DummyDateTime, HybridReplicationDetail.Status::InProgress);

        // [GIVEN] 1 failed and 1 warning tables in same run
        EnableReplicationForCompany(DummyCompanyName, true);
        AddNormalTestRunToHybridReplicationDetail(DummyRunId, 'Table 6', DummyCompanyName, DummyDateTime, DummyDateTime, HybridReplicationDetail.Status::Failed);
        AddNormalTestRunToHybridReplicationDetail(DummyRunId, 'Table 7', DummyCompanyName, DummyDateTime, DummyDateTime, HybridReplicationDetail.Status::Warning);

        // [THEN] Replication summary accurately reflects the record counts
        HybridReplicationSummary.SetAutoCalcFields("Tables Successful", "Tables Failed", "Tables with Warnings", "Tables Remaining");
        HybridReplicationSummary.Get(DummyRunId);
        Assert.AreEqual(5, HybridReplicationSummary."Tables Remaining", HybridReplicationSummary.FieldCaption("Tables Remaining"));
        Assert.AreEqual(1, HybridReplicationSummary."Tables Failed", HybridReplicationSummary.FieldCaption("Tables Failed"));
        Assert.AreEqual(1, HybridReplicationSummary."Tables with Warnings", HybridReplicationSummary.FieldCaption("Tables with Warnings"));
        Assert.AreEqual(0, HybridReplicationSummary."Tables Successful", HybridReplicationSummary.FieldCaption("Tables Successful"));

        // [WHEN] User opens the Cloud Migration Management page
        IntelligentCloudManagement.Trap();
        Page.Run(Page::"Intelligent Cloud Management");

        // [THEN] The statistics cues show the correct numbers
        IntelligentCloudManagement."Replication Statistics"."Tables Remaining".AssertEquals(5);
        IntelligentCloudManagement."Replication Statistics"."Tables Failed".AssertEquals(1);
        IntelligentCloudManagement."Replication Statistics"."Tables with Warnings".AssertEquals(1);
        IntelligentCloudManagement."Replication Statistics"."Tables Successful".AssertEquals(0);
    end;

    var
        Assert: Codeunit Assert;
}