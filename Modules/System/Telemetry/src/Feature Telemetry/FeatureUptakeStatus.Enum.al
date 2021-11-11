// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Specifies the uptake status of an application feature.
/// </summary>
enum 8703 "Feature Uptake Status"
{
    Access = Public;
    Extensible = false;

    /// <summary>
    /// The feature has not been discovered.
    /// </summary>
    value(0; "Undiscovered")
    {
        Caption = 'Undiscovered', Locked = true;
    }

    /// <summary>
    /// The feature has been discovered.
    /// </summary>
    value(1; "Discovered")
    {
        Caption = 'Discovered', Locked = true;
    }

    /// <summary>
    /// The feature has been set up.
    /// </summary>
    value(2; "Set up")
    {
        Caption = 'Set up', Locked = true;
    }

    /// <summary>
    /// The feature has been used.
    /// </summary>
    value(3; "Used")
    {
        Caption = 'Used', Locked = true;
    }
}