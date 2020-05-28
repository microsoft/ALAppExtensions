// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides functionality for getting geographical location information from the client device.
/// <example>
/// <code>
/// if GeoLocation.GetGeoLocation(Latitude, Longitude) then
///    Message('Latitude: %1, Longitude: %2', Latitude, Longitude);
/// </code>
/// </example>
/// </summary>
codeunit 50100 GeoLocation
{
    Access = Public;

    var
        GeoLocationImpl: Codeunit "GeoLocation Impl.";

    /// <summary>
    /// Gets a geographical location from the client device and returns it in the the longitude and latitude parameters.
    /// </summary>
    /// <param name="Latitude">The latitude value of the location.</param>
    /// <param name="Longitude">The longitude value of the location.</param>
    /// <returns>True if the location is available, the user confirmed to share the location and the location information was successfully retrieved, false otherwise.</returns>
    procedure GetGeoLocation(var Latitude: Decimal; var Longitude: Decimal): Boolean
    begin
        exit(GeoLocationImpl.GetGeoLocation(Latitude, Longitude));
    end;

    /// <summary>
    /// Checks if the location is available on the client device.
    /// </summary>
    /// <returns>True if the location is available; false otherwise.</returns>
    procedure IsAvailable(): Boolean
    begin
        exit(GeoLocationImpl.IsAvailable());
    end;
}