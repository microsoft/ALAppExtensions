// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 8955 "AFS Format Helper"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    [NonDebuggable]
    procedure AppendToUri(var UriText: Text; ParameterIdentifier: Text; ParameterValue: Text)
    var
        UriBuilder: Codeunit "Uri Builder";
        Uri: Codeunit Uri;
    begin
        UriBuilder.Init(UriText);
        if ParameterIdentifier <> '' then
            UriBuilder.AddQueryParameter(ParameterIdentifier, ParameterValue)
        else
            UriBuilder.AddQueryFlag(ParameterValue);
        UriBuilder.GetUri(Uri);
        UriText := Uri.GetAbsoluteUri();
    end;

    [NonDebuggable]
    procedure RemoveCurlyBracketsFromString("Value": Text): Text
    begin
        exit(DelChr("Value", '=', '{}'));
    end;

    procedure ConvertToDateTime(PropertyValue: Text): DateTime
    var
        NewDateTime: DateTime;
    begin
        NewDateTime := 0DT;
        // PropertyValue is something like the following: 'Mon, 24 May 2021 12:25:27 GMT'
        // 'Evaluate' converts these correctly
        Evaluate(NewDateTime, PropertyValue);
        exit(NewDateTime);
    end;

    procedure ConvertToInteger(PropertyValue: Text): Integer
    var
        NewInteger: Integer;
    begin
        if Evaluate(NewInteger, PropertyValue) then
            exit(NewInteger);
    end;

    procedure ConvertToEnum(FieldName: Text; PropertyValue: Text): Variant
    begin
        if FieldName = 'Resource Type' then
            case LowerCase(PropertyValue) of
                LowerCase(Format(Enum::"AFS File Resource Type"::File)):
                    exit(Enum::"AFS File Resource Type"::File);
                LowerCase(Format(Enum::"AFS File Resource Type"::Directory)):
                    exit(Enum::"AFS File Resource Type"::Directory);
            end;
    end;

    procedure GetRfc1123DateTime(MyDateTime: DateTime): Text
    begin
        exit(FormatDateTime(MyDateTime, 'R')); // https://go.microsoft.com/fwlink/?linkid=2210384
    end;

    local procedure FormatDateTime(MyDateTime: DateTime; FormatSpecifier: Text): Text
    var
        DateTimeAsXmlString: Text;
        DateTimeDotNet: DotNet DateTime;
    begin
        DateTimeAsXmlString := Format(MyDateTime, 0, 9); // Format as XML, e.g.: 2020-11-11T08:50:07.553Z
        exit(DateTimeDotNet.Parse(DateTimeAsXmlString).ToUniversalTime().ToString(FormatSpecifier));
    end;
}