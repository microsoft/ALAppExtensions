// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Reminder;

tableextension 13637 "OIOUBL-Reminder Line" extends "Reminder Line"
{
    fields
    {
        field(13631; "OIOUBL-Account Code"; Text[30])
        {
            Caption = 'Account Code';

            trigger OnValidate()
            begin
                if (Type = Type::" ") and ("OIOUBL-Account Code" <> '') then
                    ERROR(EmptyTypeWithAccCodeErr, FIELDCAPTION("OIOUBL-Account Code"), FIELDCAPTION(Type), Type);
            end;
        }

        modify(Type)
        {
            trigger OnBeforeValidate()
            var
                ReminderHeader: Record "Reminder Header";
            begin
                if Type = xRec.Type then
                    exit;

                if not ReminderHeader.Get("Reminder No.") then
                    exit;

                "OIOUBL-Account Code" := ReminderHeader."OIOUBL-Account Code"; // OIOXML

                if (Type <> Type::" ") AND ("OIOUBL-Account Code" = '') then
                    "OIOUBL-Account Code" := ReminderHeader."OIOUBL-Account Code"
                else
                    "OIOUBL-Account Code" := '';
            end;
        }
    }
    keys
    {
    }

    var
        EmptyTypeWithAccCodeErr: Label 'You cannot enter %1 if %2 is "%3".', Comment = '%1 = Value of Account Code Field, %2 = Type Caption, %3 = Type value';
}
