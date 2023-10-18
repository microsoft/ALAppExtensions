// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxEngine.JsonExchange;

using Microsoft.Finance.GST.Base;

codeunit 18018 "GST Upgrade Subscribers"
{
    local procedure GetUseCaseConfigText(CaseID: Guid; var UseCaseUpdated: Boolean; var ConfigText: text)
    var
        IsHandled: Boolean;
    begin
        OnGetUpgradedUseCaseConfig(CaseId, IsHandled, ConfigText);
        UseCaseUpdated := IsHandled;
    end;

    local procedure GetTaxTypeConfigText(TaxType: Code[20]; var TaxTypeUpdated: Boolean; var ConfigText: text)
    var
        IsHandled: Boolean;
    begin
        OnGetUpgradedTaxTypeConfig(TaxType, IsHandled, ConfigText);
        TaxTypeUpdated := IsHandled;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Engine Assisted Setup", 'OnBeforeShowTaxConfigUpgradedNotification', '', false, false)]
    local procedure OnBeforeShowTaxConfigUpgradedNotification(var ShowUpgradeNotification: Boolean)
    begin
        if ShowUpgradeNotification then
            exit;

        ShowUpgradeNotification := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Engine Assisted Setup", 'OnGetUpdatedUseCaseConfig', '', false, false)]
    local procedure OnGetUpdatedUseCaseConfig(CaseID: Guid; MajorVersion: Integer; var ConfigText: Text; var UseCaseUpdated: Boolean)
    var
        GSTTaxConfiguration: Codeunit "GST Tax Configuration";
    begin
        GSTTaxConfiguration.GetMsUseCases();
        if not GSTTaxConfiguration.IsMSUseCase(CaseID) then
            exit;

        if MajorVersion < GSTTaxConfiguration.GetMSUseCaseVersion(CaseID) then
            GetUseCaseConfigText(CaseID, UseCaseUpdated, ConfigText);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Engine Assisted Setup", 'OnGetUpdatedTaxTypeConfig', '', false, false)]
    local procedure OnGetUpdatedTaxTypeConfig(TaxType: Code[20]; MajorVersion: Integer; var ConfigText: Text; var TaxTypeUpdated: Boolean)
    var
        GSTTaxConfiguration: Codeunit "GST Tax Configuration";
    begin
        GSTTaxConfiguration.GetMsTaxTypes();
        if not GSTTaxConfiguration.IsMSTaxType(TaxType) then
            exit;

        if MajorVersion < GSTTaxConfiguration.GetMSTaxTypeVersion(TaxType) then
            GetTaxTypeConfigText(TaxType, TaxTypeUpdated, ConfigText);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetUpgradedUseCaseConfig(CaseID: Guid; var IsHandled: Boolean; var Configtext: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetUpgradedTaxTypeConfig(TaxType: Code[20]; var IsHandled: Boolean; var Configtext: Text)
    begin
    end;

}
