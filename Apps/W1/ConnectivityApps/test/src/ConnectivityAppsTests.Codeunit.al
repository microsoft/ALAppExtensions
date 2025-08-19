// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 139528 "Connectivity Apps Tests"
{
    Subtype = Test;
    RequiredTestIsolation = Disabled;
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

        // [GIVEN] Country Code on Company Information is set to CH
        CompanyInformation."Country/Region Code" := 'CH';
        CompanyInformation.Modify();

        // [WHEN] Connectivity Apps list is opened 
        ConnectivityApps.OpenView();

        // [THEN] The filter on the country on page is set to CH
        Assert.AreEqual(Format(Enum::"Conn. Apps Country/Region".Names().Get(Enum::"Conn. Apps Country/Region".Ordinals().IndexOf((Enum::"Conn. Apps Country/Region"::CH.AsInteger())))), ConnectivityApps.Filter.GetFilter("Country/Region"), 'Filter is not set');

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
        // [SCENARIO] Call to Load, loads Connectivity App buffer for every approved countries for app that works on the current country
        Initialize();

        // [GIVEN] Country Code on Company Information is set to NL
        CompanyInformation."Country/Region Code" := 'NL';
        CompanyInformation.Modify();

        BindSubscription(ConnectivityAppsLocationMock);

        // [WHEN] ConnectivityApps.Load is called
        ConnectivityApps.Load(TempConnectivityApp);

        // [THEN] The unfiltered buffer contains 4 entries
        Assert.RecordCount(TempConnectivityApp, 4);

        // [THEN] The filter on country NL returns 3 entries
        TempConnectivityApp.SetRange("Country/Region", Enum::"Conn. Apps Country/Region".Names().Get(Enum::"Conn. Apps Country/Region".Ordinals().IndexOf((Enum::"Conn. Apps Country/Region"::NL.AsInteger()))));
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

        // [GIVEN] Country Code on Company Information is set to CH
        CompanyInformation."Country/Region Code" := 'CH';
        CompanyInformation.Modify();

        BindSubscription(ConnectivityAppsLocationMock);

        // [WHEN] ConnectivityApps.Load is called
        ConnectivityApps.Load(TempConnectivityApp);

        // [THEN] The filter on the country on page is set to CH
        Assert.RecordCount(TempConnectivityApp, 2);
        TempConnectivityApp.SetRange("Country/Region", Enum::"Conn. Apps Country/Region".Names().Get(Enum::"Conn. Apps Country/Region".Ordinals().IndexOf((Enum::"Conn. Apps Country/Region"::CH.AsInteger()))));
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
        TempApprovedForConnectivityAppCountryOrRegion: Record "Conn. App Country/Region" temporary;
        TempWorksOnConnectivityAppLocalization: Record "Conn. App Country/Region" temporary;
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
        InsertConnectivityAppApprovedForCountryOrRegion(TempApprovedForConnectivityAppCountryOrRegion, TempConnectivityApp."App Id", Enum::"Conn. Apps Country/Region"::NL, "Connectivity Apps Category"::Banking);
        InsertConnectivityAppWorksOnLocalization(TempWorksOnConnectivityAppLocalization, TempConnectivityApp."App Id", Enum::"Connectivity Apps Localization"::NL, "Connectivity Apps Category"::Banking);

        // A2
        InsertConnectivityApps(TempConnectivityApp, CreateGuid(), 'A2', 'P2', CopyStr(LibraryRandom.RandText(200), 1, 200), CopyStr(LibraryRandom.RandText(100), 1, 100), CopyStr(LibraryRandom.RandText(100), 1, 100), "Connectivity Apps Category"::Banking);
        InsertConnectivityAppApprovedForCountryOrRegion(TempApprovedForConnectivityAppCountryOrRegion, TempConnectivityApp."App Id", Enum::"Conn. Apps Country/Region"::NO, "Connectivity Apps Category"::Banking);
        InsertConnectivityAppWorksOnLocalization(TempWorksOnConnectivityAppLocalization, TempConnectivityApp."App Id", Enum::"Connectivity Apps Localization"::NO, "Connectivity Apps Category"::Banking);
        // A3
        InsertConnectivityApps(TempConnectivityApp, CreateGuid(), 'A3', 'P3', CopyStr(LibraryRandom.RandText(200), 1, 200), CopyStr(LibraryRandom.RandText(100), 1, 100), CopyStr(LibraryRandom.RandText(100), 1, 100), "Connectivity Apps Category"::Banking);
        InsertConnectivityAppApprovedForCountryOrRegion(TempApprovedForConnectivityAppCountryOrRegion, TempConnectivityApp."App Id", Enum::"Conn. Apps Country/Region"::NL, "Connectivity Apps Category"::Banking);
        InsertConnectivityAppWorksOnLocalization(TempWorksOnConnectivityAppLocalization, TempConnectivityApp."App Id", Enum::"Connectivity Apps Localization"::NL, "Connectivity Apps Category"::Banking);
        InsertConnectivityAppWorksOnLocalization(TempWorksOnConnectivityAppLocalization, TempConnectivityApp."App Id", Enum::"Connectivity Apps Localization"::NO, "Connectivity Apps Category"::Banking);

        // A4
        InsertConnectivityApps(TempConnectivityApp, CreateGuid(), 'A4', 'P4', CopyStr(LibraryRandom.RandText(200), 1, 200), CopyStr(LibraryRandom.RandText(100), 1, 100), CopyStr(LibraryRandom.RandText(100), 1, 100), "Connectivity Apps Category"::Banking);
        InsertConnectivityAppApprovedForCountryOrRegion(TempApprovedForConnectivityAppCountryOrRegion, TempConnectivityApp."App Id", Enum::"Conn. Apps Country/Region"::NL, "Connectivity Apps Category"::Banking);
        InsertConnectivityAppApprovedForCountryOrRegion(TempApprovedForConnectivityAppCountryOrRegion, TempConnectivityApp."App Id", Enum::"Conn. Apps Country/Region"::NO, "Connectivity Apps Category"::Banking);
        InsertConnectivityAppWorksOnLocalization(TempWorksOnConnectivityAppLocalization, TempConnectivityApp."App Id", Enum::"Connectivity Apps Localization"::NL, "Connectivity Apps Category"::Banking);
        InsertConnectivityAppWorksOnLocalization(TempWorksOnConnectivityAppLocalization, TempConnectivityApp."App Id", Enum::"Connectivity Apps Localization"::NO, "Connectivity Apps Category"::Banking);
        InsertConnectivityAppWorksOnLocalization(TempWorksOnConnectivityAppLocalization, TempConnectivityApp."App Id", Enum::"Connectivity Apps Localization"::CH, "Connectivity Apps Category"::Banking);

        // A5
        InsertConnectivityApps(TempConnectivityApp, CreateGuid(), 'A5', 'P5', CopyStr(LibraryRandom.RandText(200), 1, 200), CopyStr(LibraryRandom.RandText(100), 1, 100), CopyStr(LibraryRandom.RandText(100), 1, 100), "Connectivity Apps Category"::Banking);
        InsertConnectivityAppApprovedForCountryOrRegion(TempApprovedForConnectivityAppCountryOrRegion, TempConnectivityApp."App Id", Enum::"Conn. Apps Country/Region"::DK, "Connectivity Apps Category"::Banking);
        InsertConnectivityAppApprovedForCountryOrRegion(TempApprovedForConnectivityAppCountryOrRegion, TempConnectivityApp."App Id", Enum::"Conn. Apps Country/Region"::NO, "Connectivity Apps Category"::Banking);
        InsertConnectivityAppWorksOnLocalization(TempWorksOnConnectivityAppLocalization, TempConnectivityApp."App Id", Enum::"Connectivity Apps Localization"::DK, "Connectivity Apps Category"::Banking);
        InsertConnectivityAppWorksOnLocalization(TempWorksOnConnectivityAppLocalization, TempConnectivityApp."App Id", Enum::"Connectivity Apps Localization"::NO, "Connectivity Apps Category"::Banking);

        ConnectivityAppDefinitions.ClearConnectivityAppDefinitions();
        ConnectivityAppDefinitions.SetConnectivityAppDefinitions(TempConnectivityApp, TempApprovedForConnectivityAppCountryOrRegion, TempWorksOnConnectivityAppLocalization);
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

    local procedure InsertConnectivityAppApprovedForCountryOrRegion(var ConnectivityAppCountryOrRegion: Record "Conn. App Country/Region"; AppId: Guid; ConnAppsSupportedCountryOrRegion: Enum "Conn. Apps Country/Region"; AppCategory: Enum "Connectivity Apps Category")
    begin
        ConnectivityAppCountryOrRegion.Init();
        ConnectivityAppCountryOrRegion."App Id" := AppId;
        ConnectivityAppCountryOrRegion."Country/Region" := ConnAppsSupportedCountryOrRegion;
        ConnectivityAppCountryOrRegion.Category := AppCategory;
        if ConnectivityAppCountryOrRegion.Insert() then;
    end;

    local procedure InsertConnectivityAppWorksOnLocalization(var ConnectivityAppLocalization: Record "Conn. App Country/Region"; AppId: Guid; ConnAppsSupportedLocalization: Enum "Connectivity Apps Localization"; AppCategory: Enum "Connectivity Apps Category")
    begin
        ConnectivityAppLocalization.Init();
        ConnectivityAppLocalization."App Id" := AppId;
        ConnectivityAppLocalization.Localization := ConnAppsSupportedLocalization;
        ConnectivityAppLocalization.Category := AppCategory;
        if ConnectivityAppLocalization.Insert() then;
    end;
}
