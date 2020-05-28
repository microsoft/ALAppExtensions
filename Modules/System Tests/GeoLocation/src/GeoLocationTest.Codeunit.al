// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 50104 "GeoLocation Test"
{
    // [FEATURE] [GeoLocation] 

    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";

    [Test]
    [Scope('OnPrem')]
    procedure TestIsGeoLocationAvailable()
    var
        GeoLocation: Page GeoLocation;
        GeoLocationTestLibrary: Codeunit "GeoLocation Test Library";
    begin
        // [When] GeoLocation test library subscribers are binded.
        BindSubscription(GeoLocationTestLibrary);

        // [Then] The return value of IsAvailable is 'true'.
        Assert.IsTrue(GeoLocation.IsAvailable(), 'The GeoLocation is unavailable.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestHasGeoLocationSuccess()
    var
        GeoLocation: Page GeoLocation;
        GeoLocationTestLibrary: Codeunit "GeoLocation Test Library";
    begin
        // [Given] GeoLocation test library subscribers are binded.
        BindSubscription(GeoLocationTestLibrary);

        // [When] The GeoLocation page is run as modal.
        GeoLocation.RunModal();

        // [Then] The GeoLocation page has a GeoLocation 
        Assert.IsTrue(GeoLocation.HasGeoLocation(), 'The GeoLocation page does not have a location.');
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('LocationPageHandler')]
    procedure TestGetGeoLocationSuccesss()
    var
        GeoLocation: Page GeoLocation;
        GeoLocationTestLibrary: Codeunit "GeoLocation Test Library";
        ActualLatitude: Decimal;
        ActualLongitude: Decimal;
        ExpectedLatitude: Decimal;
        ExpectedLongitude: Decimal;
    begin
        // [Given] GeoLocation test library subscribers are binded.
        BindSubscription(GeoLocationTestLibrary);

        // [When] The expected latitude and longitude is retrieved from the test library.
        GeoLocationTestLibrary.GetMockGeoLocation(ExpectedLatitude, ExpectedLongitude);

        // [When] The GeoLocation page is run as modal.
        GeoLocation.RunModal();

        // [When] The actual latitude and longitude is retrieved by invoking GetGeoLocation on the GeoLocation page.
        GeoLocation.GetGeoLocation(ActualLatitude, ActualLongitude);

        // [Then] The latitude is equal to the expected latitude.
        Assert.AreEqual(ExpectedLatitude, ActualLatitude, 'The latitude value is not the same as the expeceted latitude.');

        // [Then] The longitude is equal to the expected longitude.
        Assert.AreEqual(ExpectedLongitude, ActualLongitude, 'The longitude value is not the same as the expeceted longitude.');
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('LocationPageHandler')]
    procedure TestGetGeoLocationStatusIsAvailable()
    var
        GeoLocation: Page GeoLocation;
        GeoLocationTestLibrary: Codeunit "GeoLocation Test Library";
    begin
        // [Given] GeoLocation test library subscribers are binded.
        BindSubscription(GeoLocationTestLibrary);

        // [When] The GeoLocation page is run as modal.
        GeoLocation.RunModal();

        // [Then] The status of the GeoLocation is available.
        Assert.AreEqual("GeoLocation Status"::Available, GeoLocation.GetGeoLocationStatus(), 'The GeoLocation status is not "Available".');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestGetGeoLocationStatusWithoutOpeningPageIsNotAvailable()
    var
        GeoLocation: Page GeoLocation;
        GeoLocationTestLibrary: Codeunit "GeoLocation Test Library";
    begin
        // [Given] GeoLocation test library subscribers are binded.
        BindSubscription(GeoLocationTestLibrary);

        // [When] The GeoLocation page is not run as modal before.
        // [Then] The status of the GeoLocation is available.
        Assert.AreEqual("GeoLocation Status"::"Not Available", GeoLocation.GetGeoLocationStatus(), 'The GeoLocation status is not "Not Available".');
    end;


    [Test]
    [Scope('OnPrem')]
    procedure TestHasGeoLocationWithoutOpeningPageIsFalse()
    var
        GeoLocation: Page GeoLocation;
        GeoLocationTestLibrary: Codeunit "GeoLocation Test Library";
    begin
        // [Given] GeoLocation test library subscribers are binded.
        BindSubscription(GeoLocationTestLibrary);

        // [When] The GeoLocation page is not run as modal before.
        // [Then] The GeoLocation page has no GeoLocation.
        Assert.IsFalse(GeoLocation.HasGeoLocation(), 'The GeoLocation page has a location.');
    end;


    [Test]
    [Scope('OnPrem')]
    procedure TestGetGeoLocationWithoutOpeningPageResultInError()
    var
        GeoLocation: Page GeoLocation;
        GeoLocationTestLibrary: Codeunit "GeoLocation Test Library";
        ActualLatitude: Decimal;
        ActualLongitude: Decimal;
    begin
        // [Given] GeoLocation test library subscribers are binded.
        BindSubscription(GeoLocationTestLibrary);

        // [When] GetGeoLocation is invocked on the GeoLocation page without running the page as modal before.
        asserterror GeoLocation.GetGeoLocation(ActualLatitude, ActualLongitude);

        // [Then] An error is shown specifying that the GeoLocation is not retrieved.
        Assert.ExpectedError('The geographical location is not retrieved.');
    end;

    [ModalPageHandler]
    procedure LocationPageHandler(var GeoLocationPage: TestPage GeoLocation)
    begin
        // Do nothing
    end;

}