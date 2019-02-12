// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

tableextension 13642 "OIOUBL-Fin. Charge Memo Line" extends "Finance Charge Memo Line"
{
    fields
    {
        field(13631; "OIOUBL-Account Code"; Text[30])
        {
            Caption = 'Account Code';
            trigger OnValidate()
            begin
                if (Type = Type::" ") AND ("OIOUBL-Account Code" <> '') then
                    ERROR(EmptyTypeWithAccCodeErr, FIELDCAPTION("OIOUBL-Account Code"), FIELDCAPTION(Type), Type);
            end;
        }

        modify(Type)
        {
            trigger OnAfterValidate()
            var
                FinChargeMemoHeader: Record "Finance Charge Memo Header";
            begin
                if not FinChargeMemoHeader.Get("Finance Charge Memo No.") then
                    exit;

                "OIOUBL-Account Code" := FinChargeMemoHeader."OIOUBL-Account Code";
            end;
        }
    }
    keys
    {
    }

    var
        EmptyTypeWithAccCodeErr: Label 'You cannot enter %1 if %2 is "%3".', Comment = '%1 = Value of Account Code Field, %2 = Type Caption, %3 = Type value';
}