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

            CompensationLineCZC.DeleteAll();
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
        WindowDialog: Dialog;
        Text002Err: Label 'There is nothing to post.';
        Text008Msg: Label 'Posting lines              #2######.', Comment = '%2 = progress bar';
        Text009Msg: Label 'Compensation %1.', Comment = '%1 = Number of Compensations';
#if not CLEAN18
        DuplicityFoundErr: Label '%1 %2 was found. Resolve this before issue banking document.', Comment = '%1 = TableCaption, %2 = No.';
#endif
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

#if not CLEAN18
#pragma warning disable AL0432
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Compensation - Post CZC", 'OnBeforePostCompensationCZC', '', false, false)]
    local procedure CheckObsoleteOnBeforePostCompensationCZC(var CompensationHeaderCZC: Record "Compensation Header CZC")
    var
        DuplicitCreditHeader: Record "Credit Header";
    begin
        if DuplicitCreditHeader.Get(CompensationHeaderCZC."No.") then
            Error(DuplicityFoundErr, DuplicitCreditHeader.TableCaption(), DuplicitCreditHeader."No.");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Credit - Post", 'OnBeforePostCreditDoc', '', false, false)]
    local procedure CheckObsoleteOnBeforePostCreditDoc(var CreditHdr: Record "Credit Header")
    var
        DuplicitCompensationHeaderCZC: Record "Compensation Header CZC";
    begin
        if DuplicitCompensationHeaderCZC.Get(CreditHdr."No.") then
            Error(DuplicityFoundErr, DuplicitCompensationHeaderCZC.TableCaption(), DuplicitCompensationHeaderCZC."No.");
    end;
#pragma warning restore
#endif
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
