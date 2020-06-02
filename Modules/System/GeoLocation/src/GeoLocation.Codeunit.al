// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides functionality for getting geographical location information from the client device.
/// <example>
/// <code>
/// if Geolocation.GetGeolocation(Latitude, Longitude) then
///    Message('Latitude: %1, Longitude: %2', Latitude, Longitude);
/// </code>
/// </example>
/// </summary>
codeunit 50100 Geolocation
{
    Access = Public;

    var
        GeolocationImpl: Codeunit "Geolocation Impl.";

    /// <summary>
    /// Gets a geographical location from the client device and returns it in the the longitude and latitude parameters.
    /// </summary>
    /// <param name="Latitude">The latitude value of the geographical location.</param>
    /// <param name="Longitude">The longitude value of the geographical location.</param>
    /// <returns>True if the geographical location data was retrieved and is available, and the user agreed to share it, otherwise false.</returns>
    procedure GetGeolocation(var Latitude: Decimal; var Longitude: Decimal): Boolean
    begin
        exit(GeolocationImpl.GetGeolocation(Latitude, Longitude));
    end;

    /// <summary>
    /// Checks whether geographical location data is available on the client device.
    /// </summary>
    /// <returns>True if the location is available; false otherwise.</returns>
    procedure IsAvailable(): Boolean
    begin
        exit(GeolocationImpl.IsAvailable());
    end;
}