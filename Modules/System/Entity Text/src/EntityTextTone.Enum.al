// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Text;

/// <summary>
/// Enum containing supported tones of text for generation.
/// </summary>
enum 2011 "Entity Text Tone"
{
    Extensible = false;

    /// <summary>
    /// The tone of voice should be formal.
    /// </summary>
    value(0; Formal)
    {
        Caption = 'Formal';
    }

    /// <summary>
    /// The tone of voice should be casual.
    /// </summary>
    value(1; Casual)
    {
        Caption = 'Casual';
    }

    /// <summary>
    /// The tone of voice should be inspiring.
    /// </summary>
    value(2; Inspiring)
    {
        Caption = 'Inspiring';
    }

    /// <summary>
    /// The tone of voice should be upbeat.
    /// </summary>
    value(3; Upbeat)
    {
        Caption = 'Upbeat';
    }

    /// <summary>
    /// The tone of voice should be creative.
    /// </summary>
    value(4; Creative)
    {
        Caption = 'Creative';
    }
}