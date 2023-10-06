// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TCS.TCSBase;

using Microsoft.Finance.TaxEngine.TaxTypeHandler;
using Microsoft.Finance.TaxEngine.JsonExchange;

codeunit 18814 "Upgrade TCS Tax Config"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    var
        TaxType: Record "Tax Type";
        TaxEngineAssistedSetup: Codeunit "Tax Engine Assisted Setup";
    begin
        if TaxType.IsEmpty() then
            exit;

        TCSTaxConfiguration.GetTaxTypes();
        TCSTaxConfiguration.GetUseCases();
        TaxEngineAssistedSetup.PushTaxEngineNotifications();
    end;

    var
        TCSTaxConfiguration: Codeunit "TCS Tax Configuration";
}
