// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Base;

using Microsoft.Finance.TaxBase;
using Microsoft.Finance.TaxEngine.JsonExchange;
using Microsoft.Finance.TaxEngine.TaxTypeHandler;

codeunit 18016 "Upgrade GST Tax Config"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    var
        TaxType: Record "Tax Type";
        TaxEngineAssistedSetup: Codeunit "Tax Engine Assisted Setup";
    begin
        if TaxType.IsEmpty() then
            exit;

        GSTTaxConfiguration.GetMsTaxTypes();
        GSTTaxConfiguration.GetMsUseCases();
        UpgradeUseCaseTree();

        TaxEngineAssistedSetup.PushTaxEngineNotifications();
    end;

    local procedure UpgradeUseCaseTree()
    var
        TaxBaseTaxEngineSetup: Codeunit "Tax Base Tax Engine Setup";
    begin
        TaxBaseTaxEngineSetup.UpgradeUseCaseTree();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpgradeGSTUseCases(CaseID: Guid; var UseCaseConfig: Text; var IsHandled: Boolean)
    begin
    end;

    var
        GSTTaxConfiguration: Codeunit "GST Tax Configuration";
}
