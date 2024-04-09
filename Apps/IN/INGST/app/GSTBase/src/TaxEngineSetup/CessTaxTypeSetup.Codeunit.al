// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxEngine.JsonExchange;

using Microsoft.Finance.GST.Base;

codeunit 18007 "Cess Tax Type Setup"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Engine Assisted Setup", 'OnSetupTaxTypes', '', false, false)]
    local procedure OnSetupTaxTypes()
    var
        CessTaxTypeData: Codeunit "Cess Tax Type Data";
        TaxJsonDeserialization: Codeunit "Tax Json Deserialization";
    begin
        TaxJsonDeserialization.HideDialog(true);
        TaxJsonDeserialization.SkipVersionCheck(true);
        TaxJsonDeserialization.ImportTaxTypes(CessTaxTypeData.GetText());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Engine Assisted Setup", 'OnGetUseCaseConfig', '', false, false)]
    local procedure OnGetUseCaseConfig(CaseID: Guid; var ConfigText: Text; var IsHandled: Boolean)
    begin
        if IsHandled then
            exit;

        ConfigText := GetConfig(CaseID, IsHandled);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Engine Assisted Setup", 'OnGetTaxTypeConfig', '', false, false)]
    local procedure OnGetTaxTypeConfig(TaxType: Code[20]; var ConfigText: Text; var IsHandled: Boolean)
    var
        CessTaxTypeData: Codeunit "Cess Tax Type Data";
        CESSTaxTypeLbl: Label 'GST CESS';
    begin
        if IsHandled then
            exit;

        if TaxType = CESSTaxTypeLbl then begin
            ConfigText := CessTaxTypeData.GetText();
            IsHandled := true;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"GST Upgrade Subscribers", 'OnGetUpgradedTaxTypeConfig', '', false, false)]
    local procedure OnGetUpgradedTaxTypeConfig(TaxType: Code[20]; var ConfigText: Text; var IsHandled: Boolean)
    var
        CessTaxTypeData: Codeunit "Cess Tax Type Data";
        CESSTaxTypeLbl: Label 'GST CESS';
    begin
        if IsHandled then
            exit;

        if TaxType = CESSTaxTypeLbl then begin
            ConfigText := CessTaxTypeData.GetText();
            IsHandled := true;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"GST Upgrade Subscribers", 'OnGetUpgradedUseCaseConfig', '', false, false)]
    local procedure OnGetGSTConfig(CaseID: Guid; var IsHandled: Boolean; var Configtext: Text)
    begin
        Configtext := GetConfig(CaseID, IsHandled);
    end;

    procedure GetConfig(CaseID: Guid; var Handled: Boolean): Text
    var
        "{6F2DE875-4569-41DB-A28E-021E4D00378A}Lbl": Label 'GST Use Cases';
        "{8D7FD8C3-FCB1-4968-8FD6-08181778EC29}Lbl": Label 'GST Use Cases';
        "{EFF1E5F5-6CC1-414D-BD1F-1095D42F9A4A}Lbl": Label 'GST Use Cases';
        "{12089FA0-9627-4C6F-B855-112FE6FFAC49}Lbl": Label 'GST Use Cases';
        "{231587B2-D0BD-4362-9A3B-11839F7BB326}Lbl": Label 'GST Use Cases';
        "{E1914856-FF7A-4B3A-99D5-17190CE10C27}Lbl": Label 'GST Use Cases';
        "{B4A44DCF-6090-4813-9C09-193AB1A09B93}Lbl": Label 'GST Use Cases';
        "{FD3380A2-217C-4059-A344-1D832B755088}Lbl": Label 'GST Use Cases';
        "{812C7B77-0622-4E71-9F4E-261C3874A680}Lbl": Label 'GST Use Cases';
        "{FBD319E5-BDFD-43E8-B9EB-275F01FA6A40}Lbl": Label 'GST Use Cases';
        "{DF123FC7-B145-43CA-85DC-287F940778FC}Lbl": Label 'GST Use Cases';
        "{9B4E1225-00F2-4467-BA93-29AD1F2EBD46}Lbl": Label 'GST Use Cases';
        "{C08A9FD5-5ECC-4BB5-8A19-345060822129}Lbl": Label 'GST Use Cases';
        "{3E8E1EDA-828E-40BE-8FD4-3456546F47A6}Lbl": Label 'GST Use Cases';
        "{1E087C72-9078-4C31-ABD5-38F01008E508}Lbl": Label 'GST Use Cases';
        "{272FFE9F-A7C9-4AF8-87DD-3EA53BA18511}Lbl": Label 'GST Use Cases';
        "{9DB4ECE1-3397-4ADD-9EA8-40A8D82A6A9A}Lbl": Label 'GST Use Cases';
        "{3A6F385C-72E7-42C6-A696-47102B270402}Lbl": Label 'GST Use Cases';
        "{F6F63738-94DD-4B0B-BAD6-4EC11668D327}Lbl": Label 'GST Use Cases';
        "{7C64DCF3-718C-405E-A389-582FD1E33E5D}Lbl": Label 'GST Use Cases';
        "{6DEEF440-3A5B-4201-9D1B-59AC37AF4C36}Lbl": Label 'GST Use Cases';
        "{33CD3931-0BA0-4358-B808-5C6378CAA489}Lbl": Label 'GST Use Cases';
        "{725E8FB9-C4CC-42B7-B060-5E86614A8168}Lbl": Label 'GST Use Cases';
        "{CBDB09CC-FB6C-4475-89A3-62C04DADFA15}Lbl": Label 'GST Use Cases';
        "{F33121DD-68CB-423C-A98B-6FF10BD8CED7}Lbl": Label 'GST Use Cases';
        "{43F17130-4EA1-48FE-B1A8-716EE5DF7C16}Lbl": Label 'GST Use Cases';
        "{508FE302-0CAB-41B6-8C43-737EBE931312}Lbl": Label 'GST Use Cases';
        "{8D93354A-64E8-4DA5-A1A7-741A42B80B33}Lbl": Label 'GST Use Cases';
        "{8BB1C380-7CFE-4B49-82AD-78BBA652EB5C}Lbl": Label 'GST Use Cases';
        "{A622E949-C161-4AE2-B6DB-7D3C16E5D899}Lbl": Label 'GST Use Cases';
        "{6ADC0F4A-6D69-4BAE-A94F-7DC0889758DC}Lbl": Label 'GST Use Cases';
        "{AE6444ED-20D1-4E69-A69C-7DCAEC9C4738}Lbl": Label 'GST Use Cases';
        "{0F354915-7E17-421B-87D8-7E6C2716E173}Lbl": Label 'GST Use Cases';
        "{C63F1B6C-96EE-41CB-879B-801CE9C734A6}Lbl": Label 'GST Use Cases';
        "{826B72ED-5C21-45CA-A966-8443C38B768A}Lbl": Label 'GST Use Cases';
        "{423BECDD-68DC-4541-9047-8F6B797709E5}Lbl": Label 'GST Use Cases';
        "{7D571F8D-B6A0-47E0-B80F-9AC703DF1D3B}Lbl": Label 'GST Use Cases';
        "{2EA01E14-807E-4CC7-8494-9EAAFBA21709}Lbl": Label 'GST Use Cases';
        "{DEEB69C8-EDAA-4A5A-875E-A20DA52008BC}Lbl": Label 'GST Use Cases';
        "{C9822271-8F51-46B7-B4BD-A2B424B1699B}Lbl": Label 'GST Use Cases';
        "{CEAE9F6C-7E67-4347-9E66-A9C6C54E4ECE}Lbl": Label 'GST Use Cases';
        "{ED1E0A5D-C364-4F36-847E-AAE263B34185}Lbl": Label 'GST Use Cases';
        "{3B82DBC4-FAAE-477D-892C-AD82ECDFEF7E}Lbl": Label 'GST Use Cases';
        "{75A11E67-E9DF-446F-974A-AE9F91D8EA1C}Lbl": Label 'GST Use Cases';
        "{C724AA5A-92F2-4965-957B-C43EEACAABE6}Lbl": Label 'GST Use Cases';
        "{39808C8A-4131-4B49-BF1D-D8FA64667B3C}Lbl": Label 'GST Use Cases';
        "{71ED6108-7E6C-42E3-BEC8-DF9AD0C7A27E}Lbl": Label 'GST Use Cases';
        "{3D30F63D-D6C1-4B1B-ACFD-E252FAB190E2}Lbl": Label 'GST Use Cases';
        "{DE898176-3602-4CBD-BF29-EAF4A9C03987}Lbl": Label 'GST Use Cases';
        "{68FE3FB0-9F3C-44A6-9686-F37192B1A371}Lbl": Label 'GST Use Cases';
        "{535A4B2C-EEA4-4267-8638-F57DE9153FDD}Lbl": Label 'GST Use Cases';
        "{A79DCE33-C753-4680-A6A3-F824608702B1}Lbl": Label 'GST Use Cases';
        "{F7192A60-5739-4B72-AB1D-FB48ED3EE0F9}Lbl": Label 'GST Use Cases';
        "{F748E0D1-BC76-4D68-8CBD-FF4189DC3517}Lbl": Label 'GST Use Cases';
        "{37EFA642-056C-45E8-974E-6B41B335FC81}Lbl": Label 'GST Use Cases';
        "{DE8006B8-CF9F-474A-AE29-C7903A148261}Lbl": Label 'GST Use Cases';
        "{631DEFA0-165E-4BDC-8F8A-AB2A88DF90AD}Lbl": Label 'GST Use Cases';
    begin
        Handled := true;

        case CaseID of
            '{6F2DE875-4569-41DB-A28E-021E4D00378A}':
                exit("{6F2DE875-4569-41DB-A28E-021E4D00378A}Lbl");
            '{8D7FD8C3-FCB1-4968-8FD6-08181778EC29}':
                exit("{8D7FD8C3-FCB1-4968-8FD6-08181778EC29}Lbl");
            '{EFF1E5F5-6CC1-414D-BD1F-1095D42F9A4A}':
                exit("{EFF1E5F5-6CC1-414D-BD1F-1095D42F9A4A}Lbl");
            '{12089FA0-9627-4C6F-B855-112FE6FFAC49}':
                exit("{12089FA0-9627-4C6F-B855-112FE6FFAC49}Lbl");
            '{231587B2-D0BD-4362-9A3B-11839F7BB326}':
                exit("{231587B2-D0BD-4362-9A3B-11839F7BB326}Lbl");
            '{E1914856-FF7A-4B3A-99D5-17190CE10C27}':
                exit("{E1914856-FF7A-4B3A-99D5-17190CE10C27}Lbl");
            '{B4A44DCF-6090-4813-9C09-193AB1A09B93}':
                exit("{B4A44DCF-6090-4813-9C09-193AB1A09B93}Lbl");
            '{FD3380A2-217C-4059-A344-1D832B755088}':
                exit("{FD3380A2-217C-4059-A344-1D832B755088}Lbl");
            '{812C7B77-0622-4E71-9F4E-261C3874A680}':
                exit("{812C7B77-0622-4E71-9F4E-261C3874A680}Lbl");
            '{FBD319E5-BDFD-43E8-B9EB-275F01FA6A40}':
                exit("{FBD319E5-BDFD-43E8-B9EB-275F01FA6A40}Lbl");
            '{DF123FC7-B145-43CA-85DC-287F940778FC}':
                exit("{DF123FC7-B145-43CA-85DC-287F940778FC}Lbl");
            '{9B4E1225-00F2-4467-BA93-29AD1F2EBD46}':
                exit("{9B4E1225-00F2-4467-BA93-29AD1F2EBD46}Lbl");
            '{C08A9FD5-5ECC-4BB5-8A19-345060822129}':
                exit("{C08A9FD5-5ECC-4BB5-8A19-345060822129}Lbl");
            '{3E8E1EDA-828E-40BE-8FD4-3456546F47A6}':
                exit("{3E8E1EDA-828E-40BE-8FD4-3456546F47A6}Lbl");
            '{1E087C72-9078-4C31-ABD5-38F01008E508}':
                exit("{1E087C72-9078-4C31-ABD5-38F01008E508}Lbl");
            '{272FFE9F-A7C9-4AF8-87DD-3EA53BA18511}':
                exit("{272FFE9F-A7C9-4AF8-87DD-3EA53BA18511}Lbl");
            '{9DB4ECE1-3397-4ADD-9EA8-40A8D82A6A9A}':
                exit("{9DB4ECE1-3397-4ADD-9EA8-40A8D82A6A9A}Lbl");
            '{3A6F385C-72E7-42C6-A696-47102B270402}':
                exit("{3A6F385C-72E7-42C6-A696-47102B270402}Lbl");
            '{F6F63738-94DD-4B0B-BAD6-4EC11668D327}':
                exit("{F6F63738-94DD-4B0B-BAD6-4EC11668D327}Lbl");
            '{7C64DCF3-718C-405E-A389-582FD1E33E5D}':
                exit("{7C64DCF3-718C-405E-A389-582FD1E33E5D}Lbl");
            '{6DEEF440-3A5B-4201-9D1B-59AC37AF4C36}':
                exit("{6DEEF440-3A5B-4201-9D1B-59AC37AF4C36}Lbl");
            '{33CD3931-0BA0-4358-B808-5C6378CAA489}':
                exit("{33CD3931-0BA0-4358-B808-5C6378CAA489}Lbl");
            '{725E8FB9-C4CC-42B7-B060-5E86614A8168}':
                exit("{725E8FB9-C4CC-42B7-B060-5E86614A8168}Lbl");
            '{CBDB09CC-FB6C-4475-89A3-62C04DADFA15}':
                exit("{CBDB09CC-FB6C-4475-89A3-62C04DADFA15}Lbl");
            '{F33121DD-68CB-423C-A98B-6FF10BD8CED7}':
                exit("{F33121DD-68CB-423C-A98B-6FF10BD8CED7}Lbl");
            '{43F17130-4EA1-48FE-B1A8-716EE5DF7C16}':
                exit("{43F17130-4EA1-48FE-B1A8-716EE5DF7C16}Lbl");
            '{508FE302-0CAB-41B6-8C43-737EBE931312}':
                exit("{508FE302-0CAB-41B6-8C43-737EBE931312}Lbl");
            '{8D93354A-64E8-4DA5-A1A7-741A42B80B33}':
                exit("{8D93354A-64E8-4DA5-A1A7-741A42B80B33}Lbl");
            '{8BB1C380-7CFE-4B49-82AD-78BBA652EB5C}':
                exit("{8BB1C380-7CFE-4B49-82AD-78BBA652EB5C}Lbl");
            '{A622E949-C161-4AE2-B6DB-7D3C16E5D899}':
                exit("{A622E949-C161-4AE2-B6DB-7D3C16E5D899}Lbl");
            '{6ADC0F4A-6D69-4BAE-A94F-7DC0889758DC}':
                exit("{6ADC0F4A-6D69-4BAE-A94F-7DC0889758DC}Lbl");
            '{AE6444ED-20D1-4E69-A69C-7DCAEC9C4738}':
                exit("{AE6444ED-20D1-4E69-A69C-7DCAEC9C4738}Lbl");
            '{0F354915-7E17-421B-87D8-7E6C2716E173}':
                exit("{0F354915-7E17-421B-87D8-7E6C2716E173}Lbl");
            '{C63F1B6C-96EE-41CB-879B-801CE9C734A6}':
                exit("{C63F1B6C-96EE-41CB-879B-801CE9C734A6}Lbl");
            '{826B72ED-5C21-45CA-A966-8443C38B768A}':
                exit("{826B72ED-5C21-45CA-A966-8443C38B768A}Lbl");
            '{423BECDD-68DC-4541-9047-8F6B797709E5}':
                exit("{423BECDD-68DC-4541-9047-8F6B797709E5}Lbl");
            '{7D571F8D-B6A0-47E0-B80F-9AC703DF1D3B}':
                exit("{7D571F8D-B6A0-47E0-B80F-9AC703DF1D3B}Lbl");
            '{2EA01E14-807E-4CC7-8494-9EAAFBA21709}':
                exit("{2EA01E14-807E-4CC7-8494-9EAAFBA21709}Lbl");
            '{DEEB69C8-EDAA-4A5A-875E-A20DA52008BC}':
                exit("{DEEB69C8-EDAA-4A5A-875E-A20DA52008BC}Lbl");
            '{C9822271-8F51-46B7-B4BD-A2B424B1699B}':
                exit("{C9822271-8F51-46B7-B4BD-A2B424B1699B}Lbl");
            '{CEAE9F6C-7E67-4347-9E66-A9C6C54E4ECE}':
                exit("{CEAE9F6C-7E67-4347-9E66-A9C6C54E4ECE}Lbl");
            '{ED1E0A5D-C364-4F36-847E-AAE263B34185}':
                exit("{ED1E0A5D-C364-4F36-847E-AAE263B34185}Lbl");
            '{3B82DBC4-FAAE-477D-892C-AD82ECDFEF7E}':
                exit("{3B82DBC4-FAAE-477D-892C-AD82ECDFEF7E}Lbl");
            '{75A11E67-E9DF-446F-974A-AE9F91D8EA1C}':
                exit("{75A11E67-E9DF-446F-974A-AE9F91D8EA1C}Lbl");
            '{C724AA5A-92F2-4965-957B-C43EEACAABE6}':
                exit("{C724AA5A-92F2-4965-957B-C43EEACAABE6}Lbl");
            '{39808C8A-4131-4B49-BF1D-D8FA64667B3C}':
                exit("{39808C8A-4131-4B49-BF1D-D8FA64667B3C}Lbl");
            '{71ED6108-7E6C-42E3-BEC8-DF9AD0C7A27E}':
                exit("{71ED6108-7E6C-42E3-BEC8-DF9AD0C7A27E}Lbl");
            '{3D30F63D-D6C1-4B1B-ACFD-E252FAB190E2}':
                exit("{3D30F63D-D6C1-4B1B-ACFD-E252FAB190E2}Lbl");
            '{DE898176-3602-4CBD-BF29-EAF4A9C03987}':
                exit("{DE898176-3602-4CBD-BF29-EAF4A9C03987}Lbl");
            '{68FE3FB0-9F3C-44A6-9686-F37192B1A371}':
                exit("{68FE3FB0-9F3C-44A6-9686-F37192B1A371}Lbl");
            '{535A4B2C-EEA4-4267-8638-F57DE9153FDD}':
                exit("{535A4B2C-EEA4-4267-8638-F57DE9153FDD}Lbl");
            '{A79DCE33-C753-4680-A6A3-F824608702B1}':
                exit("{A79DCE33-C753-4680-A6A3-F824608702B1}Lbl");
            '{F7192A60-5739-4B72-AB1D-FB48ED3EE0F9}':
                exit("{F7192A60-5739-4B72-AB1D-FB48ED3EE0F9}Lbl");
            '{F748E0D1-BC76-4D68-8CBD-FF4189DC3517}':
                exit("{F748E0D1-BC76-4D68-8CBD-FF4189DC3517}Lbl");
            '{37EFA642-056C-45E8-974E-6B41B335FC81}':
                exit("{37EFA642-056C-45E8-974E-6B41B335FC81}Lbl");
            '{DE8006B8-CF9F-474A-AE29-C7903A148261}':
                exit("{DE8006B8-CF9F-474A-AE29-C7903A148261}Lbl");
            '{631DEFA0-165E-4BDC-8F8A-AB2A88DF90AD}':
                exit("{631DEFA0-165E-4BDC-8F8A-AB2A88DF90AD}Lbl");
        end;

        Handled := false;
    end;
}
