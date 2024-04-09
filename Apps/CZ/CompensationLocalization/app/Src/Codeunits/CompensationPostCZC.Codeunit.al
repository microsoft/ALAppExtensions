// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Compensations;

using Microsoft.EServices.EDocument;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.GeneralLedger.Preview;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Foundation.AuditCodes;
using System.Utilities;

codeunit 31269 "Compensation - Post CZC"
{
    Permissions = tabledata "Posted Compensation Header CZC" = i,
                  tabledata "Posted Compensation Line CZC" = i;
    TableNo = "Compensation Header CZC";

    trigger OnRun()
    var
        Balance: Decimal;
        TempAmount: Decimal;
        i: Integer;
    begin
        OnBeforePostCompensationCZC(Rec);
        Rec.CheckCompensationPostRestrictions();

        if Rec.Status <> Rec.Status::Released then
            Codeunit.Run(Codeunit::"Release Compens. Document CZC", Rec);

        CompensationsSetupCZC.Get();
        CompensationsSetupCZC.TestField("Compensation Bal. Account No.");

        SourceCodeSetup.Get();
        GeneralLedgerSetup.Get();

        Rec.CalcFields("Compensation Balance (LCY)");
        Balance := Rec."Compensation Balance (LCY)";
        CheckRoundingAccounts(Balance);

        i := 1;
        CompensationLineCZC.Reset();
        CompensationLineCZC.SetRange("Compensation No.", Rec."No.");
        if CompensationLineCZC.Find('-') then begin
            WindowDialog.Open('#1#################################\\' +
              Text008Msg);
            WindowDialog.Update(1, StrSubstNo(Text009Msg, Rec."No."));
            repeat
                WindowDialog.Update(2, i);
                Clear(GenJournalLine);
                GenJournalLine."Compensation CZC" := CompensationLineCZC."Source Entry No." <> 0;
                GenJournalLine.Validate("Posting Date", Rec."Posting Date");
                GenJournalLine.Validate("Document No.", Rec."No.");
                GenJournalLine.Validate("Account Type", CompensationLineCZC."Source Type".AsInteger() + 1);
                GenJournalLine.Validate("Account No.", CompensationLineCZC."Source No.");
                GenJournalLine."Posting Group" := CompensationLineCZC."Posting Group";
                GenJournalLine.Validate("Document Date", Rec."Document Date");
                GenJournalLine.Validate("Currency Code", CompensationLineCZC."Currency Code");
                if CompensationLineCZC."Currency Code" <> '' then
                    GenJournalLine.Validate("Currency Factor", CompensationLineCZC."Currency Factor");
                GenJournalLine.Validate(Description, Rec.Description);
                GenJournalLine.Validate(Amount, -CompensationLineCZC.Amount);
                GenJournalLine.Validate("Bal. Account Type", GenJournalLine."Bal. Account Type"::"G/L Account");
                GenJournalLine.Validate("Bal. Account No.", CompensationsSetupCZC."Compensation Bal. Account No.");
                GenJournalLine.Validate("Applies-to ID", Rec."No.");
                GenJournalLine."Dimension Set ID" := CompensationLineCZC."Dimension Set ID";
                GenJournalLine."Shortcut Dimension 1 Code" := CompensationLineCZC."Shortcut Dimension 1 Code";
                GenJournalLine."Shortcut Dimension 2 Code" := CompensationLineCZC."Shortcut Dimension 2 Code";
                GenJournalLine."Variable Symbol CZL" := CompensationLineCZC."Variable Symbol";

                CompensationManagementCZC.SetAppliesToID(CompensationLineCZC, Rec."No.");

                TempAmount := CompensationLineCZC."Amount (LCY)";
                Clear(CompensationLineCZC."Amount (LCY)");
                CompensationLineCZC.Modify();

                GenJournalLine."Source Code" := SourceCodeSetup."Compensation CZC";
                GenJournalLine."System-Created Entry" := true;
                GenJnlPostLine.RunWithCheck(GenJournalLine);
                CompensationLineCZC."Amount (LCY)" := TempAmount;
                CompensationLineCZC.Modify();

                CompensationManagementCZC.SetAppliesToID(CompensationLineCZC, '');
                i += 1;
            until CompensationLineCZC.Next() = 0;

            if Balance <> 0 then begin
                Clear(GenJournalLine);
                GenJournalLine.Validate("Posting Date", Rec."Posting Date");
                GenJournalLine.Validate("Document No.", Rec."No.");
                GenJournalLine.Validate("Account Type", GenJournalLine."Account Type"::"G/L Account");
                case true of
                    Balance < 0:
                        GenJournalLine.Validate("Account No.", CompensationsSetupCZC."Credit Rounding Account");
                    Balance > 0:
                        GenJournalLine.Validate("Account No.", CompensationsSetupCZC."Debit Rounding Account");
                end;
                GenJournalLine.Validate("Document Date", Rec."Document Date");
                GenJournalLine.Validate(Description, Rec.Description);
                GenJournalLine.Validate(Amount, Balance);
                GenJournalLine.Validate("Bal. Account Type", GenJournalLine."Bal. Account Type"::"G/L Account");
                GenJournalLine.Validate("Bal. Account No.", CompensationsSetupCZC."Compensation Bal. Account No.");
                GenJournalLine."Dimension Set ID" := CompensationLineCZC."Dimension Set ID";
                GenJournalLine."Shortcut Dimension 1 Code" := CompensationLineCZC."Shortcut Dimension 1 Code";
                GenJournalLine."Shortcut Dimension 2 Code" := CompensationLineCZC."Shortcut Dimension 2 Code";
                GenJournalLine."Source Code" := SourceCodeSetup."Compensation CZC";
                GenJournalLine."System-Created Entry" := true;
                GenJnlPostLine.RunWithCheck(GenJournalLine);
            end;

            if PreviewMode then
                GenJnlPostPreview.ThrowError();

            Clear(PostedCompensationHeaderCZC);
            PostedCompensationHeaderCZC.TransferFields(Rec);
            PostedCompensationHeaderCZC.Insert();
            OnAfterPostedCompensationHeaderInsertCZC(Rec, PostedCompensationHeaderCZC);
            RecordLinkManagement.CopyLinks(Rec, PostedCompensationHeaderCZC);

            Clear(CompensationLineCZC);
            CompensationLineCZC.SetRange("Compensation No.", Rec."No.");
            CompensationLineCZC.FindSet();
            repeat
                Clear(PostedCompensationLineCZC);
                PostedCompensationLineCZC.TransferFields(CompensationLineCZC);
                PostedCompensationLineCZC."Compensation No." := PostedCompensationHeaderCZC."No.";
                PostedCompensationLineCZC.Insert();
                OnAfterPostedCompensationLineInsertCZC(CompensationLineCZC, PostedCompensationLineCZC);
            until CompensationLineCZC.Next() = 0;

            UpdateIncomingDocument(Rec."Incoming Document Entry No.", Rec."Posting Date", PostedCompensationHeaderCZC."No.");

            RecordLinkManagement.RemoveLinks(CompensationLineCZC);
            CompensationLineCZC.DeleteAll();
            if Rec.HasLinks() then
                Rec.DeleteLinks();
            Rec.Delete();
            WindowDialog.Close();
        end else
            Error(Text002Err);

        OnAfterPostCompensationCZC(Rec, GenJnlPostLine, PostedCompensationHeaderCZC."No.");
    end;

    var
        CompensationLineCZC: Record "Compensation Line CZC";
        GenJournalLine: Record "Gen. Journal Line";
        PostedCompensationHeaderCZC: Record "Posted Compensation Header CZC";
        PostedCompensationLineCZC: Record "Posted Compensation Line CZC";
        CompensationsSetupCZC: Record "Compensations Setup CZC";
        SourceCodeSetup: Record "Source Code Setup";
        GeneralLedgerSetup: Record "General Ledger Setup";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        CompensationManagementCZC: Codeunit "Compensation Management CZC";
        GenJnlPostPreview: Codeunit "Gen. Jnl.-Post Preview";
        RecordLinkManagement: Codeunit "Record Link Management";
        WindowDialog: Dialog;
        Text002Err: Label 'There is nothing to post.';
        Text008Msg: Label 'Posting lines              #2######.', Comment = '%2 = progress bar';
        Text009Msg: Label 'Compensation %1.', Comment = '%1 = Number of Compensations';
        PreviewMode: Boolean;

    local procedure CheckRoundingAccounts(Balance: Decimal)
    begin
        CompensationsSetupCZC.Get();
        case true of
            Balance < 0:
                CompensationsSetupCZC.TestField("Credit Rounding Account");
            Balance > 0:
                CompensationsSetupCZC.TestField("Debit Rounding Account");
        end;
    end;

    local procedure UpdateIncomingDocument(IncomingDocNo: Integer; PostingDate: Date; DocNo: Code[20])
    var
        IncomingDocument: Record "Incoming Document";
    begin
        IncomingDocument.UpdateIncomingDocumentFromPosting(IncomingDocNo, PostingDate, DocNo);
    end;

    procedure SetPreviewMode(NewPreviewMode: Boolean)
    begin
        PreviewMode := NewPreviewMode;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostCompensationCZC(var CompensationHeaderCZC: Record "Compensation Header CZC")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostedCompensationHeaderInsertCZC(var CompensationHeaderCZC: Record "Compensation Header CZC"; var PostedCompensationHeaderCZC: Record "Posted Compensation Header CZC")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostedCompensationLineInsertCZC(var CompensationLineCZC: Record "Compensation Line CZC"; var PostedCompensationLineCZC: Record "Posted Compensation Line CZC")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostCompensationCZC(var CompensationHeaderCZC: Record "Compensation Header CZC"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; PostedCompensationHeaderNo: Code[20])
    begin
    end;
}
