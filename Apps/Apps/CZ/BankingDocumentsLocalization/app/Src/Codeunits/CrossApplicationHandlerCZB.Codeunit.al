// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using Microsoft.Finance.ReceivablesPayables;
using Microsoft.HumanResources.Payables;
using Microsoft.Purchases.Payables;
using Microsoft.Sales.Receivables;

codeunit 31416 "Cross Application Handler CZB"
{
#if not CLEAN25
    ObsoleteState = Pending;
    ObsoleteReason = 'The Access property will be changed to Internal.';
    ObsoleteTag = '25.0';
#else
    Access = Internal;
#endif

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Cross Application Mgt. CZL", 'OnCollectSuggestedApplication', '', false, false)]
    local procedure AddIssPaymentOrderLineCZBOnCollectSuggestedApplication(
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
                    CollectIssPaymentOrderLines(
                        "Banking Line Type CZB"::Customer, CustLedgerEntry."Customer No.",
                        CustLedgerEntry."Entry No.", CrossApplicationBufferCZL);
                end;
            Database::"Vendor Ledger Entry":
                begin
                    VendorLedgerEntry := CollectedFor;
                    CollectIssPaymentOrderLines(
                        "Banking Line Type CZB"::Vendor, VendorLedgerEntry."Vendor No.",
                        VendorLedgerEntry."Entry No.", CrossApplicationBufferCZL);
                end;
            Database::"Employee Ledger Entry":
                begin
                    EmployeeLedgerEntry := CollectedFor;
                    CollectIssPaymentOrderLines(
                        "Banking Line Type CZB"::Employee, EmployeeLedgerEntry."Employee No.",
                        EmployeeLedgerEntry."Entry No.", CrossApplicationBufferCZL);
                end;
        end;
    end;

    local procedure CollectIssPaymentOrderLines(AccountType: Enum "Banking Line Type CZB"; AccountNo: Code[20]; EntryNo: Integer; var CrossApplicationBufferCZL: Record "Cross Application Buffer CZL")
    var
        IssPaymentOrderLineCZB: Record "Iss. Payment Order Line CZB";
    begin
        IssPaymentOrderLineCZB.SetRange(Type, AccountType);
        IssPaymentOrderLineCZB.SetRange("No.", AccountNo);
        IssPaymentOrderLineCZB.SetRange("Applies-to C/V/E Entry No.", EntryNo);
        IssPaymentOrderLineCZB.SetFilter(Status, '<>%1', IssPaymentOrderLineCZB.Status::Canceled);
        if IssPaymentOrderLineCZB.FindSet() then
            repeat
                AddLineToBuffer(IssPaymentOrderLineCZB, CrossApplicationBufferCZL);
            until IssPaymentOrderLineCZB.Next() = 0;
    end;

    local procedure AddLineToBuffer(
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

    [EventSubscriber(ObjectType::Page, Page::"Cross Application CZL", 'OnShowCrossApplicationDocument', '', false, false)]
    local procedure ShowIssPaymentOrderLineCZBOnShowCrossApplicationDocument(TableID: Integer; DocumentNo: Code[20]; LineNo: Integer)
    var
        IssPaymentOrderLineCZB: Record "Iss. Payment Order Line CZB";
    begin
        if TableID <> Database::"Iss. Payment Order Line CZB" then
            exit;

        IssPaymentOrderLineCZB.FilterGroup(2);
        IssPaymentOrderLineCZB.SetRange("Payment Order No.", DocumentNo);
        IssPaymentOrderLineCZB.SetRange("Line No.", LineNo);
        IssPaymentOrderLineCZB.FilterGroup(0);
        Page.Run(Page::"Iss. Payment Order Lines CZB", IssPaymentOrderLineCZB);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Cross Application Buffer CZL", 'OnExcludeDocument', '', false, false)]
    local procedure SetFilterOnExcludeDocument(TableID: Integer; DocumentVariant: Variant; var CrossApplicationBufferCZL: Record "Cross Application Buffer CZL")
    var
        IssPaymentOrderLine: Record "Iss. Payment Order Line CZB";
    begin
        if TableID <> Database::"Iss. Payment Order Line CZB" then
            exit;

        IssPaymentOrderLine := DocumentVariant;
        CrossApplicationBufferCZL.RemoveDocument(
            TableID, IssPaymentOrderLine."Payment Order No.", IssPaymentOrderLine."Line No.");
    end;
}
