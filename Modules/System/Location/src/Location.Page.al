// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides an interface for accessing the location on the client device.
/// </summary>
/// <example>
/// <code>
/// Location.RunModal();
/// if Location.HasLocation() then begin
///     Location.GetLocation(Latitude, Longitude);
/// ...
/// end;
/// Clear(Location);
/// </code>
/// </example>
page 50105 "Location"
{
    Caption = 'Location request';
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
                Caption = 'Requesting location...';
                InstructionalText = 'Please, confirm that Business Central can access the location of the device.';
                Visible = LocationAvailable;
            }
            group(LocationNotSupported)
            {
                Caption = 'Could not access the location';
                InstructionalText = 'Could not access the location of the device. Make sure that you are using the app for Windows, Android, or iOS.';
                Visible = NOT LocationAvailable;
            }
        }
    }

    var
        LocationPageImpl: Codeunit "Location Page Impl.";
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
        LocationPageImpl.LocationInteractionOnOpenPage(LocationProvider, LocationAvailable);
    end;

    /// <summary>
    /// Checks if the location is available on the client device.
    /// </summary>
    /// <returns>True if the location is available; false otherwise.</returns>
    procedure IsAvailable(): Boolean
    begin
        exit(LocationPageImpl.IsAvailable(LocationProvider));
    end;

    /// <summary>
    /// Checks if a location has been retrieved from the client device and and is available.
    /// </summary>
    /// <returns>True if a location is retrieved and is available; false otherwise.</returns>
    procedure HasLocation(): Boolean
    begin
        exit(LocationPageImpl.HasLocation());
    end;

    /// <summary>
    /// Gets the location that was retrieved when opening the page.
    /// An error is displayed if the function is called without opening the page first or if the location is not available.
    /// </summary>
    /// <param name="Latitude">The latitude value of the location.</param>
    /// <param name="Longitude">The longitude value of the location.</param>
    /// <error>The location is not available.</error>
    procedure GetLocation(var Latitude: Decimal; var Longitude: Decimal)
    begin
        LocationPageImpl.GetLocation(Latitude, Longitude);
    end;

    /// <summary>
    /// Gets the status of the client device location.
    /// </summary>
    /// <returns>The status of the location. Either</returns>
    procedure GetLocationStatus(): Enum "Location Status"
    begin
        exit(LocationPageImpl.GetLocationStatus());
    end;

    /// <summary>
    /// Sets whether the device should have the best possible location accuracy.
    /// </summary>
    /// <param name="Enable">A value to provide a hint to the device that this request must have the best possible location accuracy.</param>
    procedure SetHighAccuracy(Enable: Boolean)
    begin
        LocationPageImpl.SetHighAccuracy(Enable);
    end;

    /// <summary>
    /// Sets a timeout for the location request.
    /// </summary>
    /// <param name="Timeout">The maximum length of time (milliseconds) that is allowed to pass to a location request.</param>
    procedure SetTimeout(Timeout: Integer)
    begin
        LocationPageImpl.SetTimeout(Timeout);
    end;

    /// <summary>
    /// Sets a maximum age for the location request.
    /// </summary>
    /// <param name="Age">The maximum length of time (milliseconds) of a cached location.</param>
    procedure SetMaximumAge(Age: Integer)
    begin
        LocationPageImpl.SetMaximumAge(Age);
    end;

    /// <summary>
    /// Gets whether the device should have the best possible location accuracy
    /// </summary>
    /// <returns>Whether high accuracy is set. A value to provide a hint to the device that this request must have the best possible location accuracy.</returns>
    procedure GetHighAccuracy(): Boolean
    begin
        exit(LocationPageImpl.GetHighAccuracy());
    end;

    /// <summary>
    /// Get the timeout for the location request.
    /// </summary>
    /// <returns>The maximum length of time (milliseconds) that is allowed to pass to a location request.</returns>
    procedure GetTimeout(): Integer
    begin
        exit(LocationPageImpl.GetTimeout());
    end;

    /// <summary>
    /// Gets the maximum age for the location request.
    /// </summary>
    /// <returns>The maximum length of time (milliseconds) of a cached location.</returns>
    procedure GetMaximumAge(): Integer
    begin
        exit(LocationPageImpl.GetMaximumAge());
    end;

    trigger LocationProvider::LocationChanged(Location: DotNet Location)
    begin
        LocationPageImpl.LocationInteractionOnLocationAvailable(Location);
        CurrPage.Close();
    end;
}