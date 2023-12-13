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
    var
        ConfirmManagement: Codeunit "Confirm Management";

    [EventSubscriber(ObjectType::Table, Database::"Cash Document Line CZP", 'OnBeforeFindRelatedAmoutToApply', '', false, false)]
    local procedure AddCashDocumentLineCZPOnBeforeFindRelatedAmoutToApply(CashDocumentLineCZP: Record "Cash Document Line CZP"; var AppliesToAdvanceLetterNo: Code[20])
    begin
        AppliesToAdvanceLetterNo := CashDocumentLineCZP."Advance Letter No. CZZ";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Cross Application Mgt. CZL", 'OnGetSuggestedAmountForPurchAdvLetterHeader', '', false, false)]
    local procedure AddCashDocumentLineCZPOnGetSuggestedAmountForPurchAdvLetterHeader(var TempCrossApplicationBufferCZL: Record "Cross Application Buffer CZL" temporary;
                                                                                      PurchAdvLetterHeaderNo: Code[20];
                                                                                      ExcludeTableID: Integer; ExcludeDocumentNo: Code[20]; ExcludeLineNo: Integer)
    var
        CashDocumentLineCZP: Record "Cash Document Line CZP";
    begin
        CashDocumentLineCZP.SetRange("Advance Letter No. CZZ", PurchAdvLetterHeaderNo);
        if CashDocumentLineCZP.FindSet() then
            repeat
                AddCashDocumentLineToBuffer(TempCrossApplicationBufferCZL, CashDocumentLineCZP, ExcludeTableID, ExcludeDocumentNo, ExcludeLineNo);
            until CashDocumentLineCZP.Next() = 0;
    end;

    local procedure AddCashDocumentLineToBuffer(var TempCrossApplicationBufferCZL: Record "Cross Application Buffer CZL" temporary;
                                    CashDocumentLineCZP: Record "Cash Document Line CZP";
                                    ExcludeTableID: Integer; ExcludeDocumentNo: Code[20]; ExcludeLineNo: Integer)
    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
    begin
        if (ExcludeTableID = Database::"Cash Document Line CZP") and
           (ExcludeDocumentNo = CashDocumentLineCZP."Cash Document No.") and
           (ExcludeLineNo = CashDocumentLineCZP."Line No.")
        then
            exit;

        CashDocumentHeaderCZP.Get(CashDocumentLineCZP."Cash Desk No.", CashDocumentLineCZP."Cash Document No.");
        if CashDocumentHeaderCZP.Status <> CashDocumentHeaderCZP.Status::Released then
            exit;

        TempCrossApplicationBufferCZL.Init();
        TempCrossApplicationBufferCZL."Entry No." := TempCrossApplicationBufferCZL.Count() + 1;
        TempCrossApplicationBufferCZL."Table ID" := Database::"Cash Document Line CZP";
        TempCrossApplicationBufferCZL."Applied Document No." := CashDocumentLineCZP."Cash Document No.";
        TempCrossApplicationBufferCZL."Applied Document Line No." := CashDocumentLineCZP."Line No.";
        TempCrossApplicationBufferCZL."Applied Document Date" := CashDocumentHeaderCZP."Document Date";
        case CashDocumentHeaderCZP."Document Type" of
            CashDocumentHeaderCZP."Document Type"::Receipt:
                TempCrossApplicationBufferCZL."Amount (LCY)" := CashDocumentLineCZP."Amount Including VAT (LCY)";
            CashDocumentHeaderCZP."Document Type"::Withdrawal:
                TempCrossApplicationBufferCZL."Amount (LCY)" := -CashDocumentLineCZP."Amount Including VAT (LCY)";
        end;
        TempCrossApplicationBufferCZL.Insert();
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

    [EventSubscriber(ObjectType::Table, Database::"Payment Order Line CZB", 'OnBeforeFindRelatedAmoutToApply', '', false, false)]
    local procedure AddPaymentOrderLineCZBOnBeforeFindRelatedAmoutToApply(PaymentOrderLineCZB: Record "Payment Order Line CZB"; var AppliesToAdvanceLetterNo: Code[20])
    begin
        AppliesToAdvanceLetterNo := PaymentOrderLineCZB."Purch. Advance Letter No. CZZ";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Cross Application Mgt. CZL", 'OnGetSuggestedAmountForPurchAdvLetterHeader', '', false, false)]
    local procedure AddIssPaymentOrderLineCZBOnGetSuggestedAmountForPurchAdvLetterHeader(var TempCrossApplicationBufferCZL: Record "Cross Application Buffer CZL" temporary;
                                                                                         PurchAdvLetterHeaderNo: Code[20];
                                                                                         ExcludeTableID: Integer; ExcludeDocumentNo: Code[20]; ExcludeLineNo: Integer)
    var
        IssPaymentOrderLineCZB: Record "Iss. Payment Order Line CZB";
    begin
        IssPaymentOrderLineCZB.SetRange("Purch. Advance Letter No. CZZ", PurchAdvLetterHeaderNo);
        IssPaymentOrderLineCZB.SetFilter(Status, '<>%1', IssPaymentOrderLineCZB.Status::Canceled);
        if IssPaymentOrderLineCZB.FindSet() then
            repeat
                AddPaymentOrderLineToBuffer(TempCrossApplicationBufferCZL, IssPaymentOrderLineCZB, ExcludeTableID, ExcludeDocumentNo, ExcludeLineNo);
            until IssPaymentOrderLineCZB.Next() = 0;
    end;

    local procedure AddPaymentOrderLineToBuffer(var TempCrossApplicationBufferCZL: Record "Cross Application Buffer CZL" temporary;
                                    IssPaymentOrderLineCZB: Record "Iss. Payment Order Line CZB";
                                    ExcludeTableID: Integer; ExcludeDocumentNo: Code[20]; ExcludeLineNo: Integer)
    var
        IssPaymentOrderHeaderCZB: Record "Iss. Payment Order Header CZB";
    begin
        if (ExcludeTableID = Database::"Iss. Payment Order Line CZB") and
           (ExcludeDocumentNo = IssPaymentOrderLineCZB."Payment Order No.") and
           (ExcludeLineNo = IssPaymentOrderLineCZB."Line No.")
        then
            exit;

        IssPaymentOrderHeaderCZB.Get(IssPaymentOrderLineCZB."Payment Order No.");
        TempCrossApplicationBufferCZL.Init();
        TempCrossApplicationBufferCZL."Entry No." := TempCrossApplicationBufferCZL.Count() + 1;
        TempCrossApplicationBufferCZL."Table ID" := Database::"Iss. Payment Order Line CZB";
        TempCrossApplicationBufferCZL."Applied Document No." := IssPaymentOrderLineCZB."Payment Order No.";
        TempCrossApplicationBufferCZL."Applied Document Line No." := IssPaymentOrderLineCZB."Line No.";
        TempCrossApplicationBufferCZL."Applied Document Date" := IssPaymentOrderHeaderCZB."Document Date";
        TempCrossApplicationBufferCZL."Amount (LCY)" := -IssPaymentOrderLineCZB."Amount (LCY)";
        TempCrossApplicationBufferCZL.Insert();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Issue Payment Order CZB", 'OnBeforeCheckPaymentOrderLine', '', false, false)]
    local procedure CheckSuggestedAmountToApplyOnBeforeCheckPaymentOrderLine(var PaymentOrderLineCZB: Record "Payment Order Line CZB")
    var
        SuggestedAmountToApplyQst: Label 'Purchase Advance %1 is suggested to application on other documents in the system.\Do you want to use it for this Payment Order?', Comment = '%1 = Purch. Advance Letter No.';
    begin
        if (PaymentOrderLineCZB.Type = PaymentOrderLineCZB.Type::Vendor) and (PaymentOrderLineCZB."Purch. Advance Letter No. CZZ" <> '') then
            if PaymentOrderLineCZB.CalcRelatedAmountToApply() <> 0 then
                if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(SuggestedAmountToApplyQst, PaymentOrderLineCZB."Purch. Advance Letter No. CZZ"), false) then
                    Error('');
    end;
}
