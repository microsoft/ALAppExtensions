// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.History;

using Microsoft.Finance.GST.Base;
using Microsoft.Finance.GST.Purchase;

tableextension 18086 "GST Purch. Cr. Memo Line Ext." extends "Purch. Cr. Memo Line"
{
    fields
    {
        field(18080; "GST Group Code"; Code[20])
        {
            Caption = 'GST Group Code';
            TableRelation = "GST Group";
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(18081; "GST Group Type"; Enum "GST Group Type")
        {
            Caption = 'GST Group Type';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(18082; Exempted; Boolean)
        {
            Caption = 'Exempted';
            DataClassification = CustomerContent;
        }
        field(18083; "GST Jurisdiction Type"; enum "GST Jurisdiction Type")
        {
            Caption = 'GST Jurisdiction Type';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(18084; "Custom Duty Amount"; Decimal)
        {
            Caption = 'Custom Duty Amount';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(18085; "GST Reverse Charge"; Boolean)
        {
            Caption = 'GST Reverse Charge';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(18086; "GST Assessable Value"; Decimal)
        {
            Caption = 'GST Assessable Value';
            MinValue = 0;
            DataClassification = CustomerContent;
        }
        field(18087; "Order Address Code"; Code[10])
        {
            Caption = 'Order Address Code';
            DataClassification = CustomerContent;
        }
        field(18088; "Buy-From GST Registration No"; Code[20])
        {
            Caption = 'Buy-From GST Registration No';
            DataClassification = CustomerContent;
        }
        field(18089; "GST Rounding Line"; Boolean)
        {
            Caption = 'GST Rounding Line';
            DataClassification = CustomerContent;
        }
        field(18090; "Bill to-Location(POS)"; Code[20])
        {
            Caption = 'Bill to-Location(POS)';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(18091; "Non-GST Line"; Boolean)
        {
            Caption = 'Non-GST Line';
            DataClassification = CustomerContent;
        }
        field(18092; "Supplementary"; Boolean)
        {
            Caption = 'Supplementary';
            DataClassification = CustomerContent;
        }
        field(18093; "Source Document Type"; Enum "GST Source Document Type")
        {
            Caption = 'Source Document Type';
            DataClassification = CustomerContent;
        }
        field(18094; "Source Document No."; Code[20])
        {
            Caption = 'Source Document No.';
            DataClassification = CustomerContent;
            TableRelation = if ("Source Document Type" = filter("Posted Invoice")) "Purch. Inv. Header"."No."
            else
            if ("Source Document Type" = filter("Posted Credit Memo")) "Purch. Cr. Memo Hdr."."No.";
        }
        field(18095; "GST Credit"; Enum "GST Credit")
        {
            Caption = 'GST Credit';
            DataClassification = CustomerContent;
        }
        field(18096; "HSN/SAC Code"; Code[10])
        {
            Caption = 'HSN/SAC Code';
            DataClassification = CustomerContent;
        }
        field(18113; Subcontracting; Boolean)
        {
            Caption = 'Subcontracting';
            DataClassification = CustomerContent;
        }
        field(18114; "Subcon. Order No."; Code[20])
        {
            Caption = 'Subcon. Order No.';
            DataClassification = CustomerContent;
        }
        field(18115; "Subcon. Order Line No."; Integer)
        {
            Caption = 'Subcon. Order Line No.';
            DataClassification = CustomerContent;
        }
        field(18137; "GST Vendor Type"; Enum "GST Vendor Type")
        {
            Caption = 'GST Vendor Type';
            Editable = false;
            DataClassification = CustomerContent;
        }
    }
}
