// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Formats;

using Microsoft.Sales.History;

reportextension 13919 "Posted Sales Cr.Memo" extends "Standard Sales - Credit Memo"
{
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

    [NonDebuggable]
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

#pragma warning disable AS0072
#if not CLEAN27
    [Obsolete('Event not used anymore. If you need to know whether the report is being called for ZUGFeRD Export then use IsZUGFeRDPrintProcess in Codeunit "Export ZUGFeRD Document"', '27.2')]
    [IntegrationEvent(false, false)]
    local procedure OnPreReportOnBeforeInitializePDF(SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var CreateZUGFeRDXML: Boolean)
    begin
    end;
#endif
#pragma warning restore AS0072

    var
        CreateZUGFeRDXML: Boolean;

}