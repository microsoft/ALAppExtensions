// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides functionality for getting geographical location information from the client device.
/// <example>
/// <code>
/// Geolocation.SetHighAccuracy(true);
/// if Geolocation.RequestGeolocation() then
///    Geolocation.GetGeolocation(Latitude, Longitude);        
/// </code>
/// </example>
/// </summary>
codeunit 7568 Geolocation
{
    Access = Public;

    var
        GeolocationImpl: Codeunit "Geolocation Impl.";

    /// <summary>
    /// Requests a geographical location from the client device and returns whether the request was succesful.
    /// </summary>
    /// <returns>True if the geographical location data was retrieved and is available, and the user agreed to share it, otherwise false.</returns>
    procedure RequestGeolocation(): Boolean
    begin
        exit(GeolocationImpl.RequestGeolocation(GeolocationImpl));
    end;

    /// <summary>
    /// Gets a geographical location from the client device and returns it in the the longitude and latitude parameters.
    /// </summary>
    /// <param name="Latitude">The latitude value of the geographical location.</param>
    /// <param name="Longitude">The longitude value of the geographical location.</param>
    procedure GetGeolocation(var Latitude: Decimal; var Longitude: Decimal)
    begin
        GeolocationImpl.GetGeolocation(Latitude, Longitude);
    end;

    /// <summary>
    /// Checks whether geographical location data is available on the client device.
    /// </summary>
    /// <returns>True if the location is available; false otherwise.</returns>
    procedure IsAvailable(): Boolean
    begin
        exit(GeolocationImpl.IsAvailable());
    end;

    /// <summary>
    /// Checks whether geographical location data has been retrieved from the client device and is available.
    /// </summary>
    /// <returns>True if geographical location data is retrieved and is available, otherwise false.</returns>
    procedure HasGeolocation(): Boolean
    begin
        exit(GeolocationImpl.HasGeolocation());
    end;

    /// <summary>
    /// Gets the status of the geographical location data of the client device.
    /// </summary>
    /// <returns>The status of the geographical location data.</returns>
    procedure GetGeolocationStatus(): Enum "Geolocation Status"
    begin
        exit(GeolocationImpl.GetGeolocationStatus());
    end;

    /// <summary>
    /// Sets whether the geographical location data for the device should have the highest level of accuracy.
    /// </summary>
    /// <param name="Enable">Instructs the device that the geographical location data for this request must have the highest level of accuracy.</param>
    procedure SetHighAccuracy(Enable: Boolean)
    begin
        GeolocationImpl.SetHighAccuracy(Enable);
    end;

    /// <summary>
    /// Sets a timeout for the geographical location data request.
    /// </summary>
    /// <param name="Timeout">The maximum length of time (milliseconds) that is allowed to pass to a location request.</param>
    procedure SetTimeout(Timeout: Integer)
    begin
        GeolocationImpl.SetTimeout(Timeout);
    end;

    /// <summary>
    /// Sets a maximum age for the geographical location data request.
    /// </summary>
    /// <param name="Age">The maximum length of time (milliseconds) of cached geographical location data.</param>
    procedure SetMaximumAge(Age: Integer)
    begin
        GeolocationImpl.SetMaximumAge(Age);
    end;

    /// <summary>
    /// Gets whether the device should have the highest level of accuracy for geographical location data.
    /// </summary>
    /// <returns>Whether high accuracy is set. A value to provide a hint to the device that this request must have the best possible location accuracy.</returns>
    procedure GetHighAccuracy(): Boolean
    begin
        exit(GeolocationImpl.GetHighAccuracy());
    end;

    /// <summary>
    /// Gets the timeout for the geographical location data request.
    /// </summary>
    /// <returns>The maximum length of time (milliseconds) that is allowed to pass to a location request.</returns>
    procedure GetTimeout(): Integer
    begin
        exit(GeolocationImpl.GetTimeout());
    end;

    /// <summary>
    /// Gets the maximum age for the geographical location data request.
    /// </summary>
    /// <returns>The maximum length of time (milliseconds) of geographical location data.</returns>
    procedure GetMaximumAge(): Integer
    begin
        exit(GeolocationImpl.GetMaximumAge());
    end;
}