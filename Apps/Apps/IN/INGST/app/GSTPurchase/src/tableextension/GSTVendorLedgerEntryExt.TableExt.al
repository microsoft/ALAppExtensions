// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Payables;

using Microsoft.Finance.GST.Base;
using Microsoft.Finance.TaxBase;
using Microsoft.Inventory.Location;

tableextension 18093 "GST Vendor Ledger Entry Ext" extends "Vendor Ledger Entry"
{
    fields
    {
        field(18080; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location where("Use As In-Transit" = const(false));
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(18081; "GST on Advance Payment"; Boolean)
        {
            Caption = 'GST on Advance Payment';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(18082; "HSN/SAC Code"; Code[10])
        {
            Caption = 'HSN/SAC Code';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(18083; "GST Reverse Charge"; Boolean)
        {
            Caption = 'GST Reverse Charge';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(18084; "Adv. Pmt. Adjustment"; Boolean)
        {
            Caption = 'Adv. Pmt. Adjustment';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(18085; "Location State Code"; Code[10])
        {
            Caption = 'Location State Code';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(18086; "Buyer State Code"; Code[10])
        {
            Caption = 'Buyer State Code';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = State;
        }
        field(18087; "Buyer GST Reg. No."; Code[20])
        {
            Caption = 'Buyer GST Reg. No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(18088; "GST Vendor Type"; enum "GST Vendor Type")
        {
            Caption = 'GST Vendor Type';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(18089; "Location GST Reg. No."; Code[20])
        {
            Caption = 'Location GST Reg. No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(18090; "GST Jurisdiction Type"; enum "GST Jurisdiction Type")
        {
            Caption = 'GST Jurisdiction Type';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(18091; "GST Input Service Distribution"; Boolean)
        {
            Caption = 'GST Input Service Distribution';
            DataClassification = CustomerContent;
        }
        field(18092; "GST Group Code"; Code[20])
        {
            Caption = 'GST Group Code';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(18093; "RCM Exempt"; Boolean)
        {
            Caption = 'RCM Exempt';
            DataClassification = CustomerContent;
        }
        field(18094; "GST in Journal"; Boolean)
        {
            Caption = 'GST in Journal';
            DataClassification = CustomerContent;
        }
        field(18095; "Journal Entry"; Boolean)
        {
            Caption = 'Journal Entry';
            DataClassification = CustomerContent;
        }
        field(18096; "Location ARN No."; Code[20])
        {
            Caption = 'Location ARN No.';
            DataClassification = CustomerContent;
        }
        field(18097; "Provisional Entry"; Boolean)
        {
            Caption = 'Provisional Entry';
            DataClassification = CustomerContent;
        }
    }
}
