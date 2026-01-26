// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.VAT.Setup;
using System.Utilities;

codeunit 11725 "Cash Document-Release CZP"
{
    TableNo = "Cash Document Header CZP";

    trigger OnRun()
    var
        VATPostingSetup: Record "VAT Posting Setup";
        GenJnlCheckLine: Codeunit "Gen. Jnl.-Check Line";
        IsHandled: Boolean;
    begin
        if Rec.Status = Rec.Status::Released then
            exit;
        OnBeforeReleaseCashDocument(Rec);
        Rec.CheckCashDocReleaseRestrictions();

        CheckCashDocument(Rec);

        IsHandled := false;
        OnOnRunOnBeforeCheckCashDocLines(Rec, IsHandled);
        if not IsHandled then begin
            CashDocumentLineCZP.Reset();
            CashDocumentLineCZP.SetRange("Cash Desk No.", Rec."Cash Desk No.");
            CashDocumentLineCZP.SetRange("Cash Document No.", Rec."No.");
            CashDocumentLineCZP.FindSet();
            repeat
                if CashDocumentLineCZP."Account Type" <> CashDocumentLineCZP."Account Type"::" " then begin
                    CashDocumentLineCZP.TestField("Account No.");
                    CashDocumentLineCZP.TestField(Amount);
                    if CashDocumentLineCZP."Gen. Posting Type" <> CashDocumentLineCZP."Gen. Posting Type"::" " then
                        VATPostingSetup.Get(CashDocumentLineCZP."VAT Bus. Posting Group", CashDocumentLineCZP."VAT Prod. Posting Group");
                    CashDocumentPostCZP.InitGenJnlLine(Rec, CashDocumentLineCZP);
                    CashDocumentPostCZP.GetGenJnlLine(GenJournalLine);
                    GenJnlCheckLine.RunCheck(GenJournalLine);
                end;
            until CashDocumentLineCZP.Next() = 0;
        end;

        CashDocumentHeaderCZP.Get(Rec."Cash Desk No.", Rec."No.");
        CashDocumentHeaderCZP.Status := Rec.Status::Released;
        CashDocumentHeaderCZP."Released ID" := CopyStr(UserId(), 1, MaxStrLen(CashDocumentHeaderCZP."Released ID"));
        CashDocumentHeaderCZP.CalcFields("Amount Including VAT");
        CashDocumentHeaderCZP."Released Amount" := CashDocumentHeaderCZP."Amount Including VAT";
        CashDocumentHeaderCZP.Modify();
        Rec := CashDocumentHeaderCZP;
        OnAfterReleaseCashDocument(Rec);
    end;

    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
        CashDocumentLineCZP: Record "Cash Document Line CZP";
        GenJournalLine: Record "Gen. Journal Line";
        CashDeskCZP: Record "Cash Desk CZP";
        ConfirmManagement: Codeunit "Confirm Management";
        CashDeskManagementCZP: Codeunit "Cash Desk Management CZP";
        CashDocumentPostCZP: Codeunit "Cash Document-Post CZP";
        LinesNotExistsErr: Label 'There are no Cash Document Lines to release.';
        AmountExceededLimitErr: Label 'Cash Document Amount exceeded maximal limit (%1).', Comment = '%1 = maximal limit';
        BalanceGreaterThanErr: Label 'Balance will be greater than %1 after release.', Comment = '%1 = fieldcaption';
        BalanceLowerThanErr: Label 'Balance will be lower than %1 after release.', Comment = '%1 = fieldcaption';
        BalanceGreaterThanQst: Label 'Balance will be greater than %1 after release.\\Do you want to continue?', Comment = '%1 = fieldcaption';
        BalanceLowerThanQst: Label 'Balance will be lower than %1 after release.\\Do you want to continue?', Comment = '%1 = fieldcaption';
        EmptyFieldQst: Label '%1 or %2 is empty.\\Do you want to continue?', Comment = '%1 = fieldcaption, %2 = fieldcaption';
        ApprovalProcessReleaseErr: Label 'This document can only be released when the approval process is complete.';
        ApprovalProcessReopenErr: Label 'The approval process must be cancelled or completed to reopen this document.';
        NotEqualErr: Label '%1 is not equal %2.', Comment = '%1 = Amount Including VAT FieldCaption, %2 = Released Amount FieldCaption';
        MustBePositiveErr: Label 'must be positive';
        CashPaymentLimitErr: Label 'The maximum daily limit of cash payments of %1 was exceeded for the partner %2.', Comment = '%1 = amount of limit of cash payment; %2 = number of partner';

    procedure Reopen(var CashDocumentHeaderCZP: Record "Cash Document Header CZP")
    begin
        OnBeforeReopenCashDocument(CashDocumentHeaderCZP);
        if CashDocumentHeaderCZP.Status = CashDocumentHeaderCZP.Status::Open then
            exit;
        CashDocumentHeaderCZP.Status := CashDocumentHeaderCZP.Status::Open;
        CashDocumentHeaderCZP.Modify(true);
        OnAfterReopenCashDocument(CashDocumentHeaderCZP);
    end;

    procedure PerformManualRelease(var CashDocumentHeaderCZP: Record "Cash Document Header CZP")
    var
        CashDocumentApprovMgtCZP: Codeunit "Cash Document Approv. Mgt. CZP";
    begin
        if CashDocumentApprovMgtCZP.IsCashDocApprovalsWorkflowEnabled(CashDocumentHeaderCZP) and (CashDocumentHeaderCZP.Status = CashDocumentHeaderCZP.Status::Open) then
            Error(ApprovalProcessReleaseErr);

        Codeunit.Run(Codeunit::"Cash Document-Release CZP", CashDocumentHeaderCZP);
    end;

    procedure PerformManualReopen(var CashDocumentHeaderCZP: Record "Cash Document Header CZP")
    begin
        if CashDocumentHeaderCZP.Status = CashDocumentHeaderCZP.Status::"Pending Approval" then
            Error(ApprovalProcessReopenErr);

        if not (CashDocumentHeaderCZP.Status in [CashDocumentHeaderCZP.Status::Approved, CashDocumentHeaderCZP.Status::Released]) then
            CashDocumentHeaderCZP.FieldError(Status);

        Reopen(CashDocumentHeaderCZP);
    end;

    procedure CheckCashDocument(CashDocumentHeaderCZP: Record "Cash Document Header CZP")
    begin
        CheckExceededBalanceLimit(CashDocumentHeaderCZP);
        CheckCashDocumentForPosting(CashDocumentHeaderCZP);
    end;

    internal procedure CheckCashDocumentForPosting(CashDocumentHeaderCZP: Record "Cash Document Header CZP")
    begin
        CheckCashDesk(CashDocumentHeaderCZP);
        CheckMandatoryFields(CashDocumentHeaderCZP);
        CheckCashDocumentAmount(CashDocumentHeaderCZP);
        CheckCashDocumentLines(CashDocumentHeaderCZP);
        CheckCashPaymentLimit(CashDocumentHeaderCZP);
    end;

    local procedure CheckCashDesk(CashDocumentHeaderCZP: Record "Cash Document Header CZP")
    begin
        GetCashDesk(CashDocumentHeaderCZP."Cash Desk No.");
        CashDeskCZP.TestField("Bank Acc. Posting Group");
        CashDeskCZP.TestField(Blocked, false);
        if CashDocumentHeaderCZP.Status <> CashDocumentHeaderCZP.Status::Released then
            CashDeskManagementCZP.CheckUserRights(CashDeskCZP."No.", Enum::"Cash Document Action CZP"::Release);
    end;

    local procedure CheckCashDocumentAmount(CashDocumentHeaderCZP: Record "Cash Document Header CZP")
    begin
        GetCashDesk(CashDocumentHeaderCZP."Cash Desk No.");
        CashDocumentHeaderCZP.CalcFields(CashDocumentHeaderCZP."Amount Including VAT");

        if CashDocumentHeaderCZP."Released Amount" <> 0 then
            if CashDocumentHeaderCZP."Amount Including VAT" <> CashDocumentHeaderCZP."Released Amount" then
                Error(NotEqualErr,
                    CashDocumentHeaderCZP.FieldCaption(CashDocumentHeaderCZP."Amount Including VAT"),
                    CashDocumentHeaderCZP.FieldCaption(CashDocumentHeaderCZP."Released Amount"));

        if CashDocumentHeaderCZP."Amount Including VAT" < 0 then
            CashDocumentHeaderCZP.FieldError(CashDocumentHeaderCZP."Amount Including VAT", MustBePositiveErr);

        case CashDocumentHeaderCZP."Document Type" of
            CashDocumentHeaderCZP."Document Type"::Receipt:
                if CashDocumentHeaderCZP."Amount Including VAT" > CashDeskCZP."Cash Receipt Limit" then
                    Error(AmountExceededLimitErr, CashDeskCZP."Cash Receipt Limit");
            CashDocumentHeaderCZP."Document Type"::Withdrawal:
                if CashDocumentHeaderCZP."Amount Including VAT" > CashDeskCZP."Cash Withdrawal Limit" then
                    Error(AmountExceededLimitErr, CashDeskCZP."Cash Withdrawal Limit");
        end;
    end;

    local procedure CheckExceededBalanceLimit(CashDocumentHeaderCZP: Record "Cash Document Header CZP")
    var
        CurrentBalance: Decimal;
    begin
        GetCashDesk(CashDocumentHeaderCZP."Cash Desk No.");
        if (CashDeskCZP."Max. Balance Checking" = CashDeskCZP."Max. Balance Checking"::"No Checking") and
           (CashDeskCZP."Min. Balance Checking" = CashDeskCZP."Min. Balance Checking"::"No Checking")
        then
            exit;

        CashDocumentHeaderCZP.CalcFields(CashDocumentHeaderCZP."Amount Including VAT");
        case CashDocumentHeaderCZP."Document Type" of
            CashDocumentHeaderCZP."Document Type"::Receipt:
                CurrentBalance := CashDeskCZP.CalcBalance() + CashDocumentHeaderCZP."Amount Including VAT";
            CashDocumentHeaderCZP."Document Type"::Withdrawal:
                CurrentBalance := CashDeskCZP.CalcBalance() - CashDocumentHeaderCZP."Amount Including VAT";
        end;

        case CashDeskCZP."Max. Balance Checking" of
            CashDeskCZP."Max. Balance Checking"::Warning:
                if CashDocumentHeaderCZP."Document Type" = CashDocumentHeaderCZP."Document Type"::Receipt then
                    if CurrentBalance > CashDeskCZP."Max. Balance" then
                        if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(BalanceGreaterThanQst, CashDeskCZP.FieldCaption("Max. Balance")), false) then
                            Error('');
            CashDeskCZP."Max. Balance Checking"::Blocking:
                if CashDocumentHeaderCZP."Document Type" = CashDocumentHeaderCZP."Document Type"::Receipt then
                    if CurrentBalance > CashDeskCZP."Max. Balance" then
                        Error(BalanceGreaterThanErr, CashDeskCZP.FieldCaption("Max. Balance"));
        end;

        case CashDeskCZP."Min. Balance Checking" of
            CashDeskCZP."Min. Balance Checking"::Warning:
                if CashDocumentHeaderCZP."Document Type" = CashDocumentHeaderCZP."Document Type"::Withdrawal then
                    if CurrentBalance < CashDeskCZP."Min. Balance" then
                        if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(BalanceLowerThanQst, CashDeskCZP.FieldCaption("Min. Balance")), false) then
                            Error('');
            CashDeskCZP."Min. Balance Checking"::Blocking:
                if CashDocumentHeaderCZP."Document Type" = CashDocumentHeaderCZP."Document Type"::Withdrawal then
                    if CurrentBalance < CashDeskCZP."Min. Balance" then
                        Error(BalanceLowerThanErr, CashDeskCZP.FieldCaption("Min. Balance"));
        end;
    end;

    local procedure CheckMandatoryFields(CashDocumentHeaderCZP: Record "Cash Document Header CZP")
    begin
        CashDocumentHeaderCZP.TestField(CashDocumentHeaderCZP."No.");
        CashDocumentHeaderCZP.TestField(CashDocumentHeaderCZP."Posting Date");
        CashDocumentHeaderCZP.VATRounding();
        CashDocumentHeaderCZP.CalcFields(CashDocumentHeaderCZP."Amount Including VAT", CashDocumentHeaderCZP."Amount Including VAT (LCY)");
        CashDocumentHeaderCZP.TestField(CashDocumentHeaderCZP."Amount Including VAT");
        CashDocumentHeaderCZP.TestField(CashDocumentHeaderCZP."Amount Including VAT (LCY)");
        CashDocumentHeaderCZP.TestField(CashDocumentHeaderCZP."Document Date");
        CashDocumentHeaderCZP.TestField(CashDocumentHeaderCZP."Payment Purpose");
        if CashDocumentHeaderCZP."Currency Code" <> '' then
            CashDocumentHeaderCZP.TestField(CashDocumentHeaderCZP."Currency Factor");

        GetCashDesk(CashDocumentHeaderCZP."Cash Desk No.");
        case CashDeskCZP."Payed To/By Checking" of
            CashDeskCZP."Payed To/By Checking"::Warning:
                case CashDocumentHeaderCZP."Document Type" of
                    CashDocumentHeaderCZP."Document Type"::Receipt:
                        if (CashDocumentHeaderCZP."Received By" = '') or (CashDocumentHeaderCZP."Received From" = '') then
                            if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(EmptyFieldQst, CashDocumentHeaderCZP.FieldCaption(CashDocumentHeaderCZP."Received By"),
                                                                                    CashDocumentHeaderCZP.FieldCaption(CashDocumentHeaderCZP."Received From")), false) then
                                Error('');
                    CashDocumentHeaderCZP."Document Type"::Withdrawal:
                        if (CashDocumentHeaderCZP."Paid By" = '') or (CashDocumentHeaderCZP."Paid To" = '') then
                            if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(EmptyFieldQst, CashDocumentHeaderCZP.FieldCaption(CashDocumentHeaderCZP."Paid By"),
                                                                                    CashDocumentHeaderCZP.FieldCaption(CashDocumentHeaderCZP."Paid To")), false) then
                                Error('');
                end;
            CashDeskCZP."Payed To/By Checking"::Blocking:
                case CashDocumentHeaderCZP."Document Type" of
                    CashDocumentHeaderCZP."Document Type"::Receipt:
                        begin
                            CashDocumentHeaderCZP.TestField(CashDocumentHeaderCZP."Received By");
                            CashDocumentHeaderCZP.TestField(CashDocumentHeaderCZP."Received From");
                        end;
                    CashDocumentHeaderCZP."Document Type"::Withdrawal:
                        begin
                            CashDocumentHeaderCZP.TestField(CashDocumentHeaderCZP."Paid By");
                            CashDocumentHeaderCZP.TestField(CashDocumentHeaderCZP."Paid To");
                        end;
                end;
        end;
    end;

    local procedure CheckCashDocumentLines(CashDocumentHeaderCZP: Record "Cash Document Header CZP")
    var
        SuggestedAmountToApplyQst: Label '%1 Ledger Entry %2 %3 is suggested to application on other documents in the system.\Do you want to use it for this Cash Document?', Comment = '%1 = Account Type, %2 = Applies-To Doc. Type, %3 = Applies-To Doc. No.';
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckCashDocumentLines(CashDocumentHeaderCZP, IsHandled);
        if IsHandled then
            exit;

        CashDocumentLineCZP.Reset();
        CashDocumentLineCZP.SetRange("Cash Desk No.", CashDocumentHeaderCZP."Cash Desk No.");
        CashDocumentLineCZP.SetRange("Cash Document No.", CashDocumentHeaderCZP."No.");
        CashDocumentLineCZP.SetFilter("Account No.", '<>%1', '');
        if CashDocumentLineCZP.IsEmpty() then
            Error(LinesNotExistsErr);

        CashDocumentLineCZP.SetRange("Account No.");
        CashDocumentLineCZP.SetFilter(Amount, '<>%1', 0);
        if CashDocumentLineCZP.IsEmpty() then
            Error(LinesNotExistsErr);

        CashDocumentLineCZP.SetFilter("Account Type", '<>%1', CashDocumentLineCZP."Account Type"::" ");
        CashDocumentLineCZP.SetRange(Amount, 0);
        if CashDocumentLineCZP.FindFirst() then
            CashDocumentLineCZP.FieldError(Amount);

        CashDocumentLineCZP.SetRange(Amount);
        if CashDocumentLineCZP.Findset() then
            repeat
                IsHandled := false;
                OnBeforeCheckCashDocumentLine(CashDocumentLineCZP, IsHandled);
                if not IsHandled then
                    if CashDocumentLineCZP."Applies-To Doc. No." <> '' then
                        if CashDocumentLineCZP.CalcRelatedAmountToApply() <> 0 then
                            if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(SuggestedAmountToApplyQst, CashDocumentLineCZP."Account Type", CashDocumentLineCZP."Applies-To Doc. Type", CashDocumentLineCZP."Applies-To Doc. No."), false) then
                                Error('');
            until CashDocumentLineCZP.Next() = 0;
    end;

    local procedure CheckCashPaymentLimit(CashDocumentHeaderCZP: Record "Cash Document Header CZP")
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        TotalPostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP";
        TotalCashDocumentHeaderCZP: Record "Cash Document Header CZP";
        CashPaymentTotal: Decimal;
    begin
        GeneralLedgerSetup.Get();
        if GeneralLedgerSetup."Cash Payment Limit (LCY) CZP" = 0 then
            exit;

        if not (CashDocumentHeaderCZP."Partner Type" in [CashDocumentHeaderCZP."Partner Type"::Customer, CashDocumentHeaderCZP."Partner Type"::Vendor]) then
            exit;

        TotalPostedCashDocumentHdrCZP.SetRange("Partner Type", CashDocumentHeaderCZP."Partner Type");
        TotalPostedCashDocumentHdrCZP.SetRange("Partner No.", CashDocumentHeaderCZP."Partner No.");
        TotalPostedCashDocumentHdrCZP.SetRange("Posting Date", CashDocumentHeaderCZP."Posting Date");
        if TotalPostedCashDocumentHdrCZP.FindSet() then
            repeat
                TotalPostedCashDocumentHdrCZP.CalcFields("Amount Including VAT (LCY)");
                if TotalPostedCashDocumentHdrCZP."Document Type" = TotalPostedCashDocumentHdrCZP."Document Type"::Withdrawal then
                    CashPaymentTotal -= TotalPostedCashDocumentHdrCZP."Amount Including VAT (LCY)"
                else
                    CashPaymentTotal += TotalPostedCashDocumentHdrCZP."Amount Including VAT (LCY)";
            until TotalPostedCashDocumentHdrCZP.Next() = 0;

        TotalCashDocumentHeaderCZP.SetRange("Partner Type", CashDocumentHeaderCZP."Partner Type");
        TotalCashDocumentHeaderCZP.SetRange("Partner No.", CashDocumentHeaderCZP."Partner No.");
        TotalCashDocumentHeaderCZP.SetRange("Posting Date", CashDocumentHeaderCZP."Posting Date");
        if TotalCashDocumentHeaderCZP.FindSet() then
            repeat
                TotalCashDocumentHeaderCZP.CalcFields("Amount Including VAT (LCY)");
                if TotalCashDocumentHeaderCZP."Document Type" = TotalCashDocumentHeaderCZP."Document Type"::Withdrawal then
                    CashPaymentTotal -= TotalCashDocumentHeaderCZP."Amount Including VAT (LCY)"
                else
                    CashPaymentTotal += TotalCashDocumentHeaderCZP."Amount Including VAT (LCY)";
            until TotalCashDocumentHeaderCZP.Next() = 0;

        if Abs(CashPaymentTotal) > GeneralLedgerSetup."Cash Payment Limit (LCY) CZP" then
            Error(CashPaymentLimitErr, GeneralLedgerSetup."Cash Payment Limit (LCY) CZP", CashDocumentHeaderCZP."Partner No.");
    end;

    local procedure GetCashDesk(CashDeskNo: Code[20])
    begin
        if CashDeskCZP."No." <> CashDeskNo then
            CashDeskCZP.Get(CashDeskNo);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeReleaseCashDocument(var CashDocumentHeaderCZP: Record "Cash Document Header CZP")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterReleaseCashDocument(var CashDocumentHeaderCZP: Record "Cash Document Header CZP")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeReopenCashDocument(var CashDocumentHeaderCZP: Record "Cash Document Header CZP")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterReopenCashDocument(var CashDocumentHeaderCZP: Record "Cash Document Header CZP")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckCashDocumentLine(CashDocumentLineCZP: Record "Cash Document Line CZP"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnOnRunOnBeforeCheckCashDocLines(CashDocumentHeaderCZP: Record "Cash Document Header CZP"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeCheckCashDocumentLines(CashDocumentHeaderCZP: Record "Cash Document Header CZP"; var IsHandled: Boolean)
    begin
    end;
}
