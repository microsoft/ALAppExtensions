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
        DummyReportSelectionsInteger: Integer;
    begin
        IF NOT GenJournalLine.FindSet() THEN
            EXIT;

        DummyReportSelections.Usage := DummyReportSelections.Usage::"V.Remittance";
        DummyReportSelectionsInteger := DummyReportSelections.Usage.AsInteger();

        DocumentSendingProfile.SendVendorRecords(
            DummyReportSelectionsInteger, GenJournalLine, RemittanceAdviceTxt, "Account No.", "Document No.",
            GenJournalLine.FIELDNO("Account No."), GenJournalLine.FIELDNO("Document No."));
    end;

    var
        RemittanceAdviceTxt: Label 'Remittance Advice';
}