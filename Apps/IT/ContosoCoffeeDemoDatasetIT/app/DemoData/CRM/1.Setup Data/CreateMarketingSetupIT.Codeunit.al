// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.CRM;

using Microsoft.CRM.Setup;

codeunit 12206 "Create Marketing Setup IT"
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
    begin
        MarketingSetup.Get();

        MarketingSetup.Validate("Mergefield Language ID", 1040);
        MarketingSetup.Modify(true);
    end;
}
