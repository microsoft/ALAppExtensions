// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.VoucherInterface;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.TaxBase;

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
        ContraCashAccountErr: Label 'Account No. %1 is not defined as cash account for the Voucher Sub Type %2 and Document No. %3.', Comment = '%1 = Account No., %2 = Voucher Type, %3 = Document No.';
        ContraBankAccountErr: Label 'Account No. %1 is not defined as bank account for the Voucher Sub Type %2 and Document No. %3.', Comment = '%1 = Account No., %2 = Voucher Type, %3 = Document No.';

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
    begin
        if GenJnlLine.Amount = 0 then
            exit;

        if IsGenJnlTemplateVoucherType(GenJnlTemplate) then begin
            VoucherSetup.Get(GenJnlLine."Location Code", GenJnlTemplate.Type);
            case VoucherSetup."Transaction Direction" of
                VoucherSetup."Transaction Direction"::Debit:
                    CheckAccountNoValidationForVoucherSubType(GenJnlLine, VoucherSetup, GenJnlTemplate);

                VoucherSetup."Transaction Direction"::Credit:
                    CheckAccountNoValidationForVoucherSubType(GenJnlLine, VoucherSetup, GenJnlTemplate);

                VoucherSetup."Transaction Direction"::Both, VoucherSetup."Transaction Direction"::" ":
                    ValidateVoucherAccount(GenJnlTemplate.Type, GenJnlLine);
            end;
        end;
    end;

    local procedure IsGenJnlTemplateVoucherType(GenJnlTemplate: Record "Gen. Journal Template"): Boolean
    var
        IsHandled: Boolean;
        GenJnlTemplateTypeValue: Boolean;
    begin
        OnBeforeGetGenJnlTemplateType(GenJnlTemplate, IsHandled, GenJnlTemplateTypeValue);
        if IsHandled then
            exit(GenJnlTemplateTypeValue);

        if GenJnlTemplate.Type in [
           GenJnlTemplate.Type::"Bank Payment Voucher",
           GenJnlTemplate.Type::"Cash Payment Voucher",
           GenJnlTemplate.Type::"Cash Receipt Voucher",
           GenJnlTemplate.Type::"Bank Receipt Voucher",
           GenJnlTemplate.Type::"Contra Voucher",
           GenJnlTemplate.Type::"Journal Voucher"]
        then
            exit(true);
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
                            if GenJournalLine."Bal. Account No." = '' then
                                if (GenJournalLine."Account Type" <> GenJournalLine."Account Type"::"G/L Account") then
                                    Error(AccountTypeOrBalAccountTypeErr, VoucherType, GenJournalLine."Document No.");

                        GenJournalLine."Account Type"::"Bank Account":
                            if GenJournalLine."Bal. Account No." = '' then
                                if (GenJournalLine."Account Type" <> GenJournalLine."Account Type"::"Bank Account") then
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
        GeneralJnlTemplate: Record "Gen. Journal Template";
    begin
        GeneralJnlTemplate.Get(GenJnlLine."Journal Template Name");
        if not IsContraVoucher then begin
            if (GenJnlLine."Bal. Account No." <> '') and
                (GenJnlLine."Bal. Account Type" = GenJnlLine."Bal. Account Type"::"G/L Account") and
                    (VoucherSetupCrAccount.Get(
                        GenJnlLine."Location Code",
                        GeneralJnlTemplate.Type::"Cash Receipt Voucher",
                        GenJnlLine."Bal. Account Type"::"G/L Account",
                        GenJnlLine."Bal. Account No.") or
                    VoucherSetupDrAccount.Get(
                        GenJnlLine."Location Code",
                        GeneralJnlTemplate.Type::"Cash Receipt Voucher",
                        GenJnlLine."Bal. Account Type"::"G/L Account",
                        GenJnlLine."Bal. Account No.") or
                    VoucherSetupCrAccount.Get(
                        GenJnlLine."Location Code",
                        GeneralJnlTemplate.Type::"Cash Payment Voucher",
                        GenJnlLine."Bal. Account Type"::"G/L Account",
                        GenJnlLine."Bal. Account No.") or
                    VoucherSetupCrAccount.Get(
                        GenJnlLine."Location Code",
                        GeneralJnlTemplate.Type::"Cash Payment Voucher",
                        GenJnlLine."Bal. Account Type"::"G/L Account",
                        GenJnlLine."Bal. Account No."))
            then
                Error(CashAccountErr, GenJnlLine."Bal. Account No.", GeneralJnlTemplate.Type::"Journal Voucher", GenJnlLine."Document No.");

            if (GenJnlLine."Account No." <> '') and
                (GenJnlLine."Account Type" = GenJnlLine."Account Type"::"G/L Account") and
                    (VoucherSetupCrAccount.Get(GenJnlLine."Location Code",
                    GeneralJnlTemplate.Type::"Cash Receipt Voucher",
                    GenJnlLine."Account Type"::"G/L Account",
                    GenJnlLine."Account No.")
                    or
                    VoucherSetupDrAccount.Get(GenJnlLine."Location Code",
                     GeneralJnlTemplate.Type::"Cash Receipt Voucher",
                     GenJnlLine."Account Type"::"G/L Account",
                      GenJnlLine."Account No.")
                    or
                    VoucherSetupCrAccount.Get(GenJnlLine."Location Code",
                    GeneralJnlTemplate.Type::"Cash Payment Voucher",
                    GenJnlLine."Account Type"::"G/L Account",
                    GenJnlLine."Account No.")
                    or
                    VoucherSetupDrAccount.Get(GenJnlLine."Location Code",
                    GeneralJnlTemplate.Type::"Cash Payment Voucher",
                    GenJnlLine."Account Type"::"G/L Account",
                        GenJnlLine."Account No."))
            then
                Error(CashAccountErr, GenJnlLine."Account No.", GeneralJnlTemplate.Type::"Journal Voucher", GenJnlLine."Document No.");
        end;

        if IsContraVoucher then begin
            IdentifyContraAccountForGL(GenJnlLine);
            IdentifyContraAccountForBank(GenJnlLine);
        end;
    end;

    local procedure IdentifyContraAccountForGL(GenJournalLine: Record "Gen. Journal Line")
    var
        VoucherPostingDebitAccount: Record "Voucher Posting Debit Account";
        VoucherPostingCreditAccount: Record "Voucher Posting Credit Account";
        GenJournalTemplate: Record "Gen. Journal Template";
    begin
        GenJournalTemplate.Get(GenJournalLine."Journal Template Name");
        if (GenJournalLine."Bal. Account No." <> '') and
            (GenJournalLine."Bal. Account Type" = GenJournalLine."Bal. Account Type"::"G/L Account")
            and not
            (VoucherPostingDebitAccount.Get(
            GenJournalLine."Location Code",
            GenJournalTemplate.Type::"Cash Receipt Voucher",
            GenJournalLine."Bal. Account Type"::"G/L Account",
            GenJournalLine."Bal. Account No.")
            or
            VoucherPostingCreditAccount.Get(
            GenJournalLine."Location Code",
            GenJournalTemplate.Type::"Cash Receipt Voucher",
            GenJournalLine."Bal. Account Type"::"G/L Account",
            GenJournalLine."Bal. Account No.")
            or
            VoucherPostingDebitAccount.Get(
            GenJournalLine."Location Code",
            GenJournalTemplate.Type::"Cash Payment Voucher",
            GenJournalLine."Bal. Account Type"::"G/L Account",
            GenJournalLine."Bal. Account No.")
            or
            VoucherPostingCreditAccount.Get(
            GenJournalLine."Location Code",
            GenJournalTemplate.Type::"Cash Payment Voucher",
            GenJournalLine."Bal. Account Type"::"G/L Account",
            GenJournalLine."Bal. Account No.")
            or
            VoucherPostingDebitAccount.Get(
            GenJournalLine."Location Code",
            GenJournalTemplate.Type::"Contra Voucher",
            GenJournalLine."Bal. Account Type"::"G/L Account",
            GenJournalLine."Bal. Account No.")
            or
            VoucherPostingCreditAccount.Get(
            GenJournalLine."Location Code",
            GenJournalTemplate.Type::"Contra Voucher",
            GenJournalLine."Bal. Account Type"::"G/L Account",
            GenJournalLine."Bal. Account No."))
        then
            Error(ContraCashAccountErr, GenJournalLine."Bal. Account No.", GenJournalTemplate.Type::"Contra Voucher", GenJournalLine."Document No.");

        if (GenJournalLine."Account No." <> '') and
            (GenJournalLine."Account Type" = GenJournalLine."Account Type"::"G/L Account")
            and not
            (VoucherPostingCreditAccount.Get(
            GenJournalLine."Location Code",
            GenJournalTemplate.Type::"Cash Receipt Voucher",
            GenJournalLine."Account Type"::"G/L Account",
            GenJournalLine."Account No.")
            or
            VoucherPostingDebitAccount.Get(
            GenJournalLine."Location Code",
            GenJournalTemplate.Type::"Cash Receipt Voucher",
            GenJournalLine."Account Type"::"G/L Account",
            GenJournalLine."Account No.")
            or
            VoucherPostingCreditAccount.Get(
            GenJournalLine."Location Code",
            GenJournalTemplate.Type::"Cash Payment Voucher",
            GenJournalLine."Account Type"::"G/L Account",
            GenJournalLine."Account No.")
            or
            VoucherPostingDebitAccount.Get(
            GenJournalLine."Location Code",
            GenJournalTemplate.Type::"Cash Payment Voucher",
            GenJournalLine."Account Type"::"G/L Account",
            GenJournalLine."Account No.")
            or
            VoucherPostingCreditAccount.Get(
            GenJournalLine."Location Code",
            GenJournalTemplate.Type::"Contra Voucher",
            GenJournalLine."Account Type"::"G/L Account",
            GenJournalLine."Account No.")
            or
            VoucherPostingDebitAccount.Get(
            GenJournalLine."Location Code",
            GenJournalTemplate.Type::"Contra Voucher",
            GenJournalLine."Account Type"::"G/L Account",
            GenJournalLine."Account No."))
        then
            Error(ContraCashAccountErr, GenJournalLine."Account No.", GenJournalTemplate.Type::"Contra Voucher", GenJournalLine."Document No.");
    end;

    local procedure IdentifyContraAccountForBank(GenJournalLine: Record "Gen. Journal Line")
    var
        VoucherPostingDebitAccount: Record "Voucher Posting Debit Account";
        VoucherPostingCreditAccount: Record "Voucher Posting Credit Account";
        GenJournalTemplate: Record "Gen. Journal Template";
    begin
        GenJournalTemplate.Get(GenJournalLine."Journal Template Name");
        if (GenJournalLine."Bal. Account No." <> '') and
            (GenJournalLine."Bal. Account Type" = GenJournalLine."Bal. Account Type"::"Bank Account")
            and not
            (VoucherPostingDebitAccount.Get(
            GenJournalLine."Location Code",
            GenJournalTemplate.Type::"Bank Payment Voucher",
            GenJournalLine."Bal. Account Type"::"Bank Account",
            GenJournalLine."Bal. Account No.")
            or
            VoucherPostingCreditAccount.Get(
            GenJournalLine."Location Code",
            GenJournalTemplate.Type::"Bank Receipt Voucher",
            GenJournalLine."Bal. Account Type"::"Bank Account",
            GenJournalLine."Bal. Account No.")
            or
            VoucherPostingDebitAccount.Get(
            GenJournalLine."Location Code",
            GenJournalTemplate.Type::"Bank Payment Voucher",
            GenJournalLine."Bal. Account Type"::"Bank Account",
            GenJournalLine."Bal. Account No.")
            or
            VoucherPostingCreditAccount.Get(
            GenJournalLine."Location Code",
            GenJournalTemplate.Type::"Bank Payment Voucher",
            GenJournalLine."Bal. Account Type"::"Bank Account",
            GenJournalLine."Bal. Account No.")
            or
            VoucherPostingCreditAccount.Get(
            GenJournalLine."Location Code",
            GenJournalTemplate.Type::"Contra Voucher",
            GenJournalLine."Bal. Account Type"::"Bank Account",
            GenJournalLine."Bal. Account No.")
            or
            VoucherPostingDebitAccount.Get(
            GenJournalLine."Location Code",
            GenJournalTemplate.Type::"Contra Voucher",
            GenJournalLine."Bal. Account Type"::"Bank Account",
            GenJournalLine."Bal. Account No."))
        then
            Error(ContraBankAccountErr, GenJournalLine."Bal. Account No.", GenJournalTemplate.Type::"Contra Voucher", GenJournalLine."Document No.");

        if (GenJournalLine."Account No." <> '') and
            (GenJournalLine."Account Type" = GenJournalLine."Account Type"::"Bank Account")
            and not
            (VoucherPostingCreditAccount.Get(GenJournalLine."Location Code",
            GenJournalTemplate.Type::"Bank Receipt Voucher",
            GenJournalLine."Account Type"::"Bank Account",
            GenJournalLine."Account No.")
            or
            VoucherPostingDebitAccount.Get(GenJournalLine."Location Code",
            GenJournalTemplate.Type::"Bank Receipt Voucher",
            GenJournalLine."Account Type"::"Bank Account",
            GenJournalLine."Account No.")
            or
            VoucherPostingCreditAccount.Get(GenJournalLine."Location Code",
            GenJournalTemplate.Type::"Bank Payment Voucher",
            GenJournalLine."Account Type"::"Bank Account",
            GenJournalLine."Account No.")
            or
            VoucherPostingDebitAccount.Get(GenJournalLine."Location Code",
            GenJournalTemplate.Type::"Bank Payment Voucher",
            GenJournalLine."Account Type"::"Bank Account",
            GenJournalLine."Account No.")
            or
            VoucherPostingDebitAccount.Get(
            GenJournalLine."Location Code",
            GenJournalTemplate.Type::"Contra Voucher",
            GenJournalLine."Account Type"::"Bank Account",
            GenJournalLine."Account No.")
            or
            VoucherPostingCreditAccount.Get(
            GenJournalLine."Location Code",
            GenJournalTemplate.Type::"Contra Voucher",
            GenJournalLine."Bal. Account Type"::"Bank Account",
            GenJournalLine."Account No."))
        then
            Error(ContraBankAccountErr, GenJournalLine."Account No.", GenJournalTemplate.Type::"Contra Voucher", GenJournalLine."Document No.");

    end;

    local procedure CheckAccountNoValidationForVoucherSubType(
        GenJournalLine: Record "Gen. Journal Line";
        VoucherSetup: Record "Journal Voucher Posting Setup";
        GeneralJournalTemplate: Record "Gen. Journal Template")
    var
        VoucherPostingDrAccount: Record "Voucher Posting Debit Account";
        VoucherPostingCrAccount: Record "Voucher Posting Credit Account";
    begin
        if VoucherSetup."Transaction Direction" = VoucherSetup."Transaction Direction"::Debit then
            if GenJournalLine."Bal. Account No." <> '' then begin
                if GenJournalLine.Amount > 0 then begin
                    if not VoucherPostingDrAccount.Get(GenJournalLine."Location Code", GeneralJournalTemplate.Type, GenJournalLine."Account Type", GenJournalLine."Account No.") then
                        Error(AccountNoeErr, GenJournalLine."Account No.", VoucherSetup."Transaction Direction", GeneralJournalTemplate.Type, GenJournalLine."Document No.");
                    ValidateVoucherAccount(GeneralJournalTemplate.Type, GenJournalLine);
                end else
                    if not VoucherPostingDrAccount.Get(GenJournalLine."Location Code", GeneralJournalTemplate.Type, GenJournalLine."Bal. Account Type", GenJournalLine."Bal. Account No.") then
                        Error(AccountNoeErr, GenJournalLine."Bal. Account No.", VoucherSetup."Transaction Direction", GeneralJournalTemplate.Type, GenJournalLine."Document No.");
                ValidateVoucherAccount(GeneralJournalTemplate.Type, GenJournalLine);
            end else
                ValidateVoucherPostingDrAccount(GenJournalLine, VoucherSetup, GeneralJournalTemplate);

        if VoucherSetup."Transaction Direction" = VoucherSetup."Transaction Direction"::Credit then
            if GenJournalLine."Bal. Account No." <> '' then begin
                if GenJournalLine.Amount > 0 then begin
                    if not VoucherPostingCrAccount.Get(GenJournalLine."Location Code",
                     GeneralJournalTemplate.Type, GenJournalLine."Bal. Account Type",
                     GenJournalLine."Bal. Account No.") then
                        Error(AccountNoeErr, GenJournalLine."Bal. Account No.",
                        VoucherSetup."Transaction Direction", GeneralJournalTemplate.Type,
                        GenJournalLine."Document No.");
                    ValidateVoucherAccount(GeneralJournalTemplate.Type, GenJournalLine);
                end else
                    if not VoucherPostingCrAccount.Get(GenJournalLine."Location Code", GeneralJournalTemplate.Type, GenJournalLine."Account Type", GenJournalLine."Account No.") then
                        Error(AccountNoeErr, GenJournalLine."Account No.", VoucherSetup."Transaction Direction", GeneralJournalTemplate.Type, GenJournalLine."Document No.");
                ValidateVoucherAccount(GeneralJournalTemplate.Type, GenJournalLine);
            end else
                ValidateVoucherPostingCrAccount(GenJournalLine, VoucherSetup, GeneralJournalTemplate);
    end;

    local procedure ValidateVoucherPostingDrAccount(
        GenJournalLine: Record "Gen. Journal Line";
        VoucherSetup: Record "Journal Voucher Posting Setup";
        GeneralJournalTemplate: Record "Gen. Journal Template")
    var
        VoucherPostingDrAccount: Record "Voucher Posting Debit Account";
        GenJnlLine: Record "Gen. Journal Line";
    begin
        GenJnlLine.SetRange("Journal Template Name", GenJournalLine."Journal Template Name");
        GenJnlLine.SetRange("Journal Batch Name", GenJournalLine."Journal Batch Name");
        GenJnlLine.SetRange("Document No.", GenJournalLine."Document No.");
        GenJnlLine.SetRange("Account Type", GenJnlLine."Account Type"::"G/L Account", GenJnlLine."Account Type"::"Bank Account");
        GenJnlLine.SetFilter("Line No.", '<>%1', GenJournalLine."Line No.");
        if GenJnlLine.FindFirst() then
            if GenJnlLine.Amount < 0 then
                ValidateVoucherAccount(GeneralJournalTemplate.Type, GenJournalLine);
        if GenJournalLine.Amount > 0 then begin
            if not VoucherPostingDrAccount.Get(GenJournalLine."Location Code", GeneralJournalTemplate.Type, GenJournalLine."Account Type", GenJournalLine."Account No.") then
                Error(AccountNoeErr, GenJournalLine."Bal. Account No.", VoucherSetup."Transaction Direction", GeneralJournalTemplate.Type, GenJournalLine."Document No.");
            ValidateVoucherAccount(GeneralJournalTemplate.Type, GenJournalLine);
        end;
    end;

    local procedure ValidateVoucherPostingCrAccount(
        GenJournalLine: Record "Gen. Journal Line";
        VoucherSetup: Record "Journal Voucher Posting Setup";
        GeneralJournalTemplate: Record "Gen. Journal Template")
    var
        VoucherPostingCrAccount: Record "Voucher Posting Credit Account";
        GenJnlLine: Record "Gen. Journal Line";
    begin
        GenJnlLine.SetRange("Journal Template Name", GenJournalLine."Journal Template Name");
        GenJnlLine.SetRange("Journal Batch Name", GenJournalLine."Journal Batch Name");
        GenJnlLine.SetRange("Document No.", GenJournalLine."Document No.");
        GenJnlLine.SetRange("Account Type", GenJnlLine."Account Type"::"G/L Account", GenJnlLine."Account Type"::"Bank Account");
        GenJnlLine.SetFilter("Line No.", '<>%1', GenJournalLine."Line No.");
        if GenJnlLine.FindFirst() then
            if GenJnlLine.Amount > 0 then
                if VoucherPostingCrAccount.Get(GenJournalLine."Location Code", GeneralJournalTemplate.Type, GenJnlLine."Account Type", GenJnlLine."Account No.") then
                    Error(AccountNoeErr, GenJnlLine."Account No.", VoucherSetup."Transaction Direction"::Debit, GeneralJournalTemplate.Type, GenJnlLine."Document No.");
        if GenJournalLine.Amount < 0 then begin
            if not VoucherPostingCrAccount.Get(GenJournalLine."Location Code", GeneralJournalTemplate.Type, GenJournalLine."Account Type", GenJournalLine."Account No.") then
                Error(AccountNoeErr, GenJournalLine."Account No.", VoucherSetup."Transaction Direction", GeneralJournalTemplate.Type, GenJournalLine."Document No.");
            ValidateVoucherAccount(GeneralJournalTemplate.Type, GenJournalLine);
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetGenJnlTemplateType(GenJnlTemplate: Record "Gen. Journal Template"; var IsHandled: Boolean; var GenJnlTemplateTypeValue: Boolean)
    begin
    end;

}
