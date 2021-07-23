// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 133101 "Data Out Of Geo. App Test"
{
    Subtype = Test;

    var
        DataOutOfGeoApp: Codeunit "Data Out Of Geo. App";
        EnvironmentInfoTestLibrary: Codeunit "Environment Info Test Library";
        LibraryAssert: Codeunit "Library Assert";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        PermissionsMock: Codeunit "Permissions Mock";
        RandAppTxt: Label '6e090e55-9b7e-465c-85bc-6831a3037cd5';
        GeoNotificationNewAppsMsg: Label 'This app may transfer data to other geographies than the current geography of your Dynamics 365 Business Central environment. This is to ensure proper functionality of the app.';


    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('InstallationPageHandler')]
    procedure NoOnPremNotificationsWithOutOfGeoAppTest()
    var
        MarketPlaceExtnDeployment: Page "Marketplace Extn Deployment";
    begin
        PermissionsMock.Set('Exten. Mgt. - Admin');

        LibraryVariableStorage.Clear();

        // [GIVEN] That the environment is onprem.
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(false);

        // [GIVEN] That there is an appid inserted as Out Of Geo.
        DataOutOfGeoApp.Add(RandAppTxt);

        // [WHEN] We open the extension installation page and we are installing the Out of Geo app.
        MarketPlaceExtnDeployment.SetAppID(RandAppTxt);
        MarketPlaceExtnDeployment.RunModal();

        // [THEN] No notifications are shown.
        LibraryVariableStorage.AssertEmpty();

        DataOutOfGeoApp.Remove(RandAppTxt);
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('InstallationPageHandler')]
    procedure NoOnPremNotificationsWithoutOutOfGeoAppTest()
    var
        MarketPlaceExtnDeployment: Page "Marketplace Extn Deployment";
    begin
        PermissionsMock.Set('Exten. Mgt. - Admin');

        LibraryVariableStorage.Clear();

        // [GIVEN] That the environment is onprem.
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(false);

        // [GIVEN] That there is no appid inserted as Out Of Geo.

        // [WHEN] We open the extension installation page and we are installing the Out of Geo app.
        MarketPlaceExtnDeployment.SetAppID(RandAppTxt);
        MarketPlaceExtnDeployment.RunModal();

        // [THEN] No notifications are shown.
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('InstallationPageHandler,NotificationHandler')]
    procedure SaaSNotificationsTest()
    var
        MarketPlaceExtnDeployment: Page "Marketplace Extn Deployment";
    begin
        PermissionsMock.Set('Exten. Mgt. - Admin');

        LibraryVariableStorage.Clear();

        // [GIVEN] That the environment is Saas
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);

        // [GIVEN] That there is an appid inserted as Out Of Geo.
        DataOutOfGeoApp.Add(RandAppTxt);

        // [WHEN] We open the extension installation page and we are installing the Out of Geo app.
        MarketPlaceExtnDeployment.SetAppID(RandAppTxt);
        MarketPlaceExtnDeployment.RunModal();

        // [THEN] A notification about data geo. is shown.
        LibraryAssert.AreEqual(GeoNotificationNewAppsMsg, LibraryVariableStorage.DequeueText(), 'Wrong Notification shown');

        // [GIVEN] the appid is removed from the module
        DataOutOfGeoApp.Remove(RandAppTxt);

        // [WHEN] We open the extension installation page and we are installing the Out of Geo app
        MarketPlaceExtnDeployment.RunModal();

        // [THEN] No notifications are shown
        LibraryVariableStorage.AssertEmpty();

        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(false);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure CurrentAppIsOutOfGeoSaaSTest()
    var
        ModuleInfo: ModuleInfo;
    begin
        PermissionsMock.Set('Exten. Mgt. - Admin');

        LibraryVariableStorage.Clear();
        NavApp.GetCurrentModuleInfo(ModuleInfo);

        // [GIVEN] That the environment is saas
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);

        // [GIVEN] that the current app is installed and has data out of geo.
        DataOutOfGeoApp.Add(ModuleInfo.Id);

        // [WHEN] Already Installed is called 
        // [THEN] The result will be true
        LibraryAssert.IsTrue(DataOutOfGeoApp.AlreadyInstalled(), 'There is a Data Out Of Geo app already installed');

        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(false);
        DataOutOfGeoApp.Remove(ModuleInfo.Id);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure NoOutOfGeoAppsCurrentlyInstalledTest()
    var
        ModuleInfo: ModuleInfo;
    begin
        PermissionsMock.Set('Exten. Mgt. - Admin');

        LibraryVariableStorage.Clear();
        NavApp.GetCurrentModuleInfo(ModuleInfo);

        // [GIVEN] That the environment is saas
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);

        // [GIVEN] that there are no Data Out Of Geo Apps
        // [WHEN] Already Installed is called 
        // [THEN] The result will be true
        LibraryAssert.IsFalse(DataOutOfGeoApp.AlreadyInstalled(), 'OnPrem this should always return false');
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(false);
    end;


    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure InstallationPageHandler(var MarketPlaceExtnDeployment: TestPage "Marketplace Extn Deployment")
    begin
        MarketPlaceExtnDeployment.OK().Invoke();
    end;

    [SendNotificationHandler]
    [Scope('OnPrem')]
    procedure NotificationHandler(var Notification: Notification): Boolean
    begin
        LibraryVariableStorage.Enqueue(Notification.Message);
    end;
}