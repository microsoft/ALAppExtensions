// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// This page shows instructional text for the user and is opened when the geographical location of the client device is requested.
/// </summary>
page 7568 Geolocation
{
    Caption = 'Geolocation request';
    PageType = Card;
    Editable = false;
    LinksAllowed = false;
    Extensible = false;

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
        GeolocationImpl: Codeunit "Geolocation Impl.";
        [RunOnClient]
        [WithEvents]
        LocationProvider: DotNet LocationProvider;
        LocationAvailable: Boolean;

    internal procedure SetGeolocationImpl(GeolocImpl: Codeunit "Geolocation Impl.")
    begin
        GeolocationImpl := GeolocImpl;
    end;

    /// <summary>
    /// When the page opens it requests the location from the client and shows a view.
    /// After getting the location, the page will close automatically.
    /// </summary>
    trigger OnOpenPage()
    begin
        GeolocationImpl.LocationInteractionOnOpenPage(LocationProvider, LocationAvailable);
    end;

    trigger LocationProvider::LocationChanged(Location: DotNet Location)
    begin
        GeolocationImpl.LocationInteractionOnLocationAvailable(Location);
        CurrPage.Close();
    end;
}