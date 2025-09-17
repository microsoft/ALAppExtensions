// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Posting;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.ReceivablesPayables;
using System.Utilities;

codeunit 31370 "G/L Entry Post Application CZA"
{
    Permissions = tabledata "G/L Entry" = rm,
                  tabledata "Detailed G/L Entry CZA" = rim;

    var
        ConfirmManagement: Codeunit "Confirm Management";
        NotUseDialog: Boolean;
        ApplicationEntryErr: Label '%1 No. %2 does not have an application entry.', Comment = '%1 = TableCaption G/L Entry, %2 = Entry No.';
        PrecedeLatestErr: Label 'The entered %1 must not precede the latest %1 on %2.', Comment = '%1 = FieldCatpion Postig Date, %2 = TableCaption G/L Entry';
        NothingToApplyErr: Label 'There is nothing to apply.';
        PrecedeErr: Label 'An entered %1 must not precede the %1 of application.', Comment = '%1 = FieldCaption Posting Date';
        UnapplyErr: Label 'To unapply this entry, you must first unapply all application entries in %1 No. %2 that were posted after this entry.', Comment = '%1 = TableCaption G/L Entry, %2 = Entry No.';
        PostingMsg: Label 'Posting application...';
        SuccessfullyPostedMsg: Label 'The application has been successfully posted.';
        UnapplyEntriesQst: Label 'To unapply these entries, the program will post correcting entries. Do you want to unapply the entries?';
        SuccessfullyUnappliedMsg: Label 'The entries have been successfully unapplied.';
        SignAmtMustBediffErr: Label 'Sign amounts of entries must be different.';
        ClosedEntryErr: Label 'One or more of the entries that you selected is closed.\You cannot apply closed entries.';

    procedure PostApplyGLEntry(var ApplyingGLEntry: Record "G/L Entry")
    var
        ApplyUnapplyParameters: Record "Apply Unapply Parameters";
        DetailedGLEntryCZA: Record "Detailed G/L Entry CZA";
        GLEntry: Record "G/L Entry";
        TempAppliedGLEntry: Record "G/L Entry" temporary;
        PostApplication: Page "Post Application";
        WindowDialog: Dialog;
        ApplyingAmount: Decimal;
        DocumentNo: Code[20];
        PostingDate: Date;
        ApplicationDate: Date;
        TransactionNo: Integer;
    begin
        Clear(PostingDate);
        GLEntry.ReadIsolation(IsolationLevel::ReadCommitted);
        GLEntry.SetCurrentKey("Applies-to ID CZA");
        GLEntry.SetRange("Applies-to ID CZA", ApplyingGLEntry."Applies-to ID CZA");
        OnPostApplyGLEntryOnAfterSetFilters(GLEntry, ApplyingGLEntry);
        if GLEntry.FindSet(false) then
            repeat
                if IsAppliedEntry(GLEntry, ApplyingGLEntry) then begin
                    CheckAmountSign(GLEntry, ApplyingGLEntry);
                    if GLEntry."Posting Date" > PostingDate then
                        PostingDate := GLEntry."Posting Date";

                    TempAppliedGLEntry.Init();
                    TempAppliedGLEntry := GLEntry;
                    TempAppliedGLEntry.Insert();
                end;
            until GLEntry.Next() = 0;

        if ApplyingGLEntry."Posting Date" > PostingDate then
            PostingDate := ApplyingGLEntry."Posting Date";

        DocumentNo := ApplyingGLEntry."Document No.";
        if not NotUseDialog then begin
            ApplyUnapplyParameters."Document No." := DocumentNo;
            ApplyUnapplyParameters."Posting Date" := PostingDate;
            PostApplication.SetParameters(ApplyUnapplyParameters);
            PostApplication.LookupMode(true);
            Commit();
            if Action::LookupOK = PostApplication.RunModal() then begin
                PostApplication.GetParameters(ApplyUnapplyParameters);
                DocumentNo := ApplyUnapplyParameters."Document No.";
                ApplicationDate := ApplyUnapplyParameters."Posting Date";
                if ApplicationDate < PostingDate then
                    Error(PrecedeLatestErr, GLEntry.FieldCaption("Posting Date"), GLEntry.TableCaption);
            end else
                exit;

            WindowDialog.Open(PostingMsg);
        end else
            ApplicationDate := PostingDate;

        TempAppliedGLEntry.Reset();
        TempAppliedGLEntry.CalcSums("Amount to Apply CZA");
        ApplyingAmount := TempAppliedGLEntry."Amount to Apply CZA";
        ApplyingAmount += ApplyingGLEntry."Amount to Apply CZA";

        if ApplyingAmount <> 0 then begin
            if ApplyingAmount > 0 then
                TempAppliedGLEntry.SetFilter(Amount, '>0')
            else
                TempAppliedGLEntry.SetFilter(Amount, '<0');
            TempAppliedGLEntry.SetRange("Applying Entry CZA", false);
            TempAppliedGLEntry.Ascending(false);
            if TempAppliedGLEntry.FindSet(true) then
                repeat
                    if (ApplyingGLEntry.Amount > 0) and (TempAppliedGLEntry.Amount < 0) or
                       (ApplyingGLEntry.Amount < 0) and (TempAppliedGLEntry.Amount > 0)
                    then begin
                        TempAppliedGLEntry.CalcFields("Applied Amount CZA");
                        if (ApplyingAmount <> 0) and
                           (TempAppliedGLEntry.Amount = TempAppliedGLEntry."Amount to Apply CZA" + TempAppliedGLEntry."Applied Amount CZA")
                        then begin
                            SetAmountToApply(TempAppliedGLEntry, ApplyingAmount);
                            TempAppliedGLEntry.Modify();
                        end;
                    end;
                until TempAppliedGLEntry.Next() = 0;

            if ApplyingAmount <> 0 then begin
                TempAppliedGLEntry.SetFilter("Amount to Apply CZA", '<>0');
                if TempAppliedGLEntry.FindSet(true) then
                    repeat
                        if (ApplyingGLEntry.Amount > 0) and (TempAppliedGLEntry.Amount < 0) or
                           (ApplyingGLEntry.Amount < 0) and (TempAppliedGLEntry.Amount > 0)
                        then begin
                            SetAmountToApply(TempAppliedGLEntry, ApplyingAmount);
                            TempAppliedGLEntry.Modify();
                        end;
                    until TempAppliedGLEntry.Next() = 0;
            end;
            TempAppliedGLEntry.Ascending(true);
        end;

        TransactionNo := FindLastTransactionNo() + 1;

        TempAppliedGLEntry.Init();
        TempAppliedGLEntry := ApplyingGLEntry;
        TempAppliedGLEntry."Amount to Apply CZA" -= ApplyingAmount;
        TempAppliedGLEntry.Insert();

        TempAppliedGLEntry.Reset();
        TempAppliedGLEntry.SetRange("Applies-to ID CZA", ApplyingGLEntry."Applies-to ID CZA");
        if TempAppliedGLEntry.FindSet() then
            repeat
                if TempAppliedGLEntry.Amount = 0 then
                    CloseGLEntry(TempAppliedGLEntry, ApplicationDate);
                if TempAppliedGLEntry."Amount to Apply CZA" = 0 then
                    TempAppliedGLEntry."Applies-to ID CZA" := ''
                else begin
                    DetailedGLEntryCZA.Init();
                    DetailedGLEntryCZA."Entry No." := FindLastDtldGLEntryNo() + 1;
                    DetailedGLEntryCZA."G/L Entry No." := TempAppliedGLEntry."Entry No.";
                    DetailedGLEntryCZA."Applied G/L Entry No." := ApplyingGLEntry."Entry No.";
                    DetailedGLEntryCZA."G/L Account No." := TempAppliedGLEntry."G/L Account No.";
                    DetailedGLEntryCZA."Posting Date" := ApplicationDate;
                    DetailedGLEntryCZA."Document No." := DocumentNo;
                    DetailedGLEntryCZA."Transaction No." := TransactionNo;
                    DetailedGLEntryCZA.Amount := -TempAppliedGLEntry."Amount to Apply CZA";
                    if NotUseDialog then
                        DetailedGLEntryCZA."User ID" := CopyStr(UserId, 1, MaxStrLen(DetailedGLEntryCZA."User ID"))
                    else
                        DetailedGLEntryCZA."User ID" := TempAppliedGLEntry."Applies-to ID CZA";
                    DetailedGLEntryCZA.Insert();

                    CloseGLEntry(TempAppliedGLEntry, ApplicationDate);
                end;

                WriteToDatabase(TempAppliedGLEntry);
            until TempAppliedGLEntry.Next() = 0
        else
            if not NotUseDialog then begin
                WindowDialog.Close();
                Error(NothingToApplyErr);
            end;
        if not NotUseDialog then begin
            Commit();
            WindowDialog.Close();
            Message(SuccessfullyPostedMsg);
        end;
    end;

    procedure PostUnApplyGLEntry(var DetailedGLEntryCZA: Record "Detailed G/L Entry CZA"; DocumentNo: Code[20]; PostingDate: Date)
    var
        ChangedDetailedGLEntryCZA: Record "Detailed G/L Entry CZA";
        GLEntry: Record "G/L Entry";
        SelectedDetailedGLEntryCZA: Record "Detailed G/L Entry CZA";
        WindowDialog: Dialog;
        ApplicationEntryNo: Integer;
        TransactionNo: Integer;
        UnapplidedByEntryNo: Integer;
    begin
        SelectedDetailedGLEntryCZA.SetCurrentKey("Transaction No.");
        SelectedDetailedGLEntryCZA.SetLoadFields("G/L Entry No.", "Applied G/L Entry No.", "G/L Account No.", Amount);
        SelectedDetailedGLEntryCZA.SetRange("Transaction No.", DetailedGLEntryCZA."Transaction No.");
        SelectedDetailedGLEntryCZA.SetRange("G/L Account No.", DetailedGLEntryCZA."G/L Account No.");

        if PostingDate < DetailedGLEntryCZA."Posting Date" then
            Error(PrecedeErr, SelectedDetailedGLEntryCZA.FieldCaption("Posting Date"));

        if SelectedDetailedGLEntryCZA.FindSet() then
            repeat
                ApplicationEntryNo := FindLastApplEntry(SelectedDetailedGLEntryCZA."G/L Entry No.");
                if (ApplicationEntryNo <> 0) and (ApplicationEntryNo <> SelectedDetailedGLEntryCZA."Entry No.") then
                    Error(UnapplyErr, GLEntry.TableCaption, SelectedDetailedGLEntryCZA."G/L Entry No.");
            until SelectedDetailedGLEntryCZA.Next() = 0;

        if not NotUseDialog then
            if ConfirmManagement.GetResponseOrDefault(UnapplyEntriesQst, false) then
                WindowDialog.Open(PostingMsg)
            else
                Error('');

        TransactionNo := FindLastTransactionNo() + 1;
        if SelectedDetailedGLEntryCZA.FindSet() then
            repeat
                ChangedDetailedGLEntryCZA.Init();
                ChangedDetailedGLEntryCZA."Entry No." := FindLastDtldGLEntryNo() + 1;
                UnapplidedByEntryNo := ChangedDetailedGLEntryCZA."Entry No.";
                ChangedDetailedGLEntryCZA."G/L Entry No." := SelectedDetailedGLEntryCZA."G/L Entry No.";
                ChangedDetailedGLEntryCZA."Applied G/L Entry No." := SelectedDetailedGLEntryCZA."Applied G/L Entry No.";
                ChangedDetailedGLEntryCZA."G/L Account No." := SelectedDetailedGLEntryCZA."G/L Account No.";
                ChangedDetailedGLEntryCZA."Posting Date" := PostingDate;
                ChangedDetailedGLEntryCZA."Document No." := DocumentNo;
                ChangedDetailedGLEntryCZA."Transaction No." := TransactionNo;
                ChangedDetailedGLEntryCZA.Unapplied := true;
                ChangedDetailedGLEntryCZA."Unapplied by Entry No." := SelectedDetailedGLEntryCZA."Entry No.";
                ChangedDetailedGLEntryCZA.Amount := -SelectedDetailedGLEntryCZA.Amount;
                if UserId = '' then
                    ChangedDetailedGLEntryCZA."User ID" := '***'
                else
                    ChangedDetailedGLEntryCZA."User ID" := CopyStr(UserId, 1, MaxStrLen(ChangedDetailedGLEntryCZA."User ID"));
                ChangedDetailedGLEntryCZA.Insert();
                ChangedDetailedGLEntryCZA.Get(SelectedDetailedGLEntryCZA."Entry No.");
                ChangedDetailedGLEntryCZA.Unapplied := true;
                ChangedDetailedGLEntryCZA."Unapplied by Entry No." := UnapplidedByEntryNo;
                ChangedDetailedGLEntryCZA.Modify();
                GLEntry.Get(SelectedDetailedGLEntryCZA."G/L Entry No.");
                GLEntry."Closed at Date CZA" := 0D;
                GLEntry."Closed CZA" := false;
                GLEntry.Modify();
            until SelectedDetailedGLEntryCZA.Next() = 0;
        if not NotUseDialog then begin
            Commit();
            WindowDialog.Close();
            Message(SuccessfullyUnappliedMsg);
        end;
    end;

    procedure UnApplyGLEntry(GLEntryNo: Integer)
    var
        DetailedGLEntryCZA: Record "Detailed G/L Entry CZA";
        GLEntry: Record "G/L Entry";
        ApplicationEntryNo: Integer;
    begin
        GLEntry.Get(GLEntryNo);
        if (GLEntry.Amount = 0) and GLEntry."Closed CZA" then begin
            if ConfirmManagement.GetResponseOrDefault(UnapplyEntriesQst, false) then begin
                GLEntry."Closed at Date CZA" := 0D;
                GLEntry."Closed CZA" := false;
                GLEntry.Modify();
            end;
            exit;
        end;

        ApplicationEntryNo := FindLastApplEntry(GLEntryNo);
        if ApplicationEntryNo = 0 then
            Error(ApplicationEntryErr, GLEntry.TableCaption, GLEntryNo);
        DetailedGLEntryCZA.Get(ApplicationEntryNo);
        UnApplyGL(DetailedGLEntryCZA);
    end;

    local procedure FindLastApplEntry(GLEntryNo: Integer): Integer
    var
        DetailedGLEntryCZA: Record "Detailed G/L Entry CZA";
        ApplicationEntryNo: Integer;
    begin
        DetailedGLEntryCZA.SetCurrentKey("G/L Entry No.");
        DetailedGLEntryCZA.SetLoadFields("Entry No.", Unapplied);
        DetailedGLEntryCZA.SetRange("G/L Entry No.", GLEntryNo);
        ApplicationEntryNo := 0;
        if DetailedGLEntryCZA.FindSet() then
            repeat
                if (DetailedGLEntryCZA."Entry No." > ApplicationEntryNo) and not DetailedGLEntryCZA.Unapplied then
                    ApplicationEntryNo := DetailedGLEntryCZA."Entry No.";
            until DetailedGLEntryCZA.Next() = 0;
        exit(ApplicationEntryNo);
    end;

    local procedure UnApplyGL(DetailedGLEntryCZA: Record "Detailed G/L Entry CZA")
    var
        UnapplyGLEntriesCZA: Page "Unapply G/L Entries CZA";
    begin
        DetailedGLEntryCZA.TestField(Unapplied, false);
        UnapplyGLEntriesCZA.SetDtldGLEntry(DetailedGLEntryCZA."Entry No.");
        UnapplyGLEntriesCZA.LookupMode(true);
        UnapplyGLEntriesCZA.RunModal();
    end;

    local procedure FindLastTransactionNo() TransactionNo: Integer
    var
        DetailedGLEntryCZA: Record "Detailed G/L Entry CZA";
    begin
        if DetailedGLEntryCZA.FindLast() then
            TransactionNo := DetailedGLEntryCZA."Transaction No."
        else
            TransactionNo := 0;
    end;

    local procedure FindLastDtldGLEntryNo() DtldGLEntryNo: Integer
    var
        DetailedGLEntryCZA: Record "Detailed G/L Entry CZA";
    begin
        if DetailedGLEntryCZA.FindLast() then
            DtldGLEntryNo := DetailedGLEntryCZA."Entry No."
        else
            DtldGLEntryNo := 0;
    end;

#if not CLEAN26
    [Obsolete('The local SetAmountToApply procedure is used instead.', '26.0')]
    procedure SetAmountToApply()
    var
        GLEntry: Record "G/L Entry";
        ApplyingAmount: Decimal;
    begin
        SetAmountToApply(GLEntry, ApplyingAmount);
    end;
#endif

    local procedure SetAmountToApply(var GLEntry: Record "G/L Entry"; var ApplyingAmount: Decimal)
    begin
        if Abs(GLEntry."Amount to Apply CZA") - Abs(ApplyingAmount) <= 0 then begin
            ApplyingAmount -= GLEntry."Amount to Apply CZA";
            GLEntry."Amount to Apply CZA" := 0;
        end else begin
            GLEntry."Amount to Apply CZA" -= ApplyingAmount;
            ApplyingAmount := 0;
        end;
    end;

    procedure SetApplyingGLEntry(var VarGLEntry: Record "G/L Entry"; Set: Boolean; GLApplID: Code[50])
    begin
        VarGLEntry."Applying Entry CZA" := Set;
        if Set or ((VarGLEntry."Applies-to ID CZA" = '') and not Set) then begin
            VarGLEntry.CalcFields("Applied Amount CZA");
            VarGLEntry."Applies-to ID CZA" := GLApplID;
            VarGLEntry."Amount to Apply CZA" := VarGLEntry.Amount - VarGLEntry."Applied Amount CZA";
        end else begin
            VarGLEntry."Applies-to ID CZA" := '';
            VarGLEntry."Amount to Apply CZA" := 0;
        end;
        VarGLEntry.Modify();
    end;

    procedure NotUseRequestPage()
    begin
        NotUseDialog := true;
    end;

    procedure ApplyGLEntry(var ApplGLEntry: Record "G/L Entry")
    var
        SelectedGLEntry: Record "G/L Entry";
        ApplyGenLedgerEntriesCZA: Page "Apply Gen. Ledger Entries CZA";
    begin
        if ApplGLEntry."Closed CZA" then
            Error(ClosedEntryErr);

        SelectedGLEntry.SetRange("G/L Account No.", ApplGLEntry."G/L Account No.");
        ApplyGenLedgerEntriesCZA.InsertEntry(SelectedGLEntry);
        ApplyGenLedgerEntriesCZA.SetApplyingEntry(ApplGLEntry."Entry No.");
        ApplyGenLedgerEntriesCZA.RunModal();
    end;

    procedure AutomatedGLEntryApplication(var GenJournalLine: Record "Gen. Journal Line"; var VarGLEntry: Record "G/L Entry")
    var
        SelectedGLEntry: Record "G/L Entry";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeAtomatedGLEntryApplication(GenJournalLine, VarGLEntry, IsHandled);
        if IsHandled then
            exit;

        if GenJournalLine."Applies-to Doc. No." <> '' then begin
            SelectedGLEntry.SetCurrentKey("G/L Account No.", "Closed CZA");
            SelectedGLEntry.SetLoadFields("Entry No.", Amount, "Amount to Apply CZA");
            SelectedGLEntry.SetRange("G/L Account No.", VarGLEntry."G/L Account No.");
            SelectedGLEntry.SetRange("Closed CZA", false);
            SelectedGLEntry.SetRange("Document No.", GenJournalLine."Applies-to Doc. No.");
            SelectedGLEntry.SetRange("Document Type", GenJournalLine."Applies-to Doc. Type");
            if VarGLEntry.Amount < 0 then
                SelectedGLEntry.SetFilter(Amount, '>0')
            else
                SelectedGLEntry.SetFilter(Amount, '<0');
            SelectedGLEntry.SetAutoCalcFields("Applied Amount CZA");
            if SelectedGLEntry.FindSet(true) then
                repeat
                    SelectedGLEntry."Amount to Apply CZA" := SelectedGLEntry.Amount - SelectedGLEntry."Applied Amount CZA";
                    if SelectedGLEntry."Amount to Apply CZA" <> 0 then
                        SelectedGLEntry."Applies-to ID CZA" := GenJournalLine."Document No.";
                    SelectedGLEntry.Modify();
                until SelectedGLEntry.Next() = 0;

            VarGLEntry."Applies-to ID CZA" := GenJournalLine."Document No.";
            VarGLEntry."Amount to Apply CZA" := VarGLEntry.Amount;
            VarGLEntry."Applying Entry CZA" := true;
        end else
            if GenJournalLine."Applies-to ID" <> '' then begin
                VarGLEntry."Applies-to ID CZA" := GenJournalLine."Applies-to ID";
                VarGLEntry."Amount to Apply CZA" := VarGLEntry.Amount;
                VarGLEntry."Applying Entry CZA" := true;
            end;
    end;

    local procedure IsAppliedEntry(GLEntry: Record "G/L Entry"; ApplyingGLEntry: Record "G/L Entry") IsOk: Boolean
    begin
        IsOk :=
            (GLEntry."G/L Account No." = ApplyingGLEntry."G/L Account No.") and
            ((GLEntry.Amount <> 0) and ((GLEntry.Amount * ApplyingGLEntry.Amount) < 0)) or
            (GLEntry.Amount = 0);
        OnAfterIsAppliedEntry(GLEntry, ApplyingGLEntry, IsOk);
    end;

    local procedure CheckAmountSign(GLEntry: Record "G/L Entry"; ApplyingGLEntry: Record "G/L Entry")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnPostApplyGLEntryOnBeforeSignAmtCheck(GLEntry, ApplyingGLEntry, IsHandled);
        if IsHandled then
            exit;

        if GLEntry."Amount to Apply CZA" <> 0 then
            if (GLEntry.Amount * ApplyingGLEntry.Amount) > 0 then
                Error(SignAmtMustBediffErr);
    end;

    local procedure CloseGLEntry(var GLEntry: Record "G/L Entry"; ClosedAtDate: Date)
    begin
        if GLEntry.Amount <> 0 then
            GLEntry.CalcFields("Applied Amount CZA");
        if GLEntry."Applied Amount CZA" = GLEntry.Amount then begin
            GLEntry."Closed at Date CZA" := ClosedAtDate;
            GLEntry."Closed CZA" := true;
        end;
        GLEntry."Applying Entry CZA" := false;
        GLEntry."Amount to Apply CZA" := 0;
        GLEntry."Applies-to ID CZA" := '';
    end;

    local procedure WriteToDatabase(GLEntry: Record "G/L Entry")
    var
        ModifiedGLEntry: Record "G/L Entry";
    begin
        ModifiedGLEntry.Get(GLEntry."Entry No.");
        ModifiedGLEntry."Closed at Date CZA" := GLEntry."Closed at Date CZA";
        ModifiedGLEntry."Closed CZA" := GLEntry."Closed CZA";
        ModifiedGLEntry."Applying Entry CZA" := GLEntry."Applying Entry CZA";
        ModifiedGLEntry."Amount to Apply CZA" := GLEntry."Amount to Apply CZA";
        ModifiedGLEntry."Applies-to ID CZA" := GLEntry."Applies-to ID CZA";
        ModifiedGLEntry.Modify();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeAtomatedGLEntryApplication(var GenJournalLine: Record "Gen. Journal Line"; var GLEntry: Record "G/L Entry"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnPostApplyGLEntryOnAfterSetFilters(var GLEntry: Record "G/L Entry"; var ApplyingGLEntry: Record "G/L Entry")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnPostApplyGLEntryOnBeforeSignAmtCheck(GLEntry: Record "G/L Entry"; ApplyingGLEntry: Record "G/L Entry"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterIsAppliedEntry(GLEntry: Record "G/L Entry"; ApplyingGLEntry: Record "G/L Entry"; var IsOk: Boolean)
    begin
    end;
}
