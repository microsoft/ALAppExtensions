// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TDS.TDSForCustomer;

using Microsoft.Sales.Posting;
using Microsoft.Sales.Receivables;
using Microsoft.Finance.TDS.TDSBase;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Sales.Document;
using System.Utilities;

codeunit 18661 "TDS For Customer Subscribers"
{
    var
        ConfirmMessageMsg: Label 'TDS Section Code %1 is not attached with Customer No. %2, Do you want to assign to Customer & Continue ?', Comment = '%1 = TDS Section Code,%2 = Customer No.';

    procedure TDSSectionCodeLookupGenLineForCustomer(
        var GenJournalLine: Record "Gen. Journal Line";
        VendorNo: Code[20];
        SetTDSSection: Boolean)
    var
        Section: Record "TDS Section";
        CustomerAllowedSections: Record "Customer Allowed Sections";
    begin
        if (GenJournalLine."Account Type" = GenJournalLine."Account Type"::Customer) and GenJournalLine."TDS Certificate Receivable" then begin
            CustomerAllowedSections.Reset();
            CustomerAllowedSections.SetRange("Customer No", GenJournalLine."Account No.");
            if CustomerAllowedSections.FindSet() then
                repeat
                    section.SetRange(Code, CustomerAllowedSections."TDS Section");
                    if Section.FindFirst() then
                        Section.Mark(true);
                until CustomerAllowedSections.Next() = 0;
            Section.SetRange(Code);
            section.MarkedOnly(true);
            if Page.RunModal(Page::"TDS Sections", Section) = Action::LookupOK then
                checkDefaultandAssignTDSSection(GenJournalLine, Section.Code, SetTDSSection);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales Post Invoice Events", 'OnPostLedgerEntryOnBeforeGenJnlPostLine', '', false, false)]
    local procedure OnPostLedgerEntryOnBeforeGenJnlPostLine(
        var GenJnlLine: Record "Gen. Journal Line";
        var SalesHeader: Record "Sales Header";
        var TotalSalesLine: Record "Sales Line";
        var TotalSalesLineLCY: Record "Sales Line")
    begin
        GenJnlLine."TDS Certificate Receivable" := SalesHeader."TDS Certificate Receivable";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Cust. Ledger Entry", 'OnAfterCopyCustLedgerEntryFromGenJnlLine', '', false, false)]
    local procedure InsertTDSSectionCodeinVendLedgerEntry(
        GenJournalLine: Record "Gen. Journal Line";
        var CustLedgerEntry: Record "Cust. Ledger Entry")
    begin
        CustLedgerEntry."TDS Certificate Receivable" := GenJournalLine."TDS Certificate Receivable";
        CustLedgerEntry."TDS Section Code" := GenJournalLine."TDS Section Code";
    end;

    local procedure CheckDefaultAndAssignTDSSection(
        var GenJournalLine: Record "Gen. Journal Line";
        TDSSectionCode: Code[10];
        SetTDSSection: Boolean)
    var
        CustomerAllowedSections: Record "Customer Allowed Sections";
    begin
        if (GenJournalLine."Account Type" = GenJournalLine."Account Type"::Customer) and GenJournalLine."TDS Certificate Receivable" then begin
            CustomerAllowedSections.Reset();
            CustomerAllowedSections.SetRange("Customer No", GenJournalLine."Account No.");
            CustomerAllowedSections.SetRange("TDS Section", TDSSectionCode);
            if CustomerAllowedSections.FindFirst() then begin
                if SetTDSSection then
                    GenJournalLine.Validate("TDS Section Code", CustomerAllowedSections."TDS Section")
            end else
                ConfirmAssignTDSSection(GenJournalLine, TDSSectionCode, SetTDSSection);
        end;
    end;

    local procedure ConfirmAssignTDSSection(
        var GenJournalLine: Record "Gen. Journal Line";
        TDSSectionCode: Code[10];
        SetTDSSection: Boolean)
    var
        CustomerAllowedSections: Record "Customer Allowed Sections";
        ConfirmManagement: Codeunit "Confirm Management";
    begin
        if (GenJournalLine."Account Type" <> GenJournalLine."Account Type"::Customer) or (GenJournalLine."TDS Certificate Receivable" = false) then
            exit;

        if ConfirmManagement.GetResponseOrDefault(StrSubstNo(ConfirmMessageMsg, TDSSectionCode, GenJournalLine."Account No."), true) then begin
            CustomerAllowedSections.Init();
            CustomerAllowedSections."TDS Section" := TDSSectionCode;
            CustomerAllowedSections."Customer No" := GenJournalLine."Account No.";
            CustomerAllowedSections.Insert();
        end;

        if SetTDSSection then
            GenJournalLine.Validate("TDS Section Code", CustomerAllowedSections."TDS Section")
    end;
}
