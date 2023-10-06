// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Subcontracting;

using Microsoft.Inventory.Item;
using Microsoft.Manufacturing.Document;

table 18467 "Applied Delivery Challan Entry"
{
    Caption = 'Applied Delivery Challan Entry';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            Editable = false;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(2; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            Editable = false;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(3; "Document Line No."; Integer)
        {
            Caption = 'Document Line No.';
            Editable = false;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(4; "Applied Delivery Challan No."; Code[20])
        {
            Caption = 'Applied Delivery Challan No.';
            Editable = false;
            TableRelation = "Delivery Challan Header";
            DataClassification = EndUserIdentifiableInformation;
        }
        field(5; "App. Delivery Challan Line No."; Integer)
        {
            Caption = 'App. Delivery Challan Line No.';
            Editable = false;
            TableRelation = "Delivery Challan Line"."Line No.";
            DataClassification = EndUserIdentifiableInformation;
        }
        field(6; "Parent Item No."; Code[20])
        {
            Caption = 'Parent Item No.';
            Editable = false;
            TableRelation = Item;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(7; "Line No."; Integer)
        {
            Caption = 'Line No.';
            Editable = false;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(8; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            Editable = false;
            TableRelation = Item;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(9; "Production Order No."; Code[20])
        {
            Caption = 'Production Order No.';
            Editable = false;
            TableRelation = "Production Order"."No." where(Status = filter(Released));
            DataClassification = EndUserIdentifiableInformation;
        }
        field(10; "Production Order Line No."; Integer)
        {
            Caption = 'Production Order Line No.';
            Editable = false;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(11; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 3;
            Editable = false;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(12; "Type of Quantity"; Option)
        {
            Caption = 'Type of Quantity';
            Editable = false;
            OptionCaption = 'Consume,RejectVE,RejectCE,Receive,Rework';
            OptionMembers = Consume,RejectVE,RejectCE,Receive,Rework;
            DataClassification = EndUserIdentifiableInformation;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Document No.", "Document Line No.", "Applied Delivery Challan No.", "App. Delivery Challan Line No.", "Parent Item No.", "Line No.", "Item No.", "Type of Quantity")
        {
            SumIndexFields = Quantity;
        }
    }
}
