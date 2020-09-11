// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Converts text to and from its base-64 representation.
/// </summary>
codeunit 4110 "Base64 Convert"
{
    Access = Public;
    SingleInstance = true;

    var
        Base64ConvertImpl: Codeunit "Base64 Convert Impl.";

    /// <summary>
    /// Converts the value of the input string to its equivalent string representation that is encoded with base-64 digits.
    /// </summary>
    /// <param name="String">The string to convert.</param>
    /// <returns>The string representation, in base-64, of the input string.</returns>
    procedure ToBase64(String: Text): Text
    begin
        exit(Base64ConvertImpl.ToBase64(String));
    end;

    /// <summary>
    /// Converts the value of the input string to its equivalent string representation that is encoded with base-64 digits.
    /// </summary>
    /// <param name="String">The string to convert.</param>
    /// <param name="TextEncoding">The TextEncoding for the input string.</param>
    /// <returns>The string representation, in base-64, of the input string.</returns>
    procedure ToBase64(String: Text; TextEncoding: TextEncoding): Text
    begin
        exit(Base64ConvertImpl.ToBase64(String, TextEncoding));
    end;

    /// <summary>
    /// Converts the value of the input string to its equivalent string representation that is encoded with base-64 digits.
    /// </summary>
    /// <param name="String">The string to convert.</param>
    /// <param name="TextEncoding">The TextEncoding for the input string.</param>
    /// <param name="Codepage">The Codepage if TextEncoding is MsDos or Windows.</param>
    /// <returns>The string representation, in base-64, of the input string.</returns>
    procedure ToBase64(String: Text; TextEncoding: TextEncoding; Codepage: Integer): Text
    begin
        exit(Base64ConvertImpl.ToBase64(String, TextEncoding, Codepage));
    end;

    /// <summary>
    /// Converts the value of the input string to its equivalent string representation that is encoded with base-64 digits.
    /// </summary>
    /// <param name="String">The string to convert.</param>
    /// <param name="InsertLineBreaks">Specifies whether line breaks are inserted in the output.
    /// If true, inserts line breaks after every 76 characters.</param>
    /// <returns>The string representation, in base-64, of the input string.</returns>
    procedure ToBase64(String: Text; InsertLineBreaks: Boolean): Text
    begin
        exit(Base64ConvertImpl.ToBase64(String, InsertLineBreaks));
    end;
    /// <summary>
    /// Converts the value of the input string to its equivalent string representation that is encoded with base-64 digits.
    /// </summary>
    /// <param name="String">The string to convert.</param>
    /// <param name="InsertLineBreaks">Specifies whether line breaks are inserted in the output.
    /// If true, inserts line breaks after every 76 characters.</param>
    /// <param name="TextEncoding">The TextEncoding for the input string.</param>
    /// <param name="Codepage">The Codepage if TextEncoding is MsDos or Windows.</param>
    /// <returns>The string representation, in base-64, of the input string.</returns>
    procedure ToBase64(String: Text; InsertLineBreaks: Boolean; TextEncoding: TextEncoding; Codepage: Integer): Text
    begin
        exit(Base64ConvertImpl.ToBase64(String, InsertLineBreaks, TextEncoding, Codepage));
    end;

    /// <summary>
    /// Converts the value of the input stream to its equivalent string representation that is encoded with base-64 digits.
    /// </summary>
    /// <param name="InStream">The stream to read the input from.</param>
    /// <returns>The string representation, in base-64, of the input string.</returns>
    procedure ToBase64(InStream: InStream): Text
    begin
        exit(Base64ConvertImpl.ToBase64(InStream));
    end;

    /// <summary>
    /// Converts the value of the input stream to its equivalent string representation that is encoded with base-64 digits.
    /// </summary>
    /// <param name="InStream">The stream to read the input from.</param>
    /// <param name="InsertLineBreaks">Specifies whether line breaks are inserted in the output.
    /// If true, inserts line breaks after every 76 characters.</param>
    /// <returns>The string representation, in base-64, of the input string.</returns>
    procedure ToBase64(InStream: InStream; InsertLineBreaks: Boolean): Text
    begin
        exit(Base64ConvertImpl.ToBase64(InStream, InsertLineBreaks));
    end;

    /// <summary>
    /// Converts the specified string, which encodes binary data as base-64 digits, to an equivalent regular string.
    /// </summary>
    /// <param name="Base64String">The string to convert.</param>
    /// <returns>Regular string that is equivalent to the input base-64 string.</returns>
    /// <error>The length of Base64String, ignoring white-space characters, is not zero or a multiple of 4.</error>
    /// <error>The format of Base64String is invalid. Base64String contains a non-base-64 character, more than two padding characters,
    /// or a non-white space-character among the padding characters.</error>
    procedure FromBase64(Base64String: Text): Text
    begin
        exit(Base64ConvertImpl.FromBase64(Base64String));
    end;

    /// <summary>
    /// Converts the specified string, which encodes binary data as base-64 digits, to an equivalent regular string.
    /// </summary>
    /// <param name="Base64String">The string to convert.</param>
    /// <param name="TextEncoding">The TextEncoding for the input string.</param>
    /// <returns>Regular string that is equivalent to the input base-64 string.</returns>
    /// <error>The length of Base64String, ignoring white-space characters, is not zero or a multiple of 4.</error>
    /// <error>The format of Base64String is invalid. Base64String contains a non-base-64 character, more than two padding characters,
    /// or a non-white space-character among the padding characters.</error>
    procedure FromBase64(Base64String: Text; TextEncoding: TextEncoding): Text
    begin
        exit(Base64ConvertImpl.FromBase64(Base64String, TextEncoding));
    end;

    /// <summary>
    /// Converts the specified string, which encodes binary data as base-64 digits, to an equivalent regular string.
    /// </summary>
    /// <param name="Base64String">The string to convert.</param>
    /// <param name="TextEncoding">The TextEncoding for the inout string.</param>
    /// <param name="Codepage">The Codepage if TextEncoding is MsDos or Windows.</param>
    /// <returns>Regular string that is equivalent to the input base-64 string.</returns>
    /// <error>The length of Base64String, ignoring white-space characters, is not zero or a multiple of 4.</error>
    /// <error>The format of Base64String is invalid. Base64String contains a non-base-64 character, more than two padding characters,
    /// or a non-white space-character among the padding characters.</error>
    procedure FromBase64(Base64String: Text; TextEncoding: TextEncoding; Codepage: Integer): Text
    begin
        exit(Base64ConvertImpl.FromBase64(Base64String, TextEncoding, Codepage));
    end;

    /// <summary>
    /// Converts the specified string, which encodes binary data as base-64 digits, to an equivalent regular string.
    /// </summary>
    /// <param name="Base64String">The string to convert.</param>
    /// <param name="OutStream">The stream to write the output to.</param>
    /// <returns>Regular string that is equivalent to the input base-64 string.</returns>
    /// <error>The length of Base64String, ignoring white-space characters, is not zero or a multiple of 4.</error>
    /// <error>The format of Base64String is invalid. Base64String contains a non-base-64 character, more than two padding characters,
    /// or a non-white space-character among the padding characters.</error>
    procedure FromBase64(Base64String: Text; OutStream: OutStream)
    begin
        Base64ConvertImpl.FromBase64(Base64String, OutStream);
    end;
}
