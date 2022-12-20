// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

// These tests rely on codeunit 138704 "Reten. Pol. Test Installer"
// if/when we get the function NavApp.GetCalllerModuleInfo(var Info: ModuleInfo) we can refactor and remove the installer dependency

codeunit 138703 "Reten. Pol. Allowed Tbl. Test"
{
    Subtype = Test;

    var
        Assert: Codeunit "Library Assert";
        PermissionsMock: Codeunit "Permissions Mock";
        TableIdinFilterNotListLbl: Label 'Table %1 appears in the filter but not in the list', Locked = true;
        DatefieldIsWrongLbl: Label 'The datefield number is wrong for table %1', Locked = true;
        MandatoryMinRetentionDaysLbl: Label 'The mandatory minimum number of retention days is wrong for table %1', Locked = true;
        CalcExpirationDateErr: Label 'Wrong expiration date.', Locked = true;
        MaxDateDateFormulaTxt: Label '<+CY+%1Y>', Locked = true;

    [Test]
    procedure TestAddTableIdToAllowedTables()
    var
        RetenPolAllowedTables: Codeunit "Reten. Pol. Allowed Tables";
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        // setup
        // execute
        // verify
        Assert.IsTrue(RetenPolAllowedTables.IsAllowedTable(Database::"Retention Policy Test Data"), 'Retention Policy Test Data should be allowed');
        Assert.IsFalse(RetenPolAllowedTables.IsAllowedTable(Database::"Retention Policy Test Data Two"), 'Retention Policy Test Data Two should not be allowed');
        Assert.IsTrue(RetenPolAllowedTables.IsAllowedTable(Database::"Retention Policy Test Data 3"), 'Retention Policy Test Data 3 should be allowed');
        Assert.IsFalse(RetenPolAllowedTables.IsAllowedTable(17), 'Table 17 should not be allowed');
    end;

    [Test]
    procedure TestRemoveFromAllowedTables()
    var
        RetenPolAllowedTables: Codeunit "Reten. Pol. Allowed Tables";
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        // setup
        Assert.IsTrue(RetenPolAllowedTables.IsAllowedTable(Database::"Retention Policy Test Data 3"), 'should be allowed');

        // execute
        RetenPolAllowedTables.RemoveAllowedTable(Database::"Retention Policy Test Data 3");

        // verify
        Assert.IsFalse(RetenPolAllowedTables.IsAllowedTable(Database::"Retention Policy Test Data 3"), 'should not be allowed');

        // roll back the change
        asserterror error('')
    end;

    [Test]
    procedure TestGetAllowedTablesAsList()
    var
        RetenPolAllowedTables: Codeunit "Reten. Pol. Allowed Tables";
        AllowedTables: List of [Integer];
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        // setup

        // execute
        RetenPolAllowedTables.GetAllowedTables(AllowedTables);

        // verify
        Assert.IsTrue(AllowedTables.Contains(Database::"Retention Policy Test Data"), 'Table Retention Policy Test Data should be allowed');
        Assert.IsTrue(AllowedTables.Contains(Database::"Retention Policy Test Data 3"), 'Table Retention Policy Test Data 3 should be allowed');
        Assert.IsTrue(AllowedTables.Contains(Database::"Retention Policy Log Entry"), 'Table Retention Policy Log Entry should be allowed');
        Assert.IsFalse(AllowedTables.Contains(Database::"Retention Policy Test Data Two"), 'Table Retention Policy Test Data Two should not be allowed');
        Assert.IsFalse(AllowedTables.Contains(17), 'Table G/L Entry should not be allowed');
    end;

    [Test]
    procedure TestGetAllowedTablesAsFilterString()
    var
        RetenPolAllowedTables: Codeunit "Reten. Pol. Allowed Tables";
        AllowedTables: List of [Integer];
        AllowedTablesFilter: Text;
        AllowedTablesCommaSep: Text;
        TableId: Integer;
        i: integer;
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        // setup
        RetenPolAllowedTables.GetAllowedTables(AllowedTables);

        // execute
        AllowedTablesFilter := RetenPolAllowedTables.GetAllowedTables();

        // verify
        Assert.AreNotEqual(0, AllowedTables.Count(), ' The list of allowed tables should not be empty');
        AllowedTablesCommaSep := ConvertStr(AllowedTablesFilter, '|', ',');
        Assert.AreEqual(StrLen(DelChr(AllowedTablesFilter, '=', '0123456789')), AllowedTables.Count() - 1, 'The filter should contain all allowed tables.');
        For i := 1 to AllowedTables.Count do begin
            Evaluate(TableId, SelectStr(i, AllowedTablesCommaSep));
            Assert.IsTrue(AllowedTables.Contains(TableId), StrSubstNo(TableIdinFilterNotListLbl, TableId));
        end;
    end;

    [Test]
    procedure TestGetDefaultDateFieldNo()
    var
        RetentionPolicyTestData: Record "Retention Policy Test Data";
        RetentionPolicyTestData3: Record "Retention Policy Test Data 3";
        RetentionPolicyLogEntry: Record "Retention Policy Log Entry";
        RetenPolAllowedTables: Codeunit "Reten. Pol. Allowed Tables";
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        // setup

        // execute

        // verify
        Assert.AreEqual(RetentionPolicyTestData.FieldNo("Datetime Field"), RetenPolAllowedTables.GetDefaultDateFieldNo(Database::"Retention Policy Test Data"), StrSubsTNo(DatefieldIsWrongLbl, Database::"Retention Policy Test Data"));
        Assert.AreEqual(RetentionPolicyTestData3.FieldNo("Date Field"), RetenPolAllowedTables.GetDefaultDateFieldNo(Database::"Retention Policy Test Data 3"), StrSubsTNo(DatefieldIsWrongLbl, Database::"Retention Policy Test Data 3"));
        Assert.AreEqual(RetentionPolicyLogEntry.FieldNo(SystemCreatedAt), RetenPolAllowedTables.GetDefaultDateFieldNo(Database::"Retention Policy Log Entry"), StrSubsTNo(DatefieldIsWrongLbl, Database::"Retention Policy Log Entry"));
        Assert.AreEqual(0, RetenPolAllowedTables.GetDefaultDateFieldNo(17), StrSubsTNo(DatefieldIsWrongLbl, 17));
    end;

    [Test]
    procedure TestGetMandatoryMinimumRetentionDays()
    var
        RetenPolAllowedTables: Codeunit "Reten. Pol. Allowed Tables";
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        // setup

        // execute

        // verify
        Assert.AreEqual(7, RetenPolAllowedTables.GetMandatoryMinimumRetentionDays(Database::"Retention Policy Test Data"), StrSubsTNo(MandatoryMinRetentionDaysLbl, Database::"Retention Policy Test Data"));
        Assert.AreEqual(0, RetenPolAllowedTables.GetMandatoryMinimumRetentionDays(Database::"Retention Policy Test Data 3"), StrSubsTNo(MandatoryMinRetentionDaysLbl, Database::"Retention Policy Test Data 3"));
        Assert.AreEqual(28, RetenPolAllowedTables.GetMandatoryMinimumRetentionDays(Database::"Retention Policy Log Entry"), StrSubsTNo(MandatoryMinRetentionDaysLbl, Database::"Retention Policy Log Entry"));
        Assert.AreEqual(0, RetenPolAllowedTables.GetMandatoryMinimumRetentionDays(17), StrSubsTNo(MandatoryMinRetentionDaysLbl, 17));
    end;

    [Test]
    procedure TestCalcMinimumExpirationDate()
    var
        RetenPolAllowedTables: Codeunit "Reten. Pol. Allowed Tables";
        ExpirationDate: Date;
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        // setup

        // execute
        ExpirationDate := RetenPolAllowedTables.CalcMinimumExpirationDate(Database::"Retention Policy Test Data"); // 7 days

        // verify
        Assert.AreEqual(CalcDate('<-7D>', Today()), ExpirationDate, CalcExpirationDateErr);
    end;

    [Test]
    procedure TestCalcMinimumExpirationDateMaxDate()
    var
        RetenPolAllowedTables: Codeunit "Reten. Pol. Allowed Tables";
        MaxExpirationDateFormula: DateFormula;
        ExpirationDate: Date;
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        // setup
        Evaluate(MaxExpirationDateFormula, StrSubstNo(MaxDateDateFormulaTxt, 9999 - Date2DMY(Today(), 3)));

        // execute
        ExpirationDate := RetenPolAllowedTables.CalcMinimumExpirationDate(Database::"Retention Policy Test Data 3"); // 0 days

        // verify
        Assert.AreEqual(CalcDate(MaxExpirationDateFormula, Today()), ExpirationDate, CalcExpirationDateErr);
    end;
}