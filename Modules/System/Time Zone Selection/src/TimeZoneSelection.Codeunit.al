// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides basic functionality to lookup page for Time zones. 
/// </summary>
codeunit 9198 "Time Zone Selection"
{
    Access = Public;

    /// <summary>
    /// Opens a window for viewing and selecting a Time Zone.
    /// </summary>
    /// <param name="TimeZoneText">Out parameter with the Time Zone id of the selected Time Zone.</param>
    /// <returns>True if a timezone was selected.</returns>
    procedure LookupTimeZone(var TimeZoneText: Text[180]): Boolean
    var
        TimeZoneSelectionImpl: Codeunit "Time Zone Selection Impl.";
    begin
        exit(TimeZoneSelectionImpl.LookupTimeZone(TimeZoneText));
    end;

    /// <summary>
    /// Validate a time zone text given as input and converts it into a Time Zone ID.
    /// </summary>
    /// <param name="TimeZoneText">The Time Zone text to validate.</param>
    procedure ValidateTimeZone(var TimeZoneText: Text[180])
    var
        TimeZoneSelectionImpl: Codeunit "Time Zone Selection Impl.";
    begin
        TimeZoneSelectionImpl.ValidateTimeZone(TimeZoneText);
    end;

    /// <summary>
    /// Finds the Time Zone that matches the given text and returns its display name.
    /// </summary>
    /// <param name="TimeZoneText">The search query for the Time Zone.</param>
    /// <returns>The Display Name of the Time Zone.</returns>
    procedure GetTimeZoneDisplayName(TimeZoneText: Text[180]): Text[250]
    var
        TimeZoneSelectionImpl: Codeunit "Time Zone Selection Impl.";
    begin
        exit(TimeZoneSelectionImpl.GetTimeZoneDisplayName(TimeZoneText));
    end;
}