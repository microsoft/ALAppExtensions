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
        TTok: Label 'D', Locked = true;
        BTok: Label 'Z', Locked = true;
        CTok: Label 'K', Locked = true;
        WTok: Label 'B', Locked = true;
        DTok: Label 'S', Locked = true;
        XOutputtaxTxt: Label 'l. %1 - Output tax', Comment = '%1 = line number';
        XTaxbaseTxt: Label 'l. %1 - Tax base', Comment = '%1 = line number';
        XAcquisitionofgoodstaxbaseTxt: Label 'l. %1 - Acquisition of goods, tax base', Comment = '%1 = line number';
        XDeliveryOfGoodsTaxBaseTxt: Label 'l. %1 - Delivery of goods, tax base', Comment = '%1 = line number';
        XGoodsImportTaxBaseTxt: Label 'l. %1 - Goods import, tax base', Comment = '%1 = line number';
        XCreditorTaxTxt: Label 'l. %1 - Creditor, tax', Comment = '%1 = line number';
        XDebtorTaxTxt: Label 'l. %1 - Debtor, tax', Comment = '%1 = line number';
        XInfullTxt: Label 'l. %1 - In full', Comment = '%1 = line number';
        XReducedDeductionTxt: Label 'l. %1 - Reduced deduction', Comment = '%1 = line number';
        XWithoutClaimOnDeductionTxt: Label 'l. %1 - Without claim on deduction', Comment = '%1 = line number';
        XWithClaimOnDeductionTxt: Label 'l. %1 - With claim on deduction', Comment = '%1 = line number';
        XDeductionTxt: Label 'l. %1 - Deduction', Comment = '%1 = line number';
        XCoefficientTxt: Label 'l. %1 - Coefficient %', Comment = '%1 = line number';
        XDeducationChangeTxt: Label 'l. %1 - Deducation change', Comment = '%1 = line number';
        XSettlementCoefficientTxt: Label 'l. %1 - Settlement coefficient', Comment = '%1 = line number';
        XTaxTxt: Label 'l. %1 - Tax', Comment = '%1 = line number';
    begin
        InsertData(VATStatementTemplateName, 01, TTok, XOutputtaxTxt, L001T_XMLTok);
        InsertData(VATStatementTemplateName, 01, BTok, XTaxbaseTxt, L001B_XMLTok);
        InsertData(VATStatementTemplateName, 02, TTok, XOutputtaxTxt, L002T_XMLTok);
        InsertData(VATStatementTemplateName, 02, BTok, XTaxbaseTxt, L002B_XMLTok);
        InsertData(VATStatementTemplateName, 03, TTok, XOutputtaxTxt, L003T_XMLTok);
        InsertData(VATStatementTemplateName, 03, BTok, XTaxbaseTxt, L003B_XMLTok);
        InsertData(VATStatementTemplateName, 04, TTok, XOutputtaxTxt, L004T_XMLTok);
        InsertData(VATStatementTemplateName, 04, BTok, XTaxbaseTxt, L004B_XMLTok);
        InsertData(VATStatementTemplateName, 05, TTok, XOutputtaxTxt, L005T_XMLTok);
        InsertData(VATStatementTemplateName, 05, BTok, XTaxbaseTxt, L005B_XMLTok);
        InsertData(VATStatementTemplateName, 06, TTok, XOutputtaxTxt, L006T_XMLTok);
        InsertData(VATStatementTemplateName, 06, BTok, XTaxbaseTxt, L006B_XMLTok);
        InsertData(VATStatementTemplateName, 07, TTok, XOutputtaxTxt, L007T_XMLTok);
        InsertData(VATStatementTemplateName, 07, BTok, XTaxbaseTxt, L007B_XMLTok);
        InsertData(VATStatementTemplateName, 08, TTok, XOutputtaxTxt, L008T_XMLTok);
        InsertData(VATStatementTemplateName, 08, BTok, XTaxbaseTxt, L008B_XMLTok);
        InsertData(VATStatementTemplateName, 09, TTok, XOutputtaxTxt, L009T_XMLTok);
        InsertData(VATStatementTemplateName, 09, BTok, XTaxbaseTxt, L009B_XMLTok);
        InsertData(VATStatementTemplateName, 10, TTok, XOutputtaxTxt, L010T_XMLTok);
        InsertData(VATStatementTemplateName, 10, BTok, XTaxbaseTxt, L010B_XMLTok);
        InsertData(VATStatementTemplateName, 11, TTok, XOutputtaxTxt, L011T_XMLTok);
        InsertData(VATStatementTemplateName, 11, BTok, XTaxbaseTxt, L011B_XMLTok);
        InsertData(VATStatementTemplateName, 12, TTok, XOutputtaxTxt, L012T_XMLTok);
        InsertData(VATStatementTemplateName, 12, BTok, XTaxbaseTxt, L012B_XMLTok);
        InsertData(VATStatementTemplateName, 13, TTok, XOutputtaxTxt, L013T_XMLTok);
        InsertData(VATStatementTemplateName, 13, BTok, XTaxbaseTxt, L013B_XMLTok);
        InsertData(VATStatementTemplateName, 20, BTok, XTaxbaseTxt, L020B_XMLTok);
        InsertData(VATStatementTemplateName, 21, BTok, XTaxbaseTxt, L021B_XMLTok);
        InsertData(VATStatementTemplateName, 22, BTok, XTaxbaseTxt, L022B_XMLTok);
        InsertData(VATStatementTemplateName, 23, BTok, XTaxbaseTxt, L023B_XMLTok);
        InsertData(VATStatementTemplateName, 24, BTok, XTaxbaseTxt, L024B_XMLTok);
        InsertData(VATStatementTemplateName, 25, BTok, XTaxbaseTxt, L025B_XMLTok);
        InsertData(VATStatementTemplateName, 26, BTok, XTaxbaseTxt, L026B_XMLTok);
        InsertData(VATStatementTemplateName, 30, BTok, XAcquisitionofgoodstaxbaseTxt, L030B_XMLTok);
        InsertData(VATStatementTemplateName, 31, BTok, XDeliveryOfGoodsTaxBaseTxt, L031B_XMLTok);
        InsertData(VATStatementTemplateName, 32, BTok, XGoodsImportTaxBaseTxt, L032B_XMLTok);
        InsertData(VATStatementTemplateName, 33, TTok, XCreditorTaxTxt, L033T_XMLTok);
        InsertData(VATStatementTemplateName, 34, TTok, XDebtorTaxTxt, L034T_XMLTok);
        InsertData(VATStatementTemplateName, 40, TTok, XInfullTxt, L040T_XMLTok);
        InsertData(VATStatementTemplateName, 40, CTok, XReducedDeductionTxt, L040C_XMLTok);
        InsertData(VATStatementTemplateName, 40, BTok, XTaxbaseTxt, L040B_XMLTok);
        InsertData(VATStatementTemplateName, 41, TTok, XInfullTxt, L041T_XMLTok);
        InsertData(VATStatementTemplateName, 41, CTok, XReducedDeductionTxt, L041C_XMLTok);
        InsertData(VATStatementTemplateName, 41, BTok, XTaxbaseTxt, L041B_XMLTok);
        InsertData(VATStatementTemplateName, 42, TTok, XInfullTxt, L042T_XMLTok);
        InsertData(VATStatementTemplateName, 42, CTok, XReducedDeductionTxt, L042C_XMLTok);
        InsertData(VATStatementTemplateName, 42, BTok, XTaxbaseTxt, L042B_XMLTok);
        InsertData(VATStatementTemplateName, 43, TTok, XInfullTxt, L043T_XMLTok);
        InsertData(VATStatementTemplateName, 43, CTok, XReducedDeductionTxt, L043C_XMLTok);
        InsertData(VATStatementTemplateName, 43, BTok, XTaxbaseTxt, L043B_XMLTok);
        InsertData(VATStatementTemplateName, 44, TTok, XInfullTxt, L044T_XMLTok);
        InsertData(VATStatementTemplateName, 44, CTok, XReducedDeductionTxt, L044C_XMLTok);
        InsertData(VATStatementTemplateName, 44, BTok, XTaxbaseTxt, L044B_XMLTok);
        InsertData(VATStatementTemplateName, 45, TTok, XInfullTxt, L045T_XMLTok);
        InsertData(VATStatementTemplateName, 45, CTok, XReducedDeductionTxt, L045C_XMLTok);
        InsertData(VATStatementTemplateName, 46, TTok, XInfullTxt, L046T_XMLTok);
        InsertData(VATStatementTemplateName, 46, CTok, XReducedDeductionTxt, L046C_XMLTok);
        InsertData(VATStatementTemplateName, 47, TTok, XInfullTxt, L047T_XMLTok);
        InsertData(VATStatementTemplateName, 47, CTok, XReducedDeductionTxt, L047C_XMLTok);
        InsertData(VATStatementTemplateName, 47, BTok, XTaxbaseTxt, L047B_XMLTok);
        InsertData(VATStatementTemplateName, 50, BTok, XTaxbaseTxt, L050B_XMLTok);
        InsertData(VATStatementTemplateName, 51, WTok, XWithoutClaimOnDeductionTxt, L051W_XMLTok);
        InsertData(VATStatementTemplateName, 51, DTok, XWithClaimOnDeductionTxt, L051D_XMLTok);
        InsertData(VATStatementTemplateName, 52, TTok, XDeductionTxt, L052T_XMLTok);
        InsertData(VATStatementTemplateName, 52, CTok, XCoefficientTxt, L052C_XMLTok);
        InsertData(VATStatementTemplateName, 53, TTok, XDeducationChangeTxt, L053T_XMLTok);
        InsertData(VATStatementTemplateName, 53, CTok, XSettlementCoefficientTxt, L053C_XMLTok);
        InsertData(VATStatementTemplateName, 60, TTok, XTaxTxt, L060T_XMLTok);
        InsertData(VATStatementTemplateName, 61, TTok, XTaxTxt, L061T_XMLTok);
        InsertData(VATStatementTemplateName, 62, TTok, XTaxTxt, L062T_XMLTok);
        InsertData(VATStatementTemplateName, 63, TTok, XTaxTxt, L063T_XMLTok);
        InsertData(VATStatementTemplateName, 64, TTok, XTaxTxt, L064T_XMLTok);
        InsertData(VATStatementTemplateName, 65, TTok, XTaxTxt, L065T_XMLTok);
        InsertData(VATStatementTemplateName, 66, TTok, XTaxTxt, L066T_XMLTok);
    end;

    local procedure InsertData(VATStatementTemplateName: Code[10]; LineNo: Integer; Apendix: Code[1]; Description: Text[100]; XmlCode: Code[20])
    var
        VATAttributeCodeCZL: Record "VAT Attribute Code CZL";
        AttributeCode: Code[20];
        XTagFormatLbl: Label 'DP3-%1%2', Comment = '%1 = line number with a fixed length of two characters, %2 = abbreviation specifying value on a line', Locked = true;
    begin
        AttributeCode := StrSubstNo(XTagFormatLbl, LeftPadCode(Format(LineNo), 2, '0'), Apendix);
        if VATAttributeCodeCZL.Get(VATStatementTemplateName, AttributeCode) then
            exit;
        VATAttributeCodeCZL.Init();
        VATAttributeCodeCZL.Validate("VAT Statement Template Name", VATStatementTemplateName);
        VATAttributeCodeCZL.Validate(Code, AttributeCode);
        VATAttributeCodeCZL.Validate(Description, StrSubstNo(Description, LeftPadCode(Format(LineNo), 3, '0')));
        VATAttributeCodeCZL.Validate("XML Code", XmlCode);
        case Apendix of
            'Z':
                VATAttributeCodeCZL.Validate("VAT Report Amount Type", "VAT Report Amount Type CZL"::Base);
            'D', 'S', 'B':
                VATAttributeCodeCZL.Validate("VAT Report Amount Type", "VAT Report Amount Type CZL"::Amount);
            'K':
                VATAttributeCodeCZL.Validate("VAT Report Amount Type", "VAT Report Amount Type CZL"::"Reduced Amount");
        end;
        VATAttributeCodeCZL.Insert();
    end;

    local procedure LeftPadCode(String: Text; Length: Integer; FillCharacter: Text): Text;
    begin
        exit(PadStr('', Length - StrLen(String), FillCharacter) + String);
    end;
}
