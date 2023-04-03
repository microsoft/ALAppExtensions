// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Enum containing supported text formats for generation.
/// </summary>
enum 2010 "Entity Text Format"
{
    Extensible = false;

    /// <summary>
    /// Generate a short tagline.
    /// </summary>
    value(0; Tagline)
    {
        Caption = 'Tagline';
    }

    /// <summary>
    /// Generate a paragraph of text.
    /// </summary>
    value(1; Paragraph)
    {
        Caption = 'Paragraph';
    }

    /// <summary>
    /// Generate a tagline and paragraph in one prompt.
    /// </summary>
    value(2; TaglineParagraph)
    {
        Caption = 'Tagline + Paragraph';
    }

    /// <summary>
    /// Generate a brief summary.
    /// </summary>
    value(3; Brief)
    {
        Caption = 'Brief';
    }
}