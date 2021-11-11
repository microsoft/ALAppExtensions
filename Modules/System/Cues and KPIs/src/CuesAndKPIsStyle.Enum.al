// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// This enum has the styles for the cues and KPIs on RoleCenter pages.
/// <remarks>The values match the original option field on the Cue Setup table, values 1 to 6 are blank options to be extended.</remarks>
/// </summary>
enum 9701 "Cues And KPIs Style"
{
    Extensible = true;

    /// <summary>
    /// Specifies that no style will be used when rendering the cue.
    /// </summary>
    value(0; None)
    {
        Caption = 'None';
    }

    /// <summary>
    /// Specifies that the Favorable style will be used when rendering the cue.
    /// </summary>
    value(7; Favorable)
    {
        Caption = 'Favorable';
    }

    /// <summary>
    /// Specifies that the Unfavorable style will be used when rendering the cue.
    /// </summary>
    value(8; Unfavorable)
    {
        Caption = 'Unfavorable';
    }

    /// <summary>
    /// Specifies that the Ambiguous style will be used when rendering the cue.
    /// </summary>
    value(9; Ambiguous)
    {
        Caption = 'Ambiguous';
    }
    /// <summary>
    /// Specifies that the Subordinate style will be used when rendering the cue.
    /// </summary>
    value(10; Subordinate)
    {
        Caption = 'Subordinate';
    }
}
