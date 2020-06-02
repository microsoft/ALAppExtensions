// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides an interface for accessing the location on the client device.
/// </summary>
/// <example>
/// <code>
/// Geolocation.RunModal();
/// if Geolocation.HasGeolocation() then begin
///     Geolocation.GetGeolocation(Latitude, Longitude);
/// ...
/// end;
/// Clear(Location);
/// </code>
/// </example>
page 50100 Geolocation
{
    Caption = 'Geolocation request';
    PageType = Card;
    Editable = false;
    LinksAllowed = false;
    Extensible = true;

    layout
    {
        area(content)
        {
            group(Location)
            {
                Caption = 'Requesting geographical location...';
                InstructionalText = 'Allow Business Central to access data about the geographical location of the device.';
                Visible = LocationAvailable;
            }
            group(LocationNotSupported)
            {
                Caption = 'Could not access the geographical location';
                InstructionalText = 'Could not access the geographical location of the device. Make sure that you are using the app for Windows, Android, or iOS.';
                Visible = NOT LocationAvailable;
            }
        }
    }

    var
        GeolocationPageImpl: Codeunit "Geolocation Page Impl.";
        [RunOnClient]
        [WithEvents]
        LocationProvider: DotNet LocationProvider;
        LocationAvailable: Boolean;

    /// <summary>
    /// When the page opens it requests the location from the client and shows a view.
    /// After getting the location, the page will close automatically.
    /// </summary>
    trigger OnOpenPage()
    begin
        GeolocationPageImpl.LocationInteractionOnOpenPage(LocationProvider, LocationAvailable);
    end;

    /// <summary>
    /// Checks whether the geographical location data is available on the client device.
    /// </summary>
    /// <returns>True if the location is available; false otherwise.</returns>
    procedure IsAvailable(): Boolean
    begin
        exit(GeolocationPageImpl.IsAvailable(LocationProvider));
    end;

    /// <summary>
    /// Checks whether geographical location data has been retrieved from the client device and is available.
    /// </summary>
    /// <returns>True if geographical location data is retrieved and is available, otherwise false.</returns>
    procedure HasGeolocation(): Boolean
    begin
        exit(GeolocationPageImpl.HasGeolocation());
    end;

    /// <summary>
    /// Gets the geographical location data that was retrieved when opening the page.
    /// An error is displayed if the function is called without opening the page first or if the geographical location data is not available.
    /// </summary>
    /// <param name="Latitude">The latitude value of the geographical location data.</param>
    /// <param name="Longitude">The longitude value of the geographical location data.</param>
    /// <error>The geographical location data is not available.</error>
    procedure GetGeolocation(var Latitude: Decimal; var Longitude: Decimal)
    begin
        GeolocationPageImpl.GetGeolocation(Latitude, Longitude);
    end;

    /// <summary>
    /// Gets the status of the geographical location data of the client device.
    /// </summary>
    /// <returns>The status of the geographical location data.</returns>
    procedure GetGeolocationStatus(): Enum "Geolocation Status"
    begin
        exit(GeolocationPageImpl.GetGeolocationStatus());
    end;

    /// <summary>
    /// Sets whether the geographical location data for the device should have the highest level of accuracy.
    /// </summary>
    /// <param name="Enable">Instructs the device that the geographical location data for this request must have the highest level of accuracy.</param>
    procedure SetHighAccuracy(Enable: Boolean)
    begin
        GeolocationPageImpl.SetHighAccuracy(Enable);
    end;

    /// <summary>
    /// Sets a timeout for the geographical location data request.
    /// </summary>
    /// <param name="Timeout">The maximum length of time (milliseconds) that is allowed to pass to a location request.</param>
    procedure SetTimeout(Timeout: Integer)
    begin
        GeolocationPageImpl.SetTimeout(Timeout);
    end;

    /// <summary>
    /// Sets a maximum age for the geographical location data request.
    /// </summary>
    /// <param name="Age">The maximum length of time (milliseconds) of cached geographical location data.</param>
    procedure SetMaximumAge(Age: Integer)
    begin
        GeolocationPageImpl.SetMaximumAge(Age);
    end;

    /// <summary>
    /// Gets whether the device should have the highest level of accuracy for geographical location data.
    /// </summary>
    /// <returns>Whether high accuracy is set. A value to provide a hint to the device that this request must have the best possible location accuracy.</returns>
    procedure GetHighAccuracy(): Boolean
    begin
        exit(GeolocationPageImpl.GetHighAccuracy());
    end;

    /// <summary>
    /// Gets the timeout for the geographical location data request.
    /// </summary>
    /// <returns>The maximum length of time (milliseconds) that is allowed to pass to a location request.</returns>
    procedure GetTimeout(): Integer
    begin
        exit(GeolocationPageImpl.GetTimeout());
    end;

    /// <summary>
    /// Gets the maximum age for the geographical location data request.
    /// </summary>
    /// <returns>The maximum length of time (milliseconds) of geographical location data.</returns>
    procedure GetMaximumAge(): Integer
    begin
        exit(GeolocationPageImpl.GetMaximumAge());
    end;

    trigger LocationProvider::LocationChanged(Location: DotNet Location)
    begin
        GeolocationPageImpl.LocationInteractionOnLocationAvailable(Location);
        CurrPage.Close();
    end;
}