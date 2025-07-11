// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TDS.TDSBase;

using Microsoft.Finance.TaxEngine.JsonExchange;

codeunit 18697 "TDS Upgrade Subscribers"
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
        TDSTaxConfiguration: Codeunit "TDS Tax Configuration";
    begin
        TDSTaxConfiguration.GetUseCases();
        if not TDSTaxConfiguration.IsMSUseCase(CaseID) then
            exit;

        if MajorVersion < TDSTaxConfiguration.GetMSUseCaseVersion(CaseID) then
            GetUseCaseConfigText(CaseID, UseCaseUpdated, ConfigText);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Engine Assisted Setup", 'OnGetUpdatedTaxTypeConfig', '', false, false)]
    local procedure OnGetUpdatedTaxTypeConfig(TaxType: Code[20]; MajorVersion: Integer; var ConfigText: Text; var TaxTypeUpdated: Boolean)
    var
        TDSTaxConfiguration: Codeunit "TDS Tax Configuration";
    begin
        TDSTaxConfiguration.GetTaxTypes();
        if not TDSTaxConfiguration.IsMSTaxType(TaxType) then
            exit;

        if MajorVersion < TDSTaxConfiguration.GetMSTaxTypeVersion(TaxType) then
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
