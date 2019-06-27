// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 59 "Auto Format Management Impl."
{
    Access = Internal;
    SingleInstance = false;

    var
        AutoFormatManagement: Codeunit "Auto Format Management";

    [Scope('OnPrem')]
    procedure ResolveAutoFormat(AutoFormatType: Integer; AutoFormatExpr: Text[80]): Text[80]
    var
        Result: Text[80];
        Resolved: Boolean;
    begin
        CASE AutoFormatType OF
            0:
                BEGIN
                    Result := '';
                    Resolved := TRUE;
                END;
            11:
                BEGIN
                    Result := AutoFormatExpr;
                    Resolved := TRUE;
                END;
            ELSE
                AutoFormatManagement.OnResolveAutoFormat(AutoFormatType, AutoFormatExpr, Result, Resolved);
        END;

        IF Resolved THEN
            EXIT(Result);
        EXIT('');
    end;

    [Scope('OnPrem')]
    procedure ReadRounding(): Decimal
    var
        AmountRoundingPrecision: Decimal;
    begin
        AutoFormatManagement.OnReadRounding(AmountRoundingPrecision);
        EXIT(AmountRoundingPrecision);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"UI Helper Triggers", 'AutoFormatTranslate', '', false, false)]
    local procedure DoResolveAutoFormat(AutoFormatType: Integer; AutoFormatExpr: Text[80]; var Translation: Text[80])
    begin
        Translation := ResolveAutoFormat(AutoFormatType, AutoFormatExpr);
        AutoFormatManagement.OnAfterResolveAutoFormat(AutoFormatType, AutoFormatExpr, Translation);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"UI Helper Triggers", 'GetDefaultRoundingPrecision', '', false, false)]
    local procedure GetDefaultRoundingPrecision(var AmountRoundingPrecision: Decimal)
    begin
        AmountRoundingPrecision := ReadRounding();
    end;
}