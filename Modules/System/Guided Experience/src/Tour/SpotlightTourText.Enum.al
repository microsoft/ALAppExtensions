// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Specifies the exact step of a spotlight tour that a text belongs to.
/// </summary>
enum 1997 "Spotlight Tour Text"
{
    Access = Public;
    Extensible = false;

    /// <summary>
    /// The title for the first step in the spotlight tour.
    /// </summary>
    value(0; Step1Title)
    {
        Caption = 'Step1Title', Locked = true;
    }

    /// <summary>
    /// The text for the first step in the spotlight tour.
    /// </summary>
    value(1; Step1Text)
    {
        Caption = 'Step1Text', Locked = true;
    }

    /// <summary>
    /// The title for the second step in the spotlight tour.
    /// </summary>
    value(2; Step2Title)
    {
        Caption = 'Step2Title', Locked = true;
    }

    /// <summary>
    /// The text for the second step in the spotlight tour.
    /// </summary>
    value(3; Step2Text)
    {
        Caption = 'Step2Text', Locked = true;
    }
}