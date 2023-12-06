// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Purchases.Payables;
using Microsoft.Sales.Receivables;

codeunit 31453 "Gen. Journal Line Handler CZB"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnSetJournalLineFieldsFromApplicationOnAfterFindFirstCustLedgEntryWithAppliesToID', '', false, false)]
    local procedure SetDimensionOnSetJournalLineFieldsFromApplicationOnAfterFindFirstCustLedgEntryWithAppliesToID(var GenJournalLine: Record "Gen. Journal Line"; CustLedgEntry: Record "Cust. Ledger Entry")
    begin
        if GenJournalLine.IsDimensionFromApplyEntryEnabledCZB() then
            GenJournalLine.Validate("Dimension Set ID", CustLedgEntry."Dimension Set ID");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnSetJournalLineFieldsFromApplicationOnAfterFindFirstCustLedgEntryWithAppliesToDocNo', '', false, false)]
    local procedure SetDimensionOnSetJournalLineFieldsFromApplicationOnAfterFindFirstCustLedgEntryWithAppliesToDocNo(var GenJournalLine: Record "Gen. Journal Line"; CustLedgEntry: Record "Cust. Ledger Entry")
    begin
        if GenJournalLine.IsDimensionFromApplyEntryEnabledCZB() then
            GenJournalLine.Validate("Dimension Set ID", CustLedgEntry."Dimension Set ID");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnSetJournalLineFieldsFromApplicationOnAfterFindFirstVendLedgEntryWithAppliesToID', '', false, false)]
    local procedure SetDimensionOnSetJournalLineFieldsFromApplicationOnAfterFindFirstVendLedgEntryWithAppliesToID(var GenJournalLine: Record "Gen. Journal Line"; VendLedgEntry: Record "Vendor Ledger Entry")
    begin
        if GenJournalLine.IsDimensionFromApplyEntryEnabledCZB() then
            GenJournalLine.Validate("Dimension Set ID", VendLedgEntry."Dimension Set ID");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnSetJournalLineFieldsFromApplicationOnAfterFindFirstVendLedgEntryWithAppliesToDocNo', '', false, false)]
    local procedure SetDimensionOnSetJournalLineFieldsFromApplicationOnAfterFindFirstVendLedgEntryWithAppliesToDocNo(var GenJournalLine: Record "Gen. Journal Line"; VendLedgEntry: Record "Vendor Ledger Entry")
    begin
        if GenJournalLine.IsDimensionFromApplyEntryEnabledCZB() then
            GenJournalLine.Validate("Dimension Set ID", VendLedgEntry."Dimension Set ID");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterInsertEvent', '', false, false)]
    local procedure UpdateJournalStatusOnAfterInsertEvent(var Rec: Record "Gen. Journal Line")
    var
        GenJournalLine: Record "Gen. Journal Line";
        IssBankStatementHeader: Record "Iss. Bank Statement Header CZB";
    begin
        if Rec.IsTemporary() then
            exit;
        if Rec."Bank Statement No. CZB" = '' then
            exit;

        GenJournalLine.SetRange("Journal Template Name", Rec."Journal Template Name");
        GenJournalLine.SetRange("Journal Batch Name", Rec."Journal Batch Name");
        GenJournalLine.SetRange("Bank Statement No. CZB", Rec."Bank Statement No. CZB");
        if GenJournalLine.Count = 1 then begin
            IssBankStatementHeader.Get(Rec."Bank Statement No. CZB");
            IssBankStatementHeader.UpdatePaymentJournalStatus(Enum::"Journal Status CZB"::Opened);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterDeleteEvent', '', false, false)]
    local procedure UpdateJournalStatusOnAfterDeleteEvent(var Rec: Record "Gen. Journal Line")
    var
        GenJournalLine: Record "Gen. Journal Line";
        IssBankStatementHeader: Record "Iss. Bank Statement Header CZB";
    begin
        if Rec.IsTemporary() then
            exit;
        if Rec."Bank Statement No. CZB" = '' then
            exit;

        GenJournalLine.SetRange("Journal Template Name", Rec."Journal Template Name");
        GenJournalLine.SetRange("Journal Batch Name", Rec."Journal Batch Name");
        GenJournalLine.SetRange("Bank Statement No. CZB", Rec."Bank Statement No. CZB");
        if GenJournalLine.IsEmpty() then begin
            IssBankStatementHeader.Get(Rec."Bank Statement No. CZB");
            IssBankStatementHeader.UpdatePaymentJournalStatus(Enum::"Journal Status CZB"::" ");
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterGLFinishPosting', '', false, false)]
    local procedure CleanBankStatementNoOnAfterGLFinishPosting(var GenJnlLine: Record "Gen. Journal Line")
    var
        GenJournalLine: Record "Gen. Journal Line";
        IssBankStatementHeader: Record "Iss. Bank Statement Header CZB";
    begin
        if GenJnlLine.IsTemporary() then
            exit;
        if GenJnlLine."Bank Statement No. CZB" = '' then
            exit;

        GenJournalLine.SetRange("Journal Template Name", GenJnlLine."Journal Template Name");
        GenJournalLine.SetRange("Journal Batch Name", GenJnlLine."Journal Batch Name");
        GenJournalLine.SetFilter("Line No.", '<>%1', GenJnlLine."Line No.");
        GenJournalLine.SetRange("Bank Statement No. CZB", GenJnlLine."Bank Statement No. CZB");
        if GenJournalLine.IsEmpty() then
            if IssBankStatementHeader.Get(GenJnlLine."Bank Statement No. CZB") then
                IssBankStatementHeader.UpdatePaymentJournalStatus(Enum::"Journal Status CZB"::Posted);

        GenJnlLine."Bank Statement No. CZB" := '';
        GenJnlLine.Modify();
    end;
}
