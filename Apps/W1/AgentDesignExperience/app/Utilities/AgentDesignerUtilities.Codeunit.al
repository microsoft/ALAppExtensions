// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents.Designer;

using System;

codeunit 4365 "Agent Designer Utilities"
{
    InherentPermissions = X;
    InherentEntitlements = X;

    /// <summary>
    /// Ensures the provided content is sanitized to prevent XSS attacks.
    /// The sanitization process removes potentially harmful HTML tags and does some encoding.
    /// </summary>
    /// <param name="Content">The content.</param>
    /// <returns>The sanitized content.</returns>
    procedure SanitizeContent(Content: Text): Text
    var
        AppHTMLSanitizer: DotNet AppHtmlSanitizer;
    begin
        AppHTMLSanitizer := AppHTMLSanitizer.AppHtmlSanitizer();
        exit(AppHTMLSanitizer.SanitizeEmail(Content));
    end;

    /// <summary>
    /// Ensures the provided content is encoded to prevent XSS attacks.
    /// </summary>
    /// <param name="Content">The content.</param>
    /// <returns>The encoded content.</returns>
    internal procedure EncodeContent(Content: Text): Text
    var
        HttpUtility: DotNet HttpUtility;
    begin
        HttpUtility := HttpUtility.HttpUtility();
        exit(HttpUtility.HtmlEncode(Content));
    end;
}