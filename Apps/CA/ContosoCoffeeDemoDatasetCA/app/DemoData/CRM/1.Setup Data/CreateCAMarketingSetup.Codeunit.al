// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.CRM;

using Microsoft.CRM.Setup;
using Microsoft.DemoData.Foundation;

codeunit 27074 "Create CA Marketing Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        UpdateMarketingSetup();
    end;

    local procedure UpdateMarketingSetup()
    var
        MarketingSetup: Record "Marketing Setup";
        CreateLanguage: Codeunit "Create Language";
    begin
        MarketingSetup.Get();

        MarketingSetup.Validate("Default Language Code", CreateLanguage.ENC());
        MarketingSetup.Validate("Mergefield Language ID", 4105);
        MarketingSetup.Modify(true);
    end;
}
