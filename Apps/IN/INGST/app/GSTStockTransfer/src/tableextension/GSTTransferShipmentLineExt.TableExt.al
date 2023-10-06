// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.StockTransfer;

using Microsoft.Finance.GST.Base;
using Microsoft.Inventory.Transfer;

tableextension 18394 "GST Transfer Shipment Line Ext" extends "Transfer Shipment Line"
{
    fields
    {
        field(18390; "Custom Duty Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Custom Duty Amount';
            MinValue = 0;
        }
        field(18391; Amount; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Amount';
            Editable = false;
        }
        field(18392; "GST Credit"; Enum "GST Credit")
        {
            DataClassification = CustomerContent;
            Caption = 'GST Credit';
            Editable = false;
        }
        field(18393; "GST Group Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'GST Group Code';
            Editable = false;
        }
        field(18394; "HSN/SAC Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'HSN/SAC Code';
            Editable = false;
        }
        field(18395; Exempted; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Exempted';
            Editable = false;
        }
        field(18396; "GST Assessable Value"; Decimal)
        {
            Caption = 'GST Assessable Value';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(18397; "Unit Price"; Decimal)
        {
            Caption = 'Unit Price';
            DataClassification = CustomerContent;
        }
    }
}
