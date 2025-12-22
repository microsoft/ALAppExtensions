namespace Microsoft.eServices.EDocument.Formats;

using Microsoft.Sales.History;

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
    end;

    trigger OnPreRendering(var RenderingPayload: JsonObject)
    begin
        this.OnRenderingCompleteJson(RenderingPayload);
    end;

    local procedure OnRenderingCompleteJson(var RenderingPayload: JsonObject)
    var
        ExportZUGFeRDDocument: Codeunit "Export ZUGFeRD Document";
    begin
        if CurrReport.TargetFormat <> ReportFormat::PDF then
            exit;

        if not CreateZUGFeRDXML then
            exit;

        ExportZUGFeRDDocument.CreateAndAddXMLAttachmentToRenderingPayload(Header, RenderingPayload);
    end;

    var
        CreateZUGFeRDXML: Boolean;
}