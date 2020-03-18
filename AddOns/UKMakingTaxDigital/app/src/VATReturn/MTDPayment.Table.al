// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

table 10531 "MTD Payment"
{
    Caption = 'VAT Payment';
    LookupPageID = "MTD Payments";

    fields
    {
        field(1; "Start Date"; Date)
        {
            DataClassification = CustomerContent;
        }
        field(2; "End Date"; Date)
        {
            DataClassification = CustomerContent;
        }
        field(3; "Entry No."; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(4; "Received Date"; Date)
        {
            DataClassification = CustomerContent;
        }
        field(5; Amount; Decimal)
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Start Date", "End Date", "Entry No.")
        {
        }
    }

    fieldgroups
    {
    }

    internal procedure DiffersFromPayment(MTDPayment: Record "MTD Payment"): Boolean
    begin
        exit(
          ("Received Date" <> MTDPayment."Received Date") OR
          (Amount <> MTDPayment.Amount));
    end;
}

