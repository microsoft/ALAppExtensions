// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

tableextension 13647 "OIOUBL-Sales Line" extends "Sales Line"
{
    fields
    {
        field(13631; "OIOUBL-Account Code"; Text[30])
        {
            Caption = 'Account Code';

            trigger OnValidate()
            begin
                if (Type = Type::" ") AND ("OIOUBL-Account Code" <> '') then
                    ERROR(InvalidAccountCodeErr, FIELDCAPTION("OIOUBL-Account Code"), FIELDCAPTION(Type), Type);
            end;
        }

        modify("No.")
        {
            trigger OnAfterValidate()
            var
                SalesHeader: Record "Sales Header";
            begin
                if not SalesHeader.Get("Document Type", "Document No.") then
                    exit;

                "OIOUBL-Account Code" := SalesHeader."OIOUBL-Account Code";
            end;
        }
    }
    keys
    {
    }

    var
        InvalidAccountCodeErr: Label 'You cannot enter %1 if %2 is "%3".', Comment = '%1 = Value of Account Code Field, %2 = Type Caption, %3 = Type value';
}