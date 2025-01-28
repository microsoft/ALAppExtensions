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
        ReportDistributionMgt: Codeunit "Report Distribution Management";
        DocumentTypeTxt: Text[50];
    begin
        DocumentTypeTxt := ReportDistributionMgt.GetFullDocumentTypeText(Rec);

        DocumentSendingProfile.TrySendToEMailWithEDocument(
          DummyReportSelections.Usage::"S.Invoice".AsInteger(), Rec, FieldNo("No."), DocumentTypeTxt,
          FieldNo("Bill-to Customer No."), ShowDialog);
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
        Rec.Validate("Send E-Document via Email", true);
        Rec.Modify(true);
        Rec.CreateEDocument();
        Rec.EmailEDocument(true);
    end;
}
