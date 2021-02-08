// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides helper functions to convert data
/// </summary>
codeunit 1485 "Encoding"
{
    Access = Public;

    var
        EncodingImpl: Codeunit "Encoding Impl.";

    /// <summary>
    /// Converts a text from one encoding to another.
    /// </summary>
    /// <param name="SrcCodepage">Code page identifier of the source.</param>
    /// <param name="DstCodepage">Code page identifier of the output.</param>
    /// <param name="Text">The text containing the characters to convert.</param>
    procedure Convert(SrcCodepage: Integer; DstCodepage: Integer; Text: Text): Text
    begin
        exit(EncodingImpl.Convert(SrcCodepage, DstCodepage, Text));
    end;
}