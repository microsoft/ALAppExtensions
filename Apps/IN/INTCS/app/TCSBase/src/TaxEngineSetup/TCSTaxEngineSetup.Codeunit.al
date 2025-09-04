// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TCS.TCSBase;

using Microsoft.Finance.TaxEngine.JsonExchange;

codeunit 18810 "TCS Tax Engine Setup"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Engine Assisted Setup", 'OnSetupTaxTypes', '', false, false)]
    local procedure OnSetupTaxTypes()
    var
        TaxJsonDeSerializationImport: Codeunit "Tax Json Deserialization";
        ImportTCSUseCase: Codeunit "Import TCS Use Case";
        TaxEngineResourceHelper: Codeunit "Tax Engine Resource Helper";
        IStream: InStream;
        JsonText: Text;
    begin
        NavApp.GetResource(ImportTCSUseCase.GetResourceForTaxType('TCS'), IStream);

        JsonText := TaxEngineResourceHelper.ReadJsonFromStream(IStream);
        TaxJsonDeSerializationImport.SkipVersionCheck(true);
        TaxJsonDeSerializationImport.SkipUseCaseIndentation(true);
        TaxJsonDeSerializationImport.ImportTaxTypes(JsonText);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Engine Assisted Setup", 'OnGetUseCaseConfig', '', false, false)]
    local procedure OnGetUseCaseConfig(CaseID: Guid; var ConfigText: Text; var IsHandled: Boolean)
    begin
        if IsHandled then
            exit;

        ConfigText := GetConfig(CaseID, IsHandled);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Engine Assisted Setup", 'OnSetupUseCases', '', false, false)]
    local procedure OnSetupUseCases()
    var
        TaxJsonDeserialization: Codeunit "Tax Json Deserialization";
    begin
        if not GuiAllowed then
            TaxJsonDeserialization.HideDialog(true);

        Codeunit.Run(Codeunit::"Import TCS Use Case");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Engine Assisted Setup", 'OnGetTaxTypeConfig', '', false, false)]
    local procedure OnGetTaxTypeConfig(TaxType: Code[20]; var ConfigText: Text; var IsHandled: Boolean)
    var
        TCSTaxType: Codeunit "TCS Tax Type";
        TCSTaxTypeLbl: Label 'TCS';
    begin
        if IsHandled then
            exit;

        if TaxType = TCSTaxTypeLbl then begin
            ConfigText := TCSTaxType.GetText();
            IsHandled := true;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TCS Upgrade Subscribers", 'OnGetUpgradedTaxTypeConfig', '', false, false)]
    local procedure OnGetUpgradedTaxTypeConfig(TaxType: Code[20]; var ConfigText: Text; var IsHandled: Boolean)
    var
        TCSTaxTypeData: Codeunit "TCS Tax Type";
        TCSTaxTypeLbl: Label 'TCS';
    begin
        if IsHandled then
            exit;

        if TaxType = TCSTaxTypeLbl then begin
            ConfigText := TCSTaxTypeData.GetText();
            IsHandled := true;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TCS Upgrade Subscribers", 'OnGetUpgradedUseCaseConfig', '', false, false)]
    local procedure OnGetTCSConfig(CaseID: Guid; var IsHandled: Boolean; var Configtext: Text)
    begin
        Configtext := GetConfig(CaseID, IsHandled);
    end;


    procedure GetText(CaseId: Guid): Text
    var
        IsHandled: Boolean;
    begin
        exit(GetConfig(CaseId, IsHandled))
    end;

    local procedure GetConfig(CaseID: Guid; var Handled: Boolean): Text
    var
        ImportTCSUseCase: Codeunit "Import TCS Use Case";
        FolderName: Text;
    begin
        Handled := true;

        FolderName := ImportTCSUseCase.GetResourceForUseCase('TCS');
        if ImportTCSUseCase.FindBCAppResourceFile(FolderName, CaseID) then
            exit(ImportTCSUseCase.GetConfigJsonText(CaseID, FolderName));

        Handled := false;
    end;
}
