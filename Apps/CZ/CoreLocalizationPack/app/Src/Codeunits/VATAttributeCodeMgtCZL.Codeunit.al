// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

codeunit 11781 "VAT Attribute Code Mgt. CZL"
{
    EventSubscriberInstance = Manual;

    var
        GlobalOverwriteData: Boolean;

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

    procedure InitVATAttributes(VATStatementName: Record "VAT Statement Name"; OverwriteData: Boolean)
    var
        VATStatementExportCZL: Interface "VAT Statement Export CZL";
    begin
        SetOverwriteData(OverwriteData);
        BindSubscription(this);
        VATStatementExportCZL := VATStatementName."XML Format CZL";
        VATStatementExportCZL.InitVATAttributes(VATStatementName."Statement Template Name");
        UnbindSubscription(this);
    end;
#if not CLEAN26

    [Obsolete('Replaced by InitVATAttributesCZL function with VATStatementName parameter.', '26.0')]
    procedure InitVATAttributes(VATStatementTemplate: Record "VAT Statement Template")
    var
        VATStatementExportCZL: Interface "VAT Statement Export CZL";
    begin
        VATStatementExportCZL := VATStatementTemplate."XML Format CZL";
        VATStatementExportCZL.InitVATAttributes(VATStatementTemplate.Name);
    end;
#endif

    procedure DeleteVATAttributes(VATStatementTemplate: Record "VAT Statement Template")
    var
        VATAttributeCodeCZL: Record "VAT Attribute Code CZL";
    begin
        VATAttributeCodeCZL.SetRange("VAT Statement Template Name", VATStatementTemplate.Name);
        VATAttributeCodeCZL.DeleteAll();
    end;

    procedure SetOverwriteData(NewOverwriteData: Boolean)
    begin
        GlobalOverwriteData := NewOverwriteData;
    end;

    internal procedure InsertVATAttributeCode(VATStatementTemplateName: Code[10]; XmlFormatCode: Code[10]; LineNo: Integer; Apendix: Code[1]; Description: Text[100]; XmlCode: Code[20])
    var
        VATAttributeCodeCZL: Record "VAT Attribute Code CZL";
    begin
        InsertVATAttributeCode(
            VATStatementTemplateName, VATAttributeCodeCZL.BuildVATAttributeCode(XmlFormatCode, LineNo, Apendix),
            Description, XmlCode, VATAttributeCodeCZL.ConvertApendixToVATReportAmountType(Apendix));
    end;

    internal procedure InsertVATAttributeCode(VATStatementTemplateName: Code[10]; AttributeCode: Code[20]; Description: Text[100]; XmlCode: Code[20]; VATReportAmountType: Enum "VAT Report Amount Type CZL")
    var
        VATAttributeCodeCZL: Record "VAT Attribute Code CZL";
        Exists: Boolean;
    begin
        if VATAttributeCodeCZL.Get(VATStatementTemplateName, AttributeCode) then begin
            Exists := true;

            if not IsOverwriteDataAllowed() then
                exit;
        end;

        VATAttributeCodeCZL.Init();
        VATAttributeCodeCZL.Validate("VAT Statement Template Name", VATStatementTemplateName);
        VATAttributeCodeCZL.Validate(Code, AttributeCode);
        VATAttributeCodeCZL.Validate(Description, Description);
        VATAttributeCodeCZL.Validate("XML Code", XmlCode);
        VATAttributeCodeCZL.Validate("VAT Report Amount Type", VATReportAmountType);
        if Exists then
            VATAttributeCodeCZL.Modify()
        else
            VATAttributeCodeCZL.Insert();
    end;

    local procedure IsOverwriteDataAllowed() OverwriteData: Boolean
    begin
        OverwriteData := GlobalOverwriteData;
        OnIsOverwriteDataAllowed(OverwriteData);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"VAT Attribute Code Mgt. CZL", OnIsOverwriteDataAllowed, '', false, false)]
    local procedure AllowOverwriteData(var OverwriteData: Boolean)
    begin
        OverwriteData := GlobalOverwriteData;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnIsOverwriteDataAllowed(var OverwriteData: Boolean)
    begin
    end;
}
