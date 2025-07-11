// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Payments;

using Microsoft.Finance.Currency;
using Microsoft.Finance.GST.Base;
using Microsoft.Finance.TaxBase;
using Microsoft.Inventory.Location;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;

table 18245 "GST TDS/TCS Entry"
{
    Caption = 'GST TDS/TCS Entry';
    LookupPageId = "GST TDS/TCS Entry";
    DrillDownPageId = "GST TDS/TCS Entry";
    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
            DataClassification = SystemMetadata;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(3; "Location GST Reg. No."; Code[20])
        {
            Caption = 'Location GST Reg. No.';
            DataClassification = CustomerContent;
        }
        field(4; "Location State Code"; Code[10])
        {
            Caption = 'Location State Code';
            DataClassification = CustomerContent;
        }
        field(5; "Buyer/Seller Reg. No."; Code[20])
        {
            Caption = 'Buyer/Seller Reg. No.';
            DataClassification = CustomerContent;
        }
        field(6; "Buyer/Seller State Code"; Code[10])
        {
            Caption = 'Buyer/Seller State Code';
            DataClassification = CustomerContent;
            TableRelation = State;
        }
        field(7; "Place of Supply"; Enum "GST Dependency Type")
        {
            Caption = 'Place of Supply';
            DataClassification = CustomerContent;
        }
        field(8; "Source No."; Code[20])
        {
            Caption = 'Source No.';
            DataClassification = CustomerContent;
            TableRelation = if ("Source Type" = const(Customer)) Customer
            else
            if ("Source Type" = const(Vendor)) Vendor;
        }
        field(9; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
        }
        field(10; "Document Type"; Enum "TDSTCS Document Type")
        {
            Caption = 'Document Type';
            DataClassification = CustomerContent;
        }
        field(11; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        field(12; "GST Component Code"; Code[10])
        {
            Caption = 'GST Component Code';
            DataClassification = CustomerContent;
        }
        field(13; "GST TDS/TCS Base Amount (LCY)"; Decimal)
        {
            Caption = 'GST TDS/TCS Base Amount (LCY)';
            DataClassification = CustomerContent;
        }
        field(14; "GST TDS/TCS Amount (LCY)"; Decimal)
        {
            Caption = 'GST TDS/TCS Amount (LCY)';
            DataClassification = CustomerContent;
        }
        field(15; "GST TDS/TCS %"; Decimal)
        {
            Caption = 'GST TDS/TCS %';
            DataClassification = CustomerContent;
        }
        field(16; "GST Jurisdiction"; Enum "GST Jurisdiction Type")
        {
            Caption = 'GST Jurisdiction';
            DataClassification = CustomerContent;
        }
        field(17; "Certificate Received"; Boolean)
        {
            Caption = 'Certificate Received';
            DataClassification = CustomerContent;
        }
        field(18; "Certificated Received Date"; Date)
        {
            Caption = 'Certificated Received Date';
            DataClassification = CustomerContent;
        }
        field(19; "Certificate No."; Text[100])
        {
            Caption = 'Certificate No.';
            DataClassification = CustomerContent;
        }
        field(20; "Payment Document Date"; Date)
        {
            Caption = 'Payment Document Date';
            DataClassification = CustomerContent;
        }
        field(21; "Payment Document No."; Code[20])
        {
            Caption = 'Payment Document No.';
            DataClassification = CustomerContent;
        }
        field(22; Paid; Boolean)
        {
            Caption = 'Paid';
            DataClassification = CustomerContent;
        }
        field(23; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
            DataClassification = CustomerContent;
        }
        field(24; "Currency Factor"; Decimal)
        {
            Caption = 'Currency Factor';
            DataClassification = CustomerContent;
        }
        field(25; Reversed; Boolean)
        {
            Caption = 'Reversed';
            DataClassification = CustomerContent;
        }
        field(26; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = CustomerContent;
        }
        field(27; "Transaction No."; Integer)
        {
            Caption = 'Transaction No.';
            DataClassification = CustomerContent;
        }
        field(28; Type; Enum "TDSTCS Type")
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
        }
        field(29; "Location ARN No."; Code[20])
        {
            Caption = 'Location ARN No.';
            DataClassification = CustomerContent;
        }
        field(30; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
            DataClassification = CustomerContent;
        }
        field(31; "Source Type"; Enum "Source Type")
        {
            Caption = 'Source Type';
            DataClassification = CustomerContent;
        }
        field(32; "Credit Availed"; Boolean)
        {
            Caption = 'Credit Availed';
            DataClassification = CustomerContent;
        }
        field(33; "Liable to Pay"; Boolean)
        {
            Caption = 'Liable to Pay';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
    }
}
