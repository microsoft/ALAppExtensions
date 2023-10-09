// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TDS.TDSBase;

using Microsoft.Finance.TaxEngine.TaxTypeHandler;
using Microsoft.Finance.TaxEngine.JsonExchange;

codeunit 18693 "Upgrade TDS Tax Config"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    var
        TaxType: Record "Tax Type";
        TaxEngineAssistedSetup: Codeunit "Tax Engine Assisted Setup";
    begin
        if TaxType.IsEmpty() then
            exit;

        TDSTaxConfiguration.GetTaxTypes();
        TDSTaxConfiguration.GetUseCases();
        TaxEngineAssistedSetup.PushTaxEngineNotifications();
    end;

    var
        TDSTaxConfiguration: Codeunit "TDS Tax Configuration";
}
