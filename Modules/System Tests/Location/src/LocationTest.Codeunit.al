// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 50113 "Location Test"
{
    // [FEATURE] [Location] 

    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";

    [Test]
    [Scope('OnPrem')]
    procedure TestIsLocationAvailable()
    var
        Location: Page Location;
        LocationTestLibrary: Codeunit "Location Test Library";
    begin
        // [When] Location test library subscribers are binded.
        BindSubscription(LocationTestLibrary);

        // [Then] The return value of IsAvailable is 'true'.
        Assert.IsTrue(Location.IsAvailable(), 'The location should be available during testing.');
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('LocationPageHandler')]
    procedure TestHasLocationSuccess()
    var
        Location: Page Location;
        LocationTestLibrary: Codeunit "Location Test Library";
        ActualLatitude: Decimal;
        ActualLongitude: Decimal;
        ExpectedLatitude: Decimal;
        ExpectedLongitude: Decimal;
    begin
        // [Given] Location test library subscribers are binded.
        BindSubscription(LocationTestLibrary);

        // [When] The location page is run as modal.
        Location.RunModal();

        // [Then] The location page has a location 
        Assert.IsTrue(Location.HasLocation(), 'The location page has a location');
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('LocationPageHandler')]
    procedure TestGetLocationSuccesss()
    var
        Location: Page Location;
        LocationTestLibrary: Codeunit "Location Test Library";
        ActualLatitude: Decimal;
        ActualLongitude: Decimal;
        ExpectedLatitude: Decimal;
        ExpectedLongitude: Decimal;
    begin
        // [Given] Location test library subscribers are binded.
        BindSubscription(LocationTestLibrary);

        // [When] The expected latitude and longitude is retrieved from the test library.
        LocationTestLibrary.GetMockLocation(ExpectedLatitude, ExpectedLongitude);

        // [When] The location page is run as modal.
        Location.RunModal();

        // [When] The actual latitude and longitude is retrieved by invoking GetLocation on the location page.
        Location.GetLocation(ActualLatitude, ActualLongitude);

        // [Then] The latitude is equal to the expected latitude.
        Assert.AreEqual(ExpectedLatitude, ActualLatitude, 'The latitude value is as expected.');

        // [Then] The longitude is equal to the expected longitude.
        Assert.AreEqual(ExpectedLongitude, ActualLongitude, 'The longitude value is as expected.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestGetLocationStatusIsAvailable()
    var
        Location: Page Location;
        LocationTestLibrary: Codeunit "Location Test Library";
    begin
        // [Given] Location test library subscribers are binded.
        BindSubscription(LocationTestLibrary);

        // [When] The location page is run as modal.
        Location.RunModal();

        // [Then] The status of the location is available.
        Assert.AreEqual("Location Status"::Available, Location.GetLocationStatus(), 'Location status is "Available".');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestGetLocationStatusWithoutOpeningPageIsNotAvailable()
    var
        Location: Page Location;
        LocationTestLibrary: Codeunit "Location Test Library";
    begin
        // [Given] Location test library subscribers are binded.
        BindSubscription(LocationTestLibrary);

        // [When] The location page is not run as modal before.
        // [Then] The status of the location is available.
        Assert.AreEqual("Location Status"::NotAvailable, Location.GetLocationStatus(), 'Location status is "NotAvailable".');
    end;


    [Test]
    [Scope('OnPrem')]
    procedure TestHasLocationWithoutOpeningPageIsFalse()
    var
        Location: Page Location;
        LocationTestLibrary: Codeunit "Location Test Library";
    begin
        // [Given] Location test library subscribers are binded.
        BindSubscription(LocationTestLibrary);

        // [When] The location page is not run as modal before.
        // [Then] The location page has no location.
        Assert.IsFalse(Location.HasLocation(), 'Location page has no location.');
    end;


    [Test]
    [Scope('OnPrem')]
    procedure TestGetLocationWithoutOpeningPageResultInError()
    var
        Location: Page Location;
        LocationTestLibrary: Codeunit "Location Test Library";
        ActualLatitude: Decimal;
        ActualLongitude: Decimal;
    begin
        // [Given] Location test library subscribers are binded.
        BindSubscription(LocationTestLibrary);

        // [When] GetLocation is invocked on the location page without running the page as modal before.
        asserterror Location.GetLocation(ActualLatitude, ActualLongitude);

        // [Then] An error is shown specifying that the location is not retrieved.
        Assert.ExpectedError('Location is not retrieved.');
    end;

    [ModalPageHandler]
    procedure LocationPageHandler(var LocationPage: TestPage Location)
    begin
        // Do nothing
    end;

}