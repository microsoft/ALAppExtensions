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
        RecRef: RecordRef;
        RecRef2: RecordRef;
        ProfileSelectionMethod: Option "ConfirmDefault","ConfirmPerEach","UseDefault";
        ShowDialog: Boolean;
        VendorNo: Code[20];
        DocumentNo: Code[20];
    begin
        IF NOT VendorLedgerEntry.FindSet() THEN
            EXIT;

        VendorLedgerEntry.SETFILTER("Vendor No.", '<>%1', VendorLedgerEntry."Vendor No.");
        IF NOT VendorLedgerEntry.IsEmpty() THEN BEGIN
            IF NOT DocumentSendingProfile.ProfileSelectionMethodDialog(ProfileSelectionMethod, FALSE) THEN
                EXIT;
            ShowDialog := ProfileSelectionMethod = ProfileSelectionMethod::ConfirmPerEach;
        END ELSE BEGIN
            IF NOT DocumentSendingProfile.LookUpProfileVendor(VendorLedgerEntry."Vendor No.", FALSE, TRUE) THEN
                EXIT;
            ShowDialog := FALSE;
        END;

        VendorLedgerEntry.SETRANGE("Vendor No.");
        RecRef.GETTABLE(VendorLedgerEntry);
        IF RecRef.FindSet() THEN
            REPEAT
                RecRef2 := RecRef.Duplicate();
                RecRef2.SetRecFilter();
                VendorNo := RecRef2.Field(VendorLedgerEntry.FieldNo("Vendor No.")).Value();
                DocumentNo := RecRef2.Field(VendorLedgerEntry.FieldNo("Document No.")).Value();
                IF DocumentSendingProfile.LookUpProfileVendor(VendorNo, TRUE, ShowDialog) THEN
                    DocumentSendingProfile.SendVendor(
                      DummyReportSelections.Usage::"P.V.Remit.", RecRef2, DocumentNo, VendorNo, RemittanceAdviceTxt,
                      VendorLedgerEntry.FIELDNO("Vendor No."), VendorLedgerEntry.FIELDNO("Document No."));
            UNTIL RecRef.Next() = 0;
    end;

    var
        RemittanceAdviceTxt: Label 'Remittance Advice';
}