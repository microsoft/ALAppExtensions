// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using Microsoft.Sales.History;
using Microsoft.Foundation.Reporting;

tableextension 6102 "E-Doc. Sales Invoice Header" extends "Sales Invoice Header"
{
    fields
    {
        field(6100; "Send E-Document via Email"; Boolean)
        {
            Caption = 'Send E-Document via Email';
            DataClassification = SystemMetadata;
        }
    }

    internal procedure EmailEDocument(ShowDialog: Boolean)
    var
        DocumentSendingProfile: Record "Document Sending Profile";
        DummyReportSelections: Record "Report Selections";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        ReportDistributionMgt: Codeunit "Report Distribution Management";
        DocumentTypeTxt: Text[50];
    begin
        DocumentTypeTxt := ReportDistributionMgt.GetFullDocumentTypeText(Rec);

        SalesInvoiceHeader := Rec;
        SalesInvoiceHeader.SetRange("No.", Rec."No.");

        DocumentSendingProfile.TrySendToEMailWithEDocument(
          DummyReportSelections.Usage::"S.Invoice".AsInteger(), SalesInvoiceHeader, this.FieldNo("No."), DocumentTypeTxt,
          this.FieldNo("Bill-to Customer No."), ShowDialog);
    end;

    internal procedure CreateEDocument()
    var
        EDocExport: Codeunit "E-Doc. Export";
        SalesInvoiceRecordRef: RecordRef;
    begin
        SalesInvoiceRecordRef.GetTable(Rec);
        EDocExport.CreateEDocumentForPostedDocument(SalesInvoiceRecordRef);
    end;

    internal procedure CreateAndEmailEDocument()
    begin
        Rec."Send E-Document via Email" := true;
        Rec.CreateEDocument();
        Rec.EmailEDocument(true);
    end;
}
