// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 50114 "Location Test Library"
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
    /// <param name="Handled">Signals whether taking the location was handled by the subsciber.</param>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Location Page Impl.", 'OnBeforeLocationInitialize', '', false, false)]
    local procedure OnBeforeLocationInitialize(var Handled: Boolean; var Location: DotNet Location)
    begin
        Handled := true;
        GetMockLocation(Location);
    end;

    procedure GetMockLocation(var Loc: DotNet Location)
    var
        Coordinate: DotNet Coordinate;
        Longitude: Decimal;
        Latitude: Decimal;

    begin
        Latitude := 1.5;
        Longitude := 2.5;

        Coordinate := Coordinate.Coordinate();
        Coordinate.Latitude := Latitude;
        Coordinate.Longitude := Longitude;

        Loc := Loc.Location();
        Loc.Coordinate := Coordinate;
    end;

    procedure GetMockLocation(var Latitude: Decimal; var Longitude: Decimal)
    var

    begin
        Latitude := 1.5;
        Longitude := 2.5;
    end;
}