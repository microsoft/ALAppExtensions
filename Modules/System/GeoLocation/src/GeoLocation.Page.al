// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides an interface for accessing the location on the client device.
/// </summary>
/// <example>
/// <code>
/// GeoLocation.RunModal();
/// if GeoLocation.HasGeoLocation() then begin
///     GeoLocation.GetGeoLocation(Latitude, Longitude);
/// ...
/// end;
/// Clear(Location);
/// </code>
/// </example>
page 50100 GeoLocation
{
    Caption = 'GeoLocation request';
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
                InstructionalText = 'Please, confirm that Business Central can access the geographical location of the device.';
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
        GeoLocationPageImpl: Codeunit "GeoLocation Page Impl.";
        [RunOnClient]
        [WithEvents]
        LocationProvider: DotNet LocationProvider;
        LocationAvailable: Boolean;

    /// <summary>
    /// When the page opens it request the location from the client and shows a view.
    /// After getting the location, the page will close automatically.
    /// </summary>
    trigger OnOpenPage()
    begin
        GeoLocationPageImpl.LocationInteractionOnOpenPage(LocationProvider, LocationAvailable);
    end;

    /// <summary>
    /// Checks if the location is available on the client device.
    /// </summary>
    /// <returns>True if the location is available; false otherwise.</returns>
    procedure IsAvailable(): Boolean
    begin
        exit(GeoLocationPageImpl.IsAvailable(LocationProvider));
    end;

    /// <summary>
    /// Checks if a location has been retrieved from the client device and and is available.
    /// </summary>
    /// <returns>True if a location is retrieved and is available; false otherwise.</returns>
    procedure HasGeoLocation(): Boolean
    begin
        exit(GeoLocationPageImpl.HasGeoLocation());
    end;

    /// <summary>
    /// Gets the location that was retrieved when opening the page.
    /// An error is displayed if the function is called without opening the page first or if the location is not available.
    /// </summary>
    /// <param name="Latitude">The latitude value of the location.</param>
    /// <param name="Longitude">The longitude value of the location.</param>
    /// <error>The location is not available.</error>
    procedure GetGeoLocation(var Latitude: Decimal; var Longitude: Decimal)
    begin
        GeoLocationPageImpl.GetGeoLocation(Latitude, Longitude);
    end;

    /// <summary>
    /// Gets the status of the client device location.
    /// </summary>
    /// <returns>The status of the location. Either</returns>
    procedure GetGeoLocationStatus(): Enum "GeoLocation Status"
    begin
        exit(GeoLocationPageImpl.GetGeoLocationStatus());
    end;

    /// <summary>
    /// Sets whether the device should have the best possible location accuracy.
    /// </summary>
    /// <param name="Enable">A value to provide a hint to the device that this request must have the best possible location accuracy.</param>
    procedure SetHighAccuracy(Enable: Boolean)
    begin
        GeoLocationPageImpl.SetHighAccuracy(Enable);
    end;

    /// <summary>
    /// Sets a timeout for the location request.
    /// </summary>
    /// <param name="Timeout">The maximum length of time (milliseconds) that is allowed to pass to a location request.</param>
    procedure SetTimeout(Timeout: Integer)
    begin
        GeoLocationPageImpl.SetTimeout(Timeout);
    end;

    /// <summary>
    /// Sets a maximum age for the location request.
    /// </summary>
    /// <param name="Age">The maximum length of time (milliseconds) of a cached location.</param>
    procedure SetMaximumAge(Age: Integer)
    begin
        GeoLocationPageImpl.SetMaximumAge(Age);
    end;

    /// <summary>
    /// Gets whether the device should have the best possible location accuracy
    /// </summary>
    /// <returns>Whether high accuracy is set. A value to provide a hint to the device that this request must have the best possible location accuracy.</returns>
    procedure GetHighAccuracy(): Boolean
    begin
        exit(GeoLocationPageImpl.GetHighAccuracy());
    end;

    /// <summary>
    /// Get the timeout for the location request.
    /// </summary>
    /// <returns>The maximum length of time (milliseconds) that is allowed to pass to a location request.</returns>
    procedure GetTimeout(): Integer
    begin
        exit(GeoLocationPageImpl.GetTimeout());
    end;

    /// <summary>
    /// Gets the maximum age for the location request.
    /// </summary>
    /// <returns>The maximum length of time (milliseconds) of a cached location.</returns>
    procedure GetMaximumAge(): Integer
    begin
        exit(GeoLocationPageImpl.GetMaximumAge());
    end;

    trigger LocationProvider::LocationChanged(Location: DotNet Location)
    begin
        GeoLocationPageImpl.LocationInteractionOnLocationAvailable(Location);
        CurrPage.Close();
    end;
}