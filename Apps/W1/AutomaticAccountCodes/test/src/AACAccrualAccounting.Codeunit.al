codeunit 139597 "AAC Accrual Accounting"
{
    // 1. Test to verify GL Entries when General Journal Line is posted with Automatic Account Group.
    // 
    // Covers Test Cases for WI - 350787
    // ------------------------------------------------------------------------------
    // Test Function Name                                                      TFS ID
    // ------------------------------------------------------------------------------
    // PostGeneralJournalLineWithAutomaticAccountGroup                         153593

    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
    end;

    var
        Assert: Codeunit Assert;
        LibraryERM: Codeunit "Library - ERM";
        LibraryAAC: Codeunit "Library - AAC";
        LibraryRandom: Codeunit "Library - Random";
        AmountMustBeEqualMsg: Label 'Amount must be equal.';

    [Test]
    [Scope('OnPrem')]
    procedure PostGeneralJournalLineWithAutomaticAccountGroup()
    var
        GenJournalLine: Record "Gen. Journal Line";
        AutomaticAccHeaderNo: Code[10];
        AllocationPct: Decimal;
    begin
        // Test to verify GL Entries when General Journal Line is posted with Automatic Account Group.

        // Setup: Create General Journal Line with Automatic Account Group.
        AllocationPct := LibraryRandom.RandInt(50);
        AutomaticAccHeaderNo := CreateAutomaticAccountGroup(AllocationPct);
        CreateGeneralJournalLine(GenJournalLine, CreateGLAccountWithAutoAccGroup(AutomaticAccHeaderNo), '');  // Using blank value for Currency Code.

        // Exercise.
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // Verify.
        VerifyAmountOnGLEntries(
          GenJournalLine."Document No.", GetGLAccountFromAccomaticAccountLine(AutomaticAccHeaderNo, AllocationPct),
          AllocationPct * GenJournalLine.Amount / 100, GenJournalLine."Posting Date");
        VerifyAmountOnGLEntries(
          GenJournalLine."Document No.", GetGLAccountFromAccomaticAccountLine(AutomaticAccHeaderNo, -AllocationPct),
          -AllocationPct * GenJournalLine.Amount / 100, GenJournalLine."Posting Date");
    end;

    local procedure CreateAutomaticAccountGroup(AllocationPct: Decimal): Code[10]
    var
        AutomaticAccountHeader: Record "Automatic Account Header";
        GLAccount: Record "G/L Account";
        GLAccount2: Record "G/L Account";
    begin
        LibraryERM.CreateGLAccount(GLAccount);
        LibraryERM.CreateGLAccount(GLAccount2);
        LibraryAAC.CreateAutomaticAccountHeader(AutomaticAccountHeader);
        CreateAutomaticAccountLine(AutomaticAccountHeader."No.", GLAccount."No.", AllocationPct);
        CreateAutomaticAccountLine(AutomaticAccountHeader."No.", GLAccount2."No.", -AllocationPct);
        exit(AutomaticAccountHeader."No.");
    end;

    local procedure CreateAutomaticAccountLine(AutomaticAccNo: Code[10]; GLAccountNo: Code[20]; AllocationPct: Decimal)
    var
        AutomaticAccountLine: Record "Automatic Account Line";
    begin
        LibraryAAC.CreateAutomaticAccountLine(AutomaticAccountLine, AutomaticAccNo);
        AutomaticAccountLine.Validate("G/L Account No.", GLAccountNo);
        AutomaticAccountLine.Validate("Allocation %", AllocationPct);
        AutomaticAccountLine.Modify(true);
    end;

    local procedure CreateGeneralJournalBatch(var GenJournalBatch: Record "Gen. Journal Batch")
    var
        GenJournalTemplate: Record "Gen. Journal Template";
    begin
        GenJournalTemplate.SetRange(Type, GenJournalTemplate.Type::General);
        LibraryERM.FindGenJournalTemplate(GenJournalTemplate);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
    end;

    local procedure CreateGeneralJournalLine(var GenJournalLine: Record "Gen. Journal Line"; AccountNo: Code[20]; CurrencyCode: Code[10])
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GLAccount: Record "G/L Account";
    begin
        LibraryERM.CreateGLAccount(GLAccount);
        CreateGeneralJournalBatch(GenJournalBatch);
        LibraryERM.CreateGeneralJnlLine(
          GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name, GenJournalLine."Document Type"::" ",
          GenJournalLine."Account Type"::"G/L Account", AccountNo, LibraryRandom.RandInt(1000));  // Using random value for Amount.
        GenJournalLine.Validate("Bal. Account Type", GenJournalLine."Bal. Account Type"::"G/L Account");
        GenJournalLine.Validate("Bal. Account No.", GLAccount."No.");
        GenJournalLine.Validate("Currency Code", CurrencyCode);
        GenJournalLine.Modify(true);
    end;

    local procedure CreateGLAccountWithAutoAccGroup(AutoAccGroup: Code[10]): Code[20]
    var
        GLAccount: Record "G/L Account";
    begin
        LibraryERM.CreateGLAccount(GLAccount);
        GLAccount.Validate("Automatic Account Group", AutoAccGroup);
        GLAccount.Modify(true);
        exit(GLAccount."No.");
    end;

    local procedure GetGLAccountFromAccomaticAccountLine(AutomaticAccNo: Code[10]; AllocationPct: Decimal): Code[20]
    var
        AutomaticAccountLine: Record "Automatic Account Line";
    begin
        AutomaticAccountLine.SetRange("Automatic Acc. No.", AutomaticAccNo);
        AutomaticAccountLine.SetRange("Allocation %", AllocationPct);
        AutomaticAccountLine.FindFirst();
        exit(AutomaticAccountLine."G/L Account No.");
    end;

    local procedure VerifyAmountOnGLEntries(DocumentNo: Code[20]; GLAccountNo: Code[20]; Amount: Decimal; PostingDate: Date)
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.SetRange("Document No.", DocumentNo);
        GLEntry.SetRange("G/L Account No.", GLAccountNo);
        GLEntry.SetRange("Posting Date", PostingDate);
        GLEntry.FindFirst();
        Assert.AreNearlyEqual(Amount, GLEntry.Amount, (LibraryERM.GetAmountRoundingPrecision()), AmountMustBeEqualMsg);
    end;
}

