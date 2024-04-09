// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxEngine.JsonExchange;

using Microsoft.Finance.GST.Base;

codeunit 18009 "Cess Use Case Setup"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Engine Assisted Setup", 'OnSetupUseCases', '', false, false)]
    local procedure OnSetupUseCases()
    var
        TaxJsonDeserialization: Codeunit "Tax Json Deserialization";
        CaseList: list of [Guid];
        CaseId: Guid;
    begin
        UpdateUseCaseList(CaseList);

        if not GuiAllowed then
            TaxJsonDeserialization.HideDialog(true);

        TaxJsonDeserialization.SkipVersionCheck(true);
        TaxJsonDeserialization.SkipUseCaseIndentation(true);
        foreach CaseId in CaseList do
            TaxJsonDeserialization.ImportUseCases(GetText(CaseId));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade GST Tax Config", 'OnUpgradeGSTUseCases', '', false, false)]
    local procedure OnUpgradeGSTUseCases(CaseID: Guid; var UseCaseConfig: Text; var IsHandled: Boolean)
    begin
        if IsHandled then
            exit;

        UseCaseConfig := GetText(CaseID);
        if UseCaseConfig <> '' then
            IsHandled := true;
    end;

    local procedure GetText(CaseId: Guid): Text
    var
        CessTaxTypeSetup: Codeunit "Cess Tax Type Setup";
        IsHandled: Boolean;
    begin
        exit(CessTaxTypeSetup.GetConfig(CaseId, IsHandled))
    end;

    local procedure UpdateUseCaseList(CaseList: list of [Guid])
    begin
        CaseList.Add('{6F2DE875-4569-41DB-A28E-021E4D00378A}');
        CaseList.Add('{8D7FD8C3-FCB1-4968-8FD6-08181778EC29}');
        CaseList.Add('{EFF1E5F5-6CC1-414D-BD1F-1095D42F9A4A}');
        CaseList.Add('{12089FA0-9627-4C6F-B855-112FE6FFAC49}');
        CaseList.Add('{231587B2-D0BD-4362-9A3B-11839F7BB326}');
        CaseList.Add('{E1914856-FF7A-4B3A-99D5-17190CE10C27}');
        CaseList.Add('{B4A44DCF-6090-4813-9C09-193AB1A09B93}');
        CaseList.Add('{FD3380A2-217C-4059-A344-1D832B755088}');
        CaseList.Add('{812C7B77-0622-4E71-9F4E-261C3874A680}');
        CaseList.Add('{FBD319E5-BDFD-43E8-B9EB-275F01FA6A40}');
        CaseList.Add('{DF123FC7-B145-43CA-85DC-287F940778FC}');
        CaseList.Add('{9B4E1225-00F2-4467-BA93-29AD1F2EBD46}');
        CaseList.Add('{C08A9FD5-5ECC-4BB5-8A19-345060822129}');
        CaseList.Add('{3E8E1EDA-828E-40BE-8FD4-3456546F47A6}');
        CaseList.Add('{1E087C72-9078-4C31-ABD5-38F01008E508}');
        CaseList.Add('{272FFE9F-A7C9-4AF8-87DD-3EA53BA18511}');
        CaseList.Add('{9DB4ECE1-3397-4ADD-9EA8-40A8D82A6A9A}');
        CaseList.Add('{3A6F385C-72E7-42C6-A696-47102B270402}');
        CaseList.Add('{F6F63738-94DD-4B0B-BAD6-4EC11668D327}');
        CaseList.Add('{7C64DCF3-718C-405E-A389-582FD1E33E5D}');
        CaseList.Add('{6DEEF440-3A5B-4201-9D1B-59AC37AF4C36}');
        CaseList.Add('{33CD3931-0BA0-4358-B808-5C6378CAA489}');
        CaseList.Add('{725E8FB9-C4CC-42B7-B060-5E86614A8168}');
        CaseList.Add('{CBDB09CC-FB6C-4475-89A3-62C04DADFA15}');
        CaseList.Add('{F33121DD-68CB-423C-A98B-6FF10BD8CED7}');
        CaseList.Add('{43F17130-4EA1-48FE-B1A8-716EE5DF7C16}');
        CaseList.Add('{508FE302-0CAB-41B6-8C43-737EBE931312}');
        CaseList.Add('{8D93354A-64E8-4DA5-A1A7-741A42B80B33}');
        CaseList.Add('{8BB1C380-7CFE-4B49-82AD-78BBA652EB5C}');
        CaseList.Add('{A622E949-C161-4AE2-B6DB-7D3C16E5D899}');
        CaseList.Add('{6ADC0F4A-6D69-4BAE-A94F-7DC0889758DC}');
        CaseList.Add('{AE6444ED-20D1-4E69-A69C-7DCAEC9C4738}');
        CaseList.Add('{0F354915-7E17-421B-87D8-7E6C2716E173}');
        CaseList.Add('{C63F1B6C-96EE-41CB-879B-801CE9C734A6}');
        CaseList.Add('{826B72ED-5C21-45CA-A966-8443C38B768A}');
        CaseList.Add('{423BECDD-68DC-4541-9047-8F6B797709E5}');
        CaseList.Add('{7D571F8D-B6A0-47E0-B80F-9AC703DF1D3B}');
        CaseList.Add('{2EA01E14-807E-4CC7-8494-9EAAFBA21709}');
        CaseList.Add('{DEEB69C8-EDAA-4A5A-875E-A20DA52008BC}');
        CaseList.Add('{C9822271-8F51-46B7-B4BD-A2B424B1699B}');
        CaseList.Add('{CEAE9F6C-7E67-4347-9E66-A9C6C54E4ECE}');
        CaseList.Add('{ED1E0A5D-C364-4F36-847E-AAE263B34185}');
        CaseList.Add('{3B82DBC4-FAAE-477D-892C-AD82ECDFEF7E}');
        CaseList.Add('{75A11E67-E9DF-446F-974A-AE9F91D8EA1C}');
        CaseList.Add('{C724AA5A-92F2-4965-957B-C43EEACAABE6}');
        CaseList.Add('{39808C8A-4131-4B49-BF1D-D8FA64667B3C}');
        CaseList.Add('{71ED6108-7E6C-42E3-BEC8-DF9AD0C7A27E}');
        CaseList.Add('{3D30F63D-D6C1-4B1B-ACFD-E252FAB190E2}');
        CaseList.Add('{DE898176-3602-4CBD-BF29-EAF4A9C03987}');
        CaseList.Add('{68FE3FB0-9F3C-44A6-9686-F37192B1A371}');
        CaseList.Add('{535A4B2C-EEA4-4267-8638-F57DE9153FDD}');
        CaseList.Add('{A79DCE33-C753-4680-A6A3-F824608702B1}');
        CaseList.Add('{F7192A60-5739-4B72-AB1D-FB48ED3EE0F9}');
        CaseList.Add('{F748E0D1-BC76-4D68-8CBD-FF4189DC3517}');
        CaseList.Add('{37EFA642-056C-45E8-974E-6B41B335FC81}');
        CaseList.Add('{DE8006B8-CF9F-474A-AE29-C7903A148261}');
        CaseList.Add('{631DEFA0-165E-4BDC-8F8A-AB2A88DF90AD}');
    end;
}
