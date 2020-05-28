// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 50102 "GeoLocation Page Impl."
{
    Access = Internal;

    var
        LocationNotRetrievedError: Label 'The geographical location is not retrieved.';
        CachedLocation: Dotnet Location;
        LocationOptions: DotNet LocationOptions;
        LocationOptionsEnabled: Boolean;

    procedure LocationInteractionOnOpenPage(var LocationProvider: Dotnet LocationProvider; var LocationAvailable: Boolean)
    var
        Location: DotNet Location;
        HandledByTest: Boolean;
    begin
        OnBeforeLocationInitialize(Location, HandledByTest);
        if HandledByTest then begin
            LocationInteractionOnLocationAvailable(Location);
            exit;
        end;

        LocationAvailable := IsAvailable(LocationProvider);
        if not LocationAvailable then
            exit;

        InitializeLocationOptions();
        LocationProvider := LocationProvider.Create();
        LocationProvider.RequestLocationAsync();
    end;

    local procedure InitializeLocationOptions()
    begin
        if LocationOptionsEnabled then
            exit;

        LocationOptions := LocationOptions.LocationOptions();
        LocationOptionsEnabled := true;
    end;

    procedure LocationInteractionOnLocationAvailable(Location: Dotnet Location)
    begin
        CachedLocation := Location;
    end;

    procedure IsAvailable(var LocationProvider: Dotnet LocationProvider): Boolean
    var
        IsAvailable: Boolean;
    begin
        IsAvailable := LocationProvider.IsAvailable();
        OnIsLocationAvailable(IsAvailable);
        exit(IsAvailable);
    end;

    procedure HasGeoLocation(): Boolean
    begin
        if IsNull(CachedLocation) then
            exit(false);

        if GetGeoLocationStatus() <> "GeoLocation Status"::Available then
            exit(false);

        exit(true);
    end;

    procedure GetGeoLocation(var Latitude: Decimal; var Longitude: Decimal)
    begin
        if (not HasGeoLocation()) then begin
            Error(LocationNotRetrievedError);
        end;

        Latitude := CachedLocation.Coordinate.Latitude;
        Longitude := CachedLocation.Coordinate.Longitude;
    end;

    procedure GetGeoLocationStatus(): Enum "GeoLocation Status"
    begin
        if (IsNull(CachedLocation)) then
            exit("GeoLocation Status"::"Not Available");

        exit("GeoLocation Status".FromInteger(CachedLocation.Status));
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

    [IntegrationEvent(false, false)]
    procedure OnBeforeLocationInitialize(var Location: DotNet Location; var IsHandled: Boolean)
    begin
        // Used for testing
    end;

    [IntegrationEvent(false, false)]
    procedure OnIsLocationAvailable(var IsAvailable: Boolean)
    begin
        // Used for testing
    end;

}