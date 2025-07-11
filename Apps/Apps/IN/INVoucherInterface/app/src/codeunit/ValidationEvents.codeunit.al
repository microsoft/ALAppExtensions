// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.VoucherInterface;

using Microsoft.Bank.BankAccount;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Reports;
using Microsoft.Finance.TaxBase;
using Microsoft.Foundation.AuditCodes;

codeunit 18930 "Validation Events"
{
    var
        AccountNoErr: Label 'Cash Account No. %1 should not be used for Sub Voucher Type %2 and Document No. %3.', Comment = '%1 = Account No., %2 = Sub Voucher Type, %3 = Document No.';
        DirectionErr: Label 'Account No. %1 is not defined as %2 account for the Voucher Sub Type %3 and Document No. %4.', Comment = '%1 = Account No., %2 = Direction, %3 = Voucher Sub Type, %4 = Document No.';
        AccountNotDefinedErr: Label 'Account No. is not defined as Both Debit or credit account for the Voucher Sub Type %1 and Document No.%2.', Comment = '%1 = Voucher Sub Type, %2 = Document No.';
        BalAccountTypeShouldNotBeBankAccountErr: Label 'Bal. Account Type should not be Bank Account for Document No. %1.', Comment = '%1 = Document No.';
        AccountTypeShouldNotBeBankAccountErr: Label 'Account Type should not be Bank Account for Document No. %1.', Comment = '%1 = Document No.';
        ShouldBeGLOrBankAccountErr: Label 'Account Type or Bal. Account Type can only be G/L Account or Bank Account for Sub Voucher Type %1 and Document No. %2.', Comment = '%1 = Sub Voucher Type, %2 = Document No.';
        TransactionDirectionErr: Label 'For Contra Voucher %1 is not allowed', Comment = '%1 = Transaction Direction';

    procedure DeleteCrAccounts(LocationCode: Code[20]; Type: Enum "Gen. Journal Template Type")
    var
        VoucherPostingCreditAccount: Record "Voucher Posting Credit Account";
    begin
        VoucherPostingCreditAccount.Reset();
        VoucherPostingCreditAccount.SetRange("Location code", LocationCode);
        VoucherPostingCreditAccount.SetRange(VoucherPostingCreditAccount.Type, Type);
        if VoucherPostingCreditAccount.FindSet() then
            VoucherPostingCreditAccount.DeleteAll();
    end;

    procedure DeleteDrAccounts(LocationCode: Code[20]; Type: Enum "Gen. Journal Template Type")
    var
        VoucherPostingDebitAccount: Record "Voucher Posting Debit Account";
    begin
        VoucherPostingDebitAccount.Reset();
        VoucherPostingDebitAccount.SetRange("Location code", LocationCode);
        VoucherPostingDebitAccount.SetRange(VoucherPostingDebitAccount.Type, Type);
        if VoucherPostingDebitAccount.FindSet() then
            VoucherPostingDebitAccount.DeleteAll();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Template", 'OnAfterValidateType', '', false, false)]
    local procedure UpdateVouchersSourceCode(
        var GenJournalTemplate: Record "Gen. Journal Template";
        SourceCodeSetup: Record "Source Code Setup")
    begin
        SourceCodeSetup.Get();

        GenJournalTemplate."Test Report ID" := Report::"General Journal - Test";
        case GenJournalTemplate.Type of
            GenJournalTemplate.Type::"Cash Receipt Voucher":
                AssignSourceCodeSetupDetails(GenJournalTemplate, SourceCodeSetup."Cash Receipt Voucher", Page::"Cash Receipt Voucher");
            GenJournalTemplate.Type::"Cash Payment Voucher":
                AssignSourceCodeSetupDetails(GenJournalTemplate, SourceCodeSetup."Cash Payment Voucher", Page::"Cash Payment Voucher");
            GenJournalTemplate.Type::"Bank Receipt Voucher":
                AssignSourceCodeSetupDetails(GenJournalTemplate, SourceCodeSetup."Bank Receipt Voucher", Page::"Bank Receipt Voucher");
            GenJournalTemplate.Type::"Bank Payment Voucher":
                AssignSourceCodeSetupDetails(GenJournalTemplate, SourceCodeSetup."Bank Payment Voucher", Page::"Bank Payment Voucher");
            GenJournalTemplate.Type::"Contra Voucher":
                AssignSourceCodeSetupDetails(GenJournalTemplate, SourceCodeSetup."Contra Voucher", Page::"Contra Voucher");
            GenJournalTemplate.Type::"Journal Voucher":
                AssignSourceCodeSetupDetails(GenJournalTemplate, SourceCodeSetup."Journal Voucher", Page::"Journal Voucher");
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Batch", 'OnAfterInsertEvent', '', false, false)]
    local procedure InsertPostingNoSeriesOnInsert(var Rec: Record "Gen. Journal Batch")
    var
        GeneralJournalTemplate: Record "Gen. Journal Template";
        VoucherSetup: Record "Journal Voucher Posting Setup";
    begin
        if GeneralJournalTemplate.Get(Rec."Journal Template Name") and
            VoucherSetup.Get(Rec."Location Code", GeneralJournalTemplate.Type)
        then
            Rec."Posting No. Series" := VoucherSetup."Posting No. Series";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Batch", 'OnAfterValidateEvent', 'Location Code', false, false)]
    local procedure InsertPostingNoSeriesAfterValidateLocation(var Rec: Record "Gen. Journal Batch")
    var
        GeneralJournalTemplate: Record "Gen. Journal Template";
        VoucherSetup: Record "Journal Voucher Posting Setup";
    begin
        Clear(VoucherSetup);
        if GeneralJournalTemplate.Get(Rec."Journal Template Name") and
            VoucherSetup.Get(Rec."Location Code", GeneralJournalTemplate.Type)
        then
            Rec."Posting No. Series" := VoucherSetup."Posting No. Series";
    end;

    [EventSubscriber(ObjectType::Report, Report::"General Journal - Test", 'OnAfterCheckGenJnlLine', '', true, true)]
    local procedure ValidateVoucherAccounts(
        GenJournalLine: Record "Gen. Journal Line";
        sender: Report "General Journal - Test")
    var
        GeneralJournalTemplate: Record "Gen. Journal Template";
        GeneralJournalBatch: Record "Gen. Journal Batch";
        VoucherPostingCrAccount: Record "Voucher Posting Credit Account";
        VoucherSetup: Record "Journal Voucher Posting Setup";
        GenJnlLine1: Record "Gen. Journal Line";
    begin
        GenJnlLine1.Reset();
        GenJnlLine1.SetCurrentKey("Journal Template Name", "Journal Batch Name", "Document No.");
        GenJnlLine1.SetRange("Journal Template Name", GenJournalLine."Journal Template Name");
        GenJnlLine1.SetRange("Journal Batch Name", GenJournalLine."Journal Batch Name");
        GenJnlLine1.SetRange("Document No.", GenJournalLine."Document No.");
        GenJnlLine1.SetFilter(Amount, '<>%1', 0);
        GeneralJournalTemplate.Get(GenJournalLine."Journal Template Name");
        if GeneralJournalTemplate.Type in [GeneralJournalTemplate.Type::"Bank Payment Voucher",
                                          GeneralJournalTemplate.Type::"Cash Payment Voucher",
                                          GeneralJournalTemplate.Type::"Cash Receipt Voucher",
                                          GeneralJournalTemplate.Type::"Bank Receipt Voucher",
                                          GeneralJournalTemplate.Type::"Contra Voucher",
                                          GeneralJournalTemplate.Type::"Journal Voucher"] then begin
            GeneralJournalBatch.Get(GeneralJournalTemplate.Name, GenJournalLine."Journal Batch Name");
            VoucherSetup.Get(GeneralJournalBatch."Location Code", GeneralJournalTemplate.Type);
            if ((VoucherSetup.Type <> VoucherSetup.Type::"Journal Voucher") or (VoucherSetup.Type <> VoucherSetup.Type::"Journal Voucher")) then
                VoucherSetup.TestField("Transaction Direction");

            case VoucherSetup."Transaction Direction" of
                VoucherSetup."Transaction Direction"::Debit:

                    if GenJnlLine1.FindSet() then
                        repeat
                            DefineVoucherDirection(sender, GenJnlLine1, VoucherSetup, GeneralJournalTemplate, GeneralJournalBatch);
                        until GenJnlLine1.Next() = 0;

                VoucherSetup."Transaction Direction"::Credit:
                    if GenJnlLine1.FindSet() then
                        repeat
                            DefineVoucherDirection(sender, GenJnlLine1, VoucherSetup, GeneralJournalTemplate, GeneralJournalBatch);
                        until GenJnlLine1.Next() = 0;
                VoucherSetup."Transaction Direction"::Both:
                    if GenJnlLine1.FindSet() then
                        repeat
                            ValidateVoucherAccount(GeneralJournalTemplate.Type, GenJnlLine1, sender);
                            if not (VoucherPostingCrAccount.Get(GeneralJournalBatch."Location Code", GeneralJournalTemplate.Type, GenJnlLine1."Account Type", GenJnlLine1."Account No.") or
                                        (VoucherPostingCrAccount.Get(GeneralJournalBatch."Location Code", GeneralJournalTemplate.Type, GenJnlLine1."Bal. Account Type", GenJnlLine1."Bal. Account No."))) then
                                sender.AddError(StrSubstNo(AccountNotDefinedErr, GeneralJournalTemplate.Type, GenJnlLine1."Document No."));
                        until GenJnlLine1.Next() = 0;
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateEvent', 'Account No.', false, false)]
    local procedure ValidateLocationFromBatch(var Rec: Record "Gen. Journal Line")
    var
        GenJnBatch: Record "Gen. Journal Batch";
    begin
        if GenJnBatch.Get(Rec."Journal Template Name", Rec."Journal Batch Name") then
            Rec."Location Code" := CopyStr((GenJnBatch."Location Code"), 1, 10);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Journal Voucher Posting Setup", 'OnAfterValidateEvent', 'Transaction Direction', false, false)]
    local procedure OnAfterValidateTransactionDirectionForContraVoucher(var Rec: Record "Journal Voucher Posting Setup")
    begin
        ValidateTransactionDirectionForContraVoucher(Rec);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Base Library", 'OnGetVoucherAccNo', '', false, false)]
    local procedure OnGetVoucherAccNo(var LocationCode: Code[20]; var AccountNo: Code[20]; var ForUpiPayment: Boolean)
    begin
        GetVoucherAccNoAndUpiId(LocationCode, AccountNo, ForUpiPayment);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Base Library", 'OnGetBankAccUpiId', '', false, false)]
    local procedure OnGetBankAccUpiId(BankCode: Code[20]; var UPIID: Text[50])
    begin
        GetBankAccUpiId(BankCode, UPIID);
    end;

    local procedure GetBankAccUpiId(BankCode: Code[20]; var UPIID: Text[50])
    var
        BankAccount: Record "Bank Account";
    begin
        BankAccount.Get(BankCode);
        UPIID := BankAccount."UPI ID";
    end;

    local procedure GetVoucherAccNoAndUpiId(LocationCode: Code[20]; var AccountNo: Code[20]; var ForUpiPayment: Boolean)
    var
        VoucherPostingDebitAcc: Record "Voucher Posting Debit Account";
    begin
        VoucherPostingDebitAcc.SetCurrentKey("Location code");
        VoucherPostingDebitAcc.SetRange("Location code", LocationCode);
        VoucherPostingDebitAcc.SetRange(Type, VoucherPostingDebitAcc.Type::"Bank Receipt Voucher");
        VoucherPostingDebitAcc.SetRange("Account Type", VoucherPostingDebitAcc."Account Type"::"Bank Account");
        VoucherPostingDebitAcc.SetRange("For UPI Payments", true);
        if VoucherPostingDebitAcc.FindFirst() then begin
            AccountNo := VoucherPostingDebitAcc."Account No.";
            ForUpiPayment := VoucherPostingDebitAcc."For UPI Payments";
        end;
    end;

    local procedure ValidateTransactionDirectionForContraVoucher(VoucherPostingSetup: Record "Journal Voucher Posting Setup")
    begin
        if VoucherPostingSetup.Type = VoucherPostingSetup.Type::"Contra Voucher" then
            if VoucherPostingSetup."Transaction Direction" <> VoucherPostingSetup."Transaction Direction"::Both then
                Error(TransactionDirectionErr, VoucherPostingSetup."Transaction Direction");
    end;

    local procedure ValidateVoucherAccount(
        VoucherType: Enum "Gen. Journal Template Type";
        GenJnlLine1: Record "Gen. Journal Line";
        var Sender: Report "General Journal - Test")
    begin
        case VoucherType of
            VoucherType::"Cash Receipt Voucher":
                CheckAccountTypeBalAccTypeForDiffVouchers(Sender, VoucherType, GenJnlLine1);
            VoucherType::"Cash Payment Voucher":
                CheckAccountTypeBalAccTypeForDiffVouchers(Sender, VoucherType, GenJnlLine1);
            VoucherType::"Bank Receipt Voucher":
                CheckAccountTypeBalAccTypeForDiffVouchers(Sender, VoucherType, GenJnlLine1);
            VoucherType::"Bank Payment Voucher":
                CheckAccountTypeBalAccTypeForDiffVouchers(Sender, VoucherType, GenJnlLine1);
            VoucherType::"Journal Voucher":
                begin
                    IdentifyJournalVoucherAccounts(GenJnlLine1, Sender);
                    if GenJnlLine1."Bal. Account Type" = GenJnlLine1."Bal. Account Type"::"Bank Account" then
                        sender.AddError(StrSubstNo(BalAccountTypeShouldNotBeBankAccountErr, GenJnlLine1."Document No."))
                    else
                        if GenJnlLine1."Account Type" = GenJnlLine1."Account Type"::"Bank Account" then
                            sender.AddError(StrSubstNo(AccountTypeShouldNotBeBankAccountErr, GenJnlLine1."Document No."));
                end;
            VoucherType::"Contra Voucher":
                if not (GenJnlLine1."Account Type" in [GenJnlLine1."Account Type"::"Bank Account", GenJnlLine1."Account Type"::"G/L Account"]) or
                    not (GenJnlLine1."Bal. Account Type" in [GenJnlLine1."Bal. Account Type"::"Bank Account", GenJnlLine1."Bal. Account Type"::"G/L Account"])
                then
                    sender.AddError(StrSubstNo(ShouldBeGLOrBankAccountErr, VoucherType, GenJnlLine1."Document No."));
        end;
    end;

    local procedure IdentifyJournalVoucherAccounts(
        GenJnlLine: Record "Gen. Journal Line";
        var Sender: Report "General Journal - Test")
    var
        VoucherSetupCrAccount: Record "Voucher Posting Credit Account";
        VoucherSetupDrAccount: Record "Voucher Posting Debit Account";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlTemplate: Record "Gen. Journal Template";
    begin
        GenJnlTemplate.Get(GenJnlLine."Journal Template Name");
        if GenJnlTemplate.Type in [GenJnlTemplate.Type::"Bank Payment Voucher",
                                  GenJnlTemplate.Type::"Cash Payment Voucher",
                                  GenJnlTemplate.Type::"Cash Receipt Voucher",
                                  GenJnlTemplate.Type::"Bank Receipt Voucher",
                                  GenJnlTemplate.Type::"Contra Voucher",
                                  GenJnlTemplate.Type::"Journal Voucher"] then begin
            GenJnlBatch.Get(GenJnlLine."Journal Template Name", GenJnlLine."Journal Batch Name");
            if (GenJnlLine."Bal. Account No." <> '') and
                (GenJnlLine."Bal. Account Type" = GenJnlLine."Bal. Account Type"::"G/L Account") and
                    (VoucherSetupCrAccount.Get(
                        GenJnlBatch."Location Code",
                        GenJnlTemplate.Type::"Cash Receipt Voucher",
                        GenJnlLine."Bal. Account Type"::"G/L Account",
                        GenJnlLine."Bal. Account No.") or
                    VoucherSetupDrAccount.Get(
                        GenJnlBatch."Location Code",
                        GenJnlTemplate.Type::"Cash Receipt Voucher",
                        GenJnlLine."Bal. Account Type"::"G/L Account",
                        GenJnlLine."Bal. Account No.") or
                    VoucherSetupCrAccount.Get(
                        GenJnlBatch."Location Code",
                        GenJnlTemplate.Type::"Cash Payment Voucher",
                        GenJnlLine."Bal. Account Type"::"G/L Account",
                        GenJnlLine."Bal. Account No.") or
                    VoucherSetupCrAccount.Get(
                        GenJnlBatch."Location Code",
                        GenJnlTemplate.Type::"Cash Payment Voucher",
                        GenJnlLine."Bal. Account Type"::"G/L Account",
                        GenJnlLine."Bal. Account No."))
            then
                Sender.AddError(
                    StrSubstNo(
                        AccountNoErr,
                        GenJnlLine."Bal. Account No.",
                        GenJnlTemplate.Type::"Journal Voucher",
                        GenJnlLine."Document No."));
        end;

        if (GenJnlLine."Account No." <> '') and
            (GenJnlLine."Account Type" = GenJnlLine."Account Type"::"G/L Account") and
            (VoucherSetupCrAccount.Get(
                GenJnlBatch."Location Code",
                GenJnlTemplate.Type::"Cash Receipt Voucher",
                GenJnlLine."Account Type"::"G/L Account",
                GenJnlLine."Account No.") or
            VoucherSetupDrAccount.Get(
                GenJnlBatch."Location Code",
                GenJnlTemplate.Type::"Cash Receipt Voucher",
                GenJnlLine."Account Type"::"G/L Account",
                GenJnlLine."Account No.") or
            VoucherSetupCrAccount.Get(
                GenJnlBatch."Location Code",
                GenJnlTemplate.Type::"Cash Payment Voucher",
                GenJnlLine."Account Type"::"G/L Account",
                GenJnlLine."Account No.") or
            VoucherSetupCrAccount.Get(
                GenJnlBatch."Location Code",
                GenJnlTemplate.Type::"Cash Payment Voucher",
                GenJnlLine."Account Type"::"G/L Account",
                GenJnlLine."Account No."))
        then
            Sender.AddError(
                StrSubstNo(
                    AccountNoErr, GenJnlLine."Account No.", GenJnlTemplate.Type::"Journal Voucher", GenJnlLine."Document No."));
    end;

    local procedure AssignSourceCodeSetupDetails(
        var GenJournalTemplate: Record "Gen. Journal Template";
        SourceCodeSetup: Code[10];
        TemplatePageID: Integer)
    begin
        GenJournalTemplate."Source Code" := SourceCodeSetup;
        GenJournalTemplate."Page ID" := TemplatePageID;
        GenJournalTemplate."Posting Report ID" := Report::"Voucher Register";
    end;

    local procedure DefineVoucherDirection(
        var sender: Report "General Journal - Test";
        GenJournalLine: Record "Gen. Journal Line";
        VoucherSetup: Record "Journal Voucher Posting Setup";
        GeneralJournalTemplate: Record "Gen. Journal Template";
        GeneralJournalBatch: Record "Gen. Journal Batch")
    var
        VoucherPostingDebitAccount: Record "Voucher Posting Debit Account";
        VoucherPostingCreditAccount: Record "Voucher Posting Credit Account";
    begin
        if VoucherSetup."Transaction Direction" = VoucherSetup."Transaction Direction"::Debit then
            if GenJournalLine."Bal. Account No." <> '' then begin
                if GenJournalLine.Amount > 0 then begin
                    ValidateVoucherAccount(GeneralJournalTemplate.Type, GenJournalLine, sender);
                    if not VoucherPostingDebitAccount.Get(GeneralJournalBatch."Location Code", GeneralJournalTemplate.Type, GenJournalLine."Account Type", GenJournalLine."Account No.") then
                        sender.AddError(StrSubstNo(DirectionErr, GenJournalLine."Account No.", VoucherSetup."Transaction Direction", GeneralJournalTemplate.Type, GenJournalLine."Document No."));
                end else begin
                    ValidateVoucherAccount(GeneralJournalTemplate.Type, GenJournalLine, sender);
                    if not VoucherPostingDebitAccount.Get(GeneralJournalBatch."Location Code", GeneralJournalTemplate.Type, GenJournalLine."Bal. Account Type", GenJournalLine."Bal. Account No.") then
                        sender.AddError(StrSubstNo(DirectionErr, GenJournalLine."Bal. Account No.", VoucherSetup."Transaction Direction", GeneralJournalTemplate.Type, GenJournalLine."Document No."))
                end;
            end else
                if GenJournalLine.Amount > 0 then begin
                    ValidateVoucherAccount(GeneralJournalTemplate.Type, GenJournalLine, sender);
                    if not VoucherPostingDebitAccount.Get(GeneralJournalBatch."Location Code", GeneralJournalTemplate.Type, GenJournalLine."Account Type", GenJournalLine."Account No.") then
                        sender.AddError(StrSubstNo(DirectionErr, GenJournalLine."Bal. Account No.", VoucherSetup."Transaction Direction", GeneralJournalTemplate.Type, GenJournalLine."Document No."));
                end;
        if VoucherSetup."Transaction Direction" = VoucherSetup."Transaction Direction"::Credit then
            if GenJournalLine."Bal. Account No." <> '' then begin
                if GenJournalLine.Amount > 0 then begin
                    ValidateVoucherAccount(GeneralJournalTemplate.Type, GenJournalLine, sender);
                    if not VoucherPostingCreditAccount.Get(GeneralJournalBatch."Location Code", GeneralJournalTemplate.Type, GenJournalLine."Account Type", GenJournalLine."Account No.") then
                        sender.AddError(StrSubstNo(DirectionErr, GenJournalLine."Account No.", VoucherSetup."Transaction Direction", GeneralJournalTemplate.Type, GenJournalLine."Document No."));
                end else begin
                    ValidateVoucherAccount(GeneralJournalTemplate.Type, GenJournalLine, sender);
                    if not VoucherPostingCreditAccount.Get(GeneralJournalBatch."Location Code", GeneralJournalTemplate.Type, GenJournalLine."Bal. Account Type", GenJournalLine."Bal. Account No.") then
                        sender.AddError(StrSubstNo(DirectionErr, GenJournalLine."Bal. Account No.", VoucherSetup."Transaction Direction", GeneralJournalTemplate.Type, GenJournalLine."Document No."))
                end;
            end else
                if GenJournalLine.Amount < 0 then begin
                    ValidateVoucherAccount(GeneralJournalTemplate.Type, GenJournalLine, sender);
                    if not VoucherPostingCreditAccount.Get(GeneralJournalBatch."Location Code", GeneralJournalTemplate.Type, GenJournalLine."Account Type", GenJournalLine."Account No.") then
                        sender.AddError(StrSubstNo(DirectionErr, GenJournalLine."Bal. Account No.", VoucherSetup."Transaction Direction", GeneralJournalTemplate.Type, GenJournalLine."Document No."));
                end;
    end;

    local procedure CheckAccountTypeBalAccTypeForDiffVouchers(var GenJournalTest: Report "General Journal - Test"; VoucherType: Enum "Gen. Journal Template Type"; GenJournalLine: Record "Gen. Journal Line")
    begin
        if VoucherType in [VoucherType::"Cash Receipt Voucher", VoucherType::"Bank Receipt Voucher"] then
            if GenJournalLine.Amount > 0 then begin
                if GenJournalLine."Bal. Account Type" = GenJournalLine."Bal. Account Type"::"Bank Account" then
                    GenJournalTest.AddError(StrSubstNo(BalAccountTypeShouldNotBeBankAccountErr, GenJournalLine."Document No."))
            end else
                if GenJournalLine."Account Type" = GenJournalLine."Account Type"::"Bank Account" then
                    GenJournalTest.AddError(StrSubstNo(AccountTypeShouldNotBeBankAccountErr, GenJournalLine."Document No."));
        if VoucherType in [VoucherType::"Cash Payment Voucher", VoucherType::"Bank Payment Voucher"] then
            if GenJournalLine.Amount < 0 then begin
                if GenJournalLine."Bal. Account Type" = GenJournalLine."Bal. Account Type"::"Bank Account" then
                    GenJournalTest.AddError(StrSubstNo(BalAccountTypeShouldNotBeBankAccountErr, GenJournalLine."Document No."))
            end else
                if GenJournalLine."Account Type" = GenJournalLine."Account Type"::"Bank Account" then
                    GenJournalTest.AddError(StrSubstNo(AccountTypeShouldNotBeBankAccountErr, GenJournalLine."Document No."));
    end;
}
