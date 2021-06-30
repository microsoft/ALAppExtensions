// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

// This codeunit must be executed by a test-runnner which has test-isolation disabled. 

codeunit 138705 "Retention Policy Log Test"
{
    Subtype = Test;
    Permissions = tabledata "Retention Policy Log Entry" = r;

    var
        Assert: Codeunit "Library Assert";
        PermissionsMock: Codeunit "Permissions Mock";
        RetentionPolicyLogCategory: Enum "Retention Policy Log Category";
        ErrorOccuredDuringApplyErrLbl: Label 'An error occured while applying the retention policy for table %1 %2.\\%3', Comment = '%1 = table number, %2 = table name, %3 = error message';
        TestLogMessageLbl: Label 'TestLog %1 Entry No. %2', Locked = true;
        RetentionPolicySetupRecordNotTempErr: Label 'The retention policy setup record instance must be temporary. Contact your Microsoft Partner for assistance.';
        RecordDoesNotExistErr: Label 'The Retention Policy Setup does not exist. Identification fields and values: %1', Comment = '%1 is a guid';

    [Test]
    procedure TestLogInfo()
    var
        RetentionPolicyLogEntry: Record "Retention Policy Log Entry";
        RetentionPolicyLog: Codeunit "Retention Policy Log";
        LastRetentionPolicyLogEntryNo: BigInteger;
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        //Setup
        if RetentionPolicyLogEntry.FindLast() then;
        LastRetentionPolicyLogEntryNo := RetentionPolicyLogEntry."Entry No.";

        //Exercise
        RetentionPolicyLog.LogInfo(RetentionPolicyLogCategory::"Retention Policy - Period", StrSubstNo(TestLogMessageLbl, RetentionPolicyLogEntry."Message Type"::Info, LastRetentionPolicyLogEntryNo + 1)); // runs a background task
        sleep(50); // need some time for background session
        VerifyLogEntry(LastRetentionPolicyLogEntryNo + 1, RetentionPolicyLogEntry."Message Type"::Info, RetentionPolicyLogCategory::"Retention Policy - Period", StrSubstNo(TestLogMessageLbl, RetentionPolicyLogEntry."Message Type"::Info, LastRetentionPolicyLogEntryNo + 1));

        // verify
        asserterror
            error('An error to ensure rollback');

        VerifyLogEntry(LastRetentionPolicyLogEntryNo + 1, RetentionPolicyLogEntry."Message Type"::Info, RetentionPolicyLogCategory::"Retention Policy - Period", StrSubstNo(TestLogMessageLbl, RetentionPolicyLogEntry."Message Type"::Info, LastRetentionPolicyLogEntryNo + 1));
    end;

    [Test]
    procedure TestLogWarning()
    var
        RetentionPolicyLogEntry: Record "Retention Policy Log Entry";
        RetentionPolicyLog: Codeunit "Retention Policy Log";
        LastRetentionPolicyLogEntryNo: BigInteger;
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        //Setup
        if RetentionPolicyLogEntry.FindLast() then;
        LastRetentionPolicyLogEntryNo := RetentionPolicyLogEntry."Entry No.";

        //Exercise
        RetentionPolicyLog.LogWarning(RetentionPolicyLogCategory::"Retention Policy - Period", StrSubstNo(TestLogMessageLbl, RetentionPolicyLogEntry."Message Type"::Warning, LastRetentionPolicyLogEntryNo + 1)); // runs a background task
        sleep(50); // need some time for background session
        VerifyLogEntry(LastRetentionPolicyLogEntryNo + 1, RetentionPolicyLogEntry."Message Type"::Warning, RetentionPolicyLogCategory::"Retention Policy - Period", StrSubstNo(TestLogMessageLbl, RetentionPolicyLogEntry."Message Type"::Warning, LastRetentionPolicyLogEntryNo + 1));

        // verify
        asserterror
            error('An error to ensure rollback');

        VerifyLogEntry(LastRetentionPolicyLogEntryNo + 1, RetentionPolicyLogEntry."Message Type"::Warning, RetentionPolicyLogCategory::"Retention Policy - Period", StrSubstNo(TestLogMessageLbl, RetentionPolicyLogEntry."Message Type"::Warning, LastRetentionPolicyLogEntryNo + 1));
    end;

    [Test]
    procedure TestLogError()
    var
        RetentionPolicyLogEntry: Record "Retention Policy Log Entry";
        RetentionPolicyLog: Codeunit "Retention Policy Log";
        LastRetentionPolicyLogEntryNo: BigInteger;
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        //Setup
        if RetentionPolicyLogEntry.FindLast() then;
        LastRetentionPolicyLogEntryNo := RetentionPolicyLogEntry."Entry No.";

        //Exercise
        AssertError
    RetentionPolicyLog.LogError(RetentionPolicyLogCategory::"Retention Policy - Period", StrSubstNo(TestLogMessageLbl, RetentionPolicyLogEntry."Message Type"::Error, LastRetentionPolicyLogEntryNo + 1)); // runs a background task

        // Verify
        sleep(50); // need some time for background session
        VerifyLogEntry(LastRetentionPolicyLogEntryNo + 1, RetentionPolicyLogEntry."Message Type"::Error, RetentionPolicyLogCategory::"Retention Policy - Period", StrSubstNo(TestLogMessageLbl, RetentionPolicyLogEntry."Message Type"::Error, LastRetentionPolicyLogEntryNo + 1));
    end;

    [Test]
    procedure TestLogErrorWithDisplay()
    var
        RetentionPolicyLogEntry: Record "Retention Policy Log Entry";
        RetentionPolicyLog: Codeunit "Retention Policy Log";
        LastRetentionPolicyLogEntryNo: BigInteger;
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        //Setup
        if RetentionPolicyLogEntry.FindLast() then;
        LastRetentionPolicyLogEntryNo := RetentionPolicyLogEntry."Entry No.";

        //Exercise
        AssertError
    RetentionPolicyLog.LogError(RetentionPolicyLogCategory::"Retention Policy - Period", StrSubstNo(TestLogMessageLbl, RetentionPolicyLogEntry."Message Type"::Error, LastRetentionPolicyLogEntryNo + 1), true); // runs a background task

        // Verify
        sleep(50); // need some time for background session
        VerifyLogEntry(LastRetentionPolicyLogEntryNo + 1, RetentionPolicyLogEntry."Message Type"::Error, RetentionPolicyLogCategory::"Retention Policy - Period", StrSubstNo(TestLogMessageLbl, RetentionPolicyLogEntry."Message Type"::Error, LastRetentionPolicyLogEntryNo + 1));
    end;

    [Test]
    procedure TestLogErrorWithoutDisplay()
    var
        RetentionPolicyLogEntry: Record "Retention Policy Log Entry";
        RetentionPolicyLog: Codeunit "Retention Policy Log";
        LastRetentionPolicyLogEntryNo: BigInteger;
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        //Setup
        if RetentionPolicyLogEntry.FindLast() then;
        LastRetentionPolicyLogEntryNo := RetentionPolicyLogEntry."Entry No.";

        //Exercise
        RetentionPolicyLog.LogError(RetentionPolicyLogCategory::"Retention Policy - Period", StrSubstNo(TestLogMessageLbl, RetentionPolicyLogEntry."Message Type"::Error, LastRetentionPolicyLogEntryNo + 1), false); // runs a background task

        // Verify
        sleep(50); // need some time for background session
        VerifyLogEntry(LastRetentionPolicyLogEntryNo + 1, RetentionPolicyLogEntry."Message Type"::Error, RetentionPolicyLogCategory::"Retention Policy - Period", StrSubstNo(TestLogMessageLbl, RetentionPolicyLogEntry."Message Type"::Error, LastRetentionPolicyLogEntryNo + 1));
    end;

    [Test]
    procedure TestApplyRetentionPolicyRecordMustBeTemp()
    var
        RetentionPolicySetup: Record "Retention Policy Setup";
        RetentionPolicyLogEntry: Record "Retention Policy Log Entry";
        RetentionPolicyLog: Codeunit "Retention Policy Log";
        LastRetentionPolicyLogEntryNo: BigInteger;
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        // Setup
        if RetentionPolicyLogEntry.FindLast() then;
        LastRetentionPolicyLogEntryNo := RetentionPolicyLogEntry."Entry No.";
        RetentionPolicySetup.SystemId := CreateGuid();
        RetentionPolicySetup."Table Id" := Database::"Retention Policy Test Data";
        RetentionPolicySetup.CalcFields("Table Name");
        ClearLastError();

        // Exercise
        if not Codeunit.Run(Codeunit::"Apply Retention Policy Impl.", RetentionPolicySetup) then
            RetentionPolicyLog.LogError(RetentionPolicyLogCategory::"Retention Policy - Apply", StrSubstNo(ErrorOccuredDuringApplyErrLbl, RetentionPolicySetup."Table Id", RetentionPolicySetup."Table Name", GetLastErrorText()), false);

        // Verify
        sleep(50);
        Assert.ExpectedError(RetentionPolicySetupRecordNotTempErr);
        RetentionPolicyLogEntry.FindLast();
        VerifyLogEntry(LastRetentionPolicyLogEntryNo + 1, RetentionPolicyLogEntry."Message Type"::Error, RetentionPolicyLogCategory::"Retention Policy - Apply",
            StrSubstNo(ErrorOccuredDuringApplyErrLbl, RetentionPolicySetup."Table Id", RetentionPolicySetup."Table Name", RetentionPolicySetupRecordNotTempErr));
    end;

    [Test]
    procedure TestApplyRetentionPolicyRecordMustExist()
    var
        TempRetentionPolicySetup: Record "Retention Policy Setup" temporary;
        RetentionPolicyLogEntry: Record "Retention Policy Log Entry";
        RetentionPolicyLog: Codeunit "Retention Policy Log";
        LastRetentionPolicyLogEntryNo: BigInteger;
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        // Setup
        if RetentionPolicyLogEntry.FindLast() then;
        LastRetentionPolicyLogEntryNo := RetentionPolicyLogEntry."Entry No.";
        TempRetentionPolicySetup.SystemId := CreateGuid();
        TempRetentionPolicySetup."Table Id" := Database::"Retention Policy Test Data";
        TempRetentionPolicySetup.CalcFields("Table Name");
        ClearLastError();

        // Exercise
        if not Codeunit.Run(Codeunit::"Apply Retention Policy Impl.", TempRetentionPolicySetup) then
            RetentionPolicyLog.LogError(RetentionPolicyLogCategory::"Retention Policy - Apply", StrSubstNo(ErrorOccuredDuringApplyErrLbl, TempRetentionPolicySetup."Table Id", TempRetentionPolicySetup."Table Name", GetLastErrorText()), false);

        // Verify
        sleep(50);
        Assert.ExpectedError(StrSubstNo(RecordDoesNotExistErr, TempRetentionPolicySetup.SystemId));
        RetentionPolicyLogEntry.FindLast();
        VerifyLogEntry(LastRetentionPolicyLogEntryNo + 1, RetentionPolicyLogEntry."Message Type"::Error, RetentionPolicyLogCategory::"Retention Policy - Apply",
            StrSubstNo(ErrorOccuredDuringApplyErrLbl, TempRetentionPolicySetup."Table Id", TempRetentionPolicySetup."Table Name", StrSubstNo(RecordDoesNotExistErr, TempRetentionPolicySetup.SystemId)));
    end;

    local procedure VerifyLogEntry(EntryNo: BigInteger; MessageType: Enum "Retention Policy Log Message Type"; Category: Enum "Retention Policy Log Category"; Message: Text)
    var
        RetentionPolicyLogEntry: Record "Retention Policy Log Entry";
    begin
        SelectLatestVersion();
        RetentionPolicyLogEntry.Get(EntryNo);
        Assert.AreEqual(MessageType, RetentionPolicyLogEntry."Message Type", 'wrong message type');
        Assert.AreEqual(Category, RetentionPolicyLogEntry.Category, 'wrong category');
        Assert.AreEqual(Message, RetentionPolicyLogEntry.Message, 'wrong message');
    end;
}