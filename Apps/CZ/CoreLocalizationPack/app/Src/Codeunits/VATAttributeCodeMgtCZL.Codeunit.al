// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

codeunit 11781 "VAT Attribute Code Mgt. CZL"
{
    procedure VATStatementTemplateSelection(var VATAttributeCodeCZL: Record "VAT Attribute Code CZL"; var TemplateSelected: Boolean)
    var
        TempVATStatementLine: Record "VAT Statement Line" temporary;
        VATStmtManagement: Codeunit VATStmtManagement;
    begin
        VATStmtManagement.TemplateSelection(Page::"VAT Statement", TempVATStatementLine, TemplateSelected);
        if TemplateSelected then begin
            VATAttributeCodeCZL.FilterGroup := 2;
            TempVATStatementLine.FilterGroup := 2;
            TempVATStatementLine.CopyFilter("Statement Template Name", VATAttributeCodeCZL."VAT Statement Template Name");
            VATAttributeCodeCZL.FilterGroup := 0;
        end;
    end;

    procedure InitVATAttributes(VATStatementTemplate: Record "VAT Statement Template")
    var
        VATStatementExportCZL: Interface "VAT Statement Export CZL";
    begin
        VATStatementExportCZL := VATStatementTemplate."XML Format CZL";
        VATStatementExportCZL.InitVATAttributes(VATStatementTemplate.Name);
    end;

    procedure DeleteVATAttributes(VATStatementTemplate: Record "VAT Statement Template")
    var
        VATAttributeCodeCZL: Record "VAT Attribute Code CZL";
    begin
        VATAttributeCodeCZL.SetRange("VAT Statement Template Name", VATStatementTemplate.Name);
        VATAttributeCodeCZL.DeleteAll();
    end;
}
