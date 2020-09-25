// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Specifies the type of a summary.
/// </summary>
enum 2716 "Summary Type"
{
    Extensible = false;
    /// <summary>
    /// Specifies the default type that represents caption of a object
    /// </summary>
    value(0; Caption)
    {
        Caption = 'Caption';
    }
    /// <summary>
    /// Specifies the type that represents fields defined in a brick fieldgroup
    /// </summary>
    value(1; Brick)
    {
        Caption = 'Brick';
    }
}
