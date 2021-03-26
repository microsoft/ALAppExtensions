// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

codeunit 148002 "C5 LedTable Migrator Test"
{
    EventSubscriberInstance = Manual;
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        GLAccDataMigrationFacade: Codeunit "GL Acc. Data Migration Facade";
        Department1Txt: Label 'Dep1', Locked = true;
        CostCentre1Txt: Label 'Centre1', Locked = true;
        Purpose1Txt: Label 'Purpose1', Locked = true;

    trigger OnRun();
    begin
        // [FEATURE] [C5 Data Migration]
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestC5LedTableMigration()
    var
        C5LedTable: Record "C5 LedTable";
        GLAccount: Record "G/L Account";
        ExpectedAccountNo: Code[10];
        ExpectedAccountType: Integer;
    begin
        // [SCENARIO] G/L Accounts are migrated from C5
        // [GIVEN] There are no records in G/L Account, G/L Entry, VAT Business Posting Group and staging tables
        ClearTables();

        // [GIVEN] The VAT Business Posting Group has been already migrated
        CreateVATBusPostingGroups();

        // [GIVEN] Some records are created in the staging table
        CreateLedTableEntries(C5LedTable);

        // [WHEN] MigrateAccounts is called
        C5LedTable.FindSet();
        repeat
            Migrate(C5LedTable);
        until C5LedTable.Next() = 0;

        // [THEN] A G/L Account is created for every entry in the staging table
        Assert.RecordCount(GLAccount, C5LedTable.Count());

        // [WHEN] Transactions are Migrated
        CreateOpeningBalances(5);

        // [THEN] The order of the new records and their balance is the same as in the staging table
        C5LedTable.FindSet();
        GLAccount.FindSet();
        repeat
            ExpectedAccountNo := CopyStr(FillWithLeadingZeros(C5LedTable.Account, 5), 1, 10);
            Assert.AreEqual(ExpectedAccountNo, GLAccount."No.",
                StrSubstNo('Account No. was expected to be %1 but it was %2 instead', ExpectedAccountNo, GLAccount."No."));
            Assert.AreEqual(C5LedTable.AccountName, GLAccount.Name,
                StrSubstNo('Account Name was expected to be %1 but it was %2 instead', C5LedTable.AccountName, GLAccount.Name));
            Assert.AreEqual(C5LedTable.DCproposal, GLAccount."Debit/Credit",
                StrSubstNo('%1 account was expected but it was a %2 account instead', C5LedTable.AccountName, GLAccount.Name));

            case C5LedTable.AccountType of
                C5LedTable.AccountType::"Balance a/c",
                C5LedTable.AccountType::"P/L a/c",
                C5LedTable.AccountType::Empty:
                    ExpectedAccountType := GLAccount."Account Type"::Posting;
                C5LedTable.AccountType::"Counter total",
                C5LedTable.AccountType::"Heading total":
                    ExpectedAccountType := GLAccount."Account Type"::Total;
                C5LedTable.AccountType::Heading,
                C5LedTable.AccountType::"New page":
                    ExpectedAccountType := GLAccount."Account Type"::Heading;
            end;
            Assert.AreEqual(ExpectedAccountType, GLAccount."Account Type",
                StrSubstNo('Account Type was different than expected'));

            GLAccount.CalcFields(Balance);
            Assert.AreEqual(C5LedTable.BalanceMST, GLAccount.Balance, 'Balance was different than expected');

            Assert.AreEqual(C5LedTable.Access <> C5LedTable.Access::System, GLAccount."Direct Posting",
                'Direct Posting was different than expected.');

            Assert.AreEqual(C5LedTable.Access = C5LedTable.Access::Locked, GLAccount.Blocked,
                'Blocked was different than expected.');

            CheckDefaultDimensionExists(GLAccount."No.");

            C5LedTable.Next();
        until GLAccount.Next() = 0;
    end;

    local procedure ClearTables()
    var
        C5LedTable: Record "C5 LedTable";
        GLAccount: Record "G/L Account";
        GLEntry: Record "G/L Entry";
        VATBuinesssPostingGroup: Record "VAT Business Posting Group";
    begin
        C5LedTable.DeleteAll();
        GLAccount.DeleteAll();
        GLEntry.DeleteAll();
        VATBuinesssPostingGroup.DeleteAll();
    end;

    local procedure CreateOpeningBalances(MaxAccountLength: Integer)
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.Init();
        GLEntry."Entry No." := 1;
        GLEntry."G/L Account No." := FillWithLeadingZeros('1110', MaxAccountLength);
        GLEntry.Amount := 3721.85;
        GLEntry.Description := 'Opening entry';
        GLEntry.Insert();

        GLEntry.Init();
        GLEntry."Entry No." := 2;
        GLEntry."G/L Account No." := FillWithLeadingZeros('2110', MaxAccountLength);
        GLEntry.Amount := -80;
        GLEntry.Description := 'Opening entry';
        GLEntry.Insert();

        GLEntry.Init();
        GLEntry."Entry No." := 3;
        GLEntry."G/L Account No." := FillWithLeadingZeros('13005', MaxAccountLength);
        GLEntry.Amount := 166379.71;
        GLEntry.Description := 'Opening entry';
        GLEntry.Insert();
    end;

    local procedure FillWithLeadingZeros(Value: Text; MaxLength: Integer): Code[10]
    begin
        exit(PADSTR('', MaxLength - StrLen(Value), '0') + Value);
    end;

    local procedure CreateVATBusPostingGroups()
    var
        VATBuinesssPostingGroup: Record "VAT Business Posting Group";
    begin
        VATBuinesssPostingGroup.Init();
        VATBuinesssPostingGroup.Validate(Code, 'SALG');
        VATBuinesssPostingGroup.Validate(Description, 'SALG');
        VATBuinesssPostingGroup.Insert(true);

        VATBuinesssPostingGroup.Init();
        VATBuinesssPostingGroup.Validate(Code, 'KØB');
        VATBuinesssPostingGroup.Validate(Description, 'KØB');
        VATBuinesssPostingGroup.Insert(true);
    end;

    local procedure Migrate(C5LedTable: Record "C5 LedTable")
    var
        C5LedTableMigrator: Codeunit "C5 LedTable Migrator";
    begin
        C5LedTableMigrator.OnMigrateGlAccount(GLAccDataMigrationFacade, C5LedTable.RecordId());
        C5LedTableMigrator.OnMigrateGlAccountDimensions(GLAccDataMigrationFacade, C5LedTable.RecordId());
    end;

    local procedure CreateLedTableEntries(var C5LedTable: Record "C5 LedTable")
    begin
        C5LedTable.Init();
        C5LedTable.RecId := 1;
        C5LedTable.Account := '1000';
        C5LedTable.AccountName := 'RESULTATOPGØRELSE';
        C5LedTable.DCproposal := C5LedTable.DCproposal::" ";
        C5LedTable.AccountType := C5LedTable.AccountType::Heading;
        C5LedTable.Access := C5LedTable.Access::Locked;
        C5LedTable.Department := CopyStr(Department1Txt, 1, 10);
        C5LedTable.Centre := CopyStr(CostCentre1Txt, 1, 10);
        c5LedTable.Purpose := CopyStr(Purpose1Txt, 1, 10);
        C5LedTable.Insert();

        C5LedTable.Init();
        C5LedTable.RecId := 2;
        C5LedTable.Account := '1001';
        C5LedTable.AccountName := 'OMSÆTNING';
        C5LedTable.DCproposal := C5LedTable.DCproposal::" ";
        C5LedTable.AccountType := C5LedTable.AccountType::Heading;
        C5LedTable.Access := C5LedTable.Access::Locked;
        C5LedTable.Department := CopyStr(Department1Txt, 1, 10);
        C5LedTable.Centre := CopyStr(CostCentre1Txt, 1, 10);
        C5LedTable.Purpose := CopyStr(Purpose1Txt, 1, 10);
        C5LedTable.Insert();

        C5LedTable.Init();
        C5LedTable.RecId := 3;
        C5LedTable.Account := '1110';
        C5LedTable.AccountName := 'Varesalg - Stole';
        C5LedTable.DCproposal := C5LedTable.DCproposal::Credit;
        C5LedTable.AccountType := C5LedTable.AccountType::"P/L a/c";
        C5LedTable.Vat := 'Salg';
        C5LedTable.BalanceMST := 3721.85;
        C5LedTable.Access := C5LedTable.Access::Open;
        C5LedTable.Department := CopyStr(Department1Txt, 1, 10);
        C5LedTable.Centre := CopyStr(CostCentre1Txt, 1, 10);
        C5LedTable.Purpose := CopyStr(Purpose1Txt, 1, 10);
        C5LedTable.Insert();

        C5LedTable.Init();
        C5LedTable.RecId := 4;
        C5LedTable.Account := '1999';
        C5LedTable.AccountName := 'OMSÆTNING I ALT';
        C5LedTable.DCproposal := C5LedTable.DCproposal::" ";
        C5LedTable.AccountType := C5LedTable.AccountType::"Heading total";
        C5LedTable.TotalFromAccount := '1000';
        C5LedTable.BalanceMST := 3721.85;
        C5LedTable.Access := C5LedTable.Access::Locked;
        C5LedTable.Department := CopyStr(Department1Txt, 1, 10);
        C5LedTable.Centre := CopyStr(CostCentre1Txt, 1, 10);
        C5LedTable.Purpose := CopyStr(Purpose1Txt, 1, 10);
        C5LedTable.Insert();

        C5LedTable.Init();
        C5LedTable.RecId := 5;
        C5LedTable.Account := '2110';
        C5LedTable.AccountName := 'Vareforbrug - Stole';
        C5LedTable.DCproposal := C5LedTable.DCproposal::Debit;
        C5LedTable.AccountType := C5LedTable.AccountType::"P/L a/c";
        C5LedTable.Vat := 'Køb';
        C5LedTable.BalanceMST := -80;
        C5LedTable.Access := C5LedTable.Access::Open;
        C5LedTable.Department := CopyStr(Department1Txt, 1, 10);
        C5LedTable.Centre := CopyStr(CostCentre1Txt, 1, 10);
        C5LedTable.Purpose := CopyStr(Purpose1Txt, 1, 10);
        C5LedTable.Insert();

        C5LedTable.Init();
        C5LedTable.RecId := 6;
        C5LedTable.Account := '13005';
        C5LedTable.AccountName := 'Varelager primo';
        C5LedTable.DCproposal := C5LedTable.DCproposal::" ";
        C5LedTable.AccountType := C5LedTable.AccountType::"Balance a/c";
        C5LedTable.BalanceMST := 166379.71;
        C5LedTable.Access := C5LedTable.Access::Open;
        C5LedTable.Department := CopyStr(Department1Txt, 1, 10);
        C5LedTable.Centre := CopyStr(CostCentre1Txt, 1, 10);
        C5LedTable.Purpose := CopyStr(Purpose1Txt, 1, 10);
        C5LedTable.Insert();

        C5LedTable.Init();
        C5LedTable.RecId := 7;
        C5LedTable.Account := '22999';
        C5LedTable.AccountName := 'I ALT LIG NUL';
        C5LedTable.DCproposal := C5LedTable.DCproposal::" ";
        C5LedTable.AccountType := C5LedTable.AccountType::"Heading total";
        C5LedTable.TotalFromAccount := '1000';
        C5LedTable.BalanceMST := 170021.56;
        C5LedTable.Access := C5LedTable.Access::Locked;
        C5LedTable.Department := CopyStr(Department1Txt, 1, 10);
        C5LedTable.Centre := CopyStr(CostCentre1Txt, 1, 10);
        C5LedTable.Purpose := CopyStr(Purpose1Txt, 1, 10);
        C5LedTable.Insert();
    end;

    local procedure CheckDefaultDimensionExists(GLAccountNo: Text[20])
    var
        DefaultDimension: Record "Default Dimension";
    begin
        DefaultDimension.SetRange("Table ID", Database::"G/L Account");
        DefaultDimension.SetRange("No.", GLAccountNo);
        DefaultDimension.SetRange("Dimension Code", 'C5DEPARTMENT');
        Assert.IsTrue(DefaultDimension.FindFirst(), 'Default dimension not found');
        Assert.AreEqual(Uppercase(Department1Txt), DefaultDimension."Dimension Value Code", 'Incorrect value in department dimension.');

        DefaultDimension.SetRange("Dimension Code", 'C5COSTCENTRE');
        Assert.IsTrue(DefaultDimension.FindFirst(), 'Default dimension not found');
        Assert.AreEqual(Uppercase(CostCentre1Txt), DefaultDimension."Dimension Value Code", 'Incorrect value in cost center dimension.');

        DefaultDimension.SetRange("Dimension Code", 'C5PURPOSE');
        Assert.IsTrue(DefaultDimension.FindFirst(), 'Default dimension not found');
        Assert.AreEqual(Uppercase(Purpose1Txt), DefaultDimension."Dimension Value Code", 'Incorrect value in purpose dimension.');
    end;
}
