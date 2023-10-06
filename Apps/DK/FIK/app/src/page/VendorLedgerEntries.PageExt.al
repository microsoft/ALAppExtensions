// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Bank.Payment;

using Microsoft.Purchases.Payables;

pageextension 13612 VendorLedgerEntries extends "Vendor Ledger Entries"
{
    layout
    {
        addafter("Creditor No.")
        {
            field("Giro Acc. No."; GiroAccNo)
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the vendor''s giro account.';
            }
        }
    }
    actions
    {
        addafter(IncomingDocAttachFile)
        {
            action(ExportPaymentsToFile)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Export Payments to File';
                Image = ExportFile;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Export a file with the payment information from the ledger entries.';
                trigger OnAction();
                var
                    VendorLedgerEntry: Record "Vendor Ledger Entry";
                    PmtExportMgtVendLedgEntry: Codeunit "Pmt Export Mgt Vend Ledg Entry";
                BEGIN
                    CurrPage.SETSELECTIONFILTER(VendorLedgerEntry);
                    VendorLedgerEntry.FINDFIRST();
                    PmtExportMgtVendLedgEntry.ExportVendorPaymentFileYN(VendorLedgerEntry);
                END;
            }
        }
    }
    trigger OnOpenPage();
    begin
        IF FINDFIRST() THEN;
    end;
}

