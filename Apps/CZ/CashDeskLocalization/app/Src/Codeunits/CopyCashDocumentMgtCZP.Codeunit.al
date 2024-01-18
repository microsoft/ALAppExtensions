// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

using Microsoft.CRM.Team;
using Microsoft.Finance.Currency;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Inventory.Location;
using System.Utilities;

codeunit 11712 "Copy Cash Document Mgt. CZP"
{
    var
        Currency: Record Currency;
        ErrorMessageManagement: Codeunit "Error Message Management";
        ConfirmManagement: Codeunit "Confirm Management";
        CashDeskManagementCZP: Codeunit "Cash Desk Management CZP";
        DimensionManagement: Codeunit DimensionManagement;
        CashDocType: Option "Cash Document","Posted Cash Document";
        IncludeHeader: Boolean;
        RecalculateLines: Boolean;
        DeleteLinesQst: Label 'The existing lines for %1 %2 will be deleted.\\Do you want to continue?', Comment = '%1=Document type, e.g. Invoice. %2=Document No., e.g. 001';
        CashErrorContextMsg: Label 'Copy cash document %1', Comment = '%1 - document no.';

    procedure SetProperties(NewIncludeHeader: Boolean; NewRecalculateLines: Boolean)
    begin
        IncludeHeader := NewIncludeHeader;
        RecalculateLines := NewRecalculateLines;
    end;

    procedure CopyCashDocument(FromDocType: Option; FromCashDeskNo: Code[20]; FromDocNo: Code[20]; var ToCashDocumentHeaderCZP: Record "Cash Document Header CZP")
    var
        ToCashDocumentLineCZP: Record "Cash Document Line CZP";
        OldCashDocumentHeaderCZP: Record "Cash Document Header CZP";
        FromCashDocumentHeaderCZP: Record "Cash Document Header CZP";
        FromCashDocumentLineCZP: Record "Cash Document Line CZP";
        FromPostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP";
        FromPostedCashDocumentLineCZP: Record "Posted Cash Document Line CZP";
        CashDocumentReleaseCZP: Codeunit "Cash Document-Release CZP";
        ErrorContextElement: Codeunit "Error Context Element";
        ErrorMessageHandler: Codeunit "Error Message Handler";
        DefaultDimSource: List of [Dictionary of [Integer, Code[20]]];
        NextLineNo: Integer;
        LinesNotCopied: Integer;
        ReleaseDocument: Boolean;
        EnterDocumentNoErr: Label 'Please enter a Document No.';
    begin
        ToCashDocumentHeaderCZP.TestField(ToCashDocumentHeaderCZP.Status, ToCashDocumentHeaderCZP.Status::Open);
        if FromDocNo = '' then
            Error(EnterDocumentNoErr);
        ToCashDocumentHeaderCZP.Find();

        case FromDocType of
            CashDocType::"Cash Document":
                begin
                    FromCashDocumentHeaderCZP.Get(FromCashDeskNo, FromDocNo);
                    CheckCashdDocItselfCopy(ToCashDocumentHeaderCZP, FromCashDocumentHeaderCZP);

                    if not IncludeHeader and not RecalculateLines then
                        CheckFromCashDocumentHeader(FromCashDocumentHeaderCZP, ToCashDocumentHeaderCZP);
                end;
            CashDocType::"Posted Cash Document":
                begin
                    FromPostedCashDocumentHdrCZP.Get(FromCashDeskNo, FromDocNo);

                    if not IncludeHeader and not RecalculateLines then
                        CheckFromPostedCashDocumentHeader(FromPostedCashDocumentHdrCZP, ToCashDocumentHeaderCZP);
                end;
        end;

        ToCashDocumentLineCZP.LockTable();
        ToCashDocumentLineCZP.SetRange("Cash Desk No.", ToCashDocumentHeaderCZP."Cash Desk No.");
        ToCashDocumentLineCZP.SetRange("Cash Document No.", ToCashDocumentHeaderCZP."No.");
        if IncludeHeader then
            if not ToCashDocumentLineCZP.IsEmpty() then begin
                Commit();
                if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(DeleteLinesQst, ToCashDocumentHeaderCZP."Cash Desk No.", ToCashDocumentHeaderCZP."No."), true) then
                    exit;
                ToCashDocumentLineCZP.DeleteAll(true);
            end;

        if ToCashDocumentLineCZP.FindLast() then
            NextLineNo := ToCashDocumentLineCZP."Line No."
        else
            NextLineNo := 0;

        if IncludeHeader then begin
            OldCashDocumentHeaderCZP := ToCashDocumentHeaderCZP;
            case FromDocType of
                CashDocType::"Cash Document":
                    ToCashDocumentHeaderCZP.TransferFields(FromCashDocumentHeaderCZP, false);
                CashDocType::"Posted Cash Document":
                    ToCashDocumentHeaderCZP.TransferFields(FromPostedCashDocumentHdrCZP, false);
            end;

            if ToCashDocumentHeaderCZP.Status = ToCashDocumentHeaderCZP.Status::Released then begin
                ToCashDocumentHeaderCZP.Status := ToCashDocumentHeaderCZP.Status::Open;
                ToCashDocumentHeaderCZP."Released Amount" := 0;
                ReleaseDocument := true;
            end;

            CopyFieldsFromOldCashDocHeader(ToCashDocumentHeaderCZP, OldCashDocumentHeaderCZP);
            if RecalculateLines then begin
                DimensionManagement.AddDimSource(DefaultDimSource, Database::"Responsibility Center", ToCashDocumentHeaderCZP."Responsibility Center", false);
                DimensionManagement.AddDimSource(DefaultDimSource, Database::"Salesperson/Purchaser", ToCashDocumentHeaderCZP."Salespers./Purch. Code", false);
                DimensionManagement.AddDimSource(DefaultDimSource, Database::"Cash Desk CZP", ToCashDocumentHeaderCZP."Cash Desk No.", false);
                DimensionManagement.AddDimSource(DefaultDimSource, ToCashDocumentHeaderCZP.GetPartnerTableNo(), ToCashDocumentHeaderCZP."Partner No.", false);
                ToCashDocumentHeaderCZP.CreateDim(DefaultDimSource);
            end;
            ToCashDocumentHeaderCZP."No. Printed" := 0;
            ToCashDocumentHeaderCZP.Modify();
        end;

        LinesNotCopied := 0;
        ErrorMessageManagement.Activate(ErrorMessageHandler);
        ErrorMessageManagement.PushContext(ErrorContextElement, ToCashDocumentHeaderCZP.RecordId, 0, StrSubstNo(CashErrorContextMsg, FromDocNo));
        case FromDocType of
            CashDocType::"Cash Document":
                begin
                    FromCashDocumentLineCZP.Reset();
                    FromCashDocumentLineCZP.SetRange("Cash Desk No.", FromCashDocumentHeaderCZP."Cash Desk No.");
                    FromCashDocumentLineCZP.SetRange("Cash Document No.", FromCashDocumentHeaderCZP."No.");
                    if FromCashDocumentLineCZP.FindSet() then
                        repeat
                            CopyCashDocLine(ToCashDocumentHeaderCZP, ToCashDocumentLineCZP, FromCashDocumentHeaderCZP, FromCashDocumentLineCZP, NextLineNo, LinesNotCopied);
                        until FromCashDocumentLineCZP.Next() = 0;
                end;
            CashDocType::"Posted Cash Document":
                begin
                    FromPostedCashDocumentLineCZP.Reset();
                    FromPostedCashDocumentLineCZP.SetRange("Cash Desk No.", FromPostedCashDocumentHdrCZP."Cash Desk No.");
                    FromPostedCashDocumentLineCZP.SetRange("Cash Document No.", FromPostedCashDocumentHdrCZP."No.");
                    CopyPostedCashDocLinesToDoc(ToCashDocumentHeaderCZP, FromPostedCashDocumentLineCZP, LinesNotCopied);
                end;
        end;

        if ReleaseDocument then begin
            ToCashDocumentHeaderCZP.Status := ToCashDocumentHeaderCZP.Status::Released;
            CashDocumentReleaseCZP.Reopen(ToCashDocumentHeaderCZP);
        end else
            if (FromDocType = CashDocType::"Cash Document") and
               not IncludeHeader and not RecalculateLines
            then
                if FromCashDocumentHeaderCZP.Status = FromCashDocumentHeaderCZP.Status::Released then begin
                    CashDocumentReleaseCZP.Run(ToCashDocumentHeaderCZP);
                    CashDocumentReleaseCZP.Reopen(ToCashDocumentHeaderCZP);
                end;

        if ErrorMessageManagement.GetLastErrorID() > 0 then
            ErrorMessageHandler.NotifyAboutErrors();
    end;

    local procedure GetLastToCashDocLineNo(ToCashDocumentHeaderCZP: Record "Cash Document Header CZP"): Decimal
    var
        ToCashDocumentLineCZP: Record "Cash Document Line CZP";
    begin
        ToCashDocumentLineCZP.LockTable();
        ToCashDocumentLineCZP.SetRange("Cash Desk No.", ToCashDocumentHeaderCZP."Cash Desk No.");
        ToCashDocumentLineCZP.SetRange("Cash Document No.", ToCashDocumentHeaderCZP."No.");
        if ToCashDocumentLineCZP.FindLast() then
            exit(ToCashDocumentLineCZP."Line No.");
        exit(0);
    end;

    local procedure CheckCashdDocItselfCopy(FromCashDocumentHeaderCZP: Record "Cash Document Header CZP"; ToCashDocumentHeaderCZP: Record "Cash Document Header CZP")
    var
        CopyItselfErr: Label 'Document %1 %2 cannot be copied onto itself.', Comment = '%1 = Cash Desk No., %2 = Cash Document No.';
    begin
        if (FromCashDocumentHeaderCZP."Cash Desk No." = ToCashDocumentHeaderCZP."Cash Desk No.") and
           (FromCashDocumentHeaderCZP."No." = ToCashDocumentHeaderCZP."No.")
        then
            Error(CopyItselfErr, ToCashDocumentHeaderCZP."Cash Desk No.", ToCashDocumentHeaderCZP."No.");
    end;

    local procedure CheckFromCashDocumentHeader(FromCashDocumentHeaderCZP: Record "Cash Document Header CZP"; ToCashDocumentHeaderCZP: Record "Cash Document Header CZP")
    begin
        FromCashDocumentHeaderCZP.TestField("Currency Code", ToCashDocumentHeaderCZP."Currency Code");
        FromCashDocumentHeaderCZP.TestField("Amounts Including VAT", ToCashDocumentHeaderCZP."Amounts Including VAT");
    end;

    local procedure CheckFromPostedCashDocumentHeader(FromPostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP"; ToCashDocumentHeaderCZP: Record "Cash Document Header CZP")
    begin
        FromPostedCashDocumentHdrCZP.TestField("Currency Code", ToCashDocumentHeaderCZP."Currency Code");
        FromPostedCashDocumentHdrCZP.TestField("Amounts Including VAT", ToCashDocumentHeaderCZP."Amounts Including VAT");
    end;

    local procedure CopyFieldsFromOldCashDocHeader(var ToCashDocumentHeaderCZP: Record "Cash Document Header CZP"; OldCashDocumentHeaderCZP: Record "Cash Document Header CZP")
    begin
        ToCashDocumentHeaderCZP."No. Series" := OldCashDocumentHeaderCZP."No. Series";
        ToCashDocumentHeaderCZP."Created ID" := OldCashDocumentHeaderCZP."Created ID";
        ToCashDocumentHeaderCZP."Released ID" := OldCashDocumentHeaderCZP."Released ID";
        ToCashDocumentHeaderCZP."Created Date" := OldCashDocumentHeaderCZP."Created Date";
    end;

    local procedure CopyCashDocLine(var ToCashDocumentHeaderCZP: Record "Cash Document Header CZP"; var ToCashDocumentLineCZP: Record "Cash Document Line CZP"; var FromCashDocumentHeaderCZP: Record "Cash Document Header CZP"; var FromCashDocumentLineCZP: Record "Cash Document Line CZP"; var NextLineNo: Integer; var LinesNotCopied: Integer): Boolean
    var
        CopyThisLine: Boolean;
    begin
        CopyThisLine := true;

        if CashDeskManagementCZP.IsEntityBlocked(FromCashDocumentLineCZP."Account Type", FromCashDocumentLineCZP."Account No.") then begin
            LinesNotCopied += 1;
            exit(false);
        end;

        if RecalculateLines and not FromCashDocumentLineCZP."System-Created Entry" then
            ToCashDocumentLineCZP.Init()
        else
            ToCashDocumentLineCZP := FromCashDocumentLineCZP;

        NextLineNo += 10000;
        ToCashDocumentLineCZP."Cash Desk No." := ToCashDocumentHeaderCZP."Cash Desk No.";
        ToCashDocumentLineCZP."Cash Document No." := ToCashDocumentHeaderCZP."No.";
        ToCashDocumentLineCZP."Line No." := NextLineNo;
        ToCashDocumentLineCZP.Validate("Currency Code", FromCashDocumentHeaderCZP."Currency Code");

        UpdateCashDocLine(ToCashDocumentHeaderCZP, ToCashDocumentLineCZP, FromCashDocumentHeaderCZP, FromCashDocumentLineCZP, CopyThisLine);

        if not RecalculateLines then begin
            ToCashDocumentLineCZP."Dimension Set ID" := FromCashDocumentLineCZP."Dimension Set ID";
            ToCashDocumentLineCZP."Shortcut Dimension 1 Code" := FromCashDocumentLineCZP."Shortcut Dimension 1 Code";
            ToCashDocumentLineCZP."Shortcut Dimension 2 Code" := FromCashDocumentLineCZP."Shortcut Dimension 2 Code";
        end;

        if CopyThisLine then
            ToCashDocumentLineCZP.Insert()
        else
            LinesNotCopied += 1;
        exit(true);
    end;

    local procedure UpdateCashDocLine(var ToCashDocumentHeaderCZP: Record "Cash Document Header CZP"; var ToCashDocumentLineCZP: Record "Cash Document Line CZP"; var FromCashDocumentHeaderCZP: Record "Cash Document Header CZP"; var FromCashDocumentLineCZP: Record "Cash Document Line CZP"; var CopyThisLine: Boolean)
    var
        GLAccount: Record "G/L Account";
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        if RecalculateLines and not FromCashDocumentLineCZP."System-Created Entry" then begin
            if FromCashDocumentLineCZP."Cash Desk Event" <> '' then
                ToCashDocumentLineCZP.Validate("Cash Desk Event", FromCashDocumentLineCZP."Cash Desk Event")
            else begin
                ToCashDocumentLineCZP.Validate("Account Type", FromCashDocumentLineCZP."Account Type");
                ToCashDocumentLineCZP.Description := FromCashDocumentLineCZP.Description;
                ToCashDocumentLineCZP.Validate("Description 2", FromCashDocumentLineCZP."Description 2");
                if (FromCashDocumentLineCZP."Account Type" <> FromCashDocumentLineCZP."Account Type"::" ") and (FromCashDocumentLineCZP."Account No." <> '') then
                    if ToCashDocumentLineCZP."Account Type" = ToCashDocumentLineCZP."Account Type"::"G/L Account" then begin
                        ToCashDocumentLineCZP."Account No." := FromCashDocumentLineCZP."Account No.";
                        if GLAccount."No." <> FromCashDocumentLineCZP."Account No." then
                            GLAccount.Get(FromCashDocumentLineCZP."Account No.");
                        CopyThisLine := GLAccount."Direct Posting";
                        if CopyThisLine then
                            ToCashDocumentLineCZP.Validate("Account No.", FromCashDocumentLineCZP."Account No.");
                    end else
                        ToCashDocumentLineCZP.Validate("Account No.", FromCashDocumentLineCZP."Account No.");
            end;

            if (FromCashDocumentHeaderCZP."Currency Code" <> ToCashDocumentHeaderCZP."Currency Code") or
               (FromCashDocumentHeaderCZP."Amounts Including VAT" <> ToCashDocumentHeaderCZP."Amounts Including VAT")
            then
                ToCashDocumentLineCZP.Amount := 0
            else
                ToCashDocumentLineCZP.Validate(Amount, FromCashDocumentLineCZP.Amount);
            if (FromCashDocumentLineCZP."Account Type" = FromCashDocumentLineCZP."Account Type"::" ") and (FromCashDocumentLineCZP."Account No." <> '') then
                ToCashDocumentLineCZP.Validate("Account No.", FromCashDocumentLineCZP."Account No.");
        end else
            if VATPostingSetup.Get(ToCashDocumentLineCZP."VAT Bus. Posting Group", ToCashDocumentLineCZP."VAT Prod. Posting Group") then
                ToCashDocumentLineCZP."VAT Identifier" := VATPostingSetup."VAT Identifier";
    end;

    local procedure CopyPostedCashDocLinesToDoc(ToCashDocumentHeaderCZP: Record "Cash Document Header CZP"; var FromPostedCashDocumentLineCZP: Record "Posted Cash Document Line CZP"; var LinesNotCopied: Integer)
    var
        FromPostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP";
        FromCashDocumentHeaderCZP: Record "Cash Document Header CZP";
        FromCashDocumentLineCZP: Record "Cash Document Line CZP";
        ToCashDocumentLineCZP: Record "Cash Document Line CZP";
        OldDocNo: Code[20];
        OldCashDeskNo: Code[20];
        NextLineNo: Integer;
        ToLineCounter: Integer;
        InsertDocNoLine: Boolean;
    begin
        InitCurrency(ToCashDocumentHeaderCZP."Currency Code");
        Clear(ToLineCounter);
        Clear(OldDocNo);
        Clear(OldCashDeskNo);
        if FromPostedCashDocumentLineCZP.FindSet() then
            repeat
                if (FromPostedCashDocumentHdrCZP."Cash Desk No." <> FromPostedCashDocumentLineCZP."Cash Desk No.") or
                   (FromPostedCashDocumentHdrCZP."No." <> FromPostedCashDocumentLineCZP."Cash Document No.")
                then
                    FromPostedCashDocumentHdrCZP.Get(FromPostedCashDocumentLineCZP."Cash Desk No.", FromPostedCashDocumentLineCZP."Cash Document No.");

                FromCashDocumentHeaderCZP.TransferFields(FromPostedCashDocumentHdrCZP);
                FromCashDocumentLineCZP.TransferFields(FromPostedCashDocumentLineCZP);

                if (FromPostedCashDocumentLineCZP."Cash Document No." <> OldDocNo) or (FromPostedCashDocumentLineCZP."Cash Desk No." <> OldCashDeskNo) then begin
                    OldDocNo := FromPostedCashDocumentLineCZP."Cash Document No.";
                    OldCashDeskNo := FromPostedCashDocumentLineCZP."Cash Desk No.";
                    InsertDocNoLine := true;
                end;

                NextLineNo := GetLastToCashDocLineNo(ToCashDocumentHeaderCZP);
                if InsertDocNoLine then begin
                    InsertOldCashDocNoLine(ToCashDocumentHeaderCZP, FromPostedCashDocumentLineCZP."Cash Document No.", FromPostedCashDocumentLineCZP."Cash Desk No.", NextLineNo);
                    InsertDocNoLine := false;
                end;
                ToLineCounter += 1;
                CopyCashDocLine(ToCashDocumentHeaderCZP, ToCashDocumentLineCZP, FromCashDocumentHeaderCZP, FromCashDocumentLineCZP, NextLineNo, LinesNotCopied);
            until FromPostedCashDocumentLineCZP.Next() = 0;
    end;

    local procedure InsertOldCashDocNoLine(ToCashDocumentHeaderCZP: Record "Cash Document Header CZP"; OldDocNo: Code[20]; OldCashDeskNo: Code[20]; var NextLineNo: Integer)
    var
        NewCashDocumentLineCZP: Record "Cash Document Line CZP";
        TwoPlaceholdersTok: Label '%1 %2:', Locked = true;
    begin
        NextLineNo += 10000;
        NewCashDocumentLineCZP.Init();
        NewCashDocumentLineCZP."Line No." := NextLineNo;
        NewCashDocumentLineCZP."Cash Desk No." := ToCashDocumentHeaderCZP."Cash Desk No.";
        NewCashDocumentLineCZP."Cash Document No." := ToCashDocumentHeaderCZP."No.";
        NewCashDocumentLineCZP.Description := StrSubstNo(TwoPlaceholdersTok, OldCashDeskNo, OldDocNo);
        NewCashDocumentLineCZP.Insert();
    end;

    local procedure InitCurrency(CurrencyCode: Code[10])
    begin
        if CurrencyCode <> '' then
            Currency.Get(CurrencyCode)
        else
            Currency.InitRoundingPrecision();
        Currency.TestField("Unit-Amount Rounding Precision");
        Currency.TestField("Amount Rounding Precision");
    end;
}
