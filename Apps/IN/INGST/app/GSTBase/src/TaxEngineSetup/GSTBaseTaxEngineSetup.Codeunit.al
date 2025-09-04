// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxEngine.JsonExchange;

#if not CLEAN27
using Microsoft.Finance.GST.Base;
#endif
codeunit 18004 "GST Base Tax Engine Setup"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Engine Assisted Setup", 'OnSetupTaxTypes', '', false, false)]
    local procedure OnSetupTaxTypes()
    var
        TaxJsonDeserialization: Codeunit "Tax Json Deserialization";
        ImportGSTUseCase: Codeunit "Import GST Use Case";
        TaxEngineResourceHelper: Codeunit "Tax Engine Resource Helper";
        IStream: InStream;
        JsonText: Text;
    begin
        NavApp.GetResource(ImportGSTUseCase.GetResourceForTaxType(GSTResFileLbl), IStream);

        JsonText := TaxEngineResourceHelper.ReadJsonFromStream(IStream);
        TaxJsonDeserialization.HideDialog(true);
        TaxJsonDeserialization.SkipVersionCheck(true);
        TaxJsonDeserialization.ImportTaxTypes(JsonText);
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
        ImportGSTUseCase: Codeunit "Import GST Use Case";
    begin
        if not GuiAllowed then
            TaxJsonDeserialization.HideDialog(true);

        ImportGSTUseCase.ImportUseCases(ImportGSTUseCase.GetResourceForUseCase(GSTResFileLbl));
    end;

#if not CLEAN27
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade GST Tax Config", 'OnUpgradeGSTUseCases', '', false, false)]
    local procedure OnUpgradeGSTUseCases(CaseID: Guid; var UseCaseConfig: Text; var IsHandled: Boolean)
    begin
        if IsHandled then
            exit;

        UseCaseConfig := GetText(CaseID);
        if UseCaseConfig <> '' then
            IsHandled := true;
    end;
#endif
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Engine Assisted Setup", 'OnGetTaxTypeConfig', '', false, false)]
    local procedure OnGetTaxTypeConfig(TaxType: Code[20]; var ConfigText: Text; var IsHandled: Boolean)
    var
        GSTTaxTypeData: Codeunit "GST Tax Type Data";
        GSTTaxTypeLbl: Label 'GST';
    begin
        if IsHandled then
            exit;

        if TaxType = GSTTaxTypeLbl then begin
            ConfigText := GSTTaxTypeData.GetText();
            IsHandled := true;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"GST Upgrade Subscribers", 'OnGetUpgradedTaxTypeConfig', '', false, false)]
    local procedure OnGetUpgradedTaxTypeConfig(TaxType: Code[20]; var ConfigText: Text; var IsHandled: Boolean)
    var
        GSTTaxTypeData: Codeunit "GST Tax Type Data";
        GSTTaxTypeLbl: Label 'GST';
    begin
        if IsHandled then
            exit;

        if TaxType = GSTTaxTypeLbl then begin
            ConfigText := GSTTaxTypeData.GetText();
            IsHandled := true;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"GST Upgrade Subscribers", 'OnGetUpgradedUseCaseConfig', '', false, false)]
    local procedure OnGetGSTConfig(CaseID: Guid; var IsHandled: Boolean; var Configtext: Text)
    begin
        Configtext := GetConfig(CaseID, IsHandled);
    end;

#if not CLEAN27
    local procedure GetText(CaseId: Guid): Text
    var
        IsHandled: Boolean;
    begin
        exit(GetConfig(CaseId, IsHandled))
    end;
#endif

    procedure GetConfig(CaseID: Guid; var Handled: Boolean): Text
    var
        ImportGSTUseCase: Codeunit "Import GST Use Case";
        FolderName: Text;
    begin
        Handled := true;

        FolderName := ImportGSTUseCase.GetResourceForUseCase(GSTResFileLbl);

        if ImportGSTUseCase.FindBCAppResourceFile(FolderName, CaseID) then
            exit(ImportGSTUseCase.GetConfigJsonText(CaseID, FolderName));

        Handled := false;
    end;

    var
        GSTResFileLbl: Label 'GST', MaxLength = 20;
}
