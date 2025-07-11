// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.StockTransfer;

using Microsoft.Finance.GST.Base;
using Microsoft.Inventory.Transfer;
using Microsoft.Purchases.Vendor;

tableextension 18395 "GST Trans. Receipt Header Ext" extends "Transfer Receipt Header"
{
    fields
    {
        field(18390; "Vendor No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Vendor No.';
            TableRelation = Vendor;
        }
        field(18391; "Time of Removal"; Time)
        {
            Caption = 'Time of Removal';
            DataClassification = CustomerContent;
        }
        field(18392; "LR/RR No."; Code[20])
        {
            Caption = 'LR/RR No.';
            DataClassification = CustomerContent;
        }
        field(18393; "LR/RR Date"; Date)
        {
            Caption = 'LR/RR Date';
            DataClassification = CustomerContent;
        }
        field(18394; "Vehicle No."; Code[20])
        {
            Caption = 'Vehicle No.';
            DataClassification = CustomerContent;
        }
        field(18395; "Mode of Transport"; text[15])
        {
            Caption = 'Mode of Transport';
            DataClassification = CustomerContent;
        }
        field(18396; "Bill Of Entry No."; Text[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Bill Of Entry No.';
        }
        field(18397; "Bill Of Entry Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Bill Of Entry Date';
        }
        field(18398; "Distance (Km)"; Decimal)
        {
            Caption = 'Distance (Km)';
            DataClassification = CustomerContent;
        }
        field(18399; "Vehicle Type"; Enum "GST Vehicle Type")
        {
            Caption = 'Vehicle Type';
            DataClassification = CustomerContent;
        }
        field(18400; "Vendor Invoice No."; code[20])
        {
            Caption = 'Vendor Invoice No.';
            DataClassification = CustomerContent;
        }
    }
}
