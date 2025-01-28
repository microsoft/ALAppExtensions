// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument;

using Microsoft.Sales.History;
using Microsoft.Foundation.Reporting;

tableextension 6103 "E-Doc. Sales Cr. Memo Header" extends "Sales Cr.Memo Header"
{
    fields
    {
        field(6100; "Send E-Document via Email"; Boolean)
        {
            Caption = 'Send E-Document via Email';
            DataClassification = SystemMetadata;
        }
    }

    internal procedure CreateEDocument()
    var
        EDocExport: Codeunit "E-Doc. Export";
        SalesCrMemoRecordRef: RecordRef;
    begin
        SalesCrMemoRecordRef.GetTable(Rec);
        EDocExport.CreateEDocumentForPostedDocument(SalesCrMemoRecordRef);
    end;

    internal procedure CreateAndEmailEDocument()
    begin
        Rec.Validate("Send E-Document via Email", true);
        Rec.Modify(true);
        Rec.CreateEDocument();
        Rec.EmailEDocument(true);
    end;

    internal procedure EmailEDocument(ShowDialog: Boolean)
    var
        DocumentSendingProfile: Record "Document Sending Profile";
        DummyReportSelections: Record "Report Selections";
        ReportDistributionMgt: Codeunit "Report Distribution Management";
        DocumentTypeTxt: Text[50];
    begin
        DocumentTypeTxt := ReportDistributionMgt.GetFullDocumentTypeText(Rec);

        DocumentSendingProfile.TrySendToEMailWithEDocument(
            DummyReportSelections.Usage::"S.Cr.Memo".AsInteger(), Rec, this.FieldNo("No."), DocumentTypeTxt,
            this.FieldNo("Bill-to Customer No."), ShowDialog);
    end;
}
