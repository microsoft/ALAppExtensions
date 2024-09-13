namespace Microsoft.SubscriptionBilling;

using System.Text;
using Microsoft.Utilities;

codeunit 8015 "Report Formatting"
{
    Access = Internal;
    SingleInstance = true;

    procedure AddValueToBuffer(var NameValueBuffer: Record "Name/Value Buffer"; Name: Text; Value: Text)
    begin
        AddValueToBuffer(NameValueBuffer, Name, Value, '');
    end;

    procedure AddValueToBuffer(var NameValueBuffer: Record "Name/Value Buffer"; Name: Text; Value: Text; "Value Long": Text)
    var
        KeyIndex: Integer;
    begin
        if (Value <> '') or ("Value Long" <> '') then begin
            Clear(NameValueBuffer);
            if NameValueBuffer.FindLast() then
                KeyIndex := NameValueBuffer.ID + 1;

            NameValueBuffer.Init();
            NameValueBuffer.ID := KeyIndex;
            NameValueBuffer.Name := CopyStr(Name, 1, MaxStrLen(NameValueBuffer.Name));
            NameValueBuffer.Value := CopyStr(Value, 1, MaxStrLen(NameValueBuffer.Value));
            NameValueBuffer."Value Long" := CopyStr("Value Long", 1, MaxStrLen(NameValueBuffer."Value Long"));
            NameValueBuffer.Insert(false);
        end;
    end;

    procedure GetValueFromBuffer(var NameValueBuffer: Record "Name/Value Buffer"; Name: Text) Value: Text
    begin
        if Name <> '' then begin
            NameValueBuffer.SetRange(Name, Name);
            if NameValueBuffer.FindFirst() then
                exit(NameValueBuffer.Value);
        end;
        exit('');
    end;

    procedure BlankZeroFormatting(DecimalValue: Decimal): Text
    begin
        if DecimalValue = 0 then
            exit('');
        exit(Format(DecimalValue));
    end;

    procedure BlankZeroWithCurrencyCode(DecimalValue: Decimal; CurrencyCode: Code[20]; AutoFormatType: Enum "Auto Format"): Text
    var
        AutoFormat: Codeunit "Auto Format";
    begin
        if DecimalValue = 0 then
            exit('');
        exit(Format(DecimalValue, 0, AutoFormat.ResolveAutoFormat(AutoFormatType, CurrencyCode)));
    end;

    procedure FormatTextVariableFromDecimalValue(var FormattedTextVariable: Text; DecimalValue: Decimal; AutoFormatType: Enum "Auto Format"; CurrencyCode: Code[10])
    var
        AutoFormat: Codeunit "Auto Format";
    begin
        if DecimalValue = 0 then
            FormattedTextVariable := ''
        else
            FormattedTextVariable := Format(DecimalValue, 0, AutoFormat.ResolveAutoFormat(AutoFormatType, CurrencyCode));
    end;
}