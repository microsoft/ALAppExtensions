// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.StockTransfer;

using Microsoft.Finance.GST.Base;
using Microsoft.Inventory.Ledger;

table 18390 "GST Tracking Entry"
{
    fields
    {
        field(18390; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
            Editable = false;
            AutoIncrement = true;
        }
        field(18391; "From Entry No."; Integer)
        {
            Caption = 'From Entry No.';
            TableRelation = "Detailed GST Ledger Entry";
            DataClassification = SystemMetadata;
        }
        field(18392; "From To No."; Integer)
        {
            Caption = 'From To No.';
            TableRelation = "Detailed GST Ledger Entry";
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(18393; "Item Ledger Entry No."; Integer)
        {
            Caption = 'Item Ledger Entry No.';
            TableRelation = "Item Ledger Entry";
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(18394; "Quantity"; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(18395; "Remaining Quantity"; Decimal)
        {
            Caption = 'Remaining Quantity';
            Editable = false;
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        Key(PK; "Entry No.")
        {
        }
    }
}
