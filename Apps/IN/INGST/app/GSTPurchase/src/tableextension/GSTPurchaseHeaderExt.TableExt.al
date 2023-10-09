// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Document;

using Microsoft.Finance.GST.Base;
using Microsoft.Finance.TaxBase;
using Microsoft.Foundation.Shipping;
using Microsoft.Inventory.Location;

tableextension 18081 "GST Purchase Header Ext" extends "Purchase Header"
{
    fields
    {
        field(18080; "Nature of Supply"; enum "GST Nature of Supply")
        {
            Caption = 'Nature of Supply';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(18081; "GST Vendor Type"; Enum "GST Vendor Type")
        {
            Caption = 'GST Vendor Type';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(18082; "Associated Enterprises"; Boolean)
        {
            Caption = 'Associated Enterprises';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(18083; "Invoice Type"; enum "GST Invoice Type")
        {
            Caption = 'Invoice Type';
            DataClassification = CustomerContent;
        }
        field(18084; "GST Inv. Rounding Precision"; Decimal)
        {
            Caption = 'GST Inv. Rounding Precision';
            MinValue = 0;
            DataClassification = CustomerContent;
        }
        field(18085; "GST Inv. Rounding Type"; enum "GST Inv Rounding Type")
        {
            Caption = 'GST Inv. Rounding Type';
            DataClassification = CustomerContent;
        }
        field(18086; "Supply Finish Date"; Enum "GST Rate Change")
        {
            Caption = 'Supply Finish Date';
            DataClassification = CustomerContent;
        }
        field(18087; "Payment Date"; enum "GST Rate Change")
        {
            DataClassification = CustomerContent;
            Caption = 'Payment Date';
        }
        field(18088; "Rate Change Applicable"; Boolean)
        {
            Caption = 'Rate Change Applicable';
            DataClassification = CustomerContent;
        }
        field(18089; "GST Reason Type"; enum "GST Reason Type")
        {
            DataClassification = CustomerContent;
            Caption = 'GST Reason Type';
        }
        field(18090; "GST Input Service Distribution"; Boolean)
        {
            Caption = 'GST Input Service Distribution';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(18091; "RCM Exempt"; Boolean)
        {
            Caption = 'RCM Exempt';
            DataClassification = CustomerContent;
        }
        field(18092; "GST Order Address State"; Code[10])
        {
            Caption = 'GST Order Address State';
            DataClassification = CustomerContent;
        }
        field(18093; "Vendor GST Reg. No."; Code[20])
        {
            Caption = 'Vendor GST Reg. No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(18094; "Location State Code"; Code[10])
        {
            Caption = 'Location State Code';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = State;
        }
        field(18095; "Location GST Reg. No."; Code[20])
        {
            Caption = 'Location GST Reg. No.';
            TableRelation = "GST Registration Nos.";
            DataClassification = CustomerContent;
        }
        field(18096; "Order Address GST Reg. No."; Code[20])
        {
            Caption = 'Order Address GST Reg. No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(18097; "Bill to-Location(POS)"; Code[10])
        {
            Caption = 'Bill to-Location(POS)';
            TableRelation = Location where("Use As In-Transit" = const(false));
            DataClassification = CustomerContent;
        }
        field(18098; "Vehicle No."; Code[20])
        {
            Caption = 'Vehicle No.';
            DataClassification = CustomerContent;
        }
        field(18099; "Shipping Agent Code"; Code[10])
        {
            Caption = 'Shipping Agent Code';
            TableRelation = "Shipping Agent";
            DataClassification = CustomerContent;
        }
        field(18100; "Shipping Agent Service Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Shipping Agent Service Code';
            TableRelation = "Shipping Agent Services".Code;
        }
        field(18101; "Distance (Km)"; Decimal)
        {
            Caption = 'Distance (Km)';
            DataClassification = CustomerContent;
        }
        field(18102; "Vehicle Type"; enum "GST Vehicle Type")
        {
            Caption = 'Vehicle Type';
            DataClassification = CustomerContent;
        }
        field(18103; "Reference Invoice No."; Code[20])
        {
            Caption = 'Reference Invoice No.';
            DataClassification = CustomerContent;
        }
        field(18104; "Without Bill Of Entry"; Boolean)
        {
            Caption = 'Without Bill Of Entry';
            DataClassification = CustomerContent;
        }
        field(18105; "E-Way Bill No."; Text[50])
        {
            Caption = 'E-Way Bill No.';
            DataClassification = CustomerContent;
        }
        field(18106; "POS as Vendor State"; Boolean)
        {
            Caption = 'POS as Vendor State';
            DataClassification = CustomerContent;
        }
        field(18107; "POS Out Of India"; Boolean)
        {
            Caption = 'POS Out Of India';
            DataClassification = CustomerContent;
        }
        field(18108; "Bill of Entry No."; text[20])
        {
            Caption = 'Bill of Entry No.';
            DataClassification = CustomerContent;
        }
        field(18109; "Bill of Entry Date"; date)
        {
            caption = 'Bill of Entry Date';
            DataClassification = CustomerContent;
        }
        field(18110; "GST Invoice"; Boolean)
        {
            Caption = 'GST Invoice';
            DataClassification = CustomerContent;
        }
        field(18111; "Bill of Entry Value"; Decimal)
        {
            Caption = 'Bill of Entry Value';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(18112; "Trading"; Boolean)
        {
            Caption = 'Trading';
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
        field(18116; "SubConPostLine"; Integer)
        {
            Caption = 'SubConPostLine';
            DataClassification = CustomerContent;
        }
        field(18117; "Subcon. Multiple Receipt"; Boolean)
        {
            Caption = 'Subcon. Multiple Receipt';
            DataClassification = EndUserIdentifiableInformation;
        }
    }
}
