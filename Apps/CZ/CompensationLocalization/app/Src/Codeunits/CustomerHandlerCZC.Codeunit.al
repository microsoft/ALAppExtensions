// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Compensations;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Sales.Receivables;

codeunit 31272 "Customer Handler CZC"
{
    Permissions = tabledata "Cust. Ledger Entry" = m;

    [EventSubscriber(ObjectType::Table, Database::"Cust. Ledger Entry", 'OnAfterCopyCustLedgerEntryFromGenJnlLine', '', false, false)]
    local procedure UpdateEntryOnAfterCopyCustLedgerEntryFromGenJnlLine(var CustLedgerEntry: Record "Cust. Ledger Entry"; GenJournalLine: Record "Gen. Journal Line")
    begin
        CustLedgerEntry."Compensation CZC" := GenJournalLine."Compensation CZC";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Cust. Ledger Entry", 'OnBeforeValidateEvent', 'On Hold', false, false)]
    local procedure CheckCompensationOnBeforeValidateOnHold(var Rec: Record "Cust. Ledger Entry")
    var
        GenJournalLine: Record "Gen. Journal Line";
        OnHoldErr: Label 'The operation is prohibited, until journal line of Journal Template Name = ''%1'', Journal Batch Name = ''%2'', Line No. = ''%3'' is deleted or posted.', Comment = '%1 = Template Name, %2 = Batch Name, %3 = Line No.';
    begin
        GenJournalLine.SetRange("Account Type", GenJournalLine."Account Type"::Customer);
        GenJournalLine.SetRange("Account No.", Rec."Customer No.");
        GenJournalLine.SetRange("Applies-to Doc. Type", Rec."Document Type");
        GenJournalLine.SetRange("Applies-to Doc. No.", Rec."Document No.");
        GenJournalLine.SetRange("Compensation CZC", true);
        if GenJournalLine.FindFirst() then
            Error(OnHoldErr, GenJournalLine."Journal Template Name", GenJournalLine."Journal Batch Name", GenJournalLine."Line No.");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterOldCustLedgEntryModify', '', false, false)]
    local procedure ClearOnHoldOnAfterOldCustLedgEntryModify(var CustLedgEntry: Record "Cust. Ledger Entry"; GenJournalLine: Record "Gen. Journal Line")
    begin
        if GenJournalLine."Compensation CZC" then begin
            CustLedgEntry."On Hold" := '';
            CustLedgEntry.Modify();
        end;
    end;
}
