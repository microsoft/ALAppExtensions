// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using System.Utilities;

codeunit 31169 "VAT Report Export CZL"
{
    TableNo = "VAT Report Header";

    trigger OnRun()
    begin
        case GetVATStatementXMLFormat(Rec) of
            "VAT Statement XML Format CZL"::DPHDP3:
                ExportVATReportDPHDP3(Rec);
        end;
    end;

    local procedure ExportVATReportDPHDP3(VATReportHeader: Record "VAT Report Header")
    var
        VATStatementAttachmentCZL: Record "VAT Statement Attachment CZL";
        VATStmtReportLineDataCZL: Record "VAT Stmt. Report Line Data CZL";
        ExportVATStmtDialogCZL: Report "Export VAT Stmt. Dialog CZL";
        TempBlobSubmission: Codeunit "Temp Blob";
        VATReportArchiveMgt: Codeunit "VAT Report Archive Mgt CZL";
        VATStmtXMLExportHelperCZL: Codeunit "VAT Stmt XML Export Helper CZL";
        VATStatementDPHDP3CZL: XmlPort "VAT Statement DPHDP3 CZL";
        OutStreamSubmission: OutStream;
        XmlParams: Text;
        AttachmentXPathTxt: Label 'DPHDP3/Prilohy/ObecnaPriloha', Locked = true;
        AttachmentNodeNameTok: Label 'jm_souboru', Locked = true;
    begin
        ExportVATStmtDialogCZL.Initialize(VATReportHeader);
        XmlParams := ExportVATStmtDialogCZL.RunRequestPage();
        if XmlParams = '' then
            Error('');

        VATStmtReportLineDataCZL.SetFilterTo(VATReportHeader);

        VATStatementDPHDP3CZL.ClearVariables();
        VATStatementDPHDP3CZL.SetXMLParams(XmlParams);
        VATStatementDPHDP3CZL.SetData(VATStmtReportLineDataCZL);
        TempBlobSubmission.CreateOutStream(OutStreamSubmission, TextEncoding::UTF8);
        VATStatementDPHDP3CZL.SetDestination(OutStreamSubmission);
        VATStatementDPHDP3CZL.Export();

        VATStatementDPHDP3CZL.CopyAttachmentFilter(VATStatementAttachmentCZL);
        VATStmtXMLExportHelperCZL.EncodeAttachmentsToXML(
            TempBlobSubmission, AttachmentXPathTxt, AttachmentNodeNameTok, VATStatementAttachmentCZL);

        VATReportArchiveMgt.RemoveVATReportSubmissionFromDocAttachment(VATReportHeader);
        VATReportArchiveMgt.InsertVATReportSubmissionToDocAttachment(VATReportHeader, TempBlobSubmission);
    end;

    local procedure GetVATStatementXMLFormat(VATReportHeader: Record "VAT Report Header"): Enum "VAT Statement XML Format CZL"
    var
        VATStatementTemplate: Record "VAT Statement Template";
    begin
        VATStatementTemplate.Get(VATReportHeader."Statement Template Name");
        exit(VATStatementTemplate."XML Format CZL");
    end;
}
