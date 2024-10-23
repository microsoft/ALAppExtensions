// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

using Microsoft.Bank.BankAccount;
using Microsoft.CRM.Team;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.GeneralLedger.Preview;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.Foundation.AuditCodes;
using Microsoft.HumanResources.Employee;
using Microsoft.Inventory.Location;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using System.Utilities;

#pragma warning disable AL0432
codeunit 11729 "Cash Document-Post CZP"
{
    Permissions = tabledata "Posted Cash Document Hdr. CZP" = i,
                  tabledata "Posted Cash Document Line CZP" = im;
    TableNo = "Cash Document Header CZP";

    trigger OnRun()
    var
        CashDeskCZP: Record "Cash Desk CZP";
        NoCheckCashDocument: Boolean;
        ThreePlaceholdersTok: Label '%1 %2 %3', Locked = true;
    begin
        OnBeforePostCashDoc(Rec);
        if not PreviewMode then
            Rec.CheckCashDocPostRestrictions();

        CashDocumentHeaderCZP := Rec;
        CashDocumentHeaderCZP.TestField(CashDocumentHeaderCZP."Cash Desk No.");
        CashDocumentHeaderCZP.TestField(CashDocumentHeaderCZP."No.");
        CashDocumentHeaderCZP.TestField(CashDocumentHeaderCZP."Posting Date");
        CashDocumentHeaderCZP.TestField(CashDocumentHeaderCZP."VAT Date");
        if GenJnlCheckLine.DateNotAllowed(CashDocumentHeaderCZP."Posting Date") then
            CashDocumentHeaderCZP.FieldError(CashDocumentHeaderCZP."Posting Date", PostingDateOutRangeErr);

        OnRunOnBeforeDocumentRelease(CashDocumentHeaderCZP);
        if CashDocumentHeaderCZP.Status <> CashDocumentHeaderCZP.Status::Released then begin
            Codeunit.Run(Codeunit::"Cash Document-Release CZP", CashDocumentHeaderCZP);
            NoCheckCashDocument := true;
        end;
        OnRunOnAfterDocumentRelease(CashDocumentHeaderCZP);
        // test cash desk
        CashDeskCZP.Get(CashDocumentHeaderCZP."Cash Desk No.");
        CashDeskCZP.TestField(Blocked, false);
        CashDocumentHeaderCZP.CalcFields(CashDocumentHeaderCZP."Amount Including VAT", CashDocumentHeaderCZP."Amount Including VAT (LCY)");
        if CashDocumentHeaderCZP."Amount Including VAT" <> CashDocumentHeaderCZP."Released Amount" then
            Error(NotEqualErr,
                CashDocumentHeaderCZP.FieldCaption(CashDocumentHeaderCZP."Amount Including VAT"),
                CashDocumentHeaderCZP.FieldCaption(CashDocumentHeaderCZP."Released Amount"));

        CashDeskManagementCZP.CheckUserRights(CashDeskCZP."No.", Enum::"Cash Document Action CZP"::Post, CashDocumentHeaderCZP.IsEETTransaction());

        SourceCodeSetup.Get();
        SourceCodeSetup.TestField("Cash Desk CZP");
        OnRunOnBeforeCheckCashDocument(CashDocumentHeaderCZP, NoCheckCashDocument);
        if not NoCheckCashDocument then
            CashDocumentReleaseCZP.CheckCashDocumentForPosting(Rec);
        OnRunOnAfterCheckCashDocument(CashDocumentHeaderCZP, NoCheckCashDocument);

        WindowDialog.Open(DialogMsg);
        // Insert posted cash document header
        WindowDialog.Update(1, StrSubstNo(ThreePlaceholdersTok, CashDocumentHeaderCZP."Cash Desk No.", CashDocumentHeaderCZP."Document Type", CashDocumentHeaderCZP."No."));

        PostedCashDocumentHdrCZP.Init();
        PostedCashDocumentHdrCZP.TransferFields(CashDocumentHeaderCZP);
        PostedCashDocumentHdrCZP."Posted ID" := CopyStr(UserId(), 1, MaxStrLen(PostedCashDocumentHdrCZP."Posted ID"));
        PostedCashDocumentHdrCZP."No. Printed" := 0;
        OnBeforePostedCashDocHeaderInsert(PostedCashDocumentHdrCZP, CashDocumentHeaderCZP);
        PostedCashDocumentHdrCZP.Insert();
        OnAfterPostedCashDocHeaderInsert(PostedCashDocumentHdrCZP, CashDocumentHeaderCZP);
        RecordLinkManagement.CopyLinks(CashDocumentHeaderCZP, PostedCashDocumentHdrCZP);

        PostHeader();
        PostLines();

        FinalizePosting(CashDocumentHeaderCZP);
        OnAfterPostCashDoc(CashDocumentHeaderCZP, GenJnlPostLine, PostedCashDocumentHdrCZP."No.");
    end;

    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
        CashDocumentLineCZP: Record "Cash Document Line CZP";
        TempGenJournalLine: Record "Gen. Journal Line" temporary;
        PostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP";
        PostedCashDocumentLineCZP: Record "Posted Cash Document Line CZP";
        SourceCodeSetup: Record "Source Code Setup";
        CashDeskManagementCZP: Codeunit "Cash Desk Management CZP";
        GenJnlCheckLine: Codeunit "Gen. Jnl.-Check Line";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        DimensionManagement: Codeunit DimensionManagement;
        CashDocumentReleaseCZP: Codeunit "Cash Document-Release CZP";
        GenJnlPostPreview: Codeunit "Gen. Jnl.-Post Preview";
        RecordLinkManagement: Codeunit "Record Link Management";
        WindowDialog: Dialog;
        DialogMsg: Label 'Posting Document #1#################################\\Posting Lines #2######\', Comment = '%1 = Cash Desk No. & "Cash Document Type & No., %2 = Line Count';
        PostingDateOutRangeErr: Label 'is not within your range of allowed posting dates';
        NotEqualErr: Label '%1 is not equal %2.', Comment = '%1 = Amount Including VAT FieldCaption, %2 = Released Amount FieldCaption';
        CheckDimErr: Label 'A dimension used in %1 %2, %3, %4 has caused an error.\\%5.', Comment = '%1 = TableCaption, %2 = Cash Desk No., %3 = Cash Document No., %4 = Cash Document Line No., %5 = Error Text';
        PreviewMode: Boolean;

    local procedure PostHeader()
    var
        Sign: Integer;
    begin
        Sign := CashDocumentHeaderCZP.SignAmount();
        CashDocumentHeaderCZP.CalcFields("Amount Including VAT", "Amount Including VAT (LCY)");

        TempGenJournalLine.Init();
        TempGenJournalLine."Document No." := CashDocumentHeaderCZP."No.";
        TempGenJournalLine."External Document No." := CashDocumentHeaderCZP."External Document No.";
        TempGenJournalLine.Description := CashDocumentHeaderCZP."Payment Purpose";
        TempGenJournalLine."Posting Date" := CashDocumentHeaderCZP."Posting Date";
        TempGenJournalLine."Document Date" := CashDocumentHeaderCZP."Document Date";
        TempGenJournalLine."VAT Reporting Date" := CashDocumentHeaderCZP."VAT Date";
        TempGenJournalLine."Original Doc. VAT Date CZL" := CashDocumentHeaderCZP."VAT Date";
        TempGenJournalLine."Account Type" := TempGenJournalLine."Account Type"::"Bank Account";
        TempGenJournalLine."Account No." := CashDocumentHeaderCZP."Cash Desk No.";
        TempGenJournalLine."Currency Code" := CashDocumentHeaderCZP."Currency Code";
        TempGenJournalLine.Amount := CashDocumentHeaderCZP."Amount Including VAT" * -Sign;
        TempGenJournalLine."Amount (LCY)" := CashDocumentHeaderCZP."Amount Including VAT (LCY)" * -Sign;
        TempGenJournalLine."Salespers./Purch. Code" := CashDocumentHeaderCZP."Salespers./Purch. Code";
        TempGenJournalLine."Source Currency Code" := TempGenJournalLine."Currency Code";
        TempGenJournalLine."Source Currency Amount" := TempGenJournalLine.Amount;
        TempGenJournalLine."Source Curr. VAT Base Amount" := TempGenJournalLine."VAT Base Amount";
        TempGenJournalLine."Source Curr. VAT Amount" := TempGenJournalLine."VAT Amount";
        TempGenJournalLine."System-Created Entry" := true;
        TempGenJournalLine."Shortcut Dimension 1 Code" := CashDocumentHeaderCZP."Shortcut Dimension 1 Code";
        TempGenJournalLine."Shortcut Dimension 2 Code" := CashDocumentHeaderCZP."Shortcut Dimension 2 Code";
        TempGenJournalLine."Dimension Set ID" := CashDocumentHeaderCZP."Dimension Set ID";
        TempGenJournalLine."Source Code" := SourceCodeSetup."Cash Desk CZP";
        TempGenJournalLine."Reason Code" := CashDocumentHeaderCZP."Reason Code";
        TempGenJournalLine."VAT Registration No." := CashDocumentHeaderCZP."VAT Registration No.";

        OnBeforePostCashDocHeader(TempGenJournalLine, CashDocumentHeaderCZP, GenJnlPostLine);
        GenJnlPostLine.RunWithCheck(TempGenJournalLine);
    end;

    local procedure PostLines()
    var
        GLEntryNo: Integer;
        LineCount: Integer;
        TableID: array[10] of Integer;
        No: array[10] of Code[20];
    begin
        CashDocumentLineCZP.Reset();
        CashDocumentLineCZP.SetRange("Cash Desk No.", CashDocumentHeaderCZP."Cash Desk No.");
        CashDocumentLineCZP.SetRange("Cash Document No.", CashDocumentHeaderCZP."No.");
        LineCount := 0;

        if CashDocumentLineCZP.FindSet() then
            repeat
                LineCount += 1;
                WindowDialog.Update(2, LineCount);

                // Insert posted cash document line
                PostedCashDocumentLineCZP.Init();
                PostedCashDocumentLineCZP.TransferFields(CashDocumentLineCZP);
                OnBeforePostedCashDocLineInsert(PostedCashDocumentLineCZP, PostedCashDocumentHdrCZP, CashDocumentLineCZP);
                PostedCashDocumentLineCZP.Insert();
                OnAfterPostedCashDocLineInsert(PostedCashDocumentLineCZP, PostedCashDocumentHdrCZP, CashDocumentLineCZP);

                // Post cash document lines
                if CashDocumentLineCZP.Amount <> 0 then begin
                    CashDocumentLineCZP.TestField("Account Type");
                    CashDocumentLineCZP.TestField("Account No.");

                    InitGenJnlLine(CashDocumentHeaderCZP, CashDocumentLineCZP);

                    case CashDocumentLineCZP."Account Type" of
                        CashDocumentLineCZP."Account Type"::"G/L Account":
                            TableID[1] := Database::"G/L Account";
                        CashDocumentLineCZP."Account Type"::Customer:
                            TableID[1] := Database::Customer;
                        CashDocumentLineCZP."Account Type"::Vendor:
                            TableID[1] := Database::Vendor;
                        CashDocumentLineCZP."Account Type"::"Bank Account":
                            TableID[1] := Database::"Bank Account";
                        CashDocumentLineCZP."Account Type"::"Fixed Asset":
                            TableID[1] := Database::"Fixed Asset";
                        CashDocumentLineCZP."Account Type"::Employee:
                            TableID[1] := Database::Employee;
                    end;
                    No[1] := CashDocumentLineCZP."Account No.";
                    TableID[2] := Database::"Salesperson/Purchaser";
                    No[2] := CashDocumentLineCZP."Salespers./Purch. Code";
                    TableID[3] := Database::"Responsibility Center";
                    No[3] := CashDocumentLineCZP."Responsibility Center";
                    TableID[4] := Database::"Cash Desk Event CZP";
                    No[4] := CashDocumentLineCZP."Cash Desk Event";

                    if not DimensionManagement.CheckDimValuePosting(TableID, No, CashDocumentLineCZP."Dimension Set ID") then begin
                        if CashDocumentLineCZP."Line No." <> 0 then
                            Error(
                              CheckDimErr,
                              CashDocumentHeaderCZP.TableCaption, CashDocumentHeaderCZP."Cash Desk No.", CashDocumentHeaderCZP."No.", CashDocumentLineCZP."Line No.",
                              DimensionManagement.GetDimValuePostingErr());
                        Error(DimensionManagement.GetDimValuePostingErr());
                    end;
                    OnBeforePostCashDocLine(TempGenJournalLine, CashDocumentLineCZP, GenJnlPostLine);
                    GLEntryNo := GenJnlPostLine.RunWithCheck(TempGenJournalLine);
                    OnAfterPostCashDocLine(TempGenJournalLine, CashDocumentLineCZP, GLEntryNo, GenJnlPostLine);
                end;
            until CashDocumentLineCZP.Next() = 0;

        OnAfterPostLines(CashDocumentHeaderCZP, PostedCashDocumentHdrCZP, GenJnlPostLine);
    end;

    procedure InitGenJnlLine(InitCashDocumentHeaderCZP: Record "Cash Document Header CZP"; InitCashDocumentLineCZP: Record "Cash Document Line CZP")
    var
        Sign: Integer;
    begin
        TempGenJournalLine.Init();
        case InitCashDocumentLineCZP."Gen. Document Type" of
            InitCashDocumentLineCZP."Gen. Document Type"::Payment:
                TempGenJournalLine."Document Type" := TempGenJournalLine."Document Type"::Payment;
            InitCashDocumentLineCZP."Gen. Document Type"::Refund:
                TempGenJournalLine."Document Type" := TempGenJournalLine."Document Type"::Refund;
        end;
        TempGenJournalLine."Document No." := InitCashDocumentHeaderCZP."No.";
        TempGenJournalLine."External Document No." := InitCashDocumentLineCZP."External Document No.";
        TempGenJournalLine."Posting Date" := InitCashDocumentHeaderCZP."Posting Date";
        TempGenJournalLine.Validate("VAT Reporting Date", InitCashDocumentHeaderCZP."VAT Date");
        TempGenJournalLine.Validate("Original Doc. VAT Date CZL", InitCashDocumentHeaderCZP."VAT Date");
        TempGenJournalLine."Posting Group" := InitCashDocumentLineCZP."Posting Group";
        TempGenJournalLine.Description := InitCashDocumentLineCZP.Description;
        OnInitGenJnlLineOnBeforeSetAccount(TempGenJournalLine, InitCashDocumentHeaderCZP, InitCashDocumentLineCZP);
        case InitCashDocumentLineCZP."Account Type" of
            InitCashDocumentLineCZP."Account Type"::"G/L Account":
                TempGenJournalLine."Account Type" := TempGenJournalLine."Account Type"::"G/L Account";
            InitCashDocumentLineCZP."Account Type"::Customer:
                begin
                    TempGenJournalLine."Account Type" := TempGenJournalLine."Account Type"::Customer;
                    TempGenJournalLine.Validate(TempGenJournalLine."Bill-to/Pay-to No.", InitCashDocumentLineCZP."Account No.");
                    TempGenJournalLine.Validate(TempGenJournalLine."Sell-to/Buy-from No.", InitCashDocumentLineCZP."Account No.");
                end;
            InitCashDocumentLineCZP."Account Type"::Vendor:
                begin
                    TempGenJournalLine."Account Type" := TempGenJournalLine."Account Type"::Vendor;
                    TempGenJournalLine.Validate(TempGenJournalLine."Bill-to/Pay-to No.", InitCashDocumentLineCZP."Account No.");
                    TempGenJournalLine.Validate(TempGenJournalLine."Sell-to/Buy-from No.", InitCashDocumentLineCZP."Account No.");
                end;
            InitCashDocumentLineCZP."Account Type"::"Bank Account":
                TempGenJournalLine."Account Type" := TempGenJournalLine."Account Type"::"Bank Account";
            InitCashDocumentLineCZP."Account Type"::"Fixed Asset":
                TempGenJournalLine."Account Type" := TempGenJournalLine."Account Type"::"Fixed Asset";
            InitCashDocumentLineCZP."Account Type"::Employee:
                TempGenJournalLine."Account Type" := TempGenJournalLine."Account Type"::Employee;
        end;
        TempGenJournalLine."Account No." := InitCashDocumentLineCZP."Account No.";

        Sign := InitCashDocumentLineCZP.SignAmount();

        TempGenJournalLine."VAT Bus. Posting Group" := InitCashDocumentLineCZP."VAT Bus. Posting Group";
        TempGenJournalLine."VAT Prod. Posting Group" := InitCashDocumentLineCZP."VAT Prod. Posting Group";
        TempGenJournalLine."VAT Calculation Type" := InitCashDocumentLineCZP."VAT Calculation Type";
        TempGenJournalLine."VAT Base Amount" := InitCashDocumentLineCZP."VAT Base Amount" * Sign;
        TempGenJournalLine."VAT Base Amount (LCY)" := InitCashDocumentLineCZP."VAT Base Amount (LCY)" * Sign;
        TempGenJournalLine."VAT Amount" := InitCashDocumentLineCZP."VAT Amount" * Sign;
        TempGenJournalLine."VAT Amount (LCY)" := InitCashDocumentLineCZP."VAT Amount (LCY)" * Sign;
        TempGenJournalLine.Amount := InitCashDocumentLineCZP."Amount Including VAT" * Sign;
        TempGenJournalLine."Amount (LCY)" := InitCashDocumentLineCZP."Amount Including VAT (LCY)" * Sign;
        TempGenJournalLine."VAT Difference" := InitCashDocumentLineCZP."VAT Difference" * Sign;
        TempGenJournalLine."Non-Deductible VAT %" := InitCashDocumentLineCZP."Non-Deductible VAT %";
        TempGenJournalLine."Non-Deductible VAT Base" := InitCashDocumentLineCZP."Non-Deductible VAT Base" * Sign;
        TempGenJournalLine."Non-Deductible VAT Amount" := InitCashDocumentLineCZP."Non-Deductible VAT Amount" * Sign;
        TempGenJournalLine."Non-Deductible VAT Base LCY" := InitCashDocumentLineCZP."Non-Deductible VAT Base LCY" * Sign;
        TempGenJournalLine."Non-Deductible VAT Amount LCY" := InitCashDocumentLineCZP."Non-Deductible VAT Amount LCY" * Sign;
        TempGenJournalLine."Non-Deductible VAT Base ACY" := InitCashDocumentLineCZP."Non-Deductible VAT Base ACY" * Sign;
        TempGenJournalLine."Non-Deductible VAT Amount ACY" := InitCashDocumentLineCZP."Non-Deductible VAT Amount ACY" * Sign;
        TempGenJournalLine."Non-Deductible VAT Diff." := InitCashDocumentLineCZP."Non-Deductible VAT Diff." * Sign;
        TempGenJournalLine."Gen. Posting Type" := InitCashDocumentLineCZP."Gen. Posting Type";
        TempGenJournalLine."Applies-to Doc. Type" := InitCashDocumentLineCZP."Applies-To Doc. Type";
        TempGenJournalLine."Applies-to Doc. No." := InitCashDocumentLineCZP."Applies-To Doc. No.";
        TempGenJournalLine."Applies-to ID" := InitCashDocumentLineCZP."Applies-to ID";
        TempGenJournalLine."Currency Code" := InitCashDocumentHeaderCZP."Currency Code";
        TempGenJournalLine."Currency Factor" := InitCashDocumentHeaderCZP."Currency Factor";
        if TempGenJournalLine."Account Type" = TempGenJournalLine."Account Type"::"Fixed Asset" then begin
            TempGenJournalLine.Validate(TempGenJournalLine."Depreciation Book Code", InitCashDocumentLineCZP."Depreciation Book Code");
            TempGenJournalLine.Validate(TempGenJournalLine."FA Posting Type", InitCashDocumentLineCZP."FA Posting Type");
            TempGenJournalLine.Validate(TempGenJournalLine."Maintenance Code", InitCashDocumentLineCZP."Maintenance Code");
            TempGenJournalLine.Validate(TempGenJournalLine."Duplicate in Depreciation Book", InitCashDocumentLineCZP."Duplicate in Depreciation Book");
            TempGenJournalLine.Validate(TempGenJournalLine."Use Duplication List", InitCashDocumentLineCZP."Use Duplication List");
        end;
        TempGenJournalLine."Source Currency Code" := TempGenJournalLine."Currency Code";
        TempGenJournalLine."Source Currency Amount" := TempGenJournalLine.Amount;
        TempGenJournalLine."Source Curr. VAT Base Amount" := TempGenJournalLine."VAT Base Amount";
        TempGenJournalLine."Source Curr. VAT Amount" := TempGenJournalLine."VAT Amount";
        TempGenJournalLine."System-Created Entry" := true;
        TempGenJournalLine."Shortcut Dimension 1 Code" := InitCashDocumentLineCZP."Shortcut Dimension 1 Code";
        TempGenJournalLine."Shortcut Dimension 2 Code" := InitCashDocumentLineCZP."Shortcut Dimension 2 Code";
        TempGenJournalLine."Dimension Set ID" := InitCashDocumentLineCZP."Dimension Set ID";
        TempGenJournalLine."Source Code" := SourceCodeSetup."Cash Desk CZP";
        TempGenJournalLine."Reason Code" := InitCashDocumentLineCZP."Reason Code";
        TempGenJournalLine."VAT Registration No." := InitCashDocumentHeaderCZP."VAT Registration No.";
        OnAfterInitGenJnlLine(TempGenJournalLine, InitCashDocumentHeaderCZP, InitCashDocumentLineCZP);
    end;

    procedure GetGenJnlLine(var TempNewGenJournalLine: Record "Gen. Journal Line" temporary)
    begin
        TempNewGenJournalLine := TempGenJournalLine;
    end;

    local procedure FinalizePosting(var CashDocumentHeaderCZP: Record "Cash Document Header CZP")
    begin
        if PreviewMode then begin
            WindowDialog.Close();
            OnAfterFinalizePostingPreview(CashDocumentHeaderCZP, PostedCashDocumentHdrCZP, GenJnlPostLine);
            GenJnlPostPreview.ThrowError();
        end;
        DeleteAfterPosting(CashDocumentHeaderCZP);
        WindowDialog.Close();
        OnAfterFinalizePosting(CashDocumentHeaderCZP, PostedCashDocumentHdrCZP, GenJnlPostLine);
    end;

    local procedure DeleteAfterPosting(var CashDocumentHeaderCZP: Record "Cash Document Header CZP")
    begin
        OnBeforeDeleteAfterPosting(CashDocumentHeaderCZP, PostedCashDocumentHdrCZP);
        if CashDocumentHeaderCZP.HasLinks then
            CashDocumentHeaderCZP.DeleteLinks();
        CashDocumentHeaderCZP.Delete();

        CashDocumentLineCZP.Reset();
        CashDocumentLineCZP.SetRange("Cash Desk No.", CashDocumentHeaderCZP."Cash Desk No.");
        CashDocumentLineCZP.SetRange("Cash Document No.", CashDocumentHeaderCZP."No.");
        RecordLinkManagement.RemoveLinks(CashDocumentLineCZP);
        CashDocumentLineCZP.DeleteAll();
    end;

    procedure DeleteCashDocumentHeader(var CashDocumentHeaderCZP: Record "Cash Document Header CZP")
    var
        SourceCode: Record "Source Code";
    begin
        SourceCodeSetup.Get();
        SourceCodeSetup.TestField("Deleted Document");
        SourceCode.Get(SourceCodeSetup."Deleted Document");

        // create posted document header
        PostedCashDocumentHdrCZP.Init();
        PostedCashDocumentHdrCZP.TransferFields(CashDocumentHeaderCZP);
        PostedCashDocumentHdrCZP."Canceled Document" := true;
        PostedCashDocumentHdrCZP."Posting Date" := Today;
        PostedCashDocumentHdrCZP."Created ID" := CopyStr(UserId(), 1, MaxStrLen(PostedCashDocumentHdrCZP."Created ID"));
        PostedCashDocumentHdrCZP."Payment Purpose" := SourceCode.Description;
        PostedCashDocumentHdrCZP.Insert();

        // create posted document line
        PostedCashDocumentLineCZP.Init();
        PostedCashDocumentLineCZP."Cash Desk No." := PostedCashDocumentHdrCZP."Cash Desk No.";
        PostedCashDocumentLineCZP."Document Type" := PostedCashDocumentHdrCZP."Document Type";
        PostedCashDocumentLineCZP."Cash Document No." := PostedCashDocumentHdrCZP."No.";
        PostedCashDocumentLineCZP."Line No." := 0;
        PostedCashDocumentLineCZP.Description := SourceCode.Description;
        if not PostedCashDocumentLineCZP.Insert() then
            PostedCashDocumentLineCZP.Modify();
    end;

    procedure SetPreviewMode(NewPreviewMode: Boolean)
    begin
        PreviewMode := NewPreviewMode;
    end;

    procedure SetGenJnlPostLine(var NewGenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    begin
        GenJnlPostLine := NewGenJnlPostLine;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Check Line", 'OnAfterCheckGenJnlLine', '', false, false)]
    local procedure CheckCashDeskOnAfterCheckGenJnlLine(var GenJournalLine: Record "Gen. Journal Line")
    var
        BankAccount: Record "Bank Account";
    begin
        SourceCodeSetup.Get();
        if GenJournalLine."Source Code" <> SourceCodeSetup."Cash Desk CZP" then
            exit;
        if GenJournalLine."Account Type" = GenJournalLine."Account Type"::"Bank Account" then
            if BankAccount.Get(GenJournalLine."Account No.") then
                BankAccount.TestField("Account Type CZP", BankAccount."Account Type CZP"::"Cash Desk");
        if GenJournalLine."Bal. Account Type" = GenJournalLine."Bal. Account Type"::"Bank Account" then
            if BankAccount.Get(GenJournalLine."Bal. Account No.") then
                BankAccount.TestField("Account Type CZP", BankAccount."Account Type CZP"::"Cash Desk");
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFinalizePosting(var CashDocumentHeaderCZP: Record "Cash Document Header CZP"; var PostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFinalizePostingPreview(var CashDocumentHeaderCZP: Record "Cash Document Header CZP"; var PostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostCashDoc(var CashDocumentHeaderCZP: Record "Cash Document Header CZP"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; PostedCashDocumentHeaderNo: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostedCashDocHeaderInsert(var PostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP"; var CashDocumentHeaderCZP: Record "Cash Document Header CZP")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostedCashDocLineInsert(var PostedCashDocumentLineCZP: Record "Posted Cash Document Line CZP"; var PostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP"; var CashDocumentLineCZP: Record "Cash Document Line CZP")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitGenJnlLine(var GenJournalLine: Record "Gen. Journal Line"; CashDocumentHeaderCZP: Record "Cash Document Header CZP"; CashDocumentLineCZP: Record "Cash Document Line CZP")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeDeleteAfterPosting(var CashDocumentHeaderCZP: Record "Cash Document Header CZP"; var PostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostCashDoc(var CashDocumentHeaderCZP: Record "Cash Document Header CZP")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostCashDocHeader(var GenJournalLine: Record "Gen. Journal Line"; var CashDocumentHeaderCZP: Record "Cash Document Header CZP"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostCashDocLine(var GenJournalLine: Record "Gen. Journal Line"; var CashDocumentLineCZP: Record "Cash Document Line CZP"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostedCashDocHeaderInsert(var PostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP"; var CashDocumentHeaderCZP: Record "Cash Document Header CZP")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostedCashDocLineInsert(var PostedCashDocumentLineCZP: Record "Posted Cash Document Line CZP"; var PostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP"; var CashDocumentLineCZP: Record "Cash Document Line CZP")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRunOnBeforeDocumentRelease(CashDocumentHeaderCZP: Record "Cash Document Header CZP")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRunOnAfterDocumentRelease(CashDocumentHeaderCZP: Record "Cash Document Header CZP")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRunOnBeforeCheckCashDocument(CashDocumentHeaderCZP: Record "Cash Document Header CZP"; var NoCheckCashDocument: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRunOnAfterCheckCashDocument(CashDocumentHeaderCZP: Record "Cash Document Header CZP"; NoCheckCashDocument: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostLines(CashDocumentHeaderCZP: Record "Cash Document Header CZP"; PostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnInitGenJnlLineOnBeforeSetAccount(var GenJournalLine: Record "Gen. Journal Line"; CashDocumentHeaderCZP: Record "Cash Document Header CZP"; CashDocumentLineCZP: Record "Cash Document Line CZP")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostCashDocLine(var GenJournalLine: Record "Gen. Journal Line"; var CashDocumentLineCZP: Record "Cash Document Line CZP"; GLEntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    begin
    end;
}
