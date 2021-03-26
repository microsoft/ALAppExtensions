// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Specifies the available formats in which the user can generate documents from Word templates.
/// </summary>
enum 9987 "Word Templates Save Format"
{
    Extensible = false;

    /// <summary>
    /// Saves the document in the Microsoft Word 97 - 2007 Document format.
    /// </summary>
    value(10; Doc)
    {
    }

    /// <summary>
    /// Saves the document as an Office Open XML WordprocessingML Document (macro-free).
    /// </summary>
    value(20; Docx)
    {
    }

    /// <summary>
    /// Saves the document as PDF (Adobe Portable Document) format.
    /// </summary>
    value(40; PDF)
    {
    }

    /// <summary>
    /// Saves the document in the HTML format.
    /// </summary>
    value(50; Html)
    {
    }

    /// <summary>
    /// Saves the document in the plain text format.
    /// </summary>
    value(70; Text)
    {
    }
}