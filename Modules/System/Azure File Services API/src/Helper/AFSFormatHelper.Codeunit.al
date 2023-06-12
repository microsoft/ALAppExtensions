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
    procedure AppendToUri(var Uri: Text; ParameterIdentifier: Text; ParameterValue: Text)
    var
        ConcatChar: Text;
        AppendType1Lbl: Label '%1%2=%3', Comment = '%1 = Concatenation character, %2 = Parameter Identifer, %3 = Parameter Value', Locked = true;
        AppendType2Lbl: Label '%1%2', Comment = '%1 = Concatenation character, %2 = Parameter Value', Locked = true;
    begin
        ConcatChar := '?';
        if Uri.Contains('?') then
            ConcatChar := '&';
        if ParameterIdentifier <> '' then
            Uri += StrSubstNo(AppendType1Lbl, ConcatChar, ParameterIdentifier, ParameterValue)
        else
            Uri += StrSubstNo(AppendType2Lbl, ConcatChar, ParameterValue)
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
            case PropertyValue of
                Text.LowerCase(Format(Enum::"AFS File Resource Type"::File)):
                    exit(Enum::"AFS File Resource Type"::File);
                Text.LowerCase(Format(Enum::"AFS File Resource Type"::Directory)):
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