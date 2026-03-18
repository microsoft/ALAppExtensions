// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Formats;

using Microsoft.Service.History;

reportextension 13920 "Posted Service Invoice" extends "Service - Invoice"
{

    trigger OnPreRendering(var RenderingPayload: JsonObject)
    begin
        AddXMLAttachmentforZUGFeRDExport(RenderingPayload);
    end;

    local procedure AddXMLAttachmentforZUGFeRDExport(var RenderingPayload: JsonObject)
    var
        ExportZUGFeRDDocument: Codeunit "Export ZUGFeRD Document";
    begin
        if CurrReport.TargetFormat() <> ReportFormat::PDF then
            exit;

        if not ExportZUGFeRDDocument.IsZUGFeRDPrintProcess() then
            exit;

        ExportZUGFeRDDocument.CreateAndAddXMLAttachmentToRenderingPayload("Service Invoice Header", RenderingPayload);
    end;
}
