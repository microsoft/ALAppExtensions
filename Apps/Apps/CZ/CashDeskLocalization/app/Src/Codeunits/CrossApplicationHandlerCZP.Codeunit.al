// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.ReceivablesPayables;
using Microsoft.HumanResources.Payables;
using Microsoft.Purchases.Payables;
using Microsoft.Sales.Receivables;

codeunit 31417 "Cross Application Handler CZP"
{
#if not CLEAN25
    ObsoleteState = Pending;
    ObsoleteReason = 'The Access property will be changed to Internal.';
    ObsoleteTag = '25.0';
#else
    Access = Internal;
#endif

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Cross Application Mgt. CZL", 'OnCollectSuggestedApplication', '', false, false)]
    local procedure AddCashDocumentLineCZPOnCollectSuggestedApplication(
        CollectedForTableID: Integer; CollectedFor: Variant; var CrossApplicationBufferCZL: Record "Cross Application Buffer CZL")
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        EmployeeLedgerEntry: Record "Employee Ledger Entry";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        case CollectedForTableID of
            Database::"Cust. Ledger Entry":
                begin
                    CustLedgerEntry := CollectedFor;
                    CollectCashDocumentLines(
                        "Cash Document Account Type CZP"::Customer, CustLedgerEntry."Customer No.",
                        CustLedgerEntry."Document Type", CustLedgerEntry."Document No.", CrossApplicationBufferCZL);
                end;
            Database::"Vendor Ledger Entry":
                begin
                    VendorLedgerEntry := CollectedFor;
                    CollectCashDocumentLines(
                        "Cash Document Account Type CZP"::Vendor, VendorLedgerEntry."Vendor No.",
                        VendorLedgerEntry."Document Type", VendorLedgerEntry."Document No.", CrossApplicationBufferCZL);
                end;
            Database::"Employee Ledger Entry":
                begin
                    EmployeeLedgerEntry := CollectedFor;
                    CollectCashDocumentLines(
                        "Cash Document Account Type CZP"::Employee, EmployeeLedgerEntry."Employee No.",
                        EmployeeLedgerEntry."Document Type", EmployeeLedgerEntry."Document No.", CrossApplicationBufferCZL);
                end;
        end;
    end;

    local procedure CollectCashDocumentLines(
        AccountType: Enum "Cash Document Account Type CZP";
        AccountNo: Code[20];
        DocumentType: Enum "Gen. Journal Document Type";
        DocumentNo: Code[20];
        var CrossApplicationBufferCZL: Record "Cross Application Buffer CZL")
    var
        CashDocumentLineCZP: Record "Cash Document Line CZP";
    begin
        CashDocumentLineCZP.SetRange("Account Type", AccountType);
        CashDocumentLineCZP.SetRange("Account No.", AccountNo);
        CashDocumentLineCZP.SetRange("Applies-to Doc. Type", DocumentType);
        CashDocumentLineCZP.SetRange("Applies-to Doc. No.", DocumentNo);
        if CashDocumentLineCZP.FindSet() then
            repeat
                AddLineToBuffer(CashDocumentLineCZP, CrossApplicationBufferCZL);
            until CashDocumentLineCZP.Next() = 0;
    end;

    local procedure AddLineToBuffer(
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

    [EventSubscriber(ObjectType::Page, Page::"Cross Application CZL", 'OnShowCrossApplicationDocument', '', false, false)]
    local procedure ShowCashDocumentLineCZPOnShowCrossApplicationDocument(TableID: Integer; DocumentNo: Code[20]; LineNo: Integer)
    var
        CashDocumentLineCZP: Record "Cash Document Line CZP";
    begin
        if TableID <> Database::"Cash Document Line CZP" then
            exit;

        CashDocumentLineCZP.FilterGroup(2);
        CashDocumentLineCZP.SetRange("Cash Document No.", DocumentNo);
        CashDocumentLineCZP.SetRange("Line No.", LineNo);
        CashDocumentLineCZP.FilterGroup(0);
        Page.Run(Page::"Cash Document Lines CZP", CashDocumentLineCZP);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Cross Application Buffer CZL", 'OnExcludeDocument', '', false, false)]
    local procedure SetFilterOnExcludeDocument(TableID: Integer; DocumentVariant: Variant; var CrossApplicationBufferCZL: Record "Cross Application Buffer CZL")
    var
        CashDocumentLineCZL: Record "Cash Document Line CZP";
    begin
        if TableID <> Database::"Cash Document Line CZP" then
            exit;

        CashDocumentLineCZL := DocumentVariant;
        CrossApplicationBufferCZL.RemoveDocument(
            TableID, CashDocumentLineCZL."Cash Document No.", CashDocumentLineCZL."Line No.");
    end;
}
