// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using System.Utilities;

codeunit 31233 "VAT Statement DPHDP3v3 CZL" implements "VAT Statement Export CZL"
{
    var
        VATStatementDPHDP3: Codeunit "VAT Statement DPHDP3 CZL";
        L014ZXmlTok: Label 'OPR_DANE_ZD', Locked = true;
        L014DXmlTok: Label 'OPR_DANE_DAN', Locked = true;
        L048ZXmlTok: Label 'KOR_ODP_ZD', Locked = true;
        L048DXmlTok: Label 'KOR_ODP_PLNE', Locked = true;
        L048KXmlTok: Label 'KOR_ODP_KRAC', Locked = true;

    procedure ExportToXMLFile(VATStatementName: Record "VAT Statement Name"): Text
    begin
        VATStatementDPHDP3.ExportToXMLFile(VATStatementName);
    end;

    procedure ExportToXMLBlob(VATStatementName: Record "VAT Statement Name"; var TempBlob: Codeunit "Temp Blob")
    begin
        VATStatementDPHDP3.ExportToXMLBlob(VATStatementName, TempBlob);
    end;

    procedure InitVATAttributes(VATStatementTemplateName: Code[10])
    var
        VATAttributeCodeCZL: Record "VAT Attribute Code CZL";
    begin
        // Init VAT attributes for DPHDP3 ver. 2
        VATStatementDPHDP3.InitVATAttributes(VATStatementTemplateName);

        // Init VAT attributes for DPHDP3 ver. 3
        InsertData(VATStatementTemplateName, 14, VATAttributeCodeCZL.GetBaseApendix(), VATAttributeCodeCZL.BuildTaxBaseDescription(14), L014ZXmlTok);
        InsertData(VATStatementTemplateName, 14, VATAttributeCodeCZL.GetTaxApendix(), VATAttributeCodeCZL.BuildOutputTaxDescription(14), L014DXmlTok);
        InsertData(VATStatementTemplateName, 48, VATAttributeCodeCZL.GetBaseApendix(), VATAttributeCodeCZL.BuildTaxBaseDescription(48), L048ZXmlTok);
        InsertData(VATStatementTemplateName, 48, VATAttributeCodeCZL.GetTaxApendix(), VATAttributeCodeCZL.BuildInFullDescription(48), L048DXmlTok);
        InsertData(VATStatementTemplateName, 48, VATAttributeCodeCZL.GetReducedApendix(), VATAttributeCodeCZL.BuildReducedDeductionDescription(48), L048KXmlTok);
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
        exit(VATStatementDPHDP3.GetXmlFormatCode());
    end;
}
