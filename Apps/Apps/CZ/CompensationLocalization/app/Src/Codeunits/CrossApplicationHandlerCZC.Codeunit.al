// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Compensations;

using Microsoft.Finance.ReceivablesPayables;
using Microsoft.Purchases.Payables;
using Microsoft.Sales.Receivables;

codeunit 31415 "Cross Application Handler CZC"
{
#if not CLEAN25
    ObsoleteState = Pending;
    ObsoleteReason = 'The Access property will be changed to Internal.';
    ObsoleteTag = '25.0';
#else
    Access = Internal;
#endif

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Cross Application Mgt. CZL", 'OnCollectSuggestedApplication', '', false, false)]
    local procedure AddCompensationLineCZCOnCollectSuggestedApplication(
        CollectedForTableID: Integer; CollectedFor: Variant; var CrossApplicationBufferCZL: Record "Cross Application Buffer CZL")
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        case CollectedForTableID of
            Database::"Cust. Ledger Entry":
                begin
                    CustLedgerEntry := CollectedFor;
                    CollectCompensationLines(
                        "Compensation Source Type CZC"::Customer, CustLedgerEntry."Customer No.",
                        CustLedgerEntry."Entry No.", CrossApplicationBufferCZL);
                end;
            Database::"Vendor Ledger Entry":
                begin
                    VendorLedgerEntry := CollectedFor;
                    CollectCompensationLines(
                        "Compensation Source Type CZC"::Vendor, VendorLedgerEntry."Vendor No.",
                        VendorLedgerEntry."Entry No.", CrossApplicationBufferCZL);
                end;
        end;
    end;

    local procedure CollectCompensationLines(SourceType: Enum "Compensation Source Type CZC"; SourceNo: Code[20]; SourceEntryNo: Integer; var CrossApplicationBufferCZL: Record "Cross Application Buffer CZL")
    var
        CompensationLineCZC: Record "Compensation Line CZC";
    begin
        CompensationLineCZC.SetRange("Source Type", SourceType);
        CompensationLineCZC.SetRange("Source No.", SourceNo);
        CompensationLineCZC.SetRange("Source Entry No.", SourceEntryNo);
        if CompensationLineCZC.FindSet() then
            repeat
                AddLineToBuffer(CompensationLineCZC, CrossApplicationBufferCZL);
            until CompensationLineCZC.Next() = 0;
    end;

    local procedure AddLineToBuffer(
        CompensationLineCZC: Record "Compensation Line CZC";
        var CrossApplicationBufferCZL: Record "Cross Application Buffer CZL")
    var
        CompensationHeaderCZC: Record "Compensation Header CZC";
    begin
        CompensationHeaderCZC.Get(CompensationLineCZC."Compensation No.");
        if CompensationHeaderCZC.Status <> CompensationHeaderCZC.Status::Released then
            exit;

        CrossApplicationBufferCZL.Init();
        CrossApplicationBufferCZL."Entry No." := CrossApplicationBufferCZL.Count() + 1;
        CrossApplicationBufferCZL."Table ID" := Database::"Compensation Line CZC";
        CrossApplicationBufferCZL."Applied Document No." := CompensationLineCZC."Compensation No.";
        CrossApplicationBufferCZL."Applied Document Line No." := CompensationLineCZC."Line No.";
        CrossApplicationBufferCZL."Applied Document Date" := CompensationHeaderCZC."Document Date";
        CrossApplicationBufferCZL."Amount (LCY)" := CompensationLineCZC."Amount (LCY)";
        CrossApplicationBufferCZL.Insert();
    end;

    [EventSubscriber(ObjectType::Page, Page::"Cross Application CZL", 'OnShowCrossApplicationDocument', '', false, false)]
    local procedure ShowCompensationLineCZCOnShowCrossApplicationDocument(TableID: Integer; DocumentNo: Code[20]; LineNo: Integer)
    var
        CompensationLineCZC: Record "Compensation Line CZC";
    begin
        if TableId <> Database::"Compensation Line CZC" then
            exit;

        CompensationLineCZC.FilterGroup(2);
        CompensationLineCZC.SetRange("Compensation No.", DocumentNo);
        CompensationLineCZC.SetRange("Line No.", LineNo);
        CompensationLineCZC.FilterGroup(0);
        Page.Run(Page::"Compensation Lines CZC", CompensationLineCZC);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Cross Application Buffer CZL", 'OnExcludeDocument', '', false, false)]
    local procedure SetFilterOnExcludeDocument(TableID: Integer; DocumentVariant: Variant; var CrossApplicationBufferCZL: Record "Cross Application Buffer CZL")
    var
        CompensationLineCZC: Record "Compensation Line CZC";
    begin
        if TableID <> Database::"Compensation Line CZC" then
            exit;

        CompensationLineCZC := DocumentVariant;
        CrossApplicationBufferCZL.RemoveDocument(
            TableID, CompensationLineCZC."Compensation No.", CompensationLineCZC."Line No.");
    end;
}
