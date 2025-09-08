// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxEngine.JsonExchange;

using Microsoft.Finance.GST.Base;

codeunit 18011 "GST TDS TCS Tax Type Setup"
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
        NavApp.GetResource(ImportGSTUseCase.GetResourceForTaxType(GSTTDSTCSResFileLbl), IStream);

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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Engine Assisted Setup", 'OnGetTaxTypeConfig', '', false, false)]
    local procedure OnGetTaxTypeConfig(TaxType: Code[20]; var ConfigText: Text; var IsHandled: Boolean)
    var
        GSTTDSTCSTaxTypeData: Codeunit "GST TDS TCS Tax Type Data";
        GSTTDSTCSTaxTypeLbl: Label 'GST TDS TCS';
    begin
        if IsHandled then
            exit;

        if TaxType = GSTTDSTCSTaxTypeLbl then begin
            ConfigText := GSTTDSTCSTaxTypeData.GetText();
            IsHandled := true;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"GST Upgrade Subscribers", 'OnGetUpgradedTaxTypeConfig', '', false, false)]
    local procedure OnGetUpgradedTaxTypeConfig(TaxType: Code[20]; var ConfigText: Text; var IsHandled: Boolean)
    var
        GSTTDSTCSTaxTypeData: Codeunit "GST TDS TCS Tax Type Data";
        GSTTDSTCSTaxTypeLbl: Label 'GST TDS TCS';
    begin
        if IsHandled then
            exit;

        if TaxType = GSTTDSTCSTaxTypeLbl then begin
            ConfigText := GSTTDSTCSTaxTypeData.GetText();
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
        ImportGSTUseCase: Codeunit "Import GST Use Case";
        FolderName: Text;
    begin
        Handled := true;

        FolderName := ImportGSTUseCase.GetResourceForUseCase(GSTTDSTCSResFileLbl);

        if ImportGSTUseCase.FindBCAppResourceFile(FolderName, CaseID) then
            exit(ImportGSTUseCase.GetConfigJsonText(CaseID, FolderName));

        Handled := false;
    end;

    var
        GSTTDSTCSResFileLbl: Label 'GSTTDSTCS', MaxLength = 20;
}
