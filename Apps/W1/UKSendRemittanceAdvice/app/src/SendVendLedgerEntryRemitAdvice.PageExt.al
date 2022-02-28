// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

pageextension 4023 SendVendLedgerEntryRemitAdvice extends "Vendor Ledger Entries"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        addlast("F&unctions")
        {
            // Add changes to page actions here
            action(SendRemittanceAdvice)
            {
                ApplicationArea = All;
                Caption = 'Send Remittance Advice';
                Image = SendToMultiple;
                ToolTip = 'Send the remittance advice before posting a payment journal or after posting a payment. The advice contains vendor invoice numbers, which helps vendors to perform reconciliations.';

                trigger OnAction()
                var
                    VendorLedgerEntry: Record "Vendor Ledger Entry";
                begin
                    VendorLedgerEntry := Rec;
                    CurrPage.SETSELECTIONFILTER(VendorLedgerEntry);
                    VendorLedgerEntry.SETRANGE("Document Type", VendorLedgerEntry."Document Type"::Payment);
                    SendVendorRecords(VendorLedgerEntry);
                end;
            }
        }
    }
    local procedure SendVendorRecords(var VendorLedgerEntry: Record "Vendor Ledger Entry")
    var
        DocumentSendingProfile: Record "Document Sending Profile";
        DummyReportSelections: Record "Report Selections";
        ReportSelectionInteger: Integer;
    begin
        IF NOT VendorLedgerEntry.FindSet() THEN
            EXIT;

        DummyReportSelections.Usage := DummyReportSelections.Usage::"P.V.Remit.";
        ReportSelectionInteger := DummyReportSelections.Usage.AsInteger();

        DocumentSendingProfile.SendVendorRecords(
            ReportSelectionInteger, VendorLedgerEntry, RemittanceAdviceTxt, "Vendor No.", "Document No.",
            VendorLedgerEntry.FIELDNO("Vendor No."), VendorLedgerEntry.FIELDNO("Document No."));
    end;

    var
        RemittanceAdviceTxt: Label 'Remittance Advice';
}