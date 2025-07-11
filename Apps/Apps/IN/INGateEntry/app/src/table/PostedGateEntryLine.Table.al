// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Warehouse.GateEntry;

table 18607 "Posted Gate Entry Line"
{
    Caption = 'Posted Gate Entry Line';
    LookupPageID = "Posted Gate Entry Line List";

    fields
    {
        field(1; "Entry Type"; Enum "Gate Entry Type")
        {
            Caption = 'Entry Type';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(2; "Gate Entry No."; Code[20])
        {
            Caption = 'Gate Entry No.';
            TableRelation = "Posted Gate Entry Header"."No." where("Entry Type" = field("Entry Type"));
            DataClassification = EndUserIdentifiableInformation;
        }
        field(3; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(4; "Source Type"; Enum "Gate Entry Source Type")
        {
            Caption = 'Source Type';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(5; "Source No."; Code[20])
        {
            Caption = 'Source No.';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(6; "Source Name"; Text[30])
        {
            Caption = 'Source Name';
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
        }
        field(7; Status; Enum "Gate Entry Status")
        {
            Caption = 'Status';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(8; Description; Text[80])
        {
            Caption = 'Description';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(9; "Challan No."; Code[20])
        {
            Caption = 'Challan No.';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(10; "Challan Date"; Date)
        {
            Caption = 'Challan Date';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(11; Mark; Boolean)
        {
            Caption = 'Mark';
            DataClassification = EndUserIdentifiableInformation;
        }
    }

    keys
    {
        key(Key1; "Entry Type", "Gate Entry No.", "Line No.")
        {
            Clustered = true;
        }
        key(Key2; "Entry Type", "Source Type", "Source No.", Status)
        {
        }
    }
}
