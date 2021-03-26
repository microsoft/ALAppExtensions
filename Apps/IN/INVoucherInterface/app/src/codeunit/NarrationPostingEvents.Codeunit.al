codeunit 18929 "Narration Posting Events"
{
    var
        GenJnlNarration: Record "Gen. Journal Narration";
        PostedNarration: Record "Posted Narration";
        BalAccountTypeErr: Label 'Bal. Account Type should not be Bank Account for Document No. %1.', Comment = '%1 = Document No.';
        AccountTypeErr: Label 'Account Type should not be Bank Account for Document No. %1.', Comment = '%1 = Document No.';
        AccountNoeErr: Label 'Account No. %1 is not defined as %2 account for the Voucher Sub Type %3 and Document No. %4.', Comment = '%1 = Account No., %2 = Direction, %3 = Voucher Subtype, %4 = Document No.';
        AccountTypeOrBalAccountTypeErr: Label 'Account Type or Bal. Account Type can only be G/L Account or Bank Account for Sub Voucher Type %1 and Document No. %2.', Comment = '%1 = Sub Voucher Type, %2 = Document No.';
        CashAccountErr: Label 'Cash Account No. %1 should not be used for Sub Voucher Type %2 and Document No. %3.', Comment = '%1 = Account No., %2 = Voucher Type, %3 = Document No.';
        CashAccountNotExistErr: Label 'Account No. %1 is not define as cash account for document No. %2', Comment = '%1 = GenJnlLine.Account No. %2 = GenJnlLine.Document No.';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeInsertGlobalGLEntry', '', false, false)]
    local procedure InitPostedNarration(
        GenJournalLine: Record "Gen. Journal Line";
        var GlobalGLEntry: Record "G/L Entry")
    begin
        if (GenJournalLine."Journal Template Name" = '') and (GenJournalLine."Journal Batch Name" = '') then
            exit;
        GenJnlNarration.Reset();
        GenJnlNarration.SetRange("Journal Template Name", GenJournalLine."Journal Template Name");
        GenJnlNarration.SetRange("Journal Batch Name", GenJournalLine."Journal Batch Name");
        GenJnlNarration.SetRange("Document No.", GenJournalLine."Narration Document No.");
        GenJnlNarration.SetFilter("Line No.", '<>%1', 0);
        GenJnlNarration.SetRange("Gen. Journal Line No.", 0);
        PostedNarration.Reset();
        PostedNarration.SetCurrentKey("Transaction No.");
        PostedNarration.SetRange("Transaction No.", GlobalGLEntry."Transaction No.");
        if not PostedNarration.FindFirst() then
            if GenJnlNarration.FindSet() then
                repeat
                    InsertPostedNarrationVouchers(GlobalGLEntry);
                until GenJnlNarration.Next() = 0;
        GenJnlNarration.SetRange("Gen. Journal Line No.", GenJournalLine."Line No.");
        if GenJnlNarration.FindSet() then
            repeat
                InsertPostedNarrationLines(GlobalGLEntry);
            until GenJnlNarration.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateEvent', 'Account No.', false, false)]
    local procedure UpdateNarrationDocNoOnAccNo(var Rec: Record "Gen. Journal Line")
    begin
        Rec."Narration Document No." := Rec."Document No.";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateEvent', 'Document No.', false, false)]
    local procedure UpdateNarrationDocNoOnDocumentNo(var Rec: Record "Gen. Journal Line")
    begin
        Rec."Narration Document No." := Rec."Document No.";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Batch", 'OnBeforeIfCheckBalance', '', false, false)]
    local procedure IdentifyVoucherAccounts(
        GenJnlLine: Record "Gen. Journal Line";
        GenJnlTemplate: Record "Gen. Journal Template")
    var
        VoucherSetup: Record "Journal Voucher Posting Setup";
        GeneralJournalBatch: Record "Gen. Journal Batch";
        GenJnlLine2: Record "Gen. Journal Line";
    begin
        GenJnlLine2.Reset();
        GenJnlLine2.SetCurrentKey("Journal Template Name", "Journal Batch Name", "Document No.");
        GenJnlLine2.SetRange("Journal Template Name", GenJnlLine."Journal Template Name");
        GenJnlLine2.SetRange("Journal Batch Name", GenJnlLine."Journal Batch Name");
        GenJnlLine2.SetRange("Document No.", GenJnlLine."Document No.");
        GenJnlLine2.SetFilter(Amount, '<>%1', 0);
        if GenJnlTemplate.Type in [
            GenJnlTemplate.Type::"Bank Payment Voucher",
            GenJnlTemplate.Type::"Cash Payment Voucher",
            GenJnlTemplate.Type::"Cash Receipt Voucher",
            GenJnlTemplate.Type::"Bank Receipt Voucher",
            GenJnlTemplate.Type::"Contra Voucher",
            GenJnlTemplate.Type::"Journal Voucher"]
        then begin
            GeneralJournalBatch.Get(GenJnlTemplate.Name, GenJnlLine."Journal Batch Name");
            VoucherSetup.Get(GeneralJournalBatch."Location Code", GenJnlTemplate.Type);
            case VoucherSetup."Transaction Direction" of
                VoucherSetup."Transaction Direction"::Debit:
                    if GenJnlLine2.FindSet() then
                        repeat
                            CheckAccountNoValidationForVoucherSubType(GenJnlLine2, VoucherSetup, GenJnlTemplate, GeneralJournalBatch);
                        until GenJnlLine2.Next() = 0;
                VoucherSetup."Transaction Direction"::Credit:
                    if GenJnlLine2.FindSet() then
                        repeat
                            CheckAccountNoValidationForVoucherSubType(GenJnlLine2, VoucherSetup, GenJnlTemplate, GeneralJournalBatch);
                        until GenJnlLine2.Next() = 0;
                VoucherSetup."Transaction Direction"::Both:
                    if GenJnlLine2.FindSet() then
                        repeat
                            ValidateVoucherAccount(GenJnlTemplate.Type, GenJnlLine2);
                        until GenJnlLine2.Next() = 0;
            end;
        end;
    end;

    local procedure InsertPostedNarrationVouchers(GLEntry: Record "G/L Entry")
    begin
        PostedNarration.Init();
        PostedNarration."Entry No." := 0;
        PostedNarration."Transaction No." := GLEntry."Transaction No.";
        PostedNarration."Line No." := GenJnlNarration."Line No.";
        PostedNarration."Posting Date" := GLEntry."Posting Date";
        PostedNarration."Document Type" := GLEntry."Document Type";
        PostedNarration."Document No." := GLEntry."Document No.";
        PostedNarration.Narration := GenJnlNarration.Narration;
        PostedNarration.Insert();
    end;

    local procedure InsertPostedNarrationLines(GLEntry: Record "G/L Entry")
    begin
        PostedNarration.Init();
        PostedNarration.Validate("Entry No.", GLEntry."Entry No.");
        PostedNarration."Transaction No." := GLEntry."Transaction No.";
        PostedNarration."Line No." := GenJnlNarration."Line No.";
        PostedNarration."Posting Date" := GLEntry."Posting Date";
        PostedNarration."Document Type" := GLEntry."Document Type";
        PostedNarration."Document No." := GLEntry."Document No.";
        PostedNarration.Narration := GenJnlNarration.Narration;
        PostedNarration.Insert();
    end;

    local procedure ValidateVoucherAccount(
        VoucherType: Enum "Gen. Journal Template Type";
        GenJournalLine: Record "Gen. Journal Line")
    begin
        case VoucherType of
            VoucherType::"Cash Receipt Voucher", VoucherType::"Bank Receipt Voucher":
                if GenJournalLine.Amount > 0 then begin
                    if GenJournalLine."Bal. Account Type" = GenJournalLine."Bal. Account Type"::"Bank Account" then
                        Error(BalAccountTypeErr, GenJournalLine."Document No.")
                end else
                    if GenJournalLine."Account Type" = GenJournalLine."Account Type"::"Bank Account" then
                        Error(AccountTypeErr, GenJournalLine."Document No.");
            VoucherType::"Cash Payment Voucher", VoucherType::"Bank Payment Voucher":
                if GenJournalLine.Amount < 0 then begin
                    if GenJournalLine."Bal. Account Type" = GenJournalLine."Bal. Account Type"::"Bank Account" then
                        Error(BalAccountTypeErr, GenJournalLine."Document No.")
                end else
                    if GenJournalLine."Account Type" = GenJournalLine."Account Type"::"Bank Account" then
                        Error(AccountTypeErr, GenJournalLine."Document No.");
            VoucherType::"Journal Voucher":
                begin
                    IdentifyJournalVoucherAccounts(GenJournalLine, false);
                    if GenJournalLine."Bal. Account Type" = GenJournalLine."Bal. Account Type"::"Bank Account" then
                        Error(BalAccountTypeErr, GenJournalLine."Document No.")
                    else
                        if GenJournalLine."Account Type" = GenJournalLine."Account Type"::"Bank Account" then
                            Error(AccountTypeErr, GenJournalLine."Document No.");
                end;
            VoucherType::"Contra Voucher":
                begin
                    case GenJournalLine."Account Type" of
                        GenJournalLine."Account Type"::"G/L Account":
                            if GenJournalLine."Bal. Account No." = '' then begin
                                if (GenJournalLine."Account Type" <> GenJournalLine."Account Type"::"G/L Account")
                                                                then
                                    Error(AccountTypeOrBalAccountTypeErr, VoucherType, GenJournalLine."Document No.");
                            end else
                                if ((GenJournalLine."Account Type" <> GenJournalLine."Account Type"::"G/L Account") or (GenJournalLine."Bal. Account Type" <> GenJournalLine."Bal. Account Type"::"Bank Account"))
                                                               then
                                    Error(AccountTypeOrBalAccountTypeErr, VoucherType, GenJournalLine."Document No.");
                        GenJournalLine."Account Type"::"Bank Account":
                            if GenJournalLine."Bal. Account No." = '' then begin
                                if (GenJournalLine."Account Type" <> GenJournalLine."Account Type"::"Bank Account")
                                                                then
                                    Error(AccountTypeOrBalAccountTypeErr, VoucherType, GenJournalLine."Document No.");
                            end else
                                if ((GenJournalLine."Account Type" <> GenJournalLine."Account Type"::"Bank Account") or (GenJournalLine."Bal. Account Type" <> GenJournalLine."Bal. Account Type"::"G/L Account"))
                                                                then
                                    Error(AccountTypeOrBalAccountTypeErr, VoucherType, GenJournalLine."Document No.");
                    end;
                    IdentifyJournalVoucherAccounts(GenJournalLine, true);
                end;
        end;
    end;

    local procedure IdentifyJournalVoucherAccounts(GenJnlLine: Record "Gen. Journal Line"; IsContraVoucher: Boolean)
    var
        VoucherSetupCrAccount: Record "Voucher Posting Credit Account";
        VoucherSetupDrAccount: Record "Voucher Posting Debit Account";
        GenJnlBatch: Record "Gen. Journal Batch";
        GeneralJnlTemplate: Record "Gen. Journal Template";
    begin
        GenJnlBatch.Get(GenJnlLine."Journal Template Name", GenJnlLine."Journal Batch Name");
        GeneralJnlTemplate.Get(GenJnlLine."Journal Template Name");
        if not IsContraVoucher then begin
            if (GenJnlLine."Bal. Account No." <> '') and
                (GenJnlLine."Bal. Account Type" = GenJnlLine."Bal. Account Type"::"G/L Account") and
                    (VoucherSetupCrAccount.Get(
                        GenJnlBatch."Location Code",
                        GeneralJnlTemplate.Type::"Cash Receipt Voucher",
                        GenJnlLine."Bal. Account Type"::"G/L Account",
                        GenJnlLine."Bal. Account No.") or
                    VoucherSetupDrAccount.Get(
                        GenJnlBatch."Location Code",
                        GeneralJnlTemplate.Type::"Cash Receipt Voucher",
                        GenJnlLine."Bal. Account Type"::"G/L Account",
                        GenJnlLine."Bal. Account No.") or
                    VoucherSetupCrAccount.Get(
                        GenJnlBatch."Location Code",
                        GeneralJnlTemplate.Type::"Cash Payment Voucher",
                        GenJnlLine."Bal. Account Type"::"G/L Account",
                        GenJnlLine."Bal. Account No.") or
                    VoucherSetupCrAccount.Get(
                        GenJnlBatch."Location Code",
                        GeneralJnlTemplate.Type::"Cash Payment Voucher",
                        GenJnlLine."Bal. Account Type"::"G/L Account",
                        GenJnlLine."Bal. Account No."))
            then
                Error(CashAccountErr, GenJnlLine."Bal. Account No.", GeneralJnlTemplate.Type::"Journal Voucher", GenJnlLine."Document No.");

            if (GenJnlLine."Account No." <> '') and
                (GenJnlLine."Account Type" = GenJnlLine."Account Type"::"G/L Account") and
                    (VoucherSetupCrAccount.Get(GenJnlBatch."Location Code",
                    GeneralJnlTemplate.Type::"Cash Receipt Voucher",
                    GenJnlLine."Account Type"::"G/L Account",
                    GenJnlLine."Account No.")
                    or
                    VoucherSetupDrAccount.Get(GenJnlBatch."Location Code",
                     GeneralJnlTemplate.Type::"Cash Receipt Voucher",
                     GenJnlLine."Account Type"::"G/L Account",
                      GenJnlLine."Account No.")
                    or
                    VoucherSetupCrAccount.Get(GenJnlBatch."Location Code",
                    GeneralJnlTemplate.Type::"Cash Payment Voucher",
                    GenJnlLine."Account Type"::"G/L Account",
                    GenJnlLine."Account No.")
                    or
                    VoucherSetupCrAccount.Get(GenJnlBatch."Location Code",
                    GeneralJnlTemplate.Type::"Cash Payment Voucher",
                    GenJnlLine."Account Type"::"G/L Account",
                        GenJnlLine."Account No."))
            then
                Error(CashAccountErr, GenJnlLine."Account No.", GeneralJnlTemplate.Type::"Journal Voucher", GenJnlLine."Document No.");
        end;
        if ((GenJnlLine."Account No." <> '') and (IsContraVoucher) and
                  (GenJnlLine."Account Type" = GenJnlLine."Account Type"::"G/L Account")) then
            if (not VoucherSetupDrAccount.Get(GenJnlBatch."Location Code",
              GeneralJnlTemplate.Type::"Cash Receipt Voucher",
              GenJnlLine."Account Type"::"G/L Account",
              GenJnlLine."Account No.")) then
                Error(CashAccountNotExistErr, GenJnlLine."Account No.", GenJnlLine."Document No.");
    end;

    local procedure CheckAccountNoValidationForVoucherSubType(
        GenJournalLine: Record "Gen. Journal Line";
        VoucherSetup: Record "Journal Voucher Posting Setup";
        GeneralJournalTemplate: Record "Gen. Journal Template";
        GeneralJournalBatch: Record "Gen. Journal Batch")
    var
        VoucherPostingDrAccount: Record "Voucher Posting Debit Account";
        VoucherPostingCrAccount: Record "Voucher Posting Credit Account";
        GenJnlLine: Record "Gen. Journal Line";
    begin
        if VoucherSetup."Transaction Direction" = VoucherSetup."Transaction Direction"::Debit then
            if GenJournalLine."Bal. Account No." <> '' then begin
                if GenJournalLine.Amount > 0 then begin
                    if not VoucherPostingDrAccount.Get(GeneralJournalBatch."Location Code", GeneralJournalTemplate.Type, GenJournalLine."Account Type", GenJournalLine."Account No.") then
                        Error(AccountNoeErr, GenJournalLine."Account No.", VoucherSetup."Transaction Direction", GeneralJournalTemplate.Type, GenJournalLine."Document No.");
                    ValidateVoucherAccount(GeneralJournalTemplate.Type, GenJournalLine);
                end else
                    if not VoucherPostingDrAccount.Get(GeneralJournalBatch."Location Code", GeneralJournalTemplate.Type, GenJournalLine."Bal. Account Type", GenJournalLine."Bal. Account No.") then
                        Error(AccountNoeErr, GenJournalLine."Bal. Account No.", VoucherSetup."Transaction Direction", GeneralJournalTemplate.Type, GenJournalLine."Document No.");
                ValidateVoucherAccount(GeneralJournalTemplate.Type, GenJournalLine);
            end else begin
                GenJnlLine.SetRange("Journal Template Name", GenJournalLine."Journal Template Name");
                GenJnlLine.SetRange("Journal Batch Name", GenJournalLine."Journal Batch Name");
                GenJnlLine.SetRange("Document No.", GenJournalLine."Document No.");
                GenJnlLine.SetRange("Account Type", GenJnlLine."Account Type"::"G/L Account", GenJnlLine."Account Type"::"Bank Account");
                GenJnlLine.SetFilter("Line No.", '<>%1', GenJournalLine."Line No.");
                if GenJnlLine.FindFirst() then
                    if GenJnlLine.Amount < 0 then
                        if not VoucherPostingDrAccount.Get(GeneralJournalBatch."Location Code", GeneralJournalTemplate.Type, GenJournalLine."Account Type", GenJournalLine."Account No.") then
                            Error(AccountNoeErr, GenJournalLine."Bal. Account No.", VoucherSetup."Transaction Direction"::Credit, GeneralJournalTemplate.Type, GenJournalLine."Document No.");
                if GenJournalLine.Amount > 0 then begin
                    if not VoucherPostingDrAccount.Get(GeneralJournalBatch."Location Code", GeneralJournalTemplate.Type, GenJournalLine."Account Type", GenJournalLine."Account No.") then
                        Error(AccountNoeErr, GenJournalLine."Bal. Account No.", VoucherSetup."Transaction Direction", GeneralJournalTemplate.Type, GenJournalLine."Document No.");
                    ValidateVoucherAccount(GeneralJournalTemplate.Type, GenJournalLine);
                end;
            end;
        if VoucherSetup."Transaction Direction" = VoucherSetup."Transaction Direction"::Credit then
            if GenJournalLine."Bal. Account No." <> '' then begin
                if GenJournalLine.Amount > 0 then begin
                    if not VoucherPostingCrAccount.Get(GeneralJournalBatch."Location Code",
                     GeneralJournalTemplate.Type, GenJournalLine."Bal. Account Type",
                     GenJournalLine."Bal. Account No.") then
                        Error(AccountNoeErr, GenJournalLine."Bal. Account No.",
                        VoucherSetup."Transaction Direction", GeneralJournalTemplate.Type,
                        GenJournalLine."Document No.");
                    ValidateVoucherAccount(GeneralJournalTemplate.Type, GenJournalLine);
                end else
                    if not VoucherPostingCrAccount.Get(GeneralJournalBatch."Location Code", GeneralJournalTemplate.Type, GenJournalLine."Account Type", GenJournalLine."Account No.") then
                        Error(AccountNoeErr, GenJournalLine."Account No.", VoucherSetup."Transaction Direction", GeneralJournalTemplate.Type, GenJournalLine."Document No.");
                ValidateVoucherAccount(GeneralJournalTemplate.Type, GenJournalLine);
            end else begin
                GenJnlLine.SetRange("Journal Template Name", GenJournalLine."Journal Template Name");
                GenJnlLine.SetRange("Journal Batch Name", GenJournalLine."Journal Batch Name");
                GenJnlLine.SetRange("Document No.", GenJournalLine."Document No.");
                GenJnlLine.SetRange("Account Type", GenJnlLine."Account Type"::"G/L Account", GenJnlLine."Account Type"::"Bank Account");
                GenJnlLine.SetFilter("Line No.", '<>%1', GenJournalLine."Line No.");
                if GenJnlLine.FindFirst() then
                    if GenJnlLine.Amount > 0 then
                        if VoucherPostingCrAccount.Get(GeneralJournalBatch."Location Code", GeneralJournalTemplate.Type, GenJnlLine."Account Type", GenJnlLine."Account No.") then
                            Error(AccountNoeErr, GenJnlLine."Account No.", VoucherSetup."Transaction Direction"::Debit, GeneralJournalTemplate.Type, GenJnlLine."Document No.");
                if GenJournalLine.Amount < 0 then begin
                    if not VoucherPostingCrAccount.Get(GeneralJournalBatch."Location Code", GeneralJournalTemplate.Type, GenJournalLine."Account Type", GenJournalLine."Account No.") then
                        Error(AccountNoeErr, GenJournalLine."Account No.", VoucherSetup."Transaction Direction", GeneralJournalTemplate.Type, GenJournalLine."Document No.");
                    ValidateVoucherAccount(GeneralJournalTemplate.Type, GenJournalLine);
                end;
            end;
    end;
}