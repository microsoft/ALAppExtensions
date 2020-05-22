// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Specifies the location status.
/// </summary>
enum 50107 "Location Status"
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
    value(1; NoData)
    {
        Caption = 'No data';
    }

    /// <summary>
    /// Timed out (location information not obtained in due time).
    /// </summary>
    value(2; TimedOut)
    {
        Caption = 'Timed out';
    }

    /// <summary>
    /// Not available (for example user denied app access to location).
    /// </summary>
    value(3; NotAvailable)
    {
        Caption = 'Not available';
    }
}