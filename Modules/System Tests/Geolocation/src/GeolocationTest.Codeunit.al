// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 135037 "Geolocation Test"
{
    // [FEATURE] [Geolocation] 

    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";

    [Test]
    [Scope('OnPrem')]
    procedure TestGeolocationIsAvailable()
    var
        Geolocation: Codeunit Geolocation;
        GeolocationTestLibrary: Codeunit "Geolocation Test Library";
    begin
        // [Given] Geolocation test library subscribers are bound.
        BindSubscription(GeolocationTestLibrary);

        // [When] Location availability is set to true in the Geolocation test library.
        GeolocationTestLibrary.SetLocationAvailability(true);

        // [Then] The return value of IsAvailable is 'true'.
        Assert.IsTrue(Geolocation.IsAvailable(), 'The Geolocation is unavailable.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestGeolocationIsNotAvailable()
    var
        Geolocation: Codeunit Geolocation;
        GeolocationTestLibrary: Codeunit "Geolocation Test Library";
    begin
        // [Given] Geolocation test library subscribers are bound.
        BindSubscription(GeolocationTestLibrary);

        // [When] Location availability is set to false in the Geolocation test library.
        GeolocationTestLibrary.SetLocationAvailability(false);

        // [Then] The return value of IsAvailable is 'false'.
        Assert.IsFalse(Geolocation.IsAvailable(), 'The Geolocation is available.');
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('LocationPageHandler')]
    procedure TestRequestGeolocationSuccess()
    var
        Geolocation: Codeunit Geolocation;
        GeolocationTestLibrary: Codeunit "Geolocation Test Library";
    begin
        // [Given] Geolocation test library subscribers are bound.
        BindSubscription(GeolocationTestLibrary);

        // [When] Location availability is set to true in the Geolocation test library.
        GeolocationTestLibrary.SetLocationAvailability(true);

        // [When] RequestGeolocation is invoked on the Geolocation object.
        // [Then] The Geolocation object has a geographical location.
        Assert.IsTrue(Geolocation.RequestGeolocation(), 'The Geolocation request was not successful.');
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('LocationPageHandler')]
    procedure TestHasGeolocationSuccess()
    var
        Geolocation: Codeunit Geolocation;
        GeolocationTestLibrary: Codeunit "Geolocation Test Library";
    begin
        // [Given] Geolocation test library subscribers are bound.
        BindSubscription(GeolocationTestLibrary);

        // [When] Location availability is set to true in the Geolocation test library.
        GeolocationTestLibrary.SetLocationAvailability(true);

        // [When] RequestGeolocation is invoked on the Geolocation object.
        Geolocation.RequestGeolocation();

        // [Then] The Geolocation object has a geographical location.
        Assert.IsTrue(Geolocation.HasGeolocation(), 'The Geolocation object does not have a geographical location.');
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('LocationPageHandler')]
    procedure TestGetGeolocationSuccesss()
    var
        Geolocation: Codeunit Geolocation;
        GeolocationTestLibrary: Codeunit "Geolocation Test Library";
        ActualLatitude: Decimal;
        ActualLongitude: Decimal;
        ExpectedLatitude: Decimal;
        ExpectedLongitude: Decimal;
    begin
        // [Given] Geolocation test library subscribers are bound.
        BindSubscription(GeolocationTestLibrary);

        // [When] Location availability is set to true in the Geolocation test library.
        GeolocationTestLibrary.SetLocationAvailability(true);

        // [When] The expected latitude and longitude are retrieved from the test library.
        GeolocationTestLibrary.GetMockGeolocation(ExpectedLatitude, ExpectedLongitude);

        // [When] RequestGeolocation is invoked on the Geolocation object.
        Geolocation.RequestGeolocation();

        // [When] The actual latitude and longitude are retrieved by invoking GetGeolocation on the Geolocation object.
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
        Geolocation: Codeunit Geolocation;
        GeolocationTestLibrary: Codeunit "Geolocation Test Library";
    begin
        // [Given] Geolocation test library subscribers are bound.
        BindSubscription(GeolocationTestLibrary);

        // [When] Location availability is set to true in the Geolocation test library.
        GeolocationTestLibrary.SetLocationAvailability(true);

        // [When] RequestGeolocation is invoked on the Geolocation object.
        Geolocation.RequestGeolocation();

        // [Then] The status of the geographical location data is Available.
        Assert.AreEqual("Geolocation Status"::Available, Geolocation.GetGeolocationStatus(), 'The status of the geographical location data is not "Available".');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestGetGeolocationStatusWithoutRequestingGeolocationIsNotAvailable()
    var
        Geolocation: Codeunit Geolocation;
        GeolocationTestLibrary: Codeunit "Geolocation Test Library";
    begin
        // [Given] Geolocation test library subscribers are bound.
        BindSubscription(GeolocationTestLibrary);

        // [When] Location availability is set to true in the Geolocation test library.
        GeolocationTestLibrary.SetLocationAvailability(true);

        // [When] RequestGeolocation has not been invoked on the Geolocation object.
        // [Then] The status of the geographical location data is Not Available.
        Assert.AreEqual("Geolocation Status"::"Not Available", Geolocation.GetGeolocationStatus(), 'The status of the geographical location data is not "Not Available".');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestHasGeolocationWithoutRequestingGeolocationIsFalse()
    var
        Geolocation: Codeunit Geolocation;
        GeolocationTestLibrary: Codeunit "Geolocation Test Library";
    begin
        // [Given] Geolocation test library subscribers are bound.
        BindSubscription(GeolocationTestLibrary);

        // [When] Location availability is set to true in the Geolocation test library.
        GeolocationTestLibrary.SetLocationAvailability(true);

        // [When] RequestGeolocation has not been invoked on the Geolocation object.
        // [Then] The Geolocation object does not contain a geographical location.
        Assert.IsFalse(Geolocation.HasGeolocation(), 'The Geolocation object has a location.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestGetGeolocationWithoutRequestingGeolocationResultInError()
    var
        Geolocation: Codeunit Geolocation;
        GeolocationTestLibrary: Codeunit "Geolocation Test Library";
        ActualLatitude: Decimal;
        ActualLongitude: Decimal;
    begin
        // [Given] Geolocation test library subscribers are bound.
        BindSubscription(GeolocationTestLibrary);

        // [When] Location availability is set to true in the Geolocation test library.
        GeolocationTestLibrary.SetLocationAvailability(true);

        // [When] GetGeolocation is invocked on the Geolocation object without invoking RequestGeolocation before.
        asserterror Geolocation.GetGeolocation(ActualLatitude, ActualLongitude);

        // [Then] An error message specifies that data was not retrieved for the geographical location.
        Assert.ExpectedError('The geographical location data was not retrieved.');
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('LocationPageHandler')]
    procedure TestGeolocationStatusIsTimedOut()
    var
        Geolocation: Codeunit Geolocation;
        GeolocationTestLibrary: Codeunit "Geolocation Test Library";
    begin
        // [Given] Geolocation test library subscribers are bound.
        BindSubscription(GeolocationTestLibrary);

        // [When] Location availability is set to true in the Geolocation test library.
        GeolocationTestLibrary.SetLocationAvailability(true);

        // [When] Location status is set to "Timed Out" in the Geolocation test library.
        GeolocationTestLibrary.SetGeolocationStatus("Geolocation Status"::"Timed Out");

        // [When] RequestGeolocation is invoked on the Geolocation object.
        Geolocation.RequestGeolocation();

        // [Then] The status of the geographical location data is "Timed Out"
        Assert.AreEqual("Geolocation Status"::"Timed Out", Geolocation.GetGeolocationStatus(), 'The status of the geographical location data is not "Timed Out".');
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('LocationPageHandler')]
    procedure TestGeolocationStatusIsNoData()
    var
        Geolocation: Codeunit Geolocation;
        GeolocationTestLibrary: Codeunit "Geolocation Test Library";
    begin
        // [Given] Geolocation test library subscribers are bound.
        BindSubscription(GeolocationTestLibrary);

        // [When] Location availability is set to true in the Geolocation test library.
        GeolocationTestLibrary.SetLocationAvailability(true);

        // [When] Location status is set to "No Data" in the Geolocation test library.
        GeolocationTestLibrary.SetGeolocationStatus("Geolocation Status"::"No Data");

        // [When] RequestGeolocation is invoked on the Geolocation object.
        Geolocation.RequestGeolocation();

        // [Then] The status of the geographical location data is "No Data"
        Assert.AreEqual("Geolocation Status"::"No Data", Geolocation.GetGeolocationStatus(), 'The status of the geographical location data is not "No Data".');
    end;

    [ModalPageHandler]
    procedure LocationPageHandler(var GeolocationPage: TestPage Geolocation)
    begin
        // Do nothing
    end;

}