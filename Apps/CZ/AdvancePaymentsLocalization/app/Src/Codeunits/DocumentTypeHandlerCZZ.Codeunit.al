// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.ReceivablesPayables;
using Microsoft.Sales.Receivables;
using Microsoft.Purchases.Payables;

codeunit 31141 "Document Type Handler CZZ"
{
    EventSubscriberInstance = Manual;

    [EventSubscriber(ObjectType::Table, Database::"G/L Entry", 'OnAfterCopyGLEntryFromGenJnlLine', '', false, false)]
    local procedure ClearDocumentTypeOnAfterCopyGLEntryFromGenJnlLine(var GLEntry: Record "G/L Entry")
    begin
        GLEntry."Document Type" := GLEntry."Document Type"::" ";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Cust. Ledger Entry", 'OnAfterCopyCustLedgerEntryFromGenJnlLine', '', false, false)]
    local procedure ClearDocumentTypeOnAfterCopyCustLedgerEntryFromGenJnlLine(var CustLedgerEntry: Record "Cust. Ledger Entry")
    begin
        CustLedgerEntry."Document Type" := CustLedgerEntry."Document Type"::" ";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Vendor Ledger Entry", 'OnAfterCopyVendLedgerEntryFromGenJnlLine', '', false, false)]
    local procedure ClearDocumentTypeOnAfterCopyVendLedgerEntryFromGenJnlLine(var VendorLedgerEntry: Record "Vendor Ledger Entry")
    begin
        VendorLedgerEntry."Document Type" := VendorLedgerEntry."Document Type"::" ";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Detailed CV Ledg. Entry Buffer", 'OnAfterCopyFromGenJnlLine', '', false, false)]
    local procedure ClearDocumentTypeOnAfterCopyFromGenJnlLine(var DtldCVLedgEntryBuffer: Record "Detailed CV Ledg. Entry Buffer")
    begin
        DtldCVLedgEntryBuffer."Document Type" := DtldCVLedgEntryBuffer."Document Type"::" ";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Detailed CV Ledg. Entry Buffer", 'OnAfterInitFromGenJnlLine', '', false, false)]
    local procedure ClearDocumentTypeOnAfterInitFromGenJnlLine(var DetailedCVLedgEntryBuffer: Record "Detailed CV Ledg. Entry Buffer")
    begin
        DetailedCVLedgEntryBuffer."Document Type" := DetailedCVLedgEntryBuffer."Document Type"::" ";
    end;

    [EventSubscriber(ObjectType::Table, Database::"CV Ledger Entry Buffer", 'OnAfterCopyFromVendLedgerEntry', '', false, false)]
    local procedure ClearDocumentTypeOnAfterCopyFromVendLedgerEntry(var CVLedgerEntryBuffer: Record "CV Ledger Entry Buffer")
    begin
        CVLedgerEntryBuffer."Document Type" := CVLedgerEntryBuffer."Document Type"::" ";
    end;
}
