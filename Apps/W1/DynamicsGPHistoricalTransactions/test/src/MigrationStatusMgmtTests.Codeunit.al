codeunit 139700 "Migration Status Mgmt. Tests"
{
    EventSubscriberInstance = Manual;
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;

    [Test]
    procedure TestUpdateStepStatus()
    var
        HistMigrationStepStatus: Record "Hist. Migration Step Status";
        HistMigrationCurrentStatus: Record "Hist. Migration Current Status";
        HistMigrationStatusMgmt: Codeunit "Hist. Migration Status Mgmt.";
        TestingStepType: enum "Hist. Migration Step Type";
    begin
        // [GIVEN] The GP Historical Transactions migration has started
        HistMigrationStatusMgmt.ResetAll();

        // [WHEN] Step started: GP GL Accounts
        TestingStepType := "Hist. Migration Step Type"::"GP GL Accounts";
        HistMigrationStatusMgmt.UpdateStepStatus(TestingStepType, false);

        // [THEN] Current status step will also be GP GL Accounts. The step log will also have contain this step and won't yet be completed.
        HistMigrationCurrentStatus.Get();
        Assert.AreEqual(TestingStepType, HistMigrationCurrentStatus."Current Step", 'Current status is incorrect, should be GP GL Accounts.');

        Assert.RecordCount(HistMigrationStepStatus, 1);
        HistMigrationStepStatus.FindFirst();
        Assert.AreEqual(TestingStepType, HistMigrationStepStatus.Step, 'Step is incorrect.');
        Assert.AreNotEqual(0DT, HistMigrationStepStatus."Start Date", 'Start date should not be null.');
        Assert.AreEqual(0DT, HistMigrationStepStatus."End Date", 'End date should be null.');
        Assert.IsFalse(HistMigrationStepStatus.Completed, 'Should not be completed yet.');

        // [WHEN] Step completed
        HistMigrationStatusMgmt.UpdateStepStatus(TestingStepType, true);

        // [THEN] Current status step will still be GP GL Accounts. The step log entry will be completed.
        HistMigrationCurrentStatus.Get();
        Assert.AreEqual(TestingStepType, HistMigrationCurrentStatus."Current Step", 'Current status is incorrect, should be GP GL Accounts.');

        Assert.RecordCount(HistMigrationStepStatus, 1);
        HistMigrationStepStatus.FindFirst();
        Assert.AreEqual(TestingStepType, HistMigrationStepStatus.Step, 'Step is incorrect.');
        Assert.AreNotEqual(0DT, HistMigrationStepStatus."Start Date", 'Start date should not be null.');
        Assert.AreNotEqual(0DT, HistMigrationStepStatus."End Date", 'End date should not be null.');
        Assert.IsTrue(HistMigrationStepStatus.Completed, 'Should be completed.');

        // [WHEN] Step started: GP Inventory Trx.
        TestingStepType := "Hist. Migration Step Type"::"GP Inventory Trx.";
        HistMigrationStatusMgmt.UpdateStepStatus(TestingStepType, false);
        Clear(HistMigrationStepStatus);

        // [THEN] Current status step will also be GP Inventory Trx. The step log will also have contain this step and won't yet be completed.
        HistMigrationCurrentStatus.Get();
        Assert.AreEqual(TestingStepType, HistMigrationCurrentStatus."Current Step", 'Current status is incorrect, should be GP Inventory Trx.');

        Assert.RecordCount(HistMigrationStepStatus, 2);
        HistMigrationStepStatus.SetRange(Step, TestingStepType);
        HistMigrationStepStatus.FindFirst();
        Assert.AreEqual(TestingStepType, HistMigrationStepStatus.Step, 'Step is incorrect.');
        Assert.AreNotEqual(0DT, HistMigrationStepStatus."Start Date", 'Start date should not be null.');
        Assert.AreEqual(0DT, HistMigrationStepStatus."End Date", 'End date should be null.');
        Assert.IsFalse(HistMigrationStepStatus.Completed, 'Should not be completed yet.');

        // [WHEN] Step completed
        HistMigrationStatusMgmt.UpdateStepStatus(TestingStepType, true);
        Clear(HistMigrationStepStatus);

        // [THEN] Current status step will still be GP Inventory Trx. The step log entry will be completed.
        HistMigrationCurrentStatus.Get();
        Assert.AreEqual(TestingStepType, HistMigrationCurrentStatus."Current Step", 'Current status is incorrect, should be GP Inventory Trx..');

        Assert.RecordCount(HistMigrationStepStatus, 2);
        HistMigrationStepStatus.SetRange(Step, TestingStepType);
        HistMigrationStepStatus.FindFirst();
        Assert.AreEqual(TestingStepType, HistMigrationStepStatus.Step, 'Step is incorrect.');
        Assert.AreNotEqual(0DT, HistMigrationStepStatus."Start Date", 'Start date should not be null.');
        Assert.AreNotEqual(0DT, HistMigrationStepStatus."End Date", 'End date should not be null.');
        Assert.IsTrue(HistMigrationStepStatus.Completed, 'Should be completed.');

        // [WHEN] GP Historical Transactions migration is completed
        HistMigrationStatusMgmt.SetStatusFinished();
        Clear(HistMigrationStepStatus);
        TestingStepType := "Hist. Migration Step Type"::Finished;

        // [THEN] Current status step will be Finished. The step log will also have contain this step and will be completed.
        HistMigrationCurrentStatus.Get();
        Assert.AreEqual(TestingStepType, HistMigrationCurrentStatus."Current Step", 'Current status is incorrect, should be Finished(1).');

        Assert.RecordCount(HistMigrationStepStatus, 3);

        HistMigrationStepStatus.SetRange(Step, TestingStepType);
        HistMigrationStepStatus.FindFirst();
        Assert.AreEqual(TestingStepType, HistMigrationStepStatus.Step, 'Step is incorrect.');
        Assert.AreNotEqual(0DT, HistMigrationStepStatus."Start Date", 'Start date should not be null.');
        Assert.AreNotEqual(0DT, HistMigrationStepStatus."End Date", 'End date should not be null.');
        Assert.IsTrue(HistMigrationStepStatus.Completed, 'Should be completed.');
    end;

    [Test]
    procedure TestHasNotRanStep()
    var
        HistMigrationStatusMgmt: Codeunit "Hist. Migration Status Mgmt.";
    begin
        HistMigrationStatusMgmt.ResetAll();

        // [GIVEN] The GP Historical Transactions migration has started

        // [WHEN] The step is updated
        HistMigrationStatusMgmt.UpdateStepStatus("Hist. Migration Step Type"::"GP GL Accounts", false);

        // [THEN] The HasNotRanStep and GetCurrentStatus procedures will return the correct results
        Assert.IsFalse(HistMigrationStatusMgmt.HasNotRanStep("Hist. Migration Step Type"::"GP GL Accounts"), 'The GP GL Accounts step has been ran.');
        Assert.IsTrue(HistMigrationStatusMgmt.HasNotRanStep("Hist. Migration Step Type"::"GP Receivables Trx."), 'The GP Receivables Trx. step has not been ran.');
        Assert.AreEqual("Hist. Migration Step Type"::"GP GL Accounts", HistMigrationStatusMgmt.GetCurrentStatus(), 'Current status is incorrect.');
    end;
}