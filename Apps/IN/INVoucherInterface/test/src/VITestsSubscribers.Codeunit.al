codeunit 18997 "VI Tests Subscribers"
{
    var
        LibraryERM: Codeunit "Library - ERM";

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Base Test Publishers", 'InsertJournalVoucherPostingSetup', '', false, false)]
    local procedure GetJournalVoucherPostingSetup(VoucherType: Enum "Gen. Journal Template Type"; TransactionDirection: Option)
    var
        JournalVoucherPostingSetup: Record "Journal Voucher Posting Setup";
    begin
        JournalVoucherPostingSetup.SetRange(Type, VoucherType);
        JournalVoucherPostingSetup.SetRange("Transaction Direction", TransactionDirection);
        if not JournalVoucherPostingSetup.IsEmpty then
            exit;

        JournalVoucherPostingSetup.Init();
        JournalVoucherPostingSetup.Validate(Type, VoucherType);
        JournalVoucherPostingSetup.Validate("Transaction Direction", TransactionDirection);
        JournalVoucherPostingSetup.Insert();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Base Test Publishers", 'InsertJournalVoucherPostingSetupWithLocationCode', '', false, false)]
    local procedure GetJournalVoucherPostingSetupWithLocationCode(
        VoucherType: Enum "Gen. Journal Template Type";
        LocationCode: Code[20];
        TransactionDirection: Option)
    var
        JournalVoucherPostingSetup: Record "Journal Voucher Posting Setup";
    begin
        JournalVoucherPostingSetup.SetRange(Type, VoucherType);
        JournalVoucherPostingSetup.SetRange("Location Code", LocationCode);
        JournalVoucherPostingSetup.SetRange("Transaction Direction", TransactionDirection);
        if not JournalVoucherPostingSetup.IsEmpty then
            exit;

        JournalVoucherPostingSetup.Init();
        JournalVoucherPostingSetup.Validate(Type, VoucherType);
        JournalVoucherPostingSetup.Validate("Location Code", LocationCode);
        JournalVoucherPostingSetup.Validate("Transaction Direction", TransactionDirection);
        JournalVoucherPostingSetup.Insert();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Base Test Publishers", 'InsertVoucherCreditAccountNo', '', false, false)]
    local procedure GetVoucherCreditAccountNo(VoucherType: Enum "Gen. Journal Template Type"; var AccountNo: Code[20])
    var
        VoucherPostingCreditAccount: Record "Voucher Posting Credit Account";
    begin
        VoucherPostingCreditAccount.SetRange(Type, VoucherType);
        VoucherPostingCreditAccount.SetFilter("Account No.", '<>%1', '');
        if VoucherPostingCreditAccount.FindFirst() then begin
            AccountNo := VoucherPostingCreditAccount."Account No.";
            exit;
        end;

        VoucherPostingCreditAccount.Init();
        VoucherPostingCreditAccount.Validate(Type, VoucherType);
        case VoucherType of
            VoucherType::"Bank Payment Voucher":
                begin
                    VoucherPostingCreditAccount.Validate("Account Type", VoucherPostingCreditAccount."Account Type"::"Bank Account");
                    VoucherPostingCreditAccount.Validate("Account No.", LibraryERM.CreateBankAccountNo());
                end;
            VoucherType::"Cash Payment Voucher":
                begin
                    VoucherPostingCreditAccount.Validate("Account Type", VoucherPostingCreditAccount."Account Type"::"G/L Account");
                    VoucherPostingCreditAccount.Validate("Account No.", LibraryERM.CreateGLAccountNo());
                end;
        end;
        VoucherPostingCreditAccount.Insert();
        AccountNo := VoucherPostingCreditAccount."Account No.";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Base Test Publishers", 'InsertVoucherCreditAccountNoWithLocationCode', '', false, false)]
    local procedure GetVoucherCreditAccountNoWithLocationCode(
        VoucherType: Enum "Gen. Journal Template Type";
        LocationCode: Code[20];
        var AccountNo: Code[20])
    var
        VoucherPostingCreditAccount: Record "Voucher Posting Credit Account";
    begin
        VoucherPostingCreditAccount.SetRange(Type, VoucherType);
        VoucherPostingCreditAccount.SetRange("Location code", LocationCode);
        VoucherPostingCreditAccount.SetFilter("Account No.", '<>%1', '');
        if VoucherPostingCreditAccount.FindFirst() then begin
            AccountNo := VoucherPostingCreditAccount."Account No.";
            exit;
        end;

        VoucherPostingCreditAccount.Init();
        VoucherPostingCreditAccount.Validate(Type, VoucherType);
        VoucherPostingCreditAccount.Validate("Location code", LocationCode);
        case VoucherType of
            VoucherType::"Bank Payment Voucher":
                begin
                    if AccountNo = '' then
                        AccountNo := LibraryERM.CreateBankAccountNo();
                    VoucherPostingCreditAccount.Validate("Account Type", VoucherPostingCreditAccount."Account Type"::"Bank Account");
                    VoucherPostingCreditAccount.Validate("Account No.", AccountNo);
                end;
            VoucherType::"Cash Payment Voucher":
                begin
                    if AccountNo = '' then
                        AccountNo := LibraryERM.CreateGLAccountNo();
                    VoucherPostingCreditAccount.Validate("Account Type", VoucherPostingCreditAccount."Account Type"::"G/L Account");
                    VoucherPostingCreditAccount.Validate("Account No.", AccountNo);
                end;
        end;
        VoucherPostingCreditAccount.Insert();
        AccountNo := VoucherPostingCreditAccount."Account No.";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Base Test Publishers", 'InsertVoucherDebitAccountNoWithLocationCode', '', false, false)]
    local procedure GetVoucherDebitAccountNoWithLocationCode(
        VoucherType: Enum "Gen. Journal Template Type";
        LocationCode: Code[20];
        var AccountNo: Code[20])
    var
        VoucherPostingDebitAccount: Record "Voucher Posting Debit Account";
    begin
        VoucherPostingDebitAccount.SetRange(Type, VoucherType);
        VoucherPostingDebitAccount.SetRange("Location code", LocationCode);
        VoucherPostingDebitAccount.SetFilter("Account No.", '<>%1', '');
        if VoucherPostingDebitAccount.FindFirst() then begin
            AccountNo := VoucherPostingDebitAccount."Account No.";
            exit;
        end;

        VoucherPostingDebitAccount.Init();
        VoucherPostingDebitAccount.Validate(Type, VoucherType);
        VoucherPostingDebitAccount.Validate("Location code", LocationCode);
        case VoucherType of
            voucherType::"Bank Receipt Voucher":
                begin
                    if AccountNo = '' then
                        AccountNo := LibraryERM.CreateBankAccountNo();
                    VoucherPostingDebitAccount.Validate("Account Type", VoucherPostingDebitAccount."Account Type"::"Bank Account");
                    VoucherPostingDebitAccount.Validate("Account No.", AccountNo);
                end;
            VoucherType::"Cash Receipt Voucher", Vouchertype::"Journal Voucher":
                begin
                    if AccountNo = '' then
                        AccountNo := LibraryERM.CreateGLAccountNo();
                    VoucherPostingDebitAccount.Validate("Account Type", VoucherPostingDebitAccount."Account Type"::"G/L Account");
                    VoucherPostingDebitAccount.Validate("Account No.", AccountNo);
                end;
        end;
        VoucherPostingDebitAccount.Insert();
        AccountNo := VoucherPostingDebitAccount."Account No.";
    end;
}