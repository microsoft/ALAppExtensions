// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TDS.TDSBase;

using Microsoft.Finance.TaxEngine.JsonExchange;

codeunit 18690 "TDS Tax Engine Setup"
{

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Engine Assisted Setup", 'OnSetupTaxTypes', '', false, false)]
    local procedure OnSetupTaxTypes()
    var
        TaxJsonDeSerializationImport: Codeunit "Tax Json Deserialization";
        ImportTDSUseCase: Codeunit "Import TDS Use Case";
        TaxEngineResourceHelper: Codeunit "Tax Engine Resource Helper";
        IStream: InStream;
        JsonText: Text;
    begin
        NavApp.GetResource(ImportTDSUseCase.GetResourceForTaxType('TDS'), IStream);

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

        Codeunit.Run(Codeunit::"Import TDS Use Case");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Engine Assisted Setup", 'OnGetTaxTypeConfig', '', false, false)]
    local procedure OnGetTaxTypeConfig(TaxType: Code[20]; var ConfigText: Text; var IsHandled: Boolean)
    var
        TDSTaxTypes: Codeunit "TDS Tax Types";
        TDSTaxTypeLbl: Label 'TDS';
    begin
        if IsHandled then
            exit;

        if TaxType = TDSTaxTypeLbl then begin
            ConfigText := TDSTaxTypes.GetText();
            IsHandled := true;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TDS Upgrade Subscribers", 'OnGetUpgradedTaxTypeConfig', '', false, false)]
    local procedure OnGetUpgradedTaxTypeConfig(TaxType: Code[20]; var ConfigText: Text; var IsHandled: Boolean)
    var
        TDSTaxTypeData: Codeunit "TDS Tax Types";
        TDSTaxTypeLbl: Label 'TDS';
    begin
        if IsHandled then
            exit;

        if TaxType = TDSTaxTypeLbl then begin
            ConfigText := TDSTaxTypeData.GetText();
            IsHandled := true;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TDS Upgrade Subscribers", 'OnGetUpgradedUseCaseConfig', '', false, false)]
    local procedure OnGetTDSConfig(CaseID: Guid; var IsHandled: Boolean; var Configtext: Text)
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
        ImportTDSUseCase: Codeunit "Import TDS Use Case";
        FolderName: Text;
    begin
        Handled := true;

        FolderName := ImportTDSUseCase.GetResourceForUseCase('TDS');

        if ImportTDSUseCase.FindBCAppResourceFile(FolderName, CaseID) then
            exit(ImportTDSUseCase.GetConfigJsonText(CaseID, FolderName));

        Handled := false;
    end;
}
