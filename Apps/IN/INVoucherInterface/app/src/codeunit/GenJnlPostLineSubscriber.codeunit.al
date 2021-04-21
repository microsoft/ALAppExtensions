codeunit 18931 "Gen. Jnl. Post Line Subscriber"
{
    var
        GLSetup: Record "General Ledger Setup";

    procedure UpdtCheckLedgEnrtyComputerCheck(
        GenJournalLine: Record "Gen. Journal Line";
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry")
    var
        CheckLedgEntry: Record "Check Ledger Entry";
        CheckLedgEntry2: Record "Check Ledger Entry";
        DocumentNo: Code[20];
    begin
        GLSetup.Get();
        GenJournalLine.TestField("Check Printed", true);
        CheckLedgEntry.LockTable();
        CheckLedgEntry.Reset();
        CheckLedgEntry.SetCurrentKey("Bank Account No.", "Entry Status", "Check No.");
        CheckLedgEntry.SetRange("Bank Account No.", GenJournalLine."Account No.");
        CheckLedgEntry.SetRange("Entry Status", CheckLedgEntry."Entry Status"::Printed);
        if not GLSetup."Activate Cheque No." then
            CheckLedgEntry.SetRange("Check No.", GenJournalLine."Document No.")
        else
            CheckLedgEntry.SetRange("Check No.", GenJournalLine."Cheque No.");
        if CheckLedgEntry.FindSet() then
            repeat
                CheckLedgEntry2 := CheckLedgEntry;
                CheckLedgEntry2."Entry Status" := CheckLedgEntry2."Entry Status"::Posted;
                CheckLedgEntry2."Bank Account Ledger Entry No." := BankAccountLedgerEntry."Entry No.";
                if GLSetup."Activate Cheque No." then
                    CheckLedgEntry2."Document No." := BankAccountLedgerEntry."Document No.";
                CheckLedgEntry2.Modify();
            until CheckLedgEntry.Next() = 0;
        if GLSetup."Activate Cheque No." then begin
            CheckLedgEntry.LockTable();
            CheckLedgEntry.Reset();
            CheckLedgEntry.SetCurrentKey("Bank Account No.", "Entry Status", "Check No.");
            CheckLedgEntry.SetRange("Bank Account No.", GenJournalLine."Account No.");
            CheckLedgEntry.SetFilter("Entry Status", '%1|%2|%3', CheckLedgEntry."Entry Status"::Voided,
              CheckLedgEntry."Entry Status"::"Financially Voided", CheckLedgEntry."Entry Status"::"Test Print");
            CheckLedgEntry.SetRange("Document No.", DocumentNo);
            if CheckLedgEntry.Find('-') then
                repeat
                    CheckLedgEntry2 := CheckLedgEntry;
                    CheckLedgEntry2."Document No." := BankAccountLedgerEntry."Document No.";
                    CheckLedgEntry2.Modify();
                until CheckLedgEntry.Next() = 0;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnPostBankAccOnBeforeBankAccLedgEntryInsert', '', false, false)]
    local procedure UpdateChequeDetails(
        BankAccount: Record "Bank Account";
        var BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
        var GenJournalLine: Record "Gen. Journal Line")
    begin
        GLSetup.Get();
        if GLSetup."Activate Cheque No." then begin
            BankAccountLedgerEntry."Cheque No." := GenJournalLine."Cheque No.";
            BankAccountLedgerEntry."Cheque Date" := GenJournalLine."Cheque Date";
        end;
        if (not GLSetup."Activate Cheque No.") and (GenJournalLine."Bank Payment Type" in ["Bank Payment Type"::"Manual Check",
                                                                            "Bank Payment Type"::" ",
                                                                            "Bank Payment Type"::"Computer Check"])
        then begin
            BankAccountLedgerEntry."Cheque No." := CopyStr((GenJournalLine."Document No."), 1, 10);
            BankAccountLedgerEntry."Cheque Date" := GenJournalLine."Posting Date";
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnPostBankAccOnAfterBankAccLedgEntryInsert', '', false, false)]
    local procedure UpdateCheckLedgerEntry(
        BankAccount: Record "Bank Account";
        var BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
        var GenJournalLine: Record "Gen. Journal Line")
    begin
        if ((GenJournalLine.Amount <= 0) and (GenJournalLine."Bank Payment Type" = GenJournalLine."Bank Payment Type"::"Computer Check") and GenJournalLine."Check Printed") or
               ((GenJournalLine.Amount < 0) and (GenJournalLine."Bank Payment Type" = GenJournalLine."Bank Payment Type"::"Manual Check"))
            then
            case GenJournalLine."Bank Payment Type" of
                GenJournalLine."Bank Payment Type"::"Computer Check":
                    UpdtCheckLedgEnrtyComputerCheck(GenJournalLine, BankAccountLedgerEntry);
            end;
    end;
}