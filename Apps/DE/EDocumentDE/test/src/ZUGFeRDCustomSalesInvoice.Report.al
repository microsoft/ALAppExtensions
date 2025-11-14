namespace Microsoft.eServices.EDocument.Formats;

using Microsoft.Sales.History;
using System.IO;
using System.Utilities;

report 13918 "ZUGFeRD Custom Sales Invoice"
{
    ApplicationArea = All;
    Caption = 'Custom Sales Invoice';
    DefaultRenderingLayout = CustomSalesInvoice;
    Extensible = false;
    WordMergeDataItem = Header;
    UsageCategory = Administration;
    dataset
    {
        dataitem(Header; "Sales Invoice Header")
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.", "Sell-to Customer No.", "No. Printed";
            column(DocumentNo; "No.")
            {
            }

        }
    }

    requestpage
    {
    }
    rendering
    {
        layout(CustomSalesInvoice)
        {
            Caption = 'Custom Sales Invoice (Word)';
            LayoutFile = './src/CustomSalesInvoice.docx';
            Type = Word;
        }
    }
    trigger OnPreReport()
    var
        ExportZUGFeRDDocument: Codeunit "Export ZUGFeRD Document";
    begin
        CreateZUGFeRDXML := ExportZUGFeRDDocument.IsZUGFeRDPrintProcess();
        Clear(PDFDocument);
        PDFDocument.Initialize();
    end;

    trigger OnPreRendering(var RenderingPayload: JsonObject)
    begin
        this.OnRenderingCompleteJson(RenderingPayload);
    end;

    local procedure OnRenderingCompleteJson(var RenderingPayload: JsonObject)
    var
        TempBlob: Codeunit "Temp Blob";
        XmlInStream: InStream;
        Name: Text;
        MimeType: Text;
        Description: Text;
        DataType: Enum "PDF Attach. Data Relationship";
    begin
        if CurrReport.TargetFormat <> ReportFormat::PDF then
            exit;

        if not CreateZUGFeRDXML then
            exit;
        Name := 'factur-x.xml';
        CreateXmlFile(TempBlob);
        DataType := DataType::Alternative;
        MimeType := 'text/xml';
        Description := 'This is the e-invoicing xml document';

        TempBlob.CreateInStream(XmlInStream, TextEncoding::UTF8);
        PDFDocument.AddAttachment(Name, DataType, MimeType, XmlInStream, Description, true);

        RenderingPayload := PDFDocument.ToJson(RenderingPayload);
    end;

    local procedure CreateXmlFile(var TempBlob: Codeunit "Temp Blob")
    var
        ExportZUGFeRDDocument: Codeunit "Export ZUGFeRD Document";
        OutStream: OutStream;
    begin
        TempBlob.CreateOutStream(OutStream, TextEncoding::UTF8);
        ExportZUGFeRDDocument.CreateXML(Header, OutStream);
    end;

    var
        PDFDocument: Codeunit "PDF Document";
        CreateZUGFeRDXML: Boolean;
}