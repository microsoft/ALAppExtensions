// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.StockTransfer;

using Microsoft.Finance.GST.Base;
using Microsoft.Inventory.Transfer;

tableextension 18392 "GST Transfer Line Ext" extends "Transfer Line"
{
    fields
    {
        field(18390; "Transfer Price"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Transfer Price';
        }
        field(18391; "Custom Duty Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Custom Duty Amount';
            MinValue = 0;
        }
        field(18392; Amount; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Amount';
            Editable = false;
        }
        field(18393; "GST Credit"; Enum "GST Credit")
        {
            DataClassification = CustomerContent;
            Caption = 'GST Credit';
        }
        field(18394; "GST Group Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'GST Group Code';
            TableRelation = "GST Group";
            trigger OnValidate()
            begin
                Rec."HSN/SAC Code" := '';
            end;
        }
        field(18395; "HSN/SAC Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'HSN/SAC Code';
            TableRelation = "HSN/SAC".Code where("GST Group Code" = field("GST Group Code"));
        }
        field(18396; Exempted; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Exempted';
            Editable = false;
        }
        field(18397; "GST Assessable Value"; Decimal)
        {
            Caption = 'GST Assessable Value';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(18398; "Amount Added to Inventory"; Decimal)
        {
            Caption = 'Amount Added to Inventory';
            Editable = False;
            DataClassification = CustomerContent;
        }
        field(18399; "Charges to Transfer"; Decimal)
        {
            Caption = 'Charges to Transfer';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }
}
