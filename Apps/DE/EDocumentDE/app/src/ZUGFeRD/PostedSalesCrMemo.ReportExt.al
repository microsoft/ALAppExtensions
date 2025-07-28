// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Formats;
using Microsoft.Sales.History;
using System.IO;
reportextension 13919 "Posted Sales Cr.Memo" extends "Standard Sales - Credit Memo"
{
    trigger OnPreReport()
    begin
        OnPreReportOnBeforeInitializePDF(Header, CreateZUGFeRDXML);
        Clear(PDFDocument);
        PDFDocument.Initialize();
    end;

    trigger OnPreRendering(var RenderingPayload: JsonObject)
    begin
        this.OnRenderingCompleteJson(RenderingPayload);
    end;

    [NonDebuggable]
    local procedure OnRenderingCompleteJson(var RenderingPayload: JsonObject)
    var
        UserCode: SecretText;
        AdminCode: SecretText;
        FileName: Text;
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
        FileName := CreateXmlFile(Name);
        DataType := "PDF Attach. Data Relationship"::Alternative;
        MimeType := 'text/xml';
        Description := 'This is the e-invoicing xml document';

        PDFDocument.AddAttachment(Name, DataType, MimeType, FileName, Description, true);

        RenderingPayload := PDFDocument.ToJson(RenderingPayload);
        PDFDocument.ProtectDocument(UserCode, AdminCode);
    end;

    local procedure CreateXmlFile(Filename: Text) FilePath: Text
    var
        ExportZUGFeRDDocument: Codeunit "Export ZUGFeRD Document";
        FileObject: File;
        OutStream: OutStream;
    begin
        FilePath := System.TemporaryPath() + Filename;
        FileObject.TextMode := true;
        FileObject.Create(FilePath, TextEncoding::UTF8);
        FileObject.CreateOutStream(OutStream);
        ExportZUGFeRDDocument.CreateXML(Header, OutStream);
        FileObject.Close();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPreReportOnBeforeInitializePDF(SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var CreateZUGFeRDXML: Boolean)
    begin
    end;

    var
        PDFDocument: Codeunit "PDF Document";
        CreateZUGFeRDXML: Boolean;

}