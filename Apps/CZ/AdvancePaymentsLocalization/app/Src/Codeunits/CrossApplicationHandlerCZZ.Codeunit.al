// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Bank.Documents;
using Microsoft.Finance.CashDesk;
using Microsoft.Finance.ReceivablesPayables;
using System.Utilities;

codeunit 31418 "Cross Application Handler CZZ"
{
#if not CLEAN25
    ObsoleteState = Pending;
    ObsoleteReason = 'The Access property will be changed to Internal.';
    ObsoleteTag = '25.0';
#else
    Access = Internal;
#endif

    var
        ConfirmManagement: Codeunit "Confirm Management";

    [EventSubscriber(ObjectType::Table, Database::"Cash Document Line CZP", 'OnAfterCollectSuggestedApplication', '', false, false)]
    local procedure OnAfterCollectSuggestedApplicationCashDocumentLine(CashDocumentLineCZP: Record "Cash Document Line CZP"; var CrossApplicationBufferCZL: Record "Cross Application Buffer CZL")
    begin
        if CashDocumentLineCZP."Account Type" <> CashDocumentLineCZP."Account Type"::Vendor then
            exit;

        CollectSuggestedApplicationForPurchAdvLetter(
            CashDocumentLineCZP."Advance Letter No. CZZ", CashDocumentLineCZP, CrossApplicationBufferCZL);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Payment Order Line CZB", 'OnAfterCollectSuggestedApplication', '', false, false)]
    local procedure OnAfterCollectSuggestedApplicationPaymentOrderLine(PaymentOrderLineCZB: Record "Payment Order Line CZB"; var CrossApplicationBufferCZL: Record "Cross Application Buffer CZL")
    begin
        if PaymentOrderLineCZB.Type <> PaymentOrderLineCZB.Type::Vendor then
            exit;

        CollectSuggestedApplicationForPurchAdvLetter(
            PaymentOrderLineCZB."Purch. Advance Letter No. CZZ", PaymentOrderLineCZB, CrossApplicationBufferCZL);
    end;

    local procedure CollectSuggestedApplicationForPurchAdvLetter(PurchAdvanceLetterNo: Code[20]; CalledFrom: Variant; var CrossApplicationBufferCZL: Record "Cross Application Buffer CZL")
    var
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
    begin
        if PurchAdvanceLetterNo = '' then
            exit;
        PurchAdvLetterHeaderCZZ.Get(PurchAdvanceLetterNo);
        PurchAdvLetterHeaderCZZ.CollectSuggestedApplication(CalledFrom, CrossApplicationBufferCZL);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Cross Application Mgt. CZL", 'OnCollectSuggestedApplication', '', false, false)]
    local procedure AddApplicationOnCollectSuggestedApplication(
        CollectedForTableID: Integer; CollectedFor: Variant; var CrossApplicationBufferCZL: Record "Cross Application Buffer CZL")
    var
        CashDocumentLineCZP: Record "Cash Document Line CZP";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        IssPaymentOrderLineCZB: Record "Iss. Payment Order Line CZB";
    begin
        if CollectedForTableID <> Database::"Purch. Adv. Letter Header CZZ" then
            exit;

        PurchAdvLetterHeaderCZZ := CollectedFor;

        IssPaymentOrderLineCZB.SetRange("Purch. Advance Letter No. CZZ", PurchAdvLetterHeaderCZZ."No.");
        IssPaymentOrderLineCZB.SetFilter(Status, '<>%1', IssPaymentOrderLineCZB.Status::Canceled);
        if IssPaymentOrderLineCZB.FindSet() then
            repeat
                AddIssPaymentOrderLineToBuffer(IssPaymentOrderLineCZB, CrossApplicationBufferCZL);
            until IssPaymentOrderLineCZB.Next() = 0;

        CashDocumentLineCZP.SetRange("Advance Letter No. CZZ", PurchAdvLetterHeaderCZZ."No.");
        if CashDocumentLineCZP.FindSet() then
            repeat
                AddCashDocumentLineToBuffer(CashDocumentLineCZP, CrossApplicationBufferCZL);
            until CashDocumentLineCZP.Next() = 0;
    end;

    local procedure AddCashDocumentLineToBuffer(
        CashDocumentLineCZP: Record "Cash Document Line CZP";
        var CrossApplicationBufferCZL: Record "Cross Application Buffer CZL")
    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
    begin
        CashDocumentHeaderCZP.Get(CashDocumentLineCZP."Cash Desk No.", CashDocumentLineCZP."Cash Document No.");
        if CashDocumentHeaderCZP.Status <> CashDocumentHeaderCZP.Status::Released then
            exit;

        CrossApplicationBufferCZL.Init();
        CrossApplicationBufferCZL."Entry No." := CrossApplicationBufferCZL.Count() + 1;
        CrossApplicationBufferCZL."Table ID" := Database::"Cash Document Line CZP";
        CrossApplicationBufferCZL."Applied Document No." := CashDocumentLineCZP."Cash Document No.";
        CrossApplicationBufferCZL."Applied Document Line No." := CashDocumentLineCZP."Line No.";
        CrossApplicationBufferCZL."Applied Document Date" := CashDocumentHeaderCZP."Document Date";
        case CashDocumentHeaderCZP."Document Type" of
            CashDocumentHeaderCZP."Document Type"::Receipt:
                CrossApplicationBufferCZL."Amount (LCY)" := CashDocumentLineCZP."Amount Including VAT (LCY)";
            CashDocumentHeaderCZP."Document Type"::Withdrawal:
                CrossApplicationBufferCZL."Amount (LCY)" := -CashDocumentLineCZP."Amount Including VAT (LCY)";
        end;
        CrossApplicationBufferCZL.Insert();
    end;

    local procedure AddIssPaymentOrderLineToBuffer(
        IssPaymentOrderLineCZB: Record "Iss. Payment Order Line CZB";
        var CrossApplicationBufferCZL: Record "Cross Application Buffer CZL")
    var
        IssPaymentOrderHeaderCZB: Record "Iss. Payment Order Header CZB";
    begin
        IssPaymentOrderHeaderCZB.Get(IssPaymentOrderLineCZB."Payment Order No.");
        CrossApplicationBufferCZL.Init();
        CrossApplicationBufferCZL."Entry No." := CrossApplicationBufferCZL.Count() + 1;
        CrossApplicationBufferCZL."Table ID" := Database::"Iss. Payment Order Line CZB";
        CrossApplicationBufferCZL."Applied Document No." := IssPaymentOrderLineCZB."Payment Order No.";
        CrossApplicationBufferCZL."Applied Document Line No." := IssPaymentOrderLineCZB."Line No.";
        CrossApplicationBufferCZL."Applied Document Date" := IssPaymentOrderHeaderCZB."Document Date";
        CrossApplicationBufferCZL."Amount (LCY)" := -IssPaymentOrderLineCZB."Amount (LCY)";
        CrossApplicationBufferCZL.Insert();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Cash Document-Release CZP", 'OnBeforeCheckCashDocumentLine', '', false, false)]
    local procedure CheckSuggestedAmountToApplyOnBeforeCheckCashDocumentLine(CashDocumentLineCZP: Record "Cash Document Line CZP")
    var
        SuggestedAmountToApplyQst: Label 'Purchase Advance %1 is suggested to application on other documents in the system.\Do you want to use it for this Cash Document?', Comment = '%1 = Advance Letter No.';
    begin
        if (CashDocumentLineCZP."Account Type" = CashDocumentLineCZP."Account Type"::Vendor) and (CashDocumentLineCZP."Advance Letter No. CZZ" <> '') then
            if CashDocumentLineCZP.CalcRelatedAmountToApply() <> 0 then
                if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(SuggestedAmountToApplyQst, CashDocumentLineCZP."Advance Letter No. CZZ"), false) then
                    Error('');
    end;
}
