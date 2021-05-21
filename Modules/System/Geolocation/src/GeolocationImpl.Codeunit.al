// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 7569 "Geolocation Impl."
{
    Access = Internal;

    var
        GeolocationPage: Page Geolocation;
        LocationNotRetrievedErrorMsg: Label 'The geographical location data was not retrieved.';
        CachedLocation: Dotnet Location;
        LocationProvider: DotNet LocationProvider;
        LocationOptions: DotNet LocationOptions;
        LocationOptionsEnabled: Boolean;

    procedure RequestGeolocation(GeolocationImpl: Codeunit "Geolocation Impl."): Boolean
    begin
        Clear(GeolocationPage);
        GeolocationPage.SetGeolocationImpl(GeolocationImpl);
        GeolocationPage.RunModal();
        if HasGeolocation() then
            exit(true);

        exit(false);
    end;

    procedure LocationInteractionOnOpenPage(var LocationProvdr: Dotnet LocationProvider; var LocationAvailable: Boolean)
    var
        Location: DotNet Location;
        HandledByTest: Boolean;
    begin
        OnBeforeLocationInitialize(Location, HandledByTest);
        if HandledByTest then begin
            LocationInteractionOnLocationAvailable(Location);
            exit;
        end;

        LocationAvailable := LocationProvdr.IsAvailable();
        if not LocationAvailable then
            exit;

        InitializeLocationOptions();
        LocationProvdr := LocationProvdr.Create();
        LocationProvdr.RequestLocationAsync(LocationOptions);
        LocationProvider := LocationProvdr;
    end;

    procedure LocationInteractionOnLocationAvailable(Location: Dotnet Location)
    begin
        CachedLocation := Location;
    end;

    procedure IsAvailable(): Boolean
    var
        Available: Boolean;
    begin
        Available := LocationProvider.IsAvailable();
        OnIsLocationAvailable(Available);
        exit(Available);
    end;

    procedure HasGeolocation(): Boolean
    begin
        if IsNull(CachedLocation) then
            exit(false);

        exit(GetGeolocationStatus() = "Geolocation Status"::Available);
    end;

    procedure GetGeolocation(var Latitude: Decimal; var Longitude: Decimal)
    begin
        if (not HasGeolocation()) then
            Error(LocationNotRetrievedErrorMsg);

        Latitude := CachedLocation.Coordinate.Latitude;
        Longitude := CachedLocation.Coordinate.Longitude;
    end;

    procedure GetGeolocationStatus(): Enum "Geolocation Status"
    begin
        if (IsNull(CachedLocation)) then
            exit("Geolocation Status"::"Not Available");

        exit("Geolocation Status".FromInteger(CachedLocation.Status));
    end;

    procedure SetHighAccuracy(Enable: Boolean)
    begin
        InitializeLocationOptions();
        LocationOptions.EnableHighAccuracy(Enable);
    end;

    procedure SetTimeout(Timeout: Integer)
    begin
        InitializeLocationOptions();
        LocationOptions.Timeout(Timeout)
    end;

    procedure SetMaximumAge(Age: Integer)
    begin
        InitializeLocationOptions();
        LocationOptions.MaximumAge(Age)
    end;

    procedure GetHighAccuracy(): Boolean
    begin
        InitializeLocationOptions();
        exit(LocationOptions.EnableHighAccuracy());
    end;

    procedure GetTimeout(): Integer
    begin
        InitializeLocationOptions();
        exit(LocationOptions.Timeout());
    end;

    procedure GetMaximumAge(): Integer
    begin
        InitializeLocationOptions();
        exit(LocationOptions.MaximumAge());
    end;

    local procedure InitializeLocationOptions()
    begin
        if LocationOptionsEnabled then
            exit;

        LocationOptions := LocationOptions.LocationOptions();
        LocationOptions.EnableHighAccuracy := false;
        LocationOptions.Timeout := 600000; // 10 minutes
        LocationOptions.MaximumAge := 0;
        LocationOptionsEnabled := true;
    end;

    [InternalEvent(false)]
    procedure OnBeforeLocationInitialize(var Location: DotNet Location; var IsHandled: Boolean)
    begin
        // Used for testing
    end;

    [InternalEvent(false)]
    procedure OnIsLocationAvailable(var IsAvailable: Boolean)
    begin
        // Used for testing
    end;
}