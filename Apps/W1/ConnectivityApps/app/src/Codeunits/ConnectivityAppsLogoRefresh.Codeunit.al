// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#pragma warning disable AA0247

codeunit 20355 "Connectivity Apps Logo Refresh"
{
    Access = Internal;
    Permissions = tabledata "Connectivity App Logo" = RIMD;

    trigger OnRun()
    begin
        RefreshConnectivityAppLogos();
    end;

    local procedure RefreshConnectivityAppLogos()
    var
        ConnectivityAppLogo: Record "Connectivity App Logo";
        ConnectivityAppsLogoMgt: Codeunit "Connectivity Apps Logo Mgt.";
    begin
        ConnectivityAppLogo.SetFilter("Expiry Date", '<%1', CurrentDateTime());
        if ConnectivityAppLogo.FindSet() then
            repeat
                ConnectivityAppsLogoMgt.RefreshLogoFromAppSource(ConnectivityAppLogo);
            until ConnectivityAppLogo.Next() = 0;
    end;
}
