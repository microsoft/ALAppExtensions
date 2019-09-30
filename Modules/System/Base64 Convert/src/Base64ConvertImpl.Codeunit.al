// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 4111 "Base64 Convert Impl."
{
    Access = Internal;
    SingleInstance = true;

    procedure ToBase64(String: Text): Text
    begin
        exit(ToBase64(String, false));
    end;

    procedure ToBase64(String: Text; InsertLineBreaks: Boolean): Text
    var
        Convert: DotNet Convert;
        Encoding: DotNet Encoding;
        Base64FormattingOptions: DotNet Base64FormattingOptions;
        Base64String: Text;
    begin
        if String = '' then
            exit('');

        if InsertLineBreaks then
            Base64String := Convert.ToBase64String(Encoding.UTF8().GetBytes(String), Base64FormattingOptions.InsertLineBreaks)
        else
            Base64String := Convert.ToBase64String(Encoding.UTF8().GetBytes(String));

        exit(Base64String);
    end;

    procedure ToBase64(InStream: InStream): Text
    begin
        exit(ToBase64(InStream, false));
    end;

    procedure ToBase64(InStream: InStream; InsertLineBreaks: Boolean): Text
    var
        Convert: DotNet Convert;
        MemoryStream: DotNet MemoryStream;
        InputArray: DotNet Array;
        Base64FormattingOptions: DotNet Base64FormattingOptions;
        Base64String: Text;
    begin
        MemoryStream := MemoryStream.MemoryStream();
        CopyStream(MemoryStream, InStream);
        InputArray := MemoryStream.ToArray();

        if InsertLineBreaks then
            Base64String := Convert.ToBase64String(InputArray, Base64FormattingOptions.InsertLineBreaks)
        else
            Base64String := Convert.ToBase64String(InputArray);

        MemoryStream.Close();
        exit(Base64String);
    end;

    procedure FromBase64(Base64String: Text): Text
    var
        Convert: DotNet Convert;
        Encoding: DotNet Encoding;
        OutputString: Text;
    begin
        if Base64String = '' then
            exit('');

        OutputString := Encoding.UTF8().GetString(Convert.FromBase64String(Base64String));
        exit(OutputString);
    end;

    procedure FromBase64(Base64String: Text; OutStream: OutStream)
    var
        Convert: DotNet Convert;
        MemoryStream: DotNet MemoryStream;
        ConvertedArray: DotNet Array;
    begin
        if Base64String <> '' then begin
            ConvertedArray := Convert.FromBase64String(Base64String);
            MemoryStream := MemoryStream.MemoryStream(ConvertedArray);
            MemoryStream.WriteTo(OutStream);
            MemoryStream.Close();
        end;
    end;
}

