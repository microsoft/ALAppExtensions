// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Specifies the type of a spotlight tour.
/// </summary>
enum 1996 "Spotlight Tour Type"
{
    Access = Public;
    Extensible = false;

    /// <summary>
    /// Default value - none.
    /// </summary>
    value(0; "None")
    {
        Caption = 'None';
    }

    /// <summary>
    /// Specifies that the tour spotlights the Open in Excel functionality on the page.
    /// </summary>
    value(1; "Open in Excel")
    {
        Caption = 'Open in Excel';
    }

    /// <summary>
    /// Specifies that the tour spotlights the Share to Teams functionality on the page.
    /// </summary>
    value(2; "Share to Teams")
    {
        Caption = 'Share to Teams';
    }
}