// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using System.IO;
using System.Utilities;

codeunit 11788 "VAT Statement DPHDP3 CZL" implements "VAT Statement Export CZL"
{
    var
        VATStmtXMLExportHelperCZL: Codeunit "VAT Stmt XML Export Helper CZL";
        XmlFormatCodeTok: Label 'DP3', Locked = true;

    procedure ExportToXMLFile(VATStatementName: Record "VAT Statement Name"): Text
    var
        FileManagement: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
        ClientFileNameLbl: Label 'VAT Statement %1 %2.xml', Comment = '%1 = VAT Statement Template Nam, %2 = VAT Statement Name';
    begin
        ExportToXMLBlob(VATStatementName, TempBlob);
        if TempBlob.HasValue() then
            exit(FileManagement.BLOBExport(TempBlob, StrSubstNo(ClientFileNameLbl, VATStatementName."Statement Template Name", VATStatementName.Name), true));
    end;

    procedure ExportToXMLBlob(VATStatementName: Record "VAT Statement Name"; var TempBlob: Codeunit "Temp Blob")
    var
        VATStatementAttachmentCZL: Record "VAT Statement Attachment CZL";
        ExportVATStmtDialogCZL: Report "Export VAT Stmt. Dialog CZL";
        VATStatementDPHDP3CZL: XmlPort "VAT Statement DPHDP3 CZL";
        XmlParams: Text;
        DocumentOutStream: OutStream;
        AttachmentXPathTxt: Label 'DPHDP3/Prilohy/ObecnaPriloha', Locked = true;
        AttachmentNodeNameTok: Label 'jm_souboru', Locked = true;
    begin
        XmlParams := VATStmtXMLExportHelperCZL.GetReportRequestPageParameters(Report::"Export VAT Stmt. Dialog CZL");
        VATStmtXMLExportHelperCZL.UpdateParamsVATStatementName(XmlParams, VATStatementName);
        XmlParams := ExportVATStmtDialogCZL.RunRequestPage(XmlParams);
        if XmlParams = '' then
            exit;
        VATStmtXMLExportHelperCZL.SaveReportRequestPageParameters(Report::"Export VAT Stmt. Dialog CZL", XmlParams);

        VATStatementDPHDP3CZL.ClearVariables();
        VATStatementDPHDP3CZL.SetXMLParams(XmlParams);
        TempBlob.CreateOutStream(DocumentOutStream, TextEncoding::UTF8);
        VATStatementDPHDP3CZL.SetDestination(DocumentOutStream);
        VATStatementDPHDP3CZL.Export();

        VATStatementDPHDP3CZL.CopyAttachmentFilter(VATStatementAttachmentCZL);
        VATStmtXMLExportHelperCZL.EncodeAttachmentsToXML(TempBlob, AttachmentXPathTxt, AttachmentNodeNameTok, VATStatementAttachmentCZL);
    end;

    procedure InitVATAttributes(VATStatementTemplateName: Code[10])
    var
        VATAttributeCodeCZL: Record "VAT Attribute Code CZL";
        L001T_XMLTok: Label 'DAN23', Locked = true;
        L001B_XMLTok: Label 'OBRAT23', Locked = true;
        L002T_XMLTok: Label 'DAN5', Locked = true;
        L002B_XMLTok: Label 'OBRAT5', Locked = true;
        L003T_XMLTok: Label 'DAN_PZB23', Locked = true;
        L003B_XMLTok: Label 'P_ZB23', Locked = true;
        L004T_XMLTok: Label 'DAN_PZB5', Locked = true;
        L004B_XMLTok: Label 'P_ZB5', Locked = true;
        L005T_XMLTok: Label 'DAN_PSL23_E', Locked = true;
        L005B_XMLTok: Label 'P_SL23_E', Locked = true;
        L006T_XMLTok: Label 'DAN_PSL5_E', Locked = true;
        L006B_XMLTok: Label 'P_SL5_E', Locked = true;
        L007T_XMLTok: Label 'DAN_DZB23', Locked = true;
        L007B_XMLTok: Label 'DOV_ZB23', Locked = true;
        L008T_XMLTok: Label 'DAN_DZB5', Locked = true;
        L008B_XMLTok: Label 'DOV_ZB5', Locked = true;
        L009T_XMLTok: Label 'DAN_PDOP_NRG', Locked = true;
        L009B_XMLTok: Label 'P_DOP_NRG', Locked = true;
        L010T_XMLTok: Label 'DAN_RPREN23', Locked = true;
        L010B_XMLTok: Label 'REZ_PREN23', Locked = true;
        L011T_XMLTok: Label 'DAN_RPREN5', Locked = true;
        L011B_XMLTok: Label 'REZ_PREN5', Locked = true;
        L012T_XMLTok: Label 'DAN_PSL23_Z', Locked = true;
        L012B_XMLTok: Label 'P_SL23_Z', Locked = true;
        L013T_XMLTok: Label 'DAN_PSL5_Z', Locked = true;
        L013B_XMLTok: Label 'P_SL5_Z', Locked = true;
        L020B_XMLTok: Label 'DOD_ZB', Locked = true;
        L021B_XMLTok: Label 'PLN_SLUZBY', Locked = true;
        L022B_XMLTok: Label 'PLN_VYVOZ', Locked = true;
        L023B_XMLTok: Label 'DOD_DOP_NRG', Locked = true;
        L024B_XMLTok: Label 'PLN_ZASLANI', Locked = true;
        L025B_XMLTok: Label 'PLN_REZ_PREN', Locked = true;
        L026B_XMLTok: Label 'PLN_OST', Locked = true;
        L030B_XMLTok: Label 'TRI_POZB', Locked = true;
        L031B_XMLTok: Label 'TRI_DOZB', Locked = true;
        L032B_XMLTok: Label 'DOV_OSV', Locked = true;
        L033T_XMLTok: Label 'OPR_VERIT', Locked = true;
        L034T_XMLTok: Label 'OPR_DLUZ', Locked = true;
        L040T_XMLTok: Label 'ODP_TUZ23_NAR', Locked = true;
        L040C_XMLTok: Label 'ODP_TUZ23', Locked = true;
        L040B_XMLTok: Label 'PLN23', Locked = true;
        L041T_XMLTok: Label 'ODP_TUZ5_NAR', Locked = true;
        L041C_XMLTok: Label 'ODP_TUZ5', Locked = true;
        L041B_XMLTok: Label 'PLN5', Locked = true;
        L042T_XMLTok: Label 'ODP_CU_NAR', Locked = true;
        L042C_XMLTok: Label 'ODP_CU', Locked = true;
        L042B_XMLTok: Label 'DOV_CU', Locked = true;
        L043T_XMLTok: Label 'OD_ZDP23', Locked = true;
        L043C_XMLTok: Label 'ODKR_ZDP23', Locked = true;
        L043B_XMLTok: Label 'NAR_ZDP23', Locked = true;
        L044T_XMLTok: Label 'OD_ZDP5', Locked = true;
        L044C_XMLTok: Label 'ODKR_ZDP5', Locked = true;
        L044B_XMLTok: Label 'NAR_ZDP5', Locked = true;
        L045T_XMLTok: Label 'ODP_REZ_NAR', Locked = true;
        L045C_XMLTok: Label 'ODP_REZIM', Locked = true;
        L046T_XMLTok: Label 'ODP_SUM_NAR', Locked = true;
        L046C_XMLTok: Label 'ODP_SUM_KR', Locked = true;
        L047T_XMLTok: Label 'OD_MAJ', Locked = true;
        L047C_XMLTok: Label 'ODKR_MAJ', Locked = true;
        L047B_XMLTok: Label 'NAR_MAJ', Locked = true;
        L050B_XMLTok: Label 'PLNOSV_KF', Locked = true;
        L051W_XMLTok: Label 'PLNOSV_NKF', Locked = true;
        L051D_XMLTok: Label 'PLN_NKF', Locked = true;
        L052T_XMLTok: Label 'ODP_UPRAV_KF', Locked = true;
        L052C_XMLTok: Label 'KOEF_P20_NOV', Locked = true;
        L053T_XMLTok: Label 'VYPOR_ODP', Locked = true;
        L053C_XMLTok: Label 'KOEF_P20_VYPOR', Locked = true;
        L060T_XMLTok: Label 'UPRAV_ODP', Locked = true;
        L061T_XMLTok: Label 'DAN_VRAC', Locked = true;
        L062T_XMLTok: Label 'DAN_ZOCELK', Locked = true;
        L063T_XMLTok: Label 'ODP_ZOCELK', Locked = true;
        L064T_XMLTok: Label 'DANO_DA', Locked = true;
        L065T_XMLTok: Label 'DANO_NO', Locked = true;
        L066T_XMLTok: Label 'DANO', Locked = true;
    begin
        InsertData(VATStatementTemplateName, 01, VATAttributeCodeCZL.GetTaxApendix(), VATAttributeCodeCZL.BuildOutputTaxDescription(01), L001T_XMLTok);
        InsertData(VATStatementTemplateName, 01, VATAttributeCodeCZL.GetBaseApendix(), VATAttributeCodeCZL.BuildTaxBaseDescription(01), L001B_XMLTok);
        InsertData(VATStatementTemplateName, 02, VATAttributeCodeCZL.GetTaxApendix(), VATAttributeCodeCZL.BuildOutputTaxDescription(02), L002T_XMLTok);
        InsertData(VATStatementTemplateName, 02, VATAttributeCodeCZL.GetBaseApendix(), VATAttributeCodeCZL.BuildTaxBaseDescription(02), L002B_XMLTok);
        InsertData(VATStatementTemplateName, 03, VATAttributeCodeCZL.GetTaxApendix(), VATAttributeCodeCZL.BuildOutputTaxDescription(03), L003T_XMLTok);
        InsertData(VATStatementTemplateName, 03, VATAttributeCodeCZL.GetBaseApendix(), VATAttributeCodeCZL.BuildTaxBaseDescription(03), L003B_XMLTok);
        InsertData(VATStatementTemplateName, 04, VATAttributeCodeCZL.GetTaxApendix(), VATAttributeCodeCZL.BuildOutputTaxDescription(04), L004T_XMLTok);
        InsertData(VATStatementTemplateName, 04, VATAttributeCodeCZL.GetBaseApendix(), VATAttributeCodeCZL.BuildTaxBaseDescription(04), L004B_XMLTok);
        InsertData(VATStatementTemplateName, 05, VATAttributeCodeCZL.GetTaxApendix(), VATAttributeCodeCZL.BuildOutputTaxDescription(05), L005T_XMLTok);
        InsertData(VATStatementTemplateName, 05, VATAttributeCodeCZL.GetBaseApendix(), VATAttributeCodeCZL.BuildTaxBaseDescription(05), L005B_XMLTok);
        InsertData(VATStatementTemplateName, 06, VATAttributeCodeCZL.GetTaxApendix(), VATAttributeCodeCZL.BuildOutputTaxDescription(06), L006T_XMLTok);
        InsertData(VATStatementTemplateName, 06, VATAttributeCodeCZL.GetBaseApendix(), VATAttributeCodeCZL.BuildTaxBaseDescription(06), L006B_XMLTok);
        InsertData(VATStatementTemplateName, 07, VATAttributeCodeCZL.GetTaxApendix(), VATAttributeCodeCZL.BuildOutputTaxDescription(07), L007T_XMLTok);
        InsertData(VATStatementTemplateName, 07, VATAttributeCodeCZL.GetBaseApendix(), VATAttributeCodeCZL.BuildTaxBaseDescription(07), L007B_XMLTok);
        InsertData(VATStatementTemplateName, 08, VATAttributeCodeCZL.GetTaxApendix(), VATAttributeCodeCZL.BuildOutputTaxDescription(08), L008T_XMLTok);
        InsertData(VATStatementTemplateName, 08, VATAttributeCodeCZL.GetBaseApendix(), VATAttributeCodeCZL.BuildTaxBaseDescription(08), L008B_XMLTok);
        InsertData(VATStatementTemplateName, 09, VATAttributeCodeCZL.GetTaxApendix(), VATAttributeCodeCZL.BuildOutputTaxDescription(09), L009T_XMLTok);
        InsertData(VATStatementTemplateName, 09, VATAttributeCodeCZL.GetBaseApendix(), VATAttributeCodeCZL.BuildTaxBaseDescription(09), L009B_XMLTok);
        InsertData(VATStatementTemplateName, 10, VATAttributeCodeCZL.GetTaxApendix(), VATAttributeCodeCZL.BuildOutputTaxDescription(10), L010T_XMLTok);
        InsertData(VATStatementTemplateName, 10, VATAttributeCodeCZL.GetBaseApendix(), VATAttributeCodeCZL.BuildTaxBaseDescription(10), L010B_XMLTok);
        InsertData(VATStatementTemplateName, 11, VATAttributeCodeCZL.GetTaxApendix(), VATAttributeCodeCZL.BuildOutputTaxDescription(11), L011T_XMLTok);
        InsertData(VATStatementTemplateName, 11, VATAttributeCodeCZL.GetBaseApendix(), VATAttributeCodeCZL.BuildTaxBaseDescription(11), L011B_XMLTok);
        InsertData(VATStatementTemplateName, 12, VATAttributeCodeCZL.GetTaxApendix(), VATAttributeCodeCZL.BuildOutputTaxDescription(12), L012T_XMLTok);
        InsertData(VATStatementTemplateName, 12, VATAttributeCodeCZL.GetBaseApendix(), VATAttributeCodeCZL.BuildTaxBaseDescription(12), L012B_XMLTok);
        InsertData(VATStatementTemplateName, 13, VATAttributeCodeCZL.GetTaxApendix(), VATAttributeCodeCZL.BuildOutputTaxDescription(13), L013T_XMLTok);
        InsertData(VATStatementTemplateName, 13, VATAttributeCodeCZL.GetBaseApendix(), VATAttributeCodeCZL.BuildTaxBaseDescription(13), L013B_XMLTok);
        InsertData(VATStatementTemplateName, 20, VATAttributeCodeCZL.GetBaseApendix(), VATAttributeCodeCZL.BuildTaxBaseDescription(20), L020B_XMLTok);
        InsertData(VATStatementTemplateName, 21, VATAttributeCodeCZL.GetBaseApendix(), VATAttributeCodeCZL.BuildTaxBaseDescription(21), L021B_XMLTok);
        InsertData(VATStatementTemplateName, 22, VATAttributeCodeCZL.GetBaseApendix(), VATAttributeCodeCZL.BuildTaxBaseDescription(22), L022B_XMLTok);
        InsertData(VATStatementTemplateName, 23, VATAttributeCodeCZL.GetBaseApendix(), VATAttributeCodeCZL.BuildTaxBaseDescription(23), L023B_XMLTok);
        InsertData(VATStatementTemplateName, 24, VATAttributeCodeCZL.GetBaseApendix(), VATAttributeCodeCZL.BuildTaxBaseDescription(24), L024B_XMLTok);
        InsertData(VATStatementTemplateName, 25, VATAttributeCodeCZL.GetBaseApendix(), VATAttributeCodeCZL.BuildTaxBaseDescription(25), L025B_XMLTok);
        InsertData(VATStatementTemplateName, 26, VATAttributeCodeCZL.GetBaseApendix(), VATAttributeCodeCZL.BuildTaxBaseDescription(26), L026B_XMLTok);
        InsertData(VATStatementTemplateName, 30, VATAttributeCodeCZL.GetBaseApendix(), VATAttributeCodeCZL.BuildAcquisitionOfGoodsTaxBaseDescription(30), L030B_XMLTok);
        InsertData(VATStatementTemplateName, 31, VATAttributeCodeCZL.GetBaseApendix(), VATAttributeCodeCZL.BuildDeliveryOfGoodsTaxBaseDescription(31), L031B_XMLTok);
        InsertData(VATStatementTemplateName, 32, VATAttributeCodeCZL.GetBaseApendix(), VATAttributeCodeCZL.BuildGoodsImportTaxBaseDescription(32), L032B_XMLTok);
        InsertData(VATStatementTemplateName, 33, VATAttributeCodeCZL.GetTaxApendix(), VATAttributeCodeCZL.BuildCreditorTaxDescription(33), L033T_XMLTok);
        InsertData(VATStatementTemplateName, 34, VATAttributeCodeCZL.GetTaxApendix(), VATAttributeCodeCZL.BuildDebtorTaxDescription(34), L034T_XMLTok);
        InsertData(VATStatementTemplateName, 40, VATAttributeCodeCZL.GetTaxApendix(), VATAttributeCodeCZL.BuildInFullDescription(40), L040T_XMLTok);
        InsertData(VATStatementTemplateName, 40, VATAttributeCodeCZL.GetReducedApendix(), VATAttributeCodeCZL.BuildReducedDeductionDescription(40), L040C_XMLTok);
        InsertData(VATStatementTemplateName, 40, VATAttributeCodeCZL.GetBaseApendix(), VATAttributeCodeCZL.BuildTaxBaseDescription(40), L040B_XMLTok);
        InsertData(VATStatementTemplateName, 41, VATAttributeCodeCZL.GetTaxApendix(), VATAttributeCodeCZL.BuildInFullDescription(41), L041T_XMLTok);
        InsertData(VATStatementTemplateName, 41, VATAttributeCodeCZL.GetReducedApendix(), VATAttributeCodeCZL.BuildReducedDeductionDescription(41), L041C_XMLTok);
        InsertData(VATStatementTemplateName, 41, VATAttributeCodeCZL.GetBaseApendix(), VATAttributeCodeCZL.BuildTaxBaseDescription(41), L041B_XMLTok);
        InsertData(VATStatementTemplateName, 42, VATAttributeCodeCZL.GetTaxApendix(), VATAttributeCodeCZL.BuildInFullDescription(42), L042T_XMLTok);
        InsertData(VATStatementTemplateName, 42, VATAttributeCodeCZL.GetReducedApendix(), VATAttributeCodeCZL.BuildReducedDeductionDescription(42), L042C_XMLTok);
        InsertData(VATStatementTemplateName, 42, VATAttributeCodeCZL.GetBaseApendix(), VATAttributeCodeCZL.BuildTaxBaseDescription(42), L042B_XMLTok);
        InsertData(VATStatementTemplateName, 43, VATAttributeCodeCZL.GetTaxApendix(), VATAttributeCodeCZL.BuildInFullDescription(43), L043T_XMLTok);
        InsertData(VATStatementTemplateName, 43, VATAttributeCodeCZL.GetReducedApendix(), VATAttributeCodeCZL.BuildReducedDeductionDescription(43), L043C_XMLTok);
        InsertData(VATStatementTemplateName, 43, VATAttributeCodeCZL.GetBaseApendix(), VATAttributeCodeCZL.BuildTaxBaseDescription(43), L043B_XMLTok);
        InsertData(VATStatementTemplateName, 44, VATAttributeCodeCZL.GetTaxApendix(), VATAttributeCodeCZL.BuildInFullDescription(44), L044T_XMLTok);
        InsertData(VATStatementTemplateName, 44, VATAttributeCodeCZL.GetReducedApendix(), VATAttributeCodeCZL.BuildReducedDeductionDescription(44), L044C_XMLTok);
        InsertData(VATStatementTemplateName, 44, VATAttributeCodeCZL.GetBaseApendix(), VATAttributeCodeCZL.BuildTaxBaseDescription(44), L044B_XMLTok);
        InsertData(VATStatementTemplateName, 45, VATAttributeCodeCZL.GetTaxApendix(), VATAttributeCodeCZL.BuildInFullDescription(45), L045T_XMLTok);
        InsertData(VATStatementTemplateName, 45, VATAttributeCodeCZL.GetReducedApendix(), VATAttributeCodeCZL.BuildReducedDeductionDescription(45), L045C_XMLTok);
        InsertData(VATStatementTemplateName, 46, VATAttributeCodeCZL.GetTaxApendix(), VATAttributeCodeCZL.BuildInFullDescription(46), L046T_XMLTok);
        InsertData(VATStatementTemplateName, 46, VATAttributeCodeCZL.GetReducedApendix(), VATAttributeCodeCZL.BuildReducedDeductionDescription(46), L046C_XMLTok);
        InsertData(VATStatementTemplateName, 47, VATAttributeCodeCZL.GetTaxApendix(), VATAttributeCodeCZL.BuildInFullDescription(47), L047T_XMLTok);
        InsertData(VATStatementTemplateName, 47, VATAttributeCodeCZL.GetReducedApendix(), VATAttributeCodeCZL.BuildReducedDeductionDescription(47), L047C_XMLTok);
        InsertData(VATStatementTemplateName, 47, VATAttributeCodeCZL.GetBaseApendix(), VATAttributeCodeCZL.BuildTaxBaseDescription(47), L047B_XMLTok);
        InsertData(VATStatementTemplateName, 50, VATAttributeCodeCZL.GetBaseApendix(), VATAttributeCodeCZL.BuildTaxBaseDescription(50), L050B_XMLTok);
        InsertData(VATStatementTemplateName, 51, VATAttributeCodeCZL.GetNoDeductionApendix(), VATAttributeCodeCZL.BuildWithoutClaimOnDeductionDescription(51), L051W_XMLTok);
        InsertData(VATStatementTemplateName, 51, VATAttributeCodeCZL.GetDeductionApendix(), VATAttributeCodeCZL.BuildWithClaimOnDeductionDescription(51), L051D_XMLTok);
        InsertData(VATStatementTemplateName, 52, VATAttributeCodeCZL.GetTaxApendix(), VATAttributeCodeCZL.BuildDeductionDescription(52), L052T_XMLTok);
        InsertData(VATStatementTemplateName, 52, VATAttributeCodeCZL.GetReducedApendix(), VATAttributeCodeCZL.BuildCoefficientDescription(52), L052C_XMLTok);
        InsertData(VATStatementTemplateName, 53, VATAttributeCodeCZL.GetTaxApendix(), VATAttributeCodeCZL.BuildDeductionChangeDescription(53), L053T_XMLTok);
        InsertData(VATStatementTemplateName, 53, VATAttributeCodeCZL.GetReducedApendix(), VATAttributeCodeCZL.BuildSettlementCoefficientDescription(53), L053C_XMLTok);
        InsertData(VATStatementTemplateName, 60, VATAttributeCodeCZL.GetTaxApendix(), VATAttributeCodeCZL.BuildTaxDescription(60), L060T_XMLTok);
        InsertData(VATStatementTemplateName, 61, VATAttributeCodeCZL.GetTaxApendix(), VATAttributeCodeCZL.BuildTaxDescription(61), L061T_XMLTok);
        InsertData(VATStatementTemplateName, 62, VATAttributeCodeCZL.GetTaxApendix(), VATAttributeCodeCZL.BuildTaxDescription(62), L062T_XMLTok);
        InsertData(VATStatementTemplateName, 63, VATAttributeCodeCZL.GetTaxApendix(), VATAttributeCodeCZL.BuildTaxDescription(63), L063T_XMLTok);
        InsertData(VATStatementTemplateName, 64, VATAttributeCodeCZL.GetTaxApendix(), VATAttributeCodeCZL.BuildTaxDescription(64), L064T_XMLTok);
        InsertData(VATStatementTemplateName, 65, VATAttributeCodeCZL.GetTaxApendix(), VATAttributeCodeCZL.BuildTaxDescription(65), L065T_XMLTok);
        InsertData(VATStatementTemplateName, 66, VATAttributeCodeCZL.GetTaxApendix(), VATAttributeCodeCZL.BuildTaxDescription(66), L066T_XMLTok);
    end;

    local procedure InsertData(VATStatementTemplateName: Code[10]; LineNo: Integer; Apendix: Code[1]; Description: Text[100]; XmlCode: Code[20])
    var
        VATAttributeCodeMgt: Codeunit "VAT Attribute Code Mgt. CZL";
    begin
        VATAttributeCodeMgt.InsertVATAttributeCode(
            VATStatementTemplateName, GetXmlFormatCode(), LineNo, Apendix, Description, XmlCode);
    end;

    internal procedure GetXmlFormatCode(): Code[10]
    begin
        exit(XmlFormatCodeTok);
    end;
}
