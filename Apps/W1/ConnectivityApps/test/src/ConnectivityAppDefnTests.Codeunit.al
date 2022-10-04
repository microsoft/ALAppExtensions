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
        TempApprovedForConnectivityAppCountry: Record "Connectivity App Country" temporary;
        TempWorksOnConnectivityAppCountry: Record "Connectivity App Country" temporary;
        Assert: Codeunit Assert;
    begin
        Initialize();

        // This test will ensure the data in the codeunit "Connectivity App Definitions" is parsed and loaded onto the temporary tables
        ConnectivityAppDefinitions.GetConnectivityAppDefinitions(TempConnectivityApp, TempApprovedForConnectivityAppCountry, TempWorksOnConnectivityAppCountry);
        Assert.RecordIsNotEmpty(TempConnectivityApp);
        Assert.RecordIsNotEmpty(TempApprovedForConnectivityAppCountry);
        Assert.RecordIsNotEmpty(TempWorksOnConnectivityAppCountry);
    end;

    [Test]
    procedure TestApprovedConnectivityAppShouldAlsoWorkOnACountry()
    var
        TempConnectivityApp: Record "Connectivity App" temporary;
        TempApprovedForConnectivityAppCountry: Record "Connectivity App Country" temporary;
        TempWorksOnConnectivityAppCountry: Record "Connectivity App Country" temporary;
    begin
        Initialize();

        ConnectivityAppDefinitions.GetConnectivityAppDefinitions(TempConnectivityApp, TempApprovedForConnectivityAppCountry, TempWorksOnConnectivityAppCountry);

        TempApprovedForConnectivityAppCountry.FindSet();
        repeat
            TempWorksOnConnectivityAppCountry.Get(TempApprovedForConnectivityAppCountry."App Id", TempApprovedForConnectivityAppCountry.Country);
        until TempApprovedForConnectivityAppCountry.Next() = 0;
    end;

    local procedure Initialize()
    begin
        ConnectivityAppDefinitions.ClearConnectivityAppDefinitions();
    end;
}