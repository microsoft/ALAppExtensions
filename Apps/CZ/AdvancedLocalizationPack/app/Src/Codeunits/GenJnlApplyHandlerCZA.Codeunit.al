// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.ReceivablesPayables;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Ledger;

codeunit 31379 "Gen. Jnl.-Apply Handler CZA"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Apply", 'OnBeforeRun', '', false, false)]
    local procedure GLEntryPostApplicationOnBeforeRun(var GenJnlLine: Record "Gen. Journal Line"; var IsHandled: Boolean)
    var
        CrossApplicationMgtCZL: Codeunit "Cross Application Mgt. CZL";
        AccType: Enum "Gen. Journal Account Type";
        AccNo: Code[20];
        AccBalance: Boolean;
    begin
        if IsHandled then
            exit;

        if GenJnlLine."Bal. Account Type" in
               [GenJnlLine."Bal. Account Type"::Customer, GenJnlLine."Bal. Account Type"::Vendor, GenJnlLine."Bal. Account Type"::Employee]
        then begin
            AccType := GenJnlLine."Bal. Account Type";
            AccNo := GenJnlLine."Bal. Account No.";
        end else begin
            AccType := GenJnlLine."Account Type";
            AccNo := GenJnlLine."Account No.";
        end;

        if (AccType <> GenJnlLine."Account Type"::Customer) and (AccType <> GenJnlLine."Account Type"::Vendor) and (AccType <> GenJnlLine."Account Type"::Employee) then
            if (GenJnlLine."Account Type" = GenJnlLine."Account Type"::"G/L Account") and (GenJnlLine."Account No." <> '') then begin
                AccType := GenJnlLine."Account Type";
                AccNo := GenJnlLine."Account No.";
                AccBalance := false;
            end else begin
                AccType := GenJnlLine."Bal. Account Type";
                AccNo := GenJnlLine."Bal. Account No.";
                AccBalance := true;
            end;

        if AccType = AccType::"G/L Account" then begin
            ApplyGLEntryCZA(GenJnlLine, AccNo, AccBalance);
            CrossApplicationMgtCZL.SetAppliesToID(GenJnlLine."Applies-to ID");
            IsHandled := true;
        end;
    end;

    local procedure ApplyGLEntryCZA(var GenJournalLine: Record "Gen. Journal Line"; AccNo: Code[20]; AccBalance: Boolean)
    var
        GLEntry: Record "G/L Entry";
        ApplyGenLedgerEntriesCZA: Page "Apply Gen. Ledger Entries CZA";
        PreviousAppliesToID: Code[50];
        EntrySelected: Boolean;
        MustSpecifyErr: Label 'You must specify %1 or %2.', Comment = '%1 = FieldCaption Document No., %2 = FieldCaption Applies-to ID';
    begin
        GLEntry.SetRange("G/L Account No.", AccNo);
        if GenJournalLine.Amount > 0 then
            if AccBalance then
                GLEntry.SetFilter(Amount, '>0')
            else
                GLEntry.SetFilter(Amount, '<0');
        if GenJournalLine.Amount < 0 then
            if AccBalance then
                GLEntry.SetFilter(Amount, '<0')
            else
                GLEntry.SetFilter(Amount, '>0');
        PreviousAppliesToID := GenJournalLine."Applies-to ID";
        if GenJournalLine."Applies-to ID" = '' then
            GenJournalLine."Applies-to ID" := GenJournalLine."Document No.";
        if GenJournalLine."Applies-to ID" = '' then
            Error(
              MustSpecifyErr,
              GenJournalLine.FieldCaption("Document No."), GenJournalLine.FieldCaption("Applies-to ID"));

        if GLEntry.IsEmpty() then
            exit;

        GLEntry.SetAutoCalcFields("Applied Amount CZA");
        GLEntry.SetLoadFields("Applies-to ID CZA", "Posting Date", "Document Type", "Document No.", "G/L Account No.", Description, Amount, "Amount to Apply CZA", "Applying Entry CZA", "Applied Amount CZA",
            "Gen. Bus. Posting Group", "Gen. Prod. Posting Group", "VAT Bus. Posting Group", "VAT Prod. Posting Group");

        ApplyGenLedgerEntriesCZA.InsertEntry(GLEntry);
        ApplyGenLedgerEntriesCZA.SetGenJournalLine(GenJournalLine);
        ApplyGenLedgerEntriesCZA.LookupMode(true);
        EntrySelected := ApplyGenLedgerEntriesCZA.RunModal() = Action::LookupOK;
        Clear(ApplyGenLedgerEntriesCZA);
        if not EntrySelected then begin
            GenJournalLine."Applies-to ID" := PreviousAppliesToID;
            exit;
        end;

        GLEntry.Reset();
        GLEntry.SetCurrentKey("G/L Account No.", "Applies-to ID CZA");
        GLEntry.SetRange("G/L Account No.", AccNo);
        GLEntry.SetRange("Closed CZA", false);
        GLEntry.SetRange("Applies-to ID CZA", GenJournalLine."Applies-to ID");
        if GLEntry.FindSet() then begin
            if GenJournalLine.Amount = 0 then begin
                repeat
                    if Abs(GLEntry."Amount to Apply CZA") >= Abs(GLEntry.RemainingAmountCZA()) then
                        GenJournalLine.Amount := GenJournalLine.Amount - GLEntry.RemainingAmountCZA()
                    else
                        GenJournalLine.Amount := GenJournalLine.Amount - GLEntry."Amount to Apply CZA";
                until GLEntry.Next() = 0;
                if GenJournalLine."Account Type" <> GenJournalLine."Bal. Account Type"::"G/L Account" then
                    GenJournalLine.Amount := -GenJournalLine.Amount;
                GenJournalLine.Validate(Amount);
            end;
            GenJournalLine."Applies-to Doc. Type" := GenJournalLine."Applies-to Doc. Type"::" ";
            GenJournalLine."Applies-to Doc. No." := '';
        end else
            GenJournalLine."Applies-to ID" := '';
        if GenJournalLine."Line No." <> 0 then
            GenJournalLine.Modify();
    end;
}
