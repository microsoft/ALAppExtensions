// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Specifies orientations used for printing. The value of each ID corresponds to the value assigned by Universal Print.
/// See https://docs.microsoft.com/en-us/graph/api/resources/printercapabilities.
/// </summary>
enum 2751 "Universal Printer Orientation"
{
    Extensible = false;

    /// <summary>
    /// The printer will print documents in the portrait orientation.
    /// </summary>
    value(3; portrait)
    {
        Caption = 'portrait';
    }

    /// <summary>
    /// The printer will print documents in the landscape orientation.
    /// </summary>
    value(4; landscape)
    {
        Caption = 'landscape';
    }

    /// <summary>
    /// The printer will print documents in the reverse landscape orientation.
    /// </summary>
    value(5; reverseLandscape)
    {
        Caption = 'reverseLandscape';
    }

    /// <summary>
    /// The printer will print documents in the reverse portrait orientation.
    /// </summary>
    value(6; reversePortrait)
    {
        Caption = 'reversePortrait';
    }
}
