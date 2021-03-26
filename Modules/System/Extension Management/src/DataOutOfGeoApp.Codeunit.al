// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides functions for adding, removing or checking if an App ID is within the list of apps that send data out of the Geolocation.
/// </summary>
codeunit 2506 "Data Out Of Geo. App"
{
    var
        DataOutOfGeoAppImpl: Codeunit "Data Out Of Geo. App Impl.";

    /// <summary>
    /// Adds an App ID to the list of apps that have data out of the geolocation.
    /// </summary>
    /// <param name="AppID">The App ID of the extension.</param>
    /// <returns>The result of adding to the list. True if the data was added; false otherwise.</returns>
    [Scope('OnPrem')]
    procedure Add(AppID: Guid): Boolean
    begin
        exit(DataOutOfGeoAppImpl.Add(AppID));
    end;

    /// <summary>
    /// Removes an App ID from the list of apps that have data out of the geolocation.
    /// </summary>
    /// <param name="AppID">The App ID of the extension.</param>
    /// <returns>The result of removing from the list. True if the data was removed; false otherwise.</returns>
    [Scope('OnPrem')]
    procedure Remove(AppID: Guid): Boolean
    begin
        exit(DataOutOfGeoAppImpl.Remove(AppID));
    end;

    /// <summary>
    /// Checks if an App ID is in the list of apps that have data out of the geolocation.
    /// </summary>
    /// <param name="AppID">The App ID of the extension.</param>
    /// <returns>The result of checking whether an AppID is the list. True if the AppID was found; false otherwise.</returns>
    [Scope('OnPrem')]
    procedure Contains(AppID: Guid): Boolean
    begin
        exit(DataOutOfGeoAppImpl.Contains(AppID));
    end;

    /// <summary>
    /// Checks if any of the already installed extensions are in the list of apps that have data out of the geolocation.
    /// </summary>
    /// <returns>The result of checking whether an already installed extension is in the list apps that have data out of the geolocation. True if at least one installed extension was found in the list; false otherwise.</returns>
    [Scope('OnPrem')]
    procedure AlreadyInstalled(): Boolean
    begin
        exit(DataOutOfGeoAppImpl.AlreadyInstalled());
    end;
}