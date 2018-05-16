// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

codeunit 136640 "C5 LedTrans Migrator Test"
{
    Subtype=Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        GLAccountCode: Label 'GL001', Locked=true;
        GLAccountCode2: Label 'GL002', Locked=true;
    
    trigger OnRun();
    begin
        // [FEATURE] [C5 Data Migration]
    end;  

    [Test]
    procedure TestLedTransMigrationWithCoA()
    var
        DataMigrationStatus: Record "Data Migration Status";
        GenJournalLine: Record "Gen. Journal Line";
        C5SchemaParameters: Record "C5 Schema Parameters";
        C5MigrDashboardMgt: Codeunit "C5 Migr. Dashboard Mgt";
        CurrentDate: Date;
        FirstTime: Boolean;
    begin
        // [SCENARIO] History transactions are migrated into NAV
        Initialize();

        // [GIVEN] History Migration has been selected
        DataMigrationStatus.Init();
        DataMigrationStatus."Migration Type" := C5MigrDashboardMgt.GetC5MigrationTypeTxt();
        DataMigrationStatus."Destination Table ID" := Database::"C5 LedTrans";
        DataMigrationStatus."Total Number" := 6;
        DataMigrationStatus.Insert();

        // [GIVEN] Chart of Accounts has been migrated
        DataMigrationStatus.Init();
        DataMigrationStatus."Migration Type" := C5MigrDashboardMgt.GetC5MigrationTypeTxt();
        DataMigrationStatus."Destination Table ID" := Database::"G/L Account";
        DataMigrationStatus.Insert();
        CreateGLAccount();

        // [GIVEN] The Period Start Day is 1/1/2017
        C5SchemaParameters.GetSingleInstance();
        C5SchemaParameters.CurrentPeriod := DMY2Date(1, 1, 2017);
        C5SchemaParameters.Modify();

        // [GIVEN] The C5 staging table has been filled
        CreateLedTransEntries();

        // [WHEN] The migration starts
        Migrate();

        // [THEN] General journal lines for the current period are created
        Assert.RecordCount(GenJournalLine, 4);
        FirstTime := true;
        CurrentDate := CalcDate('<-1D>', C5SchemaParameters.CurrentPeriod);
        GenJournalLine.FindSet();
        repeat
            Assert.AreEqual(1000.0, GenJournalLine.Amount, 'Amount was different than expected');
            Assert.AreEqual(0, GenJournalLine."VAT Amount", 'VAT Amount was different than expected');
            Assert.AreEqual(CurrentDate, GenJournalLine."Posting Date", 'Posting Date was different than expected');
            if FirstTime then begin
                FirstTime := false;
                Assert.AreEqual(GLAccountCode, GenJournalLine."Account No.", 'Account No. was different than expected');
            end else begin
                Assert.AreEqual(GLAccountCode2, GenJournalLine."Account No.", 'Account No. was different than expected');
                CurrentDate := CalcDate('<+1D>', CurrentDate);
            end;
        until GenJournalLine.Next() = 0;

        // [THEN] The dashboard shows that the migration is completed and all records have been migrated
        DataMigrationStatus.SetRange("Migration Type", C5MigrDashboardMgt.GetC5MigrationTypeTxt());
        DataMigrationStatus.SetRange("Destination Table ID", Database::"C5 LedTrans");
        DataMigrationStatus.FindFirst();
        Assert.AreEqual(DataMigrationStatus.Status::Completed, DataMigrationStatus.Status, 'Status was expected to be completed');
        Assert.AreEqual(DataMigrationStatus."Total Number", DataMigrationStatus."Migrated Number", 'All records were expected to have been migrated');
    end;

    [Test]
    procedure TestLedTransMigrationWithoutCoA()
    var
        GenJournalLine: Record "Gen. Journal Line";
        DataMigrationStatus: Record "Data Migration Status";
        C5MigrDashboardMgt: Codeunit "C5 Migr. Dashboard Mgt";
    begin
        // [SCENARIO] No General Journal Lines are created if chart of accounts is not migrated
        Initialize();

        // [GIVEN] History Migration has been selected
        DataMigrationStatus.Init();
        DataMigrationStatus."Migration Type" := C5MigrDashboardMgt.GetC5MigrationTypeTxt();
        DataMigrationStatus."Destination Table ID" := Database::"C5 LedTrans";
        DataMigrationStatus."Total Number" := 6;
        DataMigrationStatus.Insert();

        // [GIVEN] The C5 staging table has been filled
        CreateLedTransEntries();

        // [WHEN] The migration starts
        Migrate();

        // [THEN] No General Journal Lines are created
        Assert.RecordIsEmpty(GenJournalLine);

        // [THEN] The dashboard shows that the migration is completed and all records have been migrated
        DataMigrationStatus.SetRange("Migration Type", C5MigrDashboardMgt.GetC5MigrationTypeTxt());
        DataMigrationStatus.SetRange("Destination Table ID", Database::"C5 LedTrans");
        DataMigrationStatus.FindFirst();
        Assert.AreEqual(DataMigrationStatus.Status::Completed, DataMigrationStatus.Status, 'Status was expected to be completed');
        Assert.AreEqual(6, DataMigrationStatus."Migrated Number", 'All records were expected to have been migrated');
    end;

    local procedure Initialize()
    var
        GLAccount: Record "G/L Account";
        GenJournalLine: Record "Gen. Journal Line";
        C5LedTrans: Record "C5 LedTrans";
        DataMigrationStatus: Record "Data Migration Status";
    begin
        GLAccount.DeleteAll();
        C5LedTrans.DeleteAll();
        GenJournalLine.DeleteAll();
        DataMigrationStatus.DeleteAll();
    end;

    local procedure CreateLedTransEntries()
    var
        C5LedTrans: Record "C5 LedTrans";
    begin
        C5LedTrans.Init();
        C5LedTrans.RecId := 1;
        C5LedTrans.Account := CopyStr(GLAccountCode, 1, 10);
        C5LedTrans.AmountMST := 500;
        C5LedTrans.AmountCur := 500;
        C5LedTrans.VatAmount := 0;
        C5LedTrans.Date_ := DMY2Date(1, 9, 2016);
        C5LedTrans.Insert();

        C5LedTrans.Init();
        C5LedTrans.RecId := 2;
        C5LedTrans.Account := CopyStr(GLAccountCode, 1, 10);
        C5LedTrans.AmountMST := 500;
        C5LedTrans.AmountCur := 500;
        C5LedTrans.VatAmount := 0;
        C5LedTrans.Date_ := DMY2Date(1, 10, 2016);
        C5LedTrans.Insert();

        C5LedTrans.Init();
        C5LedTrans.RecId := 3;
        C5LedTrans.Account := CopyStr(GLAccountCode2, 1, 10);
        C5LedTrans.AmountMST := 500;
        C5LedTrans.AmountCur := 500;
        C5LedTrans.VatAmount := 0;
        C5LedTrans.Date_ := DMY2Date(1, 11, 2016);
        C5LedTrans.Insert();

        C5LedTrans.Init();
        C5LedTrans.RecId := 4;
        C5LedTrans.Account := CopyStr(GLAccountCode2, 1, 10);
        C5LedTrans.AmountMST := 500;
        C5LedTrans.AmountCur := 500;
        C5LedTrans.VatAmount := 0;
        C5LedTrans.Date_ := DMY2Date(1, 12, 2016);
        C5LedTrans.Insert();

        C5LedTrans.Init();
        C5LedTrans.RecId := 5;
        C5LedTrans.Account := CopyStr(GLAccountCode2, 1, 10);
        C5LedTrans.AmountMST := 1000;
        C5LedTrans.AmountCur := 1000;
        C5LedTrans.VatAmount := 0;
        C5LedTrans.Date_ := DMY2Date(1, 1, 2017);
        C5LedTrans.Insert();

        C5LedTrans.Init();
        C5LedTrans.RecId := 6;
        C5LedTrans.Account := CopyStr(GLAccountCode2, 1, 10);
        C5LedTrans.AmountMST := 1000;
        C5LedTrans.AmountCur := 1000;
        C5LedTrans.VatAmount := 0;
        C5LedTrans.Date_ := DMY2Date(2, 1, 2017);
        C5LedTrans.Insert();
    end;

    local procedure CreateGLAccount()
    var
        GLAccount: Record "G/L Account";
        C5LedTable: Record "C5 LedTable";
    begin
        GLAccount.Init();
        GLAccount."No." := CopyStr(GLAccountCode, 1, 20);
        GLAccount.Name := 'Some name';
        GLAccount.Insert();

        GLAccount.Init();
        GLAccount."No." := CopyStr(GLAccountCode2, 1, 20);
        GLAccount.Name := 'Some name';
        GLAccount.Insert();

        C5LedTable.Init();
        C5LedTable.Account := CopyStr(GLAccountCode, 1, 10);
        C5LedTable.Insert();
    end;

    local procedure Migrate()
    begin
        Codeunit.Run(Codeunit::"C5 LedTrans Migrator");
    end;
}

