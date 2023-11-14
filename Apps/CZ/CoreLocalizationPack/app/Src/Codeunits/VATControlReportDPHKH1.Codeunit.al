// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using System.IO;
using System.Utilities;

codeunit 31105 "VAT Control Report DPHKH1 CZL" implements "VAT Control Report Export CZL"
{
    procedure ExportToXMLFile(VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL"): Text
    var
        TempBlob: Codeunit "Temp Blob";
        FileManagement: Codeunit "File Management";
        ClientFileNameLbl: Label 'VAT Control Report %1.xml', Comment = '%1 = VAT Control Report number';
    begin
        ExportToXMLBlob(VATCtrlReportHeaderCZL, TempBlob);
        if TempBlob.HasValue() then
            exit(FileManagement.BLOBExport(TempBlob, StrSubstNo(ClientFileNameLbl, VATCtrlReportHeaderCZL."No."), true));
    end;

    procedure ExportToXMLBlob(VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL"; var TempBlob: Codeunit "Temp Blob")
    var
        ExportVATCtrlDialogCZL: Report "Export VAT Ctrl. Dialog CZL";
        VATStmtXMLExportHelperCZL: Codeunit "VAT Stmt XML Export Helper CZL";
        VATControlReportDPHKH1CZL: XmlPort "VAT Control Report DPHKH1 CZL";
        VATControlReportOutStream: OutStream;
        XmlParams: Text;
    begin
        XmlParams := VATStmtXMLExportHelperCZL.GetReportRequestPageParameters(Report::"Export VAT Ctrl. Dialog CZL");
        VATStmtXMLExportHelperCZL.UpdateParamsVATCtrlReportHeader(XmlParams, VATCtrlReportHeaderCZL);
        XmlParams := ExportVATCtrlDialogCZL.RunRequestPage(XmlParams);
        if XmlParams = '' then
            exit;
        VATStmtXMLExportHelperCZL.SaveReportRequestPageParameters(Report::"Export VAT Ctrl. Dialog CZL", XmlParams);

        TempBlob.CreateOutStream(VATControlReportOutStream);
        VATControlReportDPHKH1CZL.SetXMLParams(XmlParams);
        VATControlReportDPHKH1CZL.SetDestination(VATControlReportOutStream);
        VATControlReportDPHKH1CZL.Export();
    end;
}
