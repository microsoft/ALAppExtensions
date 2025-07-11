// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Subcontracting;

using Microsoft.Inventory.Item;
using Microsoft.Inventory.Ledger;

table 18472 "Posted Applied DeliveryChallan"
{
    Caption = 'Posted Applied DeliveryChallan';

    fields
    {
        field(1; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            Editable = false;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(2; "Document Line No."; Integer)
        {
            Caption = 'Document Line No.';
            Editable = false;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(3; "Applied Delivery Challan No."; Code[20])
        {
            Caption = 'Applied Delivery Challan No.';
            Editable = false;
            TableRelation = "Delivery Challan Header";
            DataClassification = EndUserIdentifiableInformation;
        }
        field(4; "App. Delivery Challan Line No."; Integer)
        {
            Caption = 'App. Delivery Challan Line No.';
            TableRelation = "Delivery Challan Line"."Line No.";
            DataClassification = EndUserIdentifiableInformation;
        }
        field(5; "Parent Item No."; Code[20])
        {
            Caption = 'Parent Item No.';
            Editable = false;
            TableRelation = Item;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(6; "Line No."; Integer)
        {
            Caption = 'Line No.';
            Editable = false;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(7; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            Editable = false;
            TableRelation = Item;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(8; "Production Order No."; Code[20])
        {
            Caption = 'Production Order No.';
            Editable = false;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(9; "Production Order Line No."; Integer)
        {
            Caption = 'Production Order Line No.';
            Editable = false;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(10; "Qty. to Receive"; Decimal)
        {
            Caption = 'Qty. to Receive';
            DecimalPlaces = 0 : 3;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(11; "Qty. to Consume"; Decimal)
        {
            Caption = 'Qty. to Consume';
            DecimalPlaces = 0 : 3;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(12; "Qty. to Return (C.E.)"; Decimal)
        {
            Caption = 'Qty. to Return (C.E.)';
            DecimalPlaces = 0 : 3;
            Editable = true;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(13; "Qty. To Return (V.E.)"; Decimal)
        {
            Caption = 'Qty. To Return (V.E.)';
            DecimalPlaces = 0 : 3;
            Editable = true;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(14; "Applies-to Entry"; Integer)
        {
            BlankZero = true;
            Caption = 'Applies-to Entry';
            Editable = false;
            TableRelation = "Item Ledger Entry";
            DataClassification = EndUserIdentifiableInformation;
        }
        field(15; "Job Work Return Period"; Integer)
        {
            Caption = 'Job Work Return Period';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(17; "Posted Receipt No."; Code[20])
        {
            Caption = 'Posted Receipt No.';
            DataClassification = EndUserIdentifiableInformation;
        }
    }

    keys
    {
        key(Key1;
        "Document No.",
            "Document Line No.",
            "Parent Item No.",
            "Line No.",
            "Item No.",
            "Applied Delivery Challan No.",
            "App. Delivery Challan Line No.",
            "Posted Receipt No.")
        {
            Clustered = true;
        }
    }
}
