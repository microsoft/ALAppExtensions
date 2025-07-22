codeunit 139759 "Review G/L Entries Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;
    EventSubscriberInstance = Manual;

    trigger OnRun()
    begin

    end;

    var
        Assert: Codeunit Assert;
        LibraryERM: Codeunit "Library - ERM";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryRandom: Codeunit "Library - Random";
        ReviewGLEntry: Codeunit "Review G/L Entry";


    [Test]
    procedure ZeroEntries()
    var
        GLEntry: record "G/L Entry";
    begin
        // We expect it to fail because G/L Entry is uninitalized and empty.
        GLEntry.SetRange("Entry No.", -1);
        asserterror
        ReviewGLEntry.ReviewEntries(GLEntry);
        Assert.ExpectedError('No entries were selected');
    end;

    [Test]
    procedure ReviewEntriesWithNoReviewPolicy()
    var
        GLAccount: record "G/L Account";
        GLEntry: record "G/L Entry";
    begin
        CreateGeneralLedgerEntriesForGLAccount(GLAccount, "Review Policy Type"::None, false);
        GLEntry.SetRange("G/L Account No.", GLAccount."No.");
        asserterror
        ReviewGLEntry.ReviewEntries(GLEntry);
        Assert.ExpectedError(StrSubstNo('G/L Entries for G/L Account %1 %2 were not marked as reviewed since the G/L Account has Review Policy None', GLAccount."No.", GLAccount.Name));
    end;

    [Test]
    procedure ReviewEntriesWithAllowReview()
    var
        GLAccount: record "G/L Account";
        GLEntry: record "G/L Entry";
    begin
        CreateGeneralLedgerEntriesForGLAccount(GLAccount, "Review Policy Type"::"Allow Review", false);
        GLEntry.SetRange("G/L Account No.", GLAccount."No.");
        ReviewGLEntry.ReviewEntries(GLEntry);
    end;

    [Test]
    procedure ReviewEntriesWithAllowReviewAndMatchBalance()
    var
        GLAccount: record "G/L Account";
        GLEntry: record "G/L Entry";
    begin
        CreateGeneralLedgerEntriesForGLAccount(GLAccount, "Review Policy Type"::"Allow Review and Match Balance", false);
        GLEntry.SetRange("G/L Account No.", GLAccount."No.");
        ReviewGLEntry.ReviewEntries(GLEntry);
    end;

    [Test]
    procedure ReviewEntriesWithAllowReviewAndMatchBalanceWhereBalanceNotMatch()
    var
        GLAccount: record "G/L Account";
        GLEntry: record "G/L Entry";
    begin
        CreateGeneralLedgerEntriesForGLAccount(GLAccount, "Review Policy Type"::"Allow Review and Match Balance", true);
        GLEntry.SetRange("G/L Account No.", GLAccount."No.");
        asserterror
        ReviewGLEntry.ReviewEntries(GLEntry);
        Assert.ExpectedError(StrSubstNo('Selected G/L Entries for G/L Account %1 %2 were not marked as reviewed because credit and debit do not match and the review policy on the account enforces that', GLAccount."No.", GLAccount.Name));
    end;

    [Test]
    procedure ReviewEntriesWithAllowReviewAndMatchBalanceAndAmount()
    var
        GLAccount: record "G/L Account";
        GLEntry: record "G/L Entry";
    begin
        CreateGeneralLedgerEntriesForGLAccount(GLAccount, "Review Policy Type"::"Allow Review and Match Balance", false);
        GLEntry.SetRange("G/L Account No.", GLAccount."No.");
        InsertAmountToReview(GLAccount."No.", false);
        ReviewGLEntry.ReviewEntries(GLEntry);
    end;

    [Test]
    procedure ReviewEntriesWithAllowReviewAndMatchBalanceAndAmountNotMatch()
    var
        GLAccount: record "G/L Account";
        GLEntry: record "G/L Entry";
    begin
        CreateGeneralLedgerEntriesForGLAccount(GLAccount, "Review Policy Type"::"Allow Review and Match Balance", false);
        GLEntry.SetRange("G/L Account No.", GLAccount."No.");
        InsertAmountToReview(GLAccount."No.", true);
        asserterror ReviewGLEntry.ReviewEntries(GLEntry);

        Assert.ExpectedError(StrSubstNo('Selected G/L Entries for G/L Account %1 %2 were not marked as reviewed because credit and debit do not match and the review policy on the account enforces that', GLAccount."No.", GLAccount.Name));
    end;

    [Test]
    procedure ReviewEntriesWithAllowReviewAndMatchBalanceAndAmountErrorOnInput()
    var
        GLAccount: record "G/L Account";
        GLEntry: record "G/L Entry";
        ReviewGLEntries: TestPage "Review G/L Entries";
    begin
        CreateGeneralLedgerEntriesForGLAccount(GLAccount, "Review Policy Type"::"Allow Review and Match Balance", false);
        GLEntry.SetRange("G/L Account No.", GLAccount."No.");
        GLEntry.FindFirst();
        ReviewGLEntries.OpenEdit();
        ReviewGLEntries.GoToRecord(GLEntry);
        if GLEntry."Credit Amount" <> 0 then
            asserterror ReviewGLEntries."Amount to Review".SetValue(GLEntry."Credit Amount" * 0.1)
        else
            asserterror ReviewGLEntries."Amount to Review".SetValue(GLEntry."Debit Amount" * -0.1);

        Assert.ExpectedError('Amount to Review must not be larger than Remaining Amount');
    end;

    local procedure CreateGeneralLedgerEntriesForGLAccount(var GLAccount: record "G/L Account"; ReviewPolicy: enum "Review Policy Type"; RandomAmount: boolean)
    var
        Count: Integer;
    begin
        LibraryERM.CreateGLAccount(GLAccount);
        Commit();
        GLAccount."Review Policy" := ReviewPolicy;
        GLAccount.Modify();
        Commit();
        for Count := 1 to 10 do
            if RandomAmount then
                InsertGLEntry(GLAccount."No.", LibraryRandom.RandDecInRange(100, 200, 2), LibraryRandom.RandDecInRange(100, 200, 2))
            else begin
                InsertGLEntry(GLAccount."No.", 0, Count);
                InsertGLEntry(GLAccount."No.", Count, 0);
            end;
        Commit();
    end;

    local procedure InsertGLEntry(GLAccNo: Code[20]; DebitAmount: Decimal; CreditAmount: Decimal): Integer
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.Init();
        GLEntry."Entry No." := LibraryUtility.GetNewRecNo(GLEntry, GLEntry.FieldNo("Entry No."));
        GLEntry."G/L Account No." := GLAccNo;
        GLEntry."Posting Date" := WorkDate();
        GLEntry."Debit Amount" := DebitAmount;
        GLEntry."Credit Amount" := CreditAmount;
        GLEntry.Insert();
        exit(GLEntry."Entry No.");
    end;

    local procedure InsertAmountToReview(GLAccNo: Code[20]; NotMatch: Boolean)
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.SetRange("G/L Account No.", GLAccNo);
        if GLEntry.FindSet() then
            repeat
                if NotMatch then begin
                    if GLEntry."Debit Amount" <> 0 then
                        GLEntry."Amount to Review" := GLEntry."Debit Amount" * 0.1
                    else
                        GLEntry."Amount to Review" := GLEntry."Credit Amount" * -0.2;
                end else
                    if GLEntry."Debit Amount" <> 0 then
                        GLEntry."Amount to Review" := GLEntry."Debit Amount" * 0.1
                    else
                        GLEntry."Amount to Review" := GLEntry."Credit Amount" * -0.1;

                GLEntry.Modify();
            until GLEntry.Next() = 0;
    end;
}