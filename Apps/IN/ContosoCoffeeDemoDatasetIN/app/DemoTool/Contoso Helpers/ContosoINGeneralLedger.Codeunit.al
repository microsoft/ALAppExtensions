// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoTool.Helpers;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Bank.VoucherInterface;

codeunit 19021 "Contoso IN General Ledger"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "Gen. Journal Template" = rim,
        tabledata "Journal Voucher Posting Setup" = rim,
        tabledata "Voucher Posting Credit Account" = rim;

    var
        OverwriteData: Boolean;

    procedure InsertGeneralJournalTemplate(Name: Code[10]; Description: Text[80]; Type: Enum "Gen. Journal Template Type"; PageID: Integer; NoSeries: Code[20]; PostingNoSeries: Code[20]; PostingReportID: Integer; SourceCode: Code[10]; CopytoPostedJnlLines: Boolean)
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        Exists: Boolean;
    begin
        if GenJournalTemplate.Get(Name) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        GenJournalTemplate.Validate(Name, Name);
        GenJournalTemplate.Validate(Description, Description);
        GenJournalTemplate.Validate(Type, Type);
        GenJournalTemplate.Validate("Page ID", PageID);
        GenJournalTemplate.Validate("No. Series", NoSeries);
        GenJournalTemplate.Validate("Posting No. Series", PostingNoSeries);
        GenJournalTemplate.Validate("Posting Report ID", PostingReportID);
        GenJournalTemplate.Validate("Copy to Posted Jnl. Lines", CopytoPostedJnlLines);

        if Exists then
            GenJournalTemplate.Modify(true)
        else
            GenJournalTemplate.Insert(true);

        if SourceCode <> '' then begin
            GenJournalTemplate.Validate("Source Code", SourceCode);
            GenJournalTemplate.Modify(true);
        end;
    end;

    procedure InsertVoucherPostingSetup(LocationCode: Code[10]; TemplateType: Enum "Gen. Journal Template Type"; PostingNoSeries: Code[20]; TransactionDirection: Integer)
    var
        JournalVoucherPostingSetup: Record "Journal Voucher Posting Setup";
        Exists: Boolean;
    begin
        if JournalVoucherPostingSetup.Get(LocationCode, TemplateType) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        JournalVoucherPostingSetup.Validate("Location Code", LocationCode);
        JournalVoucherPostingSetup.Validate(Type, TemplateType);
        JournalVoucherPostingSetup.Validate("Posting No. Series", PostingNoSeries);
        JournalVoucherPostingSetup."Transaction Direction" := TransactionDirection;

        if Exists then
            JournalVoucherPostingSetup.Modify(true)
        else
            JournalVoucherPostingSetup.Insert(true);
    end;

    procedure InsertVoucherPostingCreditAccount(LocationCode: Code[10]; TemplateType: Enum "Gen. Journal Template Type"; AccountType: Enum "Gen. Journal Account Type"; AccountNo: Code[20])
    var
        VoucherPostingCreditAccount: Record "Voucher Posting Credit Account";
        Exists: Boolean;
    begin
        if VoucherPostingCreditAccount.Get(LocationCode, TemplateType, AccountType, AccountNo) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        VoucherPostingCreditAccount.Validate("Location Code", LocationCode);
        VoucherPostingCreditAccount.Validate(Type, TemplateType);
        VoucherPostingCreditAccount.Validate("Account Type", AccountType);
        VoucherPostingCreditAccount.Validate("Account No.", AccountNo);

        if Exists then
            VoucherPostingCreditAccount.Modify(true)
        else
            VoucherPostingCreditAccount.Insert(true);
    end;
}
