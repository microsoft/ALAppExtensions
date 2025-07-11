// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Sales;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.Posting;
using Microsoft.Sales.Receivables;

codeunit 18141 "GST Cust. Ledger Entry"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales Post Invoice Events", 'OnPostLedgerEntryOnBeforeGenJnlPostLine', '', false, false)]
    local procedure CopyInfoToCustomerEntryOnPostLedgerEntryOnBeforeGenJnlPostLine(var GenJnlLine: Record "Gen. Journal Line"; var SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        SalesLine2: Record "Sales Line";
    begin
        GenJnlLine."Location Code" := SalesHeader."Location Code";
        GenJnlLine."GST Customer Type" := SalesHeader."GST Customer Type";
        GenJnlLine."Location State Code" := SalesHeader."Location State Code";
        GenJnlLine."Location GST Reg. No." := SalesHeader."Location GST Reg. No.";
        GenJnlLine."GST Bill-to/BuyFrom State Code" := SalesHeader."GST Bill-to State Code";
        GenJnlLine."GST Ship-to State Code" := SalesHeader."GST Ship-to State Code";
        GenJnlLine."Ship-to GST Reg. No." := SalesHeader."Ship-to GST Reg. No.";
        GenJnlLine."Customer GST Reg. No." := SalesHeader."Customer GST Reg. No.";

        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetFilter("GST Place Of Supply", '<>%1', SalesLine."GST Place Of Supply"::" ");
        if SalesLine.FindFirst() then
            GenJnlLine."GST Place of Supply" := SalesLine."GST Place Of Supply";

        GenJnlLine."Ship-to Code" := SalesHeader."Ship-to Code";
        SalesLine2.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine2.SetRange("Document No.", SalesHeader."No.");
        SalesLine2.SetFilter(Type, '<>%1', SalesLine2.Type::" ");
        SalesLine2.SetFilter(Quantity, '<>%1', 0);
        if SalesLine2.FindFirst() then
            GenJnlLine."GST Jurisdiction Type" := SalesLine2."GST Jurisdiction Type";

        GenJnlLine."GST Without Payment of Duty" := SalesHeader."GST Without Payment of Duty";
        GenJnlLine."Rate Change Applicable" := SalesHeader."Rate Change Applicable";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterInitCustLedgEntry', '', false, false)]
    local procedure CopyInfoToCustomerLedgerEntry(GenJournalLine: Record "Gen. Journal Line"; var CustLedgerEntry: Record "Cust. Ledger Entry")
    var
        Customer: Record customer;
    begin
        CustLedgerEntry."Location Code" := GenJournalLine."Location Code";
        CustLedgerEntry."GST Jurisdiction Type" := GenJournalLine."GST Jurisdiction Type";
        CustLedgerEntry."GST Without Payment of Duty" := GenJournalLine."GST Without Payment of Duty";
        if GenJournalLine."Document Type" in [GenJournalLine."Document Type"::Payment, GenJournalLine."Document Type"::Refund] then
            if (GenJournalLine."Document Type" = GenJournalLine."Document Type"::Payment) and (GenJournalLine."GST on Advance Payment") then begin
                CustLedgerEntry."HSN/SAC Code" := GenJournalLine."HSN/SAC Code";
                CustLedgerEntry."GST Group Code" := GenJournalLine."GST Group Code";
                CustLedgerEntry."GST on Advance Payment" := GenJournalLine."GST on Advance Payment";
            end else
                if (GenJournalLine."Document Type" = GenJournalLine."Document Type"::Refund) and (GenJournalLine."Applies-to Doc. No." <> '') then begin
                    CustLedgerEntry.SetCurrentKey("Customer No.", "Document Type", "Document No.", "GST on Advance Payment");
                    CustLedgerEntry.SetRange("Customer No.", GenJournalLine."Account No.");
                    CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Payment);
                    CustLedgerEntry.SetRange("Document No.", GenJournalLine."Applies-to Doc. No.");
                    CustLedgerEntry.SetRange("GST on Advance Payment", true);
                    CustLedgerEntry.SetRange("HSN/SAC Code", GenJournalLine."HSN/SAC Code");
                    if not CustLedgerEntry.IsEmpty() then begin
                        CustLedgerEntry."HSN/SAC Code" := GenJournalLine."HSN/SAC Code";
                        CustLedgerEntry."GST Group Code" := GenJournalLine."GST Group Code";
                    end;
                end;

        CustLedgerEntry."Location State Code" := GenJournalLine."Location State Code";
        Customer.Get(CustLedgerEntry."Customer No.");
        case GenJournalLine."GST Place of Supply" of
            GenJournalLine."GST Place of Supply"::"Bill-to Address":
                begin
                    CustLedgerEntry."Seller State Code" := GenJournalLine."GST Bill-to/BuyFrom State Code";
                    CustLedgerEntry."Seller GST Reg. No." := GenJournalLine."Customer GST Reg. No.";
                end;
            GenJournalLine."GST Place of Supply"::"Ship-to Address":
                begin
                    CustLedgerEntry."Seller State Code" := GenJournalLine."GST Ship-to State Code";
                    CustLedgerEntry."Seller GST Reg. No." := GenJournalLine."Ship-to GST Reg. No.";
                end;
            GenJournalLine."GST Place of Supply"::"Location Address":
                begin
                    CustLedgerEntry."Seller State Code" := GenJournalLine."Location State Code";
                    CustLedgerEntry."Seller GST Reg. No." := GenJournalLine."Customer GST Reg. No.";
                end;
        end;
        CustLedgerEntry."GST Customer Type" := GenJournalLine."GST Customer Type";
        CustLedgerEntry."Location GST Reg. No." := GenJournalLine."Location GST Reg. No.";
    end;
}
