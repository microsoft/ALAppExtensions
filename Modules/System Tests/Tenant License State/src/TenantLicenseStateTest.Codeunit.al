// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 138077 "Tenant License State Test"
{
    // The tenant license table logic forbids us from inserting two entries at the same
    // time and the insertion process is fast enough that two entries inserted consecutively
    // get registered as having the same start time (the time will only be written down to the
    // level of seconds in the database and the miliseconds will be disregarded). Thus,we have
    // introduced a delay of 1000 miliseconds for the start time of tenant licenses that get inserted
    // as part of the same process.

    Subtype = Test;

    trigger OnRun()
    begin
        // [FEATURE] Tenant License State module
        InsertionDelay := 1000;
    end;

    var
        LibraryAssert: Codeunit "Library Assert";
        PermissionsMock: Codeunit "Permissions Mock";
        InsertionDelay: Integer;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestStartDate()
    var
        TenantLicenseState: Codeunit "Tenant License State";
        StartDate: DateTime;
        CurrentDate: DateTime;
    begin
        // [GIVEN] A datetime value
        CurrentDate := CurrentDateTime();

        // [WHEN] Inserting a license state with the datetime value
        // [WHEN] Retrieving the start date of the last inserted license state
        InsertLicenseState("Tenant License State"::Evaluation, CurrentDate);
        PermissionsMock.Set('Tenant License Read');
        StartDate := TenantLicenseState.GetStartDate();

        // [THEN] The start date of the license state is the given datetime value
        LibraryAssert.AreEqual(CurrentDate, StartDate, 'StartDate is incorrect.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestEndDate()
    var
        TenantLicenseState: Codeunit "Tenant License State";
        EndDate: DateTime;
    begin
        // [WHEN] Inserting a trial license state
        // [WHEN] Retrieving the end date of the last inserted license state
        InsertLicenseState("Tenant License State"::Trial, CurrentDateTime());
        PermissionsMock.Set('Tenant License Read');
        EndDate := TenantLicenseState.GetEndDate();

        // [THEN] The end time of the license state is set
        LibraryAssert.AreNotEqual(0DT, EndDate, 'EndDate is incorrect.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestIsEvaluationMode()
    var
        TenantLicenseState: Codeunit "Tenant License State";
        IsEvaluationMode: Boolean;
    begin
        // [WHEN] Inserting an evaluation license state
        // [WHEN] Retrieving whether the last inserted license state is an evaluation one
        InsertLicenseState("Tenant License State"::Evaluation, CurrentDateTime());
        PermissionsMock.Set('Tenant License Read');
        IsEvaluationMode := TenantLicenseState.IsEvaluationMode();

        // [THEN] The check returns true
        LibraryAssert.AreEqual(true, IsEvaluationMode, 'The tenant license state should be evaluation');

        // [WHEN] Inserting a paid license state
        // [WHEN] Checking whether the license state is evaluation
        InsertLicenseState("Tenant License State"::Paid, CurrentDateTime() + InsertionDelay);
        IsEvaluationMode := TenantLicenseState.IsEvaluationMode();

        // [THEN] The check returns false
        LibraryAssert.AreEqual(false, IsEvaluationMode, 'The tenant license state should not be evaluation');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestIsTrialMode()
    var
        TenantLicenseState: Codeunit "Tenant License State";
        IsTrialMode: Boolean;
    begin
        // [WHEN] Inserting a trial license state
        // [WHEN] Checking whether the license state is trial
        InsertLicenseState("Tenant License State"::Trial, CurrentDateTime());
        PermissionsMock.Set('Tenant License Read');
        IsTrialMode := TenantLicenseState.IsTrialMode();

        // [THEN] The check returns true
        LibraryAssert.AreEqual(true, IsTrialMode, 'The tenant license state should be trial');

        // [WHEN] Inserting a suspended license state
        // [WHEN] Checking whether the license state is trial
        InsertLicenseState("Tenant License State"::Suspended, CurrentDateTime() + InsertionDelay);
        IsTrialMode := TenantLicenseState.IsTrialMode();

        // [THEN] The check returns false
        LibraryAssert.AreEqual(false, IsTrialMode, 'The tenant license state should not be trial');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestIsTrialSuspendedMode()
    var
        TenantLicenseState: Codeunit "Tenant License State";
        IsTrialSuspendedMode: Boolean;
    begin
        // [WHEN] Inserting a trial license state
        // [WHEN] Inserting a suspended license state after the trial license state has been inserted
        // [WHEN] Checking whether the license is in trial suspended mode
        InsertLicenseState("Tenant License State"::Trial, CurrentDateTime());
        InsertLicenseState("Tenant License State"::Suspended, CurrentDateTime() + InsertionDelay);
        PermissionsMock.Set('Tenant License Read');
        IsTrialSuspendedMode := TenantLicenseState.IsTrialSuspendedMode();

        // [THEN] The check returns true
        LibraryAssert.AreEqual(true, IsTrialSuspendedMode, 'The last 2 tenant license states should be trial and suspended');

        // [WHEN] Inserting a paid license state after the suspended license state has been inserted
        // [WHEN] Checking whether the license is in trial suspended mode
        InsertLicenseState("Tenant License State"::Paid, CurrentDateTime() + 2 * InsertionDelay);
        IsTrialSuspendedMode := TenantLicenseState.IsTrialSuspendedMode();

        // [THEN] The check returns false
        LibraryAssert.AreEqual(false, IsTrialSuspendedMode, 'The last 2 tenant license states should not be trial and suspended');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestIsTrialExtendedMode()
    var
        TenantLicenseState: Codeunit "Tenant License State";
        IsTrialExtendedMode: Boolean;
    begin
        // [WHEN] Inserting a trial license state
        // [WHEN] Checking whether the license is in trial suspended mode
        InsertLicenseState("Tenant License State"::Trial, CurrentDateTime());
        PermissionsMock.Set('Tenant License Read');

        IsTrialExtendedMode := TenantLicenseState.IsTrialExtendedMode();

        // [THEN] The check returns false
        LibraryAssert.AreEqual(false, IsTrialExtendedMode, 'Only the last tenant license state should be trial');

        // [WHEN] Inserting another trial license state
        // [WHEN] Checking whether the license is in trial extended mode
        InsertLicenseState("Tenant License State"::Trial, CurrentDateTime() + InsertionDelay);

        IsTrialExtendedMode := TenantLicenseState.IsTrialExtendedMode();

        // [THEN] The check returns true
        LibraryAssert.AreEqual(true, IsTrialExtendedMode, 'The last 2 or more tenant license states should be trial');

        // [WHEN] Inserting a paid license state after the two trial license states
        // [WHEN] Checking whether the license is in trial extended mode
        InsertLicenseState("Tenant License State"::Paid, CurrentDateTime() + 2 * InsertionDelay);
        IsTrialExtendedMode := TenantLicenseState.IsTrialExtendedMode();

        // [THEN] The check returns false
        LibraryAssert.AreEqual(false, IsTrialExtendedMode, 'The last tenant license state should not be trial');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestIsTrialExtendedSuspendedMode()
    var
        TenantLicenseState: Codeunit "Tenant License State";
        IsTrialExtendedSuspendedMode: Boolean;
    begin
        PermissionsMock.Set('Tenant License Read');
        // [WHEN] Inserting two trial license states
        // [WHEN] Checking whether the license is in extended suspended mode
        InsertLicenseState("Tenant License State"::Trial, CurrentDateTime());
        InsertLicenseState("Tenant License State"::Trial, CurrentDateTime() + InsertionDelay);
        IsTrialExtendedSuspendedMode := TenantLicenseState.IsTrialExtendedSuspendedMode();

        // [THEN] The check returns false
        LibraryAssert.AreEqual(false, IsTrialExtendedSuspendedMode, 'The last tenant license state should not be suspended');

        // [WHEN] Inserting a suspended license state after the two trial ones
        // [WHEN] Checking whether the license is in extended suspended mode
        InsertLicenseState("Tenant License State"::Suspended, CurrentDateTime() + 2 * InsertionDelay);
        IsTrialExtendedSuspendedMode := TenantLicenseState.IsTrialExtendedSuspendedMode();

        // [THEN] The check returns true
        LibraryAssert.AreEqual(true, IsTrialExtendedSuspendedMode, 'The last 3 tenant license states should be trial,trial and suspended');

        // [WHEN] Inserting a trial license state after the suspended one
        // [WHEN] Checking whether the license is in extended suspended mode
        InsertLicenseState("Tenant License State"::Trial, CurrentDateTime() + 3 * InsertionDelay);
        IsTrialExtendedSuspendedMode := TenantLicenseState.IsTrialExtendedSuspendedMode();

        // [THEN] The check returns false
        LibraryAssert.AreEqual(false, IsTrialExtendedSuspendedMode, 'The last tenant license state should be trial');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestIsPaidMode()
    var
        TenantLicenseState: Codeunit "Tenant License State";
        IsPaidMode: Boolean;
    begin
        PermissionsMock.Set('Tenant License Read');
        // [WHEN] Inserting a paid license state
        // [WHEN] Checking whether the license is in paid mode
        InsertLicenseState("Tenant License State"::Paid, CurrentDateTime());
        IsPaidMode := TenantLicenseState.IsPaidMode();

        // [THEN] The check returns true
        LibraryAssert.AreEqual(true, IsPaidMode, 'The tenant license state should be paid');

        // [WHEN] Inserting a suspended license state after the paid one
        // [WHEN] Checking whether the license is in paid mode
        InsertLicenseState("Tenant License State"::Suspended, CurrentDateTime() + InsertionDelay);
        IsPaidMode := TenantLicenseState.IsPaidMode();

        // [THEN] The check returns false
        LibraryAssert.AreEqual(false, IsPaidMode, 'The tenant license state should not be paid');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestIsPaidWarningMode()
    var
        TenantLicenseState: Codeunit "Tenant License State";
        IsPaidWarningMode: Boolean;
    begin
        PermissionsMock.Set('Tenant License Read');
        // [WHEN] Inserting a paid license state
        // [WHEN] Checking whether the license is in paid warning mode
        InsertLicenseState("Tenant License State"::Paid, CurrentDateTime());
        IsPaidWarningMode := TenantLicenseState.IsPaidWarningMode();

        // [THEN] The check returns false
        LibraryAssert.AreEqual(false, IsPaidWarningMode, 'The last 2 tenant license states should not be paid and warning');

        // [WHEN] Inserting a warning license state after the paid one
        // [WHEN] Checking whether the license is in paid warning mode
        InsertLicenseState("Tenant License State"::Warning, CurrentDateTime() + InsertionDelay);
        IsPaidWarningMode := TenantLicenseState.IsPaidWarningMode();

        // [THEN] The check returns true
        LibraryAssert.AreEqual(true, IsPaidWarningMode, 'The last 2 tenant license states should be paid and warning');

        // [WHEN] Inserting another paid license state after the warning one
        // [WHEN] Checking whether the license is in paid warning mode
        InsertLicenseState("Tenant License State"::Paid, CurrentDateTime() + 2 * InsertionDelay);
        IsPaidWarningMode := TenantLicenseState.IsPaidWarningMode();

        // [THEN] The check returns false
        LibraryAssert.AreEqual(false, IsPaidWarningMode, 'The last 2 tenant license states should be warning and paid.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestIsPaidSuspendedMode()
    var
        TenantLicenseState: Codeunit "Tenant License State";
        IsPaidSuspendedMode: Boolean;
    begin
        // [WHEN] Inserting a paid license state
        // [WHEN] Checking whether the license is in paid suspended mode
        InsertLicenseState("Tenant License State"::Paid, CurrentDateTime());
        
        PermissionsMock.Set('Tenant License Read');
        IsPaidSuspendedMode := TenantLicenseState.IsPaidSuspendedMode();
        
        // [THEN] The check returns false
        LibraryAssert.AreEqual(false, IsPaidSuspendedMode, 'The last 2 tenant license states should not be paid and suspended');

        // [WHEN] Inserting a suspended license state
        // [WHEN] Checking whether the license is in paid suspended mode
        InsertLicenseState("Tenant License State"::Suspended, CurrentDateTime() + InsertionDelay);

        IsPaidSuspendedMode := TenantLicenseState.IsPaidSuspendedMode();

        // [THEN] The check returns true
        LibraryAssert.AreEqual(true, IsPaidSuspendedMode, 'The last 2 tenant license states should be paid and suspended');

        // [WHEN] Inserting a paid license state
        // [WHEN] Checking whether the license is in paid suspended mode
        InsertLicenseState("Tenant License State"::Paid, CurrentDateTime() + 2 * InsertionDelay);
        IsPaidSuspendedMode := TenantLicenseState.IsPaidSuspendedMode();

        // [THEN] The check returns false
        LibraryAssert.AreEqual(false, IsPaidSuspendedMode, 'The last 2 tenant license states should be suspended and paid');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestGetLicenseState()
    var
        TenantLicenseStateRec: Record "Tenant License State";
        TenantLicenseState: Codeunit "Tenant License State";
        LicenseState: Enum "Tenant License State";
    begin
        PermissionsMock.Set('Tenant License Read');
        // [GIVEN] The tenant license state table is unfiltered
        TenantLicenseStateRec.Reset();

        // [GIVEN] There are no records in the Tenant License State table
        if TenantLicenseStateRec.IsEmpty() then begin
            // [WHEN] Retrieving the current tenant license state
            LicenseState := TenantLicenseState.GetLicenseState();

            // [THEN] The tenant license state is evaluation
            LibraryAssert.AreEqual("Tenant License State"::Evaluation,
              LicenseState, 'The tenant license state should be evaluation')
        end;

        // [WHEN] Inserting a paid license state
        InsertLicenseState("Tenant License State"::Paid, CurrentDateTime());

        // [WHEN] Retrieving the current tenant license state
        LicenseState := TenantLicenseState.GetLicenseState();

        // [THEN] The tenant license state is paid
        LibraryAssert.AreEqual("Tenant License State"::Paid,
          LicenseState, 'The tenant license state should be paid');
    end;

    local procedure InsertLicenseState(State: Option; StartDate: DateTime)
    var
        TenantLicenseState: Record "Tenant License State";
    begin
        PermissionsMock.Stop();
        TenantLicenseState.Init();
        TenantLicenseState."Start Date" := StartDate;
        TenantLicenseState.State := State;
        TenantLicenseState.Insert();
        PermissionsMock.Start();
        PermissionsMock.Set('Tenant License Read');
    end;
}