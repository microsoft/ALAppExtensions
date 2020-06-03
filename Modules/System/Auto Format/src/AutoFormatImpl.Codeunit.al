// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 59 "Auto Format Impl."
{
    Access = Internal;
    SingleInstance = false;

    var
        AutoFormat: Codeunit "Auto Format";

    procedure ResolveAutoFormat(AutoFormatType: Enum "Auto Format"; AutoFormatExpr: Text[80]): Text[80]
    var
        Result: Text[80];
        Resolved: Boolean;
        EnumType: Enum "Auto Format";
    begin
        case AutoFormatType of
            EnumType::DefaultFormat:
                begin
                    Result := '';
                    Resolved := TRUE;
                end;
            EnumType::CustomFormatExpr:
                begin
                    Result := AutoFormatExpr;
                    Resolved := TRUE;
                end;
            else
                AutoFormat.OnResolveAutoFormat(AutoFormatType, AutoFormatExpr, Result, Resolved);
        end;

        if Resolved then
            exit(Result);
        exit('');
    end;

    procedure ReadRounding(): Decimal
    var
        AmountRoundingPrecision: Decimal;
    begin
        AutoFormat.OnReadRounding(AmountRoundingPrecision);
        exit(AmountRoundingPrecision);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"UI Helper Triggers", 'AutoFormatTranslate', '', false, false)]
    local procedure DoResolveAutoFormat(AutoFormatType: Integer; AutoFormatExpr: Text[80]; var Translation: Text[80])
    begin
        Translation := ResolveAutoFormat("Auto Format".FromInteger(AutoFormatType), AutoFormatExpr);
        AutoFormat.OnAfterResolveAutoFormat("Auto Format".FromInteger(AutoFormatType), AutoFormatExpr, Translation);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"UI Helper Triggers", 'GetDefaultRoundingPrecision', '', false, false)]
    local procedure GetDefaultRoundingPrecision(var AmountRoundingPrecision: Decimal)
    begin
        AmountRoundingPrecision := ReadRounding();
    end;
}