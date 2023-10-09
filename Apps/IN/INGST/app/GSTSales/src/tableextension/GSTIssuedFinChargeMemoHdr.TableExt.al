// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.FinanceCharge;

using Microsoft.Finance.GST.Base;
using Microsoft.Finance.GST.Sales;
using Microsoft.Finance.TaxBase;
using Microsoft.Inventory.Location;
using Microsoft.Sales.Customer;

tableextension 18160 "GST Issued Fin Charge Memo Hdr" extends "Issued Fin. Charge Memo Header"
{
    fields
    {
        field(18141; "GST Bill-to State Code"; Code[10])
        {
            Caption = 'GST Bill-to State Code';
            TableRelation = State;
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(18142; "GST Ship-to State Code"; Code[10])
        {
            Caption = 'GST Ship-to State Code';
            TableRelation = State;
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(18143; "Location State Code"; Code[10])
        {
            Caption = 'Location State Codee';
            TableRelation = State;
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(18144; "Location GST Reg. No."; Code[20])
        {
            Caption = 'Location GST Reg. No.';
            TableRelation = "GST Registration Nos.";
            DataClassification = CustomerContent;
        }
        field(18145; "Invoice Type"; Enum "GST Inv Type")
        {
            Caption = 'Invoice Type';
            DataClassification = CustomerContent;
        }
        field(18146; "Customer GST Reg. No."; Code[20])
        {
            Caption = 'Customer GST Reg. No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(18147; "GST Customer Type"; Enum "GST Customer Type")
        {
            Caption = 'GST Customer Type';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(18148; "Nature of Supply"; Enum "GST Nature of Supply")
        {
            Caption = 'Nature of Supply';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(18149; "Ship-to Code"; Code[10])
        {
            Caption = 'Ship-to Code';
            TableRelation = "Ship-to Address".Code where("Customer No." = field("Customer No."));
            DataClassification = CustomerContent;
        }
        field(18150; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
            DataClassification = CustomerContent;
        }
        field(18151; "GST Without Payment of Duty"; Boolean)
        {
            Caption = 'GST Without Payment of Duty';
            DataClassification = CustomerContent;
        }
        field(18152; "Ship-to GST Reg. No."; Code[20])
        {
            Caption = 'Ship-to GST Reg. No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }
}
