// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 50103 "Geolocation Test Library"
{
    EventSubscriberInstance = Manual;

    /// <summary>
    /// Indicates that the geographical location is available when a test is in progress.
    /// </summary>
    /// <param name="IsAvailable">Indicates whether the geographical location is available.</param>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Geolocation Page Impl.", 'OnIsLocationAvailable', '', false, false)]
    local procedure OnIsLocationAvailable(var IsAvailable: Boolean)
    begin
        IsAvailable := true;
    end;

    /// <summary>
    /// Save a mock geographical location on the server instead of accessing an actual device for the location.
    /// </summary>
    /// <param name="IsHandled">Indicates whether taking the geographical location was handled by the subscriber.</param>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Geolocation Page Impl.", 'OnBeforeLocationInitialize', '', false, false)]
    local procedure OnBeforeLocationInitialize(var Location: DotNet Location; var IsHandled: Boolean)
    begin
        IsHandled := true;
        GetMockGeolocation(Location);
    end;

    procedure GetMockGeolocation(var Location: DotNet Location)
    var
        Coordinate: DotNet Coordinate;
    begin
        Location := Location.Location();
        Location.Coordinate := Coordinate.Coordinate();
        Location.Coordinate.Latitude := 1.5;
        Location.Coordinate.Longitude := 2.5;
    end;

    procedure GetMockGeolocation(var Latitude: Decimal; var Longitude: Decimal)
    begin
        Latitude := 1.5;
        Longitude := 2.5;
    end;
}