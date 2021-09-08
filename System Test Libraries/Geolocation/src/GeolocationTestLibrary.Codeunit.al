// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 135028 "Geolocation Test Library"
{
    EventSubscriberInstance = Manual;

    var
        IsLocationAvailable: Boolean;
        MockStatus: Enum "Geolocation Status";

    /// <summary>
    /// Indicates whether the geographical location is available when a test is in progress.
    /// </summary>
    /// <param name="IsAvailable">Indicates whether the geographical location is available.</param>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Geolocation Impl.", 'OnIsLocationAvailable', '', false, false)]
    local procedure OnIsLocationAvailable(var IsAvailable: Boolean)
    begin
        IsAvailable := IsLocationAvailable;
    end;

    /// <summary>
    /// Use a mock geographical location instead of accessing an actual device for the location.
    /// </summary>
    /// <param name="IsHandled">Indicates whether taking the geographical location was handled by the subscriber.</param>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Geolocation Impl.", 'OnBeforeLocationInitialize', '', false, false)]
    local procedure OnBeforeLocationInitialize(var Location: DotNet Location; var IsHandled: Boolean)
    begin
        IsHandled := true;
        GetMockGeolocation(Location);
    end;

    procedure SetLocationAvailability(IsAvailable: Boolean)
    begin
        IsLocationAvailable := IsAvailable;
    end;

    procedure SetGeolocationStatus(Status: Enum "Geolocation Status")
    begin
        MockStatus := Status;
    end;

    procedure GetMockGeolocation(var Location: DotNet Location)
    var
        Coordinate: DotNet Coordinate;
        LocationStatus: DotNet LocationStatus;
    begin
        Location := Location.Location();
        Location.Coordinate := Coordinate.Coordinate();
        Location.Coordinate.Latitude := 1.5;
        Location.Coordinate.Longitude := 2.5;
        LocationStatus := MockStatus.AsInteger();
        Location.Status := LocationStatus;
    end;

    procedure GetMockGeolocation(var Latitude: Decimal; var Longitude: Decimal)
    begin
        Latitude := 1.5;
        Longitude := 2.5;
    end;
}