codeunit 18970 "Check Management Subscriber"
{
    var
        GLEntry: Record "G/L Entry";
        BankAccLedgEntry2: Record "Bank Account Ledger Entry";
        GenJnlLine2: Record "Gen. Journal Line";
        CheckLedgEntry2: Record "Check Ledger Entry";
        VoidCheckErr: Label 'You cannot Financially Void checks posted in a non-balancing transaction.';
        VoidingCheckErr: Label 'Voiding check %1.', Comment = '%1 = CheckLedgEntry."Check No."';
        NoAppliedEntryErr: Label 'Cannot find an applied entry within the specified filter.';

    procedure FinancialStaleCheck(var CheckLedgEntry: Record "Check Ledger Entry")
    var
        SourceCodeSetup: Record "Source Code Setup";
        BankAcc: Record "Bank Account";
        VATPostingSetup: Record "VAT Posting Setup";
        CustLedgEntry: Record "Cust. Ledger Entry";
        FALedgEntry: Record "FA Ledger Entry";
        VendorLedgEntry: Record "Vendor Ledger Entry";
        BankAccLedgEntry3: Record "Bank Account Ledger Entry";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        TransactionBalance: Decimal;
    begin
        CheckLedgEntry.TestField("Entry Status", CheckLedgEntry."Entry Status"::Posted);
        CheckLedgEntry.TestField("Statement Status", CheckLedgEntry."Statement Status"::Open);
        CheckLedgEntry.TestField("Bal. Account No.");
        BankAcc.Get(CheckLedgEntry."Bank Account No.");
        BankAccLedgEntry2.Get(CheckLedgEntry."Bank Account Ledger Entry No.");
        SourceCodeSetup.Get();
        GLEntry.SetCurrentKey("Transaction No.");
        GLEntry.SetRange("Transaction No.", BankAccLedgEntry2."Transaction No.");
        GLEntry.SetRange("Document No.", BankAccLedgEntry2."Document No.");
        if GLEntry.Find('-') then
            repeat
                TransactionBalance := TransactionBalance + GLEntry.Amount;
            until GLEntry.Next() = 0;
        if TransactionBalance <> 0 then
            Error(VoidCheckErr);

        GenJnlLine2.Init();
        GenJnlLine2."Document No." := CheckLedgEntry."Document No.";
        GenJnlLine2."Account Type" := GenJnlLine2."Account Type"::"Bank Account";
        GenJnlLine2."Posting Date" := CheckLedgEntry."Posting Date";
        GenJnlLine2.Validate("Account No.", CheckLedgEntry."Bank Account No.");
        GenJnlLine2.Description := StrSubstNo(VoidingCheckErr, CheckLedgEntry."Check No.");
        GenJnlLine2.Validate(Amount, CheckLedgEntry.Amount);
        GenJnlLine2."Source Code" := SourceCodeSetup."Financially Voided Check";
        GenJnlLine2."Shortcut Dimension 1 Code" := BankAccLedgEntry2."Global Dimension 1 Code";
        GenJnlLine2."Shortcut Dimension 2 Code" := BankAccLedgEntry2."Global Dimension 2 Code";
        GenJnlLine2."Dimension Set ID" := BankAccLedgEntry2."Dimension Set ID";
        GenJnlLine2."Allow Zero-Amount Posting" := true;
        GenJnlLine2."Cheque No." := BankAccLedgEntry2."Cheque No.";
        GenJnlLine2."Cheque Date" := BankAccLedgEntry2."Cheque Date";
        GenJnlPostLine.Run(GenJnlLine2);

        GenJnlLine2.Init();
        GenJnlLine2."Document No." := CheckLedgEntry."Document No.";
        GenJnlLine2."Account Type" := CheckLedgEntry."Bal. Account Type";
        GenJnlLine2."Posting Date" := CheckLedgEntry."Posting Date";
        GenJnlLine2.Validate("Account No.", CheckLedgEntry."Bal. Account No.");
        GenJnlLine2.Validate("Currency Code", BankAcc."Currency Code");
        GenJnlLine2.Description := StrSubstNo(VoidingCheckErr, CheckLedgEntry."Check No.");
        GenJnlLine2."Source Code" := SourceCodeSetup."Financially Voided Check";
        GenJnlLine2."Allow Zero-Amount Posting" := true;
        case CheckLedgEntry."Bal. Account Type" of
            CheckLedgEntry."Bal. Account Type"::"G/L Account":
                begin
                    GLEntry.SetCurrentKey("Transaction No.");
                    GLEntry.SetRange("Transaction No.", BankAccLedgEntry2."Transaction No.");
                    GLEntry.SetRange("Document No.", BankAccLedgEntry2."Document No.");
                    GLEntry.SetRange("Posting Date", BankAccLedgEntry2."Posting Date");
                    GLEntry.SetFilter("Entry No.", '<>%1', BankAccLedgEntry2."Entry No.");
                    GLEntry.SetRange("G/L Account No.", CheckLedgEntry."Bal. Account No.");
                    if GLEntry.Find('-') then begin
                        GenJnlLine2.Validate("Account No.", GLEntry."G/L Account No.");
                        GenJnlLine2.Validate("Currency Code", BankAcc."Currency Code");
                        GenJnlLine2.Description := StrSubstNo(VoidingCheckErr, CheckLedgEntry."Check No.");
                        GenJnlLine2.Validate(Amount, -CheckLedgEntry.Amount);
                        GenJnlLine2."Shortcut Dimension 1 Code" := GLEntry."Global Dimension 1 Code";
                        GenJnlLine2."Shortcut Dimension 2 Code" := GLEntry."Global Dimension 2 Code";
                        GenJnlLine2."Dimension Set ID" := GLEntry."Dimension Set ID";
                        GenJnlLine2."Gen. Posting Type" := GLEntry."Gen. Posting Type";
                        GenJnlLine2."Gen. Bus. Posting Group" := GLEntry."Gen. Bus. Posting Group";
                        GenJnlLine2."Gen. Prod. Posting Group" := GLEntry."Gen. Prod. Posting Group";
                        GenJnlLine2."VAT Bus. Posting Group" := GLEntry."VAT Bus. Posting Group";
                        GenJnlLine2."VAT Prod. Posting Group" := GLEntry."VAT Prod. Posting Group";
                        if VATPostingSetup.Get(GLEntry."VAT Bus. Posting Group", GLEntry."VAT Prod. Posting Group") then
                            GenJnlLine2."VAT Calculation Type" := VATPostingSetup."VAT Calculation Type";
                        GenJnlPostLine.Run(GenJnlLine2);
                    end;
                end;
            CheckLedgEntry."Bal. Account Type"::Customer:
                begin
                    CustLedgEntry.SetCurrentKey("Transaction No.");
                    CustLedgEntry.SetRange("Transaction No.", BankAccLedgEntry2."Transaction No.");
                    CustLedgEntry.SetRange("Document No.", BankAccLedgEntry2."Document No.");
                    CustLedgEntry.SetRange("Posting Date", BankAccLedgEntry2."Posting Date");
                    if CustLedgEntry.Find('-') then
                        repeat
                            CustLedgEntry.CalcFields("Original Amount");
                            GenJnlLine2.Validate(Amount, -CustLedgEntry."Original Amount");
                            GenJnlLine2."Shortcut Dimension 1 Code" := CustLedgEntry."Global Dimension 1 Code";
                            GenJnlLine2."Shortcut Dimension 2 Code" := CustLedgEntry."Global Dimension 2 Code";
                            GenJnlLine2."Dimension Set ID" := CustLedgEntry."Dimension Set ID";
                            GenJnlPostLine.Run(GenJnlLine2);
                        until CustLedgEntry.Next() = 0;
                end;
            CheckLedgEntry."Bal. Account Type"::Vendor:
                begin
                    VendorLedgEntry.SetCurrentKey("Transaction No.");
                    VendorLedgEntry.SetRange("Transaction No.", BankAccLedgEntry2."Transaction No.");
                    VendorLedgEntry.SetRange("Document No.", BankAccLedgEntry2."Document No.");
                    VendorLedgEntry.SetRange("Posting Date", BankAccLedgEntry2."Posting Date");
                    if VendorLedgEntry.Find('-') then
                        repeat
                            VendorLedgEntry.CalcFields("Original Amount");
                            GenJnlLine2.Validate(Amount, -VendorLedgEntry."Original Amount");
                            MakeAppliesID(GenJnlLine2."Applies-to ID", CheckLedgEntry."Document No.");
                            GenJnlLine2."Shortcut Dimension 1 Code" := VendorLedgEntry."Global Dimension 1 Code";
                            GenJnlLine2."Shortcut Dimension 2 Code" := VendorLedgEntry."Global Dimension 2 Code";
                            GenJnlLine2."Source Currency Code" := VendorLedgEntry."Currency Code";
                            GenJnlLine2."Dimension Set ID" := BankAccLedgEntry2."Dimension Set ID";
                            GenJnlPostLine.Run(GenJnlLine2);
                        until VendorLedgEntry.Next() = 0;
                end;
            CheckLedgEntry."Bal. Account Type"::"Bank Account":
                begin
                    BankAccLedgEntry3.SetCurrentKey("Transaction No.");
                    BankAccLedgEntry3.SetRange("Transaction No.", BankAccLedgEntry2."Transaction No.");
                    BankAccLedgEntry3.SetRange("Document No.", BankAccLedgEntry2."Document No.");
                    BankAccLedgEntry3.SetRange("Posting Date", BankAccLedgEntry2."Posting Date");
                    BankAccLedgEntry3.SetFilter("Entry No.", '<>%1', BankAccLedgEntry2."Entry No.");
                    if BankAccLedgEntry3.Find('-') then
                        repeat
                            GenJnlLine2.Validate(Amount, -BankAccLedgEntry3.Amount);
                            GenJnlLine2."Shortcut Dimension 1 Code" := BankAccLedgEntry3."Global Dimension 1 Code";
                            GenJnlLine2."Shortcut Dimension 2 Code" := BankAccLedgEntry3."Global Dimension 2 Code";
                            GenJnlLine2."Dimension Set ID" := BankAccLedgEntry3."Dimension Set ID";
                            GenJnlPostLine.Run(GenJnlLine2);
                        until BankAccLedgEntry3.Next() = 0;
                end;
            CheckLedgEntry."Bal. Account Type"::"Fixed Asset":
                begin
                    FALedgEntry.SetCurrentKey("Transaction No.");
                    FALedgEntry.SetRange("Transaction No.", BankAccLedgEntry2."Transaction No.");
                    FALedgEntry.SetRange("Document No.", BankAccLedgEntry2."Document No.");
                    FALedgEntry.SetRange("Posting Date", BankAccLedgEntry2."Posting Date");
                    if FALedgEntry.Find('-') then
                        repeat
                            GenJnlLine2.Validate(Amount, -FALedgEntry.Amount);
                            GenJnlLine2."Shortcut Dimension 1 Code" := FALedgEntry."Global Dimension 1 Code";
                            GenJnlLine2."Shortcut Dimension 2 Code" := FALedgEntry."Global Dimension 2 Code";
                            GenJnlLine2."Dimension Set ID" := FALedgEntry."Dimension Set ID";
                            GenJnlPostLine.Run(GenJnlLine2);
                        until FALedgEntry.Next() = 0;
                end else begin
                            GenJnlLine2."Bal. Account Type" := CheckLedgEntry."Bal. Account Type";
                            GenJnlLine2.Validate("Bal. Account No.", CheckLedgEntry."Bal. Account No.");
                            GenJnlLine2."Shortcut Dimension 1 Code" := '';
                            GenJnlLine2."Shortcut Dimension 2 Code" := '';
                            GenJnlPostLine.RunWithoutCheck(GenJnlLine2);
                        end;
        end;
        CheckLedgEntry."Original Entry Status" := CheckLedgEntry."Entry Status";
        CheckLedgEntry."Entry Status" := CheckLedgEntry."Entry Status"::"Financially Voided";
        CheckLedgEntry.Modify();
    end;

    procedure UnApplyCustInvoicesNew(var CheckLedgEntry: Record "Check Ledger Entry"; VoidDate: Date): Boolean
    var
        BankAccLedgEntry: Record "Bank Account Ledger Entry";
        OrigPaymentCustLedgEntry: Record "Cust. Ledger Entry";
        PaymentDetCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
        GenJnlLine3: Record "Gen. Journal Line";
        SourceCodeSetup: Record "Source Code Setup";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        AppliesID: Code[50];
    begin
        // first, find first original payment line, if any
        BankAccLedgEntry.Get(CheckLedgEntry."Bank Account Ledger Entry No.");
        if CheckLedgEntry."Bal. Account Type" = CheckLedgEntry."Bal. Account Type"::Customer then begin
            OrigPaymentCustLedgEntry.SetCurrentKey("Transaction No.");
            OrigPaymentCustLedgEntry.SetRange("Transaction No.", BankAccLedgEntry."Transaction No.");
            OrigPaymentCustLedgEntry.SetRange("Document No.", BankAccLedgEntry."Document No.");
            OrigPaymentCustLedgEntry.SetRange("Posting Date", BankAccLedgEntry."Posting Date");
            if not OrigPaymentCustLedgEntry.FindFirst() then
                exit(false);
        end else
            exit(false);

        AppliesID := CheckLedgEntry."Document No.";

        PaymentDetCustLedgEntry.SetCurrentKey("Cust. Ledger Entry No.", "Entry Type", "Posting Date");
        PaymentDetCustLedgEntry.SetRange("Cust. Ledger Entry No.", OrigPaymentCustLedgEntry."Entry No.");
        PaymentDetCustLedgEntry.SetRange(Unapplied, false);
        PaymentDetCustLedgEntry.SetFilter("Applied Cust. Ledger Entry No.", '<>%1', 0);
        PaymentDetCustLedgEntry.SetRange("Entry Type", PaymentDetCustLedgEntry."Entry Type"::Application);
        if not PaymentDetCustLedgEntry.FindFirst() then
            Error(NoAppliedEntryErr);
        GenJnlLine3."Document No." := OrigPaymentCustLedgEntry."Document No.";
        GenJnlLine3."Posting Date" := VoidDate;
        GenJnlLine3."Account Type" := GenJnlLine3."Account Type"::Customer;
        GenJnlLine3."Account No." := OrigPaymentCustLedgEntry."Customer No.";
        GenJnlLine3.Correction := true;
        GenJnlLine3.Description := StrSubstNo(VoidingCheckErr, CheckLedgEntry."Check No.");
        GenJnlLine3."Shortcut Dimension 1 Code" := OrigPaymentCustLedgEntry."Global Dimension 1 Code";
        GenJnlLine3."Shortcut Dimension 2 Code" := OrigPaymentCustLedgEntry."Global Dimension 2 Code";
        GenJnlLine3."Posting Group" := OrigPaymentCustLedgEntry."Customer Posting Group";
        GenJnlLine3."Source Type" := GenJnlLine3."Source Type"::Customer;
        GenJnlLine3."Source No." := OrigPaymentCustLedgEntry."Customer No.";
        GenJnlLine3."Source Code" := SourceCodeSetup."Financially Voided Check";
        GenJnlLine3."Source Currency Code" := OrigPaymentCustLedgEntry."Currency Code";
        GenJnlLine3."System-Created Entry" := true;
        GenJnlLine3."Financial Void" := true;
        GenJnlPostLine.UnapplyCustLedgEntry(GenJnlLine3, PaymentDetCustLedgEntry);

        OrigPaymentCustLedgEntry.FindSet(true, false);
        repeat
            MakeAppliesID(AppliesID, CheckLedgEntry."Document No.");
            OrigPaymentCustLedgEntry."Applies-to ID" := AppliesID;
            OrigPaymentCustLedgEntry.CalcFields("Remaining Amount");
            OrigPaymentCustLedgEntry."Amount to Apply" := OrigPaymentCustLedgEntry."Remaining Amount";
            OrigPaymentCustLedgEntry."Accepted Pmt. Disc. Tolerance" := false;
            OrigPaymentCustLedgEntry."Accepted Payment Tolerance" := 0;
            OrigPaymentCustLedgEntry.Modify();
        until OrigPaymentCustLedgEntry.Next() = 0;
        exit(true);
    end;

    procedure MakeAppliesID(var AppliesID: Code[50]; CheckDocNo: Code[20])
    var
        AppliesIDCounter: Integer;
    begin
        if AppliesID = '' then
            exit;
        if AppliesID = CheckDocNo then
            AppliesIDCounter := 0;
        AppliesIDCounter := AppliesIDCounter + 1;
        AppliesID :=
          CopyStr(Format(AppliesIDCounter) + CheckDocNo, 1, MaxStrLen(AppliesID));
    end;

    procedure PrintCheck(var NewGenJnlLine: Record "Gen. Journal Line")
    var
        GenJnlLine: Record "Gen. Journal Line";
        ReportSelection: Record "Report Selections";
    begin
        GenJnlLine.Copy(NewGenJnlLine);
        ReportSelection.SetRange(Usage, ReportSelection.Usage::"B.Check");
        ReportSelection.SetFilter("Report ID", '<>%1', 0);
        ReportSelection.Find('-');
        repeat
            Report.RunModal(ReportSelection."Report ID", true, false, GenJnlLine);
        until ReportSelection.Next() = 0;
    end;

    procedure VoidCheckVoucher(var GenJnlLine: Record "Gen. Journal Line")
    var
        Currency: Record Currency;
        GLSetup: Record "General Ledger Setup";
        CheckAmountLCY: Decimal;
    begin
        GenJnlLine.TestField("Bank Payment Type", GenJnlLine2."Bank Payment Type"::"Computer Check");
        GenJnlLine.TestField("Check Printed", true);
        GenJnlLine.TestField("Document No.");

        if GenJnlLine."Bal. Account No." = '' then begin
            GenJnlLine."Check Printed" := false;
            GenJnlLine.Delete(true);
        end;
        CheckAmountLCY := GenJnlLine."Amount (LCY)";
        if GenJnlLine."Currency Code" <> '' then
            Currency.Get(GenJnlLine."Currency Code");
        GenJnlLine2.Reset();
        GenJnlLine2.SetCurrentKey("Journal Template Name", "Journal Batch Name", "Posting Date", "Document No.");
        GenJnlLine2.SetRange("Journal Template Name", GenJnlLine."Journal Template Name");
        GenJnlLine2.SetRange("Journal Batch Name", GenJnlLine."Journal Batch Name");
        GenJnlLine2.SetRange("Posting Date", GenJnlLine."Posting Date");
        GenJnlLine2.SetRange("Document No.", GenJnlLine."Document No.");
        if GenJnlLine2.Find('-') then
            repeat
                if (GenJnlLine2."Line No." > GenJnlLine."Line No.") and
                   (CheckAmountLCY = -GenJnlLine2."Amount (LCY)") and
                   (GenJnlLine2."Currency Code" = '') and (GenJnlLine."Currency Code" <> '') and
                   (GenJnlLine2."Account Type" = GenJnlLine2."Account Type"::"G/L Account") and
                   (GenJnlLine2."Account No." in
                    [Currency."Conv. LCY Rndg. Debit Acc.", Currency."Conv. LCY Rndg. Credit Acc."]) and
                   (GenJnlLine2."Bal. Account No." = '') and not GenJnlLine2."Check Printed"
                then
                    GenJnlLine2.Delete()
                else begin
                    if GenJnlLine."Bal. Account No." = '' then begin
                        if GenJnlLine2."Account No." = '' then begin
                            GenJnlLine2."Account Type" := GenJnlLine2."Account Type"::"Bank Account";
                            GenJnlLine2."Account No." := GenJnlLine."Account No.";
                        end else begin
                            GenJnlLine2."Bal. Account Type" := GenJnlLine2."Account Type"::"Bank Account";
                            GenJnlLine2."Bal. Account No." := GenJnlLine."Account No.";
                        end;
                        GenJnlLine2.Validate(Amount);
                        GenJnlLine2."Bank Payment Type" := GenJnlLine."Bank Payment Type";
                    end;
                    GLSetup.Get();
                    if not GLSetup."Activate Cheque No." then
                        GenJnlLine2."Document No." := ''
                    else begin
                        GenJnlLine2."Cheque No." := '';
                        GenJnlLine2."Cheque Date" := 0D;
                    end;
                    GenJnlLine2."Check Printed" := false;
                    GenJnlLine2.UpdateSource();
                    GenJnlLine2.Modify();
                end;
            until GenJnlLine2.Next() = 0;

        CheckLedgEntry2.Reset();
        CheckLedgEntry2.SetCurrentKey("Bank Account No.", "Entry Status", "Check No.");
        if GenJnlLine.Amount <= 0 then
            CheckLedgEntry2.SetRange("Bank Account No.", GenJnlLine."Account No.")
        else
            CheckLedgEntry2.SetRange("Bank Account No.", GenJnlLine."Bal. Account No.");
        CheckLedgEntry2.SetRange("Entry Status", CheckLedgEntry2."Entry Status"::Printed);
        if not GLSetup."Activate Cheque No." then
            CheckLedgEntry2.SetRange("Check No.", GenJnlLine."Document No.")
        else
            CheckLedgEntry2.SetRange("Check No.", GenJnlLine."Cheque No.");
        CheckLedgEntry2.FindFirst();
        CheckLedgEntry2."Original Entry Status" := CheckLedgEntry2."Entry Status";
        CheckLedgEntry2."Entry Status" := CheckLedgEntry2."Entry Status"::Voided;
        CheckLedgEntry2."Positive Pay Exported" := false;
        CheckLedgEntry2.Open := false;
        CheckLedgEntry2.Modify();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::CheckManagement, 'OnBeforeVoidCheckGenJnlLine2Modify', '', false, false)]
    local procedure OnBeforeVoidCheckGenJnlLine2Modify(
        GenJournalLine: Record "Gen. Journal Line";
        var GenJournalLine2: Record "Gen. Journal Line")
    var
        CheckLedgerEntry: Record "Check Ledger Entry";
        GLSetup: Record "General Ledger Setup";
    begin
        GLSetup.Get();
        if not GLSetup."Activate Cheque No." then
            GenJournalLine2."Document No." := ''
        else begin
            GenJournalLine2."Cheque No." := '';
            GenJournalLine2."Cheque Date" := 0D;
        end;

        CheckLedgerEntry.Reset();
        CheckLedgerEntry.SetCurrentKey("Bank Account No.", "Entry Status", "Check No.");
        if GenJournalLine2.Amount <= 0 then
            CheckLedgerEntry.SetRange("Bank Account No.", GenJournalLine2."Account No.")
        else
            CheckLedgerEntry.SetRange("Bank Account No.", GenJournalLine2."Bal. Account No.");
        CheckLedgerEntry.SetRange("Entry Status", CheckLedgerEntry."Entry Status"::Printed);
        if not GLSetup."Activate Cheque No." then
            CheckLedgerEntry.SetRange("Check No.", GenJournalLine2."Document No.")
        else
            CheckLedgerEntry.SetRange("Check No.", GenJournalLine2."Cheque No.");
        if CheckLedgerEntry.FindFirst() then begin
            CheckLedgerEntry."Original Entry Status" := CheckLedgerEntry."Entry Status";
            CheckLedgerEntry."Entry Status" := CheckLedgerEntry."Entry Status"::Voided;
            CheckLedgerEntry."Positive Pay Exported" := false;
            CheckLedgerEntry.Open := false;
            CheckLedgerEntry.Modify(true);
        end;
    end;
}