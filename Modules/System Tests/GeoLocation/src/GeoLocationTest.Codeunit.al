// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 50104 "Geolocation Test"
{
    // [FEATURE] [Geolocation] 

    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";

    [Test]
    [Scope('OnPrem')]
    procedure TestIsGeolocationAvailable()
    var
        Geolocation: Page Geolocation;
        GeolocationTestLibrary: Codeunit "Geolocation Test Library";
    begin
        // [When] Geolocation test library subscribers are binded.
        BindSubscription(GeolocationTestLibrary);

        // [Then] The return value of IsAvailable is 'true'.
        Assert.IsTrue(Geolocation.IsAvailable(), 'The Geolocation is unavailable.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestHasGeolocationSuccess()
    var
        Geolocation: Page Geolocation;
        GeolocationTestLibrary: Codeunit "Geolocation Test Library";
    begin
        // [Given] Geolocation test library subscribers are binded.
        BindSubscription(GeolocationTestLibrary);

        // [When] The Geolocation page is run as modal.
        Geolocation.RunModal();

        // [Then] The Geolocation page has a geographical location.
        Assert.IsTrue(Geolocation.HasGeolocation(), 'The Geolocation page does not have a geographical location.');
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('LocationPageHandler')]
    procedure TestGetGeolocationSuccesss()
    var
        Geolocation: Page Geolocation;
        GeolocationTestLibrary: Codeunit "Geolocation Test Library";
        ActualLatitude: Decimal;
        ActualLongitude: Decimal;
        ExpectedLatitude: Decimal;
        ExpectedLongitude: Decimal;
    begin
        // [Given] Geolocation test library subscribers are binded.
        BindSubscription(GeolocationTestLibrary);

        // [When] The expected latitude and longitude are retrieved from the test library.
        GeolocationTestLibrary.GetMockGeolocation(ExpectedLatitude, ExpectedLongitude);

        // [When] The Geolocation page is run as modal.
        Geolocation.RunModal();

        // [When] The actual latitude and longitude are retrieved by invoking GetGeolocation on the Geolocation page.
        Geolocation.GetGeolocation(ActualLatitude, ActualLongitude);

        // [Then] The latitude is equal to the expected latitude.
        Assert.AreEqual(ExpectedLatitude, ActualLatitude, 'The latitude value is not the same as the expected latitude.');

        // [Then] The longitude is equal to the expected longitude.
        Assert.AreEqual(ExpectedLongitude, ActualLongitude, 'The longitude value is not the same as the expected longitude.');
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('LocationPageHandler')]
    procedure TestGetGeolocationStatusIsAvailable()
    var
        Geolocation: Page Geolocation;
        GeolocationTestLibrary: Codeunit "Geolocation Test Library";
    begin
        // [Given] Geolocation test library subscribers are binded.
        BindSubscription(GeolocationTestLibrary);

        // [When] The Geolocation page is run as modal.
        Geolocation.RunModal();

        // [Then] The status of the geographical location data is Available.
        Assert.AreEqual("Geolocation Status"::Available, Geolocation.GetGeolocationStatus(), 'The status of the geographical location data is not "Available".');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestGetGeolocationStatusWithoutOpeningPageIsNotAvailable()
    var
        Geolocation: Page Geolocation;
        GeolocationTestLibrary: Codeunit "Geolocation Test Library";
    begin
        // [Given] Geolocation test library subscribers are binded.
        BindSubscription(GeolocationTestLibrary);

        // [When] The Geolocation page has not been used.
        // [Then] The status of the geographical location data is Not Available.
        Assert.AreEqual("Geolocation Status"::"Not Available", Geolocation.GetGeolocationStatus(), 'The status of the geographical location data is not "Not Available".');
    end;


    [Test]
    [Scope('OnPrem')]
    procedure TestHasGeolocationWithoutOpeningPageIsFalse()
    var
        Geolocation: Page Geolocation;
        GeolocationTestLibrary: Codeunit "Geolocation Test Library";
    begin
        // [Given] Geolocation test library subscribers are binded.
        BindSubscription(GeolocationTestLibrary);

        // [When] The Geolocation page has not been used.
        // [Then] The Geolocation page does not contain geographical locations.
        Assert.IsFalse(Geolocation.HasGeolocation(), 'The Geolocation page has a location.');
    end;


    [Test]
    [Scope('OnPrem')]
    procedure TestGetGeolocationWithoutOpeningPageResultInError()
    var
        Geolocation: Page Geolocation;
        GeolocationTestLibrary: Codeunit "Geolocation Test Library";
        ActualLatitude: Decimal;
        ActualLongitude: Decimal;
    begin
        // [Given] Geolocation test library subscribers are binded.
        BindSubscription(GeolocationTestLibrary);

        // [When] GetGeolocation is invocked on the Geolocation page without running the page as modal before.
        asserterror Geolocation.GetGeolocation(ActualLatitude, ActualLongitude);

        // [Then] An error message specifies that data was not retrieved for the geographical location.
        Assert.ExpectedError('The geographical location data was not retrieved.');
    end;

    [ModalPageHandler]
    procedure LocationPageHandler(var GeolocationPage: TestPage Geolocation)
    begin
        // Do nothing
    end;

}