// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

pageextension 4022 SendPmtJnlRemitAdvice extends "Payment Journal"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        addlast("&Payments")
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
                    GenJournalLine: Record "Gen. Journal Line";
                begin
                    GenJournalLine := Rec;
                    CurrPage.SETSELECTIONFILTER(GenJournalLine);
                    SendVendorRecords(GenJournalLine);
                end;
            }
        }
    }
    local procedure SendVendorRecords(var GenJournalLine: Record "Gen. Journal Line")
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
        IF NOT GenJournalLine.FindSet() THEN
            EXIT;

        GenJournalLine.SETFILTER("Account No.", '<>%1', GenJournalLine."Account No.");
        IF NOT GenJournalLine.IsEmpty() THEN BEGIN
            IF NOT DocumentSendingProfile.ProfileSelectionMethodDialog(ProfileSelectionMethod, FALSE) THEN
                EXIT;
            ShowDialog := ProfileSelectionMethod = ProfileSelectionMethod::ConfirmPerEach;
        END ELSE BEGIN
            IF NOT DocumentSendingProfile.LookUpProfileVendor(GenJournalLine."Account No.", FALSE, TRUE) THEN
                EXIT;
            ShowDialog := FALSE;
        END;

        GenJournalLine.SETRANGE("Account No.");
        RecRef.GETTABLE(GenJournalLine);
        IF RecRef.FindSet() THEN
            REPEAT
                RecRef2 := RecRef.Duplicate();
                RecRef2.SetRecFilter();
                VendorNo := RecRef2.Field(GenJournalLine.FieldNo("Account No.")).Value();
                DocumentNo := RecRef2.Field(GenJournalLine.FieldNo("Document No.")).Value();
                IF DocumentSendingProfile.LookUpProfileVendor(VendorNo, TRUE, ShowDialog) THEN
                    DocumentSendingProfile.SendVendor(
                      DummyReportSelections.Usage::"V.Remittance", RecRef2, DocumentNo, VendorNo, RemittanceAdviceTxt,
                      GenJournalLine.FIELDNO("Account No."), GenJournalLine.FIELDNO("Document No."));
            UNTIL RecRef.Next() = 0;
    end;

    var
        RemittanceAdviceTxt: Label 'Remittance Advice';
}