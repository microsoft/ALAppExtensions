// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides functionality for getting geographical location information from the client device.
/// </summary>
codeunit 50100 Location
{
    Access = Public;

    var
        LocationImpl: Codeunit "Location Impl.";

    /// <summary>
    /// Gets a geographical location from the client device and returns it in the the longitude and latitude parameters.
    /// </summary>
    /// <param name="Latitude">...</param>
    /// <param name="Longitude">...</param>
    /// <returns>True if the location is available, the user confirmed to share the location and the location information was successfully retrieved, false otherwise.</returns>
    procedure GetLocation(var Latitude: Decimal; var Longitude: Decimal): Boolean
    begin
        exit(LocationImpl.GetLocation(Latitude, Longitude));
    end;

    /// <summary>
    /// Checks if the location is available on the client device.
    /// </summary>
    /// <returns>True if the location is available; false otherwise.</returns>
    procedure IsAvailable(): Boolean
    begin
        exit(LocationImpl.IsAvailable());
    end;
}