// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 50103 "Location Test Library"
{
    EventSubscriberInstance = Manual;

    /// <summary>
    /// Indicate that the location is available when test is in progress.
    /// </summary>
    /// <param name="IsAvailable">Signals whether the location is available.</param>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Location Page Impl.", 'OnIsLocationAvailable', '', false, false)]
    local procedure OnIsLocationAvailable(var IsAvailable: Boolean)
    begin
        IsAvailable := true;
    end;

    /// <summary>
    /// Save a mock location on the server instead of accessing an actual device for the location.
    /// </summary>
    /// <param name="IsHandled">Signals whether taking the location was handled by the subscriber.</param>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Location Page Impl.", 'OnBeforeLocationInitialize', '', false, false)]
    local procedure OnBeforeLocationInitialize(var Location: DotNet Location; var IsHandled: Boolean)
    begin
        IsHandled := true;
        GetMockLocation(Location);
    end;

    procedure GetMockLocation(var Location: DotNet Location)
    var
        Coordinate: DotNet Coordinate;
    begin
        Location := Location.Location();
        Location.Coordinate := Coordinate.Coordinate();
        Location.Coordinate.Latitude := 1.5;
        Location.Coordinate.Longitude := 2.5;
    end;

    procedure GetMockLocation(var Latitude: Decimal; var Longitude: Decimal)
    begin
        Latitude := 1.5;
        Longitude := 2.5;
    end;
}