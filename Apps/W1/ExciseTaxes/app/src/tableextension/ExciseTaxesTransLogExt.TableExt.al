// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.ExciseTaxes;

using Microsoft.FixedAssets.Ledger;
using Microsoft.Foundation.UOM;
using Microsoft.Sustainability.ExciseTax;

tableextension 7414 "Excise Taxes Trans. Log Ext" extends "Sust. Excise Taxes Trans. Log"
{
    fields
    {
        field(7412; "Excise Tax Type"; Code[20])
        {
            Caption = 'Excise Tax Type';
            TableRelation = "Excise Tax Type".Code where(Enabled = const(true));
            DataClassification = CustomerContent;
        }
        field(7413; "Excise Entry Type"; Enum "Excise Entry Type")
        {
            Caption = 'Excise Entry Type';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(7414; "Excise Unit of Measure Code"; Code[10])
        {
            Caption = 'Excise Tax Unit of Measure';
            TableRelation = "Unit of Measure".Code;
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(7415; "Quantity for Excise Tax"; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'Quantity for Excise Tax';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(7416; "Excise Duty"; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'Excise Duty';
            DecimalPlaces = 2 : 5;
            MinValue = 0;
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(7417; "Tax Amount"; Decimal)
        {
            AutoFormatType = 1;
            AutoFormatExpression = '';
            Caption = 'Tax Amount';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(7420; "FA Ledger Entry No."; Integer)
        {
            Caption = 'FA Ledger Entry No.';
            TableRelation = "FA Ledger Entry"."Entry No.";
            DataClassification = CustomerContent;
            Editable = false;
        }
    }
}