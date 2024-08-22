// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Finance.CashDesk;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Sales.Posting;
using Microsoft.Sales.Receivables;

codeunit 31008 "Sales-Post Handler CZZ"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforePostSalesDoc', '', false, false)]
    local procedure SalesPostOnBeforePostSalesDoc(var SalesHeader: Record "Sales Header")
    var
        SalesAdvLetterManagement: Codeunit "SalesAdvLetterManagement CZZ";
    begin
        if (not SalesHeader.Invoice) or (not SalesHeader.IsAdvanceLetterDocTypeCZZ()) then
            exit;

        SalesAdvLetterManagement.CheckAdvancePayment(SalesHeader.GetAdvLetterUsageDocTypeCZZ(), SalesHeader)
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales Handler CZP", 'OnBeforeCreateCashDocument', '', false, false)]
    local procedure SalesPostOnBeforeCreateCashDocument(var SalesHeader: Record "Sales Header"; var SalesInvoiceHeader: Record "Sales Invoice Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    begin
        SalesPostOnAfterFinalizePostingOnBeforeCommit(SalesHeader, SalesInvoiceHeader, GenJnlPostLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterFinalizePostingOnBeforeCommit', '', false, false)]
    local procedure SalesPostOnAfterFinalizePostingOnBeforeCommit(var SalesHeader: Record "Sales Header"; var SalesInvoiceHeader: Record "Sales Invoice Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    var
        AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        GetLastGLEntryNoCZZ: Codeunit "Get Last G/L Entry No. CZZ";
        SalesAdvLetterManagement: Codeunit "SalesAdvLetterManagement CZZ";
        AdvLetterUsageDocTypeCZZ: Enum "Adv. Letter Usage Doc.Type CZZ";
    begin
        if (not SalesHeader.Invoice) or (not SalesHeader.IsAdvanceLetterDocTypeCZZ()) then
            exit;

        SalesInvoiceHeader.CalcFields("Remaining Amount");
        if SalesInvoiceHeader."Remaining Amount" = 0 then
            exit;

        AdvLetterUsageDocTypeCZZ := SalesHeader.GetAdvLetterUsageDocTypeCZZ();

        CustLedgerEntry.Get(SalesInvoiceHeader."Cust. Ledger Entry No.");
        BindSubscription(GetLastGLEntryNoCZZ);
        SalesAdvLetterManagement.PostAdvancePaymentUsage(AdvLetterUsageDocTypeCZZ, SalesHeader."No.", SalesInvoiceHeader, CustLedgerEntry, GenJnlPostLine, false);
        SalesAdvLetterManagement.CorrectDocumentAfterPaymentUsage(SalesInvoiceHeader."No.", CustLedgerEntry, GenJnlPostLine);
        UnbindSubscription(GetLastGLEntryNoCZZ);

        if not SalesHeader.Get(SalesHeader."Document Type", SalesHeader."No.") then begin
            AdvanceLetterApplicationCZZ.SetRange("Advance Letter Type", AdvanceLetterApplicationCZZ."Advance Letter Type"::Sales);
            AdvanceLetterApplicationCZZ.SetRange("Document Type", AdvLetterUsageDocTypeCZZ);
            AdvanceLetterApplicationCZZ.SetRange("Document No.", SalesHeader."No.");
            AdvanceLetterApplicationCZZ.DeleteAll(true);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforeCreatePrepaymentLines', '', false, false)]
    local procedure DisableCreatePrepaymentLinesOnBeforeCreatePrepaymentLines(var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforeCheckPrepmtAmtToDeduct', '', false, false)]
    local procedure DisableCheckOnBeforeCheckPrepmtAmtToDeduct(var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforeTestStatusRelease', '', false, false)]
    local procedure DisableCheckOnBeforeTestStatusRelease(var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;
}
