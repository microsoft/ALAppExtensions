// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 139528 "Connectivity Apps Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        ConnectivityAppDefinitions: Codeunit "Connectivity App Definitions";
        Assert: Codeunit Assert;
        LibraryRandom: Codeunit "Library - Random";
        IsInitialized: Boolean;

    [Test]
    procedure EmptyPageShownWhenThereAreNoApprovedAppForACountry()
    var
        CompanyInformation: Record "Company Information";
        ConnectivityApps: TestPage "Connectivity Apps";
    begin
        // [SCENARIO] Connectivity Apps list page is filtered and empty when there are no approved apps for a country
        Initialize();

        // [GIVEN] Country Code on Company Inormation is set to CH
        CompanyInformation."Country/Region Code" := 'CH';
        CompanyInformation.Modify();

        // [WHEN] Connectivity Apps list is opened 
        ConnectivityApps.OpenView();

        // [THEN] The filter on the country on page is set to CH
        Assert.AreEqual(Format("Conn. Apps Supported Country".Names().Get("Conn. Apps Supported Country".Ordinals().IndexOf(("Conn. Apps Supported Country"::CH.AsInteger())))), ConnectivityApps.Filter.GetFilter(Country), 'Filter is not set');

        // [THEN] The page is empty
        Assert.IsFalse(ConnectivityApps.First(), '');
        ConnectivityApps.Name.AssertEquals('');
    end;

    [Test]
    procedure LoadBuildsConnectivityBufferBasedOnApprovedForSetup()
    var
        CompanyInformation: Record "Company Information";
        TempConnectivityApp: Record "Connectivity App" temporary;
        ConnectivityApps: Codeunit "Connectivity Apps";
        ConnectivityAppsLocationMock: Codeunit "Connectivity Apps Loc. Mock";
    begin
        // [SCENARIO] Call to Load, loads Connectivity App buffer for every approved countires for app that works on the current country
        Initialize();

        // [GIVEN] Country Code on Company Inormation is set to NL
        CompanyInformation."Country/Region Code" := 'NL';
        CompanyInformation.Modify();

        BindSubscription(ConnectivityAppsLocationMock);

        // [WHEN] ConnectivityApps.Load is called
        ConnectivityApps.Load(TempConnectivityApp);

        // [THEN] The unfiltered buffer contains 4 entries
        Assert.RecordCount(TempConnectivityApp, 4);
        // [THEN] The filter on country NL returns 3 entries
        TempConnectivityApp.SetRange(Country, "Conn. Apps Supported Country".Names().Get("Conn. Apps Supported Country".Ordinals().IndexOf(("Conn. Apps Supported Country"::NL.AsInteger()))));
        Assert.RecordCount(TempConnectivityApp, 3);
    end;

    [Test]
    procedure EntriesForApprovedCountriesCreatedForAppThatIsNotApprovedButWorksOnCurrentCountry()
    var
        CompanyInformation: Record "Company Information";
        TempConnectivityApp: Record "Connectivity App" temporary;
        ConnectivityApps: Codeunit "Connectivity Apps";
        ConnectivityAppsLocationMock: Codeunit "Connectivity Apps Loc. Mock";
    begin
        // [SCENARIO] Call to Load, loads Connectivity App buffer for every approved countires for app that works on the current country
        Initialize();

        // [GIVEN] Country Code on Company Inormation is set to CH
        CompanyInformation."Country/Region Code" := 'CH';
        CompanyInformation.Modify();

        BindSubscription(ConnectivityAppsLocationMock);

        // [WHEN] ConnectivityApps.Load is called
        ConnectivityApps.Load(TempConnectivityApp);

        // [THEN] The filter on the country on page is set to CH
        Assert.RecordCount(TempConnectivityApp, 2);
        TempConnectivityApp.SetRange(Country, "Conn. Apps Supported Country".Names().Get("Conn. Apps Supported Country".Ordinals().IndexOf(("Conn. Apps Supported Country"::CH.AsInteger()))));
        Assert.RecordCount(TempConnectivityApp, 0);
    end;

    local procedure Initialize()
    begin
        if IsInitialized then
            exit;

        SetupTestData();
        IsInitialized := true;
    end;

    procedure SetupTestData()
    var
        TempConnectivityApp: Record "Connectivity App" temporary;
        TempApprovedForConnectivityAppCountry: Record "Connectivity App Country" temporary;
        TempWorksOnConnectivityAppCountry: Record "Connectivity App Country" temporary;
    begin
        /*******************************************************************************************
        AppId       | App Name | App Description | Publisher | Category | Approved For   | Works On
        --------------------------------------------------------------------------------------------
        <Generated> | A1       | <Generated>     | P1        | Banking  | NL             | NL  
        <Generated> | A2       | <Generated>     | P2        | Banking  | NO             | NO  
        <Generated> | A3       | <Generated>     | P3        | Banking  | NL             | NL,NO  
        <Generated> | A4       | <Generated>     | P4        | Banking  | NL,NO          | NL,NO,CH  
        <Generated> | A5       | <Generated>     | P5        | Banking  | DK,NO          | DK,NO
        *******************************************************************************************/

        // A1
        InsertConnectivityApps(TempConnectivityApp, CreateGuid(), 'A1', 'P1', CopyStr(LibraryRandom.RandText(200), 1, 200), CopyStr(LibraryRandom.RandText(100), 1, 100), CopyStr(LibraryRandom.RandText(100), 1, 100), "Connectivity Apps Category"::Banking);
        InsertConnectivityAppCountry(TempApprovedForConnectivityAppCountry, TempConnectivityApp."App Id", "Conn. Apps Supported Country"::NL, "Connectivity Apps Category"::Banking);
        InsertConnectivityAppCountry(TempWorksOnConnectivityAppCountry, TempConnectivityApp."App Id", "Conn. Apps Supported Country"::NL, "Connectivity Apps Category"::Banking);

        // A2
        InsertConnectivityApps(TempConnectivityApp, CreateGuid(), 'A2', 'P2', CopyStr(LibraryRandom.RandText(200), 1, 200), CopyStr(LibraryRandom.RandText(100), 1, 100), CopyStr(LibraryRandom.RandText(100), 1, 100), "Connectivity Apps Category"::Banking);
        InsertConnectivityAppCountry(TempApprovedForConnectivityAppCountry, TempConnectivityApp."App Id", "Conn. Apps Supported Country"::NO, "Connectivity Apps Category"::Banking);
        InsertConnectivityAppCountry(TempWorksOnConnectivityAppCountry, TempConnectivityApp."App Id", "Conn. Apps Supported Country"::NO, "Connectivity Apps Category"::Banking);
        // A3
        InsertConnectivityApps(TempConnectivityApp, CreateGuid(), 'A3', 'P3', CopyStr(LibraryRandom.RandText(200), 1, 200), CopyStr(LibraryRandom.RandText(100), 1, 100), CopyStr(LibraryRandom.RandText(100), 1, 100), "Connectivity Apps Category"::Banking);
        InsertConnectivityAppCountry(TempApprovedForConnectivityAppCountry, TempConnectivityApp."App Id", "Conn. Apps Supported Country"::NL, "Connectivity Apps Category"::Banking);
        InsertConnectivityAppCountry(TempWorksOnConnectivityAppCountry, TempConnectivityApp."App Id", "Conn. Apps Supported Country"::NL, "Connectivity Apps Category"::Banking);
        InsertConnectivityAppCountry(TempWorksOnConnectivityAppCountry, TempConnectivityApp."App Id", "Conn. Apps Supported Country"::NO, "Connectivity Apps Category"::Banking);

        // A4
        InsertConnectivityApps(TempConnectivityApp, CreateGuid(), 'A4', 'P4', CopyStr(LibraryRandom.RandText(200), 1, 200), CopyStr(LibraryRandom.RandText(100), 1, 100), CopyStr(LibraryRandom.RandText(100), 1, 100), "Connectivity Apps Category"::Banking);
        InsertConnectivityAppCountry(TempApprovedForConnectivityAppCountry, TempConnectivityApp."App Id", "Conn. Apps Supported Country"::NL, "Connectivity Apps Category"::Banking);
        InsertConnectivityAppCountry(TempApprovedForConnectivityAppCountry, TempConnectivityApp."App Id", "Conn. Apps Supported Country"::NO, "Connectivity Apps Category"::Banking);
        InsertConnectivityAppCountry(TempWorksOnConnectivityAppCountry, TempConnectivityApp."App Id", "Conn. Apps Supported Country"::NL, "Connectivity Apps Category"::Banking);
        InsertConnectivityAppCountry(TempWorksOnConnectivityAppCountry, TempConnectivityApp."App Id", "Conn. Apps Supported Country"::NO, "Connectivity Apps Category"::Banking);
        InsertConnectivityAppCountry(TempWorksOnConnectivityAppCountry, TempConnectivityApp."App Id", "Conn. Apps Supported Country"::CH, "Connectivity Apps Category"::Banking);

        // A5
        InsertConnectivityApps(TempConnectivityApp, CreateGuid(), 'A5', 'P5', CopyStr(LibraryRandom.RandText(200), 1, 200), CopyStr(LibraryRandom.RandText(100), 1, 100), CopyStr(LibraryRandom.RandText(100), 1, 100), "Connectivity Apps Category"::Banking);
        InsertConnectivityAppCountry(TempApprovedForConnectivityAppCountry, TempConnectivityApp."App Id", "Conn. Apps Supported Country"::DK, "Connectivity Apps Category"::Banking);
        InsertConnectivityAppCountry(TempApprovedForConnectivityAppCountry, TempConnectivityApp."App Id", "Conn. Apps Supported Country"::NO, "Connectivity Apps Category"::Banking);
        InsertConnectivityAppCountry(TempWorksOnConnectivityAppCountry, TempConnectivityApp."App Id", "Conn. Apps Supported Country"::DK, "Connectivity Apps Category"::Banking);
        InsertConnectivityAppCountry(TempWorksOnConnectivityAppCountry, TempConnectivityApp."App Id", "Conn. Apps Supported Country"::NO, "Connectivity Apps Category"::Banking);

        ConnectivityAppDefinitions.ClearConnectivityAppDefinitions();
        ConnectivityAppDefinitions.SetConnectivityAppDefinitions(TempConnectivityApp, TempApprovedForConnectivityAppCountry, TempWorksOnConnectivityAppCountry);
    end;

    local procedure InsertConnectivityApps(var ConnectivityApp: Record "Connectivity App"; AppId: Guid; AppName: Text[1024]; AppPublisher: Text[250]; AppDescription: Text[2048]; AppProviderSupportURL: Text[250]; AppSourceUrl: Text[250]; AppCategory: Enum "Connectivity Apps Category")
    begin
        ConnectivityApp.Init();
        ConnectivityApp."App Id" := AppId;
        ConnectivityApp.Name := AppName;
        ConnectivityApp.Publisher := AppPublisher;
        ConnectivityApp.Description := AppDescription;
        ConnectivityApp."Provider Support URL" := AppProviderSupportURL;
        ConnectivityApp."AppSource URL" := AppSourceUrl;
        ConnectivityApp.Category := AppCategory;

        if ConnectivityApp.Insert() then;
    end;

    local procedure InsertConnectivityAppCountry(var ConnectivityAppCountry: Record "Connectivity App Country"; AppId: Guid; ConnAppsSupportedCountry: Enum "Conn. Apps Supported Country"; AppCategory: Enum "Connectivity Apps Category")
    begin
        ConnectivityAppCountry.Init();
        ConnectivityAppCountry."App Id" := AppId;
        ConnectivityAppCountry.Country := ConnAppsSupportedCountry;
        ConnectivityAppCountry.Category := AppCategory;
        if ConnectivityAppCountry.Insert() then;
    end;
}