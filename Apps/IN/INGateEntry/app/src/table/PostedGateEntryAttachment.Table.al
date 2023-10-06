// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Warehouse.GateEntry;

table 18605 "Posted Gate Entry Attachment"
{
    Caption = 'Posted Gate Entry Attachment';
    LookupPageID = "Posted Gate Attachment List";

    fields
    {
        field(1; "Source Type"; Enum "Gate Entry Source Type")
        {
            Caption = 'Source Type';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(2; "Source No."; Code[20])
        {
            Caption = 'Source No.';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(3; "Entry Type"; Enum "Gate Entry Type")
        {
            Caption = 'Entry Type';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(4; "Gate Entry No."; Code[20])
        {
            Caption = 'Gate Entry No.';
            TableRelation = "Posted Gate Entry Header"."No." where("Entry Type" = field("Entry Type"));
            DataClassification = EndUserIdentifiableInformation;
        }
        field(5; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(6; "Receipt No."; Code[20])
        {
            Caption = 'Receipt No.';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(7; "Warehouse Recpt. No."; Code[20])
        {
            Caption = 'Warehouse Recpt. No.';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(8; "Purchase Invoice No."; Code[20])
        {
            Caption = 'Purchase Invoice No.';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(9; "Sales Credit Memo No."; Code[20])
        {
            Caption = 'Sales Credit Memo No.';
            DataClassification = EndUserIdentifiableInformation;
        }
    }

    keys
    {
        key(Key1; "Source Type", "Source No.", "Entry Type", "Gate Entry No.", "Line No.")
        {
            Clustered = true;
        }
    }
}
