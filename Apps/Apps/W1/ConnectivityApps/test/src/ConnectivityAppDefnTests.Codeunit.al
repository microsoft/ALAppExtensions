// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 139529 "Connectivity App Defn. Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        ConnectivityAppDefinitions: Codeunit "Connectivity App Definitions";

    [Test]
    procedure TestGetConnectivityAppDefinitions()
    var
        TempConnectivityApp: Record "Connectivity App" temporary;
        TempApprovedForConnectivityAppCountryOrRegion: Record "Conn. App Country/Region" temporary;
        TempWorksOnConnectivityAppLocalization: Record "Conn. App Country/Region" temporary;
        Assert: Codeunit Assert;
    begin
        Initialize();

        // This test will ensure the data in the codeunit "Connectivity App Definitions" is parsed and loaded onto the temporary tables
        ConnectivityAppDefinitions.GetConnectivityAppDefinitions(TempConnectivityApp, TempApprovedForConnectivityAppCountryOrRegion, TempWorksOnConnectivityAppLocalization);
        Assert.RecordIsNotEmpty(TempConnectivityApp);
        Assert.RecordIsNotEmpty(TempApprovedForConnectivityAppCountryOrRegion);
        Assert.RecordIsNotEmpty(TempWorksOnConnectivityAppLocalization);
    end;

    [Test]
    procedure TestApprovedConnectivityAppShouldAlsoWorkOnACountry()
    var
        TempConnectivityApp: Record "Connectivity App" temporary;
        TempApprovedForConnectivityAppCountryOrRegion: Record "Conn. App Country/Region" temporary;
        TempWorksOnConnectivityAppLocalization: Record "Conn. App Country/Region" temporary;
    begin
        Initialize();

        ConnectivityAppDefinitions.GetConnectivityAppDefinitions(TempConnectivityApp, TempApprovedForConnectivityAppCountryOrRegion, TempWorksOnConnectivityAppLocalization);

        if TempWorksOnConnectivityAppLocalization.FindSet() then
            repeat
                TempApprovedForConnectivityAppCountryOrRegion.Get(TempApprovedForConnectivityAppCountryOrRegion."App Id", TempApprovedForConnectivityAppCountryOrRegion."Country/Region");
            until TempWorksOnConnectivityAppLocalization.Next() = 0;
    end;

    local procedure Initialize()
    begin
        ConnectivityAppDefinitions.ClearConnectivityAppDefinitions();
    end;
}