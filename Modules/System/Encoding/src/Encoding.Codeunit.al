// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Codeunig that exposes encoding functionality.
/// </summary>
codeunit 1486 "Encoding"
{
    Access = Public;

    var
        EncodingImpl: Codeunit "Encoding Impl.";

    /// <summary>
    /// Converts a text from one encoding to another.
    /// </summary>
    /// <param name="SourceCodepage">Encoding code page identifier of the source text. Valid values are between 0 and 65535.</param>
    /// <param name="DestinationCodepage">Encoding code page identifier for the result text. Valid values are between 0 and 65535.</param>
    /// <param name="Text">The text to convert.</param>
    /// <returns>The text in the destination encoding.</returns>
    procedure Convert(SourceCodepage: Integer; DestinationCodepage: Integer; Text: Text): Text
    begin
        exit(EncodingImpl.Convert(SourceCodepage, DestinationCodepage, Text));
    end;
}