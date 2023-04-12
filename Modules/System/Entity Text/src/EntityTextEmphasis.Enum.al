// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Enum containing supported ways to emphasize text for generation.
/// </summary>
enum 2012 "Entity Text Emphasis"
{
    Extensible = false;

    /// <summary>
    /// Do not emphasize a particular quality.
    /// </summary>
    value(0; None)
    {
        Caption = ' ';
    }

    /// <summary>
    /// Emphasizes innovation.
    /// </summary>
    value(1; Innovation)
    {
        Caption = 'Innovation';
    }

    /// <summary>
    /// Emphasizes sustainability.
    /// </summary>
    value(2; Sustainability)
    {
        Caption = 'Sustainability';
    }

    /// <summary>
    /// Emphasizes power.
    /// </summary>
    value(3; Power)
    {
        Caption = 'Power';
    }

    /// <summary>
    /// Emphasizes elegance.
    /// </summary>
    value(4; Elegance)
    {
        Caption = 'Elegance';
    }

    /// <summary>
    /// Emphasizes reliability.
    /// </summary>
    value(5; Reliability)
    {
        Caption = 'Reliability';
    }

    /// <summary>
    /// Emphasizes speed.
    /// </summary>
    value(6; Speed)
    {
        Caption = 'Speed';
    }
}