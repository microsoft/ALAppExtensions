// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9060 "Auth. Format Helper"
{
    Access = Internal;

    procedure NewLine(): Text
    var
        LF: Char;
    begin
        LF := 10;
        exit(Format(LF));
    end;

    procedure GetIso8601DateTime(MyDateTime: DateTime): Text
    begin
        exit(FormatDateTime(MyDateTime, 's')); // https://docs.microsoft.com/en-us/dotnet/standard/base-types/standard-date-and-time-format-strings
    end;

    procedure GetRfc1123DateTime(MyDateTime: DateTime): Text
    begin
        exit(FormatDateTime(MyDateTime, 'R')); // https://docs.microsoft.com/en-us/dotnet/standard/base-types/standard-date-and-time-format-strings
    end;

    local procedure FormatDateTime(MyDateTime: DateTime; FormatSpecifier: Text): Text
    var
        DateTimeAsXmlString: Text;
        DotNetDateTime: DotNet DateTime;
    begin
        DateTimeAsXmlString := Format(MyDateTime, 0, 9); // Format as XML, e.g.: 2020-11-11T08:50:07.553Z
        exit(DotNetDateTime.Parse(DateTimeAsXmlString).ToUniversalTime().ToString(FormatSpecifier));
    end;

    [NonDebuggable]
    procedure GetAccessKeyHashCode(StringToSign: Text; AccessKey: Text): Text;
    var
        CryptographyManagement: Codeunit "Cryptography Management";
        HashAlgorithmType: Option HMACMD5,HMACSHA1,HMACSHA256,HMACSHA384,HMACSHA512;
    begin
        exit(CryptographyManagement.GenerateBase64KeyedHashAsBase64String(StringToSign, AccessKey, HashAlgorithmType::HMACSHA256));
    end;
}