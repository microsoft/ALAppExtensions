// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Specifies the status of the geographical location data.
/// </summary>
enum 7568 "Geolocation Status"
{
    Extensible = false;

    /// <summary>
    /// Available
    /// </summary>
    value(0; Available)
    {
        Caption = 'Available';
    }

    /// <summary>
    /// No data (no data could be obtained).
    /// </summary>
    value(1; "No Data")
    {
        Caption = 'No Data';
    }

    /// <summary>
    /// Timed out (location information not obtained in due time).
    /// </summary>
    value(2; "Timed Out")
    {
        Caption = 'Timed Out';
    }

    /// <summary>
    /// Not available (for example user denied app access to location).
    /// </summary>
    value(3; "Not Available")
    {
        Caption = 'Not Available';
    }
}